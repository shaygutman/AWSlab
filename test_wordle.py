import unittest

from wordle import is_valid_guess, score


class ScoreTest(unittest.TestCase):
    def test_exact_match(self):
        self.assertEqual(score("apple", "apple"), ["correct"] * 5)

    def test_no_shared_letters(self):
        self.assertEqual(score("zzzzz", "apple"), ["absent"] * 5)

    def test_present_letters(self):
        self.assertEqual(
            score("pleap", "apple"),
            ["present", "present", "present", "present", "present"],
        )

    def test_duplicate_guess_letter_counted_once(self):
        self.assertEqual(
            score("eeeee", "apple"),
            ["absent", "absent", "absent", "absent", "correct"],
        )

    def test_duplicate_present_limited_by_answer(self):
        self.assertEqual(
            score("ppzzz", "apple"),
            ["present", "correct", "absent", "absent", "absent"],
        )


class ValidGuessTest(unittest.TestCase):
    def test_valid(self):
        self.assertTrue(is_valid_guess("hello"))

    def test_invalid(self):
        for guess in ["hell", "hellos", "he1lo", "héllo", None, 12345]:
            self.assertFalse(is_valid_guess(guess))


if __name__ == "__main__":
    unittest.main()
