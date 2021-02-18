def anagrams(word, words):
    worddict = {}
    agrams = []
    for w in list(word):
        worddict[w] = word.count(w)
    for wo in words:
        match = 0
        for l in list(wo):
            if (l in worddict) and (wo.count(l) == worddict[l]):
                match = 1
            else:
                match = 0
                break
        if match == 1:
            agrams.append(wo)
    return agrams

#word = 'racer'
#words = ['crazer', 'carer', 'racar', 'caers', 'racer']

word = 'abba'
words = ['aabb', 'abcd', 'bbaa', 'dada']

anagrams(word, words)

def bestsolution(word, words): return [item for item in words if sorted(item) == sorted(word)]

Alternative:
from collections import Counter

def alternative(word, words):
    counts = Counter(word)
    return [w for w in words if Counter(w) == counts]