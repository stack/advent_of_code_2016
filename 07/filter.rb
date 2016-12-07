#!/usr/bin/env ruby

require 'rubygems'

require 'rainbow'

class String
  def abba_segments
    segments = 0.upto(self.length - 4).map { |idx| self[idx,4] }
    segments.find_all { |x| x.is_abba_segment? }
  end

  def is_abba_segment?
    # Fail if there are less than 4 characters
    return false if self.length < 4

    # Fail if the first two letters are the same
    return false if self[0] == self[1]

    # Compare 0 & 3 and 1 & 2
    return (self[0] == self[3]) && (self[1] == self[2])
  end
end

class Address
  attr_reader :left, :center, :right

  SPLIT_REGEX = /(?<left>[a-z]+)\[(?<center>[a-z]+)\](?<right>[a-z]+)/

  def initialize(input)
    match = SPLIT_REGEX.match input
    raise "Input regex did not match '#{input}'" if match.nil?

    @left = match['left']
    @center = match['center']
    @right = match['right']
  end

  def abba?
    # If the center is a palindrome, it's NOT ABBA
    segments = @center.abba_segments
    if !segments.empty?
      puts "INVALID CENTER: #{self.to_pretty_s(nil, segments.first, nil)}"
      return false
    end

    # If the left is a palindrome, it is ABBA
    segments = @left.abba_segments
    if !segments.empty?
      # puts "LEFT MATCH:     #{self.to_pretty_s(segments.first, nil, nil)}"
      return true
    end

    # If the right is a palindrome, it is ABBA
    segments = @right.abba_segments
    if !segments.empty?
      # puts "RIGHT MATCH:    #{self.to_pretty_s(nil, nil, segments.first)}"
      return true
    end

    # Otherwise, it is not
    # puts "NO MATCH:       #{self.to_pretty_s}"
    return false
  end

  def to_pretty_s(left_match = nil, center_match = nil, right_match = nil)
    result = ''

    if left_match.nil?
      result += @left
    else
      result += @left.sub left_match, Rainbow(left_match).green
    end

    result += Rainbow('[').bright

    if center_match.nil?
      result += @center
    else
      result += @center.sub center_match, Rainbow(center_match).red
    end

    result += Rainbow(']').bright

    if right_match.nil?
      result += @right
    else
      result += @right.sub right_match, Rainbow(right_match).green
    end

    result
  end

  def to_s
    "#{@left}[#{@center}]#{@right}"
  end
end

# Get the input file
if ARGV[0].nil?
  $stderr.puts "No input file given"
  exit
end

input = ARGV[0]

# Convert the input into addresses
addresses = File.readlines(input).map { |line| Address.new line }

# Find the ABBA addresses
abba_addresses = addresses.find_all { |a| a.abba? }

puts "ABBA Addresses: #{abba_addresses.count}"
