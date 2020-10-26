#!/usr/bin/python
import sys
import csv
#csv_file = raw_input('')
#txt_file = raw_input('')
csv_file = sys.argv[1]
txt_file = sys.argv[2]
with open(txt_file, "w") as my_output_file:
    with open(csv_file, "r") as my_input_file:
        [ my_output_file.write("\t".join(row)+'\n') for row in csv.reader(my_input_file)]
    my_output_file.close()
