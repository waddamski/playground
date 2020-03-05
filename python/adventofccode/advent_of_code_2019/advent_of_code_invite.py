import sys
# from string import maketrans

def withmaketrans():
    # with open(sys.argv[1], 'r') as text_file:
    intxt = "abcdefghijklmnopqrstuvwxyz"
    outtxt = "hijklmnopqrstuvwxyzabcdefg"
    trantab = maketrans(intxt, outtxt)

    # str = "http://www.pythonchallenge.com/pc/def/map.html"
    # str = "g fmnc wms bgblr rpylqjyrc gr zw fylb. rfyrq ufyr amknsrcpq ypc dmp. bmgle gr gl zw fylb gq glcddgagclr ylb rfyr'q ufw rfgq rcvr gq qm jmle. sqgle qrpgle.kyicrpylq() gq pcamkkclbcb. lmu ynnjw ml rfc spj."
    # str = "Bm’l gxtker matm mbfx hy rxtk tztbg - Twoxgm hy Vhwx! Tgw mabl rxtk UCLL bl max hyybvbte lihglhk hy mabl
    # hgebgx yxlmbox vhwbgz vhgmxlm pabva hyyxkl wtber lahkm, lxey-vhgmtbgxw ehzbv tgw ikhzktffbgz inssexl. Bm'l hixg mh
    # tee UCLLxkl tgw bl wxlbzgxw mh vateexgzx wbyyxkxgm ikhzktffbgz ldbeel yhk tee ldbee-exoxel - ykhf tulhenmx vhwbgz
    # ghobvxl mh lxtlhgxw xqixkml. Max vhgmxlm dbvdl hyy hg 1lm Wxvxfuxk. Oblbm twoxgmhyvhwx.vhf yhk fhkx bgyh, hk chbg
    # max #twoxgm-hy-vhwx-2019 Letvd vatggxe yhk niwtmxl, abgml tgw mbil ykhf yxeehp UCLLxkl."
    print(str.translate(trantab))


def replace_loop():
    out_list = []
    trans_dict = {"a": "h",
                  "b": "i",
                  "c": "j",
                  "d": "k",
                  "e": "l",
                  "f": "m",
                  "g": "n",
                  "h": "o",
                  "i": "p",
                  "j": "q",
                  "k": "r",
                  "l": "s",
                  "m": "t",
                  "n": "u",
                  "o": "v",
                  "p": "w",
                  "q": "x",
                  "r": "y",
                  "s": "z",
                  "t": "a",
                  "u": "b",
                  "v": "c",
                  "w": "d",
                  "x": "e",
                  "y": "f",
                  "z": "g"
                  }

    text = "Bm’l gxtker matm mbfx hy rxtk tztbg - Twoxgm hy Vhwx! Tgw mabl rxtk UCLL bl max hyybvbte lihglhk hy mabl hgebgx yxlmbox vhwbgz vhgmxlm pabva hyyxkl wtber lahkm, lxey-vhgmtbgxw ehzbv tgw ikhzktffbgz inssexl. Bm'l hixg mh tee UCLLxkl tgw bl wxlbzgxw mh vateexgzx wbyyxkxgm ikhzktffbgz ldbeel yhk tee ldbee-exoxel - ykhf tulhenmx vhwbgz ghobvxl mh lxtlhgxw xqixkml. Max vhgmxlm dbvdl hyy hg 1lm Wxvxfuxk. Oblbm twoxgmhyvhwx.vhf yhk fhkx bgyh, hk chbg max #twoxgm-hy-vhwx-2019 Letvd vatggxe yhk niwtmxl, abgml tgw mbil ykhf yxeehp UCLLxkl."
    in_text = text.lower()
    for t in in_text:
        if t in trans_dict:
            out_list.append(trans_dict[t])
        else:
            out_list.append(t)
    out_text = ''.join(str(e) for e in out_list)
    print(out_text)
    
replace_loop()