def is_valid_walk(walk):
    #determine if walk is valid
    dirs_dict = {
        "n": 1,
        "s": -1,
        "e": 1,
        "w": -1
    }

    x = 0
    y = 0

    for dir in walk:
        if dir == 'n' or dir == 's':
            y = y + dirs_dict[dir]
            print(f"y = {y}")
        if dir == 'e' or dir == 'w':
            x = x + dirs_dict[dir]
            print(f"x = {x}")
    if len(walk) == 10:
        print("Walk took exactly 10 mins. Nice")
        # return True
    else:
        print(f"No good - walk took {len(walk)} minutes")
        # return False
    if x == 0 and y == 0:
        print("Returned home safely")
    else:
        print("didn't end up at home")

def submitted(walk):
    dirs_dict = {
        "n": 1,
        "s": -1,
        "e": 1,
        "w": -1
    }

    x = 0
    y = 0

    for dir in walk:
        if dir == 'n' or dir == 's':
            y = y + dirs_dict[dir]
        if dir == 'e' or dir == 'w':
            x = x + dirs_dict[dir]
    if len(walk) == 10 and x == 0 and y == 0:
        return True
    else:
        return False

def best_solution(walk):
    return len(walk) == 10 and walk.count('n') == walk.count('s') and walk.count('e') == walk.count('w')

# walk = ['n','s','n','s','n','s','n','s','n','s']
walk = ['w', 'w', 'e', 'w', 'n', 's', 'n', 'n', 'e', 'w']

is_valid_walk(walk)