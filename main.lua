function _init()
    scene = "menu"
    _init_game()
end

function _init_game()
    palt(0,false) -- black as opaque
    pal(2,-14,1)
    pal(4,-11,1)
    pal(11,-15,1)
    pal(14,-16,1)

    background = {}
    for i=1,48 do
        add(background,star:new())
    end
    add(background,planet:new())
    player = player:new({
        x = 64,
        y = 64,
        vx = 0,
        vy = 0,
        a = 0.5,
        angle = 1 / 360 * 25,
        size = 4,
        state = "stale",
    })
    player:calculate_verts()

    asteroids = {}
    for i=1,8 do
        add(asteroids, asteroid:new())
    end
    bullets = {}
    effects = {}
    score = 0
    frame = 1
    shoot_delay = 0
    --sfx(3)
end

function _update60()
    if scene == "game" then
        input()
        player:update()
        foreach(background, obj_update)
        foreach(asteroids, obj_update)
        foreach(bullets, obj_update)
        foreach(effects,obj_update)

        for ast in all(asteroids) do
            if player:collision(ast) then
                explosion:new({x=(player.x + player.x2 + player.x3) / 3, y=(player.y + player.y2 + player.y3) / 3, size = 1}):draw()
                --sfx(3,-2)
                sfx(1,-2)
                sleep(2)
                _init_game()
                break
            end
            foreach(bullets, function (bul)
                ast:collision(bul)
            end)
        end

        if frame%300 == 0 then
            add(asteroids, asteroid:new())
            frame = 1
        else
            frame+=1
        end
    elseif scene == "menu" then
        if btn()>0 then
            scene = "game"
        end
    end
end

function _draw()
    cls(11)
    foreach(background, obj_draw)
    foreach(bullets, obj_draw)
    fillp(0b1110101010111011)
    foreach(asteroids, obj_draw)
    fillp(0b0101010101010101)
    player:draw()
    fillp()
    foreach(effects,obj_draw)
    print("score: "..score, 8,8,6)
    if scene == "menu" then
        rectfill(19,31, 110, 37, 0)
        print("press any btn to start!", 20,32,7)
    end
end