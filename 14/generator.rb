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

      three_peat = first_repeated current, 3
      next if three_peat.nil?

      puts "- Has 3-peat of #{three_peat}"
      target_letter = three_peat[0]

      fill_queue

      @queue.each_with_index do |item, item_idx|
        five_peat = first_repeated item, 5, target_letter

        unless five_peat.nil?
          puts "- Has 5-peat of #{five_peat}"
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

  def first_repeated(value, count, exact = nil)
    (value.length - count).times do |idx|
      chunk = value[idx, count]
      next unless chunk.split('').uniq.count == 1

      if exact.nil?
        return chunk
      elsif chunk[0] == exact
        return chunk
      end
    end

    nil
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
