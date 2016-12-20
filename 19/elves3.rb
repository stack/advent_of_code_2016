#!/usr/bin/env ruby

class Elf #:nodoc:
  attr_reader :position
  attr_accessor :gifts

  def initialize(position)
    @position = position
    @gifts = 1
  end
end

def run(total_elves)
  elves = Array.new(total_elves) { |x| Elf.new(x + 1) }

  while elves.count > 1
    next_idx = elves.count / 2
    next_elf = elves[next_idx]

    current_elf = elves.first

    current_elf.gifts += next_elf.gifts

    elves.delete_at next_idx

    elves.shift
    elves << current_elf
  end

  puts "#{total_elves}: #{elves.first.position} - #{elves.first.gifts}"
end

100.times do |idx|
  run(idx + 1)
end
