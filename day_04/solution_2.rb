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

# Part 1 Logic:
def remove_one_layer(lines, height, width, running_sum)
  counter = Array.new(height) { Array.new(width, 0) }

  new_lines = lines.dup

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

  newly_removed = 0
  easy_view = Array.new(height) { Array.new(width, ".") }

  # Only add up the ones that have an @ in that index.
  for y in 0..height - 1
    lines[y].chars.each_with_index do |char, x|
      if char == "@"
        # Only add if there are fewer than 4 adjacent @'s'
        if counter[y][x] < 4
          newly_removed += 1
          easy_view[y][x] = "x"
          new_lines[y][x] = "."
        else
          easy_view[y][x] = "@"
        end
      end
    end
  end
  puts "Wave completed. Removed #{newly_removed} trees. Running sum is now #{running_sum + newly_removed}. Map:"
  print_counter(easy_view)
  return new_lines, running_sum + newly_removed, newly_removed
end

# Solution logic

height = lines.length
width = lines[0].length

new_lines = lines.dup
running_sum = 0
newly_removed = 1
wave_count = 0

while newly_removed > 0
  new_lines, running_sum, newly_removed = remove_one_layer(new_lines, height, width, running_sum)
  wave_count += 1
end

puts "Running sum: #{running_sum}"
puts "Wave count: #{wave_count}"
