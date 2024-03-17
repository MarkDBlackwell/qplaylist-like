# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'date'
require 'open-uri'

# TODO: Report the geographic regions of the liking IPs.
# TODO: Register with ip-api.com?

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
      artists = Artists.artists
      keys_sorted = artists.keys.sort do |a, b|
        [a.artist.upcase, artists[a]] <=> [b.artist.upcase, artists[b]]
      end
      keys_sorted.map { |key| [key, artists[key]] }
    end

    def artists_by_popularity
      artists = Artists.artists
      keys_sorted = artists.keys.sort do |a, b|
        unless artists[a] == artists[b]
          artists[b] <=> artists[a]
        else
          a.artist.upcase <=> b.artist.upcase
        end
      end
      keys_sorted.map { |key| [key, artists[key]] }
    end

    def likes_count
      @likes_count ||= Records.records.select { |e| :l == e.toggle }.length
    end

    def songs_alphabetized_by_artist
      songs = Songs.songs
      keys_sorted = songs.keys.sort do |a, b|
        [a.artist.upcase, a.title.upcase, songs[a]] <=> [b.artist.upcase, b.title.upcase, songs[b]]
      end
      keys_sorted.map { |key| [key, songs[key]] }
    end

    def songs_by_popularity
      songs = Songs.songs
      keys_sorted = songs.keys.sort do |a, b|
        unless songs[a] == songs[b]
          songs[b] <=> songs[a]
        else
          [a.artist.upcase, a.title.upcase] <=> [b.artist.upcase, b.title.upcase]
        end
      end
      keys_sorted.map { |key| [key, songs[key]] }
    end

    def unlikes_count
      @unlikes_count ||= Records.records.select { |e| :u == e.toggle }.length
    end
  end

  module Ips
    extend self

    attr_reader :ips

    Ip = ::Data.define :ip

    @ips = ::Hash.new 0

    def build
      Records.records.each { |e| @ips[Ip.new e.ip] += 1 }
      nil
    end
  end

  module Locations
    extend self

    attr_reader :locations

    Location = ::Data.define :city, :continent, :country, :isp, :region_name

    @locations = ::Hash.new 0

    def build
      Ips.ips.each_pair { |key, count| @locations[Location.new *(fields key.ip)] += count }
      nil
    end

    private

    def fields(ip)
# TODO: Use API.
# http://ip-api.com/json/24.48.0.1?fields=status,message,city,continent,country,regionName

      ['Ashburn', 'North America', 'United States', 'AT&T Corp.', 'Virginia']
    end
  end

  module Main
    extend self

    FILENAME_OUT = 'var/song-likes-report-first.txt'

    FIRST = begin
      argument = ::ARGV[0]
      message = 'The first command-line argument must be a valid date.'
      ::Kernel.abort message unless argument
      ::Date.parse argument
    end

    LAST = begin
      yesterday = ::Date.today - 1
      argument = ::ARGV[1]
      argument ? (::Date.parse argument) : yesterday
    end

    def run
      $stdout = ::File.open FILENAME_OUT, 'w'
      s = ::Time.now.strftime '%Y-%b-%d %H:%M:%S'
      puts "WTMD Song Likes Report, run #{s}."
      puts "Range of dates: #{FIRST} through #{LAST} (inclusive)."
      Window.define FIRST, LAST
      Records.transcribe
      Songs.build
      Artists.build
      Ips.build
      Locations.build
      Report.print_report
      nil
    end
  end

  module Records
    extend self

    attr_reader :records

# The matched fields are: time, ip, toggle, artist, and title.
#                              time       ip         toggle       artist          title
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
    OUT_THIRD = ::File.open 'var/song-likes-report-third.txt', 'w'

    def print_report
      print_summary
      print_popularity
      print_alphabetical
      print_locations
      nil
    end

    private

    def print_alphabetical
      OUT_SECOND.puts "Songs (alphabetical by artist):\n\n"
      a = Database.songs_alphabetized_by_artist
      OUT_SECOND.puts a.map { |key, count| "#{count} : #{key.title} : #{key.artist}" }

      OUT_SECOND.puts "\nArtists (alphabetical):\n\n"
      a = Database.artists_alphabetized
      OUT_SECOND.puts a.map { |key, count| "#{count} : #{key.artist}" }
      nil
    end

    def print_locations
      OUT_THIRD.puts "Locations:\n\n"
      lines = Locations.locations.map do |key, count|
        fields = [key.city, key.region_name, key.country, key.continent]
        "#{count} : #{fields.join ', '}. (#{key.isp})"
      end
      OUT_THIRD.puts lines
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
      print "#{Database.likes_count} Likes and "
      print "#{Database.unlikes_count} Unlikes from "
      puts "#{Ips.ips.length} IPs."
      puts "#{Artists.artists.length} artists and"
      puts "#{Songs.songs.length} songs."
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
      @songs = filter
      nil
    end

    private

    def add(artist, title, toggle)
      addend = :l == toggle ? 1 : -1
      @raw[Song.new artist, title] += addend
      nil
    end

    def filter
      @raw.reject do |key, count|
        all_empty = key.artist.empty? && key.title.empty?
# An Unlike in our window may be paired with a Like prior to it.
        all_empty || count <= 0
      end
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
