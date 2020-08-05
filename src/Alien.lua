--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Alien = Class{}

function Alien:init(world, type, x, y, userData)
    self.rotation = 0

    self.world = world
    self.type = type or 'square'

    self.body = love.physics.newBody(self.world, 
        x or math.random(VIRTUAL_WIDTH), y or math.random(VIRTUAL_HEIGHT - 35),
        'dynamic')

    -- different shape and sprite based on type passed in
    if self.type == 'square' then
        self.shape = love.physics.newRectangleShape(35, 35)
        self.sprite = math.random(5)
    else
        self.shape = love.physics.newCircleShape(17.5)
        self.sprite = 9
    end

    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(userData)

    -- used to keep track of despawning the Alien and flinging it
    self.launched = false

    -- used to keep track of whether the alien has split yet
    self.canSplit = true

    self.children = {}
end

function Alien:render()
    love.graphics.draw(gTextures['aliens'], gFrames['aliens'][self.sprite],
        math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(),
        1, 1, 17.5, 17.5)

    -- render child aliens (spawned via splitting)
    for k, alien in pairs(self.children) do
        alien:render()
    end
end

function Alien:split()
    gSounds['split']:play()
    self.canSplit = false
    
    for i = 1, 2 do
    self.children[i] = Alien(self.world, self.type, 
        self.body:getX(), self.body:getY(), 'Player')
    end
    
    return
end