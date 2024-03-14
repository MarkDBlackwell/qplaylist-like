# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'date'

module ReportSystem
  Artist = ::Struct.new('Artist', :artist)

  Record = ::Struct.new('Record', :time, :ip, :toggle, :artist, :title)

  Song = ::Struct.new('Song', :artist, :title)

  module Likes
    extend self

    @artists = ::Hash.new 0
    @likes = ::Hash.new 0
    @songs = ::Hash.new 0

    def add(artist, title, toggle)
      addend = :l == toggle ? 1 : -1
      key = Song.new artist, title
      @likes[key] = @likes[key] + addend
      nil # Return nil.
    end

    def artists_alphabetized
      keys_sorted = @artists.keys.sort { |a, b| [a.artist, @artists[a]] <=> [b.artist, @artists[b]] }
      keys_sorted.map { |key| [key, @artists[key]] }
    end

    def artists_by_popularity
      keys_sorted = @artists.keys.sort { |b, a| [@artists[a], a.artist] <=> [@artists[b], b.artist] }
      keys_sorted.map { |key| [key, @artists[key]] }
    end

    def artists_count
      @artists.length
    end

    def process
      @likes = @likes.reject do |key, value|
        key.artist.empty? ||
        key.title.empty? ||
        value <= 0
      end
      @likes.keys.each do |key|
        count = @likes[key]
        @songs[key] = @songs[key] + count
        artist = Artist.new key.artist
        @artists[artist] = @artists[artist] + count
      end
      nil # Return nil.
    end

    def songs_alphabetized_by_artist
      keys_sorted = @songs.keys.sort { |a, b| [a.artist, a.title, @songs[a]] <=> [b.artist, b.title, @songs[b]] }
      keys_sorted.map { |key| [key, @songs[key]] }
    end

    def songs_by_popularity
      keys_sorted = @songs.keys.sort { |b, a| [@songs[a], a.artist, a.title] <=> [@songs[b], b.artist, b.title] }
      keys_sorted.map { |key| [key, @songs[key]] }
    end

    def songs_count
      @songs.length
    end
  end

  module Main
    extend self

    def run
      start = ::Date.new 2024, 2, 29
      end_with = ::Date.new 2024, 3, 31
      puts "Range of dates: #{start} through #{end_with} (inclusive)."
      Window.define start, end_with
      SongDatabase.build
      Likes.process
      Reports.process
      nil # Return nil.
    end
  end

  module Reports
    extend self

    def process
#time ip toggle artist title
#time, ip, toggle, artist, title
#times, ips, toggles, artists, titles

# [times, ips, toggles, artists, titles].map { |e| puts e }
#times, ips, toggles, artists, titles = unpacked.transpose
# unpacked.map { |e| puts e.join ' : '}
#puts artists.sort.uniq.join(':')
#puts titles.sort.uniq.join(':')

      print "#{Likes.artists_count} artists and\n"
      print "#{Likes.songs_count} songs.\n"

      print "\nSong popularity:\n\n"
      a = Likes.songs_by_popularity
      puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      print "\nSongs (alphabetical by artist):\n\n"
      a = Likes.songs_alphabetized_by_artist
      puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      print "\nArtist popularity:\n\n"
      a = Likes.artists_by_popularity
      puts a.map { |key, count| "#{count} : #{key.artist}" }

      print "\nArtists (alphabetical):\n\n"
      a = Likes.artists_alphabetized
      puts a.map { |key, count| "#{count} : #{key.artist}" }
      nil # Return nil.
    end
  end

  module SongDatabase
    extend self

    FILENAME = 'var/like.txt'
    TIME_INDEX = 1

# The matched fields are: Time, IP, Toggle, Artist, and Title.
#                              Time       IP         Toggle       Artist          Title
    REGEXP = ::Regexp.new(/^ *+([^ ]++) ++([^ ]++) ++([lu]) ++" *+(.*?) *+" ++" *+(.*?) *+" *+$/n)

    @raw = []

    def build
      lines_count_within = 0
      lines_count_bad = 0

      lines.map do |line|
        md = REGEXP.match line
        unless md
          lines_count_bad += 1
          next 
        end
        fields = 5.times.map { |i| md[i.succ].to_sym }
        if Window.within? md[TIME_INDEX]
          lines_count_within += 1
          @raw.push Record.new(*fields)
        end
      end
      message = "Warning: #{lines_count_bad} lines were bad.\n\n"
      print message if lines_count_bad > 0
      puts "#{lines.length} lines read."
      puts "Within the selected range of dates: #{lines_count_within} lines found, comprising"
      @raw.each { |e| Likes.add(e.artist, e.title, e.toggle) }
      nil # Return nil.
    end

    private

    def lines
      @lines ||= ::IO.readlines(FILENAME).map &:chomp
    end
  end

  module Window
    extend self

    def define(beginning, ending = nil)
      @beginning, @ending = beginning, ending
      nil # Return nil.
    end

    def within?(date_raw)
      date = ::Date.iso8601 date_raw
      unless @ending
        @beginning <= date
      else
        @beginning <= date &&
        date <= @ending
      end
    end
  end
end

::ReportSystem::Main.run
