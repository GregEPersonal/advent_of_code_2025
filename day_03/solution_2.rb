# Solution for Day 3

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_03/input.txt")

# Find max_joltage of a line.
def max_joltage(line, joltage_length)
  # If the joltage length is 1, then we just return the max number on the line.
  if joltage_length == 1
    return line.chars.max
  end

  # First, find the max number on the line that isn't in the last spot.
  first_digit = 0
  9.downto(0) do |max_number|
    if line[0..(-1 * joltage_length)].include?(max_number.to_s)
      first_digit = max_number
      break
    end
  end

  first_index = line.index(first_digit.to_s)

  # Then recursively get the rest.
  return first_digit.to_s + max_joltage(line[first_index + 1..-1], joltage_length - 1)
end

# Solution logic
#
total_joltage = 0

lines.each do |line|
  temp_joltage = max_joltage(line, 12).to_i
  puts temp_joltage
  total_joltage += temp_joltage
end

puts total_joltage
