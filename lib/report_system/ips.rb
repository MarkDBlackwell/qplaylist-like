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
#       test_ip_bad record.ip.downcase
      end
      nil
    end

    private

    def test_ip_bad(good)
      ip_bad = "1#{good}".to_sym
      key_bad = Ip.new ip_bad
      @ips[key_bad] += 1
    end
  end
end
