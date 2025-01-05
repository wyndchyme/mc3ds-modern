import os
file_path = os.path.abspath(os.path.join(os.getcwd(), os.pardir, "appConfiguration.info"))
with open(file_path, 'r') as f:
    data = f.readlines()

with open(file_path, 'w') as of:
    for line in data:
        line = line.strip()
        if ',' in line:
            parts = line.split(',')
            if len(parts) == 2 and parts[1].strip().isdigit():
                of.write(line + '\n')
            else:
                of.write(f"{parts[0].strip()}, 1\n")
        else:
            of.write(f"{line}, 1\n")
