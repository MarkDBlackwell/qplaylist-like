# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'records'

module ReportSystem
  module Ips
    extend self

    attr_reader :ips

    Ip = ::Data.define :ip

    @ips = ::Hash.new 0

    def build
      Records.records.each do |record|
        key = Ip.new record.ip.downcase
        @ips[key] += 1
      end
      nil
    end
  end
end
