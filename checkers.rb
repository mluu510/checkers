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

  def dup
    # Create a new board
    duped_board = Board.new

    # Generate same pieces to the dupped board
    @grid.each_with_index do |rows, r_idx|
      rows.each_with_index do |piece, c_idx|
        next if piece.nil?
        duped_board[r_idx][c_idx] = Piece.new(piece.color, piece.is_king)
      end
    end

    duped_board
  end

  def perform_moves!(move_sequence)
    # Needs at least two positions to make a move
    Raise InvalidMoveError if move_sequence.count < 2

    # Dup the board, then perform test move sequence on the dupped board
    duped_board = self.dup

    # Test move sequence
    valid_move? = true
    move_sequence.each_with_index do |move_pos, idx|
      next_move_pos = move_sequence[idx+1]
      next if next_move_pos.nil?

      if move_sequence.count == 2
        valid_move? = duped_board.perform_slide(move_pos, next_move_pos)
      else
        valid_move? = duped_board.perform_jump(move_pos, next_move_pos)
      end
      Raise InvalidMoveError unless valid_move?
    end

    # Performing actual move sequence
    move_sequence.each_with_index do |move_pos, idx|
      next_move_pos = move_sequence[idx+1]
      next if next_move_pos.nil?

      if move_sequence.count == 2
        self.perform_slide(move_pos, next_move_pos)
      else
        self.perform_jump(move_pos, next_move_pos)
      end
    end
  end

  def perform_slide(start_pos, end_pos)
    possible_slides = self.slide_moves(start_pos)
    return false if possible_slides.none? do |possible_pos|
      end_pos == possible_pos
    end

    # Performing slide
    piece_to_move = @grid[start_pos.first][start_pos.last]
    @grid[start_pos.first][start_pos.last] = nil
    @grid[end_pos.first][end_pos.last] = piece_to_move

    self.maybe_promote(end_pos)
    true
  end

  def perform_jump(start_pos, end_pos)
    possible_jumps = self.jump_moves(start_pos)
    target_pos = nil
    return false if possible_jumps.none? do |jump_pos, enemy_pos|
      if end_pos == jump_pos
        target_pos = enemy_pos
        true
      end
    end

    # Performing jump
    piece_to_move = @grid[start_pos.first][start_pos.last]
    @grid[start_pos.first][start_pos.last] = nil
    @grid[end_pos.first][end_pos.last] = piece_to_move

    # Delete the target piece
    @grid[target_pos.first][target_pos.last] = nil

    self.maybe_promote(end_pos)
    true
  end

  def maybe_promote(piece_pos)
    # Get the piece
    piece = self.get_piece(piece_pos)
    # Black piece has reach the end of the board and needs to be promoted
    if piece.color == :black && piece_pos.first == 7
      piece.is_king = true
    elsif piece.color == :white && piece_pos.first == 0
      piece.is_king = true
    end
  end

  def get_piece(pos)
    @grid[pos.first][pos.last]
  end

  def jump_moves(pos)
    piece = @grid[pos.first][pos.last]
    raise StandardError.new("No piece found!") if piece.nil?

    # Generate diffs for jumps
    jumps = nil
    target_pos = nil
    if piece.is_king
      moves      =  [[-2, -2], [-2, 2], [2, -2], [2, 2]]
      target_pos =  [[-1, -1], [-1, 1], [1, -1], [1, 1]]
    elsif piece.color == :black
      moves = [[2, -2], [2, 2]]
      target_pos = [[1, -1], [1, 1]]
    else
      moves = [[-2, -2], [-2, 2]]
      target_pos = [[-1, -1], [-1, 1]]
    end

    # Translate diffs into actual positions
    moves.map! do |d_row, d_col|
      [pos.first + d_row, pos.last + d_col]
    end
    target_pos.map! do |d_row, d_col|
      [pos.first + d_row, pos.last + d_col]
    end

    # Zip jumps and target_pos into pairs
    jump_target_pairs = moves.zip(target_pos)
    # p jump_target_pairs

    # Filter out out possible moves
    jump_target_pairs.reject do |jump_pos, target_pos|
      target_piece = self.get_piece(target_pos)
      # Reject if jump is out of bound, target position is nempty or same color
      !self.in_bound?(jump_pos) || target_piece.nil? || target_piece.color == piece.color
    end
  end

  def slide_moves(pos)
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

    # Translate diffs into actual positions
    moves.map do |d_row, d_col|
      move = [pos.first + d_row, pos.last + d_col]
    end.select do |pos|
      self.in_bound?(pos)
    end.select do |pos|
      # Check if position is empty
      @grid[pos.first][pos.last].nil?
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

g = Board.new
g.render
# p g.slide_moves([2, 1])
g.perform_moves!([[2, 1], [3, 2]])
g.render
# p g.slide_moves([3, 2])
g.perform_slide([3, 2], [4, 1])
g.render
# p g.jump_moves([5, 0])
g.perform_jump([5, 0], [3, 2])
g.render
