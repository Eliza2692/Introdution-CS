-- Instancia la classe
Player = Class{}

-- clases / class
require 'Animation'

-- variables / variable
local MOVE_SPEED = 80
local  JUMP_VELOCITY = 400
local GRAVITY = 40

-- Iniciar clase / Init class
function Player:init(map)
    -- dimensiones / dimension
    self.width = 16
    self.height = 20
    -- posicion / position
    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

    -- velocidad gravedad / gravity velocity
    self.dx = 0
    self.dy = 0

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

    self.state = 'idle'
    self.direction = 'right'
    
    self.animations = {
        ['idle'] = Animation{
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1
        },
        ['walking'] = Animation{
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['jumping'] = Animation{
            texture = self.texture,
            frames = {
                self.frames[3]
            },
            interval = 1
        }
    }

    self.animation = self.animations['idle']

    self.behaviors = {
        ['idle'] = function(dt)
            -- saltando / jumping
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            -- mueve izquierda / move left
            elseif love.keyboard.isDown('a') then
                self.dx = - MOVE_SPEED 
                self.state = 'walking'
                self.animation = self.animations['walking']
                self.direction = 'left'
            -- mueve derecha / move right
            elseif love.keyboard.isDown('d') then
                self.dx = MOVE_SPEED
                self.state = 'walking'
                self.animation = self.animations['walking']
                self.direction = 'right'      
            -- no se mueve / stop
            else
                self.animation = self.animations['idle']
            end
        end,
        ['walking'] = function(dt)
            -- saltando / jumping
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            -- mueve izquierda / move left
            elseif love.keyboard.isDown('a') then
                self.dx = - MOVE_SPEED
                self.animation = self.animations['walking']
                self.direction = 'left'
            -- mueve derecha / move right
            elseif love.keyboard.isDown('d') then
                self.dx = MOVE_SPEED
                self.animation = self.animations['walking']
                self.direction = 'right'
            -- no se mueve / stop
            else
                self.animation = self.animations['idle']
            end
        end,

        ['jumping'] = function(dt)    
            -- mueve izquierda / move left
            if love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = - MOVE_SPEED
            -- mueve derecha / move right
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
            else
                self.animation = self.animations['idle']
            end
            
            -- gravedad / gravity
            self.dy = self.dy + GRAVITY

            -- aterrizaje despues de saltar / landing after jump
            if self.y >= map.tileHeight * (map.mapHeight / 2 - 1) - self.height then
                self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations[self.state]
            end
            
        end
    }
end

-- Actualizar jugador / update player
function Player:update(dt)

    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.getCurrentFrame = self.animation:getCurrentFrame()

    self.x = self.x + self.dx * dt

    -- if we have negative y velocity (jumping), check if we collide
    -- with any blocks above us
    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y) ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y) ~= TILE_EMPTY then
            -- reset y velocity
            self.dy = 0

            if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
            end
            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
            end
        end
    end
    
end

-- dibujar jugador / draw player
function Player:render()

    local scaleX

    -- dibuja animacion y volte si va a la derecha / draw animation and flip if is going to right
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), 0, scaleX, 1, self.width / 2, self.height / 2)
end