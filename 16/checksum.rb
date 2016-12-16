#!/usr/bin/env ruby

def checksum(data)
  sum = data.split('').each_slice(2).map { |x| (x == ['0', '0'] || x == ['1', '1']) ? '1' : '0' }.join('')

  if sum.length.even?
    checksum(sum)
  else
    sum
  end
end

def generate(seed, length)
  data = seed

  while data.length < length
    data = step1(data)
  end

  data[0, length]
end

def step1(data)
  a = data
  b = a.split('').reverse.map { |x| x == '0' ? '1' : '0' }.join('')

  a + '0' + b
end

# Testing
puts 'Testing Step 1'
raise unless step1('1') == '100'
raise unless step1('0') == '001'
raise unless step1('11111') == '11111000000'
raise unless step1('111100001010') == '1111000010100101011110000'
puts 'Success!'

puts
puts 'Testing Generation'
raise unless generate('1', 2) == '10'
raise unless generate('111100001010', 10) == '1111000010'
puts 'Success!'

puts
puts 'Testing Checksum'
raise unless checksum('110010110100') == '100'
puts 'Success!'

puts
puts 'Testing Process'
raise unless generate('10000', 20) == '10000011110010000111'
raise unless checksum('10000011110010000111') == '01100'
puts 'Success!'
puts

if ARGV[0].nil?
  $stderr.puts 'Input is required'
  exit
end

input = ARGV[0]

if ARGV[1].nil?
  $stderr.puts 'Length is required'
  exit
end

length = ARGV[1].to_i

expanded_data = generate input, length
sum = checksum expanded_data
puts "CHECKSUM: #{sum}"
