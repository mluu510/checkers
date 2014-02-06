require 'colorize'

class Piece
  attr_reader :color
  attr_accessor :is_king
  def initialize(color, is_king=false)
    @color, @is_king = color, is_king
  end

  def to_s
    if color == :black
      'B'
    else
      'W'
    end
  end
end

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
    self.setup_board
  end

  def setup_board
    8.times do |i|
      @grid[0][i] = Piece.new(:black) if i.odd?
      @grid[1][i] = Piece.new(:black) if i.even?
      @grid[2][i] = Piece.new(:black) if i.odd?
      # @grid[3][i] = Piece.new(:black) if i.even?

      @grid[5][i] = Piece.new(:white) if i.even?
      @grid[6][i] = Piece.new(:white) if i.odd?
      @grid[7][i] = Piece.new(:white) if i.even?
      # @grid[4][i] = Piece.new(:black) if i.even?
    end
  end

  def perform_slide
  end

  def perform_jump
  end

  def move_diffs(pos)
    piece = @grid[pos.first][pos.last]
    raise StandardError.new("No piece found!") if piece.nil?
    moves = nil
    if piece.is_king
      moves = [[-1, -1], [-1, 1], [1, -1], [1, 1]]
    elsif piece.color == :black
      moves = [[1, -1], [1, 1]]
    else
      moves = [[-1, -1], [-1, 1]]
    end
    moves.map do |d_row, d_col|
      move = [pos.first + d_row, pos.last + d_col]
    end.select do |move|
      self.in_bound?(move)
    end
  end

  def in_bound?(pos)
    pos.each do |value|
      return false if value < 0 || value > 7
    end
    true
  end

  def render
    labels = "  0 1 2 3 4 5 6 7".blue
    puts labels
    @grid.each_with_index do |rows, r_idx|
      str = "#{r_idx} ".blue
      rows.each_with_index do |piece, c_idx|
        if piece
          str += "#{piece} "
        else
          if (r_idx + c_idx).odd?
            str += "- "
          else
            str += "  "
          end
        end
      end
      puts str + "#{r_idx}".blue
    end
    puts labels
  end
end

class Checkers
  def initialize
    @board = Board.new
  end
end

Board.new.render