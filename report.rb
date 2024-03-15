# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'date'
require 'open-uri'

module ReportSystem
  module Artists
    extend self

    attr_reader :artists

    Artist = ::Data.define :artist

    @artists = ::Hash.new 0

    def build
      Songs.songs.each_pair { |key, count| @artists[Artist.new key.artist] += count }
      nil
    end
  end

  module Database
    extend self

    def artists_alphabetized
      keys_sorted = Artists.artists.keys.sort do |a, b|
        [a.artist.upcase, Artists.artists[a]] <=> [b.artist.upcase, Artists.artists[b]]
      end
      keys_sorted.map { |key| [key, Artists.artists[key]] }
    end

    def artists_by_popularity
      keys_sorted = Artists.artists.keys.sort do |a, b|
        unless Artists.artists[a] == Artists.artists[b]
          Artists.artists[b] <=> Artists.artists[a]
        else
          a.artist.upcase <=> b.artist.upcase
        end
      end
      keys_sorted.map { |key| [key, Artists.artists[key]] }
    end

    def artists_count
      Artists.artists.length
    end

    def songs_alphabetized_by_artist
      keys_sorted = Songs.songs.keys.sort do |a, b|
        [a.artist.upcase, a.title.upcase, Songs.songs[a]] <=> [b.artist.upcase, b.title.upcase, Songs.songs[b]]
      end
      keys_sorted.map { |key| [key, Songs.songs[key]] }
    end

    def songs_by_popularity
      keys_sorted = Songs.songs.keys.sort do |a, b|
        unless Songs.songs[a] == Songs.songs[b]
          Songs.songs[b] <=> Songs.songs[a]
        else
          [a.artist.upcase, a.title.upcase] <=> [b.artist.upcase, b.title.upcase]
        end
      end
      keys_sorted.map { |key| [key, Songs.songs[key]] }
    end

    def songs_count
      Songs.songs.length
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
      Records.transcribe
      Songs.build
      Artists.build
      Report.print_summary
      Report.print_popularity
      Report.print_alphabetical
      nil
    end
  end

  module Records
    extend self

    attr_reader :records

# The matched fields are: Time, IP, Toggle, Artist, and Title.
#                              Time       IP         Toggle       Artist          Title
    REGEXP = ::Regexp.new(/^ *+([^ ]++) ++([^ ]++) ++([lu]) ++" *+(.*?) *+" ++" *+(.*?) *+" *+$/n)

    TIME_INDEX = 1
    URI_IN = 'https://wtmd.org/like/like.txt'

# Depends on previous:
    LINES = ::URI.open(URI_IN) { |f| f.readlines }

    Record = ::Data.define :time, :ip, :toggle, :artist, :title

    @records = []

    def transcribe
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
      nil
    end
  end

  module Report
    extend self

    OUT_SECOND = ::File.open 'var/song-likes-report-second.txt', 'w'

    def print_alphabetical
      OUT_SECOND.puts "Songs (alphabetical by artist):\n\n"
      a = Database.songs_alphabetized_by_artist
      OUT_SECOND.puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      OUT_SECOND.puts "\nArtists (alphabetical):\n\n"
      a = Database.artists_alphabetized
      OUT_SECOND.puts a.map { |key, count| "#{count} : #{key.artist}" }
      nil
    end

    def print_popularity
      puts "\nSong popularity:\n\n"
      a = Database.songs_by_popularity
      puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      puts "\nArtist popularity:\n\n"
      a = Database.artists_by_popularity
      puts a.map { |key, count| "#{count} : #{key.artist}" }
      nil
    end

    def print_summary
      puts "#{Database.artists_count} artists and"
      puts "#{Database.songs_count} songs."
      nil
    end
  end

  module Songs
    extend self

    attr_reader :songs

    Song = ::Data.define :artist, :title

    @raw = ::Hash.new 0

    def build
      Records.records.each { |e| add(e.artist, e.title, e.toggle) }
      filter
    end

    private

    def add(artist, title, toggle)
      addend = :l == toggle ? 1 : -1
      key = Song.new artist, title
      @raw[key] += addend
      nil
    end

    def filter
      @songs = @raw.reject do |key, count|
        all_empty = key.artist.empty? && key.title.empty?
# An Unlike in our window may be paired with a Like prior to it.
        all_empty || count <= 0
      end
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
