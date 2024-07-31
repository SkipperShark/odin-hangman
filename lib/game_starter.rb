require "json"
require "colorize"

# handles saving/loading/starting new games
class GameStarter
  include GameConstants
  NEW = "new".freeze
  LOAD = "load".freeze

  def start
    puts "Welcome to hangman!\n".colorize(:cyan)

    case user_choice
    when NEW
      new_game
    when LOAD
      initialize_game_if_no_save
      choice = load_option_choice
      data = File.read("#{SAVE_FOLDER_NAME}/#{choice}")
      puts "data : #{data}"
      puts "data.class : #{data.class}"
      obj = JSON.parse(data)
      puts "obj : #{obj}"
      puts "obj.class : #{obj.class}"
      puts "obj.clue : #{obj.clue}"
    end
  end

  private

  def user_choice
    puts "new/load?".colorize(:cyan)
    input = gets.chomp.downcase
    return input if [NEW, LOAD].include?(input)

    puts "That is not valid option, please try again".colorize(:red)
    user_choice
  end

  def new_game
    Game.new.play
  end

  def no_save_file
    !Dir.exist?("saves") || Dir.empty?("saves")
  end

  def initialize_game_if_no_save
    return unless no_save_file

    puts "no save files found! Starting new game\n\n".colorize(:cyan)
    new_game
  end

  def load_option_choice
    puts "which file would you like to load? Enter '1' if you would like to load save file (1)".colorize(:cyan)
    options = Dir.children(SAVE_FOLDER_NAME)
    options.each.with_index(1) do |option, index|
      puts "(#{index}) - #{option}".colorize(:light_magenta)
    end
    input = gets.chomp.to_i
    index = input - 1
    return options[index] if (0...options.length).include? index

    puts "That's not a valid option! Try again"
    load_option_choice
  end
end
