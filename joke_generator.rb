# joke_generator.rb
require 'json'

class JokeGenerator
  def initialize
    @jokes = []
    load_default_jokes
  end

  def load_default_jokes
    @jokes = [
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
    ]
  end

  def random_joke
    @jokes.sample
  end

  def all_jokes
    @jokes
  end

  def add_joke(text, category = 'general')
    id = @jokes.map { |j| j[:id] }.max.to_i + 1
    joke = { id: id, text: text, category: category }
    @jokes << joke
    joke
  end

  def remove_joke(id)
    @jokes.reject! { |j| j[:id] == id }
  end

  def by_category(category)
    @jokes.select { |j| j[:category].downcase == category.downcase }
  end

  def categories
    @jokes.map { |j| j[:category] }.uniq.sort
  end

  def save_to_file(filename)
    File.write(filename, JSON.pretty_generate(@jokes))
  end

  def load_from_file(filename)
    data = File.read(filename)
    @jokes = JSON.parse(data, symbolize_names: true)
  rescue Errno::ENOENT
    puts "File not found."
  end

  def display_joke(joke)
    if joke.nil?
      puts "No jokes available."
      return
    end
    puts "\n😂 Joke: #{joke[:text]}"
    puts "📁 Category: #{joke[:category]}" if joke[:category]
  end
end

def main
  gen = JokeGenerator.new
  puts "=== Random Joke Generator ==="
  loop do
    puts "\n1. Get a random joke"
    puts "2. Show all jokes"
    puts "3. Add a joke"
    puts "4. Remove a joke"
    puts "5. Filter jokes by category"
    puts "6. Show categories"
    puts "7. Save jokes to file"
    puts "8. Load jokes from file"
    puts "9. Exit"
    print "Choose: "
    choice = gets.chomp.strip
    case choice
    when '1'
      gen.display_joke(gen.random_joke)
    when '2'
      jokes = gen.all_jokes
      if jokes.empty?
        puts "No jokes."
      else
        puts "\nAll jokes:"
        jokes.each { |j| puts "[#{j[:id]}] #{j[:text]} (#{j[:category]})" }
      end
    when '3'
      print "Enter your joke: "
      text = gets.chomp.strip
      if text.empty?
        puts "Joke cannot be empty."
        next
      end
      print "Category (optional): "
      cat = gets.chomp.strip
      cat = 'general' if cat.empty?
      joke = gen.add_joke(text, cat)
      puts "Joke added with ID #{joke[:id]}."
    when '4'
      print "Enter joke ID to remove: "
      id = gets.chomp.to_i
      if gen.remove_joke(id)
        puts "Joke removed."
      else
        puts "Joke not found."
      end
    when '5'
      print "Enter category: "
      cat = gets.chomp.strip
      jokes = gen.by_category(cat)
      if jokes.empty?
        puts "No jokes in category '#{cat}'."
      else
        puts "\nJokes in category '#{cat}':"
        jokes.each { |j| puts "[#{j[:id]}] #{j[:text]}" }
      end
    when '6'
      cats = gen.categories
      if cats.empty?
        puts "No categories."
      else
        puts "Categories: #{cats.join(', ')}"
      end
    when '7'
      print "Filename: "
      fname = gets.chomp.strip
      gen.save_to_file(fname)
      puts "Saved to #{fname}."
    when '8'
      print "Filename: "
      fname = gets.chomp.strip
      gen.load_from_file(fname)
      puts "Loaded from #{fname}."
    when '9'
      puts "Goodbye! 😄"
      break
    else
      puts "Invalid choice."
    end
  end
end

main if __FILE__ == $0
