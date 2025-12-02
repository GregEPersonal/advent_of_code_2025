# Solution for Day 1

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_01/input.txt")

#Parse the line
def parse_line(line)
  letter_sign = line[0]
  if letter_sign == "L"
    sign = -1
  else
    sign = 1
  end

  amount = line[1..-1].to_i
  return sign, amount
end

# Solution logic
starting_position = 50
zero_count = 0

lines.each do |line|
  sign, amount = parse_line(line)
  shift_amount = sign * amount

  original_position = starting_position
  starting_position += shift_amount

  if starting_position <= 0
    # If it is zero or less, then we have passed the zero point and we need to count the rotations we had to make to get to the zero point.
    zero_count += (starting_position.abs / 100) + 1
    # If the original position was 0, we need to subtract 1 because we don't count the zero at the start
    if original_position == 0
      zero_count -= 1
    end
    # If the new starting_position is > 100, then we add all the rotations we had to the zero count.
    # Same logic applies for when it is exactly 100.
  elsif starting_position >= 100
    zero_count += (starting_position / 100).abs
  end

  starting_position = starting_position % 100

  # puts "New position: #{starting_position}, Zero count: #{zero_count}, Shift amount: #{shift_amount}"
end

puts "Zero count: #{zero_count}"
