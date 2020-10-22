-- Tamano de pantalla
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--paddle speed
PADDLE_SPEED = 200

-- importa Clases
Class = require'class'
push = require 'push'

require 'Ball'
require 'Paddle'

-- Variable winner
winningPlayer = 0

-- Run when the game first start up, only once; used to initialize the game
function love.load()

    -- Genera randons numeros
    math.randomseed(os.time())
    -- Define figuras
    love.graphics.setDefaultFilter('nearest','nearest')
    
    -- Sounds 
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['point_scored'] = love.audio.newSource('sounds/score.wav','static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static')
    }

    -- fuente of the game
    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf',32)
    victoryFont = love.graphics.newFont('font.ttf',24)

    -- Score of the player
    player1Score = 0
    player2Score = 0

    -- Aleatoria playing server
    servingPlayer = math.random(2) == 1 and 1 or 2

    -- ball --
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5 )

    -- position of paddles
    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Game state
    gameState = 'start'

    -- Set up the screen
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

-- Controles and position
function love.update(dt)

    -- While playing
    if gameState == 'play' then

        -- point scores player 2   
        if ball.x <= 0 then
            sounds['point_scored']:play()
            player2Score = player2Score + 1
            servingPlayer = 2           
            ball:reset()
            ball.dx = 100
            -- Look for a winner
            if player2Score >=10 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
            
        end

        -- point scores player 1   
        if ball.x >= VIRTUAL_WIDTH - 4 then
            sounds['point_scored']:play()
            player1Score = player1Score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = -100
            -- Look for a winner
            if player1Score >=10 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
            
        end

        -- Ball colides with paddles 1
        if ball:collides(paddle1) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx
        end

        -- Ball colides with paddles 1
        if ball:collides(paddle2) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx
        end

        -- Ball colides with walls up
        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()
        end

        -- Ball colides with walls down
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wall_hit']:play()
        end

        -- Player 2 control 
        if ball.x >= VIRTUAL_WIDTH / 2 then
            if paddle2.y < ball.y - 2 then
                paddle2.dy = PADDLE_SPEED * 0.6
            elseif paddle2.y > ball.y + 2 then
                paddle2.dy = -PADDLE_SPEED * 0.6
            else
                paddle2.dy = 0
            end
        else
            paddle2.dy = 0
        end

    end

    -- ubication of the paddles
    paddle1:update(dt)
    paddle2:update(dt)

    -- Player 1 control 
    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    

    -- psition of the ball
    if gameState == 'play' then
        ball:update(dt)
    end

end

-- press keyboard
function love.keypressed(key)

    -- press esc to exit
    if key == 'escape' then
        love.event.quit()

    -- press enter to play
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player2Score = 0
            player1Score = 0 
        end
    end

end

-- Celled after update by LOVE, used to draw anythin to the screen
function love.draw()

    push:apply('start')

    -- Gray Screen
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    -- Draw ball
    ball:render()
    
    -- Draw the paddles
    paddle1:render()
    paddle2:render()
    
    -- Draw score in sreen
    displayScore()

    -- mensajes en pantalla
    -- Inicio
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to pong",0 , 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to play!", 0, 32, VIRTUAL_WIDTH, 'center')
    -- after player get a point
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player ".. tostring(servingPlayer).."'s turn!",0 , 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    -- when a player wins
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player ".. tostring(winningPlayer).." wins!",0 , 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to serve!", 0, 50, VIRTUAL_WIDTH, 'center')
    end

    displayFPS()

    push:apply('end')

end

-- display FPS
function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1,1,1,1)
end

-- Display scores
function displayScore()
    -- Define size of the font
    love.graphics.setFont(scoreFont)
    -- Draw Score
    love.graphics.print(player1Score,VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(player2Score,VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
end

-- size of the screen
function love.resize(w, h)
    push:resize(w,h)
end
