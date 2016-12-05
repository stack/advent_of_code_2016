#!/usr/bin/env ruby

require 'digest/md5'

SAMPLE_INPUT = 'abc'
ACTUAL_INPUT = 'reyedfim'

password = '________'
idx = 0

while !password.index('_').nil?
  attempt = "#{ACTUAL_INPUT}#{idx}"
  hashed = Digest::MD5.new << attempt
  hashed_value = hashed.to_s

  puts "ATTEMPT: #{attempt} -> #{hashed_value} : #{password}"

  chars = hashed_value.split('')
  if chars[0..4] == ["0", "0", "0", "0", "0"]
    position = chars[5].to_i(16)
    if position < 8 && password[position] == '_'
      password[position] = chars[6]
    end
  end

  idx += 1
end

puts "PASSWORD: #{password}"
