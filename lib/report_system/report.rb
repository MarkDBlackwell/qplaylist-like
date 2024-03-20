# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'artists'
require 'database'
require 'ips'
require 'locations'
require 'songs'

module ReportSystem
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
# Temporarily, for development, report the IPs:
      OUT_THIRD.puts "( IPs by frequency ):\n\n"
      a = Database.ips_by_frequency
      OUT_THIRD.puts a.map { |key, count| "( #{count} : #{key.ip} )" }
      OUT_THIRD.puts ""

# Report the locations:
      OUT_THIRD.puts "Locations (by frequency):\n\n"
      a = Database.locations_by_frequency
      lines = a.map do |k, count|
        fields = [k.city, k.region_name, k.country, k.continent]
        "#{count} : #{fields.join ', '} – (#{k.isp})"
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
      print "#{Database.likes_count} likes and "
      puts "#{Database.unlikes_count} unlikes from"
      print "#{Locations.locations.length} locations "
      puts "(#{Ips.ips.length} IPs),"
      puts "#{Artists.artists.length} artists and"
      puts "#{Songs.songs.length} songs."
      nil
    end
  end
end
