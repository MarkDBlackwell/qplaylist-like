# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'date'

#time ip toggle artist title
#time, ip, toggle, artist, title
#times, ips, toggles, artists, titles

# [times, ips, toggles, artists, titles].map { |e| puts e }
#times, ips, toggles, artists, titles = unpacked.transpose
# unpacked.map { |e| puts e.join ' : '}
#puts artists.sort.uniq.join(':')
#puts titles.sort.uniq.join(':')

module Report
  Artist = ::Struct.new('Artist', :artist, :count)

  Record = ::Struct.new('Record', :time, :ip, :toggle, :artist, :title)

  Song = ::Struct.new('Song', :artist, :title, :count)

  module Likes
    extend self

    @artists = ::Hash.new 0
    @likes = ::Hash.new 0
    @songs = ::Hash.new 0

    def add(artist, title, toggle)
      addend = 'l' == toggle ? 1 : -1
      key = [artist, title]
      @likes[key] = @likes[key] + addend
    end

    def artists
      @artists.to_a
    end

    def process
      @likes.keys.each do |key|
        artist, title = key
        count = @likes[key]
        @songs[key] = @songs[key] + count
        @artists[artist] = @artists[artist] + count
      end
    end

    def songs
      @songs.to_a
    end
  end

  module Main
    extend self

    def run
      start = ::Date.new 2024, 3, 12
      end_with = ::Date.new 2024, 3, 12
      Window.define start, end_with
      SongDatabase.build
      process
    end

    private

    def process
      puts "Song popularity"
      puts Likes.songs.length
      puts "Song popularity alphabetized by artist"
      puts Likes.songs.length
      puts "Artist popularity"
      puts Likes.artists.length
      puts "Artist popularity alphabetized by artist"
      puts Likes.artists.length
      puts
    end
  end

  module SongDatabase
    extend self

    @raw = []

    def build
      time_index = 1
      bad_lines_count = 0
      lines.map do |line|
        md = regexp.match line
        unless md
          bad_lines_count += 1
          next 
        end
        fields = 5.times.map { |i| md[i.succ].to_sym }
        @raw.push Record.new(*fields) if Window.within? md[time_index]
      end
      print "Warning: #{bad_lines_count} lines were bad.\n\n" if bad_lines_count > 0
      @raw.each { |e| Likes.add(e.artist, e.title, e.toggle) }
      Likes.process
    end

    private

    def filename
      @filename ||= 'var/like.txt'
    end

    def lines
      @lines ||= ::IO.readlines(filename).map &:chomp
    end

    def regexp
# The matched fields are: Time, IP, Toggle, Artist, and Title.
#                                   Time       IP         Toggle       Artist          Title
      @regexp ||= ::Regexp.new(/^ *+([^ ]++) ++([^ ]++) ++([lu]) ++" *+(.*?) *+" ++" *+(.*?) *+" *+$/n)
    end
  end

  module Window
    extend self

    def define(beginning, ending = nil)
      @beginning, @ending = beginning, ending
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

::Report::Main.run
