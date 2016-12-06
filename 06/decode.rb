#!/usr/bin/env ruby

# Get the input file
if ARGV[0].nil?
  $stderr.puts "No input file given"
  exit
end

input = ARGV[0]
tallies = []

# Read each line to read the characters
File.readlines(input).each do |line|
  # Split the line
  letters = line.split ''

  # If the tallies haven't been created, create it
  if tallies.empty?
    tallies = letters.count.times.map do |_|
      {}
    end
  end

  letters.each_with_index do |letter, idx|
    if tallies[idx][letter].nil?
      tallies[idx][letter] = 1
    else
      tallies[idx][letter] += 1
    end
  end
end

first_word = tallies.map do |tally|
  sorted = tally.to_a.sort { |x,y| y[1] <=> x[1] }
  letter = sorted.first[0]

  puts "Tally 1: #{sorted.inspect} -> #{letter}"

  letter
end

puts "Word 1: #{first_word.join ''}"

second_word = tallies.map do |tally|
  sorted = tally.to_a.sort { |x,y| x[1] <=> y[1] }
  letter = sorted.first[0]

  puts "Tally 2: #{sorted.inspect} -> #{letter}"

  letter
end

puts "Word 2: #{second_word.join ''}"
