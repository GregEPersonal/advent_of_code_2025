# Solution for Day 4

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_04/input.txt")

# Just add to all adjacent squares.
def add_to_counter(counter, y, x, height, width)
  counter[y - 1][x - 1] += 1 if y - 1 >= 0 && x - 1 >= 0
  counter[y - 1][x] += 1 if y - 1 >= 0
  counter[y - 1][x + 1] += 1 if y - 1 >= 0 && x + 1 < width
  counter[y][x - 1] += 1 if x - 1 >= 0
  counter[y][x + 1] += 1 if x + 1 < width
  counter[y + 1][x - 1] += 1 if y + 1 < height && x - 1 >= 0
  counter[y + 1][x] += 1 if y + 1 < height
  counter[y + 1][x + 1] += 1 if y + 1 < height && x + 1 < width
  return counter
end

# Print the counter.
def print_counter(counter)
  counter.each do |row|
    puts row.join(" ")
  end
end

# Solution logic

height = lines.length
width = lines[0].length

counter = Array.new(height) { Array.new(width, 0) }

# For each row
for y in 0..height - 1
  line = lines[y]

  # For each column
  line.chars.each_with_index do |char, x|
    # Add to all the adjacent squares if it is an @
    if char == "@"
      counter = add_to_counter(counter, y, x, height, width)
    end
  end
end

running_sum = 0
easy_view = Array.new(height) { Array.new(width, ".") }

# Only add up the ones that have an @ in that index.
for y in 0..height - 1
  lines[y].chars.each_with_index do |char, x|
    if char == "@"
      # Only add if there are fewer than 4 adjacent @'s'
      if counter[y][x] < 4
        running_sum += 1
        easy_view[y][x] = "x"
      else
        easy_view[y][x] = "@"
      end
    end
  end
end

# print_counter(easy_view)
# print_counter(counter)
puts running_sum
