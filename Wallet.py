import BIP39
import base58
from bit import Key
from bit import wif_to_key

words = BIP39.generate_words_bip39()
key1 = Key()

print(key1)
print(words)

words = "seminar powder exile juice all property cousin august vault box account clarify"

entropy = BIP39.get_entropy_from_words_bip39(words)
print(entropy)

key2 = Key.from_hex(entropy)

print(key2)

