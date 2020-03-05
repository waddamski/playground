def alphabet_position(mystr):
    mylist = []
    mynewstr = " "
    for char in mystr:
        if char.isalpha():
            mylist.append(alphpos[char.lower()])
        else:
            pass

    return(mynewstr.join(mylist))

mystring = "The sunset sets at twelve o' clock."

alphpos = {
    "a": "1",
    "b": "2",
    "c": "3",
    "d": "4",
    "e": "5",
    "f": "6",
    "g": "7",
    "h": "8",
    "i": "9",
    "j": "10",
    "k": "11",
    "l": "12",
    "m": "13",
    "n": "14",
    "o": "15",
    "p": "16",
    "q": "17",
    "r": "18",
    "s": "19",
    "t": "20",
    "u": "21",
    "v": "22",
    "w": "23",
    "x": "24",
    "y": "25",
    "z": "26"
}

alphabet_position(mystring)

def best_solution():
    return ' '.join(str(ord(c) - 96) for c in text.lower() if c.isalpha())