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
    ("http://theoatmeal.com/feed/rss", "The Oatmeal"),
    ("http://xkcd.com/rss.xml", "XKCD"),
    ("http://feeds.feedburner.com/thedoghousediaries/feed", "Doghouse Diaries "),
    ("http://www.smbc-comics.com/rss.php", "SMBC"),
    ("http://penny-arcade.com/feed", "Penny Arcade"),
    ("http://penny-arcade.com/feed/podcasts", "Penny Arcade Podcasts"),
    # News, blogs, etc.
    ("http://www.vox.com/authors/matthew-yglesias/rss", "Matt Yglesias"),
    ("http://feeds.feedburner.com/codinghorror", "Coding Horror"),
    ("http://www.python.org/channews.rdf", "Python"),
    ("http://feeds.arstechnica.com/arstechnica/features", "Ars Technica Features"),
    ("http://hwww.damninteresting.com/?feed=rss2", "Damn Interesting"),
    ("http://www.joelonsoftware.com/rss.xml", "Joel On Software"),
    ("http://matt.might.net/articles/feed.rss", "Matt Might"),
    ("http://www.wired.com/threatlevel/feed/", "Wired: Threat Level"),
    ("http://feeds.wired.com/WiredDangerRoom", "Wired: Danger Room"),
    ("http://www.gatesnotes.com/home/rss", "Gates Notes"), # Broken date-time parsing?
    ("http://feeds.propublica.org/propublica/main", "ProPublica"),
    ("http://www.vox.com/rss/index.xml", "Vox"),
    ("http://feeds.feedburner.com/newsyc50", "HN-50"),
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
    parser.add_argument('--past_links',  type=str, default="past_links.txt")
    args = parser.parse_args()

    today = datetime.date.today()
    yesterday = today - datetime.timedelta(days=1)
    yesterday = yesterday.timetuple() # feedparser uses timetuples

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
            plain += "{}:\n".format(feed_title)
            html  += "<b>{}</b>:<br>".format(feed_title)
            for post in posts['entries']:
                title = post['title']
                link  = post['link']
                new   = True

                if link in past_links:
                    continue # skip this old link

                try: 
                    if post['published_parsed'] < yesterday:
                        continue # skip this old link
                except:
                    pass 

                try: # some feeds don't seem to have published as a key
                    if post['updated_parsed'] < yesterday:
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

    html += "</body></html>"
    send_email(args.user, args.password, args.to, "RSS Feeds for {}".format(today.isoformat()), plain, html)

    open(args.past_links, "w+").write('\n'.join(past_links))