# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'date'

$LOAD_PATH.unshift(::File.dirname __FILE__)

require 'artists'
require 'ips'
require 'locations'
require 'records'
require 'report'
require 'songs'
require 'window'

module ReportSystem
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
# %Y is year including century, zero-padded.
# %b is abbreviated month name, capitalized.
# %d is day of the month, in range (1..31), zero-padded.
# %H:%M:%S is zero-padded hour (of 24), minute, second.
      s = ::Time.now.strftime '%Y-%b-%d %H:%M:%S'
      print "WTMD Song Likes Report, run #{s}.\n\n"
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
end

::ReportSystem::Main.run
