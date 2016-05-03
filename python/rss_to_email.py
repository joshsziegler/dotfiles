#! /usr/bin/python

"""Parses RSS/Atom feeds and sends them in an email.


The MIT License (MIT)

Copyright (c) 2014-2016 Joshua S. Ziegler 

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

import smtplib, argparse, email.message


def send_email(gmail_user, gmail_pwd, to, subject, text, html):
    """Taken as-is from StackOverflow answer: http://stackoverflow.com/a/12424439
    """
    msg = email.message.EmailMessage()
    msg['Subject'] = subject
    msg['From'] = gmail_user
    msg['To'] = to 
    msg.set_content(text) # Plain text version
    msg.add_alternative(html, subtype="html") # HTML version

    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.ehlo()
    server.starttls()
    server.login(gmail_user, gmail_pwd)
    server.send_message(msg)
    server.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('user',        type=str)
    parser.add_argument('password',    type=str) 
    parser.add_argument('to',          type=str) 
    parser.add_argument('--past_links',type=str, default="past_links.txt")
    parser.add_argument('--days',      type=int, default=1)
    args = parser.parse_args()

    title, plain, html = get_feeds(args.days, args.past_links)
    html = "<html><body>{}</body></html>".format(html)

    send_email(args.user, args.password, args.to, title plain, html)
