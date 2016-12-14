#!/usr/bin/env ruby

require 'digest/md5'

class Generator #:nodoc:
  def initialize(salt)
    @salt = salt
  end

  def find(limit)
    @found = []
    @current_idx = 0
    @queue = []

    while @found.count < limit
      current = get_next
      puts "#{@current_idx - 1}: #{current} - #{@found.count}"

      three_peat = contains_sequence(current)
      next if three_peat.nil?

      puts "- Has 3-peat of #{three_peat}"
      target_letter = three_peat[0]
      target_word = target_letter * 5

      fill_queue

      1000.times do |idx|
        unless @queue[idx].index(target_word).nil?
          puts "- Has a match with #{@queue[idx]}"
          @found << current
        end
      end
    end

    @found
  end

  private

  def fill_queue
    2000.times do |idx|
      next unless @queue[idx].nil?
      @queue << Digest::MD5.hexdigest("#{@salt}#{@current_idx + idx}")
    end
  end

  def contains_sequence(value)
    match = /([0-9a-f])\1\1/.match value
    match.nil? ? nil : match[1]
  end

  def get_next
    if @queue.any?
      value = @queue.shift
    else
      value = Digest::MD5.hexdigest "#{@salt}#{@current_idx}"
    end

    @current_idx += 1

    value
  end
end

if ARGV[0].nil?
  $stderr.puts 'Salt is required'
  exit
end

salt = ARGV[0]

generator = Generator.new salt
matches = generator.find 64

puts matches
