#!/usr/bin/env ruby

require 'rubygems'

require 'rainbow'

SCREEN_WIDTH = 50
SCREEN_HEIGHT = 6

class Screen
  def initialize(width, height)
    @width = width
    @height = height
    @state = Array.new(height) { |_| Array.new(width, ' ') }
    @empty = ' '
    @full = '•'
    @v_border = '|'
    @h_border = '-'
  end

  # Properties

  def count
    @state.flatten.find_all { |x| x == @full }.count
  end

  # Instructions

  def column(index, count)
    column = @state.map { |row| row[index] }

    count.times do
      x = column.pop
      column = column.unshift x
    end

    @height.times do |row|
      @state[row][index] = column[row]
    end
  end

  def rect(width, height)
    width.times do |x|
      height.times do |y|
        @state[y][x] = @full
      end
    end
  end

  def row(index, count)
    row = @state[index]

    count.times do
      x = row.pop
      row = row.unshift x
    end

    @state[index] = row
  end

  # Utilities

  def print
    row_separator = Rainbow(@h_border * ((@width * 2) + 1)).gray
    column_separator = Rainbow(@v_border).gray

    puts row_separator
    @state.each_with_index do |row, row_idx|
      output = column_separator

      row.each_with_index do |x, idx|
        if (idx / 5) % 2 == 0
          color = :red
        else
          color = :green
        end

        output += Rainbow(x).color(color)
        output += column_separator
      end

      puts output
    end

    puts row_separator
  end
end

# Ensure there is a file
if ARGV[0].nil?
  $stderr.puts 'You must provide a file'
  exit 1
end

input = ARGV[0]

# Build an empty screen
screen = Screen.new SCREEN_WIDTH, SCREEN_HEIGHT
screen.print

# Read each instruction and perform it
instructions = File.readlines(input).map do |line|
  case line
  when /rect (\d+)x(\d+)/
    { type: :rect, width: $1.to_i, height: $2.to_i }
  when /rotate ([a-z]+) [xy]=(\d+) by (\d+)/
    { type: $1.to_sym, idx: $2.to_i, count: $3.to_i }
  else
    raise "Unknown instruction: #{line}"
  end
end

# Perform the instructions
instructions.each do |instruction|
  case instruction[:type]
  when :rect
    screen.rect instruction[:width], instruction[:height]
  when :column
    screen.column instruction[:idx], instruction[:count]
  when :row
    screen.row instruction[:idx], instruction[:count]
  else
    raise "Unknown instruction applied: #{instruction.inspect}"
  end

  screen.print
  puts "COUNT: #{screen.count}"

  sleep(0.15)
end

