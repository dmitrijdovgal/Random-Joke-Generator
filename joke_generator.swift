// joke_generator.swift
import Foundation

struct Joke: Codable {
    let id: Int
    let text: String
    let category: String
}

class JokeGenerator {
    private var jokes: [Joke] = []

    init() {
        loadDefaultJokes()
    }

    private func loadDefaultJokes() {
        jokes = [
            Joke(id: 1, text: "Why don't scientists trust atoms? Because they make up everything!", category: "science"),
            Joke(id: 2, text: "What do you call a fake noodle? An impasta!", category: "food"),
            Joke(id: 3, text: "Why did the scarecrow win an award? Because he was outstanding in his field!", category: "pun"),
            Joke(id: 4, text: "I'm reading a book on anti-gravity. It's impossible to put down!", category: "book"),
            Joke(id: 5, text: "What's the best thing about Switzerland? I don't know, but the flag is a big plus!", category: "geography"),
            Joke(id: 6, text: "Why do programmers prefer dark mode? Because light attracts bugs!", category: "programming"),
            Joke(id: 7, text: "I told my wife she was drawing her eyebrows too high. She looked surprised.", category: "marriage"),
            Joke(id: 8, text: "What do you call a bear with no teeth? A gummy bear!", category: "animal"),
            Joke(id: 9, text: "Why don't eggs tell jokes? They'd crack each other up!", category: "food"),
            Joke(id: 10, text: "I used to play piano by ear, but now I use my hands.", category: "music"),
        ]
    }

    func randomJoke() -> Joke? {
        return jokes.randomElement()
    }

    func allJokes() -> [Joke] {
        return jokes
    }

    func addJoke(text: String, category: String = "general") -> Joke {
        let id = (jokes.map { $0.id }.max() ?? 0) + 1
        let joke = Joke(id: id, text: text, category: category)
        jokes.append(joke)
        return joke
    }

    func removeJoke(id: Int) -> Bool {
        if let idx = jokes.firstIndex(where: { $0.id == id }) {
            jokes.remove(at: idx)
            return true
        }
        return false
    }

    func byCategory(_ category: String) -> [Joke] {
        return jokes.filter { $0.category.lowercased() == category.lowercased() }
    }

    func categories() -> [String] {
        return Set(jokes.map { $0.category }).sorted()
    }

    func saveToFile(filename: String) throws {
        let data = try JSONEncoder().encode(jokes)
        try data.write(to: URL(fileURLWithPath: filename))
    }

    func loadFromFile(filename: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: filename))
        jokes = try JSONDecoder().decode([Joke].self, from: data)
    }

    func displayJoke(_ joke: Joke?) {
        guard let joke = joke else {
            print("No jokes available.")
            return
        }
        print("\n😂 Joke: \(joke.text)")
        if !joke.category.isEmpty {
            print("📁 Category: \(joke.category)")
        }
    }
}

func main() {
    let gen = JokeGenerator()
    print("=== Random Joke Generator ===")
    while true {
        print("\n1. Get a random joke")
        print("2. Show all jokes")
        print("3. Add a joke")
        print("4. Remove a joke")
        print("5. Filter jokes by category")
        print("6. Show categories")
        print("7. Save jokes to file")
        print("8. Load jokes from file")
        print("9. Exit")
        print("Choose: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
        switch choice {
        case "1":
            gen.displayJoke(gen.randomJoke())
        case "2":
            let jokes = gen.allJokes()
            if jokes.isEmpty {
                print("No jokes.")
            } else {
                print("\nAll jokes:")
                for j in jokes {
                    print("[\(j.id)] \(j.text) (\(j.category))")
                }
            }
        case "3":
            print("Enter your joke: ", terminator: "")
            guard let text = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
                print("Joke cannot be empty.")
                continue
            }
            print("Category (optional): ", terminator: "")
            let cat = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "general"
            let joke = gen.addJoke(text: text, category: cat.isEmpty ? "general" : cat)
            print("Joke added with ID \(joke.id).")
        case "4":
            print("Enter joke ID to remove: ", terminator: "")
            guard let idStr = readLine(), let id = Int(idStr.trimmingCharacters(in: .whitespaces)) else {
                print("Invalid ID.")
                continue
            }
            if gen.removeJoke(id: id) {
                print("Joke removed.")
            } else {
                print("Joke not found.")
            }
        case "5":
            print("Enter category: ", terminator: "")
            guard let cat = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            let jokes = gen.byCategory(cat)
            if jokes.isEmpty {
                print("No jokes in category '\(cat)'.")
            } else {
                print("\nJokes in category '\(cat)':")
                for j in jokes {
                    print("[\(j.id)] \(j.text)")
                }
            }
        case "6":
            let cats = gen.categories()
            if cats.isEmpty {
                print("No categories.")
            } else {
                print("Categories: \(cats.joined(separator: ", "))")
            }
        case "7":
            print("Filename: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            do {
                try gen.saveToFile(filename: fname)
                print("Saved to \(fname).")
            } catch {
                print("Error saving: \(error)")
            }
        case "8":
            print("Filename: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            do {
                try gen.loadFromFile(filename: fname)
                print("Loaded from \(fname).")
            } catch {
                print("Error loading: \(error)")
            }
        case "9":
            print("Goodbye! 😄")
            return
        default:
            print("Invalid choice.")
        }
    }
}

main()
