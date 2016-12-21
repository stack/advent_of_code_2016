#!/usr/bin/env ruby

class Scrambler #:nodoc:
  def initialize(password, reversed = false)
    @password = password.split ''
    @reversed = reversed
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
    if @reversed
      move_internal(y, x)
    else
      move_internal(x, y)
    end
  end

  def move_internal(x, y)
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
    if @reversed
      new_direction = direction == 'left' ? 'right' : 'left'
      rotate_internal new_direction, steps
    else
      rotate_internal direction, steps
    end
  end

  def rotate_internal(direction, steps)
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

    puts "Shifted #{direction.ljust(5, ' ')} #{steps} steps         -> #{scrambled}"
  end

  def rotate_letter(a)
    if @reversed
      rotate_letter_backward a
    else
      rotate_letter_forward a
    end
  end

  def rotate_letter_backward(a)
    # Find all permutations of this step to get back to
    permutations = []
    @password.count.times do |idx|
      permutation = @password.dup

      idx.times do
        x = permutation.shift
        permutation.push x
      end

      permutations << permutation
    end

    # Find the first permutation that makes sense
    permutations.each do |permutation|
      working_permutation = permutation.dup

      idx = working_permutation.index a
      steps = idx + 1
      steps += 1 if idx >= 4

      steps.times do
        x = working_permutation.pop
        working_permutation.unshift x
      end

      if working_permutation == @password
        @password = permutation
        return
      end
    end

    raise 'Unsatisfied reverse permutation lookup'
  end

  def rotate_letter_forward(a)
    idx = @password.index a
    steps = idx + 1
    steps += 1 if idx >= 4

    rotate_internal 'right', steps

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

# Should we reverse?
reversed_value = ARGV.shift || '0'
reversed = reversed_value == '1'

# Build a new scrambler
scrambler = Scrambler.new password, reversed
puts 'Reversed!' if reversed
puts '                              -> 0123456789'
puts "Initial                       -> #{scrambler.scrambled}"

# Perform the scramble steps
instructions = ARGF.readlines
instructions.reverse! if reversed

instructions.each do |instruction|
  scrambler.perform instruction
end

# Output the result
puts "Final Value: #{scrambler.scrambled}"
