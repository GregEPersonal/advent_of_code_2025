import time
from scipy.optimize import milp, LinearConstraint, Bounds
import numpy as np

# Read in the file from test_input.txt, and save it as lines. 
with open("day_10/input.txt", "r") as file:
    lines = file.readlines()

# Parse the lines into a list of lists.


def solve_line(joltage_array, button_arrays):
    #Okay, we're going to create a linear algebra matrix, and solve it. 
    target = np.array(joltage_array, dtype=int)  # or int, but milp wants float arrays
    button_matrix = np.zeros((len(joltage_array), len(button_arrays)))
    for button_index, button in enumerate(button_arrays):
        for joltage_index in button:
            button_matrix[joltage_index, button_index] = 1
    
    c = np.ones(len(button_arrays), dtype=float)

    constraint = LinearConstraint(button_matrix, lb=target, ub=target)
    bounds = Bounds(lb=np.zeros(len(button_arrays)), ub=np.full(len(button_arrays), np.inf))
    integrality = np.ones(len(button_arrays), dtype=int)  # 1 => integer variable

    res = milp(c=c, constraints=[constraint], bounds=bounds, integrality=integrality)

    # print(res.status, res.message)
    # print("x =", res.x)
    # print("total presses =", res.fun)
    return res.fun



# Solution logic
total_button_count = 0

# lines_to_skip = [13, 86, 95, 102, 112, 121, 167, 195]
lines_to_skip = []
starting_index = 0

# The rest of the lines are the lines of the file.
for line_index, line in enumerate(lines):
  start_time = time.time()

  if starting_index and line_index < starting_index:
    next
  

  if line_index in lines_to_skip:
    print(f"Skipping line {line_index}")
    next
  

  #Parse the line.
  #The first segment end where "]" is found.
  # The second segment goes from there until "{" is found.
  # The final segment goes from there until the end of the line.
  # We DO want to include the "]" and "{" in the segments.

  end_of_first_segment = line.index("]")
  start_of_third_segment = line.index("{")
  first_segment = line[:end_of_first_segment]
  second_segment = line[end_of_first_segment + 1:start_of_third_segment - 1]
  third_segment = line[start_of_third_segment:]

  # puts "Lights: #{first_segment}"
  print(f"Buttons: {second_segment}")
  print(f"Third segment: {third_segment}")

  first_segment_array = []
  for char in first_segment.strip()[1:-2]:
    if char == ".":
      first_segment_array.append(0)
    else:
      first_segment_array.append(1)
    
  
  second_segment_arrays = []
  for segment in second_segment.strip().split(" "):
    clean_array = segment.strip()[1:-1].split(",")
    second_segment_arrays.append([int(x) for x in clean_array])
  third_segment_array = []
  for item in third_segment.strip()[1:-1].split(","):
    if item != "":
      third_segment_array.append(int(item))

  # Solve this one.
  new_button_count = solve_line(third_segment_array, second_segment_arrays)
  elapsed_time = time.time() - start_time
  print(f"SOLVED! New button count: {new_button_count} for line {line_index} (Time: {elapsed_time} seconds)")
  total_button_count += new_button_count

print(f"Total button count: {total_button_count}")