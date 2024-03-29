pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

-- PICO-Crate
-- by Harmony Honey
-- HarmonyHunnie.com 
--
-- Music created by Gruber
-- Pico-8 Tunes Volume 1
-- https://www.lexaloffle.com/bbs/?tid=29008
-- https://gruber99.bandcamp.com/album/pico-8-tunes-vol-1
--
-- Maps created in Tiled
-- converted for tiled_room using tiled.py


-- global vars
ent_table = {}
classes = {}

flag_solid = 0

--gravity = 0.2

room = 1
room_text = ""
room_change = 0
load_timer = 0

debug = false

death_count = 0
death_length = 4

start_time = 0
time_elapsed = 0
time_min = "00"
time_sec = "00"

is_win = false
win_time = 3600
win_record = "0|00:00"
win_length = 0



tiled_room = {
    "0000000000000000000000000000000000000000000000000000000000009000000000000000a000000000000000a0000065555555555600005e000cc0e00500005010e00004e50000655555555556000000a0000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000,walk (with arrow keys)",
    "0000000000000000000000000000000000000000000000000000000000000000000b0b000b0b0000006555555555560000500000e00005000050e09000040500005100a000e0050000655563365556000055555555555500000000000000a0000000000000009000000000000000000000000000000000000000000000000000,jump (with z key)",
    "000b990000000000000999000000000000099c00000000000000a00000bb0000006555555555560000500c0c00000500005e00000e0405000050000000000500005000e0b99005000050000099c0e500005e00000a00050000501002ba0e0500006555555555560000000a000000a00000000a000000c00000000c0000000000,push me",
    "000000b99000000000000099c0000000000bb00a00bb0000000655555555600000050a000040500000050900e0005000000500000000500000050000000e50000005000e0000500000050000000b500000050e000655600000051002b555500000065555565550000000ccc0000a00000000000000b99000000000000099c000,pickup (with x key)",
    "0000b99000000000000099c00000000000000a0000000000000065555556000000066c04ccc6600000050000000c500000050000e000500000060e00000050000005000000e060000005000e000050000005b200102b500000065555555560000000000000a00000000000000b99000000000000099c00000000000000000000,stack two",
    "00000000000000000000000000000000000000000000000000000000000000000065555555555600005000e0000e0500005e00000000450000500000e00005000050e0000000e5000052010e00000500006555633333350000555555555556000000000000000000000000000000000000000000000000000000000000000000,toss n cross",
    "000b9900000000000009990000000000000999000000000000099c00000b00000000a00b000a0bb000655555655555600050e0055500e050005000e656004050005221000e000e50006555533355556000a000655560ac0000c0000cc000a000000000000000a0000000000000b99990000000000099999000000000009999c0,push bridge",
    "0000000000b99000000000000099c00000000000000a00000065555555555600005ccc040ccc050000500000000005000050e000000005000050000000e005000050000e00000500005000000000050000500e00000025000050000010e2250000655555555556000000a0000000000000009000000000000000000000000000,stack three",
    "000000000000000000000000000000000000000000000000655555555555555650ccc000000ccc0550000000000000e55000000b9900000550e000099c00000550000e00a000e006500003333333000552e006555556040552010555555500b5655556555556555600a00000000000000b99000000000000099c000000000000,spike hill",
    "000000000000000000000655555600000000050000450000000005e000050000000005000005000000000500e035000000000500006500000000050e000500000000053000e500000000056000050000000005000e05000000000500003500000000052e00650000000005221005000000000655555600000000000000000000,up up up",
    "000000000000000000000000000000000065555555555600005c0cc400cc05000050000000000500005000000e0005000050e000000005000050000000e005000050000000000500005000e0000025000050900000022500005ba00010e2b5000065555555555600000000000000a000000000000000a0000000000000009000,stack four",
    "00b99000000000000099c00000000000000a00000000000000ba0000000000006555555555555556500000000ccc00055000e00000000e05540000e0000e0005500000000000002550e0000000e01025533333333333655665555555555565550000ccc000000a00000000000000b990000000000000999000000000000099c0,stepping stones",
    "00000000000000000000000000000000655555555555555650000e00000000055040000000e000055e0000000000000550000000e00000055000e0000000000555600000000e0005555000e0000000255550000000000e25555000000e0010255553333333336556556555555555655500000000000000000000000000000000,cross n stack",
    "000000000000000000000000000000000065555555555600005000e04000050000500000000e050000500000000005000050e000000005000050000000e005000050000000000500005000e00000050000500000000025000050000000e225000050e00010022500006555555555560000000000000000000000000000000000,stairway to heaven",
    "00000000000000000000000000000000000000000000000065555555555555565000e00000000005500000000000e0055000000e0000000550e000000000040550000000000000055000000030e0000552100e0050000e0565563333533333355555555565555556000000000000000000000000000000000000000000000000,spike long jump",
    "000000000000000000006555555600000000500040e5000000005e000005000000005000000500000000500000050000000050000e050000000050e000050000000050000065000000005000e055000000005e000055000000005000656500000000500e55550000000052105555000000006555655500000000000000000000,throw n dodge",
    "000000000000000000000000000000000655555555555560050000000000e050050400000000005005000000e00000500500e00000000050050000000000015005000000e000025005e00000000e025005000000000022500500000e000222500533333333365560065555555556555000000000000000000000000000000000,spike stack",
    "000000000000000000000000000000006555555555555556500000e0000000055000000000e00405500e00000000000550000000000000e55000000e0000000550e0000000e0333550000e0000006556520003333333555552e00655555565555201055555555555655556555555555500000000000000000000000000000000,spike stairs",
    "00000b9b0000000000006555555600000000500c9c05000000005040000500000b90500000050000099d500e00b5000009c050000065000000005e0000550000000050000055000000005000e055000000005000005500000000500006550000000052e005550b9900005221b555d999000065555655099c0000000000000000,two solutions",
    "655555555556000050cc00ccc0e5000050e000000005d900500000e0000500005000e000020500005e100000e2b50000655600e055560000005000005cc00b990050b9905000099c0050999050bb00a00050999065555556005099c0000000e500500a000e0004059d5e0a00000e000500533333333333350065555555555556,down the boot",
    "65555555555555555ccc00cc00a0065550100000e0c00065522220000000e0055555563333000005555555555600b99555600a0e0000999556000900000099c5500e000000e00a0550000033336555555b99006555555555599c0000cc00ccc550a000e0000004055ba00000000e000555555633333333355555555555555556,the big two",
    "6555555555555556500cc00a00ccc00550000e0900000005500000000e00000550e0333333300e05500065555550000550405cc0000000b553335000b9900056655560e0999000055cc0c00099c0e005500000000a003335500e00000a0065555220033333335555522006555555555552210555555555556555555555555555,the final challenge",
}

-- core loop
function _init()
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
        if e.is_moving and (e.speed_x != 0 or e.speed_y != 0) then
            move(e)
        end

        if e.is_using_gravity then
            e.speed_y += e.gravity
        end
    end

    if load_timer > 0 then
        load_timer -= 1

        if load_timer == 0 then
            tiled_load()
        end
    end

    
    -- enable debug
    if not debug and btn(4, 1) and btn(4) and btn(5) then
        debug_enable()
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

    -- timer
    time_elapsed = time() - start_time
    time_min = tostr(flr(time_elapsed / 60))
    time_sec = tostr(flr(time_elapsed % 60))
    if #time_min == 1 then
        time_min = "0"..time_min
    end
    if #time_sec == 1 then
        time_sec = "0"..time_sec
    end

end

function _draw()
    cls()
    -- map
    map(0, 0, 0, 0, 128, 64)

    -- draw ents
    for e in all(ent_table) do
        e.draw(e)
    end

    -- death count
    rectfill(0,0, 11 + death_length, 8, 0)
    spr(9, 1, 0)
    print(death_count, 11, 2, 7)

    -- timer
    rectfill(97, 0, 128, 8, 0)
    print(time_min..":"..time_sec, 99, 2, 7)
    spr(11, 120, 1)

    -- winner
    if is_win then
        rectfill(62 - win_length / 2, 0, 64 + win_length / 2, 8, 0)
        print(win_record, 64 - win_length / 2, 2, 11)
    end

    -- room 1
    if room == 1 then
        print("pico-crate", 33, 16, 9)
        print("by harmony honey", 21, 29, 10)
    end

    -- room text
    -- l = text_length, px = print_x, py = print_y
    local l = #room_text * 4
    local px = 64
    local py = 122
    rectfill(px - (l / 2) - 1, py - 1, px + (l / 2) - 1, py + 5, 0)
    color(7)
    print(room_text, px - (l / 2), py)

    -- debug text
    if debug then
        cursor(0, 8, 8)
        print("stat: "..stat(1))
        print("ent: "..#ent_table)
        print("room: "..room)
    end
end

-- functions

-- easier than typing flr(arg + 0.5)
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

-- custom map loader using data copied from tiled
function tiled_load()
    -- clear entities
    ent_table = {}

    -- reload map data from cartridge (clear to blank for now)
    reload(0x2000, 0x2000, 0x1000)

    -- advance room
    if room_change != 0 then
        room = room + sgn(room_change)

        -- you win
        if room == #tiled_room + 1 then
            is_win = true
            if time_elapsed < win_time then
                win_time = time_elapsed
                win_record = tostr(death_count).."-"..time_min..":"..time_sec
                win_length = #win_record * 4
            end
            room = 1
            start_time = time()
            death_count = 0
        end

        room = mid(1, room, #tiled_room)
        room_change = 0
    end

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
            mset(x, y, 50)
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

    -- if room == #tiled_room - 1 then load_win() end

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
            y = this.y + 4,
            hitbox_x = this.hitbox_x,
            hitbox_y = 8,
        }
        hit = check_solid_tile_x(test, distance)
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

-- return distance of upcoming move
function move_get_distance(this)
    return {
        x = round(this.remainder_x + this.speed_x),
        y = round(this.remainder_y + this.speed_y),
    }
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

function entity_find(class, ignore)
    for e in all(ent_table) do
        if e.name == class.name and e != ignore then
            return e
        end
    end
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

-- debug funcs
function debug_enable()
    sfx(13)
    debug = true
    menuitem(4, "disable debug", debug_disable)
end

function debug_disable()
    debug = false
    menuitem(4)
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
    gravity = 0.2,

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
        spr(this.sprite, this.x - this.sprite_x + this.draw_offset_x, this.y - this.sprite_y + this.draw_offset_y,
            1, 1, this.flip_x, this.flip_y)
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
    move_slow = 0.8,
    move_accel = 0.1,
    move_last = 0,
    push_speed = 0.3,

    gravity = 0.25,
    jump_speed = 2,
    jump_frames = 10,
    jump_count = 0,
    is_jump = false,

    anim_frame = 0,
    anim_step_run = 0.2,
    anim_step_idle = 0.04,

    is_holding_crate = false,

    speed_drop_x = 1,
    speed_drop_y = -1,

    speed_throw_x = 1.0,
    speed_throw_y = -2.5,

    speed_throw_fast_x = 1.7,
    speed_throw_fast_y = -2.5,

    speed_throw_high_x = 0.7,
    speed_throw_high_y = -3.5,

    update = function(this)
        -- check for spikes
        if this.speed_y > 0 and entity_check(this, this.x, this.y, class_spike) != nil then
            this.death(this)
            death_count += 1
            death_length = #tostr(death_count) * 4
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

        -- start jump
        if btn_press(4) and this.check_jump(this) then
            --this.speed_y = -this.jump_speed
            this.sprite = this.sprite_jump
            this.draw_offset_y = 0
            sfx(6)
            this.is_jump = true
            this.jump_count = 0
        end

        -- jump height
        if this.is_jump then
            if btn(4) then
                this.speed_y = -this.jump_speed
                this.jump_count += 1
                if this.jump_count > this.jump_frames then
                    this.is_jump = false
                end
            else
                this.is_jump = false
            end
        end

        -- crate pickup / throw
        if this.is_holding_crate then
            if btn_press(5) then
                this.crate_throw(this)
                --[[
                if btn(0) or btn(1) then
                    this.crate_throw_fast(this)
                else
                    this.crate_throw(this)
                end
                --]]
            end
        elseif btn_press(5) then
            local dir = sgn(numbool(not this.flip_x) - 1)
            local e = entity_check(this, this.x, this.y + 1, class_crate)
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
        if this.is_on_floor and move_get_distance(this).x != 0 then
            local dir = this.get_dir(this)
            local e = entity_check(this, this.x + dir, this.y, class_crate)
            if e != nil then
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
        
        --treadmill_move(this)
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

    crate_throw_fast = function(this)
        local c = this.crate_release(this)
        local dir = this.get_dir(this)
        c.speed_x = this.speed_throw_fast_x * dir
        c.speed_y = this.speed_throw_fast_y
        sfx(5)
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

    is_pushed = false,

    update = function(this)
        if this.speed_x != 0 and this.is_on_floor then
            this.speed_x = 0
        end

        this.is_pushed = false
    end,

    push = function(this, dir)
        local hit = move_x(this, 1 * dir)

        if not hit then
            this.is_pushed = true
            for c in all(entity_check_all(this, this.x, this.y - 1, class_crate)) do
                -- only be pushed by 1 crate
                if not c.is_pushed then
                    c.push(c, dir)
                end
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
000000004444444400999990000000000099999000999990009999900000000000cccc0000000000007777000077700000000000000000000000000000000000
00000000449999440099999900999990009999990099999900999999000000000c7777c007777770070000700700070000000000000000000000000000000000
007007004949949400fcffc00099999900fcffc000fcffc000fcffc000000000c777777c77777777700700077007007000000000000000000000000000000000
000770004994499400fffff000fcffc000fffff000fffff0f8fffff000000700c777777c77700700700700077007707000000000000000000000000000000000
00077000499449948888888888fffff888888888888888880088880d07000700c777777c77700700700077077000007000000000000000000000000000000000
0070070049499494f088880ff088880ff088880ff088880fd8888f8d07007770c777777c07777777700000070700070000000000000000000000000000000000
0000000044999944088008800880088008800dddddd00880d880088d777077700c7777c000070707070000700077700000000000000000000000000000000000
0000000044444444ddd00dddddd00dddddd0000000000dddd00000007770777000cccc0000000000007777000000000000000000000000000000000000000000
66577666d555555d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d576666577666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd566666575555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555565555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666577565555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666d576565555d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd56656666dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555d555555d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03330000030303300000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030330030303300550505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03330330033300000550555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03303330330303000555055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03303030330333000505055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003330000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04400200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04400020003330330444044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400220003030334404440400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04400200003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000220000033302022202200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04400020033030302220222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400220033030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001
00000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001
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
00000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001
00000000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000001
__gff__
0000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000e00003f6511b641096310362100611006113a70108701137011470111501147011470113701137011270111701107010d7010d7010c7010c7010c701006010060100601006010060100601006010060100601
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
000400000b250242500e25029250122502c25016250242501925020250162501c2500b200212002e2002820032200382003f20000200002000020000200002000020000200002000020000200002000020000200
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

