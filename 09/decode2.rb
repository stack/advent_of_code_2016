#!/usr/bin/env ruby

class Node
  def self.parse_children(data)
    children = []

    state = :none
    buffer = ''

    letters = data.split('')
    while letters.any?
      letter = letters.shift

      if state == :none
        buffer += letter
        if letter == '('
          state = :marker
        else
          state = :word
        end
      elsif state == :word
        if letter == '('
          children << DataNode.new(buffer) unless buffer.empty?
          buffer = letter
          state = :marker
        else
          buffer += letter
        end
      elsif state == :marker
        buffer += letter
        if letter == ')'
          if buffer =~ /\((\d+)x(\d+)\)/
            marker = buffer
            length = $1.to_i
            count = $2.to_i

            buffer = ''
            length.times { buffer += letters.shift }

            children << MarkerNode.new(marker, length, count, buffer)
            buffer = ''
          else
            raise "Invalid marker: #{buffer}"
          end

          state = :none
        end
      end
    end

    if state == :word && !buffer.empty?
      children << DataNode.new(buffer)
    elsif state == :marker
      if buffer =~ /\((\d+)x(\d+)\)/
        marker = buffer
        length = $1.to_i
        count = $2.to_i

        buffer = ''
        length.times { buffer += letters.shift }

        children << MarkerNode.new(marker, length, count, buffer)
      else
        raise "Invalid marker: #{buffer}"
      end
    end

    children 
  end

  def length
    0
  end
end

class DataNode < Node
  def initialize(data)
    @data = data
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
    @children = Node.parse_children(data)
  end

  def length
    length = @children.reduce(0) { |sum,x| sum + x.length }
    length * @marker_count
  end
end

data = ARGF.read.chomp
nodes = Node.parse_children data

puts "Nodes: #{nodes.inspect}"

length = nodes.reduce(0) { |sum,x| sum + x.length }
puts "Length: #{length}"
