#!/usr/bin/env ruby

require 'digest/md5'

SAMPLE_INPUT = 'abc'
ACTUAL_INPUT = 'reyedfim'

password = ''
idx = 0

while password.length < 8
  attempt = "#{ACTUAL_INPUT}#{idx}"
  hashed = Digest::MD5.new << attempt
  hashed_value = hashed.to_s

  puts "ATTEMPT: #{attempt} -> #{hashed_value} : #{password}"

  chars = hashed_value.split('')
  if chars[0..4] == ["0", "0", "0", "0", "0"]
    password += chars[5]
  end

  idx += 1
end

puts "PASSWORD: #{password}"
