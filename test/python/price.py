import sys
from eth_abi import encode

def get_price(sqrtPriceX96, decimals0, decimals1, scaledPriceSensitivity):
    p = (float(sqrtPriceX96) / 2**96)**2
    d = 10**float(decimals0) / 10**float(decimals1)
    adjustedP = p / d

    data = encode(["uint256"], [int(float(scaledPriceSensitivity)/adjustedP)]).hex()
    print("0x" +str(data))

def main():
    args = sys.argv[1:]
    return get_price(*args)

__name__ == "__main__" and main()