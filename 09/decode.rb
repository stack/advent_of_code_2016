#!/usr/bin/env ruby

if ARGV[0].nil?
  $stderr.put 'You must provide an input file'
  exit 1
end

data = File.read ARGV[0]

left = ''
remainder = data.split('')

while remainder.any?
  current = remainder.shift

  # Advance if normal
  if current != '('
    left += current
    next
  end

  # Read a marker
  marker = ''
  while current != ')'
    current = remainder.shift
    marker += current
  end

  # Parse the marker
  if marker =~ /(\d+)x(\d+)/
    length = $1.to_i
    count = $2.to_i
  else
    raise "Invalid marker: #{marker}"
  end

  # Get the string
  repeated = ''
  length.times { repeated += remainder.shift }

  # Append
  left += (repeated * count)

  puts left
end

puts "Length: #{left.length}"
