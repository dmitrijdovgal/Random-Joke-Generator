// joke_generator.js
const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

class JokeGenerator {
    constructor() {
        this.jokes = [];
        this.loadDefaultJokes();
    }

    loadDefaultJokes() {
        this.jokes = [
            { id: 1, text: "Why don't scientists trust atoms? Because they make up everything!", category: "science" },
            { id: 2, text: "What do you call a fake noodle? An impasta!", category: "food" },
            { id: 3, text: "Why did the scarecrow win an award? Because he was outstanding in his field!", category: "pun" },
            { id: 4, text: "I'm reading a book on anti-gravity. It's impossible to put down!", category: "book" },
            { id: 5, text: "What's the best thing about Switzerland? I don't know, but the flag is a big plus!", category: "geography" },
            { id: 6, text: "Why do programmers prefer dark mode? Because light attracts bugs!", category: "programming" },
            { id: 7, text: "I told my wife she was drawing her eyebrows too high. She looked surprised.", category: "marriage" },
            { id: 8, text: "What do you call a bear with no teeth? A gummy bear!", category: "animal" },
            { id: 9, text: "Why don't eggs tell jokes? They'd crack each other up!", category: "food" },
            { id: 10, text: "I used to play piano by ear, but now I use my hands.", category: "music" },
        ];
    }

    getRandomJoke() {
        if (this.jokes.length === 0) return null;
        return this.jokes[Math.floor(Math.random() * this.jokes.length)];
    }

    getAllJokes() { return this.jokes; }

    addJoke(text, category = "general") {
        const id = this.jokes.length > 0 ? this.jokes[this.jokes.length-1].id + 1 : 1;
        const joke = { id, text, category };
        this.jokes.push(joke);
        return joke;
    }

    removeJoke(id) {
        const idx = this.jokes.findIndex(j => j.id === id);
        if (idx !== -1) {
            this.jokes.splice(idx, 1);
            return true;
        }
        return false;
    }

    getByCategory(category) {
        return this.jokes.filter(j => j.category.toLowerCase() === category.toLowerCase());
    }

    getCategories() {
        const cats = new Set(this.jokes.map(j => j.category));
        return [...cats].sort();
    }

    saveToFile(filename) {
        fs.writeFileSync(filename, JSON.stringify(this.jokes, null, 2), 'utf8');
    }

    loadFromFile(filename) {
        try {
            const data = fs.readFileSync(filename, 'utf8');
            this.jokes = JSON.parse(data);
        } catch (e) {
            console.log(`Error loading ${filename}: ${e.message}`);
        }
    }
}

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

function displayJoke(joke) {
    if (!joke) {
        console.log("No jokes available.");
        return;
    }
    console.log(`\n😂 Joke: ${joke.text}`);
    if (joke.category) console.log(`📁 Category: ${joke.category}`);
}

async function main() {
    const gen = new JokeGenerator();
    console.log("=== Random Joke Generator ===");
    while (true) {
        console.log("\n1. Get a random joke");
        console.log("2. Show all jokes");
        console.log("3. Add a joke");
        console.log("4. Remove a joke");
        console.log("5. Filter jokes by category");
        console.log("6. Show categories");
        console.log("7. Save jokes to file");
        console.log("8. Load jokes from file");
        console.log("9. Exit");
        const choice = await ask("Choose: ");
        switch (choice.trim()) {
            case "1": {
                const joke = gen.getRandomJoke();
                displayJoke(joke);
                break;
            }
            case "2": {
                const jokes = gen.getAllJokes();
                if (jokes.length === 0) console.log("No jokes.");
                else {
                    console.log("\nAll jokes:");
                    jokes.forEach(j => console.log(`[${j.id}] ${j.text} (${j.category})`));
                }
                break;
            }
            case "3": {
                const text = await ask("Enter your joke: ");
                if (!text.trim()) { console.log("Joke cannot be empty."); break; }
                const cat = await ask("Category (optional): ");
                const joke = gen.addJoke(text.trim(), cat.trim() || "general");
                console.log(`Joke added with ID ${joke.id}.`);
                break;
            }
            case "4": {
                const idStr = await ask("Enter joke ID to remove: ");
                const id = parseInt(idStr, 10);
                if (isNaN(id)) { console.log("Invalid ID."); break; }
                if (gen.removeJoke(id)) console.log("Joke removed.");
                else console.log("Joke not found.");
                break;
            }
            case "5": {
                const cat = await ask("Enter category: ");
                const jokes = gen.getByCategory(cat);
                if (jokes.length === 0) console.log(`No jokes in category '${cat}'.`);
                else {
                    console.log(`\nJokes in category '${cat}':`);
                    jokes.forEach(j => console.log(`[${j.id}] ${j.text}`));
                }
                break;
            }
            case "6": {
                const cats = gen.getCategories();
                if (cats.length === 0) console.log("No categories.");
                else console.log("Categories:", cats.join(", "));
                break;
            }
            case "7": {
                const fname = await ask("Filename: ");
                gen.saveToFile(fname);
                console.log(`Saved to ${fname}.`);
                break;
            }
            case "8": {
                const fname = await ask("Filename: ");
                gen.loadFromFile(fname);
                console.log(`Loaded from ${fname}.`);
                break;
            }
            case "9":
                console.log("Goodbye! 😄");
                rl.close();
                return;
            default:
                console.log("Invalid choice.");
        }
    }
}

main().catch(console.error);
