// joke_generator.go
package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"
)

type Joke struct {
	ID       int    `json:"id"`
	Text     string `json:"text"`
	Category string `json:"category"`
}

type JokeGenerator struct {
	jokes []Joke
}

func NewJokeGenerator() *JokeGenerator {
	g := &JokeGenerator{}
	g.loadDefaultJokes()
	return g
}

func (g *JokeGenerator) loadDefaultJokes() {
	g.jokes = []Joke{
		{1, "Why don't scientists trust atoms? Because they make up everything!", "science"},
		{2, "What do you call a fake noodle? An impasta!", "food"},
		{3, "Why did the scarecrow win an award? Because he was outstanding in his field!", "pun"},
		{4, "I'm reading a book on anti-gravity. It's impossible to put down!", "book"},
		{5, "What's the best thing about Switzerland? I don't know, but the flag is a big plus!", "geography"},
		{6, "Why do programmers prefer dark mode? Because light attracts bugs!", "programming"},
		{7, "I told my wife she was drawing her eyebrows too high. She looked surprised.", "marriage"},
		{8, "What do you call a bear with no teeth? A gummy bear!", "animal"},
		{9, "Why don't eggs tell jokes? They'd crack each other up!", "food"},
		{10, "I used to play piano by ear, but now I use my hands.", "music"},
	}
}

func (g *JokeGenerator) GetRandomJoke() *Joke {
	if len(g.jokes) == 0 {
		return nil
	}
	return &g.jokes[rand.Intn(len(g.jokes))]
}

func (g *JokeGenerator) GetAllJokes() []Joke {
	return g.jokes
}

func (g *JokeGenerator) AddJoke(text, category string) Joke {
	id := 1
	if len(g.jokes) > 0 {
		id = g.jokes[len(g.jokes)-1].ID + 1
	}
	if category == "" {
		category = "general"
	}
	joke := Joke{ID: id, Text: text, Category: category}
	g.jokes = append(g.jokes, joke)
	return joke
}

func (g *JokeGenerator) RemoveJoke(id int) bool {
	for i, j := range g.jokes {
		if j.ID == id {
			g.jokes = append(g.jokes[:i], g.jokes[i+1:]...)
			return true
		}
	}
	return false
}

func (g *JokeGenerator) GetByCategory(category string) []Joke {
	var result []Joke
	for _, j := range g.jokes {
		if strings.EqualFold(j.Category, category) {
			result = append(result, j)
		}
	}
	return result
}

func (g *JokeGenerator) GetCategories() []string {
	m := make(map[string]bool)
	for _, j := range g.jokes {
		m[j.Category] = true
	}
	var cats []string
	for k := range m {
		cats = append(cats, k)
	}
	return cats
}

func (g *JokeGenerator) SaveToFile(filename string) error {
	data, err := json.MarshalIndent(g.jokes, "", "  ")
	if err != nil {
		return err
	}
	return ioutil.WriteFile(filename, data, 0644)
}

func (g *JokeGenerator) LoadFromFile(filename string) error {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return err
	}
	return json.Unmarshal(data, &g.jokes)
}

func displayJoke(j *Joke) {
	if j == nil {
		fmt.Println("No jokes available.")
		return
	}
	fmt.Printf("\n😂 Joke: %s\n", j.Text)
	if j.Category != "" {
		fmt.Printf("📁 Category: %s\n", j.Category)
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())
	gen := NewJokeGenerator()
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== Random Joke Generator ===")
	for {
		fmt.Println("\n1. Get a random joke")
		fmt.Println("2. Show all jokes")
		fmt.Println("3. Add a joke")
		fmt.Println("4. Remove a joke")
		fmt.Println("5. Filter jokes by category")
		fmt.Println("6. Show categories")
		fmt.Println("7. Save jokes to file")
		fmt.Println("8. Load jokes from file")
		fmt.Println("9. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			joke := gen.GetRandomJoke()
			displayJoke(joke)
		case "2":
			jokes := gen.GetAllJokes()
			if len(jokes) == 0 {
				fmt.Println("No jokes.")
			} else {
				fmt.Println("\nAll jokes:")
				for _, j := range jokes {
					fmt.Printf("[%d] %s (%s)\n", j.ID, j.Text, j.Category)
				}
			}
		case "3":
			fmt.Print("Enter your joke: ")
			scanner.Scan()
			text := strings.TrimSpace(scanner.Text())
			if text == "" {
				fmt.Println("Joke cannot be empty.")
				continue
			}
			fmt.Print("Category (optional): ")
			scanner.Scan()
			cat := strings.TrimSpace(scanner.Text())
			joke := gen.AddJoke(text, cat)
			fmt.Printf("Joke added with ID %d.\n", joke.ID)
		case "4":
			fmt.Print("Enter joke ID to remove: ")
			scanner.Scan()
			idStr := strings.TrimSpace(scanner.Text())
			id, err := strconv.Atoi(idStr)
			if err != nil {
				fmt.Println("Invalid ID.")
				continue
			}
			if gen.RemoveJoke(id) {
				fmt.Println("Joke removed.")
			} else {
				fmt.Println("Joke not found.")
			}
		case "5":
			fmt.Print("Enter category: ")
			scanner.Scan()
			cat := strings.TrimSpace(scanner.Text())
			jokes := gen.GetByCategory(cat)
			if len(jokes) == 0 {
				fmt.Printf("No jokes in category '%s'.\n", cat)
			} else {
				fmt.Printf("\nJokes in category '%s':\n", cat)
				for _, j := range jokes {
					fmt.Printf("[%d] %s\n", j.ID, j.Text)
				}
			}
		case "6":
			cats := gen.GetCategories()
			if len(cats) == 0 {
				fmt.Println("No categories.")
			} else {
				fmt.Println("Categories:", strings.Join(cats, ", "))
			}
		case "7":
			fmt.Print("Filename: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			err := gen.SaveToFile(fname)
			if err != nil {
				fmt.Println("Error saving:", err)
			} else {
				fmt.Printf("Saved to %s.\n", fname)
			}
		case "8":
			fmt.Print("Filename: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			err := gen.LoadFromFile(fname)
			if err != nil {
				fmt.Println("Error loading:", err)
			} else {
				fmt.Printf("Loaded from %s.\n", fname)
			}
		case "9":
			fmt.Println("Goodbye! 😄")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
