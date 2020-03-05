song = "WUBWEWUBAREWUBWUBTHEWUBCHAMPIONSWUBMYWUBFRIENDWUB"
def song_decoder(song):
    mystr = " ".join(song.split("WUB", -1))
    return(" ".join(mystr.split()))

print(song_decoder(song))


def best_solution(song):
    return " ".join(song.replace('WUB', ' ').split())
