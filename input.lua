function input()
    if btn(0) then
        player.a+=0.0125
    elseif btn(1) then
        player.a-=0.0125
    end

    if btn(2) then
        player.vx = mid(-1, player.vx + 0.008 * (cos(player.a)) * -1, 0.8)
        player.vy = mid(-1, player.vy + 0.008 * (sin(player.a)) * -1, 0.8)
        player.state = "accel"
        if noise != 1 then
            sfx(1)
            noise = 1
        end
    else
        player.state = "stale"
        noise = 0
        sfx(1,-2)
    end

    if (btnp(4) or btnp(5)) and shoot_delay <= 0 then
        sfx(0)
        add(bullets, bullet:new())
        shoot_delay=20
    else
        shoot_delay-=1
    end
        
end