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
  next_idx = elves.count / 2
  next_elf = elves[next_idx]

  current_elf = elves.first

  puts "Elf #{current_elf.position} takes Elf #{next_elf.position}'s #{next_elf.gifts} gift(s)"
  current_elf.gifts += next_elf.gifts

  elves.delete_at next_idx

  elves.shift
  elves << current_elf
end

puts "Elf #{elves.first.position} has #{elves.first.gifts} gifts"
