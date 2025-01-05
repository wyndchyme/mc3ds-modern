import os
import hashlib

def calculate_sha256(file_path):
    """Calculate the SHA256 hash of an entire file."""
    sha256_hash = hashlib.sha256()
    try:
        with open(file_path, 'rb') as file:
            file_content = file.read()  # Read the entire file
            sha256_hash.update(file_content)
        return sha256_hash.hexdigest()
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return None

def create_sha256_hashlist():
    current_dir = os.getcwd()
    parent_dir = os.path.abspath(os.path.join(os.getcwd(), os.pardir))
    print(f"Parent directory: {parent_dir}")
    os.chdir(parent_dir)
    
    app_config_path = os.path.join(parent_dir, "appConfiguration.info")
    if not os.path.exists(app_config_path):
        print(f"Error: {app_config_path} does not exist.")
        return
    
    try:
        with open(app_config_path, 'r') as f:
            file_list = [line.split(',')[0].strip() for line in f.read().splitlines()]
    except Exception as e:
        print(f"Error reading {app_config_path}: {e}")
        return
    
    hash_list_path = os.path.join(current_dir, "hashlist.sha256")
    with open(hash_list_path, 'w') as hashlist_file:
        for file_name in file_list:
            file_path = f"{parent_dir}/{file_name}"
            print(f"Processing file: {file_name}")
            
            if not os.path.exists(file_path):
                print(f"Warning: {file_name} does not exist in the directory.")
                continue
            
            try:
                file_hash = calculate_sha256(file_path)
                if file_hash:
                    hashlist_file.write(f"{file_hash}\n")
            except Exception as e:
                print(f"Error processing {file_name}: {e}")
    
    # Calculate the hash for the entire appConfiguration.info file
    print("Calculating SHA256 hash for appConfiguration.info...")
    app_config_hash = calculate_sha256(app_config_path)
    if app_config_hash:
        print(f"SHA256 for appConfiguration.info: {app_config_hash}")
    
    print(f"Hash list created at {hash_list_path}")

create_sha256_hashlist()
