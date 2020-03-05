import sys
from string import maketrans

def withloop():
    with open(sys.argv[1], 'r') as text_file:
        translate = []
        for line in text_file:
            for ch in line:
                if (ch>='a' and ch<='x'):
                    translate.append(chr(ord(ch) + 2))
                elif (ch>='y' and ch<='z'):
                    translate.append(chr(ord(ch) -24))
                else:
                    translate.append(ch)

    mainstr = ''.join(translate)
    string1 = mainstr.replace(',', '')
    string2 = string1.replace('"', '')

    print(string2)


def withmaketrans():
    # with open(sys.argv[1], 'r') as text_file:
    intxt = "abcdefghijklmnopqrstuvwxyz"
    outtxt = "cdefghijklmnopqrstuvwxyzab"
    trantab = maketrans(intxt, outtxt)

    str = "http://www.pythonchallenge.com/pc/def/map.html"
    # str = "g fmnc wms bgblr rpylqjyrc gr zw fylb. rfyrq ufyr amknsrcpq ypc dmp. bmgle gr gl zw fylb gq glcddgagclr ylb rfyr'q ufw rfgq rcvr gq qm jmle. sqgle qrpgle.kyicrpylq() gq pcamkkclbcb. lmu ynnjw ml rfc spj."
    print(str.translate(trantab))

withmaketrans()