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

  def find(start = [0, 0], target = [0, 0], favorite_number = 0)
    # Initialize the data management
    @start = start
    @target = target

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

      if current == @target
        return build_path(current)
      end

      neighbors(current).each do |neighbor|
        next unless valid? neighbor
        next if visited? neighbor

        new_cost = @cost_so_far[current] + 1
        if !@cost_so_far.key?(neighbor) || new_cost < @cost_so_far[neighbor]
          @cost_so_far[neighbor] = new_cost
          priority = new_cost + heuristic(@target, neighbor)

          @frontier << { coord: neighbor, priority: priority }
          @came_from[neighbor] = current
        end
      end

      @frontier.sort! { |l, r| r[:priority] <=> l[:priority] }
    end

    # We've failed, so return an empty path
    []
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
  
  def heuristic(a, b)
    (a[0] - b[0]).abs + (a[1] - b[1]).abs
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
    current = node
    distance = 0

    while current != @start
      current = @came_from[current]

      if current.nil?
        distance = Integer::MAX
        break
      end

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
    elsif path_distance(node) > @max_path
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

# Testing
traversal = Traversal.new
traversal.favorite_number = 10

test_values = '.#.####.##..#..#...##....##...###.#.###..##..#..#...##....#.#...##.###'
test_results = test_values.split('').map { |x| x == '.' }

6.times do |y|
  10.times do |x|
    coord = [x, y]
    idx = (y * 10) + x
    raise "Coord failed at #{coord}" unless traversal.open_space?(coord) == test_results[idx]
  end
end

# Sample Input
traversal = Traversal.new
traversal.max_x = 10
traversal.max_y = 7

path = traversal.find [1, 1], [7, 4], 10

puts
puts path.inspect
puts
traversal.print_full_board path
puts "STEPS: #{path.length - 1}"

# Part 1 Input
traversal = Traversal.new
traversal.max_x = 100
traversal.max_y = 100

path = traversal.find [1, 1], [31, 39], 1362

puts
puts path.inspect
puts
traversal.print_full_board path
puts "STEPS: #{path.length - 1}"

# Part 2 Input
traversal = Traversal.new
traversal.favorite_number = 1362
traversal.max_path = 50

valid_points = (0..51).to_a.permutation(2).find_all { |x| traversal.open_space?(x) }
puts "VALID POINTS: #{valid_points.count}"

successes = 0
valid_points.each do |target|
  traversal = Traversal.new
  traversal.max_x = 53
  traversal.max_y = 53

  path = traversal.find [1, 1], target, 1362
    
  if !path.empty? && path.count <= 50
    successes += 1
  end
end

puts "SUCCESSES: #{successes}"
