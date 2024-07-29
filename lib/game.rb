require "colorize"

# contains game logic for the hangman game
class Game
  def initialize(filename)
    raise StandardError, "words file not found!" unless File.exist? filename

    @filename = filename
    @starting_num_lives = 8
    @num_lives_left = @starting_num_lives

    @secret_word = secret_word_from_file
    @clue = Array.new(secret_word.length)

    puts "Welcome to hangman!\n\n"
    puts "Secret word : #{secret_word}"
    display_clue
  end

  def play
    until game_won
      action = user_action
      if action[:is_save] == true
        puts "user wants to save"
        return
      end
      lose_a_life unless guess_correct action[:guess]
      display_clue
      if game_lost
        puts "You lost! Sadlife"
        return
      end
      puts "lives left : #{num_lives_left}\n------------------------------\n\n"
    end
    puts "You won! Congratulations"
  end

  def guess_correct(guess_letter)
    letter_in_secret_word = false
    secret_word.chars.each_with_index do |letter, index|
      if letter == guess_letter
        clue[index] = letter
        letter_in_secret_word = true
      end
    end
    letter_in_secret_word
  end

  private

  def game_won
    clue.none?(&:nil?)
  end

  def game_lost
    num_lives_left <= 0
  end

  def secret_word_from_file
    words = File.open(filename, "r").readlines
    filtered_words = words.filter { |w| w.length < 12 && w.length > 5 }
    filtered_words.sample.strip.downcase
  end

  def lose_a_life
    self.num_lives_left -= 1
    puts "That is not in the secret, you lost a life!".colorize(:red)
  end

  def user_action
    puts "Enter the letter of your guess. Enter #{'save'.colorize(:green)} if you would like to save"
    input = gets.chomp.downcase
    return { is_save: true, guess: nil } if input == "save"
    return { is_save: false, guess: input } if input.match("^[a-zA-Z]{1}$")

    puts "That is not a valid letter! Please try again.".colorize(:red)
    user_action
  end

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

  attr_accessor :secret_word, :clue, :num_lives, :num_lives_left, :filename
end