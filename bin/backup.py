"""Simple, same-site backup via Zip.

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

import shutil, os, datetime, logging, argparse
_log = logging.getLogger(__name__) # get module-level logger

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--src_path',    type=str, default="D:/home/")
    parser.add_argument('--dst_path',    type=str, default="D:/")
    parser.add_argument('--name_prefix', type=str, default="josh_pc_")
    parser.add_argument('-d', '--delete_old',  action='store_true')
    parser.add_argument('-t', '--append_time', action='store_true')
    args = parser.parse_args()

    # Don't edit below here
    now = datetime.datetime.now()
    date_format = "%Y_%m_%d"
    if args.append_time:
        date_format += "-%H_%M_%S"

    archive_name = args.name_prefix + now.strftime(date_format)
    dst_new = os.path.join(args.dst_path,  archive_name)
    format = '%(levelname)s:%(filename)s:%(lineno)s:%(funcName)s:  %(message)s'
    logging.basicConfig(format=format, level=logging.INFO)

    if args.delete_old:
        # find old backups with the same name_prefix
        old_backups = [ f for f in os.listdir(args.dst_path) if os.path.isfile(os.path.join(args.dst_path,f)) and args.name_prefix in f ]
        # delete the old backups
        for path in old_backups:
            tmp = os.path.join(args.dst_path, path)
            _log.info("Deleting old backups: {}".format(tmp))
            os.remove(tmp)

    # create the new backup
    _log.info("Creating new backup: {}".format(dst_new))
    shutil.make_archive(dst_new, "zip", args.src_path, args.src_path)
