local board = {
    { 0, 0, 0 },
    { 0, 0, 0 },
    { 0, 0, 0 }
}

local currentPlayer = 1     -- 1 = X, 2 = O
local gameState = "playing" -- "playing", "win", "draw"
local winner = nil
local cellSize = 150
local margin = 50
local boardSize = cellSize * 3

local function resetGame()
    board = {
        { 0, 0, 0 },
        { 0, 0, 0 },
        { 0, 0, 0 }
    }
    currentPlayer = 1
    gameState = "playing"
    winner = nil
end

local function checkWin()
    for i = 1, 3 do
        if board[i][1] ~= 0 and board[i][1] == board[i][2] and board[i][2] == board[i][3] then
            return board[i][1]
        end
        if board[1][i] ~= 0 and board[1][i] == board[2][i] and board[2][i] == board[3][i] then
            return board[1][i]
        end
    end

    if board[1][1] ~= 0 and board[1][1] == board[2][2] and board[2][2] == board[3][3] then
        return board[1][1]
    end
    if board[1][3] ~= 0 and board[1][3] == board[2][2] and board[2][2] == board[3][1] then
        return board[1][3]
    end

    for i = 1, 3 do
        for j = 1, 3 do
            if board[i][j] == 0 then
                return nil
            end
        end
    end

    return 0 -- draw
end

function love.load()
    love.window.setTitle("Tic Tac Toe")
    love.window.setMode(boardSize + margin * 2, boardSize + margin * 2+100)
    love.graphics.setFont(love.graphics.newFont(24))
    resetGame()
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.16)

    love.graphics.setColor(1, 1, 1)
    for i = 1, 2 do
        love.graphics.setLineWidth(6)
        love.graphics.line(margin + i * cellSize, margin, margin + i * cellSize, margin + boardSize)
        love.graphics.line(margin, margin + i * cellSize, margin + boardSize, margin + i * cellSize)
    end

    for row = 1, 3 do
        for col = 1, 3 do
            local value = board[row][col]
            local x = margin + (col - 1) * cellSize
            local y = margin + (row - 1) * cellSize

            if value == 1 then
                love.graphics.setColor(0.92, 0.4, 0.4)
                love.graphics.setLineWidth(10)
                love.graphics.line(x + 30, y + 30, x + cellSize - 30, y + cellSize - 30)
                love.graphics.line(x + cellSize - 30, y + 30, x + 30, y + cellSize - 30)
            elseif value == 2 then
                love.graphics.setColor(0.4, 0.6, 0.96)
                love.graphics.setLineWidth(10)
                love.graphics.circle("line", x + cellSize / 2, y + cellSize / 2, cellSize / 2 - 30)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    local message = "Player X's turn"
    if gameState == "win" then
        message = string.format("Player %s wins!", winner == 1 and "X" or "O")
    elseif gameState == "draw" then
        message = "Draw!"
    elseif currentPlayer == 2 then
        message = "Player O's turn"
    end

    love.graphics.printf(message, 0, boardSize + margin + 10, boardSize + margin * 2, "center")
    love.graphics.printf("Click a square to play. Press R to reset.", 0, boardSize + margin + 40, boardSize + margin * 2,
    "center")
end

function love.mousepressed(x, y, button)
    if button ~= 1 or gameState ~= "playing" then
        return
    end

    if x < margin or x > margin + boardSize or y < margin or y > margin + boardSize then
        return
    end

    local col = math.floor((x - margin) / cellSize) + 1
    local row = math.floor((y - margin) / cellSize) + 1

    if board[row][col] == 0 then
        board[row][col] = currentPlayer
        local result = checkWin()
        if result == 1 or result == 2 then
            gameState = "win"
            winner = result
        elseif result == 0 then
            gameState = "draw"
        else
            currentPlayer = 3 - currentPlayer
        end
    end
end

function love.keypressed(key)
    if key == "r" then
        resetGame()
    end
end
