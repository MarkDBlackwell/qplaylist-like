# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require 'json'
require 'net/http'
require 'uri'

require 'database'

module ReportSystem
  module Locations
    extend self

    BATCH_LENGTH_MAX = 100
# TODO: possibly register with this service organization.
    ENDPOINT = ::URI::HTTP.build host: 'ip-api.com', path: '/batch', query: 'fields=city,continent,country,isp,message,query,regionName,status'
    HEADERS = {Accept: 'application/json', Connection: 'Keep-Alive', 'Content-Type': 'application/json'}

    attr_reader :locations

    Location = ::Data.define :city, :continent, :country, :isp, :region_name

    @locations = ::Hash.new 0

    def build
      requests_remaining, seconds_till_next_window = [15, 60]
      a = Database.ips_alphabetized
      a.each_slice BATCH_LENGTH_MAX do |batch|
        keys, counts = batch.transpose
        delay requests_remaining, seconds_till_next_window
        begin
          response = service_fetch keys, counts
          add response, counts
          requests_remaining, seconds_till_next_window = timings response
        rescue
          $stderr.puts "Rescued #{response.inspect}"
        end
      end
      nil
    end

    private

    def add(response, counts)
      ::JSON.parse(response.body).each_with_index do |ip_data, index|
        status = ip_data['status']
#       $stderr.puts "#{ip_data.inspect}"
        unless 'success' == status
          $stderr.puts "status: #{status}, message: #{ip_data['message']}, query: #{ip_data['query']}"
          next
        end
        fields = %w[city continent country isp regionName].map { |e| ip_data[e].to_sym }
        @locations[Location.new(*fields)] += counts.at index
      end
      nil
    end

    def delay(requests_remaining, seconds_till_next_window)
      seconds = requests_remaining.positive? ? 0 : seconds_till_next_window.succ
      ::Kernel.sleep seconds
      nil
    end

    def service_fetch(keys, counts)
      ips = keys.map &:ip
      data = ::JSON.generate ips
# Within an HTTP session, is it possible to post to a URI which includes a query? I couldn't discover how.
## ::Net::HTTP.start(hostname) do |http|
      result = ::Net::HTTP.post ENDPOINT, data, HEADERS
      $stderr.puts "#{result.inspect}" unless ::Net::HTTPOK == result.class
      result
    end

    def timings(response)
      %w[rl ttl].map { |e| "x-#{e}" }.map { |k| response.to_hash[k].first.to_i }
    end
  end
end
