# Solution for Day 8

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_08/input.txt")

class JunctionBox
  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
    @connected_list = []
  end

  def x
    return @x
  end

  def y
    return @y
  end

  def z
    return @z
  end

  def to_s
    return "#{@x},#{@y},#{@z}"
  end

  def distance(other_junction_box)
    return Math.sqrt((@x - other_junction_box.x) ** 2 + (@y - other_junction_box.y) ** 2 + (@z - other_junction_box.z) ** 2)
  end

  def connected_list
    return @connected_list
  end

  def add_connected_junction(other_junction_box)
    @connected_list << other_junction_box
  end
end

def update_circuits_list(circuits_list, i, j)
  # First, we need to find the circuits that contain i and j.
  i_circuit = nil
  i_circuit_index = nil
  j_circuit = nil
  j_circuit_index = nil
  circuits_list.each_with_index do |circuit, index|
    if circuit.include?(i)
      i_circuit = circuit
      i_circuit_index = index
    end
    if circuit.include?(j)
      j_circuit = circuit
      j_circuit_index = index
    end
  end
  if i_circuit == j_circuit
    return circuits_list
  end

  circuits_list[i_circuit_index] = i_circuit.concat(j_circuit)
  circuits_list.delete(j_circuit)
  return circuits_list
end

# Solution logic

junction_array = []

lines.each do |line|
  x, y, z = line.split(",").map(&:to_i)
  junction_array << JunctionBox.new(x, y, z)
end

# Let's try the calculate everything way first.
# calc_array = Array.new(junction_array.length) { Array.new(junction_array.length, -1) }
# junction_array.each_with_index do |junction, i|
#   junction_array.each_with_index do |other_junction, j|
#     if i != j && i < j
#       calc_array[i][j] = junction.distance(other_junction)
#     end
#   end
# end

# Let's try calculate everything with a hash.
calc_array = {}
junction_array.each_with_index do |junction, i|
  junction_array.each_with_index do |other_junction, j|
    if i != j && i < j
      calc_array[i.to_s + "," + j.to_s] = junction.distance(other_junction)
    end
  end
end

# Okay, now we want to sort the full hashby distance, and keep track of the indices for each distance.
sorted_calc_array = calc_array.sort_by { |key, value| value }

# Connected Circuits List
# Initially, a list of the indices, 0-length-1.
circuits_list = []
for i in 0..junction_array.length - 1
  circuits_list << [i]
end

# Now, we iterate through X steps, and take teh shortest distance and add the indices to the connected list.

final_i = nil
final_j = nil

sorted_calc_array.each do |key, value|
  i, j = key.split(",").map(&:to_i)
  circuits_list = update_circuits_list(circuits_list, i, j)
  if circuits_list.length == 1
    final_i = i
    final_j = j
    break
  end
end

final_result = junction_array[final_i].x * junction_array[final_j].x
puts "Result is: #{final_result}"
