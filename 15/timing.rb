#!/usr/bin/env ruby

class Sculpture
  def initialize
    @ball = 0
    @drop = 0
    @time = 0
    @positions = []
    @sizes = []
    @original_positions = []
    @original_sizes
  end

  def add_disc(idx, size, position, time)
    @sizes[idx] = size
    @positions[idx] = position

    rotate_disc idx, time * -1
  end

  def drop(time)
    @original_positions = @positions.dup
    @original_sizes = @sizes.dup

    @drop = time

    # print

    while valid? && !complete?
      @ball += 1 if @time >= @drop
      rotate_discs

      # print
      @time += 1
    end

    complete?
  end

  def reset!
    @positions = @original_positions
    @sizes = @original_sizes
    @ball = 0
    @drop = 0
    @time = 0
  end

  def rotate_disc(idx, times = 1)
    if times == 0
      return
    elsif times < 0
      @positions[idx] -= 1
      @positions[idx] += @sizes[idx] if @positions[idx] < 0
      rotate_disc idx, times + 1
    elsif times > 0
      @positions[idx] += 1
      @positions[idx] -= @sizes[idx] if @positions[idx] >= @sizes[idx]
      rotate_disc idx, times - 1
    end
  end

  def rotate_discs
    @positions.count.times do |idx|
      rotate_disc idx
    end
  end

  def print
    if @ball == 0
      puts '    •'
    else
      puts
    end

    @positions.each_with_index do |position, idx|
      value = '*' * @sizes[idx]
      value[position] = ' '

      if @ball == idx + 1
        if value[0] == ' '
          value[0] = '•'
        else
          value[0] = 'X'
        end
      end

      puts "#{idx + 1}: |#{value}|"
    end

    if @ball > @positions.count
      puts '    •'
    else
      puts
    end
  end

  def complete?
    @ball > @positions.count
  end

  def valid?
    # Valid if the ball has started
    return true if @ball == 0

    # Valid if the ball is past the discs
    return true if complete?

    # Does the ball fit in the disc
    disc = @positions[@ball - 1]
    disc == 0
  end
end


sculpture = Sculpture.new

ARGF.each_line do |line|
  if line =~ /Disc #(\d+) has (\d+) positions; at time=(\d+), it is at position (\d+)./
    idx = $1.to_i - 1
    size = $2.to_i
    time = $3.to_i
    position = $4.to_i

    sculpture.add_disc idx, size, position, time
  else
    raise "Invalid input: #{line}"
  end
end

time = 0
loop do
  puts "TIME: #{time}"
  break if sculpture.drop time

  time += 1
  sculpture.reset!
end

puts "FINAL TIME: #{time}"
