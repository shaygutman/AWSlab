WORD_LENGTH = 5
MAX_GUESSES = 6

ANSWERS = [
    "apple", "beach", "brain", "bread", "brick", "brush", "candy", "chair",
    "chalk", "charm", "chess", "chest", "child", "cloud", "coast", "crane",
    "cream", "crown", "dance", "dream", "drink", "eagle", "earth", "fairy",
    "field", "flame", "flute", "frost", "fruit", "ghost", "giant", "glass",
    "globe", "grape", "grass", "heart", "honey", "horse", "house", "jelly",
    "juice", "knife", "lemon", "light", "lucky", "magic", "mango", "maple",
    "music", "night", "ocean", "olive", "onion", "paint", "paper", "peach",
    "pearl", "piano", "pilot", "pizza", "plant", "plate", "queen", "quiet",
    "radio", "river", "robot", "salad", "sauce", "scarf", "sheep", "shell",
    "shirt", "shore", "skate", "smile", "snake", "space", "spoon", "storm",
    "sugar", "sunny", "sword", "table", "tiger", "toast", "tooth", "torch",
    "tower", "train", "truck", "water", "whale", "wheel", "world", "zebra",
]


def score(guess, answer):
    result = ["absent"] * WORD_LENGTH
    leftover = {}
    for i, (g, a) in enumerate(zip(guess, answer)):
        if g == a:
            result[i] = "correct"
        else:
            leftover[a] = leftover.get(a, 0) + 1
    for i, g in enumerate(guess):
        if result[i] != "correct" and leftover.get(g, 0) > 0:
            result[i] = "present"
            leftover[g] -= 1
    return result


def is_valid_guess(guess):
    return isinstance(guess, str) and len(guess) == WORD_LENGTH and guess.isascii() and guess.isalpha()
