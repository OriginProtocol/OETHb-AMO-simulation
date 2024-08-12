import json
import sys
import os
import fcntl
import time
from eth_abi import decode
from typing import List, Dict, Any
from itertools import product

def decode_string_array(encoded_data: str) -> List[str]:
    try:
        if encoded_data.startswith('0x'):
            encoded_data = encoded_data[2:]
        data_bytes = bytes.fromhex(encoded_data)
        decoded = decode(['string[]'], data_bytes)
        return decoded[0]
    except Exception as e:
        print(f"Error decoding string array: {e}")
        sys.exit(1)

def decode_uint256_array(encoded_data: str) -> List[int]:
    try:
        if encoded_data.startswith('0x'):
            encoded_data = encoded_data[2:]
        data_bytes = bytes.fromhex(encoded_data)
        decoded = decode(['uint256[]'], data_bytes)
        return decoded[0]
    except Exception as e:
        print(f"Error decoding uint256 array: {e}")
        sys.exit(1)

def decode_uint256_2d_array(encoded_data: str) -> List[List[int]]:
    try:
        if encoded_data.startswith('0x'):
            encoded_data = encoded_data[2:]
        data_bytes = bytes.fromhex(encoded_data)
        decoded = decode(['uint256[][]'], data_bytes)
        return decoded[0]
    except Exception as e:
        print(f"Error decoding uint256 2D array: {e}")
        sys.exit(1)

def initialize_json_structure(data: Dict, input_names: List[str], input_values: List[List[int]], output_names: List[str]) -> None:
    try:
        if 'inputs' not in data:
            data['inputs'] = {}
        if 'outputs' not in data:
            data['outputs'] = {}
        
        for name, values in zip(input_names, input_values):
            data['inputs'][name] = values
        
        combinations = list(product(*input_values))
        
        for output_name in output_names:
            if output_name not in data['outputs']:
                data['outputs'][output_name] = {}
            
            current = data['outputs'][output_name]
            for combo in combinations:
                temp = current
                for i, value in enumerate(combo):
                    value_str = str(value)
                    if i == len(combo) - 1:
                        if value_str not in temp:
                            temp[value_str] = 0  # Initialize with 0 only if not present
                    else:
                        if value_str not in temp:
                            temp[value_str] = {}
                        temp = temp[value_str]
    except Exception as e:
        print(f"Error initializing JSON structure: {e}")
        sys.exit(1)

def update_json_structure(data: Dict, location: List[int], input_names: List[str], output_names: List[str], output_values: List[int]) -> None:
    try:
        for output_name, output_value in zip(output_names, output_values):
            current = data['outputs'][output_name]
            for i, loc_value in enumerate(location):
                loc_str = str(loc_value)
                if i == len(location) - 1:
                    current[loc_str] = output_value
                else:
                    if loc_str not in current:
                        current[loc_str] = {}
                    current = current[loc_str]
    except Exception as e:
        print(f"Error updating JSON structure: {e}")
        sys.exit(1)

def load_and_update_json(json_file_path: str, lock_file_path: str, 
                         input_names: List[str], input_values: List[List[int]], 
                         location: List[int],
                         output_names: List[str], output_values: List[int]) -> None:
    with open(lock_file_path, 'w') as lock_file:
        while True:
            try:
                fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except IOError:
                time.sleep(0.1)
        
        try:
            # Load existing data
            try:
                with open(json_file_path, 'r') as json_file:
                    data = json.load(json_file)
            except (FileNotFoundError, json.JSONDecodeError):
                data = {}

            # Initialize structure (this will not overwrite existing values)
            initialize_json_structure(data, input_names, input_values, output_names)

            # Update structure with new values
            update_json_structure(data, location, input_names, output_names, output_values)

            # Save updated data
            with open(json_file_path, 'w') as json_file:
                json.dump(data, json_file, indent=2)
            
            print(f"JSON data has been updated and saved to {json_file_path}")
        
        finally:
            fcntl.flock(lock_file, fcntl.LOCK_UN)

def main():
    lock_file_path = None
    try:
        if len(sys.argv) != 7:
            raise ValueError("Incorrect number of arguments. Expected 7 arguments including the script name.")

        json_file_path = sys.argv[1]
        lock_file_path = f"{json_file_path}.lock"
        input_names = decode_string_array(sys.argv[2])
        input_values = decode_uint256_2d_array(sys.argv[3])
        location = decode_uint256_array(sys.argv[4])
        output_names = decode_string_array(sys.argv[5])
        output_values = decode_uint256_array(sys.argv[6])

        if len(input_names) != len(input_values):
            raise ValueError("The number of input names does not match the number of input value lists.")
        if len(output_names) != len(output_values):
            raise ValueError("The number of output names does not match the number of output values.")

        load_and_update_json(json_file_path, lock_file_path, input_names, input_values, 
                             location, output_names, output_values)

    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
    finally:
        if lock_file_path and os.path.exists(lock_file_path):
            try:
                os.remove(lock_file_path)
                print(f"Lock file {lock_file_path} has been removed.")
            except Exception as e:
                print(f"Error removing lock file {lock_file_path}: {e}")

if __name__ == "__main__":
    main()