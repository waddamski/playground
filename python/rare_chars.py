import sys

def parse_chars():
    with open(sys.argv[1], 'r') as text_file:
        char_array = []
        for line in text_file:
            for ch in line:
                if (ch>='a' and ch<='z'):
                    char_array.append(ch)

    print(char_array)


parse_chars()