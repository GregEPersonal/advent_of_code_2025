# Solution for Day 9

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_09/input.txt")

def print_test_case(point_to_check, point_a, point_b)
  full_array = Array.new(9) { Array.new(14, ".") }

  @rectangle_coords.each do |coord|
    full_array[coord[1]][coord[0]] = "#"
  end

  full_array[point_to_check[1]][point_to_check[0]] = "X"
  full_array[point_a[1]][point_a[0]] = "A"
  full_array[point_b[1]][point_b[0]] = "B"

  full_array.each do |line|
    puts line.join("")
  end
end

def calc_distance(point_a, point_b)
  return Math.sqrt((point_b[0] - point_a[0]) ** 2 + (point_b[1] - point_a[1]) ** 2)
end

def calculate_angle(point_to_check, point_a, point_b)
  check_to_a = calc_distance(point_to_check, point_a)
  check_to_b = calc_distance(point_to_check, point_b)
  a_to_b = calc_distance(point_a, point_b)

  #Calculate direction of vector
  ca_x = point_a[0] - point_to_check[0]
  ca_y = point_a[1] - point_to_check[1]
  cb_x = point_b[0] - point_to_check[0]
  cb_y = point_b[1] - point_to_check[1]

  cross = cb_y * ca_x - cb_x * ca_y
  clockwise = cross > 0 ? 1 : -1

  partial = (check_to_a ** 2 + check_to_b ** 2 - a_to_b ** 2) / (2 * check_to_a * check_to_b)
  partial = partial.clamp(-1, 1)
  angle = Math.acos(partial) * 180 / Math::PI

  # print_test_case(point_to_check, point_a, point_b)
  # puts "Angle: #{angle}"
  # puts "Clockwise: #{clockwise}"

  # binding.pry

  #Calculate angle
  return clockwise * angle
end

def point_on_line(coords_array, hashed_x_coords, hashed_y_coords, point_to_check)
  matching_x_indices = hashed_x_coords[point_to_check[0]]
  matching_y_indices = hashed_y_coords[point_to_check[1]]

  if !matching_x_indices.nil?
    for index in matching_x_indices
      point_a = coords_array[index]
      point_b = coords_array[(index + 1) % coords_array.length]
      if (point_to_check[1] >= point_a[1] && point_to_check[1] <= point_b[1]) || (point_to_check[1] <= point_a[1] && point_to_check[1] >= point_b[1])
        return true
      end
    end
  end
  if !matching_y_indices.nil?
    for index in matching_y_indices
      point_a = coords_array[index]
      point_b = coords_array[(index + 1) % coords_array.length]
      if (point_to_check[0] >= point_a[0] && point_to_check[0] <= point_b[0]) || (point_to_check[0] <= point_a[0] && point_to_check[0] >= point_b[0])
        return true
      end
    end
  end
  return false
end

def point_in_area(coords_array, hashed_x_coords, hashed_y_coords, point_to_check)
  total_angle = 0.0

  if coords_array.include?(point_to_check)
    # puts " - Part of coord array"
    return true
  end

  # Next up, check if it's on one of the lines.
  # That is, we check if the coords_array has two adjacent points in which the point_to_check is between them.
  if point_on_line(coords_array, hashed_x_coords, hashed_y_coords, point_to_check)
    return true
  end

  last_point = coords_array.last
  coords_array.each do |next_point|
    point_angle = calculate_angle(point_to_check, last_point, next_point)
    # puts "For point #{next_point[0]},#{next_point[1]}, add'l angle is #{point_angle}"
    total_angle += point_angle
    last_point = next_point
  end

  if ((360 - total_angle).abs < 0.25)
    return true
  else
    # puts " - Not in area. Point #{point_to_check[0]},#{point_to_check[1]} : angle sum is #{total_angle}"
    return false
  end
end

def other_corners_in_area(coords_array, hashed_x_coords, hashed_y_coords, corner_1, corner_2)
  corner_3 = [corner_1[0], corner_2[1]]
  corner_4 = [corner_2[0], corner_1[1]]

  point_3_in_area = point_in_area(coords_array, hashed_x_coords, hashed_y_coords, corner_3)
  point_4_in_area = point_in_area(coords_array, hashed_x_coords, hashed_y_coords, corner_4)
  # print_test_case(corner_1, corner_3, corner_4)
  # puts "Point 3: #{corner_3[0]},#{corner_3[1]} in area: #{point_3_in_area}"
  # puts "Point 4: #{corner_4[0]},#{corner_4[1]} in area: #{point_4_in_area}"
  return point_3_in_area && point_4_in_area

  # return point_in_area(coords_array, corner_3) && point_in_area(coords_array, corner_4)
end

# Validate a lot of points in the rectangle to ensure it's good.
def validate_largest_rectangle(coords_array, hashed_x_coords, hashed_y_coords, corner_1, corner_2)
  x_1 = corner_1[0]
  x_2 = corner_2[0]
  y_1 = corner_1[1]
  y_2 = corner_2[1]

  # Just assert that the 1's are smaller.
  if x_1 > x_2
    temp_x = x_2
    x_2 = x_1
    x_1 = temp_x
  end
  if y_1 > y_2
    temp_y = y_2
    y_2 = y_1
    y_1 = temp_y
  end

  puts "Validating rectangle with x coordinates: #{x_1},#{x_2} and y coordinates: #{y_1},#{y_2}"
  # For each perimeter, select 100 points, evenly spaced, and check whether the point is in the area.
  num_steps = 100
  x_diff = x_2 - x_1
  x_gap = [x_diff / num_steps, 1].max
  y_diff = y_2 - y_1
  y_gap = [y_diff / num_steps, 1].max

  # counter = 0

  x_test = x_1
  while x_test < x_2
    top_in_area = point_in_area(coords_array, hashed_x_coords, hashed_y_coords, [x_test, y_1])
    bottom_in_area = point_in_area(coords_array, hashed_x_coords, hashed_y_coords, [x_test, y_2])
    if !top_in_area || !bottom_in_area
      return false
    end
    x_test += x_gap
    # counter += 1
    # puts "Checked #{counter} of #{num_steps} points on the top and bottom" if counter % 10 == 0
  end

  y_test = y_1
  while y_test < y_2
    left_in_area = point_in_area(coords_array, hashed_x_coords, hashed_y_coords, [x_1, y_test])
    right_in_area = point_in_area(coords_array, hashed_x_coords, hashed_y_coords, [x_2, y_test])
    if !left_in_area || !right_in_area
      return false
    end
    y_test += y_gap
    # counter += 1
    # puts "Checked #{counter} of #{num_steps} points on the left and right" if counter % 10 == 0
  end

  return true
end

# Solution logic
# Eh, let's just brute force it for now.
rectangle_coords = []
lines.each do |line|
  x, y = line.split(",").map(&:to_i)
  rectangle_coords << [x, y]
end
@rectangle_coords = rectangle_coords

# Hash each coordinate
hashed_x_coords = {}
hashed_y_coords = {}
rectangle_coords.each_with_index do |coord, index|
  if hashed_x_coords[coord[0]] == nil
    hashed_x_coords[coord[0]] = []
  end
  if hashed_y_coords[coord[1]] == nil
    hashed_y_coords[coord[1]] = []
  end
  hashed_x_coords[coord[0]] << index
  hashed_y_coords[coord[1]] << index
end

# Test code to evaluate the input file
# last_point = rectangle_coords.last
# x_increasing = true
# y_increasing = true
# min_x_distance = 100000
# min_y_distance = 100000
# rectangle_coords.each_with_index do |coord, index|
#   last_x, last_y = last_point
#   x, y = coord

#   if (x - last_x).abs < min_x_distance && (x - last_x).abs > 0
#     min_x_distance = (x - last_x).abs
#     puts "New min x distance: #{min_x_distance}"
#   end

#   if (y - last_y).abs < min_y_distance && (y - last_y).abs > 0
#     min_y_distance = (y - last_y).abs
#     puts "New min y distance: #{min_y_distance}"
#   end

#   if x_increasing
#     if (x - last_x < 0)
#       puts "Changed x-direction at index #{index} - point #{x},#{y}"
#       x_increasing = false
#     end
#   else
#     if (x - last_x > 0)
#       puts "Changed x-direction at index #{index} - point #{x},#{y}"
#       x_increasing = true
#     end
#   end

#   if y_increasing
#     if (y - last_y < 0)
#       puts "Changed y-direction at index #{index} - point #{x},#{y}"
#       y_increasing = false
#     end
#   else
#     if (y - last_y > 0)
#       puts "Changed y-direction at index #{index} - point #{x},#{y}"
#       y_increasing = true
#     end
#   end
#   last_point = coord
# end

# For each rectangle
# - If points don't cross bad coords line
# - If larger than last one
# - Check if oppososite corners are in using sum angles algorithm

# Hardcoded bad coords from input.
bad_y_coords = [50002, 48778]

# Next up, we calcualte largest rectangle
largest_rectangle = 0
total_checks = 0
rectangle_coords.each_with_index do |coord, first_index|
  x, y = coord
  rectangle_coords.each_with_index do |other_coord, second_index|
    other_x, other_y = other_coord
    # Don't double check
    if second_index > first_index
      rectangle = ((x - other_x).abs + 1) * ((y - other_y).abs + 1)
      if rectangle > largest_rectangle
        # puts "Checking rectangle with corners: #{x},#{y} & #{other_x},#{other_y}"
        if (other_y >= bad_y_coords[0] && y >= bad_y_coords[0]) || (other_y <= bad_y_coords[1] && y <= bad_y_coords[1])
          if other_corners_in_area(rectangle_coords, hashed_x_coords, hashed_y_coords, [x, y], [other_x, other_y])
            puts "Validating new largest rectangle; Corners: #{x},#{y} & #{other_x},#{other_y}; size: #{largest_rectangle}"
            if validate_largest_rectangle(rectangle_coords, hashed_x_coords, hashed_y_coords, [x, y], [other_x, other_y])
              largest_rectangle = rectangle
              puts "New largest rectangle: #{largest_rectangle}"
              puts "Corners: #{x},#{y} & #{other_x},#{other_y}"
              # print_test_case([x, y], [other_x, other_y], [x, other_y])
            else
              puts "Validation failed"
            end
          end
        end
      end
    end
  end
  total_checks += 1
  puts "Total checks: #{total_checks}" if total_checks % 20 == 0
end

puts largest_rectangle
