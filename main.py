import csv
import sys

# 1. Setup the input and output
input_file = 'data.csv'
output_dst = sys.stdout  # This sends everything to the terminal

with open(input_file, mode='r', newline='') as f:
    reader = csv.DictReader(f)

    # 2. Define the new structure
    new_headers = reader.fieldnames + ['New_Column']
    writer = csv.DictWriter(output_dst, fieldnames=new_headers)

    # 3. Write the header and the data
    writer.writeheader()
    for row in reader:
        # This is where you add your logic
        row['New_Column'] = 'Some Value'
        writer.writerow(row)