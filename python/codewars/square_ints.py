
num = 9119
def first_go(num):
    mylist = list(map(int, str(num)))
    mystr = [str(i**2) for i in mylist]
    myint = int("".join(mystr))
    return myint

# print(first_go(num))

def best_solution(num):
    ret = ""
    for x in str(num):
        ret += str(int(x) ** 2)
    return int(ret)

print(best_solution(num))