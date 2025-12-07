# Solution for Day 5

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_05/input.txt")

# Solution logic
reading_ranges = true
range_array = []

lines.each_with_index do |line, index|
  if line.empty?
    reading_ranges = false
  end

  if reading_ranges
    low, high = line.split("-").map(&:to_i)
    range_array[index] = [low, high]
  end
end

# Okay, so we basically, for each range, check if it overlaps with any other range.
# If it does, then we extend the original range to include the new range.
def iterate_on_combining_ranges(range_array)
  new_range_array = []
  combined_ranges = false

  range_array.each_with_index do |range, index|
    low, high = range
    unique_range = true
    new_range_array.each_with_index do |compared_range, new_index|
      compared_low, compared_high = compared_range

      # IF we are totally outside of
      if low > compared_high || high < compared_low
        next # Could just leave out this case, but it is here for clarity.
      elsif low >= compared_low && high <= compared_high
        # We are completely inside of the new range, so we don't need to add it.
        unique_range = false
        combined_ranges = true
        break
      elsif low >= compared_low
        unique_range = false
        combined_ranges = true
        new_range_array[new_index] = [compared_low, high]
        break
      elsif high <= compared_high
        unique_range = false
        combined_ranges = true
        new_range_array[new_index] = [low, compared_high]
        break
      elsif low <= compared_low && high >= compared_high
        unique_range = false
        combined_ranges = true
        new_range_array[new_index] = [low, high]
        break
      end
    end
    new_range_array << range if unique_range
    combined_ranges = true if !unique_range
  end
  return new_range_array, combined_ranges
end

# Loop until we have no more combined ranges.
new_range_array = range_array
loop do
  new_range_array, combined_ranges = iterate_on_combining_ranges(new_range_array)
  break if !combined_ranges
end

total_count = 0

new_range_array.each do |range|
  low, high = range
  total_count += high - low + 1
  puts "Range: #{range}, Unique count: #{high - low + 1}"
end

puts total_count
