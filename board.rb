require './piece.rb'

class InvalidMoveError < Exception
end

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def setup_board
    8.times do |i|
      @grid[0][i] = Piece.new(:black) if i.odd?
      @grid[1][i] = Piece.new(:black) if i.even?
      @grid[2][i] = Piece.new(:black) if i.odd?

      @grid[5][i] = Piece.new(:white) if i.even?
      @grid[6][i] = Piece.new(:white) if i.odd?
      @grid[7][i] = Piece.new(:white) if i.even?
    end
  end

  def []=(pos, value)
    @grid[pos.first][pos.last] = value
  end

  def dup
    # Create a new board
    duped_board = Board.new

    # Generate same pieces to the dupped board
    @grid.each_with_index do |rows, r_idx|
      rows.each_with_index do |piece, c_idx|
        next if piece.nil?
        duped_board[[r_idx, c_idx]] = Piece.new(piece.color, piece.is_king)
      end
    end

    duped_board
  end

  # Not required???
  def valid_move_seq?(move_sequence)
    begin
      self.perform_moves!(move_sequence)
    rescue
      return false
    end
    true
  end

  def perform_moves!(move_sequence)
    # Needs at least two positions to make a move
    raise InvalidMoveError if move_sequence.count < 2

    # Dup the board, then perform test move sequence on the dupped board
    duped_board = self.dup
    if move_sequence.count == 2
      # Attempt slide first
      start_pos = move_sequence.first
      end_pos = move_sequence.last
      # debugger
      is_valid_move = duped_board.perform_slide(start_pos, end_pos)

      # Slide worked, so DO IT!
      if is_valid_move
        puts "Slided from #{start_pos} to #{end_pos}."
        self.perform_slide(start_pos, end_pos)
      else
        # debugger
        # Slide didn't work, attempting jump
        is_valid_move = duped_board.perform_jump(start_pos, end_pos)
        if is_valid_move
          puts "Jumped from #{start_pos} to #{end_pos}."
          self.perform_jump(start_pos, end_pos)
        else
          raise InvalidMoveError
        end
      end

    else
      # puts "Testing multi jumps sequence"
      # Must be a multi jump sequence, TEST IT!
      move_sequence.each_with_index do |move_pos, idx|
        # debugger
        next_move_pos = move_sequence[idx+1]
        next if next_move_pos.nil?

        is_valid_move = duped_board.perform_jump(move_pos, next_move_pos)
        raise InvalidMoveError unless is_valid_move
      end

      # Multi jump sequence are valid! Do it!
      puts "Performing multi-jumps sequence!"
      move_sequence.each_with_index do |move_pos, idx|
        next_move_pos = move_sequence[idx+1]
        next if next_move_pos.nil?

        self.perform_jump(move_pos, next_move_pos)
      end
      puts "Nice move!"
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
      jumps      =  [[-2, -2], [-2, 2], [2, -2], [2, 2]]
      target_pos =  [[-1, -1], [-1, 1], [1, -1], [1, 1]]
    elsif piece.color == :black
      jumps = [[2, -2], [2, 2]]
      target_pos = [[1, -1], [1, 1]]
    else
      jumps = [[-2, -2], [-2, 2]]
      target_pos = [[-1, -1], [-1, 1]]
    end

    # Translate diffs into actual positions
    jumps.map! do |d_row, d_col|
      [pos.first + d_row, pos.last + d_col]
    end
    target_pos.map! do |d_row, d_col|
      [pos.first + d_row, pos.last + d_col]
    end

    # Zip jumps and target_pos into pairs
    jump_target_pairs = jumps.zip(target_pos)
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

    slides = piece.slide_diffs

    # Translate diffs into actual positions
    slides.map do |slide_pos|
      [pos.first + slide_pos.first, pos.last + slide_pos.last]
    end.select do |slide_pos|
      self.in_bound?(slide_pos)
    end.select do |slide_pos|
      # Check if position is empty
      @grid[slide_pos.first][slide_pos.last].nil?
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