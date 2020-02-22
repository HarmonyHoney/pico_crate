pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- global vars
ent_table = {}
classes = {}

flag_solid = 0

gravity = 0.2

room = 0
room_x = 0
room_y = 0
room_advance = false
load_timer = 0

room_text = {
    "dont be pushy",
    "pick me up",
    "bridge the gap",
    "time to throw down",
    "up up up",
    "this is a hold up",
    "roomy dee",
    "room7",
    "room8",
    "room9",
    "room10",
    "room11",
    "room12",
    "room13",
    "room14",
    "room15",
    "room16",
    "room17",
    "room18",
    "room19",
    "room20",
    "room21",
    "room22",
    "room23",
    "room24",
    "room25",
    "room26",
    "room27",
    "room28",
    "room29",
    "room30",
    "room31",
}

-- core loop
function _init()
    -- duplicate treadmill sprites
    sprite_copy(22, 23)
    sprite_copy(24, 25)

    -- copy button wall sprites
    sprite_copy(8, 9)
    sprite_copy(12, 13)

    map_load()
end


function _update60()
    -- update
    for e in all(ent_table) do
        if e.update != nil then
            e.update(e)
        end
    end

    -- move
    for e in all(ent_table) do
        if e.is_using_gravity then
            e.speed_y += gravity
        end

        if e.is_moving and (e.speed_x != 0 or e.speed_y != 0) then
            move(e)
        end
    end

    if load_timer > 0 then
        load_timer -= 1

        if load_timer == 0 then
            map_load()
        end
    end
end

function _draw()
    cls()
    --map()
    map(0, 0, 0, 0, 128, 64)

    for e in all(ent_table) do
        e.draw(e)
    end

    color(8)
    print("stat: "..stat(1), room_x * 128, room_y * 128)
    print("ent: "..count(ent_table), room_x * 128, room_y * 128 + 7)
    print("room: "..room, room_x * 128, room_y * 128 + 14)

    -- print room text
    local text_length = #room_text[room + 1] * 4
    local center_x = room_x * 128 + 64
    local center_y = room_y * 128 + 122
    -- background color
    rectfill(center_x - (text_length / 2) - 1, center_y - 1, center_x + (text_length / 2) - 1, center_y + 5, 1)
    -- text
    color(7)
    print(room_text[room + 1], center_x - (text_length / 2), center_y)

end



-- functions

-- too lazy to type + 0.5 every time
function round(arg)
    return flr(arg + 0.5)
end

-- convert bool to number
function numbool(arg)
    if arg then
        return 1
    else
        return 0
    end
end

-- iterate though map tiles and create entities
function map_load()
    -- remove entities
    ent_table = {}

    -- reset toggleable walls
    class_button_red.wall_unset()
    class_button_green.wall_unset()

    -- reload map data from cartridge
    reload(0x2000, 0x2000, 0x1000)

    -- advance room
    if room_advance then
        room_advance = false
        room += 1
    end

    -- room position
    local ry = flr(room / 8)
    local rx = room - (ry * 8)

    -- room coords
    room_x = rx
    room_y = ry
    -- set camera
    camera(room_x * 128, room_y * 128)

    -- tile coords
    ry = ry * 16
    rx = rx * 16

    -- look at map
    for y = 0, 15 do
        for x = 0, 15 do
            local tile = mget(rx + x, ry + y)
            -- change gray tile to blue tile
            if tile == 33 then
                mset(rx + x, ry + y, 32)
            -- look for classes
            elseif tile != 0 then
                foreach(classes,
                function(class)
                    if class.sprite == tile then
                        -- create entity
                        local ent = entity_create(class, ((rx + x) * 8), ((ry + y) * 8))
                        -- adjust position based on sprite offset
                        ent.x += ent.sprite_x
                        ent.y += ent.sprite_y

                        -- clear tile on map
                        if ent.is_remove_tile then
                            mset(rx + x, ry + y, 0)
                        end
                    end
                end)
            end
        end
    end

end

-- copy and paste sprite on sheet
function sprite_copy(copy, paste)
    local source = sprite_first_byte(copy)
    local dest = sprite_first_byte(paste)

    for i = 0, 7 do
        memcpy(tostr(dest + (i * 64), true), tostr(source + (i * 64), true), 4)
    end

end

-- returns first top left byte of sprite as decimal
function sprite_first_byte(sprite)
    local y = flr(sprite / 16)
    local x = sprite - (y * 16)

    local byte = y * (64 * 8)
    byte += x * 4

    return byte
end

-- axis aligned bounding box
-- description from: https://love2d.org/wiki/BoundingBox.lua
-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function aabb(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

-- check tilemap for flag_solid
function check_solid_tile_x(this, distance)
    local check_up = false
    local check_down = false
    local y1 = flr(this.y / 8)
    local y2 = flr((this.y + this.hitbox_y - 1) / 8)

    -- left
    if distance == -1 then
        local x = flr((this.x - 1) / 8)
        check_up = fget(mget(x, y1), flag_solid)
        check_down = fget(mget(x, y2), flag_solid)

    -- right
    elseif distance == 1 then
        local x = flr((this.x + this.hitbox_x) / 8)
        check_up = fget(mget(x, y1), flag_solid)
        check_down = fget(mget(x, y2), flag_solid)
    end

    return check_up or check_down
end

-- check tilemap for flag_solid
function check_solid_tile_y(this, distance)
    local check_left = false
    local check_right = false
    local x1 = flr(this.x / 8)
    local x2 = flr((this.x + this.hitbox_x - 1) / 8)

    -- up
    if distance == -1 then
        local y = flr((this.y - 1) / 8)
        check_left = fget(mget(x1, y), flag_solid)
        check_right = fget(mget(x2, y), flag_solid)

    -- down
    elseif distance == 1 then
        local y = flr((this.y + this.hitbox_y) / 8)
        check_left = fget(mget(x1, y), flag_solid)
        check_right = fget(mget(x2, y), flag_solid)
    end

    return check_left or check_right
end

-- aabb but for solid tiles
function check_tile_solid(this)
    -- check 1, 2, 3, 4
    local c1 = false
    local c2 = false
    local c3 = false
    local c4 = false

    local x1 = flr(this.x / 8)
    local y1 = flr(this.y / 8)

    local x2 = flr((this.x + this.hitbox_x - 1) / 8)
    local y2 = flr((this.y + this.hitbox_y - 1) / 8)

    c1 = fget(mget(x1, y1), flag_solid)
    c2 = fget(mget(x2, y1), flag_solid)
    c3 = fget(mget(x1, y2), flag_solid)
    c4 = fget(mget(x2, y2), flag_solid)

    return c1 or c2 or c3 or c4
end

-- check tilemap, and then check entities
function check_solid_x(this, distance)
    local hit = false
    hit = check_solid_tile_x(this, distance)

    if not hit then
        hit = entity_check_solid(this, distance, 0) != nil
    end

    return hit
end

-- check tilemap, and then check entities
function check_solid_y(this, distance)
    local hit = false
    hit = check_solid_tile_y(this, distance)

    if not hit then
        hit = entity_check_solid(this, 0, distance) != nil
    end

    return hit
end


-- move entity
function move(this)

    -- clear bools
    this.has_moved_x = false
    this.has_moved_y = false
    this.has_hit_up = false
    this.has_hit_down = false
    this.has_hit_left = false
    this.has_hit_right = false

    local dy -- distance y
    this.remainder_y += this.speed_y
    dy = round(this.remainder_y)
    this.remainder_y -= dy
    if dy != 0 then
        move_y(this, dy)
    end

    local dx -- distance x
    this.remainder_x += this.speed_x
    dx = round(this.remainder_x)
    this.remainder_x -= dx
    if dx != 0 then
        move_x(this, dx)
    end

end

-- move x axis
function move_x(this, dist)
    local hit = false
    this.has_moved_x = true
    if this.is_colliding then
        local step = sgn(dist)
        for i=1, abs(dist) do
            if not check_solid_x(this, step) then
                    this.x += step
            else
                this.speed_x = 0
                this.remainder_x = 0

                if step == -1 then
                    this.has_hit_left = true
                else
                    this.has_hit_right = true
                end

                hit = true

                break
            end
        end
    else
        this.x += dist
    end

    return hit
end

-- move y axis
function move_y(this, dist)
    local hit = false
    this.has_moved_y = true
    this.is_on_floor = false
    if this.is_colliding then
        local step = sgn(dist)
        for i=1, abs(dist) do
            if not check_solid_y(this, step) then
                    this.y += step
            else
                this.speed_y = 0
                this.remainder_y = 0

                if step == -1 then
                    this.has_hit_up = true
                else
                    this.has_hit_down = true
                    this.is_on_floor = true
                end

                hit = true

                break
            end
        end
    else
        this.x += dist
    end

    return hit
end

-- used to instantiate a new entity
function entity_create(class, x, y)
    local ent = {}

    -- copy keys from base class
    for k, v in pairs(class_base) do ent[k] = v end

    -- override keys from inherited class
    if class.inherit_from != nil then
        for k, v in pairs(class.inherit_from) do ent[k] = v end
    end

    -- override keys from actual class
    for k, v in pairs(class) do ent[k] = v end

    -- set position
    ent.x = x
    ent.y = y

    -- initialize
    if ent.init != nil then
        ent.init(ent)
    end

    add(ent_table, ent)
    return ent
end

-- remove entity instance from table
function entity_remove(ent)
    del(ent_table, ent)
end

function entity_check(this, x, y, class, ignore)
    local ent = nil

    for e in all(ent_table) do
        if e != this and e.name == class.name and e != ignore then
            if aabb(x, y, this.hitbox_x, this.hitbox_y, e.x, e.y, e.hitbox_x, e.hitbox_y) then
                ent = e
                break
            end
        end
    end

    return ent
end

-- only checks for solid entities
-- dx, dy = distance x and y
function entity_check_solid(this, dx, dy, ignore)
    local ent = nil

    for e in all(ent_table) do
        if e != this and e.is_solid and e != ignore then
            if aabb(this.x + dx, this.y + dy, this.hitbox_x, this.hitbox_y, e.x, e.y, e.hitbox_x, e.hitbox_y) then
                ent = e
                break
            end
        end
    end

    return ent
end

function entity_check_moving(this, x, y, ignore)
    local ent = nil

    for e in all(ent_table) do
        if e != this and e.is_moving and e != ignore then
            if aabb(x, y, this.hitbox_x, this.hitbox_y, e.x, e.y, e.hitbox_x, e.hitbox_y) then
                ent = e
                break
            end
        end
    end

    return ent
end

-- move on treadmill
function treadmill_move(this)
    local dist = 0
    local speed = 0.7
    this.is_on_treadmill = false
    local e = entity_check(this, this.x, this.y + 1, class_treadmill)
    if e != nil then
        this.remainder_x += e.tread_dir * speed
        --move_x(this, e.tread_speed)
        this.is_on_treadmill = true
        dist = e.tread_speed
    end

    return dist
end


-- classes

-- all classes inherit from class_base before inherit_from
class_base = {
    tile = nil,
    inherit_from = nil,
    name = "base",
    x = 0,
    y = 0,

    speed_x = 0,
    speed_y = 0,

    remainder_x = 0,
    remainder_y = 0,

    sprite = -1,
    sprite_x = 0,
    sprite_y = 0,

    draw_offset_x = 0,
    draw_offset_y = 0,

    flip_x = false,
    flip_y = false,

    hitbox_x = 8,
    hitbox_y = 8,

    is_moving = false,
    is_solid = false,
    is_colliding = false,
    is_using_gravity = false,
    is_on_treadmill = false,
    is_remove_tile = true,

    has_moved_x = false,
    has_moved_y = false,

    has_hit_up = false,
    has_hit_down = false,
    has_hit_left = false,
    has_hit_right = false,

    is_on_floor = false,

    init = nil,
    update = nil,
    draw = function(this)
        spr(this.sprite, this.x - this.sprite_x + this.draw_offset_x, this.y - this.sprite_y + this.draw_offset_y, 1, 1, this.flip_x, this.flip_y)
    end
}
add(classes, class_base)

class_player = {
    name = "player",
    tile = 1,
    sprite = 2,

    sprite_idle1 = 2,
    sprite_idle2 = 3,
    sprite_run1 = 4,
    sprite_run2 = 5,
    sprite_jump = 6,

    is_moving = true,
    is_solid = true,
    is_colliding = true,
    is_using_gravity = true,

    move_speed = 1,
    jump_speed = 3.3,

    anim_frame = 0,
    anim_step_run = 0.2,
    anim_step_idle = 0.04,

    is_holding_crate = false,

    speed_drop_x = 1,
    speed_drop_y = -1,

    speed_throw_x = 1.7,
    speed_throw_y = -2.5,

    speed_throw_high_x = 0.7,
    speed_throw_high_y = -3.5,

    z_last = false,
    x_last = false,

    update = function(this)
        -- check for spikes
        if entity_check(this, this.x, this.y, class_spike) != nil then
            if this.is_holding_crate then
                this.crate_drop(this)
            end

            entity_create(class_explode, this.x + 3, this.y + 3)
            entity_remove(this)
            load_timer = 30
            return 0
        end

        -- check for exit
        if not this.is_holding_crate then
            if entity_check(this, this.x, this.y, class_exit) != nil then
                entity_create(class_explode, this.x + 3, this.y + 3)
                entity_remove(this)
                room_advance = true
                load_timer = 30
                return 0
            end
        end

        -- animation
        if this.is_on_floor then
            -- idle
            if this.speed_x == 0 then
                this.anim_frame += this.anim_step_idle

                if this.anim_frame >= 2 then
                    this.anim_frame = mid(0, this.anim_frame - 2, 1.99)
                end

                if flr(this.anim_frame) == 0 then
                    this.sprite = this.sprite_idle1
                elseif flr(this.anim_frame) == 1 then
                    this.sprite = this.sprite_idle2
                    -- this frame is half as long
                    this.anim_frame += this.anim_step_idle
                end

                this.draw_offset_y = 0
                
            -- run
            else
                this.anim_frame += this.anim_step_run

                if this.anim_frame >= 4 then
                    this.anim_frame = mid(0, this.anim_frame - 4, 3.99)
                end

                if flr(this.anim_frame) == 0 then
                    this.sprite = this.sprite_idle1
                    this.draw_offset_y = 0
                elseif flr(this.anim_frame) == 1 then
                    this.sprite = this.sprite_run1
                    this.draw_offset_y = -1
                elseif flr(this.anim_frame) == 2 then
                    this.sprite = this.sprite_idle1
                    this.draw_offset_y = 0
                elseif flr(this.anim_frame) == 3 then
                    this.sprite = this.sprite_run2
                    this.draw_offset_y = -1
                end
            end
        end

        
        -- walking
        if btn(0) then
            this.speed_x = -this.move_speed
            this.flip_x = true
        elseif btn(1) then
            this.speed_x = this.move_speed
            this.flip_x = false
        else
            this.speed_x = 0
        end

        -- jump
        if btn(4) and not this.z_last and this.is_on_floor then
            this.speed_y = -this.jump_speed
            this.sprite = this.sprite_jump
            this.draw_offset_y = 0
            sfx(6)
        end
        -- only jump on first press
        this.z_last = btn(4)

        -- crate pickup / throw
        if this.is_holding_crate then
            if btn(5) and not this.x_last then
                this.crate_throw(this)
            elseif btnp(3) then
                this.crate_drop(this)
            end

        elseif btn(5) and not this.x_last then
            local dir = sgn(numbool(not this.flip_x) - 1)
            local e = entity_check(this, this.x + 4 * dir, this.y, class_crate)
            if e != nil then
                local offset = this.crate_find_space(this, e)
                if offset then
                    this.crate_pickup(this)
                    this.x += offset
                    del(ent_table, e)
                end
            end
        end
        -- only throw on first press
        this.x_last = btn(5)

        -- crate push
        local dir = this.get_dir(this)
        local e = entity_check(this, this.x + dir, this.y, class_crate)
        if e != nil then
            local hit = move_x(e, 1 * dir)
            if not hit then
                --sfx(1)
            end
        end
        
        treadmill_move(this)
    end,

    draw = function(this)
        if not this.is_holding_crate then
            class_base.draw(this)
            -- draw debug collider
            --rect(this.x, this.y - 8, this.x + 7, this.y + 7, 11)
        else
            -- offset y for crate
            local oy = numbool(this.sprite == this.sprite_idle2)

            -- draw body
            spr(this.sprite, this.x, this.y + 8 + this.draw_offset_y, 1, 1, this.flip_x, this.flip_y)

            -- draw crate
            spr(class_crate.sprite, this.x, this.y + oy + this.draw_offset_y)

            -- draw debug collider
            --rect(this.x, this.y, this.x + this.hitbox_x - 1, this.y + this.hitbox_y - 1, 11)
        end
    end,

    get_dir = function(this)
        return sgn(numbool(not this.flip_x) - 1)
    end,

    crate_pickup = function(this)
        this.is_holding_crate = true
        this.y -= 8
        this.hitbox_y = 16
        sfx(2)
    end,

    crate_release = function(this)
        this.is_holding_crate = false
        this.hitbox_y = 8
        this.y += 8
        return entity_create(class_crate, this.x, this.y - 8)
    end,

    crate_drop = function(this)
        local c = this.crate_release(this)
        local dir = this.get_dir(this)
        c.speed_x = this.speed_drop_x * dir
        c.speed_y = this.speed_drop_y
        sfx(4)
    end,

    crate_throw = function(this)
        local c = this.crate_release(this)
        local dir = this.get_dir(this)
        c.speed_x = this.speed_throw_x * dir
        c.speed_y = this.speed_throw_y
        sfx(3)
    end,

    crate_throw_high = function(this)
        local c = this.crate_release(this)
        local dir = this.get_dir(this)
        c.speed_x = this.speed_throw_high_x * dir
        c.speed_y = this.speed_throw_high_y
        sfx(5)
    end,

    crate_check_space = function(finder, ignore)
        local check = false
        check = check_tile_solid(finder)

        if not check then
            local e = entity_check(finder, finder.x, finder.y, class_crate, ignore)
            if e != nil then
                check = true
            end
        end

        return check
    end,

    crate_find_space = function(this, ignore)
        local offset = nil
        local finder = {}
        finder.x = this.x
        finder.y = this.y - 8
        finder.hitbox_x = 8
        finder.hitbox_y = 16

        -- wiggle around a look for an open space
        for i in all({0, 1, -1, 2, -2}) do
            finder.x = this.x + i
            if not this.crate_check_space(finder, ignore) then
                offset = i
                break
            end
        end

        return offset
    end,

}
add(classes, class_player)

class_crate = {
    name = "crate",
    tile = 2,
    sprite = 1,

    is_moving = true,
    is_solid = true,
    is_colliding = true,
    is_using_gravity = true,

    update = function(this)
        if this.speed_x != 0 and this.is_on_floor then
            this.speed_x = 0
        end

        treadmill_move(this)
    end,
}
add(classes, class_crate)

class_exit = {
    name = "exit",
    tile = 3,
    sprite = 21,
    sprite_x = 2,
    sprite_y = 2,
    hitbox_x = 4,
    hitbox_y = 4,

    is_growing = false,
    grow_speed = 0.1,
    radius = 5,
    radius_min = 1.1,
    radius_max = 5.9,

    color_fill = 7,
    color_outline = 12,

    particle_table = {},
    particle_count = 5,
    particle_speed = 0.2,
    particle_color = 7,

    init = function(this)
        this.particle_table = {}
        -- create particles
        for i = 1, this.particle_count do
            local p = {
                x = (this.x + 2) + rnd(this.radius * 2) - this.radius,
                y = this.y + 10 - i * 2,
            }

            add(this.particle_table, p)
        end

    end,

    update = function(this)
        -- move particles
        for p in all(this.particle_table) do
            p.y -= this.particle_speed
            if p.y < this.y - 8 then
                p.y = this.y + 2
                p.x = (this.x + 2) + rnd(this.radius * 2) - this.radius
            end
        end

        -- grow and shrink
        if this.is_growing then
            this.radius += this.grow_speed
            if this.radius >= this.radius_max then
                this.is_growing = false
            end
        else
            this.radius -= this.grow_speed
            if this.radius <= this.radius_min then
                this.is_growing = true
            end
        end
    end,

    draw = function(this)
        -- draw outline
        circfill(this.x + 2, this.y + 2, this.radius + 2, this.color_outline)

        -- draw circle
        circfill(this.x + 2, this.y + 2, this.radius, this.color_fill)

        -- draw particles
        for p in all(this.particle_table) do
            pset(p.x, p.y, this.particle_color)
        end
    end,

}
add(classes, class_exit)

class_spike = {
    name = "spike",
    sprite = -1,
    is_remove_tile = false,
    draw = nil,
}

class_spike_top = {
    inherit_from = class_spike,
    tile = 4,
    sprite = 17,

    hitbox_x = 8,
    hitbox_y = 5,
}
add(classes, class_spike_top)

class_spike_bottom = {
    inherit_from = class_spike,
    tile = 5,
    sprite = 18,

    sprite_y = 3,
    hitbox_x = 8,
    hitbox_y = 5,
}
add(classes, class_spike_bottom)

class_spike_left = {
    inherit_from = class_spike,
    tile = 6,
    sprite = 19,

    hitbox_x = 5,
    hitbox_y = 8,
}
add(classes, class_spike_left)

class_spike_right = {
    inherit_from = class_spike,
    tile = 7,
    sprite = 20,
    
    sprite_x = 3,
    hitbox_x = 5,
    hitbox_y = 8,
}
add(classes, class_spike_right)

class_explode = {
    name = "explode",
    radius = 8,
    color = 7,
    color_outline = 5,

    init = function(this)
        sfx(0)
    end,

    update = function(this)
        this.radius -= 0.5

        if this.radius <= 0 then
            entity_remove(this)
        end
    end,

    draw = function(this)
        circfill(this.x, this.y, this.radius + 2, this.color_outline)
        circfill(this.x, this.y, this.radius, this.color)
    end,
}
add(classes, class_explode)

class_treadmill = {
    name = "treadmill",
    is_solid = true,
    tread_dir = 1,
    offset = 0,

    update = function(this)
        this.offset += 0.2

        if this.offset >= 8 then
            this.offset -= 8
        end
    end,

    draw = function(this)
        sspr(flr(this.sheet_x + (this.offset * -this.tread_dir)), this.sheet_y, 8, 8, this.x, this.y)
    end,

}
add(classes, class_treadmill)

class_treadmill_left = {
    inherit_from = class_treadmill,
    tile = 12,
    sprite = 22,
    tread_dir = -1,
    sheet_x = 48,
    sheet_y = 8,
}
add(classes, class_treadmill_left)

class_treadmill_right = {
    inherit_from = class_treadmill,
    tile = 13,
    sprite = 24,
    tread_dir = 1,
    sheet_x = 72,
    sheet_y = 8,
}
add(classes, class_treadmill_right)

class_button_red = {
    name = "button_red",
    tile = 8,
    sprite = 7,

    sprite_y = 5,
    hitbox_y = 3,

    is_pressed = false,
    is_pressed_last = false,

    update = function(this)
        this.is_pressed_last = this.is_pressed
        this.is_pressed = entity_check(this, this.x, this.y, class_crate) != nil or entity_check(this, this.x, this.y, class_player) != nil

        if this.is_pressed and not this.is_pressed_last then
            this.wall_set()
            this.draw_offset_y = 2
        elseif not this.is_pressed and this.is_pressed_last then
            this.wall_unset()
            this.draw_offset_y = 0
        end
    end,

    wall_set = function()
        fset(8, 0, true)
        sprite_copy(10, 8)
    end,

    wall_unset = function()
        fset(8, 0, false)
        sprite_copy(9, 8)
    end,
}
add(classes, class_button_red)

class_button_green = {
    name = "button_green",
    tile = 10,
    sprite = 11,

    sprite_y = 5,
    hitbox_y = 3,

    is_pressed = false,
    is_pressed_last = false,

    update = function(this)
        this.is_pressed_last = this.is_pressed
        this.is_pressed = entity_check(this, this.x, this.y, class_crate) != nil or entity_check(this, this.x, this.y, class_player) != nil

        if this.is_pressed and not this.is_pressed_last then
            this.wall_set()
            this.draw_offset_y = 2
        elseif not this.is_pressed and this.is_pressed_last then
            this.wall_unset()
            this.draw_offset_y = 0
        end
    end,

    wall_set = function()
        fset(12, 0, true)
        sprite_copy(14, 12)
    end,

    wall_unset = function()
        fset(12, 0, false)
        sprite_copy(13, 12)
    end,
}
add(classes, class_button_green)


-- menu items
menuitem(1, "reset level", map_load)

function last_room()
    room = max(0, room - 1)
    map_load()
end

menuitem(2, "last room", last_room)

function next_room()
    room_advance = true
    map_load()
end

menuitem(3, "next room", next_room)


__gfx__
000000002222222200999990000000000099999000999990009999900000000088088088880000888888888800000000bb0bb0bb88000088bbbbbbbb00000000
000000002244442200999999009999900099999900999999009999990000000080000008888008888222222800000000b000000b88800888b333333b00000000
007007002424424200fcffc00099999900fcffc000fcffc000fcffc000000000000000000888888082222228000000000000000008888880b333333b00000000
000770002442244200fffff000fcffc000fffff000fffff0f8fffff00000000080000008008888008222222800000000b000000b00888800b333333b00000000
00077000244224428888888888fffff888888888888888880088880d0000000080000008008888008222222800000000b000000b00888800b333333b00000000
0070070024244242f088880ff088880ff088880ff088880fd8888f8d088888800000000008888880822222280bbbbbb00000000008888880b333333b00000000
0000000022444422088008800880088008800dddddd00880d880088d88888888800000088880088882222228bbbbbbbbb000000b88800888b333333b00000000
0000000022222222ddd00dddddd00dddddd0000000000dddd000000088888888880880888800008888888888bbbbbbbbbb0bb0bb88000088bbbbbbbb00000000
666666660777077700000000770000000000000000cccc0055559995880000885999555588000088000000000000000000000000000000000000000000000000
67777776077707770000000077770000000007770c7777c055599955888008885599955588800888000000000000000000000000000000000000000000000000
6777777607770070000000007700000000077777c777777c55999555088888805559995508888880000000000000000000000000000000000000000000000000
6777777600700070000007000000000000000777c777777c59995555008888005555999500888800000000000000000000000000000000000000000000000000
6777777600700000070007007770000000000000c777777c59995555008888005555999500888800000000000000000000000000000000000000000000000000
6777777600000000070077707777700000000077c777777c55999555088888805559995508888880000000000000000000000000000000000000000000000000
67777776000000007770777077700000000077770c7777c055599955888008885599955588800888000000000000000000000000000000000000000000000000
666666660000000077707770000000000000007700cccc0055559995880000885999555588000088000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000000000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000200000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000000000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000100000000010101010000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000010100000001000000000100001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000100000001000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000100000001010101010000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000100000001000000000100001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000100000001000000000100001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01001010101010000010101010000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000000000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000000000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000000000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01000000000000000000000000000001121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
01010101010101010101010101010101121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
02020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
12121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202
__label__
11166666116611161116161666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
17177776617717161777171667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
17177776617717161117111667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
17177776617717166717771667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
11177176111711161117771667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
11177776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
66166666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
11166666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
17777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
11177776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000006666666600000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000006777777600000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000006666666600000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666666666666666666666666666
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000000000000022222222000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000000000000022444422000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000000000000024244242000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000000000000024422442000000000000000000000000000067777776677777766777777667777776
66666666000000000000000000000000000000000000000000000000000024422442000000000000000000000000000066666666666666666666666666666666
66666666000000000000000000000000000000000000000000000000000024244242000000000000000000000000000066666666666666666666666666666666
67777776000000000000000000000000000000000000000000009999900022444422000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000009999990022222222000000000000000000000000000067777776677777766777777667777776
6777777600000000000000000000000000000000000000000000fcffc00000000000000000000000000000000000000067777776677777766777777667777776
6777777600000000000000000000000000000000000000000000fffff00000000000000000000000000000000000000067777776677777766777777667777776
67777776000000000000000000000000000000000000000000008888000000000000000000000000000000000000000067777776677777766777777667777776
677777760000000000000000000000000000000000000000000f8888f00000000000000000000000000000000000000067777776677777766777777667777776
66666666000000000000000000000000000000000000000000008008000000000000000000000000000000000000000066666666666666666666666666666666
66666666000000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
66666666000000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666000000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776000000000000000000000000000000006777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
66666666000000000000000000000000000000006666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
67777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776677777766777777667777776
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__gff__
0000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020201010101010101020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020201000000000151020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212110101010101010101010212121202020202020202020202020202020202121212121212121212121212121212120202020201000000000001020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020101010101010101010101010202021212110000000000000000010212121202010101010101010101010101020202121211010101010101010101021212120202020201000000000001020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020100000000000000000000010202021212110000000000000150010212121202010000000000000000000001020202121211000000000150000001021212120202020201000000000121020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020100000000000000000150010202021212110000000000000000010212121202010000000000000000000151020202121211000000000000000001021212120202020201000000000101020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020100000000000000000000010202021212110000000000000000010212121202010000000000000000000001020202121211000000000000000001021212120202020201000000000001020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020100000000000000000000010202021212110000000000000000010212121202010000000000000000000001020202121211000000000000000001021212120202020201012000000001020202020212121212121212121212115212121212020202020202020202020202020202021212121212121212121212121212121
2020100000000000000000000010202021212110000000000000000010212121202010010002000000000000001020202121211000000000000000001021212120202020201010000000001020202020212121212102212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020100002000001000000000010202021212110000000000010101010212121202010101010101212121212121020202121211000000101000200001021212120202020201000000000001020202020212121212101212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020101010101010101010101010202021212110020000010010101010212121202010101010101010101010101020202121211012121010101012121021212120202020201001000000121020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212110101010101010101010212121202020202020202020202020202020202121211010101010101010101021212120202020201001000000101020202020212121212121000000000000002121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020201001000200001020202020212121212121121212121212122121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020201010101010101020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
2020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121
1010101010101010101010101010101020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000000020000000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000000000000000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000101010101000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000010000000000010000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000010000000000010000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000010000000000010000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000101010101000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000010000000000010000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000010000000000010000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000010000000000010000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000101010101000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000000000000000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000000000000000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1000000000000000000000000000001020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
1010101010101010101010101010101020202020202020202020202020202020212121212121212121212121212121212020202020202020202020202020202021212121212121212121212121212121202020202020202020202020202020202121212121212121212121212121212120202020202020202020202020202020
__sfx__
000e00003f6711b651096410363100621006113a70108701137011470111501147011470113701137011270111701107010d7010d7010c7010c7010c701006010060100601006010060100601006010060100601
000500000044202402054020440200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
0003000002450064500a4500e45012450164401a4301e420224100040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
00050000224501e4501a65016650126500e6400a63005620016100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500000b450064501a650166400f630086200261005600016000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0005000022450264501a65016650126500e6400a63005620016100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00040000240510c0010d0011200119001240012b0011b00122001260012a001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
__music__
00 40424344

