import os
import subprocess

def main():
    parent_dir = os.path.abspath(os.path.join(os.getcwd(), os.pardir))
    exclude_file = "appConfiguration.info"
    exclude_folders = {"_scripts", "docs"}
    files_list_path = os.path.join(os.getcwd(), f"{parent_dir}\\appConfiguration.info")
    
    files_list = []
    directories_list = []
    existing_entries = {}
    
    if os.path.exists(files_list_path):
        with open(files_list_path, "r") as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        path, version = line.rsplit(", ", 1)
                        existing_entries[path.strip()] = int(version.strip())
                    except ValueError:
                        print(f"Invalid line format in {files_list_path}: {line}")

    for root, dirs, files in os.walk(parent_dir):
        dirs[:] = [d for d in dirs if d not in exclude_folders]
        
        directories_list.append(root)
        for file in files:
            if file != exclude_file:
                relative_path = os.path.join(root, file).replace(parent_dir, "").strip()
                if relative_path not in existing_entries:
                    files_list.append(relative_path)
    
    with open(files_list_path, "w") as f:
        for path, version in existing_entries.items():
            f.write(f"{path},{version}\n")
        for new_file in files_list:
            f.write(f"{new_file}\n")
    
    example_script_path = os.path.join(os.getcwd(), ".\\addNumbersToAppConf.py")
    if os.path.exists(example_script_path):
        subprocess.run(["python", example_script_path])
    else:
        print(f"'example.py' not found in {os.getcwd()}.")

if __name__ == "__main__":
    main()
