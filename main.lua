-- ============================================
-- VARIABLES GLOBALES - Variables que se usan en todo el programa
-- ============================================

-- El tablero del juego: una tabla 3x3 con números
-- 0 = casilla vacía, 1 = jugador (X), 2 = IA (O)
local board = {
    { 0, 0, 0 },
    { 0, 0, 0 },
    { 0, 0, 0 }
}

-- Quién tiene el turno: 1 = jugador, 2 = IA
local currentPlayer = 1

-- Estado del juego: "playing" = jugando, "win" = ganó alguien, "draw" = empate
local gameState = "playing"

-- Quién ganó (1 o 2). nil significa que nadie ha ganado todavía
local winner = nil

-- Tamaño de cada casilla en píxeles
local cellSize = 150

-- Espacio vacío alrededor del tablero en píxeles
local margin = 50

-- Tamaño total del tablero (ancho y alto)
local boardSize = cellSize * 3

-- Modo de juego: "ai" = contra la IA, "2player" = dos jugadores
local gameMode = "ai"

-- Símbolo del jugador: 1 = X, 2 = O (el jugador es X)
local playerSymbol = 1

-- ============================================
-- FUNCIÓN: resetGame()
-- Explicación: Reinicia el juego a su estado inicial
-- ============================================
local function resetGame()
    -- Vaciar todas las casillas del tablero (ponerlas a 0)
    board = {
        { 0, 0, 0 },
        { 0, 0, 0 },
        { 0, 0, 0 }
    }
    -- El jugador 1 (X) empieza siempre
    currentPlayer = 1
    -- Volvemos al estado de "jugando"
    gameState = "playing"
    -- No hay ganador todavía
    winner = nil
end

-- ============================================
-- FUNCIÓN: checkWin()
-- Explicación: Verifica si alguien ganó o si hay empate
-- Retorna: 1 si ganó X, 2 si ganó O, 0 si empate, nil si aún se juega
-- ============================================
local function checkWin()
    -- Revisar todas las filas (horizontales)
    for i = 1, 3 do
        -- Si los 3 elementos de una fila son iguales y no están vacíos
        if board[i][1] ~= 0 and board[i][1] == board[i][2] and board[i][2] == board[i][3] then
            return board[i][1] -- Retornar quién ganó
        end
        -- Revisar todas las columnas (verticales)
        if board[1][i] ~= 0 and board[1][i] == board[2][i] and board[2][i] == board[3][i] then
            return board[1][i] -- Retornar quién ganó
        end
    end

    -- Revisar la diagonal de arriba-izquierda a abajo-derecha
    if board[1][1] ~= 0 and board[1][1] == board[2][2] and board[2][2] == board[3][3] then
        return board[1][1]
    end
    -- Revisar la diagonal de arriba-derecha a abajo-izquierda
    if board[1][3] ~= 0 and board[1][3] == board[2][2] and board[2][2] == board[3][1] then
        return board[1][3]
    end

    -- Revisar si hay casillas vacías (loop anidado = dos bucles juntos)
    for i = 1, 3 do
        for j = 1, 3 do
            if board[i][j] == 0 then
                -- Si encontramos una casilla vacía, el juego aún continúa
                return nil
            end
        end
    end

    -- Si no hay casillas vacías ni ganador, es empate
    return 0
end

-- ============================================
-- FUNCIÓN: findWinningMove(player)
-- Explicación: Busca si hay un movimiento ganador para el jugador especificado
-- Parámetro: player = 1 (X) o 2 (O)
-- Retorna: fila, columna donde está el movimiento ganador (o nil si no hay)
-- ============================================
local function findWinningMove(player)
    -- Recorrer cada casilla del tablero
    for row = 1, 3 do
        for col = 1, 3 do
            -- Si la casilla está vacía
            if board[row][col] == 0 then
                -- Temporalmente colocar el símbolo del jugador aquí
                board[row][col] = player
                -- Verificar si esto causa una victoria
                local result = checkWin()
                -- Quitar el símbolo (restaurar la casilla a vacía)
                board[row][col] = 0
                -- Si este movimiento gana, retornar la posición
                if result == player then
                    return row, col
                end
            end
        end
    end
    -- Si no hay movimiento ganador, retornar nil (nada)
    return nil
end

-- ============================================
-- FUNCIÓN: getAIMove()
-- Explicación: Calcula el mejor movimiento para la IA
-- La IA sigue esta estrategia (en orden de prioridad):
-- 1. Ganar si puede
-- 2. Bloquear al jugador si está a punto de ganar
-- 3. Tomar el centro
-- 4. Tomar una esquina
-- 5. Tomar cualquier casilla disponible
-- ============================================
local function getAIMove()
    -- PASO 1: Intentar ganar
    local winRow, winCol = findWinningMove(2)
    if winRow then
        return winRow, winCol
    end

    -- PASO 2: Bloquear al jugador
    local blockRow, blockCol = findWinningMove(1)
    if blockRow then
        return blockRow, blockCol
    end

    -- PASO 3: Tomar el centro si está disponible (posición fuerte)
    if board[2][2] == 0 then
        return 2, 2
    end

    -- PASO 4: Tomar una esquina (posiciones estratégicas)
    -- Las esquinas son: (1,1), (1,3), (3,1), (3,3)
    for _, pos in ipairs({ { 1, 1 }, { 1, 3 }, { 3, 1 }, { 3, 3 } }) do
        if board[pos[1]][pos[2]] == 0 then
            return pos[1], pos[2]
        end
    end

    -- PASO 5: Tomar cualquier casilla disponible
    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == 0 then
                return row, col
            end
        end
    end

    -- Si no hay casillas disponibles, retornar nil
    return nil
end

-- ============================================
-- FUNCIÓN: love.load()
-- Explicación: Se ejecuta UNA SOLA VEZ al iniciar el juego
-- Aquí configuramos la ventana, fuentes y el estado inicial
-- ============================================
function love.load()
    -- Cambiar el título de la ventana
    love.window.setTitle("Tic Tac Toe")
    -- Establecer el tamaño de la ventana (ancho, alto)
    love.window.setMode(boardSize + margin * 2, boardSize + margin * 2 + 50)
    -- Establecer el tipo y tamaño de la fuente para el texto (24 píxeles)
    love.graphics.setFont(love.graphics.newFont(15))
    -- Inicializar el juego (vaciar el tablero)
    resetGame()
end

-- ============================================
-- FUNCIÓN: love.draw()
-- Explicación: Se ejecuta cada fotograma (~60 veces por segundo)
-- Aquí dibujamos todo lo que el jugador ve en pantalla
-- ============================================
function love.draw()
    -- Limpiar la pantalla con un color de fondo oscuro (RGB: 0.1, 0.1, 0.16)
    love.graphics.clear(0.1, 0.1, 0.16)

    -- Dibujar las líneas del tablero (la cuadrícula 3x3)
    love.graphics.setColor(1, 1, 1) -- Color blanco
    for i = 1, 2 do
        -- Grosor de las líneas: 6 píxeles
        love.graphics.setLineWidth(6)
        -- Líneas verticales (dividen las columnas)
        love.graphics.line(margin + i * cellSize, margin, margin + i * cellSize, margin + boardSize)
        -- Líneas horizontales (dividen las filas)
        love.graphics.line(margin, margin + i * cellSize, margin + boardSize, margin + i * cellSize)
    end

    -- Dibujar las X y O en cada casilla
    for row = 1, 3 do
        for col = 1, 3 do
            -- Obtener qué hay en esta casilla (0=vacía, 1=X, 2=O)
            local value = board[row][col]
            -- Calcular la posición en píxeles de esta casilla
            local x = margin + (col - 1) * cellSize
            local y = margin + (row - 1) * cellSize

            -- Si la casilla contiene X (1)
            if value == 1 then
                -- Color rojo para X
                love.graphics.setColor(0.92, 0.4, 0.4)
                love.graphics.setLineWidth(10) -- Grosor de línea
                -- Dibujar una X (dos líneas diagonales)
                love.graphics.line(x + 30, y + 30, x + cellSize - 30, y + cellSize - 30)
                love.graphics.line(x + cellSize - 30, y + 30, x + 30, y + cellSize - 30)
                -- Si la casilla contiene O (2)
            elseif value == 2 then
                -- Color azul para O
                love.graphics.setColor(0.4, 0.6, 0.96)
                love.graphics.setLineWidth(10)
                -- Dibujar un círculo en el centro de la casilla
                love.graphics.circle("line", x + cellSize / 2, y + cellSize / 2, cellSize / 2 - 30)
            end
        end
    end

    -- Dibujar el texto del mensaje (turno, ganador, empate, etc.)
    love.graphics.setColor(1, 1, 1) -- Color blanco
    local message = "Turno del Jugador X"
    -- Cambiar el mensaje según el estado del juego
    if gameState == "win" then
        message = string.format("¡El Jugador %s ganó!", winner == 1 and "X" or "O")
    elseif gameState == "draw" then
        message = "¡Empate!"
    elseif currentPlayer == 2 then
        if gameMode == "ai" then
            message = "Turno de la IA"
        else
            message = "Turno del Jugador O"
        end
    end

    -- Mostrar el mensaje en el centro, debajo del tablero
    love.graphics.printf(message, 0, boardSize + margin + 10, boardSize + margin * 2, "center")
    -- Mostrar instrucciones y modo de juego
    local modeText = gameMode == "ai" and "vs IA" or "2 Jugadores"
    love.graphics.printf(modeText .. " | Presiona R para reiniciar | Presiona A para cambiar modo", 0,
        boardSize + margin + 40,
        boardSize + margin * 2, "center")
end

-- ============================================
-- FUNCIÓN: love.mousepressed(x, y, button)
-- Explicación: Se ejecuta cuando el jugador hace clic con el mouse
-- Parámetros: x, y = posición del clic; button = botón del mouse (1=izquierdo)
-- ============================================
function love.mousepressed(x, y, button)
    -- Verificar si se hizo clic con el botón izquierdo y el juego está activo
    if button ~= 1 or gameState ~= "playing" then
        return -- Salir si no es el botón correcto o el juego terminó
    end

    -- Verificar si el clic está dentro del tablero
    if x < margin or x > margin + boardSize or y < margin or y > margin + boardSize then
        return -- Salir si hizo clic fuera del tablero
    end

    -- Convertir las coordenadas del clic a fila y columna del tablero
    -- math.floor redondea hacia abajo
    local col = math.floor((x - margin) / cellSize) + 1
    local row = math.floor((y - margin) / cellSize) + 1

    -- Si jugamos contra IA, solo permitir al jugador hacer clic en su turno
    if gameMode == "ai" and currentPlayer ~= playerSymbol then
        return
    end

    -- Si la casilla clickeada está vacía
    if board[row][col] == 0 then
        -- Colocar el símbolo del jugador actual en esa casilla
        board[row][col] = currentPlayer
        -- Verificar si alguien ganó o si hay empate
        local result = checkWin()

        if result == 1 or result == 2 then
            -- Alguien ganó
            gameState = "win"
            winner = result
        elseif result == 0 then
            -- Hay empate (tablero lleno sin ganador)
            gameState = "draw"
        else
            -- El juego continúa, cambiar de turno
            -- Truco: 3 - 1 = 2, 3 - 2 = 1 (alterna entre jugadores)
            currentPlayer = 3 - currentPlayer

            -- Si jugamos contra IA y es su turno
            if gameMode == "ai" and currentPlayer == 2 then
                -- Obtener el movimiento de la IA
                local aiRow, aiCol = getAIMove()
                if aiRow then
                    -- Colocar el símbolo de la IA en el tablero
                    board[aiRow][aiCol] = 2
                    -- Verificar si la IA ganó o hay empate
                    result = checkWin()

                    if result == 1 or result == 2 then
                        gameState = "win"
                        winner = result
                    elseif result == 0 then
                        gameState = "draw"
                    else
                        -- Turno del jugador de nuevo
                        currentPlayer = 1
                    end
                end
            end
        end
    end
end

-- ============================================
-- FUNCIÓN: love.keypressed(key)
-- Explicación: Se ejecuta cuando el jugador presiona una tecla
-- Parámetro: key = la tecla que se presionó ("r", "a", "escape", etc.)
-- ============================================
function love.keypressed(key)
    -- Si se presiona la tecla "R", reiniciar el juego
    if key == "r" then
        resetGame()
        -- Si se presiona la tecla "A", cambiar entre modo IA y 2 jugadores
    elseif key == "a" then
        -- Cambiar modo: si era "ai" pasa a "2player", sino a "ai"
        gameMode = gameMode == "ai" and "2player" or "ai"
        -- Reiniciar el juego con el nuevo modo
        resetGame()
    end
end
