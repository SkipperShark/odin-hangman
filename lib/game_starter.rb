require "json"
require "colorize"

# handles saving/loading/starting new games
class GameStarter
  include GameConstants
  NEW = "new".freeze
  LOAD = "load".freeze

  def initialize
    saves = Dir.children(SAVE_FOLDER_NAME).sort
    @save_options = saves.map.with_index(1) do |option, index|
      {
        filename: option,
        index: index
      }
    end
  end

  def start
    puts "Welcome to hangman!\n".colorize(:cyan)

    case user_choice
    when NEW
      new_game
    when LOAD
      initialize_game_if_no_save
      choice = load_option_choice
      save_raw_data = File.read("#{SAVE_FOLDER_NAME}/#{choice}")
      game = Game.from_json(save_raw_data)
      game.play
    end
  end

  private

  attr_reader :save_options

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
    show_save_options
    save_option_indexes = (0...save_options.length)
    input = gets.chomp.to_i
    index = input - 1
    return save_options[index][:filename] if save_option_indexes.include? index

    puts "That's not a valid option! Try again"
    load_option_choice
  end

  def show_save_options
    puts "which file would you like to load? Enter '1' if you would like to load save file (1)".colorize(:cyan)
    save_options.each do |option|
      puts "(#{option[:index]}) - #{option[:filename]}".colorize(:light_magenta)
    end
  end
end
