#!/usr/bin/env ruby

class Scrambler #:nodoc:
  def initialize(password)
    @password = password.split ''
  end

  def perform(text)
    case text
    when /move position (\d+) to position (\d+)/
      move($1.to_i, $2.to_i)
    when /reverse positions (\d+) through (\d+)/
      reverse_positions($1.to_i, $2.to_i)
    when /rotate based on position of letter ([a-z])/
      rotate_letter($1)
    when /rotate (left|right) (\d+) step/
      rotate($1, $2.to_i)
    when /swap letter ([a-z]) with letter ([a-z])/
      swap_letters($1, $2)
    when /swap position (\d+) with position (\d+)/
      swap_positions($1.to_i, $2.to_i)
    else
      raise "Unhandled perform line: #{text}"
    end
  end

  def scrambled
    @password.join ''
  end

  def move(x, y)
    temp = @password.delete_at x
    @password.insert y, temp
    puts "Moved #{x} to #{y}                  -> #{scrambled}"
  end

  def reverse_positions(x, y)
    reversed = @password[x..y].reverse
    @password[x..y] = reversed
    puts "Reversed #{x}..#{y}                 -> #{scrambled}"
  end

  def rotate(direction, steps)
    steps.times do
      if direction == 'left'
        x = @password.shift
        @password.push x
      elsif direction == 'right'
        x = @password.pop
        @password.unshift x
      else
        raise "Unknown rotate direction: #{direction}"
      end
    end

    puts "Shifted #{direction.ljust(5, ' ') } #{steps} steps         -> #{scrambled}"
  end

  def rotate_letter(a)
    idx = @password.index a
    steps = idx + 1
    steps += 1 if idx >= 4

    rotate 'right', steps

    puts "Rotated #{steps} steps from #{a} @ #{idx}    -> #{scrambled}"
  end

  def swap_letters(a, b)
    a_idx = @password.index a
    b_idx = @password.index b
    @password[a_idx], @password[b_idx] = @password[b_idx], @password[a_idx]

    puts "Swapped #{a} @ #{a_idx} and #{b} @ #{b_idx}       -> #{scrambled}"
  end

  def swap_positions(x, y)
    @password[x], @password[y] = @password[y], @password[x]
    puts "Swapped #{x} and #{y}               -> #{scrambled}"
  end
end

# Get the unscrambled password
password = ARGV.shift
if password.nil?
  $stderr.puts 'You must provide a password'
  exit 1
end

# Build a new scrambler
scrambler = Scrambler.new password
puts "                              -> 0123456789"
puts "Initial                       -> #{scrambler.scrambled}"

# Perform the scramble steps
ARGF.each do |line|
  scrambler.perform line.chomp
end

# Output the result
puts "Final Value: #{scrambler.scrambled}"
