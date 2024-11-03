import struct

def add_2_to_negative_integers(file_path, offset_limit):
    with open(file_path, 'r+b') as file:
        offset = 0
        while offset < offset_limit:
            file.seek(offset)
            data = file.read(4)
            if len(data) < 4:
                break  # End of file
            
            value = struct.unpack('<i', data)[0]
            if value < 0:
                new_value = value + 3
                new_data = struct.pack('<i', new_value)
                file.seek(offset)
                file.write(new_data)
            
            offset += 4

# Example usage
file_path0 = 'mc_20.bjson'
file_path1 = 'mc_20_cn.bjson'
file_path2 = 'mc_20_jp.bjson'
file_path3 = 'mc_20_kr.bjson'
file_path4 = 'mc_20_ru.bjson'
file_path5 = 'mc_20_tw.bjson'
file_path6 = 'sga_10.bjson'


offset_limit = 0x11600
add_2_to_negative_integers(file_path0, offset_limit)
print("Operation completed.")
add_2_to_negative_integers(file_path1, offset_limit)
print("Operation completed.")
add_2_to_negative_integers(file_path2, offset_limit)
print("Operation completed.")
add_2_to_negative_integers(file_path3, offset_limit)
print("Operation completed.")
add_2_to_negative_integers(file_path4, offset_limit)
print("Operation completed.")
add_2_to_negative_integers(file_path5, offset_limit)
print("Operation completed.")
add_2_to_negative_integers(file_path6, offset_limit)
print("Operation completed.")