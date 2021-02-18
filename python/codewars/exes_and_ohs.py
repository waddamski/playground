def xo(mystr):
    oh = 0
    ex = 0
    for p in mystr:
        # print(p.lower())
        if p.lower() == 'o':
            oh += 1
            # print("OH = ", oh)
        elif p.lower() == 'x':
            ex += 1
            # print("EX = ", ex)
    print("EX = ", ex)
    print("OH = ", oh)
    if oh == ex:
        return True
    else:
        return False

def bestsolution(mystring):
    s = s.lower()
    return s.count('x') == s.count('o')

mystring = 'XXxxooooosssudosioioxx13FoOOxxxxx'

print(bool(xo(mystring)))