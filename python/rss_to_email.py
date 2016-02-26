#! /usr/bin/python

"""Parses RSS/Atom feeds and sends them in an email.


The MIT License (MIT)

Copyright (c) 2014 Joshua S. Ziegler 

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

import datetime, traceback, smtplib, argparse, email.message
import feedparser

feeds = [ # These will be printed in-order, so put important stuff first
    # Comics
    ("http://penny-arcade.com/feed", "Penny Arcade"),
    ("http://feeds.feedburner.com/thedoghousediaries/feed", "Doghouse Diaries "),
    ("http://www.smbc-comics.com/rss.php", "SMBC"),
    ("http://theoatmeal.com/feed/rss", "The Oatmeal"),
    ("http://xkcd.com/rss.xml", "XKCD"),
    # News, blogs, etc.
    ("http://www.vox.com/authors/matthew-yglesias/rss", "Vox: Matt Yglesias"),
    ("http://feeds.arstechnica.com/arstechnica/features", "Ars Technica"),
    ("http://www.wired.com/threatlevel/feed/", "Wired: Threat Level"),
    ("http://feeds.wired.com/WiredDangerRoom", "Wired: Danger Room"),
    ("http://www.vox.com/rss/index.xml", "Vox"),
    ("https://news.ycombinator.com/rss", "Hacker News")
]

plain_links = [ # Simply put as-is in the email 
    #("http://hckrnews.com/", "Hckr News")
]


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

    today = datetime.date.today()
    x_days_ago = today - datetime.timedelta(days=args.days)
    x_days_ago = x_days_ago.timetuple() # feedparser uses timetuples

    past_links = []
    try:
        past_links = open(args.past_links, "r+").read().split('\n') 
    except:
        pass # no file found

    plain = ""
    html = "<html><head></head><body>"
    for feed, feed_title in feeds:
        try:
            posts = feedparser.parse(feed)
            if len(posts['entries']) < 1: # skip feeds without any stories
                continue

            plain += "{}:\n".format(feed_title)
            html  += "<b><a href=\"{}\" style=\"text-decoration: none;color: black;\">{}</a></b>:<br>".format(feed, feed_title)
            for post in posts['entries']:
                title = post['title']
                link  = post['link']
                new   = True

                if link in past_links:
                    continue # skip this old link

                try: 
                    if post['published_parsed'] < x_days_ago:
                        continue # skip this old link
                except:
                    pass 

                try: # some feeds don't seem to have published as a key
                    if post['updated_parsed'] < x_days_ago:
                        continue # skip this old link
                except:
                    pass 

                # include it by default if not in past_link file or published date
                past_links.append(link)
                plain += "    {} {}\n".format(title, link)
                html  += "&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"{}\" style=\"text-decoration: none;color: #444;\">{}</a><br>".format(link, title)

        except:
            err = "Choked on {}\n{}\n\n".format(feed, traceback.format_exc())
            plain += err
            html  += err

    plain += "\n"
    html += "<br>"

    for link, pretty_name in plain_links:
        plain += "{} {}\n".format(title, link)
        html  += "<a href=\"{}\" style=\"text-decoration: none;color: #444;\">{}</a><br>".format(link, pretty_name)

    html += "</body></html>"
    send_email(args.user, args.password, args.to, "RSS Feeds for {}".format(today.isoformat()), plain, html)

    open(args.past_links, "w+").write('\n'.join(past_links))
