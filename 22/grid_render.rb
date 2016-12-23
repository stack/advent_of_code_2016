#!/usr/bin/env ruby

require 'rubygems'

require 'RMagick'

# Color theme "Tema de cores 7" by guilhermebcpp.
# https://color.adobe.com/Tema-de-cores-7-color-theme-9015955/

class Renderer #:nodoc:
  ACCESSIBLE_COLOR = '#437356'.freeze
  BACKGROUND_COLOR = '#ffffff'.freeze
  BLOCKED_COLOR    = '#1e4147'.freeze
  EMPTY_COLOR      = '#aac789'.freeze
  GOAL_COLOR       = '#f34a53'.freeze
  PATH_COLOR       = '#fae3b4'.freeze
  VIABLE_COLOR     = '#eee'.freeze

  BLOCK_WIDTH = 20
  BLOCK_HEIGHT = 20
  BLOCK_SPACING = 2

  def initialize(width, height)
    @index = 0
    @width = width
    @height = height

    @image_width = ((BLOCK_WIDTH + BLOCK_SPACING) * width) + (BLOCK_SPACING * 2)
    @image_height = ((BLOCK_HEIGHT + BLOCK_SPACING) * height) + (BLOCK_SPACING * 2)

    @canvas = Magick::Image.new @image_width, @image_height do
      self.background_color = BACKGROUND_COLOR
    end
  end

  def draw_state(accessible, goal, empty, viable, path)
    puts "Drawing State: #{accessible.inspect} - #{goal.inspect} - #{empty.inspect}"

    # Clear the image
    gc = Magick::Draw.new
    gc.fill BACKGROUND_COLOR
    gc.rectangle 0, 0, @image_width, @image_height
    gc.draw @canvas

    # Go through every possible "pixel", drawing based on given values
    @width.times do |x|
      @height.times do |y|
        coord = [x, y]
        image_x = ((BLOCK_WIDTH + BLOCK_SPACING) * x) + BLOCK_SPACING
        image_y = ((BLOCK_HEIGHT + BLOCK_SPACING) * y) + BLOCK_SPACING

        gc = Magick::Draw.new

        color = if coord == goal
                  GOAL_COLOR
                elsif coord == empty
                  EMPTY_COLOR
                elsif path.include? coord
                  PATH_COLOR
                elsif coord == accessible
                  ACCESSIBLE_COLOR
                elsif viable.include? coord
                  VIABLE_COLOR
                else
                  BLOCKED_COLOR
                end

        gc.fill color
        gc.rectangle image_x, image_y, image_x + BLOCK_WIDTH, image_y + BLOCK_HEIGHT

        gc.draw @canvas
      end
    end

    # Generate a saved name
    name = "grid_#{@index.to_s.rjust(4, '0') }.png"
    @canvas.write name

    # Iterate
    @index += 1
  end
end

class PathFinder #:nodoc:
  def initialize(nodes, viable)
    @nodes = []
    @viable = viable
    @max_x = 0
    @max_y = 0

    nodes.each do |row|
      row.each do |node|
        @nodes[node.y] = [] if @nodes[node.y].nil?
        @nodes[node.y][node.x] = node.dup

        @max_x = [@max_x, node.x].max
        @max_y = [@max_y, node.y].max
      end
    end
  end

  def path(a, b)
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
        next unless @viable.include? neighbor

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
    neighbors = []

    neighbors << @nodes[node.y][node.x - 1] if node.x > 0
    neighbors << @nodes[node.y][node.x + 1] if node.x < @max_x
    neighbors << @nodes[node.y - 1][node.x] if node.y > 0
    neighbors << @nodes[node.y + 1][node.x] if node.y < @max_y

    neighbors
  end
end

class Grid #:nodoc:
  attr_accessor :nodes
  attr_accessor :accessible, :goal
  attr_accessor :renderer

  def initialize
    @nodes = []
    @highest_x = 0

    @accessible = [0, 0]
    @goal = [0, 0]

    @renderer = nil
  end

  def add_node(node_or_line)
    if node_or_line.is_a? Node
      add_node_object node_or_line
    elsif node_or_line.is_a? String
      add_node_line node_or_line
    else
      raise "Unhandled node type: #{node_or_line.class}"
    end
  end

  def complete?
    @accessible == @goal
  end

  def current_empty
    @nodes.each do |row|
      row.each do |node|
        return node if node.empty?
      end
    end

    nil
  end

  def goal_node
    @nodes[@goal[1]][@goal[0]]
  end

  def target_empty
    @nodes[@goal[1]][@goal[0] - 1]
  end

  def print_grid(show_path = false)
    viable = viable_pairs.flatten.uniq
    empty_node = current_empty
    target_node = target_empty

    if show_path
      viable = viable_pairs.flatten.uniq
      viable.delete goal_node
      path_finder = PathFinder.new @nodes, viable_pairs.flatten.uniq
      path = path_finder.path empty_node, target_node
    else
      path = []
    end

    total_columns = @nodes.first.count
    print '    '
    total_columns.times do |c|
      print c.to_s.rjust(2, ' ').ljust(4, ' ')
    end

    puts

    @nodes.each_with_index do |row, y|
      print y.to_s.rjust(3, ' ')
      print ' '

      row.each_with_index do |node, x|
        char = if node.coord == @goal
                 'G'
               elsif node.empty?
                 '_'
               elsif !path.nil? && path.include?(node)
                 'O'
               elsif node.full?
                 '#'
               elsif viable.include?(node)
                 '.'
               else
                 '#'
               end

        output = if node == empty_node
                   "[#{char}] "
                 elsif node == target_node
                   "{#{char}} "
                 elsif node.coord == @accessible
                   "(#{char}) "
                 else
                   " #{char}  "
                 end

        print output
      end

      puts
    end

    unless show_path
      print_grid(true)
    end
  end

  def step
    empty_node = current_empty
    empty_coord = empty_node.coord
    target_node = target_empty
    goal = goal_node

    viable = viable_pairs.flatten.uniq
    viable.delete goal

    finder = PathFinder.new @nodes, viable
    path = finder.path empty_node, target_node
    target = path[1]

    if empty_node != target_node # A blank space is needed in front of the goal to move it
      swap = @nodes[target.y][target.x]
      empty_node.used = swap.used
      empty_node.available = empty_node.size - empty_node.used
      swap.used = 0
      swap.available = swap.size
    else # There's space to move, so do it
      target_node.used = goal.used
      target_node.available = target_node.size - target_node.used
      goal.used = 0
      goal.available = goal.size
      @goal = [@goal[0] - 1, @goal[1]]
      empty_coord = [empty_coord[0] + 1, empty_coord[1]]
    end

    unless @renderer.nil?
      viable_coords = viable.map(&:coord)
      path_coords = path.map(&:coord)
      @renderer.draw_state @accessible, @goal, empty_coord, viable_coords, path_coords
    end
  end

  def viable_pairs
    @nodes.flatten.permutation(2).find_all do |pair|
      if pair[0].empty? || pair[0] == pair[1]
        false
      else
        pair[0].used <= pair[1].available
      end
    end
  end

  private

  def add_node_line(line)
    match = /^(?<name>.+)\s+(?<size>\d+)T\s+(?<used>\d+)T\s+(?<avail>\d+)T/.match line
    return if match.nil?

    name = match[:name]
    size = match[:size].to_i
    used = match[:used].to_i
    avail = match[:avail].to_i

    node = Node.new name, size, used, avail
    add_node_object node
  end

  def add_node_object(node)
    @nodes[node.y] = [] if @nodes[node.y].nil?
    @nodes[node.y][node.x] = node

    if node.y == 0
      @highest_x = [@highest_x, node.x].max
      @goal = [@highest_x, 0]
    end
  end
end

class Node #:nodoc:
  attr_reader :x, :y
  attr_reader :name, :size
  attr_accessor :available, :used

  def initialize(name, size, used, available)
    @name = name.strip
    @size = size
    @used = used
    @available = available

    match = /node-x(?<x>\d+)-y(?<y>\d+)/.match @name
    raise "Cannot find position in node named '#{@name}'" if match.nil?

    @x = match[:x].to_i
    @y = match[:y].to_i
  end

  def coord
    [@x, @y]
  end

  def dup
    Node.new name.dup, size, used, available
  end

  def empty?
    @used.zero?
  end

  def eq?(other)
    hash == other.hash
  end

  def full?
    @available.zero?
  end

  def hash
    @name.hash
  end

  def ==(other)
    @name == other.name
  end
end

# Collect all of the nodes
grid = Grid.new
ARGF.each_line do |line|
  grid.add_node line
end

# Find all of the viable pairs
viable_pairs = grid.viable_pairs
puts "Viable Pairs: #{viable_pairs.count}"

# Build the renderer
renderer = Renderer.new grid.nodes.first.count, grid.nodes.count
grid.renderer = renderer

# Print the initial state
steps = 0
loop do
  grid.step
  steps += 1

  break if grid.complete?
end

puts "Steps: #{steps}"
