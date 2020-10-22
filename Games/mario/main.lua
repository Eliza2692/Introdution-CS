-- MARIO

-- Variables globales / Global variable

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Clases / class

Class = require 'class'
push = require 'push'
require 'Util'
require 'Map'

-- mapa / map
map = Map()

-- Cargar Juego / Load Game
function love.load()
    
    -- genera el mismo pantalla / genera la misma pantalla
    math.randomseed(os.time())

    -- definir dibujos / clear up pixeles
    love. graphics.setDefaultFilter('nearest', 'nearest')

    -- definir pantalla / setup screen
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true
    })

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- cambiar tamano pantalla / resize window
function love.resize(w, h)
    push:resize(w, h)
end

-- soltar tecla / release key
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    love.keyboard.keysPressed[key] = true
end

-- tecla fue presionada
function love.keyboard.wasPressed(key)

    return love.keyboard.keysPressed[key]
    
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- presionar tecla / press key
function love.keyboard.wasReleased(key)
    
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- Actualizar juego / Update game
function love.update(dt)

    -- Actualizar mapa / Update map
    map:update(dt)

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

end

-- dibujar juego / draw game
function love.draw()
    
    push:apply('start')

    -- movimiento de pantalla / move pantalla
    love.graphics.translate(math.floor(-map.xcam + 0.5), math.floor(-map.ycam + 0.5))

    -- pantalla color azul / blue screen
    love.graphics.clear(108/255, 140/255, 1, 1)

    -- dibujar mapa / draw map
    map:render()

    push:apply('end')
end