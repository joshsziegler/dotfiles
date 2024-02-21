"""
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


import os
import re
from hashlib import md5
import json
# from dhash import dhash

class FindDupes(object):
    def __init__(self, home, dir_list=None, delete_dupes=False, use_dhash=False):
        self.home = home
        if delete_dupes:
            print("This will delete duplicates!")
            temp = input("Enter \"YES\" to continues: ")
            if temp != "YES":
                raise Exception("User did enter YES to confirm dupe deletion.")
        self.delete_dupes = delete_dupes
        self.use_dhash = use_dhash
        self.file_blacklist = [] # list of regex objects
        self.dir_blacklist  = [] # list of regex objects
        if dir_list:
            self.dir_list = dir_list
        else:
            # Search all directorys in the home directory
            self.dir_list = [ name for name in os.listdir(home) if os.path.isdir(os.path.join(home, name)) ]

        self.hash_to_path = {} # hash: list of paths on local disk

    def path(self, directory):
        return os.path.abspath(os.path.join(self.home, directory))

    def blacklist_file(self, pattern):
        regex = re.compile(pattern)
        self.file_blacklist.append(regex)

    def blacklist_dir(self, pattern):
        regex = re.compile(pattern)
        self.dir_blacklist.append(regex)

    def blacklisted_file(self, file_name):
        for regex in self.file_blacklist:
            if regex.search(file_name):
                return True
        return False

    def blacklisted_dir(self, file_name):
        for regex in self.dir_blacklist:
            if regex.search(file_name):
                return True
        return False

    def search_dir(self, directory):
        for filename in os.listdir(directory):
            path = os.path.join(directory, filename)
            path = os.path.abspath(path) # Normalize the path

            if os.path.islink(path):
                continue # skip links
            elif os.path.isdir(path):
                if self.blacklisted_dir(path):
                    #print "Skipping dir:", root
                    continue # skip this directory

                self.search_dir(path)
            else:
                if self.blacklisted_file(path):
                    #print "Skipping file:", file_path
                    continue # skip this file

                try:
                    binary_str = open(path, 'rb').read()
                except IOError as e:
                    print("Failed to open", path)
                    print(e)

                if self.use_dhash:
                    file_hash = dhash(path)
                else:
                    file_hash = md5(binary_str).hexdigest()

                if file_hash not in self.hash_to_path:
                    self.hash_to_path[file_hash] = [path]
                else:
                    if path not in self.hash_to_path[file_hash]:
                        # This is a duplicate
                        self.hash_to_path[file_hash].append(path)
                        if self.delete_dupes:
                            print("Deleting duplicate: {}".format(path))
                            os.remove(path)

        self.filter_duplicates()


    def search_for_dupes(self):
        for directory in self.dir_list:
            self.search_dir(self.path(directory))

    def save(self):
        s = open("dupes.txt", 'w')
        for f_hash in self.hash_to_path.keys():
            s.write(f_hash + ":\n")
            for path in self.hash_to_path[f_hash]:
                s.write("\t" + path + "\n")
        s.close()

    def filter_duplicates(self):
        to_remove = []
        for f_hash in self.hash_to_path:
            if len(self.hash_to_path[f_hash]) < 2:
                to_remove.append(f_hash)
        for f_hash in to_remove:
            del self.hash_to_path[f_hash]

    def add_dir(self, directory):
        if directory not in self.dir_list:
            self.dir_list.append(directory)

if __name__ == "__main__":
    #search_dirs = ["documents", "Google Drive", "Pictures"]
    #zb = FindDupes("/", search_dirs)
    zb = FindDupes("/cygdrive/c/home/", delete_dupes=False)
    zb.blacklist_dir("\.\w*?$") # all hidden directories
    zb.blacklist_file("^\.") # all hidden files (starting with a dot)
    zb.blacklist_file("^.*?\.swp") # all files ending with '.swp'
    zb.blacklist_file("^.*?.txt")
    zb.blacklist_file("^venv") # all Python Virtual environments
    zb.search_for_dupes()
    zb.save()
