"""Calculates accumulated time of last [TAG] in WebVTT files.

Will also show time between a [START] and [COMPLETE] set of tags, without affecting the other tag time calculations.

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

import sys, re, argparse
from datetime import datetime


time_fmt = '%H:%M:%S.%f'
cue_re = re.compile(r'(?P<start>\d\d\:\d\d\:\d\d[.,]\d\d\d)\s*?-->\s*?(?P<end>\d\d\:\d\d\:\d\d[.,]\d\d\d)\n(?P<cue>.*?)\n\n', re.DOTALL)
tag_re = re.compile(r'\[(?P<tag>\w*?)\]') 


def fix_end_of_file(file_as_str):
    """My regex for WebVTT cues will not find the very last cue if it isn't followed by two line returns.
    This is a quick and dirty fix for that :)
    """
    return file_as_str + "\n\n"

def calc_vtt_tag_times(args):
    # Dictionary of tag -> time elapsed while *under* that tag
    tags = {}
    for t in args.tags:
        tags[t] = datetime.strptime('00:00:00.0', time_fmt)

    ignored_tags = set() # set of all ignored tags
    timer_results = [] # list of timer results

    ###  State variables (stores current/last tag and timer data)
    timer_start = None
    last_tag = None
    last_tag_start = None
    # This is just curr_time, but we need to keep a reference to the LAST curr_time so we can finish calculate the last tags' time
    last_time = None 

    vtt_file = open(args.webvtt_file, 'r').read() 
    vtt_file = fix_end_of_file(vtt_file)

    cue_matches = cue_re.finditer(vtt_file)
    for cm in cue_matches:
        curr_time = datetime.strptime(cm.group('start'), time_fmt)
        last_time = curr_time

        tag_matches = tag_re.finditer(cm.group('cue'))
        for tm in tag_matches:
            curr_tag = tm.group('tag')
            if curr_tag == "START":
                if timer_start != None:
                    print("ERROR: Found timer START tag, before the last one was closed (COMPLETE tag).")
                    sys.exit()
                timer_start = curr_time
                continue
            elif curr_tag == "COMPLETE":
                if timer_start == None:
                    print("ERROR: Found timer END tag before a START tag.")
                    sys.exit()
                # Print the resulting time span and reset the timers
                timer_results.append("TIMER: {} --> {} (TOTAL: {})".format(timer_start.strftime(time_fmt), 
                    curr_time.strftime(time_fmt), (curr_time-timer_start)))
                timer_start = None
                continue

            if curr_tag not in tags: 
                ignored_tags.add(curr_tag)
                continue

            if last_tag_start == None:
                # We must be at the very beginning, so start a new timer for this tag
                last_tag = curr_tag
                last_tag_start = curr_time
            else:
                tags[last_tag] += (curr_time - last_tag_start)
                last_tag = curr_tag
                last_tag_start = curr_time

    # We need to calculate the last tags elapsed time, because this normally only happens when we run into the next 
    # tag (which there is none)
    if last_tag_start:
        tags[last_tag] += (last_time - last_tag_start)

    # Print the results
    for k in args.tags:
        print("Time for {:>6}: {}".format(k, tags[k].strftime(time_fmt)))
    print("")
    for r in timer_results:
        print(r)
    print("")
    print("Ignored Tags: ", ignored_tags)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('webvtt_file', type=str)
    parser.add_argument('--timer_start_tag', type=str, default='START')
    parser.add_argument('--timer_end_tag',   type=str, default='END')
    parser.add_argument('--tags', nargs='*', 
        default=["UNITY", "CODE", "JSON", "INST", "DOCS", "STATE", "TREE", "DEBUG"], 
        help="list of tags other than START/END to keep track of")
    args = parser.parse_args()

    calc_vtt_tag_times(args)
    