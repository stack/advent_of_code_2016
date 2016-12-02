#!/usr/bin/env ruby

require 'rubygems'

require 'gtk3'
require 'rmagick'
require 'ostruct'

def turn_right(orientation)
  case orientation
  when :north
    :east
  when :east
    :south
  when :south
    :west
  when :west
    :north
  end
end

def turn_left(orientation)
  case orientation
  when :north
    :west
  when :west
    :south
  when :south
    :east
  when :east
    :north
  end
end

raw_input = File.read 'walking_instructions.txt'
directions = raw_input.strip.split ', '

background_color = Magick::Pixel.new(0, 0, 65535, 0)
visited_color = Magick::Pixel.new(65535, 52428, 0, 0)
collision_color = Magick::Pixel.new(65535, 0, 0, 0)

image_width = 500
image_height = 500
image = Magick::Image.new(image_width, image_height) do
  self.background_color = 'blue'
end

orientation = :north
x_offset = image_width / 2
y_offset = image_height / 2

current_x = x_offset
current_y = y_offset

image.pixel_color(current_x, current_y, visited_color)

directions.each_with_index do |direction, index|
  if direction =~ /([LR])(\d+)/
    # Get the next orienation
    orientation = ($1 == "L") ? turn_left(orientation) : turn_right(orientation)

    0.upto($2.to_i - 1) do
      case orientation
      when :north
        current_y -= 1
      when :south
        current_y += 1
      when :east
        current_x += 1
      when :west
        current_x -= 1
      end

      # Collision?
      current_color = image.pixel_color(current_x, current_y)
      if current_color == background_color
        image.pixel_color(current_x, current_y, visited_color)
      elsif current_color == visited_color
        puts "Collision at #{current_x - x_offset}, #{current_y - y_offset}"
        image.pixel_color(current_x, current_y, collision_color)
      elsif current_color == collision_color
        puts "Another Collision at #{current_x - x_offset}, #{current_y - y_offset}"
      else
        $stderr.puts "Bad Color Match: #{current_color.red}, #{current_color.green}, #{current_color.blue}, #{current_color.opacity}"
      end

      image.write("visit_#{'%03d' % index}.jpg")
    end
  else
    $stderr.puts "Improper direction: #{direction}"
  end
end

`rm -f visit.mp4`
`ffmpeg -f image2 -i visit_%03d.jpg -r 12 -s #{image_width}x#{image_height} -vcodec h264 visit.mkv` 
`rm -f *.jpg`

