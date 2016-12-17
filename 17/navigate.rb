#!/usr/bin/env ruby

require 'digest/md5'

OPEN_VALUES = /[b-f]/

def generate_state(state, direction)
  case direction
  when :up
    {
      x: state[:x],
      y: state[:y] - 1,
      passcode: state[:passcode] + 'U'
    }
  when :down
    {
      x: state[:x],
      y: state[:y] + 1,
      passcode: state[:passcode] + 'D'
    }
  when :left
    {
      x: state[:x] - 1,
      y: state[:y],
      passcode: state[:passcode] + 'L'
    }
  when :right
    {
      x: state[:x] + 1,
      y: state[:y],
      passcode: state[:passcode] + 'R'
    }
  else
    raise "Unsupported door type: #{door}"
  end
end

def open_doors(hash)
  doors = []

  doors << :down if hash[1] =~ OPEN_VALUES
  doors << :right if hash[3] =~ OPEN_VALUES
  doors << :up if hash[0] =~ OPEN_VALUES
  doors << :left if hash[2] =~ OPEN_VALUES

  doors
end

# Testing
print 'Testing #open_doors...'

passcode = 'hijkl'
hash = Digest::MD5.hexdigest passcode
doors = open_doors hash

raise unless doors[0] == :down
raise unless doors[1] == :up
raise unless doors[2] == :left

passcode = 'hijklD'
hash = Digest::MD5.hexdigest passcode
doors = open_doors hash

raise unless doors[0] == :right
raise unless doors[1] == :up
raise unless doors[2] == :left

puts 'Success.'

# Get the passcode
passcode = ARGV[0]
exit(1) if passcode.nil?

# Get the keep_going flag
keep_going = ARGV[1].nil? ? false : true

# Set an initial position
start = { x: 0, y: 0, passcode: passcode }
queue = []
queue << start

longest = nil

# Loop through the states
while queue.any?
  # Get the next position
  current = queue.shift

  # Done?
  if longest.nil?
    puts "#{current.inspect}"
  else
    puts "#{current.inspect}, LONGEST: #{longest.inspect} (#{longest[:passcode].length - passcode.length})"
  end

  if current[:x] == 3 && current[:y] == 3
    if longest.nil?
      longest = current
    elsif current[:passcode].length > longest[:passcode].length
      longest = current
    end

    if keep_going
      next
    else
      break
    end
  end

  # Calculate the current hash
  hash = Digest::MD5.hexdigest current[:passcode]

  # Get all possible doors
  doors = open_doors hash

  # Remove any invalid doors
  doors = doors.delete_if { |x| x == :up && current[:y] == 0 }
  doors = doors.delete_if { |x| x == :down && current[:y] == 3 }
  doors = doors.delete_if { |x| x == :left && current[:x] == 0 }
  doors = doors.delete_if { |x| x == :right && current[:x] == 3 }

  # Build all possible doors and queue them
  queue += doors.map { |door| generate_state current, door }
  doors.each do |door|
    next_state = generate_state current, door

    if keep_going
      queue.unshift next_state
    else
      queue << next_state
    end
  end
end

puts "Found vault with #{longest}"
