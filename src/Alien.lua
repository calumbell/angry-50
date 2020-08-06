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

    self.size = 35

    -- different shape and sprite based on type passed in
    if self.type == 'square' then
        self.shape = love.physics.newRectangleShape(self.size, self.size)
        self.sprite = math.random(5)
    else
        self.shape = love.physics.newCircleShape(self.size/2)
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


-- handles alien splitting, creates two child aliens and sets their velocity
function Alien:split(dt)
    gSounds['split']:play()

    -- disable future spliting
    self.canSplit = false

    -- get component velocities of parent alien
    local vx, vy = self.body:getLinearVelocity()
    
    -- instantiate 1st alien (heading clockwise from parent)
    self.children[1] = Alien(self.world, self.type, 
        self.body:getX() + (self.size * vy/vx * dt),
        self.body:getY() + (self.size * vx/vy * dt),
        'Player'
    )

    -- swaping x & y velocities creates perpendicular motion
    self.children[1].body:setLinearVelocity(vy, vx)

    -- instantiate 2nd alien (heading anti-clockwise from parent)
    self.children[2] = Alien(self.world, self.type, 
        self.body:getX() - (self.size * vy/vx * dt),
        self.body:getY() + (self.size * vx/vy * dt),
        'Player'
    )

    -- as above, but negate y component for perpendicular motion
    -- in opposite direction
    self.children[2].body:setLinearVelocity(vy * -1, vx)
    
    return
end