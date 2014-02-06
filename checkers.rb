require 'debugger'
require 'colorize'
require './board.rb'

class InvalidMoveError < Exception
end

class Checkers
  def initialize
    @board = Board.new
    @board.setup_board
    @player1 = HumanPlayer.new
    @player2 = HumanPlayer.new
    @current_player = player1
    puts "Welcome to Checkers. Let's play!"
    self.play
  end

  def play
    while true
      @board.render
      puts "#{@current_player.color}'s turn. Enter your move sequence."
      move_sequence = @current_player.get_move_sequence
      begin
        @board.perform_moves(move_sequence)
      rescue
        puts "Invalid move sequence! Please try again."
        move_sequence = @current_player.get_move_sequence
        @board.perform_moves(move_sequence)
      end
    end
  end

end

class Player
  def initialize(color)
    raise StandardError.new("Invalid color!") if color != :black || color != :white

    @color = color
  end

  def color
    if @color == :black
      'Black'
    else
      'White'
    end
  end
end

class HumanPlayer
  def get_move_sequence
    move_sequence = gets.chomp.split(' ').map do |pos_str|
      pos_str.split(',')
    end
    p move_sequence
    move_sequence
  end
end

board = Board.new
board.setup_board
board.render
board.perform_moves!([[2, 1], [3, 2]])
board.render
board.perform_moves!([[3, 2], [4, 1]])
board.render
board.perform_moves!([[1, 0], [2, 1]])
board.render
board.perform_moves!([[5, 0], [3, 2], [1,0]])
board.render
# p g.perform_jump([1, 0], [3, 2]) # Test invalid move case

