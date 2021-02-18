import urllib.request

def scrape():
    req = urllib.request.Request('http://en.wikipedia.org/robots.txt')
    with urllib.request.urlopen(req) as response:
        return(response.read())

print(scrape())