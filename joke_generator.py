# joke_generator.py
import json
import random
import sys
from typing import List, Dict, Optional

class JokeGenerator:
    def __init__(self):
        self.jokes: List[Dict] = []
        self._load_default_jokes()

    def _load_default_jokes(self):
        self.jokes = [
            {"id": 1, "text": "Why don't scientists trust atoms? Because they make up everything!", "category": "science"},
            {"id": 2, "text": "What do you call a fake noodle? An impasta!", "category": "food"},
            {"id": 3, "text": "Why did the scarecrow win an award? Because he was outstanding in his field!", "category": "pun"},
            {"id": 4, "text": "I'm reading a book on anti-gravity. It's impossible to put down!", "category": "book"},
            {"id": 5, "text": "What's the best thing about Switzerland? I don't know, but the flag is a big plus!", "category": "geography"},
            {"id": 6, "text": "Why do programmers prefer dark mode? Because light attracts bugs!", "category": "programming"},
            {"id": 7, "text": "I told my wife she was drawing her eyebrows too high. She looked surprised.", "category": "marriage"},
            {"id": 8, "text": "What do you call a bear with no teeth? A gummy bear!", "category": "animal"},
            {"id": 9, "text": "Why don't eggs tell jokes? They'd crack each other up!", "category": "food"},
            {"id": 10, "text": "I used to play piano by ear, but now I use my hands.", "category": "music"},
        ]

    def get_random_joke(self) -> Optional[Dict]:
        return random.choice(self.jokes) if self.jokes else None

    def get_all_jokes(self) -> List[Dict]:
        return self.jokes

    def add_joke(self, text: str, category: str = "general") -> Dict:
        new_id = max([j["id"] for j in self.jokes]) + 1 if self.jokes else 1
        joke = {"id": new_id, "text": text, "category": category}
        self.jokes.append(joke)
        return joke

    def remove_joke(self, joke_id: int) -> bool:
        for i, j in enumerate(self.jokes):
            if j["id"] == joke_id:
                del self.jokes[i]
                return True
        return False

    def get_by_category(self, category: str) -> List[Dict]:
        return [j for j in self.jokes if j["category"].lower() == category.lower()]

    def get_categories(self) -> List[str]:
        return sorted(set(j["category"] for j in self.jokes))

    def save_to_file(self, filename: str):
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(self.jokes, f, indent=2, ensure_ascii=False)

    def load_from_file(self, filename: str):
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                self.jokes = json.load(f)
        except FileNotFoundError:
            print(f"File {filename} not found.")

def display_joke(joke):
    print(f"\n😂 Joke: {joke['text']}")
    if joke.get('category'):
        print(f"📁 Category: {joke['category']}")

def main():
    gen = JokeGenerator()
    print("=== Random Joke Generator ===")
    while True:
        print("\n1. Get a random joke")
        print("2. Show all jokes")
        print("3. Add a joke")
        print("4. Remove a joke")
        print("5. Filter jokes by category")
        print("6. Show categories")
        print("7. Save jokes to file")
        print("8. Load jokes from file")
        print("9. Exit")
        choice = input("Choose: ").strip()
        if choice == "1":
            joke = gen.get_random_joke()
            if joke:
                display_joke(joke)
            else:
                print("No jokes available.")
        elif choice == "2":
            jokes = gen.get_all_jokes()
            if jokes:
                print("\nAll jokes:")
                for j in jokes:
                    print(f"[{j['id']}] {j['text']} ({j['category']})")
            else:
                print("No jokes.")
        elif choice == "3":
            text = input("Enter your joke: ").strip()
            if not text:
                print("Joke cannot be empty.")
                continue
            cat = input("Category (optional): ").strip() or "general"
            joke = gen.add_joke(text, cat)
            print(f"Joke added with ID {joke['id']}.")
        elif choice == "4":
            try:
                jid = int(input("Enter joke ID to remove: ").strip())
                if gen.remove_joke(jid):
                    print("Joke removed.")
                else:
                    print("Joke not found.")
            except ValueError:
                print("Invalid ID.")
        elif choice == "5":
            cat = input("Enter category: ").strip()
            jokes = gen.get_by_category(cat)
            if jokes:
                print(f"\nJokes in category '{cat}':")
                for j in jokes:
                    print(f"[{j['id']}] {j['text']}")
            else:
                print(f"No jokes in category '{cat}'.")
        elif choice == "6":
            cats = gen.get_categories()
            if cats:
                print("Categories:", ", ".join(cats))
            else:
                print("No categories.")
        elif choice == "7":
            fname = input("Filename: ").strip()
            gen.save_to_file(fname)
            print(f"Saved to {fname}.")
        elif choice == "8":
            fname = input("Filename: ").strip()
            gen.load_from_file(fname)
            print(f"Loaded from {fname}.")
        elif choice == "9":
            print("Goodbye! 😄")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
