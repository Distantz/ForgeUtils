import math
from wordfreq import get_frequency_dict

class PascalCaser:
    def __init__(self, extra_words: list[str] = None):
        self.freqs = get_frequency_dict('en')
        
        if extra_words:
            for word in extra_words:
                self.freqs[word.lower()] = 1e-3 

    def get_pascal_case(self, string: str) -> str:
        segmented = self.segment_string(string)
        return ''.join(word.capitalize() for word in segmented)

    def segment_string(self, string: str) -> list[str]:
        string = string.lower()
        n = len(string)
        
        dp = [None] * (n + 1)
        dp[0] = (0.0, [])

        for i in range(n):
            if dp[i] is None:
                continue
            
            current_score, current_words = dp[i]
            
            # Look ahead up to a reasonable max word length (e.g., 25 chars)
            for j in range(i + 1, min(n + 1, i + 26)):
                word = string[i:j]

                if word in self.freqs:
                    prob = self.freqs[word]
                else:
                    prob = 1e-10 / (10 ** len(word))

                score = current_score + math.log(max(prob, 1e-300))
                
                if dp[j] is None or score > dp[j][0]:
                    dp[j] = (score, current_words + [word])

        # Fallback if the string couldn't be parsed
        if dp[n] is None:
            return list(string)
            
        return dp[n][1]