def mysolution(mystring):
    mylist = []
    str1 = " "
    for mystr in mystring.split():
        mylist.append(mystr.capitalize())
    return(str1.join(mylist))


def best_solution(mystring):
    return " ".join(w.capitalize() for w in mystring.split())


def main():
    string = "How can mirrors be real if our eyes aren't real"
    res = best_solution(string)
    print(res)
    # print(mysolution(string))


main()