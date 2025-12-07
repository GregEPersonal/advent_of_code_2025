# Solution for Day 7

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_07/input.txt")

# Solution logic

# OKay, so we'll parse this into a 2D array..
# Then we'll find S in teh first line, and store the index.
# For the next line, we'll check if it hits a splitter, and if so, we'll store the new indices.

splitter_map = Array.new(lines.length) { Array.new(lines[0].length, ".") }
start_index = nil

lines.each_with_index do |line, col_index|
  splitter_map[col_index] = line.split("")
end

start_index = splitter_map[0].index("S")

# Okay, next up, for each row, we iterate and adjust the tracked indices.
tachyon_indices = [start_index]
tachyon_split_count = 0

splitter_map.each_with_index do |row, row_index|
  next if row_index == 0 # Skip the first one, we've already done it.
  new_tachyon_indices = []
  for i in tachyon_indices
    if row[i] == "^"
      new_tachyon_indices << i - 1
      new_tachyon_indices << i + 1
      tachyon_split_count += 1
    else
      new_tachyon_indices << i
    end
  end
  new_tachyon_indices.uniq!
  tachyon_indices = new_tachyon_indices
end

puts "Tachyon beam count: #{tachyon_indices.length}"
puts "Tachyon split count: #{tachyon_split_count}"
