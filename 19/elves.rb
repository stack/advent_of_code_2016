#!/usr/bin/env ruby

class Elf #:nodoc:
  attr_reader :position
  attr_accessor :gifts

  def initialize(position)
    @position = position
    @gifts = 1
  end
end

if ARGV[0].nil?
  $stderr.puts 'You must supply a number of elves'
  exit 1
end

total_elves = ARGV[0].to_i
elves = Array.new(total_elves) { |x| Elf.new(x + 1) }

while elves.count > 1
  current_elf = elves.shift

  if current_elf.gifts.zero?
    puts "Skipping #{current_elf.position}"
    next
  end

  next_elf = elves.first
  break if next_elf.nil?

  puts "Elf #{current_elf.position} takes Elf #{next_elf.position}'s #{next_elf.gifts} gift(s)"
  current_elf.gifts += next_elf.gifts
  next_elf.gifts = 0

  elves << current_elf
end

puts "Elf #{elves.first.position} has #{elves.first.gifts} gifts"
