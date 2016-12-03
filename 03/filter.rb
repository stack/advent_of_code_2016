#!/usr/bin/env ruby

def validate(sides)
  0.upto(sides.count - 1) do |idx|
    new_sides = sides.dup
    single = new_sides.delete_at(idx)
    total = new_sides.reduce(0, :+)

    return false if total <= single
  end

  true
end

triangles = File.readlines('triangles.txt').map do |line|
  line.split(' ').map { |x| x.to_i }
end

valid = 0
invalid = 0

triangles.each do |triangle|
  if validate(triangle)
    puts "#{triangle.inspect} - VALID"
    valid += 1
  else
    puts "#{triangle.inspect} - INVALID"
    invalid += 1
  end
end

puts "Valid: #{valid}"
puts "Invalid #{invalid}"
