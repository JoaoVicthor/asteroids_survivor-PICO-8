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
        return true
    end,
    draw_collision = function(self)
        rect(self.cx1,self.cy1,self.cx2,self.cy2,8)
    end
}

player = entity:new({
    x = 64,
    y = 64,
    a = 0.5,
    angle = 1 / 360 * 25,
    size = 4,
    state = "stale",

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
            line(self.x2, self.y2, self.x2 + cos(self.a) * 2, self.y2 + sin(self.a) * 2,-7)
            line(self.x3, self.y3, self.x3 + cos(self.a) * 2, self.y3 + sin(self.a) * 2,-7)
        end
        line(self.x2,self.y2,self.x3,self.y3, 5)
        line(self.x,self.y,self.x2,self.y2, 6)
        line(self.x3,self.y3,self.x,self.y, 6)
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
        tbl.col = rnd({6,7,13})
        tbl.cx1 = tbl.x-(tbl.size-1)
        tbl.cx2 = tbl.x+(tbl.size-1)
        tbl.cy1 = tbl.y-(tbl.size-1)
        tbl.cy2 = tbl.y+(tbl.size-1)
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

        self.cx1 = self.x-(self.size-1)
        self.cx2 = self.x+(self.size-1)
        self.cy1 = self.y-(self.size-1)
        self.cy2 = self.y+(self.size-1)

    end,

    draw = function(self)
        circ(self.x, self.y, self.size,self.col)
    end,

    collision = function (self, obj)
        collided = entity.collision(self,obj)
        if collided then
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
                    vx = self.vx * rnd({-1, -0.5, 0.5, 1}),
                    vy = self.vy * rnd({-1, -0.5, 0.5, 1})
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
        self.x+=self.vx
        self.y+=self.vy

        self.cx1 = self.x
        self.cx2 = self.x
        self.cy1 = self.y
        self.cy2 = self.y
    end,

    draw = function(self)
        circfill(self.x,self.y,0,7)
    end
}