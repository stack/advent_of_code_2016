#!/usr/bin/env ruby

class Ducts #:nodoc:
  def initialize(lines)
    parse_grid lines
    find_positions
    calculate_all_distances
  end

  def all_distances
    indexes = @positions_list.keys.permutation.find_all { |x| x.first.zero? }

    puts "Indexes: #{indexes.inspect}"

    pairs = indexes.map do |index|
      list = []
      work = index.dup

      while work.count > 1
        pair = []
        pair << work.shift
        pair << work.first
        list << pair
      end

      list
    end

    puts "Pairs: #{pairs.inspect}"

    distances = pairs.map do |pairs_list|
      pairs_list.map { |pair| @all_distances[pair] }
    end

    puts "Distances: #{distances}"

    all_distances = distances.map do |distance|
      distance.reduce(0) { |acc, elem| acc + elem }
    end

    puts "All Distances: #{all_distances}"

    all_distances
  end

  def print_grid
    @grid.each_with_index do |row, y|
      row.each_with_index do |place, x|
        position = @positions[[x, y]]
        print position.nil? ? place : position
      end

      puts
    end
  end

  def calculate_all_distances
    @all_paths = {}
    @all_distances = {}

    pairs = @positions_list.keys.permutation(2).to_a.uniq.map(&:sort).uniq
    puts "Pairs: #{pairs.inspect}"

    finder = PathFinder.new @grid
    pairs.each do |pair|
      left = @positions_list[pair[0]]
      right = @positions_list[pair[1]]

      path = finder.find_path left, right

      @all_paths[pair] = path
      @all_paths[pair.reverse] = path

      @all_distances[pair] = path.length - 1
      @all_distances[pair.reverse] = path.length - 1
    end

    puts "Paths: #{@all_paths}"
    puts "Distances: #{@all_distances}"
  end

  private

  def find_paths(nodes)
    paths = []
    working = nodes.dup

    finder = PathFinder.new @grid

    while working.count > 1
      left = working.shift
      right = working.first

      paths << finder.find_path(left, right)
    end
      
    paths
  end

  def find_positions
    @positions = {}
    @positions_list = {}

    @grid.each_with_index do |row, y|
      row.each_with_index do |place, x|
        next unless ('0'..'9').cover? place

        idx = place.to_i
        @positions[[x, y]] = idx
        @positions_list[idx] = [x, y]
        @grid[y][x] = '.'
      end
    end
  end

  def parse_grid(lines)
    @grid = lines.map { |line| line.split '' }
  end
end

class PathFinder #:nodoc:
  def initialize(grid)
    @grid = Marshal.load(Marshal.dump(grid))
    @max_x = @grid.first.count - 1
    @max_y = @grid.count - 1
  end

  def find_path(a, b)
    @start = a
    @frontier = []
    @came_from = {}
    @cost_so_far = {}

    @frontier << { node: a, priority: 0 }
    @came_from[a] = nil
    @cost_so_far[a] = 0

    while @frontier.any?
      current = @frontier.shift
      current_node = current[:node]

      if current_node == b
        return build_path(current_node)
      end

      neighbors(current_node).each do |neighbor|
        next if @came_from.key? neighbor

        new_cost = @cost_so_far[current_node] + 1
        if !@cost_so_far.key?(neighbor) || new_cost < @cost_so_far[neighbor]
          @cost_so_far[neighbor] = new_cost
          priority = new_cost

          @frontier << { node: neighbor, priority: priority }
          @came_from[neighbor] = current_node
        end
      end
    end
  end

  private

  def build_path(node)
    current_node = node
    path = [current_node]

    while current_node != @start
      current_node = @came_from[current_node]
      path << current_node
    end

    path.reverse
  end

  def neighbors(node)
    x = node[0]
    y = node[1]

    neighbors = []
    neighbors << [x - 1, y] if x > 0
    neighbors << [x + 1, y] if x < @max_x
    neighbors << [x, y - 1] if y > 0
    neighbors << [x, y + 1] if y < @max_y

    neighbors.find_all { |n| @grid[n[1]][n[0]] == '.' } 
  end
end

lines = ARGF.each_line.map(&:chomp)

ducts = Ducts.new lines
distances = ducts.all_distances
puts "Shortest: #{distances.min}"
