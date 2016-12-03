#!/usr/bin/env ruby

require 'ostruct'

KEYPAD = [
  [nil, nil, "1", nil, nil],
  [nil, "2", "3", "4", nil],
  ["5", "6", "7", "8", "9"],
  [nil, "A", "B", "C", nil],
  [nil, nil, "D", nil, nil],
].freeze

current = OpenStruct.new
current.x = 1
current.y = 1

def move(current, direction)
  moved = OpenStruct.new
  moved.x = current.x
  moved.y = current.y

  if direction == :U
    if moved.y != 0 && KEYPAD[current.y - 1][current.x] != nil
      moved.y -= 1
    end
  elsif direction == :D
    if moved.y != 4 && KEYPAD[current.y + 1][current.x] != nil
      moved.y += 1
    end
  elsif direction == :L
    if moved.x != 0 && KEYPAD[current.y][current.x - 1] != nil
      moved.x -= 1
    end
  elsif direction == :R
    if moved.x != 4 && KEYPAD[current.y][current.x + 1] != nil
      moved.x += 1
    end
  end

  moved
end

instructions = File.readlines('code.txt').map do |line|
  line.split('').map { |x| x.to_sym }
end

puts "Instructions: #{instructions.count}"

code = ""

instructions.each do |instruction|
  instruction.each do |step|
    puts "STEP: #{step}, #{current.x}, #{current.y}"

    current = move(current, step)
  
    puts "-   #{current.x}, #{current.y}"
  end

  code += KEYPAD[current.y][current.x]
end

puts "CODE: #{code}"

