def countBits(n):
    bin_n = (bin(n)[2:])
    int_list = list(map(int, str(bin_n)))
    return (sum(int_list))

# n = 1234
n = 10
countBits(n)

def bestsolution(n):
    return bin(n).count("1")