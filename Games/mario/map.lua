-- importar clases / import class 
require 'Util'
require 'Player'

-- Instancia la classe
Map = Class{}

-- nombre de imagenes / pictures name
TILE_BRICK = 1
TILE_EMPTY = 4

-- Clouds / nubes
CLOUD_LEFT = 6
CLOUD_RIGHT = 7

-- Arbustos / Bush
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- Hongos / Mushroom
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- Saltos / Jump block
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

-- Velocidad de la pantalla / scroll screen
local SCROLL_SPEED = 62

-- Iniciar clase / Init class
function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}
    --Jugadores / players
    self.player = Player(self)
    -- camara / camera
    self.xcam = 0
    self.ycam = 0
    -- genera squad para cada losa / generate quads for evry tiles
    self.sprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    -- Genera tile para el movimiento de la camera / generate tiles for the camera moves
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- llenar en mapa con tiles vacios / filing the map with empty tile
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- Crear randoms niveles / create random leves
    local x = 1

    while x < self.mapWidth do

        -- Genera nubes / 2% generate a cloud
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                -- escoge un punto donde ubicar nube / choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 -6)
                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x+1, cloudStart, CLOUD_RIGHT)
            end
        end

        -- Genera hongos / 5% generate a mushroom
        if math.random(20) == 1 then
            -- lado izquierdo del tubo / left side of pipe
            self:setTile(x, self.mapHeight / 2 -2, MUSHROOM_TOP )
            self:setTile(x, self.mapHeight / 2 -1, MUSHROOM_BOTTOM )

            -- inicio del mapa llenado con ladrillos / halfway map populates with bricks
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- next vertical scan line
            x = x + 1
        
        -- arbusto / 10% probability of generate bush
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then 
            local  bushLevel = self.mapHeight / 2 - 1

            -- arbusto y luego columna / place the bush
            self:setTile(x,bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            -- next vertical scan line
            x = x + 1

            -- arbusto y luego columna / place the bush
            self:setTile(x,bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            -- next vertical scan line
            x = x + 1

        -- vacio / 10% chance to dont generate anything
        elseif math.random(10) ~= 1 then

            -- create column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            if math.random(15) == 1 then
                -- escoge un punto donde ubicar nube / choose a random vertical spot above where blocks/pipes generate
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            -- next vertical scan line
            x = x + 1

        else
            x = x + 2
        end

    end

end

-- Define nombre de las figuras / Define tile
function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

-- obtienes las cooredenadas de las lozas / get tiles tyoe a oixel coordinate
function Map:tileAt(x, y)
   return self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1) 
end

-- Define nombre de las figuras / Define tile
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- Actualizar mapa / update map
function Map:update(dt)

    -- mueve 
    self.xcam = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2, math.min(self.mapWidthPixels - VIRTUAL_WIDTH,self.player.x)))

    -- actualiza jugador / update player
    self.player:update(dt)
end

-- Dibujar mapa / draw map
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.sprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

    -- dibujar jugador / draw player
    self.player:render()
end