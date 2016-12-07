#!/usr/bin/env ruby

require 'rubygems'

require 'rainbow'

class String
  def aba_segments
    segments = 0.upto(self.length - 3).map { |idx| self[idx, 3] }
    segments.find_all { |x| x.is_aba_segment? }
  end

  def abba_segments
    segments = 0.upto(self.length - 4).map { |idx| self[idx, 4] }
    segments.find_all { |x| x.is_abba_segment? }
  end

  def is_aba_segment?
    # Fail if there are less than 3 characters
    return false if self.length < 3

    return (self[0] == self[2]) && self[1] != '[' && self[1] != ']'
  end

  def inverse_aba_segment
    raise 'Invalid ABA length for inversion' if self.length != 3
    raise 'Not an ABA value of inversion' unless self.is_aba_segment?

    return self[1] + self[0] + self[1]
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

class ABBAAddress
  attr_reader :input, :pretty_input
  attr_reader :valid_supernets, :invalid_supernets

  def initialize(input)
    # Initialize the state
    @input = input
    @pretty_input = ''
    @valid_supernets = 0
    @invalid_supernets = 0

    # Loop through the characters, looking for ABBA matches
    idx = 0
    state = :supernet

    while idx < input.length
      value = input[idx, 4]

      if value[0] == '['
        state = :hypernet
        @pretty_input += Rainbow('[').bright
        idx += 1
      elsif value[0] == ']'
        state = :supernet
        @pretty_input += Rainbow(']').bright
        idx += 1
      elsif value.is_abba_segment?
        if state == :supernet
          @pretty_input += Rainbow(value).green
          @valid_supernets += 1
        else
          @pretty_input += Rainbow(value).red.bright
          @invalid_supernets += 1
        end

        idx += 4
      else
        if state == :supernet
          @pretty_input += value[0]
        else
          @pretty_input += Rainbow(value[0]).bright
        end

        idx += 1
      end
    end
  end

  def abba?
    return false if @invalid_supernets > 0
    return true if @valid_supernets > 0
    return false
  end
end

# Get the input file
if ARGV[0].nil?
  $stderr.puts "No input file given"
  exit
end

input = ARGV[0]

# Convert the input into ABBA addresses
addresses = File.readlines(input).map { |line| ABBAAddress.new line }

# Find the ABBA addresses
abba_addresses = addresses.find_all { |a|
  puts a.pretty_input
  a.abba? 
}

puts '---'
puts "ABBA Addresses: #{abba_addresses.count}"
puts '---'

class ABAParser
  attr_accessor :valid

  REGEX = /\b([a-z]+)\b/

  def initialize(input)
    # Initial state
    @valid = false

    # Split up the hypernets and supernets
    @hypernets = []
    @supernets = []

    parts = input.scan(REGEX).flatten.compact
    parts.each_with_index do |part, idx|
      if idx.odd?
        @hypernets << part
      else
        @supernets << part
      end
    end

    # Convert the nets into their possible ABAs
    @hypernet_abas = @hypernets.map { |x| x.aba_segments }
    @supernet_abas = @supernets.map { |x| x.aba_segments }

    # Flatten and unqiue each ABA set to look for matches
    @unique_hypernet_abas = @hypernet_abas.flatten.uniq.sort
    @unique_supernet_abas = @supernet_abas.flatten.uniq.sort

    # Invert the hypernet ABAs to get the BABs
    @unique_hypernet_babs = @unique_hypernet_abas.map { |x| x.inverse_aba_segment }

    # Find the intersection of the nets
    @intersection = @unique_supernet_abas & @unique_hypernet_babs

    # Valid if there is an intersection
    @valid = @intersection.any?

    puts "#{@valid ? 'VALID' : 'INVALID'} INPUT: #{pretty_input_s} ->"
    puts "- H ABAS: #{@hypernet_abas.inspect} -> #{@unique_hypernet_babs.inspect}"
    puts "- S ABAS: #{@supernet_abas.inspect} -> #{@unique_supernet_abas.inspect}"
    puts "- Intersection: #{@intersection.inspect}"
  end

  def pretty_input_s
    total_length = @supernets.length + @hypernets.length
    total_length.times.map { |x| pretty_segment(x) }.join('')
  end

  def pretty_segment(idx)
    # Get the values
    value = idx.odd? ? @hypernets[idx/2] : @supernets[idx/2]
    abas = idx.odd? ? @hypernet_abas[idx/2] : @supernet_abas[idx/2]

    # Bold a hypernet
    if idx.odd?
      value = Rainbow(' [').bright + value + Rainbow('] ').bright
    end

    # Swap ABAs for color
    abas.each do |aba|
      is_match = @intersection.member?(aba) || @intersection.member?(aba.inverse_aba_segment)
      color = idx.odd? ? :red : :green

      replacement = Rainbow(aba).color(color)
      replacement = replacement.underline if is_match
      
      value = value.gsub aba, replacement
    end

    value
  end
end

# Convert the input to ABA addresses
addresses = File.readlines(input).map { |line| ABAParser.new line.strip }
valid_addresses = addresses.find_all { |x| x.valid }

puts '---'
puts "Valid ABAs: #{valid_addresses.count}"
puts '---'
