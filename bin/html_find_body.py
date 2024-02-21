#!/usr/bin/env python

from bs4 import BeautifulSoup
import urllib.request
import argparse


def find_element_with_most_paragraphs(url):
    html = urllib.request.urlopen(url).read()
    soup = BeautifulSoup(html, "html.parser")
    parents = soup.find_all(['div', 'article', 'body'])

    most_paras = ""
    most_paras_num = 0

    for el in parents:
        num_paras = len(el.find_all('p', recursive=False))
        if num_paras > most_paras_num:
            most_paras = el
            most_paras_num = num_paras

    return most_paras

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('url',  type=str)
    args = parser.parse_args()

    print(find_element_with_most_paragraphs(args.url))
