# Solution for Day 9

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_09/input.txt")

# Solution logic
# Eh, let's just brute force it for now.
rectangle_coords = []
lines.each do |line|
  x, y = line.split(",").map(&:to_i)
  rectangle_coords << [x, y]
end

# Next up, we calcualte largest rectangle
largest_rectangle = 0
rectangle_coords.each_with_index do |coord, first_index|
  x, y = coord
  rectangle_coords.each_with_index do |other_coord, second_index|
    other_x, other_y = other_coord
    # if second_index > first_index
    rectangle = ((x - other_x).abs + 1) * ((y - other_y).abs + 1)
    if rectangle > largest_rectangle
      largest_rectangle = rectangle
    end
    # end
  end
end

puts largest_rectangle
