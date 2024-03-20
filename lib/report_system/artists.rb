# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'songs'

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
end
