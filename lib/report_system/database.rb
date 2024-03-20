# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'artists'
require 'ips'
require 'locations'
require 'records'
require 'songs'

module ReportSystem
  module Database
    extend self

    def artists_alphabetized
       @artists_alphabetized ||= begin
        artists = Artists.artists
        keys_sorted = artists.keys.sort do |a, b|
          [a.artist.upcase, artists[a]] <=> [b.artist.upcase, artists[b]]
        end
        keys_sorted.map { |key| [key, artists[key]] }
      end
    end

    def artists_by_popularity
       @artists_by_popularity ||= begin
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
    end

    def ips_alphabetized
       @ips_alphabetized ||= begin
        ips = Ips.ips
        keys_sorted = ips.keys.sort do |a, b|
          [a.ip, ips[a]] <=> [b.ip, ips[b]]
        end
        keys_sorted.map { |key| [key, ips[key]] }
      end
    end

    def ips_by_frequency
       @ips_by_frequency ||= begin
        ips = Ips.ips
        keys_sorted = ips.keys.sort do |a, b|
          unless ips[a] == ips[b]
            ips[b] <=> ips[a]
          else
            a.ip <=> b.ip
          end
        end
        keys_sorted.map { |key| [key, ips[key]] }
      end
    end

    def likes_count
       @likes_count ||= Records.records.select { |e| :l == e.toggle }.length
    end

    def locations_by_frequency
       @locations_by_frequency ||= begin
        locations = Locations.locations
        keys_sorted = locations.keys.sort do |a, b|
          unless locations[a] == locations[b]
            locations[b] <=> locations[a]
          else
            [    a.city, a.region_name, a.country, a.continent, a.isp] <=>
                [b.city, b.region_name, b.country, b.continent, b.isp]
          end
        end
        keys_sorted.map { |key| [key, locations[key]] }
      end
    end

    def songs_alphabetized_by_artist
       @songs_alphabetized_by_artist ||= begin
        songs = Songs.songs
        keys_sorted = songs.keys.sort do |a, b|
          [    a.artist.upcase, a.title.upcase, songs[a]] <=>
              [b.artist.upcase, b.title.upcase, songs[b]]
        end
        keys_sorted.map { |key| [key, songs[key]] }
      end
    end

    def songs_by_popularity
       @songs_by_popularity ||= begin
        songs = Songs.songs
        keys_sorted = songs.keys.sort do |a, b|
          unless songs[a] == songs[b]
            songs[b] <=> songs[a]
          else
            [    a.artist.upcase, a.title.upcase] <=>
                [b.artist.upcase, b.title.upcase]
          end
        end
        keys_sorted.map { |key| [key, songs[key]] }
      end
    end

    def unlikes_count
       @unlikes_count ||= Records.records.select { |e| :u == e.toggle }.length
    end
  end
end
