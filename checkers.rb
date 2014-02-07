require 'debugger'
require 'colorize'
require './board.rb'

class Checkers
  def initialize
    @board = Board.new
    @board.setup_board
    @player1 = HumanPlayer.new(:black)
    @player2 = HumanPlayer.new(:white)
    @current_player = @player1
    puts "Welcome to Checkers. Let's play!"
    self.play
  end

  def play
    while true
      begin
        @board.render

        # Get player's move sequence
        puts "#{@current_player.color_str}'s turn. Enter your move sequence."
        move_sequence = @current_player.get_move_sequence

        # Check of selected piece belongs to current player
        selected_piece = @board.get_piece(move_sequence.first)
        while true
          if selected_piece.nil?
            puts "Cannot find a piece at that location! Try again."
          elsif selected_piece.color != @current_player.color
            puts "That is not your piece! Try again."
          else
            break
          end
          move_sequence = @current_player.get_move_sequence
          selected_piece = @board.get_piece(move_sequence.first)
        end

        # Perform move sequence
        @board.perform_moves!(move_sequence)

        # Swap players
        if @current_player == @player1
          @current_player = @player2
        else
          @current_player = @player1
        end

      rescue Exception => e
        # puts e.message
        puts "Invalid move sequence! Please try again."
        move_sequence = @current_player.get_move_sequence
        @board.perform_moves!(move_sequence)

        # Swap players
        if @current_player == @player1
          @current_player = @player2
        else
          @current_player = @player1
        end
        retry
      end
    end
  end
end

class Player
  attr_reader :color
  def initialize(color)
    raise StandardError.new("Invalid color!") if color != :black && color != :white

    @color = color
  end

  def color_str
    if @color == :black
      'Black'
    else
      'White'
    end
  end
end

class HumanPlayer < Player
  # def initialize(color)
  #   super(color)
  # end

  def get_move_sequence
    move_sequence = gets.chomp.split(' ').map do |pos_str|
      pos_str.split(',').map do |value|
        value.to_i
      end
    end
    # p move_sequence
    move_sequence
  end
end

# board = Board.new
# board.setup_board
# board.render
# board.perform_moves!([[2, 1], [3, 2]])
# board.render
# board.perform_moves!([[3, 2], [4, 1]])
# board.render
# board.perform_moves!([[1, 0], [2, 1]])
# board.render
# board.perform_moves!([[5, 0], [3, 2], [1,0]])
# board.render

checker = Checkers.new
checker.play



