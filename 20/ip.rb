#!/usr/bin/env ruby

# Read the maximum
if ARGV[0].nil?
  $stderr.puts 'Assuming a maximum of 4294967295'
  max = 4_294_967_295
else
  max = ARGV[0].to_i
end

max = 10

# Read the input from stdin
input_ranges = ARGF.each_line.map do |line|
  range = line.chomp.split('-').map(&:to_i)
  Range.new range[0], range[1]
end

# Start with the full range and split the matching ranges
all_ranges = [(0..max)]
input_ranges.each do |range|
  # Find all of the ranges that intersect
  found_ranges = []
  loop do
    idx = all_ranges.index { |x| range.min >= x.min || range.max <= x.max }
    break if idx.nil?

    # Extract this range and split it
    old_range = all_ranges.delete_at idx 

    left_min = old_range.min
    left_max = [old_range.max, range.max].min
  end

  # Find the range that contains this range
  raise "Failed to find matching range for #{range}" if idx.nil?

  # Remove the range, split it, and re-insert it
  old_range = all_ranges.delete_at idx
  left_range = old_range.min..range.min - 1
  right_range = range.max + 1..old_range.max

  puts "Split #{old_range} with #{range} in to #{left_range} and #{right_range}"
  all_ranges << left_range unless left_range.max.nil?
  all_ranges << right_range
  puts "-> #{all_ranges.inspect}"
end
