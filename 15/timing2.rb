#!/usr/bin/env ruby

ARGF.each_line do |line|
  if line =~ /Disc #(\d+) has (\d+) positions; at time=(\d+), it is at position (\d+)./
    idx = $1.to_i - 1
    size = $2.to_i
    time = $3.to_i
    position = $4.to_i

    sculpture.add_disc idx, size, position, time
  else
    raise "Invalid input: #{line}"
  end
end

