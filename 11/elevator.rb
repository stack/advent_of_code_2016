#!/usr/bin/env ruby

require 'set'

class Listener #:nodoc:
  def initialize
    @best_count = (2 ** (0.size * 8 - 2) - 1)
  end

  def announce(states)
    puts "COMPLETE WITH #{states.count} STEPS"

    @best_count = [@best_count, states.count].min
    puts "BEST COUNT: #{@best_count}"
  end
end

# Generate the current state and put it in a queue
# While True
# - Get the next state
# - Generate its children and put them in the queue
#

class State #:nodoc:
  attr_accessor :elevator
  attr_reader :floors

  def initialize(callback)
    @floors = []
    @types = SortedSet.new
    @elevator = 0
    @callback = callback
  end

  def self.new_from_instruction(instruction)
    new_elevator = instruction[:direction] == :up ? @elevator + 1 : @elevator - 1
    return nil if new_elevator < 0 || new_elevator == @floors.count
  end

  def add_floor(floor_id)
    @floors[floor_id] = { id: floor_id, generators: [], microchips: [] }
  end

  def add_generator(type, floor_id)
    @floors[floor_id][:generators] << type
    @types << type
  end

  def add_microchip(type, floor_id)
    @floors[floor_id][:microchips] << type
    @types << type
  end

  def remove_generator(type, floor_id)
    @floors[floor_id][:generators].delete type
  end

  def remove_microchip(type, floor_id)
    @floors[floor_id][:microchips].delete type
  end

  def clone
    other = State.new(@callback)

    @floors.each do |floor|
      other.add_floor floor[:id]
      floor[:generators].each { |generator| other.add_generator(generator, floor[:id]) }
      floor[:microchips].each { |microchip| other.add_microchip(microchip, floor[:id]) }
    end

    other.elevator = @elevator

    other
  end

  def run(previous_states = [])
    # Check for completeness
    top_floor = @floors.last
    if top_floor[:generators].count == @types.count && top_floor[:microchips].count == @types.count
      @callback.announce previous_states
      return
    end

    puts '------------------'
    print

    # Add this state to the stack
    previous_states.push self

    # Build a list of combinations to attempt
    combinations = []
    current_floor = @floors[@elevator]

    # Generate each possible floor
    new_floors = []
    new_floors << :up if @elevator < (@floors.count - 1)
    new_floors << :down if @elevator > 0

    # Generate each two microchip combination
    new_floors.each do |floor|
      current_floor[:microchips].permutation(2).each do |microchips|
        combinations << { direction: floor, microchips: microchips, generators: [] }
      end
    end

    # Generate each two generator combination
    new_floors.each do |floor|
      current_floor[:generators].permutation(2).each do |generators|
        combinations << { direction: floor, microchips: [], generators: generators }
      end
    end

    # Generate each microchip-generator combination
    new_floors.each do |floor|
      current_floor[:microchips].each do |microchip|
        current_floor[:generators].each do |generator|
          combinations << { direction: floor, microchips: [microchip], generators: [generator] }
        end
      end
    end

    # Generate each single microchip combination
    new_floors.each do |floor|
      current_floor[:microchips].each do |microchip|
        combinations << { direction: floor, microchips: [microchip], generators: [] }
      end
    end

    # Generate each single generator combination
    new_floors.each do |floor|
      current_floor[:generators].each do |generator|
        combinations << { direction: floor, microchips: [], generators: [generator] }
      end
    end

    puts "Possible Combinations: #{combinations.inspect}"

    # Filter combinations for plausibility
    filtered_combinations = combinations.find_all do |combination|
      target_elevator = (combination[:direction] == :up) ? @elevator + 1 : @elevator - 1
      target_floor = @floors[target_elevator]

      target_generators = target_floor[:generators] + combination[:generators]
      target_microchips = target_floor[:microchips] + combination[:microchips]

      remaining_microchips = target_microchips - target_generators
      remaining_generators = target_generators - target_microchips

      !(remaining_microchips.any? && remaining_generators.any?)
    end

    puts "Filtered Combinations: #{filtered_combinations.inspect}"

    # Create new states and run them
    filtered_combinations.each do |combination|
      target_elevator = (combination[:direction] == :up) ? @elevator + 1 : @elevator - 1

      new_state = self.clone
      new_state.elevator = target_elevator

      combination[:generators].each do |generator| 
        new_state.remove_generator generator, @elevator
        new_state.add_generator generator, target_elevator
      end

      combination[:microchips].each do |microchip|
        new_state.remove_microchip microchip, @elevator
        new_state.add_microchip microchip, target_elevator
      end

      # Skip if this is a repeat
      if previous_states.include?(new_state)
        puts "--- SKIPPING: #{combination}"
        next
      end

      puts "-- NEXT: #{combination}"
      new_state.print

      @children << new_state

      new_state.run(previous_states)
    end

    puts

    # Complete, so remove from the stack
    previous_states.pop
  end

  def ==(other)
    @floors == other.floors && @elevator == other.elevator
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

  private

  def get_floor(floor_id)
    @floors[floor_id] = { generators: [], microchips: [] } if @floors[floor_id].nil?
    @floors[floor_id]
  end
end

# Build the listener
listener = Listener.new

# Read the initial state
state = State.new listener
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

state.run

