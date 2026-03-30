import csv
import sys

input_file = 'data.csv'
output = sys.stdout

with open(input_file, mode='r', newline='') as f:
    reader = csv.DictReader(f)

    new_headers = reader.fieldnames
    writer = csv.DictWriter(output, fieldnames=new_headers)

    writer.writeheader()
    for row in reader:
        writer.writerow(row)