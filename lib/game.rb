# contains game logic for the hangman game
class Game
  def initialize(filename)
    raise StandardError, "words file not found!" unless File.exist? filename

    @words = File.open(filename, "r").readlines
    @filtered_words = words.filter { |w| w.length < 12 && w.length > 5 }

    @secret_word = filtered_words.sample.strip
    @clue = Array.new(secret_word.length)

    puts "words.length : #{words.length}"
    puts "filtered_words.length : #{filtered_words.length}"
    puts "secret_word.length : #{secret_word.length}"
    pp "secret word : #{secret_word}"
    puts "Welcome to hangman!\n\n"
    puts "Secret word : #{secret_word}"
    display_clue
  end

  def guess_letter
    nil
  end

  private

  def display_clue
    print "Clue : "
    clue.each do |letter|
      if letter.nil?
        print "_ "
      else
        print "#{letter} "
      end
    end
    puts "\n"
  end

  attr_accessor :words, :filtered_words, :secret_word, :clue
end
