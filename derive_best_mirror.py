#############################################################
#                                                           #
# This script parses stdin and pulls the link to the best   #
# performing server.                                        #
#                                                           #
# *Parsing list can be attained via curl. For example:      #
#   curl -L "https://archlinux.org/mirrors/status/json/" \  #
#        | derive_best_mirror.py -                          # 
#                                                           #
#############################################################
import argparse
import sys
import json


def derive_url(plaintext):
    plaintext = plaintext.strip()
    if not plaintext:
        return None

    mirrorlist = json.loads(plaintext)
    best_score = float("inf")

    for mirror in mirrorlist.get("urls", []):
        tmpscore = mirror.get("score", None)
        if tmpscore is None:
            continue
        try:
            tmpscore = float(tmpscore)
        except (TypeError, ValueError):
            continue
        if tmpscore < best_score:
            best_score = tmpscore
            url = mirror.get("url")
    return url

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", nargs="?", default="-", help='path to JSON file or "-" for stdin (default)')
    args = parser.parse_args()
    plaintext = sys.stdin.read()
    url = derive_url(plaintext)
    print(url)

if __name__ == "__main__":
    main()
