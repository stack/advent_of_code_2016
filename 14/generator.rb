#!/usr/bin/env ruby

require 'rubygems'

require 'digest/md5'
require 'rainbow'

class Generator #:nodoc:
  def initialize(salt)
    @salt = salt
  end

  def find(limit, stretch)
    @stretch = stretch

    @found = []
    @current_idx = 0
    @queue = []

    while @found.count < limit
      current = get_next
      puts "#{@current_idx - 1}: #{current} - #{@found.count}"

      triplet = contains_sequence(current)
      next if triplet.nil?

      puts "- Has triplet of #{triplet}"
      target_letter = triplet[0]
      target_word = target_letter * 5

      fill_queue

      1000.times do |idx|
        unless @queue[idx].index(target_word).nil?
          puts "- Has a match with #{@queue[idx]}"
          @found << { key: current, key_idx: @current_idx - 1, match: @queue[idx], match_idx: @current_idx + idx, letter: target_letter}
          @found.uniq!
          break
        end
      end
    end

    @found
  end

  private

  def fill_queue
    2000.times do |idx|
      next unless @queue[idx].nil?

      value = Digest::MD5.hexdigest("#{@salt}#{@current_idx + idx}")
      value = stretch_hash(value)

      @queue << value
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
      value = stretch_hash(value)
    end

    @current_idx += 1

    value
  end

  def stretch_hash(hash)
    value = hash
    @stretch.times { value = Digest::MD5.hexdigest(value) }
    value
  end
end

if ARGV[0].nil?
  $stderr.puts 'Salt is required'
  exit
end

salt = ARGV[0]

stretch = 0
stretch = ARGV[1].to_i unless ARGV[1].nil?

generator = Generator.new salt
matches = generator.find 65, stretch

puts "Matches:"
matches.each_with_index do |match, idx|
  triplet = match[:letter] * 3
  five = match[:letter] * 5

  key = match[:key].sub triplet, Rainbow(triplet).red
  key_match = match[:match].sub five, Rainbow(five).red

  puts "(#{idx+1}) #{match[:key_idx]}: #{key} -> #{match[:match_idx]}: #{key_match}"
end
