import os
import hashlib

def calculate_sha256(file_path):
    """Calculate the SHA256 hash of a file."""
    try:
        with open(file_path, 'rb') as file:
            file_content = file.read()  # Read the whole file at once
            sha256_hash = hashlib.sha256(file_content).hexdigest()
        return sha256_hash
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return None

def update_hash_and_version():
    current_dir = os.getcwd()
    parent_dir = os.path.abspath(os.path.join(current_dir, os.pardir))
    
    app_config_path = os.path.join(parent_dir, "appConfiguration.info")
    hashlist_path = os.path.join(current_dir, "hashlist.sha256")
    
    if not os.path.exists(app_config_path) or not os.path.exists(hashlist_path):
        print("Error: Required files (appConfiguration.info or hashlist.sha256) not found.")
        return
    
    try:
        # Read the app configuration
        with open(app_config_path, 'r') as config_file:
            app_config_lines = config_file.readlines()
        
        # Read the hashlist
        with open(hashlist_path, 'r') as hashlist_file:
            hashlist_lines = hashlist_file.readlines()
        
        if len(app_config_lines) != len(hashlist_lines):
            print("Error: appConfiguration.info and hashlist.sha256 do not have matching line counts.")
            return

        updated_hashlist = []
        updated_config = []

        # Process each line in appConfiguration.info
        for idx, line in enumerate(app_config_lines):
            file_info = line.strip().split(',')
            file_path = file_info[0].strip()
            version = int(file_info[1].strip())
            full_file_path = f"{parent_dir}/{file_path}"
            
            if not os.path.exists(full_file_path):
                print(f"Warning: File {file_path} does not exist. Skipping.")
                updated_hashlist.append(hashlist_lines[idx].strip())  # Keep existing hash
                updated_config.append(line.strip())  # Keep existing configuration
                continue

            # Calculate current hash
            current_hash = calculate_sha256(full_file_path)
            stored_hash = hashlist_lines[idx].strip()
            
            if current_hash != stored_hash:
                print(f"Hash mismatch for {file_path}. Updating hash and version.")
                updated_hashlist.append(current_hash)
                updated_config.append(f"{file_path}, {version + 1}")
            else:
                updated_hashlist.append(stored_hash)
                updated_config.append(line.strip())
        
        # Write updated hashlist
        with open(hashlist_path, 'w') as hashlist_file:
            hashlist_file.write("\n".join(updated_hashlist) + "\n")
        
        # Write updated app configuration
        with open(app_config_path, 'w') as config_file:
            config_file.write("\n".join(updated_config) + "\n")
        
        print("Hashlist and appConfiguration.info updated successfully.")
    
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    update_hash_and_version()
