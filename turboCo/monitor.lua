-- This file is intended to provide extensions to the terminal (term) API of computercraft
-- The intention is to create commonly used utility functions that computercraft somehow does not provide

--Sets cursor to the beggining of the next line
function setCursorToNewLine(screen)
  local x,y = screen.getCursorPos()
  screen.setCursorPos(1, y+1)
end

--Sets cursor to the beggining of the next line after writing
function writeLn(screen, text)
  screen.write(text)
  setCursorToNewLine(screen)
end

--Writes centered text for a monitor of any size, then enter a new line
function writeCenterLn(screen, text)
  local width,height = screen.getSize()
  local textSize = string.len(text)
  local emptySpace = width - textSize
  print(emptySpace)
  if emptySpace >= 0 then
    startingX = emptySpace / 2
    print(startingX)
    monitor.setCursorPos(startingX, height)
  end
  writeLn(screen, text)
end

