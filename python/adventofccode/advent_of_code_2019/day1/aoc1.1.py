# https://adventofcode.com/2019/day/1
# take input, divide by 12, round down and then subtract 2.

total = 0

with open('day1_input.txt') as file:
    for line in file.readlines():
        # print(int(line))
        res = (int(line) // 3) - 2
        # print(res)
        total = total + res

print("TOTAL = ", total)