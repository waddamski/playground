# https://adventofcode.com/2019/day/1

# take module mass, calculate fuel.
# take this calc and use this as the new mass input.
# repeat until you get to zero or negative value (treat as zero)
# Fuel calc: (input // 3) - 2

total = 0

with open('day1_input.txt') as file:
    for line in file.readlines():
        mf = (int(line) // 3) - 2
        ff = (mf //3) - 2
        mod_fuel = mf + ff
        while ff > 0:
            ff = (ff // 3) - 2
            if ff > 0:
                mod_fuel = mod_fuel + ff
        total = total + mod_fuel

print("TOTAL = ", total)