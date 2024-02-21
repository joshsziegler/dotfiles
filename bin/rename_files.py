# coding: utf-8

import argparse
import os
import re
import shutil


def rename_files_in_dir(directory, live_run=False):
    if not live_run:
        print("Performing dry run...")
        
    files = [f for f in os.listdir(directory) if os.path.isfile(f)]

    for old_path in files:
        new_path = re.sub('[^0-9a-zA-Z-\.,_]', '_', old_path)
        new_path = re.sub('_+', '_', new_path)
        new_path = re.sub('_-_', '-', new_path)
        new_path = re.sub('(^_|_$|\.$)', '', new_path)
        if live_run:
            shutil.move(old_path, new_path)
        else:
            print("{} -> {}".format(old_path, new_path))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=str, help="which directory's files to rename")
    parser.add_argument('-l', '--live_run', default=False, action='store_true', help="If not given, perform a dry run by showing what would be renamed.")
    args = parser.parse_args()

    rename_files_in_dir(args.directory, args.live_run)
