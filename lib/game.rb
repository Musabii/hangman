# frozen_string_literal: true

require 'yaml'
# this is the class of the game
class Game
  private

  def initialize
    @dict = File.open('5desk.txt', 'r').readlines
    @word = get_word(5, 12)
    @correct_letters = @word.split('')
    @letters = Array.new(@word.length, '_')
    @guesses_made = []
    @guesses_left = 9
    load if File.exist?('yaml.dump')
    play
  end

  def continue?
    puts 'Please type \'123\' if you want to continue the last game you saved. (type anything else if you don\'t)'
    input = gets.chomp
    true if input == '123'
  end

  def ask_guess
    puts 'Please enter a single letter, or the word! (you can type \'123\' to save the game'
    letter = gets.chomp.downcase
    return letter if letter =~ /[A-Za-z]/ && (letter.length == @word.length || letter.length == 1) || letter == '123'

    ask_guess
  end

  def display_status
    puts @letters.join(' ')
    puts "You have #{@guesses_left} guesses left!"
    puts "Letters you've guessed before: #{@guesses_made.join(', ')}" unless @guesses_made.empty?
  end

  def play
    display_status
    guess = ask_guess
    p guess
    return save if guess == '123'
    return play if @guesses_made.include?(guess)

    update_letters(guess) if guess.length == 1
    @guesses_left -= 1
    return lose if @guesses_left.zero?
    return win if guess == @word || @letters == @correct_letters

    play
  end

  def win
    puts "Congrats you\'ve won!. The word was #{@word}"
  end

  def lose
    puts 'You\'re out of guesses genius! YOU LOST!'
    puts "The word was #{@word}"
  end

  def same_guess
    puts 'Please enter a letter you haven\'t before!'
    play
  end

  def update_letters(guess)
    @guesses_made << guess
    all = @correct_letters.each_index.select { |i| @correct_letters[i] == guess }
    all.each { |i| @letters[i] = guess }
  end

  def get_word(min, max)
    word = @dict[rand(@dict.size)].chomp
    return get_word(min, max) if word.length < min || word.length > max

    word
  end

  def save
    puts 'Saved'
    data = [@word, @correct_letters, @letters, @guesses_made, @guesses_left]
    File.open('yaml.dump', 'w') { |f| f.write(YAML.dump(data)) }
  end

  def load
    return unless continue?

    puts 'Loaded'
    data = YAML.safe_load(File.read('yaml.dump'))
    @word, @correct_letters, @letters, @guesses_made, @guesses_left = data
    File.delete('yaml.dump')
  end
end

Game.new
