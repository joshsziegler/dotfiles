"""Parses CSV files containing personal health data and save a summary as a file.


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

import csv, os.path, datetime, argparse

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
    runs = list(runs) # FIXME: inefficient
    runs = [Run(r) for r in runs[1:]]
    for run in runs:
        total_miles += run.miles
        if run.total_in_sec and run.miles in records:
            if not records[run.miles] or records[run.miles].total_in_sec > run.total_in_sec:
                records[run.miles] = run


    runs.sort(key=lambda x: x.date, reverse=True)
    last_three_runs = runs[0:7]

    html = "<h3>Running:</h3>"
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


def csv_to_table_as_is(dir, filename):
    """Parse CSV formatted file specified as dir/filename.csv to HTML formatted table as is.

    Expects the first row to be headers, which are capitalized using .title()
    """
    path = os.path.join(dir, filename)
    csvfile = open(path, newline='')
    ex = csv.reader(csvfile, delimiter=",", quoting=csv.QUOTE_NONE)
    rows = list(ex) # FIXME: inefficient
    html_ = "<h3>{}:</h3><table>".format(filename[:-4].replace("_", " ").title())
    html_ += "<tr>{}</tr>".format("".join(["<td><b>{}</b></td>".format(x.title()) for x in rows[0]]))
    for row in rows[1:]:
        html_ += "<tr>"
        for cell in row:
            html_ += "<td>{}</td>".format(cell)
        html_ += "</tr>"
    html_ += "</table><br>"
    return html_


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--health_dir',  type=str, default="C:/home/health_data/")
    args = parser.parse_args()

    today = datetime.date.today()

    html = "<html><head></head><body>"
    html += "<h2>Health Summary for {}</h2>".format(today.isoformat())
    html += "{}<br />".format(parse_runs(args.health_dir))
    for f in ["max_weight_ex.csv", "max_reps_ex.csv", "last_of.csv","body_fat.csv"]:
        html += "{}<hr /><br />".format(csv_to_table_as_is(args.health_dir, f))
    html += "</body></html>"

    summary = os.path.join(args.health_dir, "summary.html")
    open(summary, 'w').write(html)
