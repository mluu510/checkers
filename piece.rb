class Piece
  attr_reader :color
  attr_accessor :is_king
  def initialize(color, is_king=false)
    @color, @is_king = color, is_king
  end

  def slide_diffs
    if self.is_king
      [[-1, -1], [-1, 1], [1, -1], [1, 1]]
    elsif self.color == :black
      [[1, -1], [1, 1]]
    else
      [[-1, -1], [-1, 1]]
    end
  end

  def jump_diffs
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

    jumps.zip(target_pos)
  end

  def to_s
    if color == :black
      'B'
    else
      'W'
    end
  end
end