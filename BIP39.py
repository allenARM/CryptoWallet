#functions
from mnemonic import Mnemonic
def generate_words_bip39():
	mnemo = Mnemonic(language="English")
	words = mnemo.generate(strength=128)
	return words

def get_seed_from_words_bip39(words):
	mnemo = Mnemonic(language="English")
	seed = mnemo.to_seed(words, passphrase="").hex()

	return seed

import random

# example code

words = generate_words_bip39()
seed = get_seed_from_words_bip39(words)

random.seed(seed)

print(words)
print(seed)
print(random.random())