local neutral = 300
local friend = myHero.team
local foe = neutral - friend

local mathhuge = math.huge
local mathsqrt = math.sqrt
local mathpow = math.pow
local function GetDistanceSqr(Pos1, Pos2)
    local Pos2 = Pos2 or myHero.pos
    local dx = Pos1.x - Pos2.x
    local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
    return dx^2 + dz^2
end

local function GetDistance(Pos1, Pos2)
	return mathsqrt(GetDistanceSqr(Pos1, Pos2))
end

local function GetDistance2D(p1,p2)
    local p2 = p2 or myHero
    return  mathsqrt(mathpow((p2.x - p1.x),2) + mathpow((p2.y - p1.y),2))
end

local function GetTarget(range) 
    local target = nil 
    if _G.EOWLoaded then 
        target = EOW:GetTarget(range) 
    elseif _G.SDK and _G.SDK.Orbwalker then 
        target = _G.SDK.TargetSelector:GetTarget(range) 
    else 
        target = GOS:GetTarget(range) 
    end 
    return target 
end

local function EnableOrb(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
    else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
end

local function ClosestMinion(range,team)
    local bestMinion = nil
    local closest = math.huge
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if GetDistance(minion.pos) < range and minion.team == team then
            local Distance = GetDistance(minion.pos, mousePos)
            if Distance < closest then
                bestMinion = minion
                closest = Distance
            end
        end
    end
    return bestMinion
end

local function ClosestHero(range,team)
    local bestHero = nil
    local closest = mathhuge
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if GetDistance(hero.pos) < range and hero.team == team and not hero.dead then
            local Distance = GetDistance(hero.pos, mousePos)
            if Distance < closest then
                bestHero = hero
                closest = Distance
            end
        end
    end
    return bestHero
end

class "Aatrox"

function Aatrox:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Aatrox:LoadSpells()
    Q = { Range = 650, Delay = 0.25, Speed = 450, Width = 275}
    W = { Range = 0}
    E = { Range = 1200, Delay = 0.25, Speed = 1000, Width = 120}
    R = { Range = 550}
end

function Aatrox:LoadMenu()
	Aatrox = MenuElement({type = MENU, id = "Aatrox", name = "Rugal Aimbot "..myHero.charName})
	Aatrox:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Aatrox.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Aatrox.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Aatrox.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Aatrox.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Aatrox.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Aatrox.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Aatrox:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Aatrox.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Aatrox.Draw:MenuElement({id = "E", name = "E range", value = true})
    Aatrox.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Aatrox:Tick()
    self:Spells()
end

function Aatrox:Spells()
	local target = GetTarget(3500)
    if Aatrox.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
	end
    if Aatrox.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Aatrox.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Aatrox.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Aatrox.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Aatrox.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Aatrox:Draw()
    if myHero.dead then return end
    if Aatrox.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Aatrox.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Aatrox.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Aatrox.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Aatrox.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Aatrox.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Aatrox.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Ahri"

function Ahri:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ahri:LoadSpells()
    Q = { Range = 880, Delay = 0.25, Speed = 1700, Width = 80}
    W = { Range = 700}
    E = { Range = 975, Delay = 0.25, Speed = 1600, Width = 50}
    R = { Range = 450}
end

function Ahri:LoadMenu()
	Ahri = MenuElement({type = MENU, id = "Ahri", name = "Rugal Aimbot "..myHero.charName})
	Ahri:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Ahri.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Ahri.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ahri.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Ahri.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Ahri.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ahri.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Ahri:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Ahri.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Ahri.Draw:MenuElement({id = "W", name = "W range", value = true})
    Ahri.Draw:MenuElement({id = "E", name = "E range", value = true})
    Ahri.Draw:MenuElement({id = "R", name = "R range", value = true})
    Ahri.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Ahri:Tick()
    self:Spells()
end

function Ahri:Spells()
	local target = GetTarget(1000)
    if Ahri.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
	end
    if Ahri.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ahri.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ahri.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ahri.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Ahri.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Ahri:Draw()
    if myHero.dead then return end
    if Ahri.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Ahri.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Ahri.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Ahri.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Ahri.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Ahri.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Ahri.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Akali"

function Akali:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Akali:LoadSpells()
    Q = { Range = 600}
    W = { Range = 475}
    E = { Range = 300}
    R = { Range = 700}
end

function Akali:LoadMenu()
	Akali = MenuElement({type = MENU, id = "Akali", name = "Rugal Aimbot "..myHero.charName})
	Akali:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Akali.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Akali.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Akali.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Akali.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Akali.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Akali.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Akali:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Akali.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Akali.Draw:MenuElement({id = "W", name = "W range", value = true})
    Akali.Draw:MenuElement({id = "E", name = "E range", value = true})
    Akali.Draw:MenuElement({id = "R", name = "R range", value = true})
    Akali.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Akali:Tick()
    self:Spells()
end

function Akali:Spells()
	local target = GetTarget(3500)
    if Akali.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Akali.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(R.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Akali.Spells.RSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_R, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(R.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Akali.Spells.RSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_R, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Akali.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Akali.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Akali.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Akali.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Akali.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if Akali.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Akali:Draw()
    if Akali.dead then return end
    if Akali.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Akali.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Akali.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Akali.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Akali.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Akali.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Akali.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Alistar"

function Alistar:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Alistar:LoadSpells()
    Q = { Range = 365}
    W = { Range = 650}
    E = { Range = 0}
    R = { Range = 0}
end

function Alistar:LoadMenu()
	Alistar = MenuElement({type = MENU, id = "Alistar", name = "Rugal Aimbot "..myHero.charName})
	Alistar:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Alistar.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Alistar.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Alistar.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Alistar.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Alistar.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Alistar:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Alistar.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Alistar.Draw:MenuElement({id = "W", name = "W range", value = true})
    Alistar.Draw:MenuElement({id = "E", name = "E range", value = true})
    Alistar.Draw:MenuElement({id = "R", name = "R range", value = true})
    Alistar.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Alistar:Tick()
    self:Spells()
end

function Alistar:Spells()
	local target = GetTarget(3500)
    if Alistar.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
	end
    if Alistar.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
	end
    if Alistar.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
	end
    if Alistar.Spells.W:Value() then
        if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < Alistar.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(W.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Alistar.Spells.WSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_W, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(W.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Alistar.Spells.WSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_W, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
end

function Alistar:Draw()
    if myHero.dead then return end
    if Alistar.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Alistar.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Alistar.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Alistar.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Alistar.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Alistar.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
    end
end

class "Amumu"

function Amumu:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Amumu:LoadSpells()
    Q = { Range = 1100, Delay = 0.25, Speed = 2000, Width = 70}
    W = { Range = 300}
    E = { Range = 350}
    R = { Range = 550}
end

function Amumu:LoadMenu()
	Amumu = MenuElement({type = MENU, id = "Amumu", name = "Rugal Aimbot "..myHero.charName})
	Amumu:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Amumu.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Amumu.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Amumu.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Amumu.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Amumu.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Amumu:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Amumu.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Amumu.Draw:MenuElement({id = "W", name = "W range", value = true})
    Amumu.Draw:MenuElement({id = "E", name = "E range", value = true})
    Amumu.Draw:MenuElement({id = "R", name = "R range", value = true})
    Amumu.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Amumu:Tick()
    self:Spells()
end

function Amumu:Spells()
	local target = GetTarget(3500)
    if Amumu.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
	end
    if Amumu.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Amumu.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Amumu.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if Amumu.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Amumu:Draw()
    if Amumu.dead then return end
    if Amumu.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Amumu.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Amumu.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Amumu.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Amumu.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Amumu.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
    end
end

class "Anivia"

function Anivia:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Anivia:LoadSpells()
    Q = { Range = 1075, Delay = 0.25, Width = 225, Speed = 850}
    W = { Range = 1000}
    E = { Range = 650}
    R = { Range = 750, Delay = 0.25, Width = 400, Speed = mathhuge}
end

function Anivia:LoadMenu()
	Anivia = MenuElement({type = MENU, id = "Anivia", name = "Rugal Aimbot "..myHero.charName})
	Anivia:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Anivia.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Anivia.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Anivia.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Anivia.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Anivia.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Anivia.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Anivia.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Anivia:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Anivia.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Anivia.Draw:MenuElement({id = "W", name = "W range", value = true})
    Anivia.Draw:MenuElement({id = "E", name = "E range", value = true})
    Anivia.Draw:MenuElement({id = "R", name = "R range", value = true})
    Anivia.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Anivia:Tick()
    self:Spells()
end

function Anivia:Spells()
	local target = GetTarget(3500)
    if Anivia.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Anivia.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Anivia.Spells.E:Value() then
        if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < Anivia.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(E.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Anivia.Spells.ESearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_E, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(E.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Anivia.Spells.ESearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_E, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Anivia.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
	if Anivia.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Anivia.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Anivia:Draw()
    if Anivia.dead then return end
    if Anivia.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Anivia.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Anivia.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Anivia.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Anivia.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Anivia.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Anivia.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Anivia.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Annie"

function Annie:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Annie:LoadSpells()
    Q = { Range = 625}
    W = { Range = 600, Delay = 0.25, Width = 50, Speed = mathhuge}
    E = { Range = 0}
    R = { Range = 600, Delay = 0.25, Width = 290, Speed = mathhuge}
end

function Annie:LoadMenu()
	Annie = MenuElement({type = MENU, id = "Annie", name = "Rugal Aimbot "..myHero.charName})
	Annie:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Annie.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Annie.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Annie.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Annie.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Annie.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Annie.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Annie.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Annie:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Annie.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Annie.Draw:MenuElement({id = "W", name = "W range", value = true})
    Annie.Draw:MenuElement({id = "E", name = "E range", value = true})
    Annie.Draw:MenuElement({id = "R", name = "R range", value = true})
    Annie.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Annie:Tick()
    self:Spells()
end

function Annie:Spells()
	local target = GetTarget(3500)
    if Annie.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Annie.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Annie.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Annie.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Annie.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Annie.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Annie.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if Annie.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Annie.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Annie:Draw()
    if Annie.dead then return end
    if Annie.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Annie.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Annie.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Annie.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Annie.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Annie.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Annie.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Annie.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Ashe"

function Ashe:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ashe:LoadSpells()
    Q = { Range = 600}
    W = { Range = 1200, Delay = 0.25, Width = 50, Speed = mathhuge}
    E = { Range = 25000}
    R = { Range = 25000, Delay = 0.25, Width = 290, Speed = mathhuge}
end

function Ashe:LoadMenu()
	Ashe = MenuElement({type = MENU, id = "Ashe", name = "Rugal Aimbot "..myHero.charName})
	Ashe:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Ashe.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Ashe.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Ashe.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ashe.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Ashe.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Ashe.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Ashe:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Ashe.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Ashe.Draw:MenuElement({id = "W", name = "W range", value = true})
    Ashe.Draw:MenuElement({id = "E", name = "E range", value = true})
    Ashe.Draw:MenuElement({id = "R", name = "R range", value = true})
    Ashe.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Ashe:Tick()
    self:Spells()
end

function Ashe:Spells()
	local target = GetTarget(3500)
    if Ashe.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ashe.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ashe.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
    if Ashe.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if Ashe.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ashe.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Ashe:Draw()
    if Ashe.dead then return end
    if Ashe.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Ashe.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Ashe.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Ashe.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Ashe.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Ashe.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Ashe.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "AurelionSol"

function AurelionSol:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function AurelionSol:LoadSpells()
    Q = { Range = 1075, Delay = 0.25, Width = 210, Speed = 600}
    W = { Range = 650}
    E = { Range = 7000}
    R = { Range = 1500, Delay = 0.25, Width = 120, Speed = 4285}
end

function AurelionSol:LoadMenu()
	AurelionSol = MenuElement({type = MENU, id = "AurelionSol", name = "Rugal Aimbot "..myHero.charName})
	AurelionSol:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    AurelionSol.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    AurelionSol.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    AurelionSol.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    AurelionSol.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    AurelionSol.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    AurelionSol.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	AurelionSol:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    AurelionSol.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    AurelionSol.Draw:MenuElement({id = "W", name = "W range", value = true})
    AurelionSol.Draw:MenuElement({id = "E", name = "E range", value = true})
    AurelionSol.Draw:MenuElement({id = "R", name = "R range", value = true})
    AurelionSol.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function AurelionSol:Tick()
    self:Spells()
end

function AurelionSol:Spells()
	local target = GetTarget(3500)
    if AurelionSol.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < AurelionSol.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if AurelionSol.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if AurelionSol.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if AurelionSol.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < AurelionSol.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function AurelionSol:Draw()
    if AurelionSol.dead then return end
    if AurelionSol.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if AurelionSol.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if AurelionSol.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if AurelionSol.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if AurelionSol.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), AurelionSol.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), AurelionSol.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Azir"

function Azir:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Azir:LoadSpells()
    Q = { Range = 740}
    W = { Range = 500}
    E = { Range = 1100}
    R = { Range = 250}
end

function Azir:LoadMenu()
	Azir = MenuElement({type = MENU, id = "Azir", name = "Rugal Aimbot "..myHero.charName})
	Azir:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Azir.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Azir.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Azir.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Azir.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Azir.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Azir.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Azir.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Azir:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Azir.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Azir.Draw:MenuElement({id = "W", name = "W range", value = true})
    Azir.Draw:MenuElement({id = "E", name = "E range", value = true})
    Azir.Draw:MenuElement({id = "R", name = "R range", value = true})
    Azir.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Azir:Tick()
    self:Spells()
end

function Azir:Spells()
	local target = GetTarget(3500)
    if Azir.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Azir.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.cursorPos())
            EnableOrb(true)
        end
    end
    if Azir.Spells.W:Value() then
        if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < Azir.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(W.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Azir.Spells.WSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_W, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(W.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Azir.Spells.WSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_W, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Azir.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Azir.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Azir.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Azir.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Azir.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Azir:Draw()
    if Azir.dead then return end
    if Azir.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Azir.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Azir.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Azir.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Azir.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Azir.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Azir.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Azir.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Bard"

function Bard:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Bard:LoadSpells()
    Q = { Range = 950, Delay = 0.25, Width = 80, Speed = 1500}
    W = { Range = 800}
    E = { Range = 0}
    R = { Range = 3400, Delay = 0.25, Width = 350, Speed = 2100}
end

function Bard:LoadMenu()
	Bard = MenuElement({type = MENU, id = "Bard", name = "Rugal Aimbot "..myHero.charName})
	Bard:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Bard.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Bard.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Bard.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Bard.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Bard.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Bard.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Bard:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Bard.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Bard.Draw:MenuElement({id = "W", name = "W range", value = true})
    Bard.Draw:MenuElement({id = "E", name = "E range", value = true})
    Bard.Draw:MenuElement({id = "R", name = "R range", value = true})
    Bard.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Bard:Tick()
    self:Spells()
end

function Bard:Spells()
	local target = GetTarget(3500)
    if Bard.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Bard.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Bard.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Bard.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if Bard.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Bard.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Bard:Draw()
    if Bard.dead then return end
    if Bard.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Bard.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Bard.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Bard.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Bard.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Bard.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Bard.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Blitzcrank"

function Blitzcrank:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Blitzcrank:LoadSpells()
    Q = { Range = 925, Delay = 0.25, Width = 60, Speed = 1750}
    W = { Range = 0}
    E = { Range = 0}
    R = { Range = 600}
end

function Blitzcrank:LoadMenu()
	Blitzcrank = MenuElement({type = MENU, id = "Blitzcrank", name = "Rugal Aimbot "..myHero.charName})
	Blitzcrank:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Blitzcrank.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Blitzcrank.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Blitzcrank.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Blitzcrank.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Blitzcrank.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Blitzcrank:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Blitzcrank.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Blitzcrank.Draw:MenuElement({id = "W", name = "W range", value = true})
    Blitzcrank.Draw:MenuElement({id = "E", name = "E range", value = true})
    Blitzcrank.Draw:MenuElement({id = "R", name = "R range", value = true})
    Blitzcrank.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Blitzcrank:Tick()
    self:Spells()
end

function Blitzcrank:Spells()
	local target = GetTarget(3500)
    if Blitzcrank.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
    if Blitzcrank.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Blitzcrank.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
	if Blitzcrank.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Blitzcrank.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Blitzcrank:Draw()
    if Blitzcrank.dead then return end
    if Blitzcrank.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Blitzcrank.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Blitzcrank.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Blitzcrank.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Blitzcrank.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Blitzcrank.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
    end
end

class "Brand"

function Brand:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Brand:LoadSpells()
    Q = { Range = 1050, Delay = 0.25, Width = 65, Speed = 1550}
    W = { Range = 900, Delay = 0.625, Width = 250, Speed = mathhuge}
    E = { Range = 625}
    R = { Range = 750}
end

function Brand:LoadMenu()
	Brand = MenuElement({type = MENU, id = "Brand", name = "Rugal Aimbot "..myHero.charName})
	Brand:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Brand.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Brand.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Brand.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Brand.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Brand.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Brand.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Brand.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Brand.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Brand:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Brand.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Brand.Draw:MenuElement({id = "W", name = "W range", value = true})
    Brand.Draw:MenuElement({id = "E", name = "E range", value = true})
    Brand.Draw:MenuElement({id = "R", name = "R range", value = true})
    Brand.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Brand:Tick()
    self:Spells()
end

function Brand:Spells()
	local target = GetTarget(3500)
    if Brand.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Brand.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(R.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Brand.Spells.RSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_R, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(R.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Brand.Spells.RSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_R, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Brand.Spells.E:Value() then
        if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < Brand.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(E.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Brand.Spells.ESearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_E, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(E.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Brand.Spells.ESearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_E, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Brand.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Brand.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Brand.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Brand.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Brand:Draw()
    if Brand.dead then return end
    if Brand.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Brand.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Brand.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Brand.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Brand.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Brand.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Brand.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Brand.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Brand.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Braum"

function Braum:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Braum:LoadSpells()
    Q = { Range = 1000, Delay = 0.25, Width = 65, Speed = 1670}
    R = { Range = 1250, Delay = 0.5, Width = 115, Speed = 1400}
    W = { Range = 650}
    E = { Range = 0}
end

function Braum:LoadMenu()
	Braum = MenuElement({type = MENU, id = "Braum", name = "Rugal Aimbot "..myHero.charName})
	Braum:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Braum.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Braum.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Braum.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Braum.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Braum.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Braum.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Braum.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Braum:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Braum.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Braum.Draw:MenuElement({id = "W", name = "W range", value = true})
    Braum.Draw:MenuElement({id = "E", name = "E range", value = true})
    Braum.Draw:MenuElement({id = "R", name = "R range", value = true})
    Braum.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Braum:Tick()
    self:Spells()
end

function Braum:Spells()
	local target = GetTarget(3500)
    if Braum.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Braum.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Braum.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Braum.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Braum.Spells.W:Value() then
        local ally = ClosestHero(W.Range,friend)
        if ally and not ally.isMe and GetDistance(ally.pos) < W.Range and GetDistance(ally.pos,Game.mousePos()) < Braum.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, ally)
            EnableOrb(true)
        end
    end
    if Braum.Spells.E:Value() then
        local enemy = ClosestHero(3500,foe)
        if enemy then
            EnableOrb(false)
            Control.CastSpell(HK_E,enemy)
            EnableOrb(true)
        else
            EnableOrb(false)
            Control.CastSpell(HK_E)
            EnableOrb(true)
        end
    end
end

function Braum:Draw()
    if Braum.dead then return end
    if Braum.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Braum.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Braum.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Braum.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Braum.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Braum.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Braum.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Braum.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Caitlyn"

function Caitlyn:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Caitlyn:LoadSpells()
    Q = { Range = 1250, Delay = 0.625, Width = 90, Speed = 2200}
    W = { Range = 800, Delay = 0.25, Width = 75, Speed = mathhuge}
    E = { Range = 750, Delay = 0.25, Width = 60, Speed = 1500}
    R = { Range = 3000}
end

function Caitlyn:LoadMenu()
	Caitlyn = MenuElement({type = MENU, id = "Caitlyn", name = "Rugal Aimbot "..myHero.charName})
	Caitlyn:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Caitlyn.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Caitlyn.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Caitlyn.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Caitlyn.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Caitlyn.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Caitlyn.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Caitlyn.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Caitlyn.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Caitlyn:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Caitlyn.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Caitlyn.Draw:MenuElement({id = "W", name = "W range", value = true})
    Caitlyn.Draw:MenuElement({id = "E", name = "E range", value = true})
    Caitlyn.Draw:MenuElement({id = "R", name = "R range", value = true})
    Caitlyn.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Caitlyn:Tick()
    self:Spells()
end

function Caitlyn:Spells()
	local target = GetTarget(3500)
    if Caitlyn.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Caitlyn.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
    if Caitlyn.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Caitlyn.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Caitlyn.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Caitlyn.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Caitlyn.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Caitlyn.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Caitlyn:Draw()
    if Caitlyn.dead then return end
    if Caitlyn.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Caitlyn.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Caitlyn.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Caitlyn.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Caitlyn.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Caitlyn.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Caitlyn.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Caitlyn.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Caitlyn.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Camille"

function Camille:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Camille:LoadSpells()
    W = { Range = 610, Delay = 0.75, Width = 80, Speed = mathhuge}
    E = { Range = 800, Delay = 0.25, Width = 45, Speed = 1350}
    Q = { Range = 0}
    R = { Range = 475}
end

function Camille:LoadMenu()
	Camille = MenuElement({type = MENU, id = "Camille", name = "Rugal Aimbot "..myHero.charName})
	Camille:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Camille.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Camille.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Camille.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Camille.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Camille.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Camille.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Camille.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Camille:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Camille.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Camille.Draw:MenuElement({id = "W", name = "W range", value = true})
    Camille.Draw:MenuElement({id = "E", name = "E range", value = true})
    Camille.Draw:MenuElement({id = "R", name = "R range", value = true})
    Camille.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Camille:Tick()
    self:Spells()
end

function Camille:Spells()
	local target = GetTarget(3500)
    if Camille.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Camille.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
    if Camille.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Camille.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Camille.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Camille.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Camille.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
end

function Camille:Draw()
    if Camille.dead then return end
    if Camille.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Camille.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Camille.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Camille.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Camille.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Camille.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Camille.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Camille.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Cassiopeia"

function Cassiopeia:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Cassiopeia:LoadSpells()
    Q = { Range = 850, Delay = 0.4, Width = 150, Speed = mathhuge}
    W = { Range = 800, Delay = 0.25, Width = 160, Speed = mathhuge}
    E = { Range = 700}
    R = { Range = 825, Delay = 0.5, Width = 180, Speed = mathhuge}
end

function Cassiopeia:LoadMenu()
	Cassiopeia = MenuElement({type = MENU, id = "Cassiopeia", name = "Rugal Aimbot "..myHero.charName})
	Cassiopeia:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Cassiopeia.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Cassiopeia.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Cassiopeia.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Cassiopeia.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Cassiopeia.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Cassiopeia.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Cassiopeia.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Cassiopeia.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Cassiopeia:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Cassiopeia.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Cassiopeia.Draw:MenuElement({id = "W", name = "W range", value = true})
    Cassiopeia.Draw:MenuElement({id = "E", name = "E range", value = true})
    Cassiopeia.Draw:MenuElement({id = "R", name = "R range", value = true})
    Cassiopeia.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Cassiopeia:Tick()
    self:Spells()
end

function Cassiopeia:Spells()
	local target = GetTarget(3500)
    if Cassiopeia.Spells.E:Value() then
        if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < Cassiopeia.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(E.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Cassiopeia.Spells.ESearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_E, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(E.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Cassiopeia.Spells.ESearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_E, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Cassiopeia.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Cassiopeia.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Cassiopeia.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Cassiopeia.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Cassiopeia.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Cassiopeia.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Cassiopeia:Draw()
    if Cassiopeia.dead then return end
    if Cassiopeia.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Cassiopeia.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Cassiopeia.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Cassiopeia.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Cassiopeia.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Cassiopeia.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Cassiopeia.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Cassiopeia.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Cassiopeia.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Chogath"

function Chogath:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Chogath:LoadSpells()
    Q = { Range = 950, Delay = 0.5, Width = 175, Speed = mathhuge}
    W = { Range = 650, Delay = 0.5, Width = 60, Speed = mathhuge}
    E = { Range = 500}
    R = { Range = 175 + myHero.boundingRadius}
end

function Chogath:LoadMenu()
	Chogath = MenuElement({type = MENU, id = "Chogath", name = "Rugal Aimbot "..myHero.charName})
	Chogath:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Chogath.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Chogath.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Chogath.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Chogath.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Chogath.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Chogath.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Chogath.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Chogath:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Chogath.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Chogath.Draw:MenuElement({id = "W", name = "W range", value = true})
    Chogath.Draw:MenuElement({id = "E", name = "E range", value = true})
    Chogath.Draw:MenuElement({id = "R", name = "R range", value = true})
    Chogath.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Chogath:Tick()
    self:Spells()
end

function Chogath:Spells()
	local target = GetTarget(3500)
    if Chogath.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Chogath.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(R.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Chogath.Spells.RSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_R, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(R.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Chogath.Spells.RSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_R, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Chogath.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Chogath.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Chogath.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Chogath.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Chogath.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Chogath:Draw()
    if Chogath.dead then return end
    if Chogath.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Chogath.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Chogath.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Chogath.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Chogath.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Chogath.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Chogath.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Chogath.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Corki"

function Corki:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Corki:LoadSpells()
    Q = { Range = 825, Delay = 0.25, Width = 250, Speed = 1000}
    W = { Range = 600, Delay = 0, Width = 100, Speed = 650}
    E = { Range = 600, Delay = 0.25, Width = 35, Speed = mathhuge}
    R = { Range = 1225, Delay = 0.175, Width = 35, Speed = 1950}
end

function Corki:LoadMenu()
	Corki = MenuElement({type = MENU, id = "Corki", name = "Rugal Aimbot "..myHero.charName})
	Corki:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Corki.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Corki.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Corki.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Corki.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Corki.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Corki.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Corki.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Corki.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Corki:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Corki.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Corki.Draw:MenuElement({id = "W", name = "W range", value = true})
    Corki.Draw:MenuElement({id = "E", name = "E range", value = true})
    Corki.Draw:MenuElement({id = "R", name = "R range", value = true})
    Corki.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Corki:Tick()
    self:Spells()
end

function Corki:Spells()
	local target = GetTarget(3500)
    if Corki.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Corki.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Corki.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Corki.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Corki.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Corki.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Corki.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Corki.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
end

function Corki:Draw()
    if Corki.dead then return end
    if Corki.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Corki.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Corki.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Corki.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Corki.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Corki.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Corki.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Corki.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Corki.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Darius"

function Darius:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Darius:LoadSpells()
    E = { Range = 535, Delay = 0.25, Width = 50, Speed = mathhuge}
    Q = { Range = 425}
    W = { Range = 0}
    R = { Range = 460}
end

function Darius:LoadMenu()
	Darius = MenuElement({type = MENU, id = "Darius", name = "Rugal Aimbot "..myHero.charName})
	Darius:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Darius.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Darius.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Darius.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Darius.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Darius.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Darius.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Darius:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Darius.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Darius.Draw:MenuElement({id = "W", name = "W range", value = true})
    Darius.Draw:MenuElement({id = "E", name = "E range", value = true})
    Darius.Draw:MenuElement({id = "R", name = "R range", value = true})
    Darius.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Darius:Tick()
    self:Spells()
end

function Darius:Spells()
	local target = GetTarget(3500)
    if Darius.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Darius.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
    if Darius.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Darius.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Darius.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Darius.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
end

function Darius:Draw()
    if Darius.dead then return end
    if Darius.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Darius.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Darius.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Darius.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Darius.Draw.Search:Value() then
        Draw.Circle(Game.mousePos(), Darius.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Darius.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Diana"

function Diana:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Diana:LoadSpells()
    Q = { Range = 900, Delay = 0.25, Width = 205, Speed = 1400}
    W = { Range = 200}
    E = { Range = 450}
    R = { Range = 825}
end

function Diana:LoadMenu()
	Diana = MenuElement({type = MENU, id = "Diana", name = "Rugal Aimbot "..myHero.charName})
	Diana:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Diana.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Diana.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Diana.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Diana.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Diana.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Diana.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Diana:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Diana.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Diana.Draw:MenuElement({id = "W", name = "W range", value = true})
    Diana.Draw:MenuElement({id = "E", name = "E range", value = true})
    Diana.Draw:MenuElement({id = "R", name = "R range", value = true})
    Diana.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Diana:Tick()
    self:Spells()
end

function Diana:Spells()
	local target = GetTarget(3500)
    if Diana.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Diana.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(R.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Diana.Spells.RSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_R, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(R.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Diana.Spells.RSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_R, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
	if Diana.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Diana.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Diana.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
    if Diana.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Diana:Draw()
    if Diana.dead then return end
    if Diana.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Diana.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Diana.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Diana.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Diana.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Diana.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Diana.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "DrMundo"

function DrMundo:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function DrMundo:LoadSpells()
    Q = { Range = 975, Delay = 0.25, Width = 60, Speed = 1850}
    W = { Range = 162.5}
    E = { Range = 0}
    R = { Range = 0}
end

function DrMundo:LoadMenu()
	DrMundo = MenuElement({type = MENU, id = "DrMundo", name = "Rugal Aimbot "..myHero.charName})
	DrMundo:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    DrMundo.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    DrMundo.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    DrMundo.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    DrMundo.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    DrMundo.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	DrMundo:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    DrMundo.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    DrMundo.Draw:MenuElement({id = "W", name = "W range", value = true})
    DrMundo.Draw:MenuElement({id = "E", name = "E range", value = true})
    DrMundo.Draw:MenuElement({id = "R", name = "R range", value = true})
    DrMundo.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function DrMundo:Tick()
    self:Spells()
end

function DrMundo:Spells()
	local target = GetTarget(3500)
	if DrMundo.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < DrMundo.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if DrMundo.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
    if DrMundo.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
    if DrMundo.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function DrMundo:Draw()
    if DrMundo.dead then return end
    if DrMundo.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if DrMundo.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if DrMundo.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if DrMundo.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if DrMundo.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), DrMundo.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
    end
end

class "Draven"

function Draven:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Draven:LoadSpells()
    E = { Range = 1050, Delay = 0.25, Width = 120, Speed = 1400}
    R = { Range = 25000, Delay = 0.5, Width = 130, Speed = 2000}
    Q = { Range = 0}
    W = { Range = 0}
end

function Draven:LoadMenu()
	Draven = MenuElement({type = MENU, id = "Draven", name = "Rugal Aimbot "..myHero.charName})
	Draven:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Draven.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Draven.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Draven.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Draven.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Draven.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Draven.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Draven:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Draven.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Draven.Draw:MenuElement({id = "W", name = "W range", value = true})
    Draven.Draw:MenuElement({id = "E", name = "E range", value = true})
    Draven.Draw:MenuElement({id = "R", name = "R range", value = true})
    Draven.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Draven:Tick()
    self:Spells()
end

function Draven:Spells()
	local target = GetTarget(3500)
    if Draven.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Draven.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Draven.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Draven.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Draven.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Draven.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
end

function Draven:Draw()
    if Draven.dead then return end
    if Draven.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Draven.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Draven.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Draven.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Draven.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Draven.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Draven.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Ekko"

function Ekko:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ekko:LoadSpells()
    Q = { Range = 1075, Delay = 0.25, Speed = 1650, Width = 135}
    W = { Range = 1600, Delay = 0.25, Speed = 1650, Width = 400}
    E = { Range = 325}
    R = { Range = 0}
end

function Ekko:LoadMenu()
	Ekko = MenuElement({type = MENU, id = "Ekko", name = "Rugal Aimbot "..myHero.charName})
	Ekko:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Ekko.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Ekko.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ekko.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Ekko.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ekko.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Ekko.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Ekko:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Ekko.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Ekko.Draw:MenuElement({id = "W", name = "W range", value = true})
    Ekko.Draw:MenuElement({id = "E", name = "E range", value = true})
    Ekko.Draw:MenuElement({id = "R", name = "R range", value = true})
    Ekko.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Ekko:Tick()
    self:Spells()
end

function Ekko:Spells()
	local target = GetTarget(3500)
    if Ekko.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ekko.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ekko.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ekko.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ekko.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
    if Ekko.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Ekko:Draw()
    if myHero.dead then return end
    if Ekko.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Ekko.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Ekko.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Ekko.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Ekko.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Ekko.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Ekko.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
    end
end

class "Elise"

function Elise:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Elise:LoadSpells()
    Q = { Range = 625}
    W = { Range = 950}
    E = { Range = 1075, Delay = 0.25, Speed = 1600, Width = 55}
    Q2 = { Range = 475}
    W2 = { Range = 0}
    E2 = { Range = 750}
    R = { Range = 0}
end

function Elise:LoadMenu()
	Elise = MenuElement({type = MENU, id = "Elise", name = "Rugal Aimbot "..myHero.charName})
	Elise:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Elise.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Elise.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Elise.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Elise.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Elise.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Elise.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Elise.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Elise:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Elise.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Elise.Draw:MenuElement({id = "W", name = "W range", value = true})
    Elise.Draw:MenuElement({id = "E", name = "E range", value = true})
    Elise.Draw:MenuElement({id = "R", name = "R range", value = true})
    Elise.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Elise:Tick()
    local form = self:CurrentForm()
    if form == "Human" then
        self:HumanSpells()
    elseif form == "Spider" then
        self:SpiderSpells()
    end
end

function Elise:CurrentForm()
    if myHero:GetSpellData(_R).name == "EliseR" then
        return "Human"
    else
        return "Spider"
    end
end

function Elise:HumanSpells()
	local target = GetTarget(3500)
    if Elise.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Elise.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Elise.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Elise.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Elise.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Elise.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Elise.Spells.W:Value() then
        if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < Elise.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(W.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Elise.Spells.WSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_W, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(W.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Elise.Spells.WSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_W, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Elise.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Elise:SpiderSpells()
	local target = GetTarget(3500)
    if Elise.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q2.Range and GetDistance(target.pos,Game.mousePos()) < Elise.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q2.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Elise.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q2.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Elise.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Elise.Spells.E:Value() and not myHero:GetSpellData(_E).toggleState ~= 2 then
        if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < Elise.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(E.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Elise.Spells.ESearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_E, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(E.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Elise.Spells.ESearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_E, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
	if Elise.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Elise.Spells.E:Value() and myHero:GetSpellData(_E).toggleState ~= 2 then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
    if Elise.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Elise:Draw()
    if myHero.dead then return end
    local form = self:CurrentForm()
    if form == "Human" then
        if Elise.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
        if Elise.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
        if Elise.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
        if Elise.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    elseif form == "Spider" then
        if Elise.Draw.Q:Value() then Draw.Circle(myHero.pos, Q2.Range, 3,  Draw.Color(255, 000, 000, 255)) end
        if Elise.Draw.W:Value() then Draw.Circle(myHero.pos, W2.Range, 3,  Draw.Color(255, 000, 255, 000)) end
        if Elise.Draw.E:Value() then Draw.Circle(myHero.pos, E2.Range, 3,  Draw.Color(255, 255, 255, 000)) end
        if Elise.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    end
    if Elise.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Elise.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Elise.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Elise.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Elise.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Evelynn"

function Evelynn:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Evelynn:LoadSpells()
    Q = { Range = 800, Delay = 0.25, Speed = 2200, Width = 35}
    W = { Range = 1100 + myHero:GetSpellData(_W).level * 100}
    E = { Range = 210}
    R = { Range = 450, Delay = 0.35, Speed = mathhuge, Width = 180}
end

function Evelynn:LoadMenu()
	Evelynn = MenuElement({type = MENU, id = "Evelynn", name = "Rugal Aimbot "..myHero.charName})
	Evelynn:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Evelynn.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Evelynn.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Evelynn.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Evelynn.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Evelynn.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Evelynn.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Evelynn.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Evelynn.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Evelynn:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Evelynn.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Evelynn.Draw:MenuElement({id = "W", name = "W range", value = true})
    Evelynn.Draw:MenuElement({id = "E", name = "E range", value = true})
    Evelynn.Draw:MenuElement({id = "R", name = "R range", value = true})
    Evelynn.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Evelynn:Tick()
    self:Spells()
end

function Evelynn:Spells()
	local target = GetTarget(3500)
    if Evelynn.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Evelynn.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Evelynn.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Evelynn.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Evelynn.Spells.W:Value() then
        if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < Evelynn.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(W.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Evelynn.Spells.WSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_W, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(W.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Evelynn.Spells.WSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_W, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Evelynn.Spells.E:Value() then
        if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < Evelynn.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(E.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Evelynn.Spells.ESearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_E, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(E.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Evelynn.Spells.ESearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_E, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
end

function Evelynn:Draw()
    if myHero.dead then return end
    if Evelynn.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Evelynn.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Evelynn.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Evelynn.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Evelynn.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Evelynn.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Evelynn.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Evelynn.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Evelynn.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Ezreal"

function Ezreal:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ezreal:LoadSpells()
    Q = { Range = 1150, Delay = 0.25, Speed = 2000, Width = 80}
    W = { Range = 1000, Delay = 0.25, Speed = 1550, Width = 80}
    E = { Range = 475}
    R = { Range = 25000, Delay = 0.25, Speed = 2000, Width = 160}
end

function Ezreal:LoadMenu()
	Ezreal = MenuElement({type = MENU, id = "Ezreal", name = "Rugal Aimbot "..myHero.charName})
	Ezreal:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Ezreal.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Ezreal.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ezreal.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Ezreal.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ezreal.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Ezreal.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Ezreal.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Ezreal:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Ezreal.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Ezreal.Draw:MenuElement({id = "W", name = "W range", value = true})
    Ezreal.Draw:MenuElement({id = "E", name = "E range", value = true})
    Ezreal.Draw:MenuElement({id = "R", name = "R range", value = true})
    Ezreal.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Ezreal:Tick()
    self:Spells()
end

function Ezreal:Spells()
	local target = GetTarget(3500)
    if Ezreal.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ezreal.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ezreal.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ezreal.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ezreal.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ezreal.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ezreal.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Ezreal:Draw()
    if myHero.dead then return end
    if Ezreal.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Ezreal.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Ezreal.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Ezreal.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Ezreal.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Ezreal.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Ezreal.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Ezreal.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "FiddleSticks"

function FiddleSticks:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function FiddleSticks:LoadSpells()
    Q = { Range = 575}
    W = { Range = 575}
    E = { Range = 750}
    R = { Range = 800}
end

function FiddleSticks:LoadMenu()
	FiddleSticks = MenuElement({type = MENU, id = "FiddleSticks", name = "Rugal Aimbot "..myHero.charName})
	FiddleSticks:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    FiddleSticks.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    FiddleSticks.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    FiddleSticks.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    FiddleSticks.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    FiddleSticks.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    FiddleSticks.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    FiddleSticks.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	FiddleSticks:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    FiddleSticks.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    FiddleSticks.Draw:MenuElement({id = "W", name = "W range", value = true})
    FiddleSticks.Draw:MenuElement({id = "E", name = "E range", value = true})
    FiddleSticks.Draw:MenuElement({id = "R", name = "R range", value = true})
    FiddleSticks.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function FiddleSticks:Tick()
    self:Spells()
end

function FiddleSticks:Spells()
	local target = GetTarget(3500)
    if FiddleSticks.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < FiddleSticks.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < FiddleSticks.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < FiddleSticks.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if FiddleSticks.Spells.W:Value() then
        if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < FiddleSticks.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(W.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < FiddleSticks.Spells.WSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_W, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(W.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < FiddleSticks.Spells.WSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_W, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if FiddleSticks.Spells.E:Value() then
        if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < FiddleSticks.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(E.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < FiddleSticks.Spells.ESearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_E, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(E.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < FiddleSticks.Spells.ESearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_E, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if FiddleSticks.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function FiddleSticks:Draw()
    if myHero.dead then return end
    if FiddleSticks.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if FiddleSticks.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if FiddleSticks.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if FiddleSticks.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if FiddleSticks.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), FiddleSticks.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), FiddleSticks.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), FiddleSticks.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Fiora"

function Fiora:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Fiora:LoadSpells()
    Q = { Range = 400, Delay = 0, Speed = 800, Width = 50}
    W = { Range = 750, Delay = 0.75, Speed = mathhuge, Width = 85}
    E = { Range = 0}
    R = { Range = 500}
end

function Fiora:LoadMenu()
	Fiora = MenuElement({type = MENU, id = "Fiora", name = "Rugal Aimbot "..myHero.charName})
	Fiora:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Fiora.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Fiora.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Fiora.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Fiora.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Fiora.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Fiora.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Fiora.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Fiora:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Fiora.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Fiora.Draw:MenuElement({id = "W", name = "W range", value = true})
    Fiora.Draw:MenuElement({id = "E", name = "E range", value = true})
    Fiora.Draw:MenuElement({id = "R", name = "R range", value = true})
    Fiora.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Fiora:Tick()
    self:Spells()
end

function Fiora:Spells()
	local target = GetTarget(3500)
    if Fiora.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Fiora.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Fiora.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Fiora.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Fiora.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Fiora.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(R.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Fiora.Spells.RSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_R, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(R.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Fiora.Spells.RSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_R, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Fiora.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Fiora:Draw()
    if myHero.dead then return end
    if Fiora.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Fiora.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Fiora.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Fiora.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Fiora.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Fiora.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Fiora.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Fiora.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Fizz"

function Fizz:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Fizz:LoadSpells()
    Q = { Range = 550}
    W = { Range = 0}
    E = { Range = 400}
    R = { Range = 1300, Delay = 0.25, Speed = 1300, Width = 120}
end

function Fizz:LoadMenu()
	Fizz = MenuElement({type = MENU, id = "Fizz", name = "Rugal Aimbot "..myHero.charName})
	Fizz:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Fizz.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Fizz.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Fizz.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Fizz.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Fizz.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Fizz.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Fizz:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Fizz.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Fizz.Draw:MenuElement({id = "W", name = "W range", value = true})
    Fizz.Draw:MenuElement({id = "E", name = "E range", value = true})
    Fizz.Draw:MenuElement({id = "R", name = "R range", value = true})
    Fizz.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Fizz:Tick()
    self:Spells()
end

function Fizz:Spells()
	local target = GetTarget(3500)
    if Fizz.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Fizz.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Fizz.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Fizz.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Fizz.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Fizz.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
	if Fizz.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Fizz.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Fizz:Draw()
    if myHero.dead then return end
    if Fizz.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Fizz.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Fizz.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Fizz.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Fizz.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Fizz.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Fizz.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Galio"

function Galio:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Galio:LoadSpells()
    Q = { Range = 825, Delay = 0.25, Speed = 1150, Width = 150}
    W = { Range = 350}
    E = { Range = 650, Delay = 0.45, Speed = 1400, Width = 160}
    R = { Range = 5500}
end

function Galio:LoadMenu()
	Galio = MenuElement({type = MENU, id = "Galio", name = "Rugal Aimbot "..myHero.charName})
	Galio:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Galio.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Galio.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Galio.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Galio.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Galio.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Galio.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Galio:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Galio.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Galio.Draw:MenuElement({id = "W", name = "W range", value = true})
    Galio.Draw:MenuElement({id = "E", name = "E range", value = true})
    Galio.Draw:MenuElement({id = "R", name = "R range", value = true})
    Galio.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Galio:Tick()
    self:Spells()
end

function Galio:Spells()
	local target = GetTarget(3500)
    if Galio.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Galio.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Galio.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Galio.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Galio.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Galio.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Galio:Draw()
    if myHero.dead then return end
    if Galio.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Galio.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Galio.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Galio.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Galio.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Galio.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Galio.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Gangplank"

function Gangplank:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Gangplank:LoadSpells()
    Q = { Range = 625}
    W = { Range = 0}
    E = { Range = 1000, Delay = 0.25, Speed = mathhuge, Width = 400}
    R = { Range = 25000, Delay = 0.25, Speed = mathhuge, Width = 600}
end

function Gangplank:LoadMenu()
	Gangplank = MenuElement({type = MENU, id = "Gangplank", name = "Rugal Aimbot "..myHero.charName})
	Gangplank:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Gangplank.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Gangplank.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gangplank.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Gangplank.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Gangplank.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gangplank.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Gangplank.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Gangplank:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Gangplank.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Gangplank.Draw:MenuElement({id = "W", name = "W range", value = true})
    Gangplank.Draw:MenuElement({id = "E", name = "E range", value = true})
    Gangplank.Draw:MenuElement({id = "R", name = "R range", value = true})
    Gangplank.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Gangplank:Tick()
    self:Spells()
end

function Gangplank:Spells()
	local target = GetTarget(3500)
    if Gangplank.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gangplank.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gangplank.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gangplank.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gangplank.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Gangplank.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Gangplank.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Gangplank.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
	if Gangplank.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Gangplank:Draw()
    if myHero.dead then return end
    if Gangplank.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Gangplank.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Gangplank.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Gangplank.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Gangplank.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Gangplank.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Gangplank.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Gangplank.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Garen"

function Garen:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Garen:LoadSpells()
    Q = { Range = 0}
    W = { Range = 0}
    E = { Range = 325}
    R = { Range = 400}
end

function Garen:LoadMenu()
	Garen = MenuElement({type = MENU, id = "Garen", name = "Rugal Aimbot "..myHero.charName})
	Garen:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Garen.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Garen.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Garen.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Garen.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Garen.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Garen:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Garen.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Garen.Draw:MenuElement({id = "W", name = "W range", value = true})
    Garen.Draw:MenuElement({id = "E", name = "E range", value = true})
    Garen.Draw:MenuElement({id = "R", name = "R range", value = true})
    Garen.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Garen:Tick()
    self:Spells()
end

function Garen:Spells()
	local target = GetTarget(3500)
    if Garen.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Garen.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
    if Garen.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
	if Garen.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Garen.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Garen:Draw()
    if myHero.dead then return end
    if Garen.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Garen.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Garen.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Garen.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Garen.Draw.Search:Value() then
        Draw.Circle(Game.mousePos(), Garen.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Gnar"

function Gnar:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Gnar:LoadSpells()
    Q = { Range = 1100, Delay = 0.25, Speed = 2500, Width = 55}
    W = { Range = 0}
    E = { Range = 475, Delay = 0.25, Speed = 900, Width = 160}
    R = { Range = 475}
    Q2 = { Range = 1100, Delay = 0.5, Speed = 2100, Width = 90}
    W2 = { Range = 550, Delay = 0.6, Speed = mathhuge, Width = 100}
    E2 = { Range = 600, Delay = 0.25, Speed = 800, Width = 375}
end

function Gnar:LoadMenu()
	Gnar = MenuElement({type = MENU, id = "Gnar", name = "Rugal Aimbot "..myHero.charName})
	Gnar:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Gnar.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Gnar.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gnar.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Gnar.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gnar.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Gnar.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gnar.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Gnar:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Gnar.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Gnar.Draw:MenuElement({id = "W", name = "W range", value = true})
    Gnar.Draw:MenuElement({id = "E", name = "E range", value = true})
    Gnar.Draw:MenuElement({id = "R", name = "R range", value = true})
    Gnar.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Gnar:Tick()
    self:Spells()
end

function Gnar:Spells()
	local target = GetTarget(3500)
    if Gnar.Spells.Q:Value() and myHero:GetSpellData(_Q).name == "GnarQ" then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gnar.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gnar.Spells.W:Value() and myHero:GetSpellData(_W).name == "GnarW" then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gnar.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gnar.Spells.E:Value() and myHero:GetSpellData(_E).name == "GnarE" then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gnar.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gnar.Spells.Q:Value() and myHero:GetSpellData(_Q).name == "GnarBigQ" then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gnar.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q2.Range, Q2.Delay, Q2.Speed, Q2.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q2.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gnar.Spells.W:Value() and myHero:GetSpellData(_W).name == "GnarBigW" then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gnar.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W2.Range, W2.Delay, W2.Speed, W2.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W2.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gnar.Spells.E:Value() and myHero:GetSpellData(_E).name == "GnarBigE" then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gnar.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E2.Range, E2.Delay, E2.Speed, E2.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E2.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gnar.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Gnar:Draw()
    if myHero.dead then return end
    if Gnar.Draw.Q:Value() and myHero:GetSpellData(_Q).name == "GnarQ" then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Gnar.Draw.W:Value() and myHero:GetSpellData(_W).name == "GnarW" then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Gnar.Draw.E:Value() and myHero:GetSpellData(_E).name == "GnarE" then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Gnar.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Gnar.Draw.Q:Value() and myHero:GetSpellData(_Q).name == "GnarBigQ" then Draw.Circle(myHero.pos, Q2.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Gnar.Draw.W:Value() and myHero:GetSpellData(_W).name == "GnarBigW" then Draw.Circle(myHero.pos, W2.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Gnar.Draw.E:Value() and myHero:GetSpellData(_E).name == "GnarBigE" then Draw.Circle(myHero.pos, E2.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Gnar.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Gnar.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Gnar.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Gnar.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Gragas"

function Gragas:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Gragas:LoadSpells()
    Q = { Range = 850, Delay = 0.25, Speed = 1000, Width = 250}
    W = { Range = 0}
    E = { Range = 600, Delay = 0.25, Speed = 900, Width = 170}
    R = { Range = 1000, Delay = 0.25, Speed = 1800, Width = 400}
end

function Gragas:LoadMenu()
	Gragas = MenuElement({type = MENU, id = "Gragas", name = "Rugal Aimbot "..myHero.charName})
	Gragas:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Gragas.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Gragas.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gragas.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Gragas.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Gragas.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Gragas.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Gragas.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Gragas:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Gragas.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Gragas.Draw:MenuElement({id = "W", name = "W range", value = true})
    Gragas.Draw:MenuElement({id = "E", name = "E range", value = true})
    Gragas.Draw:MenuElement({id = "R", name = "R range", value = true})
    Gragas.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Gragas:Tick()
    self:Spells()
end

function Gragas:Spells()
	local target = GetTarget(3500)
    if Gragas.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gragas.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gragas.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gragas.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Gragas.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Gragas.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Gragas.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Gragas:Draw()
    if myHero.dead then return end
    if Gragas.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Gragas.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Gragas.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Gragas.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Gragas.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Gragas.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Gragas.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Gragas.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Graves"

function Graves:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Graves:LoadSpells()
    Q = { Range = 925, Delay = 0.25, Speed = 2000, Width = 100}
    W = { Range = 950, Delay = 0.15, Speed = 1450, Width = 250}
    E = { Range = 425}
    R = { Range = 1000, Delay = 0.25, Speed = 2100, Width = 100}
end

function Graves:LoadMenu()
	Graves = MenuElement({type = MENU, id = "Graves", name = "Rugal Aimbot "..myHero.charName})
	Graves:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Graves.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Graves.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Graves.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Graves.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Graves.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Graves.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Graves.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Graves:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Graves.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Graves.Draw:MenuElement({id = "W", name = "W range", value = true})
    Graves.Draw:MenuElement({id = "E", name = "E range", value = true})
    Graves.Draw:MenuElement({id = "R", name = "R range", value = true})
    Graves.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Graves:Tick()
    self:Spells()
end

function Graves:Spells()
	local target = GetTarget(3500)
    if Graves.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Graves.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Graves.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Graves.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Graves.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Graves.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Graves.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Graves:Draw()
    if myHero.dead then return end
    if Graves.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Graves.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Graves.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Graves.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Graves.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Graves.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Graves.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Graves.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Hecarim"

function Hecarim:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Hecarim:LoadSpells()
    Q = { Range = 350}
    W = { Range = 575}
    E = { Range = 0}
    R = { Range = 1000, Delay = 0.01, Speed = 1100, Width = 230}
end	

function Hecarim:LoadMenu()
	Hecarim = MenuElement({type = MENU, id = "Hecarim", name = "Rugal Aimbot "..myHero.charName})
	Hecarim:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Hecarim.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Hecarim.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Hecarim.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Hecarim.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Hecarim.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Hecarim:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Hecarim.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Hecarim.Draw:MenuElement({id = "W", name = "W range", value = true})
    Hecarim.Draw:MenuElement({id = "E", name = "E range", value = true})
    Hecarim.Draw:MenuElement({id = "R", name = "R range", value = true})
    Hecarim.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Hecarim:Tick()
    self:Spells()
end

function Hecarim:Spells()
	local target = GetTarget(3500)
    if Hecarim.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Hecarim.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Hecarim.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
	if Hecarim.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Hecarim.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Hecarim:Draw()
    if myHero.dead then return end
    if Hecarim.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Hecarim.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Hecarim.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Hecarim.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Hecarim.Draw.Search:Value() then
        Draw.Circle(Game.mousePos(), Hecarim.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Heimerdinger"

function Heimerdinger:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Heimerdinger:LoadSpells()
    Q = { Range = 450}
    W = { Range = 1325, Delay = 0.25, Speed = 2050, Width = 60}
    E = { Range = 970, Delay = 0.25, Speed = 1200, Width = 250}
    R = { Range = 0}
end

function Heimerdinger:LoadMenu()
	Heimerdinger = MenuElement({type = MENU, id = "Heimerdinger", name = "Rugal Aimbot "..myHero.charName})
	Heimerdinger:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Heimerdinger.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Heimerdinger.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Heimerdinger.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Heimerdinger.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Heimerdinger.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Heimerdinger.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Heimerdinger:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Heimerdinger.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Heimerdinger.Draw:MenuElement({id = "W", name = "W range", value = true})
    Heimerdinger.Draw:MenuElement({id = "E", name = "E range", value = true})
    Heimerdinger.Draw:MenuElement({id = "R", name = "R range", value = true})
    Heimerdinger.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Heimerdinger:Tick()
    self:Spells()
end

function Heimerdinger:Spells()
	local target = GetTarget(3500)
    if Heimerdinger.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Heimerdinger.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Heimerdinger.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Heimerdinger.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Heimerdinger.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
	if Heimerdinger.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Heimerdinger.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
    if Heimerdinger.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Heimerdinger:Draw()
    if myHero.dead then return end
    if Heimerdinger.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Heimerdinger.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Heimerdinger.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Heimerdinger.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Heimerdinger.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Heimerdinger.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Heimerdinger.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Illaoi"

function Illaoi:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Illaoi:LoadSpells()
    Q = { Range = 850, Delay = 0.75, Speed = mathhuge, Width = 100}
    W = { Range = 0}
    E = { Range = 900, Delay = 0.25, Speed = 1900, Width = 50}
    R = { Range = 450}
end

function Illaoi:LoadMenu()
	Illaoi = MenuElement({type = MENU, id = "Illaoi", name = "Rugal Aimbot "..myHero.charName})
	Illaoi:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Illaoi.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Illaoi.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Illaoi.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Illaoi.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Illaoi.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Illaoi.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Illaoi:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Illaoi.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Illaoi.Draw:MenuElement({id = "W", name = "W range", value = true})
    Illaoi.Draw:MenuElement({id = "E", name = "E range", value = true})
    Illaoi.Draw:MenuElement({id = "R", name = "R range", value = true})
    Illaoi.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Illaoi:Tick()
    self:Spells()
end

function Illaoi:Spells()
	local target = GetTarget(3500)
    if Illaoi.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Illaoi.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Illaoi.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Illaoi.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
	if Illaoi.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Illaoi.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Illaoi:Draw()
    if myHero.dead then return end
    if Illaoi.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Illaoi.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Illaoi.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Illaoi.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Illaoi.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Illaoi.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Illaoi.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Irelia"

function Irelia:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Irelia:LoadSpells()
    Q = { Range = 625}
    W = { Range = 825, Delay = 0.25, Speed = mathhuge, Width = 90}
    E = { Range = 900, Delay = 0, Speed = 2000, Width = 90}
    R = { Range = 100, Delay = 0.4, Speed = 2000, Width = 160}
end

function Irelia:LoadMenu()
	Irelia = MenuElement({type = MENU, id = "Irelia", name = "Rugal Aimbot "..myHero.charName})
	Irelia:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Irelia.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Irelia.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Irelia.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Irelia.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Irelia.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Irelia.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Irelia.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Irelia.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Irelia:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Irelia.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Irelia.Draw:MenuElement({id = "W", name = "W range", value = true})
    Irelia.Draw:MenuElement({id = "E", name = "E range", value = true})
    Irelia.Draw:MenuElement({id = "R", name = "R range", value = true})
    Irelia.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Irelia:Tick()
    self:Spells()
end

function Irelia:Spells()
	local target = GetTarget(3500)
    if Irelia.Spells.W:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Irelia.Spells.WSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_W, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Irelia.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Irelia.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Irelia.Spells.R:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Irelia.Spells.RSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_R, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Irelia.Spells.Q:Value() then
        if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Irelia.Spells.QSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(Q.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Irelia.Spells.QSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_Q, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(Q.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Irelia.Spells.QSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_Q, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
end

function Irelia:Draw()
    if myHero.dead then return end
    if Irelia.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Irelia.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Irelia.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Irelia.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Irelia.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Irelia.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Irelia.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Irelia.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Irelia.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Ivern"

function Ivern:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ivern:LoadSpells()
    Q = { Range = 1075, Delay = 0.25, Speed = 1300, Width = 65}
    W = { Range = 1000}
    E = { Range = 750}
    R = { Range = 0}
end

function Ivern:LoadMenu()
	Ivern = MenuElement({type = MENU, id = "Ivern", name = "Rugal Aimbot "..myHero.charName})
	Ivern:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Ivern.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Ivern.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ivern.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Ivern.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Ivern.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Ivern.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Ivern:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Ivern.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Ivern.Draw:MenuElement({id = "W", name = "W range", value = true})
    Ivern.Draw:MenuElement({id = "E", name = "E range", value = true})
    Ivern.Draw:MenuElement({id = "R", name = "R range", value = true})
    Ivern.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Ivern:Tick()
    self:Spells()
end

function Ivern:Spells()
	local target = GetTarget(3500)
    if Ivern.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Ivern.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Ivern.Spells.E:Value() then
        local ally = ClosestHero(E.Range,friend)
        if ally and GetDistance(ally.pos) < E.Range and GetDistance(ally.pos,Game.mousePos()) < Ivern.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, ally)
            EnableOrb(true)
        end
    end
	if Ivern.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Ivern.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Ivern:Draw()
    if myHero.dead then return end
    if Ivern.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Ivern.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Ivern.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Ivern.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Ivern.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Ivern.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Ivern.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "Janna"

function Janna:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Janna:LoadSpells()
    Q = { Range = 1750, Delay = 0, Speed = 667, Width = 120}
    W = { Range = 550 + myHero.boundingRadius}
    E = { Range = 800}
    R = { Range = 725}
end

function Janna:LoadMenu()
	Janna = MenuElement({type = MENU, id = "Janna", name = "Rugal Aimbot "..myHero.charName})
	Janna:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Janna.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Janna.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Janna.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Janna.Spells:MenuElement({id = "WSearch", name = "W Search Range", min = 50, max = 3500, value = 250, step = 10})
    Janna.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Janna.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Janna.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
	Janna:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Janna.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Janna.Draw:MenuElement({id = "W", name = "W range", value = true})
    Janna.Draw:MenuElement({id = "E", name = "E range", value = true})
    Janna.Draw:MenuElement({id = "R", name = "R range", value = true})
    Janna.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Janna:Tick()
    self:Spells()
end

function Janna:Spells()
	local target = GetTarget(3500)
    if Janna.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Janna.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Janna.Spells.W:Value() then
        if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < Janna.Spells.WSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        else
            local foeminion = ClosestMinion(W.Range,foe)
            if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Janna.Spells.WSearch:Value() then
                EnableOrb(false)
                Control.CastSpell(HK_W, foeminion)
                EnableOrb(true)
            else
                local neutralminion = ClosestMinion(W.Range,neutral)
                if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Janna.Spells.WSearch:Value() then
                    EnableOrb(false)
                    Control.CastSpell(HK_W, neutralminion)
                    EnableOrb(true)
                end
            end
        end
    end
    if Janna.Spells.E:Value() then
        local ally = ClosestHero(E.Range,friend)
        if ally and GetDistance(ally.pos) < E.Range and GetDistance(ally.pos,Game.mousePos()) < Janna.Spells.ESearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_E, ally)
            EnableOrb(true)
        end
    end
    if Janna.Spells.R:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Janna:Draw()
    if myHero.dead then return end
    if Janna.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Janna.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Janna.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Janna.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Janna.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Janna.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Janna.Spells.WSearch:Value(), 1,  Draw.Color(255, 000, 255, 000))
        Draw.Circle(Game.mousePos(), Janna.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
    end
end

class "JarvanIV"

function JarvanIV:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function JarvanIV:LoadSpells()
    Q = { Range = 770, Delay = 0.4, Speed = mathhuge, Width = 60}
    W = { Range = 625}
    E = { Range = 860, Delay = 0.01, Speed = 3440, Width = 175}
    R = { Range = 650}
end

function JarvanIV:LoadMenu()
	JarvanIV = MenuElement({type = MENU, id = "JarvanIV", name = "Rugal Aimbot "..myHero.charName})
	JarvanIV:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    JarvanIV.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    JarvanIV.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    JarvanIV.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    JarvanIV.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    JarvanIV.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    JarvanIV.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    JarvanIV.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	JarvanIV:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    JarvanIV.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    JarvanIV.Draw:MenuElement({id = "W", name = "W range", value = true})
    JarvanIV.Draw:MenuElement({id = "E", name = "E range", value = true})
    JarvanIV.Draw:MenuElement({id = "R", name = "R range", value = true})
    JarvanIV.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function JarvanIV:Tick()
    self:Spells()
end

function JarvanIV:Spells()
	local target = GetTarget(3500)
    if JarvanIV.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < JarvanIV.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if JarvanIV.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < JarvanIV.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if JarvanIV.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < JarvanIV.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
	if JarvanIV.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function JarvanIV:Draw()
    if myHero.dead then return end
    if JarvanIV.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if JarvanIV.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if JarvanIV.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if JarvanIV.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if JarvanIV.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), JarvanIV.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), JarvanIV.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), JarvanIV.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Nautilus"

function Nautilus:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Nautilus:LoadSpells()
    Q = { Range = 1100, Delay = 0.25, Speed = 2000, Width = 90}
    W = { Range = 0}
    E = { Range = 600}
    R = { Range = 825}
end

function Nautilus:LoadMenu()
	Nautilus = MenuElement({type = MENU, id = "Nautilus", name = "Rugal Aimbot "..myHero.charName})
	Nautilus:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Nautilus.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Nautilus.Spells:MenuElement({id = "QSearch", name = "Q Search Range", min = 50, max = 3500, value = 250, step = 10})
    Nautilus.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Nautilus.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Nautilus.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Nautilus.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Nautilus:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Nautilus.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Nautilus.Draw:MenuElement({id = "W", name = "W range", value = true})
    Nautilus.Draw:MenuElement({id = "E", name = "E range", value = true})
    Nautilus.Draw:MenuElement({id = "R", name = "R range", value = true})
    Nautilus.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Nautilus:Tick()
    self:Spells()
end

function Nautilus:Spells()
	local target = GetTarget(3500)
    if Nautilus.Spells.Q:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Nautilus.Spells.QSearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_Q, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Nautilus.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Nautilus.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
	if Nautilus.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
    if Nautilus.Spells.E:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function Nautilus:Draw()
    if myHero.dead then return end
    if Nautilus.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Nautilus.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Nautilus.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Nautilus.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Nautilus.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Nautilus.Spells.QSearch:Value(), 1,  Draw.Color(255, 000, 000, 255))
        Draw.Circle(Game.mousePos(), Nautilus.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

class "Skarner"

function Skarner:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Skarner:LoadSpells()
    Q = { Range = 350}
    W = { Range = 0}
    E = { Range = 1000, Delay = 0.25, Speed = 1500, Width = 70}
    R = { Range = 350}
end

function Skarner:LoadMenu()
	Skarner = MenuElement({type = MENU, id = "Skarner", name = "Rugal Aimbot "..myHero.charName})
	Skarner:MenuElement({type = MENU, id = "Spells", name = "Spells"})
    Skarner.Spells:MenuElement({id = "Q", name = "Q", key = string.byte("Q")})
    Skarner.Spells:MenuElement({id = "W", name = "W", key = string.byte("W")})
    Skarner.Spells:MenuElement({id = "E", name = "E", key = string.byte("E")})
    Skarner.Spells:MenuElement({id = "ESearch", name = "E Search Range", min = 50, max = 3500, value = 250, step = 10})
    Skarner.Spells:MenuElement({id = "R", name = "R", key = string.byte("R")})
    Skarner.Spells:MenuElement({id = "RSearch", name = "R Search Range", min = 50, max = 3500, value = 250, step = 10})
	Skarner:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Skarner.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Skarner.Draw:MenuElement({id = "W", name = "W range", value = true})
    Skarner.Draw:MenuElement({id = "E", name = "E range", value = true})
    Skarner.Draw:MenuElement({id = "R", name = "R range", value = true})
    Skarner.Draw:MenuElement({id = "Search", name = "Search ranges", value = false})
end

function Skarner:Tick()
    self:Spells()
end

function Skarner:Spells()
	local target = GetTarget(3500)
    if Skarner.Spells.E:Value() then
        if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Skarner.Spells.ESearch:Value() then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, false, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            else
                EnableOrb(false)
                Control.CastSpell(HK_E, Game.mousePos())
                EnableOrb(true)
            end
        else
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.mousePos())
            EnableOrb(true)
        end
    end
    if Skarner.Spells.R:Value() then
        if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Skarner.Spells.RSearch:Value() then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        end
    end
    if Skarner.Spells.Q:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_Q)
        EnableOrb(true)
    end
	if Skarner.Spells.W:Value() then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Skarner:Draw()
    if myHero.dead then return end
    if Skarner.Draw.Q:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Skarner.Draw.W:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Skarner.Draw.E:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Skarner.Draw.R:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    if Skarner.Draw.Search:Value() then 
        Draw.Circle(Game.mousePos(), Skarner.Spells.ESearch:Value(), 1,  Draw.Color(255, 255, 255, 000))
        Draw.Circle(Game.mousePos(), Skarner.Spells.RSearch:Value(), 1,  Draw.Color(255, 255, 000, 000))
    end
end

local loaded = false
Callback.Add("Load", function()
    if loaded == false then
        _G[myHero.charName]()
        loaded = true
    end
end)

-- HPred
class "HPred"  Callback.Add("Tick", function() HPred:Tick() end)  local _reviveQueryFrequency = 3 local _lastReviveQuery = Game.Timer() local _reviveLookupTable = { ["LifeAura.troy"] = 4, ["ZileanBase_R_Buf.troy"] = 3, ["Aatrox_Base_Passive_Death_Activate"] = 3 }  local _blinkSpellLookupTable = { ["EzrealArcaneShift"] = 475, ["RiftWalk"] = 500, ["EkkoEAttack"] = 0, ["AlphaStrike"] = 0, ["KatarinaE"] = -255, ["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, }  local _blinkLookupTable = { "global_ss_flash_02.troy", "Lissandra_Base_E_Arrival.troy", "LeBlanc_Base_W_return_activation.troy" }  local _cachedRevives = {}  local _movementHistory = {}  function HPred:Tick() if Game.Timer() - _lastReviveQuery < _reviveQueryFrequency then return end  _lastReviveQuery=Game.Timer() for _, revive in pairs(_cachedRevives) do if Game.Timer() > revive.expireTime + .5 then _cachedRevives[_] = nil end end  for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then _cachedRevives[particle.networkID] = {} _cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name] local nearestDistance = 500 for i = 1, Game.HeroCount() do local t = Game.Hero(i) local tDistance = self:GetDistance(particle.pos, t.pos) if tDistance < nearestDistance then nearestDistance = nearestDistance _cachedRevives[particle.networkID]["owner"] = t.charName _cachedRevives[particle.networkID]["pos"] = t.pos _cachedRevives[particle.networkID]["isEnemy"] = t.isEnemy end end end end end  function HPred:GetEnemyNexusPosition() if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end end   function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision) local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius) if target and aimPosition then return target, aimPosition end end  function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies) local targetCount = 0 for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed) if predictedPos:To2D().onScreen then local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos) if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) ^ 2) then targetCount = targetCount + 1 end end end end return targetCount end  function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist) local _validTargets = {} for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTarget(t) and (not whitelist or whitelist[t.charName]) then local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision) if hitChance >= minimumHitChance and aimPosition:To2D().onScreen then _validTargets[t.charName] = {["hitChance"] = hitChance, ["aimPosition"] = aimPosition} end end end  local rHitChance = 0 local rAimPosition for targetName, targetData in pairs(_validTargets) do if targetData.hitChance > rHitChance then rHitChance = targetData.hitChance rAimPosition = targetData.aimPosition end end  if rHitChance >= minimumHitChance then return rHitChance, rAimPosition end end  function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision) self:UpdateMovementHistory(target)  local hitChance = 1  local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed) local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed) local reactionTime = self:PredictReactionTime(target, .1) local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)  if _movementHistory and _movementHistory[target.charName] and Game.Timer() - _movementHistory[target.charName]["ChangedAt"] < .25 then hitChance = 2 end  if not target.pathing or not target.pathing.hasMovePath then hitChance = 2 end  if movementRadius - target.boundingRadius <= radius /2 then hitChance = 3 end  if target.activeSpell and target.activeSpell.valid then if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then hitChance = 4 else hitChance = 3 end end  if self:GetDistance(myHero.pos, aimPosition) >= range then hitChance = -1 end  if hitChance > 0 and checkCollision then if self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then hitChance = -1 end end  return hitChance, aimPosition end  function HPred:PredictReactionTime(unit, minimumReactionTime) local reactionTime = minimumReactionTime  if unit.activeSpell and unit.activeSpell.valid then local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer() if windupRemaining > 0 then reactionTime = windupRemaining end end  local isRecalling, recallDuration = self:GetRecallingData(unit) if isRecalling and recallDuration > .25 then reactionTime = .25 end  return reactionTime end  function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)  local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then local dashEndPosition = t:GetPath(1) if self:GetDistance(source, dashEndPosition) <= range  and dashEndPosition:To2D().onScreen then local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed) local deltaInterceptTime =skillInterceptTime - dashTimeRemaining if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then target = t aimPosition = dashEndPosition return target, aimPosition end end end end end  function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.pos:To2D().onScreen then local success, timeRemaining = self:HasBuff(t, "zhonyasringshield") if success then local spellInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) local deltaInterceptTime = spellInterceptTime - timeRemaining if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end end end  function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for _, revive in pairs(_cachedRevives) do if revive.isEnemy and revive.pos:To2D().onScreen then local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed) if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then target = self:GetEnemyByName(revive.owner) aimPosition = revive.pos return target, aimPosition end end end end  function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer() if windupRemaining > 0 then local endPos local blinkRange = _blinkSpellLookupTable[t.activeSpell.name] if type(blinkRange) == "table" then local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange) if target and distance < 250 then endPos = target.pos end elseif blinkRange > 0 then endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z) endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * math.min(self:GetDistance(t.activeSpell.startPos,endPos), range) else local blinkTarget = self:GetObjectByHandle(t.activeSpell.target) if blinkTarget then local offsetDirection  if blinkRange == 0 then offsetDirection = (blinkTarget.pos - t.pos):Normalized() elseif blinkRange == -1 then offsetDirection = (t.pos-blinkTarget.pos):Normalized() elseif blinkRange == -255 then if radius > 250 then endPos = blinkTarget.pos end end  if offsetDirection then endPos = blinkTarget.pos - offsetDirection * 150 end  end end  local interceptTime = self:GetSpellInterceptTime(myHero.pos, endPos, delay,speed) local deltaInterceptTime = interceptTime - windupRemaining if self:GetDistance(source, endPos) <= range and endPos:To2D().onScreen and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then target = t aimPosition = endPos return target,aimPosition end end end end end  function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius) local target local aimPosition for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if particle and _blinkLookupTable[particle.name] and self:GetDistance(source, particle.pos) < range and particle.pos:To2D().onScreen then local pPos = particle.pos for k,v in pairs(self:GetEnemyHeroes()) do local t = v if t and t.isEnemy and self:GetDistance(t.pos, pPos) < t.boundingRadius then if (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then target = t aimPosition = pPos return target,aimPosition end end end end end end  function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) local interceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end  function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen then local immobileTime = self:GetImmobileTime(t)  local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed) if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end end  function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.TurretCount() do local turret = Game.Turret(i); if turret.isEnemy and self:GetDistance(source, turret.pos) <= range and turret.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(turret.pos,223.31) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = turret aimPosition =interceptPosition return target, aimPosition end end end end  for i = 1, Game.WardCount() do local ward = Game.Ward(i); if ward.isEnemy and self:GetDistance(source, ward.pos) <= range and ward.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(ward.pos,100.01) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = ward aimPosition = interceptPosition return target, aimPosition end end end end  for i = 1, Game.MinionCount() do local minion = Game.Minion(i); if minion.isEnemy and self:GetDistance(source, minion.pos) <= range and minion.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(minion.pos,143.25) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = minion aimPosition = interceptPosition return target, aimPosition end end end end end  function HPred:GetTargetMS(target) local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms return ms end  function HPred:Angle(A, B) local deltaPos = A - B local angle = math.atan2(deltaPos.x, deltaPos.z) *  180 / math.pi if angle < 0 then angle = angle + 360 end return angle end  function HPred:UpdateMovementHistory(unit) if not _movementHistory[unit.charName] then _movementHistory[unit.charName] = {} _movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos _movementHistory[unit.charName]["StartPos"] = unit.pathing.endPos _movementHistory[unit.charName]["PreviousAngle"] = 0 _movementHistory[unit.charName]["ChangedAt"] = Game.Timer() end  if _movementHistory[unit.charName]["EndPos"].x ~=unit.pathing.endPos.x or _movementHistory[unit.charName]["EndPos"].y ~=unit.pathing.endPos.y or _movementHistory[unit.charName]["EndPos"].z ~=unit.pathing.endPos.z then _movementHistory[unit.charName]["PreviousAngle"] = self:Angle(Vector(_movementHistory[unit.charName]["StartPos"].x, _movementHistory[unit.charName]["StartPos"].y, _movementHistory[unit.charName]["StartPos"].z), Vector(_movementHistory[unit.charName]["EndPos"].x, _movementHistory[unit.charName]["EndPos"].y, _movementHistory[unit.charName]["EndPos"].z)) _movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos _movementHistory[unit.charName]["StartPos"] = unit.pos _movementHistory[unit.charName]["ChangedAt"] = Game.Timer() end  end  function HPred:PredictUnitPosition(unit, delay) local predictedPosition = unit.pos local timeRemaining = delay local pathNodes = self:GetPathNodes(unit) for i = 1, #pathNodes -1 do local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1]) local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)  if timeRemaining > nodeTraversalTime then timeRemaining =  timeRemaining - nodeTraversalTime predictedPosition = pathNodes[i + 1] else local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized() predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining break; end end return predictedPosition end  function HPred:IsChannelling(target, interceptTime) if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then return true end end  function HPred:HasBuff(target, buffName, minimumDuration) local duration = minimumDuration if not minimumDuration then duration = 0 end local durationRemaining for i = 1, target.buffCount do local buff = target:GetBuff(i) if buff.duration > duration and buff.name == buffName then durationRemaining = buff.duration return true, durationRemaining end end end  function HPred:GetTeleportOffset(origin, magnitude) local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude return teleportOffset end  function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed) local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed return interceptTime end  function HPred:CanTarget(target) return target.isEnemy and target.alive and target.visible and target.isTargetable end  function HPred:CanTargetALL(target) return target.alive and target.visible and target.isTargetable end  function HPred:UnitMovementBounds(unit, delay, reactionTime) local startPosition = self:PredictUnitPosition(unit, delay)  local radius = 0 local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit) if (deltaDelay >0) then radius = self:GetTargetMS(unit) * deltaDelay end return startPosition, radius end  function HPred:GetImmobileTime(unit) local duration = 0 for i = 0, unit.buffCount do local buff = unit:GetBuff(i); if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then duration = buff.duration end end return duration end  function HPred:GetSlowedTime(unit) local duration = 0 for i = 0, unit.buffCount do local buff = unit:GetBuff(i); if buff.count > 0 and buff.duration > duration and buff.type == 10 then duration = buff.duration return duration end end return duration end  function HPred:GetPathNodes(unit) local nodes = {} table.insert(nodes, unit.pos) if unit.pathing.hasMovePath then for i = unit.pathing.pathIndex, unit.pathing.pathCount do path = unit:GetPath(i) table.insert(nodes, path) end end return nodes end  function HPred:GetObjectByHandle(handle) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.handle == handle then target = enemy return target end end  for i = 1, Game.MinionCount() do local minion = Game.Minion(i) if minion.handle == handle then target = minion return target end end  for i = 1, Game.WardCount() do local ward = Game.Ward(i); if ward.handle == handle then target = ward return target end end  for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if particle.handle == handle then target = particle return target end end end function HPred:GetObjectByPosition(position) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.MinionCount() do local enemy = Game.Minion(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.WardCount() do local enemy = Game.Ward(i); if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.ParticleCount() do local enemy = Game.Particle(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end end  function HPred:GetEnemyHeroByHandle(handle) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.handle == handle then target = enemy return target end end end  function HPred:GetNearestParticleByNames(origin, names) local target local distance = math.max for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) local d = self:GetDistance(origin, particle.pos) if d < distance then distance = d target = particle end end return target, distance end  function HPred:GetPathLength(nodes) local result = 0 for i = 1, #nodes -1 do result = result + self:GetDistance(nodes[i], nodes[i + 1]) end return result end  function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)  if not frequency then frequency = radius end local directionVector = (endPos - origin):Normalized() local checkCount = self:GetDistance(origin, endPos) / frequency for i = 1, checkCount do local checkPosition = origin + directionVector * i * frequency local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then return true end end return false end  function HPred:IsMinionIntersection(location, radius, delay, maxDistance) if not maxDistance then maxDistance = 500 end for i = 1, Game.MinionCount() do local minion = Game.Minion(i) if self:CanTarget(minion) and self:GetDistance(minion.pos, location) < maxDistance then local predictedPosition = self:PredictUnitPosition(minion, delay) if self:GetDistance(location, predictedPosition) <= radius + minion.boundingRadius then return true end end end return false end  function HPred:VectorPointProjectionOnLineSegment(v1, v2, v) assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)") local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y) local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2) local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) } local rS = rL < 0 and 0 or (rL > 1 and 1 or rL) local isOnSegment = rS == rL local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) } return pointSegment, pointLine, isOnSegment end   function HPred:GetRecallingData(unit) for K, Buff in pairs(GetBuffs(unit)) do if Buff.name == "recall" and Buff.duration > 0 then return true, Game.Timer() - Buff.startTime end end return false end  function HPred:GetEnemyByName(name) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.isEnemy and enemy.charName == name then target = enemy return target end end end  function HPred:IsPointInArc(source, origin, target, angle, range) local deltaAngle = math.abs(HPred:Angle(origin, target) - HPred:Angle(source, origin)) if deltaAngle < angle and self:GetDistance(origin, target) < range then return true end end  function HPred:GetEnemyHeroes() local _EnemyHeroes = {} for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy and enemy.isEnemy then table.insert(_EnemyHeroes, enemy) end end return _EnemyHeroes end  function HPred:GetDistanceSqr(p1, p2) return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2 end  function HPred:GetDistance(p1, p2) return math.sqrt(self:GetDistanceSqr(p1, p2)) end
