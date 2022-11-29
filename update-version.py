#! /usr/bin/python3
# -*- coding: utf-8 -*-
# Importing re module
import re, os

#
# Adapt these before a new release an run the script
#
new_version = "1.59"
new_date = "2022/11/29"

# Replace version and date in all files
def replacetext():
    for dname, dirs, files in os.walk("tex/"):
        search_text = "\{polyglossia\}\[\d\d\d\d/\d\d/\d\d v\d\.\d+"
        replace_text = "{polyglossia}[" + new_date + " v" + new_version
        for fname in files:
            if fname != "polyglossia.sty":
                continue
            fpath = os.path.join(dname, fname)
            file = ""
            with open(fpath) as f:
                # Read file data and store it in a file variable
                file = f.read()

            # Replace pattern
            file = re.sub(search_text, replace_text, file)

            with open(fpath, "w") as f:
                f.write(file)
    # Report success
    print("polyglossia.sty updated")

    for dname, dirs, files in os.walk("tex/"):
        search_text = "Language definition file \(part of polyglossia v\d\.\d+ \-\- \d\d\d\d/\d\d/\d\d"
        replace_text = "Language definition file (part of polyglossia v" + new_version + " -- " + new_date
        search_text_lde = "\{\d\d\d\d/\d\d/\d\d\}\{v\d\.\d+\}"
        replace_text_lde = "{" + new_date + "}{v" + new_version + "}" 
        for fname in files:
            extension = os.path.splitext(fname)[1]
            if extension != ".ldf" and extension != ".lde":
                continue
            fpath = os.path.join(dname, fname)
            file = ""
            with open(fpath) as f:
                # Read file data and store it in a file variable
                file = f.read()

            # Replace pattern
            file_new = re.sub(search_text, replace_text, file)
            
            if file == file_new:
                print("No version string found, or version already updated, in " + fname + "!")

            # Also consider Bastien's experimental macro
            file_new = re.sub(search_text_lde, replace_text_lde, file_new)

            with open(fpath, "w") as f:
                f.write(file_new)
    # Report success
    print("ldf and lde versions updated")
    
    for dname, dirs, files in os.walk("tex/"):
        search_text = "part of polyglossia v\d\.\d+ \-\- \d\d\d\d/\d\d/\d\d"
        replace_text = "part of polyglossia v" + new_version + " -- " + new_date
        for fname in files:
            extension = os.path.splitext(fname)[1]
            if extension != ".lua":
                continue
            fpath = os.path.join(dname, fname)
            file = ""
            with open(fpath) as f:
                # Read file data and store it in a file variable
                file = f.read()

            # Replace pattern
            file_new = re.sub(search_text, replace_text, file)
            
            if file == file_new:
                # Report back if we didn't find a match
                print("No version string found in " + fname + "!")

            with open(fpath, "w") as f:
                f.write(file_new)
    # Report success
    print("lua module versions updated")

    for dname, dirs, files in os.walk("doc/"):
        search_text = "\d\.\d+ \(forthcoming\)"
        replace_text = new_version + " (" + new_date + ")" 
        for fname in files:
            if fname != "polyglossia.tex":
                continue
            fpath = os.path.join(dname, fname)
            file = ""
            with open(fpath) as f:
                # Read file data and store it in a file variable
                file = f.read()

            # Replace pattern
            file = re.sub(search_text, replace_text, file)

            with open(fpath, "w") as f:
                f.write(file)
    # Report success
    print("Manual version updated")
   
    # Opening the file in read and write mode
    with open('README.md','r+') as f:
        udate = new_date.split("/")
        search_text = "THE POLYGLOSSIA PACKAGE v\d\.\d+"
        replace_text = "THE POLYGLOSSIA PACKAGE v" + new_version
        search_ctext = "(\-\d\d\d\d) ([Arthur|Bastien|Jürgen])"
        replace_ctext = "-" + new_date[:4] + r" \2"
        # Reading the file data and store
        # it in a file variable
        file = f.read()
          
        # Replacing Version
        file = re.sub(search_text, replace_text, file)
        # Updating Copyright Year
        file = re.sub(search_ctext, replace_ctext, file)
  
        # Setting the position to the top
        # of the page to insert data
        f.seek(0)
          
        # Writing replaced data in the file
        f.write(file)
  
        # Truncating the file size
        f.truncate()
    # Report success
    print("README.md updated")
    
    return "All replacements done!"

# Call main function
print(replacetext())

