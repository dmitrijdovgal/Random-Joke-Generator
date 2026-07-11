// JokeGenerator.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

class Joke
{
    public int Id { get; set; }
    public string Text { get; set; }
    public string Category { get; set; }
}

class JokeGenerator
{
    private List<Joke> jokes = new List<Joke>();
    private Random rand = new Random();

    public JokeGenerator()
    {
        LoadDefaultJokes();
    }

    private void LoadDefaultJokes()
    {
        jokes = new List<Joke>
        {
            new Joke { Id = 1, Text = "Why don't scientists trust atoms? Because they make up everything!", Category = "science" },
            new Joke { Id = 2, Text = "What do you call a fake noodle? An impasta!", Category = "food" },
            new Joke { Id = 3, Text = "Why did the scarecrow win an award? Because he was outstanding in his field!", Category = "pun" },
            new Joke { Id = 4, Text = "I'm reading a book on anti-gravity. It's impossible to put down!", Category = "book" },
            new Joke { Id = 5, Text = "What's the best thing about Switzerland? I don't know, but the flag is a big plus!", Category = "geography" },
            new Joke { Id = 6, Text = "Why do programmers prefer dark mode? Because light attracts bugs!", Category = "programming" },
            new Joke { Id = 7, Text = "I told my wife she was drawing her eyebrows too high. She looked surprised.", Category = "marriage" },
            new Joke { Id = 8, Text = "What do you call a bear with no teeth? A gummy bear!", Category = "animal" },
            new Joke { Id = 9, Text = "Why don't eggs tell jokes? They'd crack each other up!", Category = "food" },
            new Joke { Id = 10, Text = "I used to play piano by ear, but now I use my hands.", Category = "music" },
        };
    }

    public Joke GetRandomJoke()
    {
        if (jokes.Count == 0) return null;
        return jokes[rand.Next(jokes.Count)];
    }

    public List<Joke> GetAllJokes() => jokes;

    public Joke AddJoke(string text, string category = "general")
    {
        int id = jokes.Count > 0 ? jokes.Max(j => j.Id) + 1 : 1;
        var joke = new Joke { Id = id, Text = text, Category = category };
        jokes.Add(joke);
        return joke;
    }

    public bool RemoveJoke(int id)
    {
        var joke = jokes.FirstOrDefault(j => j.Id == id);
        if (joke != null) return jokes.Remove(joke);
        return false;
    }

    public List<Joke> GetByCategory(string category)
    {
        return jokes.Where(j => j.Category.Equals(category, StringComparison.OrdinalIgnoreCase)).ToList();
    }

    public List<string> GetCategories()
    {
        return jokes.Select(j => j.Category).Distinct().OrderBy(c => c).ToList();
    }

    public void SaveToFile(string filename)
    {
        string json = JsonSerializer.Serialize(jokes, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(filename, json);
    }

    public void LoadFromFile(string filename)
    {
        if (!File.Exists(filename)) return;
        string json = File.ReadAllText(filename);
        jokes = JsonSerializer.Deserialize<List<Joke>>(json) ?? new List<Joke>();
    }

    public static void DisplayJoke(Joke joke)
    {
        if (joke == null)
        {
            Console.WriteLine("No jokes available.");
            return;
        }
        Console.WriteLine($"\n😂 Joke: {joke.Text}");
        if (!string.IsNullOrEmpty(joke.Category))
            Console.WriteLine($"📁 Category: {joke.Category}");
    }

    static void Main()
    {
        var gen = new JokeGenerator();
        Console.WriteLine("=== Random Joke Generator ===");
        while (true)
        {
            Console.WriteLine("\n1. Get a random joke");
            Console.WriteLine("2. Show all jokes");
            Console.WriteLine("3. Add a joke");
            Console.WriteLine("4. Remove a joke");
            Console.WriteLine("5. Filter jokes by category");
            Console.WriteLine("6. Show categories");
            Console.WriteLine("7. Save jokes to file");
            Console.WriteLine("8. Load jokes from file");
            Console.WriteLine("9. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim() ?? "";
            switch (choice)
            {
                case "1":
                    DisplayJoke(gen.GetRandomJoke());
                    break;
                case "2":
                    var all = gen.GetAllJokes();
                    if (all.Count == 0) Console.WriteLine("No jokes.");
                    else
                    {
                        Console.WriteLine("\nAll jokes:");
                        foreach (var j in all)
                            Console.WriteLine($"[{j.Id}] {j.Text} ({j.Category})");
                    }
                    break;
                case "3":
                    Console.Write("Enter your joke: ");
                    string text = Console.ReadLine()?.Trim();
                    if (string.IsNullOrEmpty(text)) { Console.WriteLine("Joke cannot be empty."); break; }
                    Console.Write("Category (optional): ");
                    string cat = Console.ReadLine()?.Trim() ?? "general";
                    var joke = gen.AddJoke(text, cat);
                    Console.WriteLine($"Joke added with ID {joke.Id}.");
                    break;
                case "4":
                    Console.Write("Enter joke ID to remove: ");
                    if (int.TryParse(Console.ReadLine(), out int id))
                    {
                        if (gen.RemoveJoke(id)) Console.WriteLine("Joke removed.");
                        else Console.WriteLine("Joke not found.");
                    }
                    else Console.WriteLine("Invalid ID.");
                    break;
                case "5":
                    Console.Write("Enter category: ");
                    string catFilter = Console.ReadLine()?.Trim() ?? "";
                    var filtered = gen.GetByCategory(catFilter);
                    if (filtered.Count == 0)
                        Console.WriteLine($"No jokes in category '{catFilter}'.");
                    else
                    {
                        Console.WriteLine($"\nJokes in category '{catFilter}':");
                        foreach (var j in filtered)
                            Console.WriteLine($"[{j.Id}] {j.Text}");
                    }
                    break;
                case "6":
                    var cats = gen.GetCategories();
                    if (cats.Count == 0) Console.WriteLine("No categories.");
                    else Console.WriteLine("Categories: " + string.Join(", ", cats));
                    break;
                case "7":
                    Console.Write("Filename: ");
                    string fname = Console.ReadLine()?.Trim() ?? "jokes.json";
                    gen.SaveToFile(fname);
                    Console.WriteLine($"Saved to {fname}.");
                    break;
                case "8":
                    Console.Write("Filename: ");
                    fname = Console.ReadLine()?.Trim() ?? "jokes.json";
                    gen.LoadFromFile(fname);
                    Console.WriteLine($"Loaded from {fname}.");
                    break;
                case "9":
                    Console.WriteLine("Goodbye! 😄");
                    return;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }
}
