function DisplayChessboard()
  local chessboard = {
    "8 r n b q k b n r",
    "7 p p p p p p p p",
    "6 . . . . . . . .",
    "5 . . . . . . . .",
    "4 . . . . . . . .",
    "3 . . . . . . . .",
    "2 P P P P P P P P",
    "1 R N B Q K B N R",
    "  a b c d e f g h"
  }

  local white_square = '▓'
  local black_square = '░'

  local rows = 9
  local cols = 16
  for row = 1, rows do
    local current_row = ""
    for col = 1, cols do
      local piece = ""
      local square_color

      if row % 2 == col % 2 then
        square_color = white_square
      else
        square_color = black_square
      end

      local symbol = chessboard[row]:sub(col, col)

      if symbol == "." then
        piece = square_color
      else
        piece = symbol
      end

      current_row = current_row .. " " .. piece
    end

    print(current_row)
  end
end

vim.cmd("command! DisplayChessboard lua DisplayChessboard()")
