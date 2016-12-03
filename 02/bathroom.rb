#!/usr/bin/env ruby

require 'ostruct'

KEYPAD = [
  [ 1, 2, 3 ],
  [ 4, 5, 6 ],
  [ 7, 8, 9 ]
].freeze

current = OpenStruct.new
current.x = 1
current.y = 1

def move(current, direction)
  moved = OpenStruct.new
  moved.x = current.x
  moved.y = current.y

  case direction
  when :U
    moved.y -= 1 unless moved.y == 0
  when :D
    moved.y += 1 unless moved.y == 2
  when :L
    moved.x -= 1 unless moved.x == 0
  when :R
    moved.x += 1 unless moved.x == 2
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

  code += KEYPAD[current.y][current.x].to_s
end

puts "CODE: #{code}"

