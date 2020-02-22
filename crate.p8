pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- PICO-Crate
-- by Harrison Monroe
-- a PICO-8 Cartridge


-- global vars
ent_table = {}
classes = {}

flag_solid = 0

gravity = 0.2

room = 1
room_text = ""
room_change = 0
load_timer = 0

debug = false

tiled_room = {
    "0000000000000000000000000000000000000000000000000000000000009000000000000000a000000000000000a0000065555555555600005e000cc0e00500005010e00004e50000655555555556000000a0000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000,walk (with arrow keys)",
    "0000000000000000000000000000000000000000000000000000000000000000000b0b000b0b0000006555555555560000500000e00005000050e09000040500005100a000e0050000655563365556000055555555555500000000000000a0000000000000009000000000000000000000000000000000000000000000000000,jump (with z key)",
    "000b990000000000000999000000000000099c00000000000000a00000bb00000065555555555600005e0c0c0e0005000050000000040500005000e0b99005000050000099c00500005e00000a00050000501002ba00e500006555555555560000000a000000a00000000a000000a00000000a000000c00000000c0000000000,push me",
    "000000000000000000000000000000000000000000000000000655555555600000050000e000500000050000004050000005e0000000500000050000000e50000005000e00005000000500000000500000050e000655600000051002055550000006555556555000000000000000000000000000000000000000000000000000,pickup (with x key)",
    "00000000000000000000000000000000000000000000000000000000000000000065555555555600005000e0000e0500005e00000000450000500000e00005000050e0000000e5000052010e00000500006555633333350000555555555556000000000000000000000000000000000000000000000000000000000000000000,toss n cross",
    "000000000000000000000000000000000000000000000000000655555555600000050e000000500000050000400e5000000500e0000050000005000000e0500000050e00e000500000050000000e50000005e0220100500000053365563350000006555555556000000000000000000000000000000000000000000000000000,drop (down arrow)",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065555005555600005e0050050e050000500e655604050000521000e000e500006555533555560000000065560000000000000000000000000000000000000000000000000000000000000000000000,push bridge",
    "00000000000000000000000000000000000000000000000000000655556000000000050e00500000000005040e50000000000500005000000000050002500000000005e006500000000005000550000000000500e550000000000501055000000000065556500000000000000000000000000000000000000000000000000000,jump n grab",
    "000000000000000000000655555600000000050000450000000005e000050000000005000005000000000500e035000000000500006500000000050e000500000000053000e500000000056000050000000005000e05000000000520003500000000052e00650000000005201005000000000655555600000000000000000000,up up up",
    "00000000000000000000000000000000006555555555560000500000000005000050400e000e050000500000000005000050e000000005000050000000e005000050000000002500005000e00000250000500000000025000050000000e025000050e00010002500006555555555560000000000000000000000000000000000,stack it up",
    "00000000000000000000000000000000000000000000000065555555555555565000e00000000005500000000000e0055000000e0000000550e000000000040550000000000000055000000030e0000552100e0050000e0565563333533333355555555565555556000000000000000000000000000000000000000000000000,spike long jump",
    "0000000000000000000065555556000000005000e005000000005e000405000000005000000500000000500000050000000050000e050000000050e000050000000050000065000000005000e055000000005e000055000000005000656500000000500e55550000000052105555000000006555655500000000000000000000,throw n dodge",
    "00000000000000000000000000000000000000000000000000000000000000006555555555555556500000000e0000055000e00000000e05540000e0000e0025500000000000002550e0000000e01025533333333333655665555555555565550000000000000000000000000000000000000000000000000000000000000000,toss three",
    "000000000000000000000000000000000655555555555560050000000000e050050400000000005005000000e00002500500e00000000250050000000000025005000000e000025005e00000000e025005000000000002500500000e000102500533333333365560065555555556555000000000000000000000000000000000,spike stack",
    "00000000000000000000000000000000655555555555555650000e00000000055040000000e000055e0000000000000550000000e00000055000e0000000000555600000000e0025555000e0000000255550000000000e25555000000e0010255553333333336556556555555555655500000000000000000000000000000000,cross n stack",
    "000000000000000000000000000000006555555555555556500000e0000000055000000000e00405500e00000000000550000000000000e55000000e0000000550e0000000e0333550000e0000006556520003333333555552e00655555565555201055555555555655556555555555500000000000000000000000000000000,spike stairs",
    "000000000000000000006555555600000000500000050000000050400e05000000005000000500000000500e00050000000050000065000000005e0000550000000050000055000000005000e005000000005000005500000000500006550000000052e005550000000052010555000000006555565500000000000000000000,throw dodge climb",
    "065555555560000005000000005000000500000e00500000050e00000250000005100e0002500000065600006560000000050000500000000005000050000000000500e050000000000500005000000000050000655555600005000000000050000500000e00405000050e00000e005000053333333333500006555555555560,down the boot",
    "65555555555555555200000000e00655520000e000000065522010000000000555555633330000055555555556000005556000000000e00556000000000000055000e0000000000550000033336555555000006555555555500000000000000550e0000000000405500000000e00000555555633333333355555555555555556,the big two",
    "6555555555555556500cc00000ccc00550000000000000055000000e0000000550e0333333300e055000655555500005504050000000000553335000b99000566555600e999000055200000099c0e0055200e0000a003335520000000ae0655552e0033333335555520006555555555552010555555555556555555555555555,the final challenge",
}

-- core loop
function _init()

    -- duplicate treadmill sprites
    sprite_copy(22, 23)
    sprite_copy(24, 25)

    -- copy button wall sprites
    sprite_copy(8, 9)
    sprite_copy(12, 13)

    -- erase wall tile
    --sprite_copy(64, 16)

    tiled_load()

    music(6)
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
            tiled_load()
        end
    end

    

    -- debug change room
    -- if holding shift
    if debug and btn(4, 1) then
        if btn_press(0) then
            room_change = -1
            tiled_load()
        elseif btn_press(1) then
            room_change = 1
            tiled_load()
        end
    end

    -- needed for btn_press()
    btn_last_collect()
end

function _draw()
    cls()
    --map()
    map(0, 0, 0, 0, 128, 64)

    for e in all(ent_table) do
        e.draw(e)
    end

    -- debug text
    if debug then
        color(8)
        print("stat: "..stat(1))
        print("ent: "..count(ent_table))
        print("room: "..room)
    end

    -- print room text
    -- l = text_length, px = print_x, py = print_y
    local l = #room_text * 4
    local px = 64
    local py = 122
    -- text box
    rectfill(px - (l / 2) - 1, py - 1, px + (l / 2) - 1, py + 5, 0)
    -- text
    color(7)
    print(room_text, px - (l / 2), py)
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

btn_last = {}
function btn_last_collect()
    for i = 0, 5 do
        btn_last[i] = btn(i)
    end
end

function btn_press(arg)
    return btn(arg) and not btn_last[arg]
end

function tiled_load()
    -- clear entities
    ent_table = {}

    -- reload map data from cartridge (clear to blank for now)
    reload(0x2000, 0x2000, 0x1000)

    -- advance room
    if room_change != 0 then
        room_change = sgn(room_change)
        room = mid(1, room + room_change, #tiled_room)
    end
    room_change = 0

    local map = tiled_room[room]

    room_text = sub(map, 258)

    -- create tiles and entities
    for i = 0, 255 do
        local t = sub(map, i + 1, i + 1)
        local y = flr(i / 16)
        local x = i - (y * 16)

        if t == "5" then
            mset(x, y, 16)
        elseif t == "6" then
            mset(x, y, 17)
        elseif t == "9" then
            mset(x, y, 32)
        elseif t == "a" then
            mset(x, y, 48)
        elseif t == "b" then
            mset(x, y, 49)
        elseif t == "c" then
            mset(x, y, 33)
        elseif t == "d" then
            --mset(x, y, 33)
        elseif t == "e" then
            mset(x, y, 34)
        end


        -- look for classes
        foreach(classes,
        function(class)
            if tostr(class.tile) == t then
                -- create entity
                local ent = entity_create(class, x * 8, y * 8)
                -- adjust position based on sprite offset
                ent.x += ent.sprite_x
                ent.y += ent.sprite_y
            end
        end)


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

    -- fix for holding crate and not checking enough pixels
    if not hit and this.is_holding_crate then
        local test = {
            x = this.x,
            y = this.y,
            hitbox_x = this.hitbox_x,
            hitbox_y = 8,
        }
        hit = check_solid_tile_x(test, distance)
        if not hit then
            test.hitbox_y = 9
            hit = check_solid_tile_x(test, distance)
        end
    end

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
    this.is_on_floor_3 = this.is_on_floor_2
    this.is_on_floor_2 = this.is_on_floor
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

function entity_check_all(this, x, y, class, ignore)
    local ent = {}
    local i = 1

    for e in all(ent_table) do
        if e != this and e.name == class.name and e != ignore then
            if aabb(x, y, this.hitbox_x, this.hitbox_y, e.x, e.y, e.hitbox_x, e.hitbox_y) then
                ent[i] = e
                i += 1
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
    is_on_floor_2 = false,
    is_on_floor_3 = false,

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
    move_slow = 0.8,
    move_accel = 0.1,
    move_last = 0,
    push_speed = 0.3,

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

    update = function(this)
        -- check for spikes
        if this.speed_y > 0 and entity_check(this, this.x, this.y, class_spike) != nil then
            this.death(this)
            return 0
        end

        -- check for exit portal
        local portal = entity_check(this, this.x, this.y, class_exit)
        if portal != nil then
            local go = false
            -- make sure player is touching portal, not just held crate
            if this.is_holding_crate then
                go = this.y < portal.y - 4
            else
                go = true
            end

            if go then
                this.death(this)
                room_change = 1
                return 0
            end
        end

        -- animation
        if this.is_on_floor then
            -- idle
            if  abs(this.speed_x) < 0.2 then
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
        if btn(0) and this.speed_x then
            this.speed_x -= this.move_accel
            this.speed_x = max(this.speed_x, -this.move_speed)
            this.flip_x = true
        elseif btn(1) and this.speed_x then
            this.speed_x += this.move_accel
            this.speed_x = min(this.speed_x, this.move_speed)
            this.flip_x = false
        else
            this.speed_x *= this.move_slow
        end

        this.move_last = this.speed_x

        -- jump
        if btn_press(4) and this.check_jump(this) then
            this.speed_y = -this.jump_speed
            this.sprite = this.sprite_jump
            this.draw_offset_y = 0
            sfx(6)
        end

        -- crate pickup / throw
        if this.is_holding_crate then
            if btn_press(5) then
                this.crate_throw(this)
            elseif btn_press(3) then
                this.crate_drop(this)
            end

        elseif btn_press(5) then
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

        -- in on floor
        -- crate push
        if this.is_on_floor then
            local dir = this.get_dir(this)
            local e = entity_check(this, this.x + dir, this.y, class_crate)
            if e != nil then
                --local hit = move_x(e, 1 * dir)
                e.push(e, dir)
                -- slow movement when pushing
                if abs(this.speed_x) > this.push_speed then
                    this.speed_x = this.push_speed * sgn(this.speed_x)
                end
            end
        end

        -- debug spawn crate
        if debug and btn(4, 1) and btn_press(5) then
            this.crate_pickup(this)
        end
        
        treadmill_move(this)
    end,

    draw = function(this)
        if not this.is_holding_crate then
            class_base.draw(this)
            -- draw debug collider
            if debug then rect(this.x, this.y - 8, this.x + 7, this.y + 7, 11) end
        else
            -- offset y for crate
            local oy = numbool(this.sprite == this.sprite_idle2)

            -- draw body
            spr(this.sprite, this.x, this.y + 8 + this.draw_offset_y, 1, 1, this.flip_x, this.flip_y)

            -- draw crate
            spr(class_crate.sprite, this.x, this.y + oy + this.draw_offset_y)

            -- draw debug collider
            if debug then rect(this.x, this.y, this.x + this.hitbox_x - 1, this.y + this.hitbox_y - 1, 11) end
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

    death = function(this)
        if this.is_holding_crate then
            this.crate_drop(this)
        end

        entity_create(class_explode, this.x + 3, this.y + 3)
        entity_remove(this)
        load_timer = 30
    end,

    -- for coyote jump
    check_jump = function(this)
        return this.is_on_floor or this.is_on_floor_2 or this.is_on_floor_3
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

    push = function(this, dir)
        local hit = move_x(this, 1 * dir)

        if not hit then
            for c in all(entity_check_all(this, this.x, this.y - 1, class_crate)) do
                c.push(c, dir)
            end
        end

    end,
}
add(classes, class_crate)

class_exit = {
    name = "exit",
    tile = 4,
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
    sprite = 7,

    tile = 3,

    sprite_y = 6,
    hitbox_x = 8,
    hitbox_y = 2,
}
add(classes, class_spike)

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
    tile = 13,
    sprite = 22,
    tread_dir = -1,
    sheet_x = 48,
    sheet_y = 8,
}
add(classes, class_treadmill_left)

class_treadmill_right = {
    inherit_from = class_treadmill,
    tile = 14,
    sprite = 24,
    tread_dir = 1,
    sheet_x = 72,
    sheet_y = 8,
}
add(classes, class_treadmill_right)

class_button_red = {
    name = "button_red",
    tile = -1,
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
    tile = -1,
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
menuitem(1, "reset level", tiled_load)

function last_room()
    room_change = -1
    tiled_load()
end

menuitem(2, "prev room", last_room)

function next_room()
    room_change = 1
    tiled_load()
end

menuitem(3, "next room", next_room)

function toggle_debug()
    debug = not debug
end

menuitem(4, "toggle debug", toggle_debug)

__gfx__
000000002222222200999990000000000099999000999990009999900000000000cccc0000000000000000000000000000000000880880888800008888888888
00000000224444220099999900999990009999990099999900999999000000000c7777c000000000000000000000000000000000800000088880088882222228
007007002424424200fcffc00099999900fcffc000fcffc000fcffc000000000c777777c00000000000000000000000000000000000000000888888082222228
000770002442244200fffff000fcffc000fffff000fffff0f8fffff000000700c777777c00000000000000000000000000000000800000080088880082222228
00077000244224428888888888fffff888888888888888880088880d07000700c777777c00000000000000000000000000000000800000080088880082222228
0070070024244242f088880ff088880ff088880ff088880fd8888f8d07007770c777777c00000000000000000000000008888880000000000888888082222228
0000000022444422088008800880088008800dddddd00880d880088d777077700c7777c000000000000000000000000088888888800000088880088882222228
0000000022222222ddd00dddddd00dddddd0000000000dddd00000007770777000cccc0000000000000000000000000088888888880880888800008888888888
66577666d555555d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb0bb0bb88000088bbbbbbbb
6d576666577666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000b88800888b333333b
dd5666665755556500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888880b333333b
55555555565555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000b00888800b333333b
66666577565555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000b00888800b333333b
6666d576565555d5000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbb00000000008888880b333333b
666dd56656666dd500000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbb000000b88800888b333333b
55555555d555555d00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb0bb0bb88000088bbbbbbbb
03330000030303300000555000000000000000000000000000000500000000000000000000000000000000000000000055559995880000885999555588000088
03030330030303300550505000000000000000000000000000550000000000000000000000000000000000000000000055599955888008885599955588800888
03330330033300000550555000000000000000000000000050550000000000000000000000000000000000000000000055999555088888805559995508888880
00000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000059995555008888005555999500888800
03303330330303000555055000000000000000000000000000505505000000000000000000000000000000000000000059995555008888005555999500888800
03303030330333000505055000000000000000000000000000005500000000000000000000000000000000000000000055999555088888805559995508888880
00003330000000000555000000000000000000000000000005000000000000000000000000000000000000000000000055599955888008885599955588800888
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000055559995880000885999555588000088
04400200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000220000000000000000000000000000000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000
04400020003330330000000000000000000000000000000050550050000000000000000000000000000000000000000000000000000000000000000000000000
00400220003030330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04400200003000000000000000000000000000000000000000505505000000000000000000000000000000000000000000000000000000000000000000000000
04000220000033300000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000
04400020033030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400220033030300000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003330000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030330000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003330330000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003303330000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003303030000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003330000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400020000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400020000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400020000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400020000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400220000000000000000000000000
0000000000000000d555555d66577666665776666657766666577666665776666657766666577666665776666657766666577666d555555d0000000000000000
0000000000000000577666656d5766666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d576666577666650000000000000000
000000000000000057555565dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666575555650000000000000000
00000000000000005655556555555555555555555555555555555555555555555555555555555555555555555555555555555555565555650000000000000000
00000000000000005655556566666577666665776666657766666577666665776666657766666577666665776666657766666577565555650000000000000000
0000000000000000565555d56666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d576565555d50000000000000000
000000000000000056666dd5666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd56656666dd50000000000000000
0000000000000000d555555d55555555555555555555555555555555555555555555555555555555555555555555555555555555d555555d0000000000000000
00000000000000006657766600005550000000000000000000000000030303300303033000000000000055500000000000000000665776660000000000000000
00000000000000006d576666055050500000000000000000000000000303033003030330000000000550505000000000000000006d5766660000000000000000
0000000000000000dd56666605505550000000000000000000000000033300000333000000000000055055500000000000000000dd5666660000000000000000
00000000000000005555555500000000000000000000000000000000000003000000030000000000000000000000700000000000555555550000000000000000
00000000000000006666657705550550000000000000000000000000330303003303030000000000055505500000000000000000666665770000000000000000
00000000000000006666d576050505500000000000000000000000003303330033033300000000000505055000ccc7c0000000006666d5760000000000000000
0000000000000000666dd5660555000000000000000000000000000000000000000000000000000005550000ccccccccc0000000666dd5660000000000000000
000000000000000055555555000000000000000000000000000000000000000000000000000000000000000ccc77777ccc000000555555550000000000000000
00000000000000006657766600000000009999900000000000005550000000000000000000000000000000ccc7777777ccc05550665776660000000000000000
00000000000000006d57666600000000009999990000000005505050000000000000000000000000000000cc777777777cc050506d5766660000000000000000
0000000000000000dd5666660000000000fcffc0000000000550555000000000000000000000000000000cc77777777777cc5550dd5666660000000000000000
0000000000000000555555550000000000fffff0000000000000000000000000000000000000000000000cc77777777777cc0000555555550000000000000000
0000000000000000666665770000000088888888000000000555055000000000000000000000000000000cc77777777777cc0550666665770000000000000000
00000000000000006666d57600000000f088880f000000000505055000000000000000000000000000000cc77777777777cc05506666d5760000000000000000
0000000000000000666dd5660000000008800880000000000555000000000000000000000000000000000cc77777777777cc0000666dd5660000000000000000
00000000000000005555555500000000ddd00ddd0000000000000000000000000000000000000000000000cc777777777cc00000555555550000000000000000
0000000000000000d555555d66577666665776666657766666577666665776666657766666577666665776ccc7777777ccc77666d555555d0000000000000000
0000000000000000577666656d5766666d5766666d5766666d5766666d5766666d5766666d5766666d57666ccc77777ccc576666577666650000000000000000
000000000000000057555565dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666cccccccccd566666575555650000000000000000
000000000000000056555565555555555555555555555555555555555555555555555555555555555555555555ccccc555555555565555650000000000000000
00000000000000005655556566666577666665776666657766666577666665776666657766666577666665776666657766666577565555650000000000000000
0000000000000000565555d56666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d5766666d576565555d50000000000000000
000000000000000056666dd5666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd566666dd56656666dd50000000000000000
0000000000000000d555555d55555555555555555555555555555555555555555555555555555555555555555555555555555555d555555d0000000000000000
00000000000000000000000000000000044002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000040002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000044000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000004002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000044002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000040002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000044000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000004002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000030303300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000033303300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000033033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000033030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000707077707000707000000700707077707770707000007770777077700770707000007070777070700770070000000000000000000000
00000000000000000000707070707000707000007000707007000700707000007070707070707070707000007070700070707000007000000000000000000000
00000000000000000000707077707000770000007000707007000700777000007770770077007070707000007700770077707770007000000000000000000000
00000000000000000000777070707000707000007000777007000700707000007070707070707070777000007070700000700070007000000000000000000000
00000000000000000000777070707770707000000700777077700700707000007070707070707700777000007070777077707700070000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000e00003f6711b651096410363100621006113a70108701137011470111501147011470113701137011270111701107010d7010d7010c7010c7010c701006010060100601006010060100601006010060100601
000500000044202402054020440200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
0003000002450064500a4500e45012450164401a4301e420224100040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
00050000224501e4501a65016650126500e6400a63005620016100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500000b450064501a650166400f630086200261005600016000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0005000022450264501a65016650126500e6400a63005620016100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00040000240510c0010d0011200119001240012b0011b00122001260012a001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
0112000003744030250a7040a005137441302508744080251b7110a704037440302524615080240a7440a02508744087250a7040c0241674416025167251652527515140240c7440c025220152e015220150a525
011200000c033247151f5152271524615227151b5051b5151f5201f5201f5221f510225212252022522225150c0331b7151b5151b715246151b5151b5051b515275202752027522275151f5211f5201f5221f515
011200000c0330802508744080250872508044187151b7151b7000f0251174411025246150f0240c7440c0250c0330802508744080250872508044247152b715275020f0251174411025246150f0240c7440c025
011200002452024520245122451524615187151b7151f71527520275202751227515246151f7151b7151f715295202b5212b5122b5152461524715277152e715275002e715275022e715246152b7152771524715
011200002352023520235122351524615177151b7151f715275202752027512275152461523715277152e7152b5202c5212c5202c5202c5202c5222c5222c5222b5202b5202b5222b515225151f5151b51516515
011200000c0330802508744080250872508044177151b7151b7000f0251174411025246150f0240b7440b0250c0330802508744080250872524715277152e715080242e715080242e715246150f0240c7440c025
__music__
00 40424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 07424344
00 07424344
00 07084344
00 07084344
01 07084344
00 07084344
00 090a4344
02 0b0c4344

