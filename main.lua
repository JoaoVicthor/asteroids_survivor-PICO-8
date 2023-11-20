function _init()
    asteroids = {}
    for i=1,8 do
        add(asteroids, asteroid:new())
    end
    bullets = {}
    score = 0
    frame = 1
end

function _update60()
    input()
    player:update()
    foreach(asteroids, function (obj) obj:update() end)
    foreach(bullets, function(obj)
        if obj.x < 0 or obj.x > 128 or obj.y < 0 or obj.y > 128 then
            del(bullets,obj)
        else
            obj:update()
        end
    end)

    foreach(asteroids, function (ast)
        if player:collision(ast) then
            extcmd("shutdown")
        end
        foreach(bullets, function (bul)
            ast:collision(bul)
        end)
    end)

    if frame%300 == 0 then
        add(asteroids, asteroid:new())
        frame = 1
    else
        frame+=1
    end
end

function _draw()
    cls()
    player:draw()
    foreach(asteroids, function (obj) obj:draw() end)
    foreach(bullets, function(obj) obj:draw() end)
    print("score: "..score, 8,8,6)
end