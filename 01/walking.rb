#!/usr/bin/env ruby

require 'ostruct'

def adjustment(orientation, distance)
  result = OpenStruct.new

  case orientation
  when :north
    result.x = 0
    result.y = distance
  when :south
    result.x = 0
    result.y = distance * -1
  when :east
    result.x = distance
    result.y = 0
  when :west
    result.x = distance * -1
    result.y = 0
  end

  result
end

def turn_right(orientation)
  case orientation
  when :north
    :east
  when :east
    :south
  when :south
    :west
  when :west
    :north
  end
end

def turn_left(orientation)
  case orientation
  when :north
    :west
  when :west
    :south
  when :south
    :east
  when :east
    :north
  end
end

raw_input = File.read 'walking_instructions.txt'
directions = raw_input.split ', '

orientation = :north
x_offset = 0
y_offset = 0

directions.each do |direction|
  if direction =~ /([LR])(\d+)/
    # Get the next orienation
    new_orientation = ($1 == "L") ? turn_left(orientation) : turn_right(orientation)
    new_adjustment = adjustment new_orientation, $2.to_i

    # Make the adjustments
    puts "#{direction} - #{orientation}: #{x_offset}, #{y_offset} -> #{new_orientation}: #{x_offset + new_adjustment.x}, #{y_offset + new_adjustment.y}"

    orientation = new_orientation
    x_offset += new_adjustment.x
    y_offset += new_adjustment.y
  else
    $stderr.puts "Improper direction: #{direction}"
  end
end

puts "Final position: #{orientation} - #{x_offset}, #{y_offset} = #{x_offset + y_offset}"

