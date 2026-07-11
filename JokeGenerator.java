// JokeGenerator.java
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;

class Joke {
    int id;
    String text;
    String category;

    Joke(int id, String text, String category) {
        this.id = id;
        this.text = text;
        this.category = category;
    }
}

public class JokeGenerator {
    private List<Joke> jokes = new ArrayList<>();
    private Random rand = new Random();

    public JokeGenerator() {
        loadDefaultJokes();
    }

    private void loadDefaultJokes() {
        jokes.add(new Joke(1, "Why don't scientists trust atoms? Because they make up everything!", "science"));
        jokes.add(new Joke(2, "What do you call a fake noodle? An impasta!", "food"));
        jokes.add(new Joke(3, "Why did the scarecrow win an award? Because he was outstanding in his field!", "pun"));
        jokes.add(new Joke(4, "I'm reading a book on anti-gravity. It's impossible to put down!", "book"));
        jokes.add(new Joke(5, "What's the best thing about Switzerland? I don't know, but the flag is a big plus!", "geography"));
        jokes.add(new Joke(6, "Why do programmers prefer dark mode? Because light attracts bugs!", "programming"));
        jokes.add(new Joke(7, "I told my wife she was drawing her eyebrows too high. She looked surprised.", "marriage"));
        jokes.add(new Joke(8, "What do you call a bear with no teeth? A gummy bear!", "animal"));
        jokes.add(new Joke(9, "Why don't eggs tell jokes? They'd crack each other up!", "food"));
        jokes.add(new Joke(10, "I used to play piano by ear, but now I use my hands.", "music"));
    }

    public Joke getRandomJoke() {
        if (jokes.isEmpty()) return null;
        return jokes.get(rand.nextInt(jokes.size()));
    }

    public List<Joke> getAllJokes() { return jokes; }

    public Joke addJoke(String text, String category) {
        int id = jokes.stream().mapToInt(j -> j.id).max().orElse(0) + 1;
        if (category == null || category.trim().isEmpty()) category = "general";
        Joke joke = new Joke(id, text, category);
        jokes.add(joke);
        return joke;
    }

    public boolean removeJoke(int id) {
        return jokes.removeIf(j -> j.id == id);
    }

    public List<Joke> getByCategory(String category) {
        return jokes.stream().filter(j -> j.category.equalsIgnoreCase(category)).collect(Collectors.toList());
    }

    public List<String> getCategories() {
        return jokes.stream().map(j -> j.category).distinct().sorted().collect(Collectors.toList());
    }

    public void saveToFile(String filename) throws IOException {
        String json = jokes.stream().map(j -> String.format("{\"id\":%d,\"text\":\"%s\",\"category\":\"%s\"}", j.id, j.text, j.category))
                .collect(Collectors.joining(",", "[", "]"));
        Files.write(Paths.get(filename), json.getBytes());
    }

    public void loadFromFile(String filename) throws IOException {
        String json = new String(Files.readAllBytes(Paths.get(filename)));
        // Simple parsing (not using a JSON lib to keep dependency-free)
        jokes.clear();
        String[] items = json.substring(1, json.length()-1).split("\\},\\{");
        for (String item : items) {
            String clean = item.replace("{", "").replace("}", "");
            String[] fields = clean.split(",");
            int id = 0;
            String text = "", category = "";
            for (String f : fields) {
                String[] kv = f.split(":");
                if (kv.length == 2) {
                    String key = kv[0].trim().replace("\"", "");
                    String val = kv[1].trim().replace("\"", "");
                    if (key.equals("id")) id = Integer.parseInt(val);
                    else if (key.equals("text")) text = val;
                    else if (key.equals("category")) category = val;
                }
            }
            jokes.add(new Joke(id, text, category));
        }
    }

    private static void displayJoke(Joke joke) {
        if (joke == null) {
            System.out.println("No jokes available.");
            return;
        }
        System.out.printf("\n😂 Joke: %s\n", joke.text);
        if (joke.category != null && !joke.category.isEmpty())
            System.out.printf("📁 Category: %s\n", joke.category);
    }

    public static void main(String[] args) throws IOException {
        JokeGenerator gen = new JokeGenerator();
        Scanner scanner = new Scanner(System.in);
        System.out.println("=== Random Joke Generator ===");
        while (true) {
            System.out.println("\n1. Get a random joke");
            System.out.println("2. Show all jokes");
            System.out.println("3. Add a joke");
            System.out.println("4. Remove a joke");
            System.out.println("5. Filter jokes by category");
            System.out.println("6. Show categories");
            System.out.println("7. Save jokes to file");
            System.out.println("8. Load jokes from file");
            System.out.println("9. Exit");
            System.out.print("Choose: ");
            String choice = scanner.nextLine().trim();
            switch (choice) {
                case "1":
                    displayJoke(gen.getRandomJoke());
                    break;
                case "2":
                    List<Joke> all = gen.getAllJokes();
                    if (all.isEmpty()) System.out.println("No jokes.");
                    else {
                        System.out.println("\nAll jokes:");
                        for (Joke j : all)
                            System.out.printf("[%d] %s (%s)\n", j.id, j.text, j.category);
                    }
                    break;
                case "3":
                    System.out.print("Enter your joke: ");
                    String text = scanner.nextLine().trim();
                    if (text.isEmpty()) { System.out.println("Joke cannot be empty."); break; }
                    System.out.print("Category (optional): ");
                    String cat = scanner.nextLine().trim();
                    Joke joke = gen.addJoke(text, cat);
                    System.out.printf("Joke added with ID %d.\n", joke.id);
                    break;
                case "4":
                    System.out.print("Enter joke ID to remove: ");
                    int id = scanner.nextInt(); scanner.nextLine();
                    if (gen.removeJoke(id)) System.out.println("Joke removed.");
                    else System.out.println("Joke not found.");
                    break;
                case "5":
                    System.out.print("Enter category: ");
                    String catFilter = scanner.nextLine().trim();
                    List<Joke> filtered = gen.getByCategory(catFilter);
                    if (filtered.isEmpty())
                        System.out.printf("No jokes in category '%s'.\n", catFilter);
                    else {
                        System.out.printf("\nJokes in category '%s':\n", catFilter);
                        for (Joke j : filtered)
                            System.out.printf("[%d] %s\n", j.id, j.text);
                    }
                    break;
                case "6":
                    List<String> cats = gen.getCategories();
                    if (cats.isEmpty()) System.out.println("No categories.");
                    else System.out.println("Categories: " + String.join(", ", cats));
                    break;
                case "7":
                    System.out.print("Filename: ");
                    String fname = scanner.nextLine().trim();
                    gen.saveToFile(fname);
                    System.out.printf("Saved to %s.\n", fname);
                    break;
                case "8":
                    System.out.print("Filename: ");
                    fname = scanner.nextLine().trim();
                    gen.loadFromFile(fname);
                    System.out.printf("Loaded from %s.\n", fname);
                    break;
                case "9":
                    System.out.println("Goodbye! 😄");
                    scanner.close();
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }
}
