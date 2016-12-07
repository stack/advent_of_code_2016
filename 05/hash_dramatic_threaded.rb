#!/usr/bin/env ruby

require 'celluloid'
require 'digest/md5'

INPUT = 'reyedfim'
THREADS = 8
CHUNKS = 1000

class Worker
  include Celluloid

  def process(input, start_index, count)
    matches = []

    count.times do |c|
      idx = start_index + c
      attempt = "#{input}#{idx}"
      hashed = Digest::MD5.new << attempt
      hashed_value = hashed.to_s

      puts "ATTEMPT: #{attempt} -> #{hashed_value}"

      chars = hashed_value.split('')
      if chars[0..4] == ['0', '0', '0', '0', '0']
        position = chars[5].to_i(16)
        matches << { position: position, letter: chars[6], idx: idx }
      end
    end

    matches
  end
end

password = '________'
current_idx = 0

while !password.index('_').nil?
  threads = []
  THREADS.times.each do |id|
    threads << Worker.new(id, INPUT, current_idx, CHUNKS)
    current_idx += CHUNKS
  end

  futures = threads.map { |t| t.future.process }

  results = futures.map { |f| f.value }
  results.flatten!

  results.each do |result|
    next if result[:position] >= 8
    next if password[result[:position]] != '_'

    password[result[:position]] = result[:letter]
  end

  puts "---\n---\nCURRENT PASSWORD: #{password}\n---\n---"
end

puts "PASSWORD: #{password}"
