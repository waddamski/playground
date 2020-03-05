a = 'toast'
b = 'bread'
c = 'z'
mylist = [a, b, c]
blah = ['w', 'a', 'z', 'z', 'u', 'p', 'toast']

for thing in mylist:
    if thing != 'toast' or thing in blah:
        print("Thing is true", thing)
