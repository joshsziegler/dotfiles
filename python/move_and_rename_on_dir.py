"""
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
import os
import shutil

def move_and_rename(src_dir, dest_dir):
    """Recursively walks a directory returns a list of paths of all files.
    """
    results = []
    for r,d,f in os.walk(src_dir):
        for files in f:
            src = os.path.join(r, files)
            dest = r.replace(".\\","").replace(".","").replace("\\", " - ").replace(",", " - ") 
            if dest: 
                dest += " - " + files.replace(",", " - ")
            else:
                dest = files.replace(",", " - ")
            #print(r, files, dest)
            print(src, "  ->  ", os.path.join(dest_dir, dest))
            shutil.move(src, dest) 

if __name__ == "__main__":
    dest_dir = os.path.join("..","dest")
    print("Moving renamed file to ", dest_dir)
    move_and_rename(".", dest_dir)
