"""Simple, naive GCA4 to JSON converter. 

Modify the below user variables to your liking and then run _from_ the directory
with your GCA files.  



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
import sys 
import re
import json
import string

###
# Begin user variables
###

pretty_print_json = True # takes up more room, but easier to read
use_skip_sections_list = True
use_skip_keys_list = True

def get_path_to_pdf_version(filename):
    return "pdf/" + filename + ".pdf"

### Known Section names:
# System, Author, General, ShieldArcs, Body, Setuings, Stats,
# Advantages, Disadvantages, Quirks, Skills, Spells, Equipment,
# Descriptions, Notes, Bonuses, Conditionals, BasicDamageList,
# DamageBreaks, SkillTypes ChangeLog, Packages
###

# use all lowercase!
skip_sections = ["system",
                 "author",
                 "campaign", 
                 "groups", 
                 "logentry", 
                 "skilltypes", 
                 "changelog", 
                 "cats", 
                 "basicdamagelist", 
                 "damagebreaks", 
                 "bonuses", # TODO, relies on ownerid
                 "conditionals",  # TODO, relies on ownerid 
                 "packages"]


skip_keys = ["idkey",
             "needscheck",
             "cat",
             "hide",
             "group",
             "maxscore",
             "minscore",
             "posx",
             "posy",
             "step",
             "up",
             "down",
             "disadat",
             "basescore",
             "syslevels",
             "round",
             "mainwin",
             "premodspoints",
             "basepoints",
             "parentkey",
             "display"]

###
## End of User Variables 
###

def contains_special_chars(val):
    for c in val:
        if c in ["*", "(", ")", "+"]:
            return True
    else:
        return False

def is_number(obj):
    """Returns if this object can be represented as a float.
    """
    try:
        float(obj)
        return True
    except ValueError:
        return False

def is_int(obj):
    """Returns True if this object can be represented as an integer and does
    not contain a decimal point.
    """
    try:
        int(obj) # Truncates decimal portions of float...
        if '.' in str(obj):
            return False
        return True
    except ValueError:
        return False

def get_pc_name(head, filename):
    char_file = open(os.path.join(head, filename), 'r').read()

    match = re.search("charname\((.*?)\)", char_file)
    if match:
        char_name = match.group(1).replace(" ", "_").replace("(","")
    else:
        char_name = file_name.replace(" ", "_")
    return char_name

def save_json(directory, characters, pretty_print=False):
    if pretty_print:
        json_dump = json.dumps(characters, indent=4)
    else:
        json_dump = json.dumps(characters)

    open(os.path.join(directory, "characters.json"), 'w').write(json_dump)

def get_pc_type(characters, char_name, head, filename):
    char_file = open(os.path.join(head, filename), 'r').read()
    match = re.search("playername\((.*?)\)", char_file)
    if match:
        if match.group(1) in ("GM", ""):
            characters[char_name]["pc_type"] = "GM"
        else:
            characters[char_name]["pc_type"] = "PC"
    else: # safeguard against errors - assume it's an NPC/GM
        characters[char_name]["pc_type"] = "GM"

def parse_val(val):
    if contains_special_chars(val):
        return val
    elif is_int(val):
        return int(val)
    elif is_number(val):
        return float(val)
    else:
        return val

def parse_gca_subsection_line(characters, line, curr_pc_name, curr_section):
    """Parses a single line under one of the sections [Stats, Advantages, etc.].

    Tries to adhere to the GCA format [e.g. key(val(15))] which is a bit wonky.  
    """
    curr_line_name = ""
    curr_key = ""
    curr_val = ""
    on_key = True # assume false means we're on a value
    num_l_parens = 0

    for char in line:
        if char == ",":
            if num_l_parens == 0:
                on_key = True 
                # Save previous key-value; Note some lines are named, so treat
                # these as sub-objects
                if not curr_line_name and curr_key == "name": 
                    # Special case: ignore this name weird name val in GCA with just hyphens. 
                    if len(curr_val.replace("-", "").strip()) > 1:
                        curr_line_name = curr_val
                        try:
                            if not characters[curr_pc_name][curr_section][curr_line_name]:
                                pass # this is a partial name? or we might overright something 
                        except KeyError:
                            characters[curr_pc_name][curr_section][curr_line_name] = {}
                    #else:
		        #print "\t\t", curr_line_name
                elif not curr_line_name and curr_key == "nameext": 
                    curr_line_name += " - " 
                    curr_line_name += curr_val
                    try:
                        if not characters[curr_pc_name][curr_section][curr_line_name]:
                            pass # this is a partial name? or we might overright something 
                    except KeyError:
                        characters[curr_pc_name][curr_section][curr_line_name] = {}
                else:
                    curr_val = parse_val(curr_val)   
                    if use_skip_keys_list and \
                        (curr_line_name in skip_keys or curr_key in skip_keys):
                        pass
                    else:
                        if curr_line_name:
                            characters[curr_pc_name][curr_section][curr_line_name][curr_key] = curr_val
                        else:
                            characters[curr_pc_name][curr_section][curr_key] = curr_val
                        #print "\t\t\t", curr_key, ":", curr_val 
                # reset key-val
                curr_key = ""
                curr_val = ""
                continue # don't add this to the curr_key/val

        elif char == "(":
            num_l_parens += 1
            if num_l_parens == 1:
                on_key = False # now at the value
                continue # don't add this to the curr_key/val
        elif char == ")":
            num_l_parens -= 1
            if num_l_parens == 0:
                continue # don't add this to the curr_key/val

        if on_key:
            curr_key += char
        elif not on_key:
            curr_val += char
        else:
            print "Error!  Please tell the developer he sucks. :)"

def convert_gca4_to_json(path):
    (head, tail) = os.path.split(path)
    if len(head) <= 0:
        head = "."
    print "Character Directory:", head 

    characters = {}

    for filename in os.listdir(head):
        if filename[-4:] == "gca4":
            char_file = open(os.path.join(head, filename), 'r')
            curr_pc_name = get_pc_name(head, filename)
            characters[curr_pc_name] = {"pdf": get_path_to_pdf_version(filename[:-5]) }
            get_pc_type(characters, curr_pc_name, head, filename)

            print curr_pc_name
            curr_section = None 
            for line in char_file:
                # remove whitespace and make sure we have a non-blank line to parse
                line = line.strip() 
                if len(line) < 1: 
                    continue
                    
                # see if we changed sections
                if line[0] + line[-1] == "[]": # Section header
                    curr_section = line[1:-1].lower()
                    characters[curr_pc_name][curr_section] = {}
                    continue 
                elif use_skip_sections_list and curr_section in skip_sections:
                    continue 
                else:
                    parse_gca_subsection_line(characters, line, curr_pc_name, curr_section)

    # finally, save all our work
    save_json(head, characters, pretty_print_json)

if __name__ == "__main__":
    # try to use the directory that the script is running in as the characters dir
    path = sys.argv[0] 
    convert_gca4_to_json(path)
                
