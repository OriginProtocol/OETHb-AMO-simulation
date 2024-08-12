import json
import sys
import os
import fcntl
import time
from eth_abi import decode
from typing import List, Dict

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

def initialize_json_structure(data: Dict, ratios: List[int], amounts: List[int]) -> None:
    try:
        if 'outputs' not in data:
            data['outputs'] = {}
        
        output_keys = ['totalSuplyBefore', 'totalSuplyAfter', 'vaultBalanceBefore', 'vaultBalanceAfter']
        
        for key in output_keys:
            if key not in data['outputs']:
                data['outputs'][key] = {}
            
            for ratio in ratios:
                ratio_str = str(ratio)
                if ratio_str not in data['outputs'][key]:
                    data['outputs'][key][ratio_str] = {}
                
                for amount in amounts:
                    amount_str = str(amount)
                    if amount_str not in data['outputs'][key][ratio_str]:
                        data['outputs'][key][ratio_str][amount_str] = 0
    except Exception as e:
        print(f"Error initializing JSON structure: {e}")
        sys.exit(1)

def update_json_structure(data: Dict, ratio: int, amount: int, 
                          total_supply_before: int, total_supply_after: int, 
                          balance_before: int, balance_after: int) -> None:
    try:
        ratio_str = str(ratio)
        amount_str = str(amount)
        
        data['outputs']['totalSuplyBefore'][ratio_str][amount_str] = total_supply_before
        data['outputs']['totalSuplyAfter'][ratio_str][amount_str] = total_supply_after
        data['outputs']['vaultBalanceBefore'][ratio_str][amount_str] = balance_before
        data['outputs']['vaultBalanceAfter'][ratio_str][amount_str] = balance_after
    except Exception as e:
        print(f"Error updating JSON structure: {e}")
        sys.exit(1)

def load_and_update_json(json_file_path: str, lock_file_path: str, ratios: List[int], amounts: List[int], 
                         current_ratio: int, current_amount: int,
                         total_supply_before: int, total_supply_after: int,
                         balance_before: int, balance_after: int) -> None:
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
            initialize_json_structure(data, ratios, amounts)
            update_json_structure(data, current_ratio, current_amount,
                                  total_supply_before, total_supply_after,
                                  balance_before, balance_after)

            # Save updated data
            with open(json_file_path, 'w') as json_file:
                json.dump(data, json_file, indent=2)
            
            print(f"JSON data has been updated and saved to {json_file_path}")
        
        finally:
            fcntl.flock(lock_file, fcntl.LOCK_UN)

def main():
    lock_file_path = None
    try:
        if len(sys.argv) != 10:
            raise ValueError("Incorrect number of arguments. Expected 10 arguments including the script name.")

        json_file_path = sys.argv[1]
        lock_file_path = f"{json_file_path}.lock"
        ratios = decode_uint256_array(sys.argv[2])
        amounts = decode_uint256_array(sys.argv[3])
        current_ratio = decode_uint256(sys.argv[4])
        current_amount = decode_uint256(sys.argv[5])
        total_supply_before = decode_uint256(sys.argv[6])
        total_supply_after = decode_uint256(sys.argv[7])
        balance_before = decode_uint256(sys.argv[8])
        balance_after = decode_uint256(sys.argv[9])

        load_and_update_json(json_file_path, lock_file_path, ratios, amounts, current_ratio, current_amount,
                             total_supply_before, total_supply_after,
                             balance_before, balance_after)

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