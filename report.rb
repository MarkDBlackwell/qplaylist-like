
# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

#time ip toggle artist title
#time, ip, toggle, artist, title
#times, ips, toggles, artists, titles
# [times, ips, toggles, artists, titles].map { |e| puts e }
#times, ips, toggles, artists, titles = unpacked.transpose
# unpacked.map { |e| puts e.join ' : '}
#puts artists.sort.uniq.join(':')
#puts titles.sort.uniq.join(':')

=begin
  class Likes
    attr_reader :like
    def initialize(like)
      @like = like
    end
  end

  class LikesByArtistTitleToggle < Likes
    def <=>(other)
      self.like.
      artist, title, toggle <=> other.like.artist
    end
  end

  class Song < Array
    attr_reader :artist, :title, :count
    def initialize(artist, title, count)
      @artist, @title, @count = artist, title, count
    end
  end

  class SongLike
    attr_reader :time, :ip, :artist, :title

    def initialize(time, ip, artist, title)
      @time, @ip, @artist, @title = time, ip, artist, title
    end
  end
  class Like < Array
    attr_reader :time, :ip, :toggle, :artist, :title

    def initialize(time, ip, toggle, artist, title)
      @time, @ip, @toggle, @artist, @title = time, ip, toggle, artist, title
    end
  end
    def songs
  end
    def artist_count(artist)
    end

    def artists
    end

    def songs
    end

    def titles
    end

    def likes(artist, title)
      key = [artist, title]
      @likes[key]
    end

    def songs
      @likes.keys
    end

=end
#####################################################################

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
      time_start = Window.year_month_day_utc 2024, 2, 1
      Window.define time_start

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
      time_field_match_index = 1
      bad_lines_count = 0
      lines.map do |line|
        md = regexp.match line
        unless md
          bad_lines_count += 1
          next 
        end
        fields = 5.times.map { |i| md[i.succ].to_sym }
        @raw.push Record.new(*fields) if Window.within? md[time_field_match_index]
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

    def define(t_start, t_end = ::Time.now)
      @time_start, @time_end = t_start, t_end
    end

    def within?(time)
      true
    end

    def year_month_day_utc(year, month, day)
      ::Time.new year, month, day, nil, nil, nil, 'Z'
    end
  end
end

::Report::Main.run
