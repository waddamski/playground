# take a string of numbers. Find a 1 and run until you hit 99.
# Stick them in an array.
# take the 2nd and 3rd numbers to discover which positions to add together.
# The 4th number shows which positional number to replace with the sum of the previous step.
# stop at 99
# opcode 2 means multiply but works in the same way otherwise.

# 1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2).
# 2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6).
# 2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
# 1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99.

with open('day2_input.txt') as file:
    input_str = file.read()
    input_list = input_str.split(",")
    thing = 0
    list_len = len(input_list)
    while thing < list_len:
        print("Input_List[0] = ", int(input_list[0]))
        if int(input_list[thing]) == 1:
            first = int(input_list[thing+1])
            second = int(input_list[thing+2])
            dest = int(input_list[thing+3])
            input_list[dest] = (int(input_list[first]) + int(input_list[second]))
            thing = thing + 4
        elif int(input_list[thing]) == 2:
            first = int(input_list[thing + 1])
            second = int(input_list[thing + 2])
            dest = int(input_list[thing + 3])
            input_list[dest] = (int(input_list[first]) * int(input_list[second]))
            thing = thing + 4
        elif int(input_list[thing]) == 99:
            print("Opcode = 99. Exiting")
            break
        else:
            print("SOMETHING AWFUL HAPPENED")
            break
    print("Input_List[0] = ", int(input_list[0]))