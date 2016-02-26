#! /usr/bin/python

"""Updates a dynamic DNS record with Google Domains API.

Requires Python 3.x and requests


The MIT License (MIT)

Copyright (c) 2016 Joshua S. Ziegler 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

import argparse
import requests  


def update_dyn_dns(username, password, domain, prev_ip=None):
    new_ip = None

    f = requests.get('https://api.ipify.org?format=text')
    if f.status_code != requests.codes.ok:
        print("Failed to retrieve external IP. Server returned {}: {}".format(f.status_code, f.reason))
        return None
    new_ip = f.text

    if not new_ip:
        print("Failed to retrieve external IP: {}".format(new_ip))
        return None

    if new_ip == prev_ip: 
        print("IP has not changed. Update complete.")
        return None

    url = "https://domains.google.com/nic/update?hostname={}&myip={}".format(domain, new_ip)
    print("Updating IP address for {} to {}".format(domain, new_ip))
    print("GET {}".format(url))

    f = requests.get(url, auth=(username, password))
    if f.status_code != requests.codes.ok:
        print("Failed to update dynamic IP. Server returned {}: {}".format(f.status_code, f.reason))
        return
    print("Response: {}".format(f.text))

    return new_ip

if __name__ == "__main__":
    username = None
    password = None
    domain   = None
    prev_ip  = None 

    try: # pull in arguments from config.py 
        from config import google_dyn_dns
        username = google_dyn_dns["username"]
        password = google_dyn_dns["password"]
        domain   = google_dyn_dns["domain"]

    except: # failed to import config.py -- try command line arguments
        parser = argparse.ArgumentParser()
        parser.add_argument('username', type=str)
        parser.add_argument('password', type=str) 
        parser.add_argument('domain',   type=str) 
        args = parser.parse_args()
        username = args.username
        password = args.password
        domain   = args.domain

    try:
        with open("previous_ip", "r") as f:
            prev_ip = f.read() 
    except:
        print("Failed to find our previous IP from file.")
    
    new_ip = update_dyn_dns(username, password, domain, prev_ip)

    if new_ip:
        print("Saving new IP to file.")
        with open("previous_ip", "w") as f:
            f.write(new_ip)

