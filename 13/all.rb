#!/usr/bin/env ruby

class Integer
  MAX = 2**(0.size * 8 - 2) - 1
end

class Traversal #:nodoc:
  attr_accessor :max_x, :max_y, :max_path
  attr_accessor :favorite_number

  def initialize
    @max_x = Integer::MAX
    @max_y = Integer::MAX
    @max_path = Integer::MAX

    @favorite_number = 0

    @board_width = 0
    @board_height = 0
  end

  def find(start = [0, 0], max_path = Integer::MAX, favorite_number = 0)
    # Initialize the data management
    @start = start
    @max_path = max_path

    @frontier = []
    @came_from = {}
    @cost_so_far = {}
    @favorite_number = favorite_number

    # Inject the first node
    @frontier << { coord: start, priority: 0 }
    @came_from[start] = nil
    @cost_so_far[start] = 0

    # Keep running until we've completed the frontier
    while @frontier.any?
      node = @frontier.shift
      current = node[:coord]

      @board_width = [current[0] + 1, @board_width].max
      @board_height = [current[1] + 1, @board_height].max

      print_known_board

      neighbors(current).each do |neighbor|
        next unless valid? neighbor
        next if visited? neighbor

        distance = path_distance(current) + 1
        next if distance > @max_path

        new_cost = @cost_so_far[current] + 1
        if !@cost_so_far.key?(neighbor) || new_cost < @cost_so_far[neighbor]
          @cost_so_far[neighbor] = new_cost
          priority = new_cost

          @frontier << { coord: neighbor, priority: priority }
          @came_from[neighbor] = current
        end
      end

      @frontier.sort! { |l, r| r[:priority] <=> l[:priority] }
    end

    @came_from.keys.count
  end

  def print_known_board
    puts '-' * @board_width

    @board_height.times do |y|
      puts @board_width.times.map { |x|
        key = [x, y]

        if !@came_from.key?(key)
          '?'
        elsif open_space?(key)
          '.'
        else
          '#'
        end
      }.join('')
    end

    puts '-' * @board_width
  end

  def print_full_board(path = [])
    puts '-' * @board_width

    @board_height.times do |y|
      puts @board_width.times.map { |x|
        key = [x, y]

        if path.include? key
          'O'
        elsif open_space? key
          '.'
        elsif wall? key
          '#'
        else
          '?'
        end
      }.join('')
    end

    puts '-' * @board_width
  end

  # Utilities

  def build_path(node)
    current = node
    path = [current]

    while current != @start
      current = @came_from[current]
      path << current
    end

    path.reverse
  end
  
  def neighbors(node)
    [
      [node[0], node[1] - 1],
      [node[0] + 1, node[1]],
      [node[0], node[1] + 1],
      [node[0] - 1, node[1]],
    ]
  end

  def open_space?(node)
    bits = value(node).to_s(2).split('')
    ones = bits.find_all { |b| b == '1' }

    ones.count.even?
  end

  def path_distance(node)
    puts "Path Distance: #{@came_from.inspect}"

    current = node
    distance = 0

    while current != @start
      puts "- #{current}"
      current = @came_from[current]
      distance += 1
    end

    distance
  end

  def valid?(node)
    if node[0] < 0 || node[1] < 0
      false
    elsif node[0] > @max_x || node[1] > @max_y
      false
    elsif wall?(node)
      false
    else
      true
    end
  end

  def value(node)
    x = node[0]
    y = node[1]

    value = x * x + 3 * x + 2 * x * y + y + y * y
    value + @favorite_number
  end

  def visited?(node)
    @came_from.key? node
  end

  def wall?(node)
    !open_space?(node)
  end
end

# Part 2 Input
traversal = Traversal.new
result = traversal.find [1, 1], 50, 1362

puts "VISITED: #{result}"
