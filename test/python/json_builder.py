import json
import sys
import os
import fcntl
import time
from eth_abi import decode
from typing import List, Dict, Any

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

def decode_uint256(encoded_data: str) -> int:
    try:
        if encoded_data.startswith('0x'):
            encoded_data = encoded_data[2:]
        data_bytes = bytes.fromhex(encoded_data)
        decoded = decode(['uint256'], data_bytes)
        return decoded[0]
    except Exception as e:
        print(f"Error decoding uint256: {e}")
        sys.exit(1)

def initialize_json_structure(data: Dict, ratios: List[int], amounts: List[int], output_names: List[str]) -> None:
    try:
        if 'outputs' not in data:
            data['outputs'] = {}
        
        for output_name in output_names:
            if output_name not in data['outputs']:
                data['outputs'][output_name] = {}
            
            for ratio in ratios:
                ratio_str = str(ratio)
                if ratio_str not in data['outputs'][output_name]:
                    data['outputs'][output_name][ratio_str] = {}
                
                for amount in amounts:
                    amount_str = str(amount)
                    if amount_str not in data['outputs'][output_name][ratio_str]:
                        data['outputs'][output_name][ratio_str][amount_str] = 0
    except Exception as e:
        print(f"Error initializing JSON structure: {e}")
        sys.exit(1)

def update_json_structure(data: Dict, ratio: int, amount: int, output_names: List[str], output_values: List[int]) -> None:
    try:
        ratio_str = str(ratio)
        amount_str = str(amount)
        
        for name, value in zip(output_names, output_values):
            data['outputs'][name][ratio_str][amount_str] = value
    except Exception as e:
        print(f"Error updating JSON structure: {e}")
        sys.exit(1)

def load_and_update_json(json_file_path: str, lock_file_path: str, ratios: List[int], amounts: List[int], 
                         current_ratio: int, current_amount: int,
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

            # Update inputs
            data['inputs'] = {
                "ratio": ratios,
                "amount": amounts
            }

            # Initialize and update structure
            initialize_json_structure(data, ratios, amounts, output_names)
            update_json_structure(data, current_ratio, current_amount, output_names, output_values)

            # Save updated data
            with open(json_file_path, 'w') as json_file:
                json.dump(data, json_file, indent=2)
            
            print(f"JSON data has been updated and saved to {json_file_path}")
        
        finally:
            fcntl.flock(lock_file, fcntl.LOCK_UN)

def main():
    lock_file_path = None
    try:
        if len(sys.argv) != 8:
            raise ValueError("Incorrect number of arguments. Expected 8 arguments including the script name.")

        json_file_path = sys.argv[1]
        lock_file_path = f"{json_file_path}.lock"
        ratios = decode_uint256_array(sys.argv[2])
        amounts = decode_uint256_array(sys.argv[3])
        current_ratio = decode_uint256(sys.argv[4])
        current_amount = decode_uint256(sys.argv[5])
        output_names = decode_string_array(sys.argv[6])
        output_values = decode_uint256_array(sys.argv[7])

        if len(output_names) != len(output_values):
            raise ValueError("The number of output names does not match the number of output values.")

        load_and_update_json(json_file_path, lock_file_path, ratios, amounts, current_ratio, current_amount,
                             output_names, output_values)

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