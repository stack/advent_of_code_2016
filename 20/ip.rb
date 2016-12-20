#!/usr/bin/env ruby

class Range #:nodoc:
  def overlap?(other)
    max >= other.min && min <= other.max
  end

  def eliminate(other)
    splits = []

    # Handle the split on the left
    if other.min > min
      left_min = min
      left_max = [max, other.min - 1].min
      splits << (left_min..left_max) unless left_max < left_min
    end

    # Handle the split on the right
    if other.max < max
      right_min = other.max + 1
      right_max = [max, other.max].max
      splits << (right_min..right_max) unless right_max < right_min
    end

    splits
  end
end

# Testing
raise unless (0..5).overlap?(2..6)
raise unless (0..5).overlap?(1..2)
raise unless (2..6).overlap?(1..3)
raise unless (2..6).overlap?(1..2)

raise unless (5..10).eliminate(3..6) == [7..10]
raise unless (5..10).eliminate(3..11) == []
raise unless (5..10).eliminate(7..12) == [5..6]
raise unless (5..10).eliminate(7..8) == [5..6, 9..10]

# Read the maximum
if ARGV[0].nil?
  puts 'Assuming a maximum of 4294967295'
  max = 4_294_967_295
else
  max = ARGV.shift.to_i
  puts "Using a maximum of #{max}"
end

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
    idx = all_ranges.index { |x| range.overlap? x }
    break if idx.nil?

    # Extract this range and split it
    old_range = all_ranges.delete_at idx 
    found_ranges += old_range.eliminate(range)
  end

  # Re-apply the ranges to the end
  all_ranges += found_ranges
end

all_ranges.sort! { |x, y| x.min <=> y.min }
puts "First IP: #{all_ranges.first.min}"

allowed = all_ranges.map(&:size).reduce(0) { |acc, elem| acc + elem }
puts "Total Allowed: #{allowed}"
