# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'date'
require 'open-uri'

module ReportSystem
  module SongDatabase
    extend self

    Artist = ::Data.define :artist
    Song = ::Data.define :artist, :title

    @artists = ::Hash.new 0
    @likes_raw = ::Hash.new 0
    @songs = ::Hash.new 0

    def add(artist, title, toggle)
      addend = :l == toggle ? 1 : -1
      key = Song.new artist, title
      @likes_raw[key] += addend
      nil
    end

    def artists_alphabetized
      keys_sorted = @artists.keys.sort do |a, b|
        [a.artist.upcase, @artists[a]] <=> [b.artist.upcase, @artists[b]]
      end
      keys_sorted.map { |key| [key, @artists[key]] }
    end

    def artists_by_popularity
      keys_sorted = @artists.keys.sort do |a, b|
        unless @artists[a] == @artists[b]
          @artists[b] <=> @artists[a]
        else
          a.artist.upcase <=> b.artist.upcase
        end
      end
      keys_sorted.map { |key| [key, @artists[key]] }
    end

    def artists_count
      @artists.length
    end

    def process
      @likes = @likes_raw.reject do |key, value|
        all_empty = key.artist.empty? && key.title.empty?
# Handle any Like/Unlike pairs which span a border date.
        all_empty || value <= 0
      end
      @likes.keys.each do |key|
        count = @likes[key]
        @songs[key] += count
        artist = Artist.new key.artist
        @artists[artist] += count
      end
      nil
    end

    def songs_alphabetized_by_artist
      keys_sorted = @songs.keys.sort do |a, b|
        [a.artist.upcase, a.title.upcase, @songs[a]] <=> [b.artist.upcase, b.title.upcase, @songs[b]]
      end
      keys_sorted.map { |key| [key, @songs[key]] }
    end

    def songs_by_popularity
      keys_sorted = @songs.keys.sort do |a, b|
        unless @songs[a] == @songs[b]
          @songs[b] <=> @songs[a]
        else
          [a.artist.upcase, a.title.upcase] <=> [b.artist.upcase, b.title.upcase]
        end
      end
      keys_sorted.map { |key| [key, @songs[key]] }
    end

    def songs_count
      @songs.length
    end
  end

  module Main
    extend self

    FILENAME_OUT = 'var/song-likes-report-first.txt'

    FIRST = begin
      argument = ::ARGV[0]
      message = "The first command-line argument must be a valid date."
      ::Kernel.abort message unless argument
      ::Date.parse argument
    end

    LAST = begin
      yesterday = ::Date.today - 1
      argument = ::ARGV[1]
      argument ? (::Date.parse argument) : yesterday
    end

    def run
      $stdout = File.open FILENAME_OUT, 'w'
      puts "Range of dates: #{FIRST} through #{LAST} (inclusive)."
      Window.define FIRST, LAST
      Records.build
      SongDatabase.process
      Report.print_summary
      Report.print_popularity
      Report.print_alphabetical
      nil
    end
  end

  module Report
    extend self

    OUT_SECOND = ::File.open 'var/song-likes-report-second.txt', 'w'

    def print_alphabetical
      OUT_SECOND.puts "Songs (alphabetical by artist):\n\n"
      a = SongDatabase.songs_alphabetized_by_artist
      OUT_SECOND.puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      OUT_SECOND.puts "\nArtists (alphabetical):\n\n"
      a = SongDatabase.artists_alphabetized
      OUT_SECOND.puts a.map { |key, count| "#{count} : #{key.artist}" }
      nil
    end

    def print_popularity
      puts "\nSong popularity:\n\n"
      a = SongDatabase.songs_by_popularity
      puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      puts "\nArtist popularity:\n\n"
      a = SongDatabase.artists_by_popularity
      puts a.map { |key, count| "#{count} : #{key.artist}" }
      nil
    end

    def print_summary
      puts "#{SongDatabase.artists_count} artists and"
      puts "#{SongDatabase.songs_count} songs."
      nil
    end
  end

  module Records
    extend self

    Record = ::Data.define :time, :ip, :toggle, :artist, :title

# The matched fields are: Time, IP, Toggle, Artist, and Title.
#                              Time       IP         Toggle       Artist          Title
    REGEXP = ::Regexp.new(/^ *+([^ ]++) ++([^ ]++) ++([lu]) ++" *+(.*?) *+" ++" *+(.*?) *+" *+$/n)

    TIME_INDEX = 1
    URI_IN = 'https://wtmd.org/like/like.txt'

# Depends on previous:

    LINES = ::URI.open(URI_IN) { |f| f.readlines }

    @records = []

    def build
      lines_count_within = 0
      lines_count_bad = 0

      LINES.map do |line|
        md = REGEXP.match line
        unless md
          lines_count_bad += 1
          next 
        end
        fields = 5.times.map { |i| md[i.succ].to_sym }
        if Window.within? md[TIME_INDEX]
          lines_count_within += 1
          @records.push Record.new(*fields)
        end
      end
      message = "Warning: #{lines_count_bad} interaction records were bad.\n"
      $stderr.puts message if lines_count_bad > 0
      puts "#{LINES.length} total customer interactions read. Within the selected range of dates:"
      puts "#{lines_count_within} interactions found, comprising"
# The Report module prints next.
      @records.each { |e| SongDatabase.add(e.artist, e.title, e.toggle) }
      nil
    end
  end

  module Window
    extend self

    def define(*parms)
      @beginning, @ending = parms
      nil
    end

    def within?(date_raw)
      date = ::Date.iso8601 date_raw
      date >= @beginning &&
          date <= @ending
    end
  end
end

::ReportSystem::Main.run
