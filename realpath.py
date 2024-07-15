from os.path import realpath, dirname
from sys import argv
print(dirname(realpath(argv[0])))
