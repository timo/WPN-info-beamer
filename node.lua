gl.setup(800, 600)

W = 800
H = 600

json = require("json")

util.auto_loader(_G)

ship_leader = { { "player 1", 99 }, { "player 2", 50 } }
metal_leader = { { "player 3", 99 }, { "player 4", 50 } }
base_leader = { { "player 5", 99 }, { "player 6", 50 } }

util.file_watch("wpn_stats.json", function(content)
    jsd = json.decode(content)
    ship_leader = jsd["ships"]
    metal_leader = jsd["metal"]
    base_leader = jsd["bases"]
end)

font = resource.load_font("silkscreen.ttf")

ship_pos = {}
ship_dir = {}
ship_turn = {}
ship_types = {}

for i = 1,10 do
    table.insert(ship_pos, {math.random() * W, math.random() * H})
    table.insert(ship_dir, {math.random() * 2 * math.pi, math.random() * 50 + 20})
    table.insert(ship_turn, math.random() * 0.1)
    table.insert(ship_types, math.ceil(math.random() * 4))
end

ship_type_names = {"small", "large", "medium", "small"}
ship_img = {}
for _, i in ipairs(ship_type_names) do
   table.insert(ship_img, resource.load_image("ship_" .. i .. ".png"))
end

planet_img = resource.load_image("planet.png")
planet_pos = {}
planet_rot = {}

for i = 1, 5 do
    table.insert(planet_pos, {math.random() * W, math.random() * H, math.random()})
    table.insert(planet_rot, {math.random() * 360, math.random() * 30 - 15})
end

function move_ships()
    for i = 1,10 do
        if math.random() < 0.2 then
            ship_turn[i] = ship_turn[i] + (math.random() * 0.5) * dt
            if ship_turn[i] > 4 then
                ship_turn[i] = 4
            elseif ship_turn[i] < -4 then
                ship_turn[i] = -4
            end
        elseif math.random() < 0.2 then
            ship_turn[i] = ship_turn[i] - (math.random() * 0.5) * dt
        end
        ship_dir[i][1] = ship_dir[i][1] + ship_turn[i] * dt
        ship_pos[i][1] = ship_pos[i][1] + math.sin(ship_dir[i][1]) * ship_dir[i][2] * dt
        ship_pos[i][2] = ship_pos[i][2] + math.cos(ship_dir[i][1]) * ship_dir[i][2] * dt

        ship_pos[i][1] = ((ship_pos[i][1] + 100) % (W + 200) - 100)
        ship_pos[i][2] = ((ship_pos[i][2] + 100) % (H + 200) - 100)
    end
end

function draw_ships()
    for i, pos in ipairs(ship_pos) do
        dir = ship_dir[i][1]
        gl.pushMatrix()
        gl.translate(pos[1], pos[2], 0)
        gl.rotate(-dir * 360 / (2 * math.pi) + 180,0,0,1)

        img = ship_img[ship_types[i]]
        w, h = img:size()

        img:draw(-w / 2, -h / 2, w / 2, h / 2)
        gl.popMatrix()
    end
end

function move_draw_planets()
    for i, pos in ipairs(planet_pos) do
        planet_rot[i][1] = planet_rot[i][1] + planet_rot[i][2] * dt

        gl.pushMatrix()
        gl.translate(pos[1], pos[2])
        gl.rotate(planet_rot[i][1], 0, 0, 1)
        gl.scale(pos[3], pos[3], 1)
        w, h = planet_img:size()
        planet_img:draw(-w / 2, -h / 2, w / 2, h / 2)

        gl.popMatrix()
    end
end

last_move_time = sys.now()
dt = 0
function node.render()
    gl.clear(0, 0, 0, 1)
    dt = sys.now() - last_move_time
    last_move_time = sys.now()

    move_draw_planets()

    move_ships()

    draw_ships()

    font:write(10, 10, "WPN Leaderboard", 50, 1, 1, 1, 1)

    font:write(10, 100, "Schiffe (in slots):", 35, 1, 1, 1, 1)

    font:write(10, 150, "1." .. ship_leader[1][1] .. " (" .. ship_leader[1][2] .. ")" , 30, 1, 1, 1, 1)
    font:write(20, 190, "2." .. ship_leader[2][1] .. " (" .. ship_leader[2][2] .. ")" , 25, 1, 1, 1, 1)

    font:write(30, 250, "Metall:", 35, 1, 1, 1, 1)
    font:write(30, 300, "1." .. metal_leader[1][1] .. " (" .. metal_leader[1][2] .. ")" , 30, 1, 1, 1, 1)
    font:write(40, 340, "2." .. metal_leader[2][1] .. " (" .. metal_leader[2][2] .. ")" , 25, 1, 1, 1, 1)

    font:write(50, 400, "Basen:", 35, 1, 1, 1, 1)
    font:write(50, 450, "1." .. base_leader[1][1] .. " (" .. base_leader[1][2] .. ")" , 30, 1, 1, 1, 1)
    font:write(60, 490, "2." .. base_leader[2][1] .. " (" .. base_leader[2][2] .. ")" , 25, 1, 1, 1, 1)
end
