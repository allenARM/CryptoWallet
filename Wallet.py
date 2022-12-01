import BIP39
from bit import Key
from bit import PrivateKeyTestnet
from bit import PrivateKey

# generate words
# words = BIP39.generate_words_bip39()
# print(words)

# generate Bitcoin wallet in mainnet 
# key1 = Key()
# print(key1)

# using generated words
words = "seminar powder exile juice all property cousin august vault box account clarify"
print(words)
# getting entropy seed
entropy = BIP39.get_entropy_from_words_bip39(words)
# print(entropy)

# generating bitcoin wallet using entropy seed
key2 = Key.from_hex(entropy)

print(key2)

# converting private key to wif, so we can use it in test net
key2_test = PrivateKeyTestnet(key2.to_wif())

# checks to see if it worked
print("Your address is: " + key2_test.address)
print("Your segwit address is: " + key2_test.segwit_address)
print("Current balance in btc: " + key2_test.get_balance('btc'))
print("Private key is: " + str(key2_test))
