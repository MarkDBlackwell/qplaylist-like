# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'records'

module ReportSystem
  module Songs
    extend self

    attr_reader :songs

    Song = ::Data.define :artist, :title

    @raw = ::Hash.new 0

    def build
      Records.records.each { |e| add(e.artist, e.title, e.toggle) }
      @songs = filter
      @raw = nil
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
end
