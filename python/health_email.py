"""Parses CSV files containing personal health data and send it a summary via email.


Data includes latest runs, PRs on runs and lifts, weight, and so on.

All date formats are YYYYMMDD

runs.csv format:
date,miles,hours,minutes,seconds



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

import csv, os.path, datetime, smtplib, argparse, email.message
from collections import OrderedDict

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

def n2es(x):
    """None/Null to Empty String
    """
    if not x:
        return ""
    return x

def nullOrInt(x):
    if len(x) == 0:
        return None
    else:
        return int(x)

def date_format(d):
    """Takes numerical date without formatting (20141225) and formats it (2014.12.25)
    """
    if not d:
        return ""
    t = str(d)
    return "{}.{}.{}".format(t[0:4], t[4:6], t[6:8])

class Run(object):
    def __init__(self, x):
        self.date = int(x[0])
        self.miles = float(x[1])
        self.hours = nullOrInt(x[2])
        self.minutes = nullOrInt(x[3])
        self.seconds = nullOrInt(x[4])
        self.total_in_sec = None
        if self.hours is not None and self.minutes is not None and self.seconds is not None:
            self.total_in_sec = self.hours*60*60+self.minutes*60+self.seconds

    def pace(self):
        if not self.total_in_sec:
            return ""
        pace_min = int((self.total_in_sec/60)//self.miles)
        pace_sec = int(((self.total_in_sec/60)%self.miles)/self.miles*60)
        return "{}:{:0>2d}".format(pace_min, pace_sec)

def parse_runs(dir):
    """Parse runs.csv in the given directory (dir)

    Returns HTML formatted summary of that file, including current records and
    recent runs.
    """
    path = os.path.join(dir, "runs.csv")
    total_miles = 0.0
    records = {1:None, 2:None, 3: None, 4:None, 5:None, 6:None, 7:None, 8:None, 9:None, 10:None, 13.1:None}
    last_three_runs = []
    csvfile = open(path, newline='')
    runs = csv.reader(csvfile, delimiter=",", quoting=csv.QUOTE_NONE)
    runs = [Run(r) for r in runs]
    for run in runs:
        total_miles += run.miles
        if run.total_in_sec and run.miles in records:
            if not records[run.miles] or records[run.miles].total_in_sec > run.total_in_sec:
                records[run.miles] = run


    runs.sort(key=lambda x: x.date, reverse=True)
    last_three_runs = runs[0:7]

    html = "<b>Running:</b><hr>"
    html +=  "<b>All Time Mileage:</b> {}<br><br>".format(total_miles)
    html += "<table><tr><td><b>Recent Runs</b></td><td><b>Miles</b></td><td><b>H</b></td><td><b>M</b></td><td><b>S</b></td><td><b>Pace</b></td></tr>"
    for run in last_three_runs:
        html += "<tr><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td></tr>".format(date_format(run.date), run.miles, n2es(run.hours), n2es(run.minutes), n2es(run.seconds), run.pace())
    html += "</table><br>"

    html += "&nbsp;&nbsp;&nbsp;&nbsp;<table><tr><td><b>Record</b></td><td><b>Date</b></td><td><b>H</b></td><td><b>M</b></td><td><b>S</b></td><td><b>Pace</b></td></tr>"
    for dist in records:
        run = records[dist]
        if run:
            html += "<tr><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td></tr>".format(run.miles, date_format(run.date), n2es(run.hours), n2es(run.minutes), n2es(run.seconds), run.pace())
    html += "</table><br>"

    return html


def parse_max_weight_ex(dir):
    """Parse max_weight_ex.csv in the given directory (dir)

    Returns HTML formatted summary of that file, including current records.
    """
    path = os.path.join(dir, "max_weight_ex.csv")
    csvfile = open(path, newline='')
    ex = csv.reader(csvfile, delimiter=",", quoting=csv.QUOTE_NONE)
    ex = list(ex)
    html = "<b>Max Weight Records:</b><hr>"
    html += "<table><tr><td><b>Exercise</b></td><td><b>1 RM</b></td><td><b>Date</b></td><td><b>2 RM</b></td><td><b>Date</b></td><td><b>3 RM</b></td><td><b>Date</b></td></tr>"
    for e in ex:
        html += "<tr><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td></tr>".format(e[0], e[1], date_format(e[2]), e[3], date_format(e[4]), e[5], date_format(e[6]))
    html += "</table><br>"
    return html


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('user',        type=str)
    parser.add_argument('password',    type=str)
    parser.add_argument('to',          type=str)
    parser.add_argument('--health_dir',  type=str, default="C:/home/health/")
    args = parser.parse_args()

    today = datetime.date.today()

    html = "<html><head></head><body>"
    html += "{}<br />".format(parse_runs(args.health_dir))
    html += "{}<br />".format(parse_max_weight_ex(args.health_dir))
    html += "</body></html>"


    send_email(args.user, args.password, args.to, "Health Summary for {}".format(today.isoformat()), "HTML Failed to Load", html)
