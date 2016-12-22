#!/usr/bin/env ruby

class Node #:nodoc:
  attr_reader :x, :y
  attr_reader :name
  attr_reader :size, :used, :available

  def initialize(name, size, used, available)
    @name = name
    @size = size
    @used = used
    @available = available

    if @name =~ /node-x(?<x>\d+)-y(?<y>\d+)/
      @x = $~[:x].to_i
      @y = $~[:y].to_i
    else
      raise "Cannot find position in node named '#{@name}'"
    end
  end

  def empty?
    @used.zero?
  end

  def ==(other)
    @name == other.name
  end
end

# Collect all of the nodes
nodes = []
ARGF.each_line do |line|
  if line =~ /^(?<name>.+)\s+(?<size>\d+)T\s+(?<used>\d+)T\s+(?<avail>\d+)T/
    node = Node.new $~[:name], $~[:size].to_i, $~[:used].to_i, $~[:avail].to_i

    nodes[node.y] = [] if nodes[node.y].nil?
    nodes[node.y][node.x] = node
  end
end

# Find all of the viable pairs
viable_pairs = nodes.flatten.permutation(2).find_all do |pair|
  if pair[0].empty?
    false
  elsif pair[0] == pair[1]
    false
  else
    pair[0].used <= pair[1].available
  end
end

puts "Viable Pairs: #{viable_pairs.count}"
