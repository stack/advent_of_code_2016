#!/usr/bin/env ruby

class Parser
  def self.parse(data)
    parser = Parser.new
    parser.parse(data)
  end

  def parse(data)
    # Initialize state
    @nodes = []
    @state = :none
    @buffer = ''
    @letters = data.split('')

    while @letters.any?
      letter = @letters.shift

      if @state == :none
        @buffer += letter
        @state = (letter == '(') ? :marker : :word
      elsif @state == :word
        if letter == '('
          handle_word
          @buffer = letter
          @state = :marker
        else
          @buffer += letter
        end
      elsif @state == :marker
        @buffer += letter
        if letter == ')'
          handle_marker
          @state = :none
        end
      end
    end

    if @state == :word
      handle_word
    elsif @state == :marker
      handle_marker
    end

    @nodes
  end

  private

  def handle_word
    @nodes << DataNode.new(@buffer) unless @buffer.empty?
    @buffer = ''
  end

  def handle_marker
    if @buffer =~ /\((\d+)x(\d+)\)/
      marker = @buffer
      length = $1.to_i
      count = $2.to_i

      @buffer = ''
      length.times { @buffer += @letters.shift }

      @nodes << MarkerNode.new(marker, length, count, @buffer)
      @buffer = ''
    else
      raise "Invalid marker: #{@buffer}"
    end
  end
end

class Node
  def dots
    raise NotImplementedError
  end

  def length
    raise NotImplementedError
  end
end

class RootNode < Node
  def initialize(data)
    @children = Parser.parse data
  end

  def dots
    dots = @children.map { |child| "ROOT -> #{child.object_id}" }
    dots += @children.map { |child| child.dots }.flatten
  end

  def length
    @children.reduce(0) { |sum, x| sum + x.length }
  end
end

class DataNode < Node
  def initialize(data)
    @data = data
  end

  def dots
    ["#{self.object_id}[label=\"#{@data}\"]"]
  end

  def length
    @data.length
  end
end

class MarkerNode < Node
  def initialize(marker, marker_length, marker_count, data)
    @marker = marker
    @marker_length = marker_length
    @marker_count = marker_count
    @children = Parser.parse data
  end

  def dots
    dots = ["#{self.object_id}[label=\"#{@marker}\"]"]
    dots += @children.map { |child| "#{self.object_id} -> #{child.object_id}" }
    dots += @children.map { |child| child.dots }.flatten
  end

  def length
    length = @children.reduce(0) { |sum,x| sum + x.length }
    length * @marker_count
  end
end

data = ARGF.read.chomp
root = RootNode.new data

puts "Nodes: #{root.inspect}"
puts "Length: #{root.length}"

dots = root.dots
File.open 'graph.gv', 'w' do |f|
  f.puts 'digraph {'

  dots.each do |dot|
    f.puts "\t#{dot}"
  end

  f.puts '}'
end

`dot graph.gv -Tpng -o graph.png`
