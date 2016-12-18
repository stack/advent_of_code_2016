#!/usr/bin/env ruby

def next_row(row)
  row = types_for_row(row).map do |types|
    case types
    when ['^', '^', '.'] then '^'
    when ['.', '^', '^'] then '^'
    when ['^', '.', '.'] then '^'
    when ['.', '.', '^'] then '^'
    else
      '.'
    end
  end

  row.join ''
end

def safe_tiles(row)
  row.split('').find_all { |x| x == '.' }.count
end

def types_for_row(row)
  Array.new(row.length) do |idx|
    [
      idx.zero? ? '.' : row[idx - 1],
      row[idx],
      row[idx + 1] || '.'
    ]
  end
end

if ARGV[0].nil?
  $stderr.puts 'You must supply an initial row'
  exit 1
end

initial = ARGV[0]

if ARGV[1].nil?
  $stderr.puts 'You must supply a max number of rows'
  exit 1
end

max_rows = ARGV[1].to_i
rjust = max_rows.to_s.length

total_safe = 0
current_row = initial
row_count = 0

loop do
  safe = safe_tiles(current_row)
  total_safe += safe
  puts "#{row_count.to_s.rjust(rjust)}: #{current_row} (#{safe}, #{total_safe})"

  row_count += 1

  break if row_count == max_rows

  current_row = next_row current_row
end
