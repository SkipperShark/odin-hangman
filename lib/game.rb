require "colorize"
require "json"

require_relative "game_constants"

# contains game logic for the hangman game
class Game
  include GameConstants

  attr_reader :clue, :num_lives_left, :secret_word

  def initialize(clue = nil, secret_word = nil, num_lives_left = nil)
    @filename = POSSIBLE_SECRETS_FILENAME
    @starting_num_lives = STARTING_NUM_LIVES

    raise StandardError, "words file not found!" unless File.exist? filename

    @num_lives_left = num_lives_left.nil? ? @starting_num_lives : num_lives_left
    @secret_word = secret_word.nil? ? secret_word_from_file : secret_word
    @clue = clue.nil? ? Array.new(@secret_word.length) : clue
  end

  def self.from_json(string)
    data = JSON.parse(string, { symbolize_names: true })
    new(data[:clue], data[:secret_word], data[:num_lives_left])
  end

  def play
    intro_message
    action = user_action

    if action[:is_save]
      save_game
      puts "game saved. See you soon!".colorize(:green)
      return
    end

    lose_a_life unless guess_correct action[:guess]
    display_clue

    if game_won
      puts "You won! Congratulations".colorize(:yelow)
      return
    end

    if game_lost
      puts "You lost! Sadlife".colorize(:yellow)
      return
    end

    play
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

  attr_accessor :filename
  attr_writer :clue, :secret_word, :num_lives_left

  def intro_message
    puts "Secret word : #{secret_word}"
    display_clue
    puts "lives left : #{num_lives_left}\n------------------------------\n\n"
  end

  def save_game
    dirname = "saves"
    FileUtils.mkdir_p dirname
    save_filename = Time.now.strftime("%Y-%m-%d %H-%M-%S")
    save_obj = JSON.dump({
      clue: clue,
      num_lives_left: num_lives_left,
      secret_word: secret_word
    })
    filepath = "#{dirname}/#{save_filename}.json"
    File.write(filepath, save_obj)
  end

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
    puts "Enter the letter of your guess. Enter 'save' if you would like to save".colorize(:green)
    input = gets.chomp.downcase
    return { is_save: true, guess: nil } if input == "save"
    return { is_save: false, guess: input } if input.match("^[a-zA-Z]{1}$")

    puts "That is not a valid letter! Please try again.".colorize(:red)
    user_action
  end

  def display_clue
    print "Clue : ".colorize(:green)
    clue.each do |letter|
      if letter.nil?
        print "_ ".colorize(:green)
      else
        print "#{letter} ".colorize(:green)
      end
    end
    puts "\n"
  end
end
