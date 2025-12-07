# Solution for Day 5

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_05/input.txt")

def test_fresh(number, range_array)
  for i in 0..range_array[0].length - 1
    if number >= range_array[0][i] && number <= range_array[1][i]
      return true
    end
  end
  return false
end

# Solution logic
reading_ranges = true
range_array = Array.new(2) { Array.new(0) }
fresh_count = 0

lines.each_with_index do |line, index|
  if line.empty?
    reading_ranges = false
  end

  if reading_ranges
    low, high = line.split("-").map(&:to_i)
    range_array[0][index] = low
    range_array[1][index] = high
  else
    number = line.to_i
    is_fresh = test_fresh(number, range_array)
    if is_fresh
      fresh_count += 1
    end
  end
end

puts fresh_count
