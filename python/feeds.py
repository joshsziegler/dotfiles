#! /usr/bin/python

"""Parses RSS/Atom feeds and returns them as HTML.


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

import sys, datetime, traceback, argparse
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


def get_feeds(days, past_links_path):
    today = datetime.date.today()
    x_days_ago = today - datetime.timedelta(days=days)
    x_days_ago = x_days_ago.timetuple() # feedparser uses timetuples

    past_links = []
    try:
        past_links = open(past_links_path, "r+").read().split('\n') 
    except:
        pass # no file found

    news_title = "RSS Feeds for {}".format(today.isoformat())
    plain = "{}\n".format(news_title)
    html =  "<h1>{}</h1>".format(news_title)
    for feed, feed_title in feeds:
        try:
            posts = feedparser.parse(feed)
            if len(posts['entries']) < 1: # skip feeds without any stories
                continue

            plain += "{}:\n".format(feed_title)
            html  += "<h3>{}</h3>".format(feed_title)
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
                html  += "&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"http://www.readability.com/read?url={}\">{}</a><br>".format(link, title)

        except:
            err = "Choked on {}\n{}\n\n".format(feed, traceback.format_exc())
            plain += err
            html  += err

    plain += "\n"
    html += "<br>"

    for link, pretty_name in plain_links:
        plain += "{} {}\n".format(pretty_name, link)
        html  += "<a href=\"{}\">{}</a><br>".format(link, pretty_name)

    open(past_links_path, "w+").write('\n'.join(past_links))

    return (news_title, plain, html)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--html', action='store_true')
    parser.add_argument('--past_links', type=str, default="past_links.txt")
    parser.add_argument('--days',       type=int, default=1)
    parser.add_argument('-t', '--templates_path', type=str, default="/home/josh/zglr_org/templates.py")
    args = parser.parse_args()


    title, plain, html = get_feeds(args.days, args.past_links)
    html = "<html><body>{}</body></html>".format(html)
    if args.html:
        # Import the templates module for 'base'
        if sys.version_info >= (3, 5):
            import importlib.util
            spec = importlib.util.spec_from_file_location("templates", args.templates_path)
            templates = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(templates)
        elif sys.version_info >= (3, 3):
            from importlib.machinery import SourceFileLoader
            templates = SourceFileLoader("templates", args.templates_path).load_module()
        else:
            print("Failed to import templates for 'base'")
            sys.exit()

        html = templates.base(title, html)
        html = html.encode('ascii', 'ignore')
        print(html)
    else:
        print(plain.encode('ascii', 'ignore'))