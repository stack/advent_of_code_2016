#!/usr/bin/env ruby

require 'ostruct'


class Room
  attr_reader :name, :sector, :checksum

  ROOM_REGEX = /^(?<name>.+)-(?<sector>\d+)\[(?<checksum>[a-z]{5})\]$/

  def initialize(line)
    match = ROOM_REGEX.match(line)

    @name = match['name']
    @sector = match['sector'].to_i
    @checksum = match['checksum']
  end

  def decrypted_name
    decrypted = @name.split('').map { |x|
      if x == '-'
        ' '
      else
        value = x.ord
        value -= 97
        value += @sector
        value = value % 26
        value += 97

        value.chr('UTF-8')
      end
    }

    decrypted.join('')
  end

  def valid?
    puts "ROOM: #{@name}: #{@sector} [#{@checksum}]"
    test = checksum_from_stats

    puts "- CHECKSUM: #{test}"

    checksum_from_stats == @checksum
  end

  private

  def checksum_from_stats
    stats = letter_stats

    sorted = stats.sort do |x,y|
      if x[1] == y[1]
        x[0] <=> y[0]
      else
        y[1] <=> x[1]
      end
    end

    sorted[0..4].map { |x| x[0] }.join('')
  end

  def letter_stats
    letters = @name.gsub('-', '').split('').sort
    stats = []

    puts "- LETTERS: #{letters.inspect}"

    unique_letters = letters.uniq
    stats = unique_letters.map do |letter|
      count = letters.reduce(0) { |sum, x| sum + (x == letter ? 1 : 0) }
      [letter, count]
    end

    puts "- STATS: #{stats}"

    stats
  end

end

all_rooms = File.readlines('rooms.txt').map do |line|
  Room.new line
end

valid_rooms = all_rooms.find_all { |x| x.valid? }
valid_sum = valid_rooms.reduce(0) { |sum, room| sum += room.sector }

puts "---"
puts "Final Sum: #{valid_sum}"
puts "---"

valid_rooms.each do |room|
  puts "#{room.name} - #{room.sector} -> #{room.decrypted_name}"
end

