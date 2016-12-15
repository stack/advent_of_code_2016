#!/usr/bin/env ruby

class Disc #:nodoc:
  attr_reader :idx

  def initialize(idx, size, position, time)
    @idx = idx
    @size = size
    @position = position
    @time = time

    @last_known_valid_position = initial_valid
  end

  def initial_valid
    @size - @position - @idx
  end

  def print(time)
    position = (@position + time) % @size
    value = '*' * @size
    value[position] = ' '

    puts "#{idx}: |#{value}|"
  end

  def reset_last_known_valid_position(time_range)
    while @last_known_valid_position > time_range.min
      puts "RESET #{@idx} #{@last_known_valid_position} by #{@size}"
      @last_known_valid_position -= @size
    end
  end

  def valid_positions(time_range)
    # Adjust the last know valid position to make it work for the given range
    reset_last_known_valid_position(time_range)

    positions = []
    current = @last_known_valid_position

    loop do
      next_position = current
      current += @size

      break if next_position > time_range.max
      next unless time_range.member?(next_position)

      positions << next_position
    end

    @last_known_valid_position = positions.last if positions.any?

    positions
  end
end

class Sculpture #:nodoc:
  CHUNK_SIZE = 1000

  def initialize
    @discs = []
  end

  def add_disc(disc)
    @discs[disc.idx - 1] = disc
  end

  def find_valid_state
    start_time = 0
    loop do
      # Get the next range
      range = (start_time..(start_time + CHUNK_SIZE - 1))
      puts "Inspecting #{range}"

      # Get all the valid positions for that range
      valid_positions = @discs.map { |disc| disc.valid_positions range }

      # Loop for a common time across all
      initial = valid_positions.first
      common = valid_positions.reduce(initial) { |acc, elem| acc & elem }.sort
      return common.first if common.any?

      start_time += CHUNK_SIZE
    end
  end

  def print(time)
    @discs.each do |disc|
      disc.print time
    end
  end
end

sculpture = Sculpture.new

ARGF.each_line do |line|
  if line =~ /Disc #(\d+) has (\d+) positions; at time=(\d+), it is at position (\d+)./
    idx = Regexp.last_match[1].to_i
    size = Regexp.last_match[2].to_i
    time = Regexp.last_match[3].to_i
    position = Regexp.last_match[4].to_i

    disc = Disc.new idx, size, position, time
    sculpture.add_disc disc
  else
    raise "Invalid input: #{line}"
  end
end

valid_state = sculpture.find_valid_state
puts "VALID STATE: #{valid_state}"
