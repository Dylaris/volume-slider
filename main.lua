local animated_value = 0.5
local animated_speed = 10
local display_slider = true

local slider = {
    x = 100,
    y = 250,
    width = 400,
    height = 10,
    value = 0.5,
    dragging = false,
    button = {
        x = 0,
        y = 0,
        radius = 10
    }
}

local mouse_icon = love.graphics.newImage("assets/mouse.png")
local volume_icon = {
    scale = 1.5,
    rect = {},
    image = love.graphics.newImage("assets/volume.png")
}
local volume_change = false
local music = love.audio.newSource("assets/music.mp3", "stream")

local function inside_circle(x, y, circle)
    local distance = math.sqrt((x-circle.x)^2+(y-circle.y)^2)
    return distance <= circle.radius
end

local function inside_rectangle(x, y, rectangle)
    return x >= rectangle.x and x <= rectangle.x+rectangle.width and
           y >= rectangle.y and y <= rectangle.y+rectangle.height
end

local function update_slider_button_position()
    slider.button.x = slider.x + slider.value*slider.width
    slider.button.y = slider.y + slider.height/2
end

local function update_volume_icon_size()
    local mousex, mousey = love.mouse.getPosition()
    volume_icon.rect.width = volume_icon.image:getWidth()*volume_icon.scale
    volume_icon.rect.height = volume_icon.image:getHeight()*volume_icon.scale
    volume_icon.rect.x = slider.x - 40
    volume_icon.rect.y = slider.y + slider.height/2 - volume_icon.rect.height/2

    if inside_rectangle(mousex, mousey, volume_icon.rect) then
        volume_icon.scale = 2
    else
        volume_icon.scale = 1.5
    end
end

local function handle_slider_drag()
    if love.mouse.isDown(1) then
        local mousex, mousey = love.mouse.getPosition()
        -- drag or not
        if inside_circle(mousex, mousey, slider.button) then slider.dragging = true end
        if slider.dragging then
            local relativex = math.max(slider.x, math.min(slider.x+slider.width, mousex))
            slider.value = (relativex-slider.x) / slider.width
            volume_change = true
        end
    else
        slider.dragging = false
    end
end

local function handle_slider_click(mousex, mousey)
    if inside_rectangle(mousex, mousey, slider) then
        local relativex = math.max(slider.x, math.min(slider.x+slider.width, mousex))
        slider.value = (relativex-slider.x) / slider.width
        volume_change = true
    end
end

local function handle_volume_icon_click(mousex, mousey)
    if inside_rectangle(mousex, mousey, volume_icon.rect) then
        display_slider = not display_slider
    end
end

local function draw_slider()
    -- track shader
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle(
        "fill",
        slider.x+4, slider.y+4,
        slider.width, slider.height,
        5, 5
    )

    -- track background
    love.graphics.setColor(0.25, 0.25, 0.3)
    love.graphics.rectangle(
        "fill",
        slider.x, slider.y,
        slider.width, slider.height,
        5, 5
    )

    -- track border
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.rectangle(
        "line",
        slider.x, slider.y,
        slider.width, slider.height,
        5, 5
    )

    -- progress filling
    local r = 0.1 + slider.value*0.4
    local g = 0.8 + slider.value*0.2
    local b = 1.0
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle(
        "fill",
        slider.x, slider.y,
        animated_value*slider.width, slider.height,
        5, 5
    )

    -- button shader
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.circle(
        "fill",
        slider.button.x+2, slider.button.y+2,
        slider.button.radius
    )

    -- button body
    local mousex, mousey = love.mouse.getPosition()
    local button_color = {1, 1, 1} -- normal
    if slider.dragging then
        button_color = {1, 0.8, 0.2} -- dragging
    elseif inside_circle(mousex, mousey, slider.button) then
        button_color = {0.8, 0.9, 1} -- hover
    end
    love.graphics.setColor(button_color)
    love.graphics.circle(
        "fill",
        slider.button.x, slider.button.y,
        slider.button.radius
    )

    -- percetange value
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print(
        string.format("volum: %d%%", math.floor(animated_value*100)),
        slider.x, slider.y-30
    )
end


local function draw_volume_icon()
    local mousex, mousey = love.mouse.getPosition()
    volume_icon.rect.width = volume_icon.image:getWidth()*volume_icon.scale
    volume_icon.rect.height = volume_icon.image:getHeight()*volume_icon.scale
    volume_icon.rect.x = slider.x - 40
    volume_icon.rect.y = slider.y + slider.height/2 - volume_icon.rect.height/2

    love.graphics.push()
    love.graphics.scale(volume_icon.scale, volume_icon.scale) -- scale everything (image and x/y ...)
    love.graphics.draw(volume_icon.image, volume_icon.rect.x/volume_icon.scale, volume_icon.rect.y/volume_icon.scale)
    love.graphics.pop()
end

local function draw_mouse_icon()
    local mousex, mousey = love.mouse.getPosition()
    love.graphics.push()
    love.graphics.scale(1.5, 1.5) -- scale everything (image and x/y ...)
    love.graphics.draw(mouse_icon, mousex/1.5, mousey/1.5)
    love.graphics.pop()
end

function love.load()
    love.mouse.setVisible(false)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    music:setLooping(true)
    music:play()
end

function love.mousepressed()
    local mousex, mousey = love.mouse.getPosition()
    handle_volume_icon_click(mousex, mousey)
    if display_slider then handle_slider_click(mousex, mousey) end
end

function love.update(dt)
    update_slider_button_position()
    update_volume_icon_size()
    if display_slider then handle_slider_drag() end
    animated_value = animated_value + (slider.value-animated_value)*animated_speed*dt
    if volume_change then
        music:setVolume(slider.value)
        volume_change = false
    end
end

function love.draw()
    if display_slider then draw_slider() end
    draw_volume_icon()
    draw_mouse_icon()
end
