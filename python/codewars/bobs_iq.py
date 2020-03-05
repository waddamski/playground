def iq_test(numbers):
    mylist = [int(num) for num in numbers.split()]
    convlist = [(i % 2) for i in mylist]
    if convlist.count(0) == 1:
        print(convlist.index(0) + 1)
        return (convlist.index(0) + 1)
    else:
        print(convlist.index(1) + 1)
        return (convlist.index(1) + 1)


def best_solution(numbers):
    e = [int(i) % 2 == 0 for i in numbers.split()]

    return e.index(True) + 1 if e.count(True) == 1 else e.index(False) + 1


numbers = "7 5 3 2 1"
iq_test(numbers)