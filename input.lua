function input()
    if btn(0) then
        player.a+=0.0125
    elseif btn(1) then
        player.a-=0.0125
    end

    if btn(2) then
        player.vx = mid(-1, player.vx + 0.012 * (cos(player.a)) * -1 ,1)
        player.vy = mid(-1, player.vy + 0.012 * (sin(player.a)) * -1, 1)
        player.state = "accel"
    else
        player.state = "stale"
    end

    if(btnp(4)) then
        add(bullets, bullet:new())
    end
        
end