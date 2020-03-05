def find_it(seq):
    for i in seq:
        if not (seq.count(i)/2).is_integer():
            return i

def best_solution(seq):
    for i in seq:
        if seq.count(i)%2!=0:
            return i

sequence = [20,1,-1,2,-2,3,3,5,5,1,2,4,20,4,-1,-2,5]

find_it(sequence)