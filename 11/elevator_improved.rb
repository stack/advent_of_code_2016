#!/usr/bin/env ruby

require 'set'

class State #:nodoc:
  attr_accessor :depth
  attr_accessor :elevator
  attr_accessor :floors
  attr_accessor :previous_state
  attr_accessor :types

  def initialize
    @depth = 1
    @elevator = 0
    @floors = []
    @types = SortedSet.new
  end

  def new_from_instruction(instruction)
    new_state = self.duplicate
    new_state.depth = @depth + 1
    new_state.previous_state = self

    next_elevator = instruction[:direction] == :up ? @elevator + 1 : @elevator - 1

    # Prevent floor overflow
    return nil if next_elevator < 0
    return nil if next_elevator >= @floors.count

    new_state.elevator = next_elevator

    # Remove the items from the current floor and put them on the new floor
    instruction[:generators].each do |generator|
      new_state.floors[@elevator][:generators].delete generator
      new_state.floors[next_elevator][:generators] << generator
    end

    instruction[:microchips].each do |microchip|
      new_state.floors[@elevator][:microchips].delete microchip
      new_state.floors[next_elevator][:microchips] << microchip
    end

    new_state
  end

  def distance
    distance = 0

    @floors.each_with_index do |floor, idx|
      multiplier = @types.count - idx - 1
      distance += multiplier * (floor[:generators].count + floor[:microchips].count)
    end

    distance
  end

  def add_floor(id)
    @floors[id] = { id: id, generators: [], microchips: [] }
  end

  def add_generator(type, floor_id)
    @floors[floor_id][:generators] << type
    @types << type
  end

  def add_microchip(type, floor_id)
    @floors[floor_id][:microchips] << type
    @types << type
  end

  def already_visited?
    return false if @previous_state.nil?

    already_visited_current?(@previous_state, self)
  end

  def already_visited_current?(current_state, target_state)
    if current_state.nil?
      false
    elsif current_state == target_state
      true
    else
      already_visited_current?(current_state.previous_state, target_state)
    end
  end

  def complete?
    last_floor = @floors.last
    last_floor[:microchips].count == @types.count && last_floor[:generators].count == @types.count
  end

  def duplicate
    new_state = State.new

    new_state.elevator = @elevator
    new_state.floors = @floors.map { |floor| { id: floor[:id], generators: floor[:generators].dup, microchips: floor[:microchips].dup } }
    new_state.types = @types

    new_state
  end

  def possible_instructions
    instructions = []
    directions = [:up, :down]
    current_floor = @floors[@elevator]

    # Two-microchip options
    directions.each do |direction|
      current_floor[:microchips].permutation(2).each do |microchips|
        instructions << { direction: direction, microchips: microchips, generators: [] }
      end
    end

    # Two-generator options
    directions.each do |direction|
      current_floor[:generators].permutation(2).each do |generators|
        instructions << { direction: direction, microchips: [], generators: generators }
      end
    end

    # Mixed options
    directions.each do |direction|
      current_floor[:microchips].each do |microchip|
        current_floor[:generators].each do |generator|
          instructions << { direction: direction, microchips: [microchip], generators: [generator] }
        end
      end
    end

    # Single microchip option
    directions.each do |direction|
      instructions += current_floor[:microchips].map { |microchip| { direction: direction, microchips: [microchip], generators: [] } }
    end

    # Single generator option
    directions.each do |direction|
      instructions += current_floor[:generators].map { |generator| { direction: direction, microchips: [], generators: [generator] } }
    end

    instructions
  end

  def print
    @floors.reverse.each do |floor|
      output = "F#{floor[:id]} "
      output += (@elevator == floor[:id]) ? 'E  ' : '.  '

      @types.each do |type|
        if floor[:generators].include? type
          output += "#{type[0,2].upcase}G "
        else
          output += " .  "
        end

        if floor[:microchips].include? type
          output += "#{type[0,2].upcase}M "
        else
          output += " .  "
        end
      end

      puts output
    end
  end

  def valid?
    @floors.each do |floor|
      microchips = floor[:microchips] - floor[:generators]
      generators = floor[:generators] - floor[:microchips]

      return false if microchips.any? && generators.any?
    end

    true
  end

  def ==(other)
    @floors == other.floors && @elevator == other.elevator
  end
end

# Generate the first state
state = State.new
ARGF.each_line do |line|
  # Get the floor number
  if line =~ /The ([a-z]+) floor contains/
    floor_id = case $1
               when 'first'  then 0
               when 'second' then 1
               when 'third'  then 2
               when 'fourth' then 3
               else
                 raise "Unsupported floor: #{$1}"
               end
  end

  state.add_floor floor_id

  # Get the microchips and generators
  line.scan(/a ([a-z]+)-compatible microchip/).flat_map(&:compact).each do |microchip|
    state.add_microchip(microchip, floor_id)
  end

  line.scan(/a ([a-z]+) generator/).flat_map(&:compact).each do |generator|
    state.add_generator(generator, floor_id)
  end
end

# Create a queue with the first start
queue = [state]
visited = []
while queue.any?
  # Get the next state
  current = queue.shift

  # Exit if the current state is complete
  if current.complete?
    puts "FINAL: #{current.depth + 1}"
    current.print
    break
  end

  puts "DEPTH: #{current.depth}"
  current.print

  # Perform the next possible instructions, adding valid state back to the queue
  # puts current.possible_instructions
  next_states = current.possible_instructions.map { |instruction|
    next_state = current.new_from_instruction instruction

    if next_state.nil? || visited.include?(current) || next_state.already_visited?
      nil
    else
      next_state
    end
  }

  queue += next_states.compact
  queue.sort! { |x, y| x.distance <=> y.distance }

  visited << current
end
