import sys
import json
import os
from eth_abi import decode
from hexbytes import HexBytes

def decode_uint256_array(encoded_string):
    if not encoded_string.startswith('0x'):
        raise ValueError("Encoded string must start with '0x'")
    encoded_bytes = HexBytes(encoded_string[2:])
    try:
        return [int(x) for x in decode(['uint256[]'], encoded_bytes)[0]]
    except Exception as e:
        raise ValueError(f"Failed to decode uint256 array: {e}")

def decode_uint256_nested_array(encoded_string):
    if not encoded_string.startswith('0x'):
        raise ValueError("Encoded string must start with '0x'")
    encoded_bytes = HexBytes(encoded_string[2:])
    try:
        decoded = decode(['uint256[][]'], encoded_bytes)[0]
        return [[int(y) for y in x] for x in decoded]
    except Exception as e:
        raise ValueError(f"Failed to decode nested uint256 array: {e}")

def create_json_structure(ratios, amounts, check_balances):
    if len(ratios) != len(amounts) or len(ratios) != len(check_balances):
        raise ValueError("Mismatch in lengths of ratios, amounts, and check_balances")
    return {
        "ratios": ratios,
        "amounts": {str(ratios[i]): amounts[i] for i in range(len(ratios))},
        "checkBalances": {str(ratios[i]): check_balances[i] for i in range(len(ratios))}
    }

def main():
    if len(sys.argv) != 5:
        raise ValueError("Incorrect number of arguments. Expected 5, got " + str(len(sys.argv)))

    path_and_name = sys.argv[1]
    encoded_ratios = sys.argv[2]
    encoded_amounts = sys.argv[3]
    encoded_checkBalances = sys.argv[4]

    try:
        ratios = decode_uint256_array(encoded_ratios)
        amounts = decode_uint256_nested_array(encoded_amounts)
        check_balances = decode_uint256_nested_array(encoded_checkBalances)

        json_data = create_json_structure(ratios, amounts, check_balances)

        json_path = f"{path_and_name}.json"

        os.makedirs(os.path.dirname(json_path), exist_ok=True)

        with open(json_path, 'w') as json_file:
            json.dump(json_data, json_file, indent=4)

        print(f"JSON file created successfully at: {json_path}")
        
        # Verify the file was created and can be read back
        with open(json_path, 'r') as json_file:
            _ = json.load(json_file)

    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()