entity = {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    size = 0,
    col = 1,

    new = function (self,tbl)
        tbl = tbl or {}
        setmetatable(tbl, {
            __index = self
        })
        return tbl
    end,

    collision = function(self,obj)
        if obj.cx1 > self.cx2 or
           obj.cx2 < self.cx1 or 
           obj.cy1 > self.cy2 or
           obj.cy2 < self.cy1 then
            return false
        end
        sfx(2)
        return true
    end,
    draw_collision = function(self)
        rect(self.cx1,self.cy1,self.cx2,self.cy2,8)
    end
}

player = entity:new({

    update = function(self)
        self.x+=self.vx
        self.y+=self.vy
        if self.a > 1 then
            self.a=0.0125
        elseif self.a<0 then
            self.a=0.9875
        end

        if self.x > 128 + self.size then
            self.x-=128+self.size
        elseif self.x < 0 - self.size then
            self.x+=128+self.size
        end

        if self.y > 128 + self.size then
            self.y-=128+self.size
        elseif self.y < 0 - self.size then
            self.y+=128+self.size
        end

        self.x2 = self.x + cos(self.a+self.angle) * self.size
        self.y2 = self.y + sin(self.a+self.angle) * self.size
        self.x3 = self.x + cos(self.a-self.angle) * self.size
        self.y3 = self.y + sin(self.a-self.angle) * self.size

        self.cx1 = min(self.x,min(self.x2,self.x3)) + 1
        self.cx2 = max(self.x,max(self.x2,self.x3)) - 1
        self.cy1 = min(self.y,min(self.y2,self.y3)) + 1
        self.cy2 = max(self.y,max(self.y2,self.y3)) - 1
    end,

    draw = function(self)
        if self.state == "accel" then
            line(self.x2, self.y2, self.x2 + cos(self.a) * 2, self.y2 + sin(self.a) * 2,0x9a)
            line(self.x3, self.y3, self.x3 + cos(self.a) * 2, self.y3 + sin(self.a) * 2,0x9a)
        end
        line(self.x2,self.y2,self.x3,self.y3, 0x55)
        line(self.x,self.y,self.x2,self.y2, 0x67)
        line(self.x3,self.y3,self.x,self.y, 0x67)
    end
})

asteroid = {
    new = function(self, tbl)
        tbl = entity.new(self, tbl)
        tbl.size = tbl.size or rnd({2,4,8})
        tbl.x = tbl.x or rnd({0-rnd(self.size),128+rnd(self.size)})
        tbl.y = tbl.y or rnd(128)
        tbl.vx = tbl.vx or rnd(0.5) * rnd({-1,1})
        tbl.vy = tbl.vy or rnd(0.5) * rnd({-1,1})
        tbl.col = tbl.col or rnd({0x5e, 0x65, 0xd5})
        tbl.cx1 = tbl.x-(tbl.size)
        tbl.cx2 = tbl.x+(tbl.size)
        tbl.cy1 = tbl.y-(tbl.size)
        tbl.cy2 = tbl.y+(tbl.size)
        return tbl
    end,

    update = function(self)
        self.x+=self.vx
        self.y+=self.vy

        if self.x > 128 + self.size then
            self.x-=128+self.size
        elseif self.x < 0 - self.size then
            self.x+=128+self.size
        end

        if self.y > 128 + self.size then
            self.y-=128+self.size
        elseif self.y < 0 - self.size then
            self.y+=128+self.size
        end

        self.cx1 = self.x-(self.size + 1)
        self.cx2 = self.x+(self.size + 1)
        self.cy1 = self.y-(self.size + 1)
        self.cy2 = self.y+(self.size + 1)

    end,

    draw = function(self)
        circfill(self.x, self.y, self.size+1,0)
        circfill(self.x, self.y, self.size,self.col)
    end,

    collision = function (self, obj)
        collided = entity.collision(self,obj)
        if collided then
            add(effects,explosion:new({x=self.x, y=self.y}))
            score+=1
            if self.size == 2 then
                del(asteroids,self)
            else
                self.size \= 2
                self.vx += obj.vx / 4
                self.vy += obj.vy / 4
                add(asteroids,asteroid:new({
                    size = self.size,
                    x = self.x,
                    y = self.y,
                    vx = self.vx * rnd({-1, -0.5, 0.5, 0.75}),
                    vy = self.vy * rnd({-1, -0.5, 0.5, 0.75}),
                    col = self.col
                }))
            end
            del(bullets,obj)
        end
    end
}

bullet = {
    new = function (self, tbl)
        tbl = entity.new(self, tbl)
        tbl.x = player.x
        tbl.y = player.y
        tbl.vx = 1 * (cos(player.a)) * - 1
        tbl.vy = 1 * (sin(player.a)) * - 1
        return tbl
    end,

    update = function(self)
        if self.x < 0 or self.x > 128 or self.y < 0 or self.y > 128 then
            del(bullets,self)
        else
            self.x+=self.vx
            self.y+=self.vy

            self.cx1 = self.x
            self.cx2 = self.x
            self.cy1 = self.y
            self.cy2 = self.y
        end
    end,

    draw = function(self)
        circfill(self.x,self.y,0,7)
    end
}

explosion = {
    new = function (self, tbl)
        tbl = entity.new(self, tbl)
        tbl.size = tbl.size or 2
        tbl.life = 12
        return tbl
    end,

    update = function (self)
        if self.life > 0 then
            self.life-=1
        else
            del(effects, self) 
        end
    end,

    draw = function (self)
        circfill(self.x, self.y, self.size+(self.life/4), 10)
        circfill(self.x, self.y, self.size/2+(self.life/4), 9)
        circfill(self.x, self.y, self.size/2+(self.life/4)-1, 8)
    end
}

star = {
    new = function (self, tbl)
        tbl = entity.new(self, tbl) 
        tbl.x = rnd(128)
        tbl.y = rnd(128)
        tbl.v = rnd(0.01)
        tbl.size = rnd({0,1})
        tbl.col = rnd({0,3,13})
        tbl.type = rnd({"square","circle"})
        return tbl
    end,

    update = function (self)
        self.x += self.v
        if self.x > 128 + self.size then
            self.x-=128+self.size
        end
    end,

    draw = function (self)
        if self.type == "square" then
            rectfill(self.x, self.y,self.x+self.size,self.y+self.size,self.col)
        elseif self.type == "circle" then
            circfill(self.x, self.y, self.size, self.col)
        end
    end

}

planet = {
    new = function (self, tbl)
        tbl = entity.new(self, tbl) 
        tbl.x = rnd({34 + rnd(8), 94 - rnd(8)})
        tbl.y = rnd({34 + rnd(8), 94 - rnd(8)})
        --tbl.v = rnd(0.01)
        return tbl
    end,

    update = function (self)
    end,

    draw = function (self)
        circfill(self.x, self.y, 33, 0)
        circfill(self.x, self.y, 31, 14)
        pal(2,-14,1)
        circfill(self.x + 4, self.y-3, 27, 2)
        fillp(0x0100010001000100)
        circfill(self.x + 4, self.y-3, 26, 0xe2)
    end

}