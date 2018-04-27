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

--[""] = {Q = , W = , E = , R = },

local ranges = {
    ["Aatrox"] = {Q = 650, W = 1, E = 100, R = 1},
    ["Ahri"] = {Q = 880, W = 700, E = 975, R = 450},
    ["Alistar"] = {Q = 365, W = 650, E = 350, R = 1},
    ["Amumu"] = {Q = 1100, W = 300, E = 350, R = 550},
    ["Annie"] = {Q = 625, W = 625, E = 1, R = 600},
    ["Ashe"] = {Q = 1, W = 1200, E = mathhuge, R = mathhuge},
    ["Brand"] = {Q = 1050, W = 900, E = 625, R = 750},
    ["Caitlyn"] = {Q = 1250, W = 800, E = 750, R = 3000},
    ["Chogath"] = {Q = 950, W = 650, E = 1, R = 175 + myHero.boundingRadius},
    ["Darius"] = {Q = 425, W = 1, E = 535, R = 460},
    ["DrMundo"] = {Q = 925, W = 325, E = 1, R = 1},
    ["Fizz"] = {Q = 550, W = 1, E = 730, R = 1300},
    ["Galio"] = {Q = 825, W = 350, E = 650, R = 5500},
    ["Garen"] = {Q = 1, W = 1, E = 325, R = 400},
    ["Illaoi"] = {Q = 850, W = 1, E = 900, R = 450},
    ["Jax"] = {Q = 700, W = 1, E = 300, R = 1},
    ["Kayle"] = {Q = 650, W = 900, E = 525, R = 900},
    ["Kayn"] = {Q = 350, W = 900, E = 1, R = 750},
    ["Maokai"] = {Q = 600, W = 525, E = 1100, R = 3000},
    ["MasterYi"] = {Q = 600, W = 1, E = 1, R = 1},
    ["MissFortune"] = {Q = 650, W = 1, E = 1000, R = 1400},
    ["Morgana"] = {Q = 1175, W = 900, E = 800, R = 625},
    ["Nunu"] = {Q = 125, W = 700, E = 550, R = 650},
    ["Olaf"] = {Q = 1000, W = 1, E = 325, R = 1},
    ["Pantheon"] = {Q = 600, W = 600, E = 600, R = 5500},
    ["Poppy"] = {Q = 430, W = 400, E = 425, R = 1900},
    ["Riven"] = {Q = 260, W = 125, E = 325, R = 900},
    ["Ryze"] = {Q = 1000, W = 615, E = 615, R = 3000},
    ["Singed"] = {Q = 1, W = 1000, E = 125, R = 1},
    ["Sivir"] = {Q = 1250, W = 1, E = 1, R = 1},
    ["Sona"] = {Q = 825, W = 1000, E = 430, R = 900},
    ["Soraka"] = {Q = 800, W = 550, E = 925, R = 1},
    ["Tryndamere"] = {Q = 1, W = 850, E = 660, R = 1},
    ["Vladimir"] = {Q = 600, W = 150, E = 600, R = 700},
    ["Volibear"] = {Q = 1, W = 400, E = 425, R = 500},
    ["Warwick"] = {Q = 350, W = 4000, E = 375, R = 25000},
    ["XinZhao"] = {Q = 1, W = 900, E = 650, R = 550},
    ["Yorick"] = {Q = 1, W = 600, E = 700, R = 600},
    ["Zilean"] = {Q = 900, W = 1, E = 550, R = 900},
}

local delays = {
    ["Aatrox"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Ahri"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Alistar"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Amumu"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Annie"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Ashe"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Brand"] = {Q = 0.25, W = 0.625, E = 0.25, R = 0.25},
    ["Caitlyn"] = {Q = 0.625, W = 0.25, E = 0.25, R = 0.25},
    ["Chogath"] = {Q = 0.5, W = 0.5, E = 0.25, R = 0.25},
    ["Darius"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["DrMundo"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Fizz"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Galio"] = {Q = 0.25, W = 0.25, E = 0.45, R = 0.25},
    ["Garen"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Illaoi"] = {Q = 0.75, W = 0.25, E = 0.25, R = 0.25},
    ["Jax"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Kayle"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Kayn"] = {Q = 0.15, W = 0.55, E = 0.25, R = 0.25},
    ["Maokai"] = {Q = 0.375, W = 0.25, E = 0.25, R = 0.25},
    ["MasterYi"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["MissFortune"] = {Q = 0.25, W = 0.25, E = 0.5, R = 0.01},
    ["Morgana"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Nunu"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Olaf"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Pantheon"] = {Q = 0.25, W = 0.25, E = 0.389, R = 0.25},
    ["Poppy"] = {Q = 0.32, W = 0.25, E = 0.25, R = 0.33},
    ["Riven"] = {Q = 0.267, W = 0.25, E = 0.25, R = 0.25},
    ["Ryze"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Singed"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Sivir"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Sona"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Soraka"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Tryndamere"] = {Q = 0.25, W = 0.25, E = 0.01, R = 0.25},
    ["Vladimir"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.389},
    ["Volibear"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
    ["Warwick"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.1},
    ["XinZhao"] = {Q = 0.25, W = 0.5, E = 0.25, R = 0.25},
    ["Yorick"] = {Q = 0.25, W = 0.25, E = 0.33, R = 0.25},
    ["Zilean"] = {Q = 0.25, W = 0.25, E = 0.25, R = 0.25},
}

local widths = {
    ["Aatrox"] = {Q = 275, W = 1, E = 100, R = 1},
    ["Ahri"] = {Q = 100, W = 1, E = 60, R = 1},
    ["Alistar"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Amumu"] = {Q = 80, W = 1, E = 1, R = 1},
    ["Annie"] = {Q = 1, W = 50, E = 1, R = 290},
    ["Ashe"] = {Q = 1, W = 58, E = 1, R = 130},
    ["Brand"] = {Q = 60, W = 250, E = 1, R = 1},
    ["Caitlyn"] = {Q = 90, W = 75, E = 70, R = 1},
    ["Chogath"] = {Q = 350, W = 60, E = 1, R = 1},
    ["Darius"] = {Q = 1, W = 1, E = 50, R = 1},
    ["DrMundo"] = {Q = 60, W = 1, E = 1, R = 1},
    ["Fizz"] = {Q = 1, W = 1, E = 330, R = 80},
    ["Galio"] = {Q = 150, W = 1, E = 160, R = 1},
    ["Garen"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Illaoi"] = {Q = 100, W = 1, E = 50, R = 1},
    ["Jax"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Kayle"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Kayn"] = {Q = 350, W = 90, E = 1, R = 1},
    ["Maokai"] = {Q = 110, W = 1, E = 1, R = 1},
    ["MasterYi"] = {Q = 1, W = 1, E = 1, R = 1},
    ["MissFortune"] = {Q = 1, W = 1, E = 400, R = 40},
    ["Morgana"] = {Q = 70, W = 325, E = 1, R = 1},
    ["Nunu"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Olaf"] = {Q = 90, W = 1, E = 1, R = 1},
    ["Pantheon"] = {Q = 1, W = 1, E = 80, R = 1},
    ["Poppy"] = {Q = 85, W = 1, E = 1, R = 100},
    ["Riven"] = {Q = 135, W = 1, E = 1, R = 50},
    ["Ryze"] = {Q = 55, W = 1, E = 1, R = 1},
    ["Singed"] = {Q = 1, W = 265, E = 1, R = 1},
    ["Sivir"] = {Q = 90, W = 1, E = 1, R = 1},
    ["Sona"] = {Q = 1, W = 1, E = 1, R = 140},
    ["Soraka"] = {Q = 235, W = 1, E = 300, R = 1},
    ["Tryndamere"] = {Q = 1, W = 1, E = 225, R = 1},
    ["Vladimir"] = {Q = 1, W = 1, E = 1, R = 350},
    ["Volibear"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Warwick"] = {Q = 1, W = 1, E = 1, R = 45},
    ["XinZhao"] = {Q = 1, W = 45, E = 1, R = 1},
    ["Yorick"] = {Q = 1, W = 300, E = 25, R = 1},
    ["Zilean"] = {Q = 180, W = 1, E = 1, R = 1},
}

local speeds = {
    ["Aatrox"] = {Q = 450, W = 1, E = 1250, R = 1},
    ["Ahri"] = {Q = 2500, W = 1, E = 1550, R = 1},
    ["Alistar"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Amumu"] = {Q = 2000, W = 1, E = 1, R = 1},
    ["Annie"] = {Q = 1, W = mathhuge, E = 1, R = mathhuge},
    ["Ashe"] = {Q = 1, W = 1500, E = 1, R = 1600},
    ["Brand"] = {Q = 1600, W = mathhuge, E = 1, R = 1},
    ["Caitlyn"] = {Q = 2200, W = mathhuge, E = 1600, R = 1},
    ["Chogath"] = {Q = mathhuge, W = mathhuge, E = 1, R = 1},
    ["Darius"] = {Q = 1, W = 1, E = mathhuge, R = 1},
    ["DrMundo"] = {Q = 2000, W = 1, E = 1, R = 1},
    ["Fizz"] = {Q = 1, W = 1, E = mathhuge, R = 1300},
    ["Galio"] = {Q = 1150, W = 1, E = 1400, R = 1},
    ["Garen"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Illaoi"] = {Q = mathhuge, W = 1, E = 1900, R = 1},
    ["Jax"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Kayle"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Kayn"] = {Q = mathhuge, W = mathhuge, E = 1, R = 1},
    ["Maokai"] = {Q = 1600, W = 1, E = 1, R = 1},
    ["MasterYi"] = {Q = 1, W = 1, E = 1, R = 1},
    ["MissFortune"] = {Q = 1, W = 1, E = mathhuge, R = mathhuge},
    ["Morgana"] = {Q = 1200, W = mathhuge, E = 1, R = 1},
    ["Nunu"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Olaf"] = {Q = 1600, W = 1, E = 1, R = 1},
    ["Pantheon"] = {Q = 1, W = 1, E = mathhuge, R = 1},
    ["Poppy"] = {Q = mathhuge, W = 1, E = 1, R = 1600},
    ["Riven"] = {Q = mathhuge, W = 1, E = 1, R = 1600},
    ["Ryze"] = {Q = 1700, W = 1, E = 1, R = 1},
    ["Singed"] = {Q = 1, W = mathhuge, E = 1, R = 1},
    ["Sivir"] = {Q = 1350, W = 1, E = 1, R = 1},
    ["Sona"] = {Q = 1, W = 1, E = 1, R = 2400},
    ["Soraka"] = {Q = 1150, W = 1, E = mathhuge, R = 1},
    ["Tryndamere"] = {Q = 1, W = 1, E = 1300, R = 1},
    ["Vladimir"] = {Q = 1, W = 1, E = 1, R = mathhuge},
    ["Volibear"] = {Q = 1, W = 1, E = 1, R = 1},
    ["Warwick"] = {Q = 1, W = 1, E = 1, R = 1800},
    ["XinZhao"] = {Q = 1, W = mathhuge, E = 1, R = 1},
    ["Yorick"] = {Q = 1, W = mathhuge, E = 2100, R = 1},
    ["Zilean"] = {Q = 2050, W = 1, E = 1, R = 1},
}

class "Helper"

function Helper:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Helper:LoadSpells()
    local myName = myHero.charName
    Q = { Range = ranges[myName].Q, Delay = delays[myName].Q, Width = widths[myName].Q, Speed = speeds[myName].Q}
    W = { Range = ranges[myName].W, Delay = delays[myName].W, Width = widths[myName].W, Speed = speeds[myName].W}
    E = { Range = ranges[myName].E, Delay = delays[myName].E, Width = widths[myName].E, Speed = speeds[myName].E}
    R = { Range = ranges[myName].R, Delay = delays[myName].R, Width = widths[myName].R, Speed = speeds[myName].R}
end

function Helper:LoadMenu()
    Helper = MenuElement({type = MENU, id = "Helper", name = "Rugal Caster "..myHero.charName})
    
    local heroName = myHero.charName
    Helper:MenuElement({id = heroName, name = "Helper " ..heroName, type = MENU})
    Helper[heroName]:MenuElement({type = MENU, id = "Spells", name = "Spells"})

    Helper[heroName].Spells:MenuElement({type = MENU, id = "Q", name = "Q"})
    Helper[heroName].Spells.Q:MenuElement({id = "Key", name = "Key", key = string.byte("Q")})
    Helper[heroName].Spells.Q:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target","Self Cast","Ally Cast","Self + Ally Cast"}})
    Helper[heroName].Spells.Q:MenuElement({id = "Collision", name = "Collision?", value = true})
    Helper[heroName].Spells.Q:MenuElement({id = "Search", name = "Search Range", min = 50, max = 3500, value = 250, step = 10})
    Helper[heroName].Spells.Q:MenuElement({id = "Range", name = "Draw Range", value = true})
    Helper[heroName].Spells.Q:MenuElement({id = "SearchRange", name = "Draw Search Range", value = true})

    Helper[heroName].Spells:MenuElement({type = MENU, id = "W", name = "W"})
    Helper[heroName].Spells.W:MenuElement({id = "Key", name = "Key", key = string.byte("W")})
    Helper[heroName].Spells.W:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target","Self Cast","Ally Cast","Self + Ally Cast"}})
    Helper[heroName].Spells.W:MenuElement({id = "Collision", name = "Collision?", value = true})
    Helper[heroName].Spells.W:MenuElement({id = "Search", name = "Search Range", min = 50, max = 3500, value = 250, step = 10})
    Helper[heroName].Spells.W:MenuElement({id = "Range", name = "Draw Range", value = true})
    Helper[heroName].Spells.W:MenuElement({id = "SearchRange", name = "Draw Search Range", value = true})

    Helper[heroName].Spells:MenuElement({type = MENU, id = "E", name = "E"})
    Helper[heroName].Spells.E:MenuElement({id = "Key", name = "Key", key = string.byte("E")})
    Helper[heroName].Spells.E:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target","Self Cast","Ally Cast","Self + Ally Cast"}})
    Helper[heroName].Spells.E:MenuElement({id = "Collision", name = "Collision?", value = true})
    Helper[heroName].Spells.E:MenuElement({id = "Search", name = "Search Range", min = 50, max = 3500, value = 250, step = 10})
    Helper[heroName].Spells.E:MenuElement({id = "Range", name = "Draw Range", value = true})
    Helper[heroName].Spells.E:MenuElement({id = "SearchRange", name = "Draw Search Range", value = true})

    Helper[heroName].Spells:MenuElement({type = MENU, id = "R", name = "R"})
    Helper[heroName].Spells.R:MenuElement({id = "Key", name = "Key", key = string.byte("R")})
    Helper[heroName].Spells.R:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target","Self Cast","Ally Cast","Self + Ally Cast"}})
    Helper[heroName].Spells.R:MenuElement({id = "Collision", name = "Collision?", value = true})
    Helper[heroName].Spells.R:MenuElement({id = "Search", name = "Search Range", min = 50, max = 3500, value = 250, step = 10})
    Helper[heroName].Spells.R:MenuElement({id = "Range", name = "Draw Range", value = true})
    Helper[heroName].Spells.R:MenuElement({id = "SearchRange", name = "Draw Search Range", value = true})
end

function Helper:Tick()
    self:Spells()
end

function Helper:Spells()
    local target = GetTarget(25000)

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
    local howQ = Helper[myHero.charName].Spells.Q.How:Value()
    local usekey = Helper[myHero.charName].Spells.Q.Key:Value()
    if howQ == 1 then
        if usekey then
            if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.Q.Search:Value() then
                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, Helper[myHero.charName].Spells.Q.Collision:Value(), nil)
                if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                    Control.CastSpell(HK_Q, aimPosition)
                end
            else
                Control.CastSpell(HK_Q, Game.mousePos())
            end
        end
    elseif howQ == 2 then
        if usekey then
            if target and GetDistance(target.pos) < Q.Range and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.Q.Search:Value() then
                Control.CastSpell(HK_Q, target)
            else
                local foeminion = ClosestMinion(Q.Range,foe)
                if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.Q.Search:Value() then
                    Control.CastSpell(HK_Q, foeminion)
                else
                    local neutralminion = ClosestMinion(Q.Range,neutral)
                    if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.Q.Search:Value() then
                        Control.CastSpell(HK_Q, neutralminion)
                    end
                end
            end
        end
    elseif howQ == 3 then
        if usekey then
            Control.CastSpell(HK_Q, Game.cursorPos())
        end
    elseif howQ == 4 then
        if usekey then
            Control.CastSpell(HK_Q)
        end
    elseif howQ == 5 then
        if usekey then
            Control.CastSpell(HK_Q,myHero)
        end
    elseif howQ == 5 then
        if usekey then
            local ally = ClosestHero(Q.Range,friend)
            if ally and not ally.isMe and GetDistance(ally.pos) < Q.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.Q.Search:Value() then
                Control.CastSpell(HK_Q, ally)
            end
        end
    elseif howQ == 6 then
        if usekey then
            local ally = ClosestHero(Q.Range,friend)
            if ally and GetDistance(ally.pos) < Q.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.Q.Search:Value() then
                Control.CastSpell(HK_Q, ally)
            end
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
    local howW = Helper[myHero.charName].Spells.W.How:Value()
    local usekey = Helper[myHero.charName].Spells.W.Key:Value()
    if howW == 1 then
        if usekey then
            if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.W.Search:Value() then
                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, W.Range, W.Delay, W.Speed, W.Width, Helper[myHero.charName].Spells.W.Collision:Value(), nil)
                if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= W.Range then
                    Control.CastSpell(HK_W, aimPosition)
                end
            else
                Control.CastSpell(HK_W, Game.mousePos())
            end
        end
    elseif howW == 2 then
        if usekey then
            if target and GetDistance(target.pos) < W.Range and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.W.Search:Value() then
                Control.CastSpell(HK_W, target)
            else
                local foeminion = ClosestMinion(W.Range,foe)
                if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.W.Search:Value() then
                    Control.CastSpell(HK_W, foeminion)
                else
                    local neutralminion = ClosestMinion(W.Range,neutral)
                    if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.W.Search:Value() then
                        Control.CastSpell(HK_W, neutralminion)
                    end
                end
            end
        end
    elseif howW == 3 then
        if usekey then
            Control.CastSpell(HK_W, Game.cursorPos())
        end
    elseif howW == 4 then
        if usekey then
            Control.CastSpell(HK_W)
        end
    elseif howW == 5 then
        if usekey then
            Control.CastSpell(HK_W,myHero)
        end
    elseif howW == 5 then
        if usekey then
            local ally = ClosestHero(W.Range,friend)
            if ally and not ally.isMe and GetDistance(ally.pos) < W.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.W.Search:Value() then
                Control.CastSpell(HK_W, ally)
            end
        end
    elseif howW == 6 then
        if usekey then
            local ally = ClosestHero(W.Range,friend)
            if ally and GetDistance(ally.pos) < W.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.W.Search:Value() then
                Control.CastSpell(HK_W, ally)
            end
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
    local howE = Helper[myHero.charName].Spells.E.How:Value()
    local usekey = Helper[myHero.charName].Spells.E.Key:Value()
    if howE == 1 then
        if usekey then
            if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.E.Search:Value() then
                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, E.Range, E.Delay, E.Speed, E.Width, Helper[myHero.charName].Spells.E.Collision:Value(), nil)
                if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= E.Range then
                    Control.CastSpell(HK_E, aimPosition)
                end
            else
                Control.CastSpell(HK_E, Game.mousePos())
            end
        end
    elseif howE == 2 then
        if usekey then
            if target and GetDistance(target.pos) < E.Range and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.E.Search:Value() then
                Control.CastSpell(HK_E, target)
            else
                local foeminion = ClosestMinion(E.Range,foe)
                if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.E.Search:Value() then
                    Control.CastSpell(HK_E, foeminion)
                else
                    local neutralminion = ClosestMinion(E.Range,neutral)
                    if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.E.Search:Value() then
                        Control.CastSpell(HK_E, neutralminion)
                    end
                end
            end
        end
    elseif howE == 3 then
        if usekey then
            Control.CastSpell(HK_E, Game.cursorPos())
        end
    elseif howE == 4 then
        if usekey then
            Control.CastSpell(HK_E)
        end
    elseif howE == 5 then
        if usekey then
            Control.CastSpell(HK_E,myHero)
        end
    elseif howE == 5 then
        if usekey then
            local ally = ClosestHero(E.Range,friend)
            if ally and not ally.isMe and GetDistance(ally.pos) < E.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.E.Search:Value() then
                Control.CastSpell(HK_E, ally)
            end
        end
    elseif howE == 6 then
        if usekey then
            local ally = ClosestHero(E.Range,friend)
            if ally and GetDistance(ally.pos) < E.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.E.Search:Value() then
                Control.CastSpell(HK_E, ally)
            end
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
    local howR = Helper[myHero.charName].Spells.R.How:Value()
    local usekey = Helper[myHero.charName].Spells.R.Key:Value()
    if howR == 1 then
        if usekey then
            if target and HPred:CanTarget(target) and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.R.Search:Value() then
                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, R.Range, R.Delay, R.Speed, R.Width, Helper[myHero.charName].Spells.R.Collision:Value(), nil)
                if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= R.Range then
                    Control.CastSpell(HK_R, aimPosition)
                end
            else
                Control.CastSpell(HK_R, Game.mousePos())
            end
        end
    elseif howR == 2 then
        if usekey then
            if target and GetDistance(target.pos) < R.Range and GetDistance(target.pos,Game.mousePos()) < Helper[myHero.charName].Spells.R.Search:Value() then
                Control.CastSpell(HK_R, target)
            else
                local foeminion = ClosestMinion(R.Range,foe)
                if foeminion and GetDistance(foeminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.R.Search:Value() then
                    Control.CastSpell(HK_R, foeminion)
                else
                    local neutralminion = ClosestMinion(R.Range,neutral)
                    if neutralminion and GetDistance(neutralminion.pos,Game.mousePos()) < Helper[myHero.charName].Spells.R.Search:Value() then
                        Control.CastSpell(HK_R, neutralminion)
                    end
                end
            end
        end
    elseif howR == 3 then
        if usekey then
            Control.CastSpell(HK_R, Game.cursorPos())
        end
    elseif howR == 4 then
        if usekey then
            Control.CastSpell(HK_R)
        end
    elseif howR == 5 then
        if usekey then
            Control.CastSpell(HK_R,myHero)
        end
    elseif howR == 5 then
        if usekey then
            local ally = ClosestHero(R.Range,friend)
            if ally and not ally.isMe and GetDistance(ally.pos) < R.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.R.Search:Value() then
                Control.CastSpell(HK_R, ally)
            end
        end
    elseif howR == 6 then
        if usekey then
            local ally = ClosestHero(R.Range,friend)
            if ally and GetDistance(ally.pos) < R.Range and GetDistance(ally.pos,Game.mousePos()) < Helper[myHero.charName].Spells.R.Search:Value() then
                Control.CastSpell(HK_R, ally)
            end
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
end

function Helper:Draw()
    if myHero.dead then return end
    if Helper[myHero.charName].Spells.Q.Range:Value() then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Helper[myHero.charName].Spells.W.Range:Value() then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Helper[myHero.charName].Spells.E.Range:Value() then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Helper[myHero.charName].Spells.R.Range:Value() then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
    
    if Helper[myHero.charName].Spells.Q.SearchRange:Value() then Draw.Circle(Game.mousePos(), Helper[myHero.charName].Spells.Q.Search:Value(), 1,  Draw.Color(255, 000, 000, 255)) end
    if Helper[myHero.charName].Spells.W.SearchRange:Value() then Draw.Circle(Game.mousePos(), Helper[myHero.charName].Spells.W.Search:Value(), 1,  Draw.Color(255, 000, 255, 000)) end
    if Helper[myHero.charName].Spells.E.SearchRange:Value() then Draw.Circle(Game.mousePos(), Helper[myHero.charName].Spells.E.Search:Value(), 1,  Draw.Color(255, 255, 255, 000)) end
    if Helper[myHero.charName].Spells.R.SearchRange:Value() then Draw.Circle(Game.mousePos(), Helper[myHero.charName].Spells.R.Search:Value(), 1,  Draw.Color(255, 255, 000, 000)) end
end

local loaded = false
Callback.Add("Load", function()
    if loaded == false then
        Helper()
        loaded = true
    end
end)

-- HPred
class "HPred"  Callback.Add("Tick", function() HPred:Tick() end)  local _reviveQueryFrequency = 3 local _lastReviveQuery = Game.Timer() local _reviveLookupTable = { ["LifeAura.troy"] = 4, ["ZileanBase_R_Buf.troy"] = 3, ["Aatrox_Base_Passive_Death_Activate"] = 3 }  local _blinkSpellLookupTable = { ["EzrealArcaneShift"] = 475, ["RiftWalk"] = 500, ["EkkoEAttack"] = 0, ["AlphaStrike"] = 0, ["KatarinaE"] = -255, ["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, }  local _blinkLookupTable = { "global_ss_flash_02.troy", "Lissandra_Base_E_Arrival.troy", "LeBlanc_Base_W_return_activation.troy" }  local _cachedRevives = {}  local _movementHistory = {}  function HPred:Tick() if Game.Timer() - _lastReviveQuery < _reviveQueryFrequency then return end  _lastReviveQuery=Game.Timer() for _, revive in pairs(_cachedRevives) do if Game.Timer() > revive.expireTime + .5 then _cachedRevives[_] = nil end end  for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then _cachedRevives[particle.networkID] = {} _cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name] local nearestDistance = 500 for i = 1, Game.HeroCount() do local t = Game.Hero(i) local tDistance = self:GetDistance(particle.pos, t.pos) if tDistance < nearestDistance then nearestDistance = nearestDistance _cachedRevives[particle.networkID]["owner"] = t.charName _cachedRevives[particle.networkID]["pos"] = t.pos _cachedRevives[particle.networkID]["isEnemy"] = t.isEnemy end end end end end  function HPred:GetEnemyNexusPosition() if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end end   function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision) local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius) if target and aimPosition then return target, aimPosition end end  function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies) local targetCount = 0 for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed) if predictedPos:To2D().onScreen then local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos) if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) ^ 2) then targetCount = targetCount + 1 end end end end return targetCount end  function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist) local _validTargets = {} for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTarget(t) and (not whitelist or whitelist[t.charName]) then local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision) if hitChance >= minimumHitChance and aimPosition:To2D().onScreen then _validTargets[t.charName] = {["hitChance"] = hitChance, ["aimPosition"] = aimPosition} end end end  local rHitChance = 0 local rAimPosition for targetName, targetData in pairs(_validTargets) do if targetData.hitChance > rHitChance then rHitChance = targetData.hitChance rAimPosition = targetData.aimPosition end end  if rHitChance >= minimumHitChance then return rHitChance, rAimPosition end end  function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision) self:UpdateMovementHistory(target)  local hitChance = 1  local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed) local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed) local reactionTime = self:PredictReactionTime(target, .1) local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)  if _movementHistory and _movementHistory[target.charName] and Game.Timer() - _movementHistory[target.charName]["ChangedAt"] < .25 then hitChance = 2 end  if not target.pathing or not target.pathing.hasMovePath then hitChance = 2 end  if movementRadius - target.boundingRadius <= radius /2 then hitChance = 3 end  if target.activeSpell and target.activeSpell.valid then if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then hitChance = 4 else hitChance = 3 end end  if self:GetDistance(myHero.pos, aimPosition) >= range then hitChance = -1 end  if hitChance > 0 and checkCollision then if self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then hitChance = -1 end end  return hitChance, aimPosition end  function HPred:PredictReactionTime(unit, minimumReactionTime) local reactionTime = minimumReactionTime  if unit.activeSpell and unit.activeSpell.valid then local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer() if windupRemaining > 0 then reactionTime = windupRemaining end end  local isRecalling, recallDuration = self:GetRecallingData(unit) if isRecalling and recallDuration > .25 then reactionTime = .25 end  return reactionTime end  function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)  local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then local dashEndPosition = t:GetPath(1) if self:GetDistance(source, dashEndPosition) <= range  and dashEndPosition:To2D().onScreen then local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed) local deltaInterceptTime =skillInterceptTime - dashTimeRemaining if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then target = t aimPosition = dashEndPosition return target, aimPosition end end end end end  function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.pos:To2D().onScreen then local success, timeRemaining = self:HasBuff(t, "zhonyasringshield") if success then local spellInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) local deltaInterceptTime = spellInterceptTime - timeRemaining if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end end end  function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for _, revive in pairs(_cachedRevives) do if revive.isEnemy and revive.pos:To2D().onScreen then local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed) if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then target = self:GetEnemyByName(revive.owner) aimPosition = revive.pos return target, aimPosition end end end end  function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer() if windupRemaining > 0 then local endPos local blinkRange = _blinkSpellLookupTable[t.activeSpell.name] if type(blinkRange) == "table" then local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange) if target and distance < 250 then endPos = target.pos end elseif blinkRange > 0 then endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z) endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * math.min(self:GetDistance(t.activeSpell.startPos,endPos), range) else local blinkTarget = self:GetObjectByHandle(t.activeSpell.target) if blinkTarget then local offsetDirection  if blinkRange == 0 then offsetDirection = (blinkTarget.pos - t.pos):Normalized() elseif blinkRange == -1 then offsetDirection = (t.pos-blinkTarget.pos):Normalized() elseif blinkRange == -255 then if radius > 250 then endPos = blinkTarget.pos end end  if offsetDirection then endPos = blinkTarget.pos - offsetDirection * 150 end  end end  local interceptTime = self:GetSpellInterceptTime(myHero.pos, endPos, delay,speed) local deltaInterceptTime = interceptTime - windupRemaining if self:GetDistance(source, endPos) <= range and endPos:To2D().onScreen and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then target = t aimPosition = endPos return target,aimPosition end end end end end  function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius) local target local aimPosition for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if particle and _blinkLookupTable[particle.name] and self:GetDistance(source, particle.pos) < range and particle.pos:To2D().onScreen then local pPos = particle.pos for k,v in pairs(self:GetEnemyHeroes()) do local t = v if t and t.isEnemy and self:GetDistance(t.pos, pPos) < t.boundingRadius then if (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then target = t aimPosition = pPos return target,aimPosition end end end end end end  function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) local interceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end  function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen then local immobileTime = self:GetImmobileTime(t)  local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed) if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end end  function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.TurretCount() do local turret = Game.Turret(i); if turret.isEnemy and self:GetDistance(source, turret.pos) <= range and turret.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(turret.pos,223.31) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = turret aimPosition =interceptPosition return target, aimPosition end end end end  for i = 1, Game.WardCount() do local ward = Game.Ward(i); if ward.isEnemy and self:GetDistance(source, ward.pos) <= range and ward.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(ward.pos,100.01) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = ward aimPosition = interceptPosition return target, aimPosition end end end end  for i = 1, Game.MinionCount() do local minion = Game.Minion(i); if minion.isEnemy and self:GetDistance(source, minion.pos) <= range and minion.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(minion.pos,143.25) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = minion aimPosition = interceptPosition return target, aimPosition end end end end end  function HPred:GetTargetMS(target) local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms return ms end  function HPred:Angle(A, B) local deltaPos = A - B local angle = math.atan2(deltaPos.x, deltaPos.z) *  180 / math.pi if angle < 0 then angle = angle + 360 end return angle end  function HPred:UpdateMovementHistory(unit) if not _movementHistory[unit.charName] then _movementHistory[unit.charName] = {} _movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos _movementHistory[unit.charName]["StartPos"] = unit.pathing.endPos _movementHistory[unit.charName]["PreviousAngle"] = 0 _movementHistory[unit.charName]["ChangedAt"] = Game.Timer() end  if _movementHistory[unit.charName]["EndPos"].x ~=unit.pathing.endPos.x or _movementHistory[unit.charName]["EndPos"].y ~=unit.pathing.endPos.y or _movementHistory[unit.charName]["EndPos"].z ~=unit.pathing.endPos.z then _movementHistory[unit.charName]["PreviousAngle"] = self:Angle(Vector(_movementHistory[unit.charName]["StartPos"].x, _movementHistory[unit.charName]["StartPos"].y, _movementHistory[unit.charName]["StartPos"].z), Vector(_movementHistory[unit.charName]["EndPos"].x, _movementHistory[unit.charName]["EndPos"].y, _movementHistory[unit.charName]["EndPos"].z)) _movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos _movementHistory[unit.charName]["StartPos"] = unit.pos _movementHistory[unit.charName]["ChangedAt"] = Game.Timer() end  end  function HPred:PredictUnitPosition(unit, delay) local predictedPosition = unit.pos local timeRemaining = delay local pathNodes = self:GetPathNodes(unit) for i = 1, #pathNodes -1 do local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1]) local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)  if timeRemaining > nodeTraversalTime then timeRemaining =  timeRemaining - nodeTraversalTime predictedPosition = pathNodes[i + 1] else local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized() predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining break; end end return predictedPosition end  function HPred:IsChannelling(target, interceptTime) if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then return true end end  function HPred:HasBuff(target, buffName, minimumDuration) local duration = minimumDuration if not minimumDuration then duration = 0 end local durationRemaining for i = 1, target.buffCount do local buff = target:GetBuff(i) if buff.duration > duration and buff.name == buffName then durationRemaining = buff.duration return true, durationRemaining end end end  function HPred:GetTeleportOffset(origin, magnitude) local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude return teleportOffset end  function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed) local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed return interceptTime end  function HPred:CanTarget(target) return target.isEnemy and target.alive and target.visible and target.isTargetable end  function HPred:CanTargetALL(target) return target.alive and target.visible and target.isTargetable end  function HPred:UnitMovementBounds(unit, delay, reactionTime) local startPosition = self:PredictUnitPosition(unit, delay)  local radius = 0 local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit) if (deltaDelay >0) then radius = self:GetTargetMS(unit) * deltaDelay end return startPosition, radius end  function HPred:GetImmobileTime(unit) local duration = 0 for i = 0, unit.buffCount do local buff = unit:GetBuff(i); if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then duration = buff.duration end end return duration end  function HPred:GetSlowedTime(unit) local duration = 0 for i = 0, unit.buffCount do local buff = unit:GetBuff(i); if buff.count > 0 and buff.duration > duration and buff.type == 10 then duration = buff.duration return duration end end return duration end  function HPred:GetPathNodes(unit) local nodes = {} table.insert(nodes, unit.pos) if unit.pathing.hasMovePath then for i = unit.pathing.pathIndex, unit.pathing.pathCount do path = unit:GetPath(i) table.insert(nodes, path) end end return nodes end  function HPred:GetObjectByHandle(handle) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.handle == handle then target = enemy return target end end  for i = 1, Game.MinionCount() do local minion = Game.Minion(i) if minion.handle == handle then target = minion return target end end  for i = 1, Game.WardCount() do local ward = Game.Ward(i); if ward.handle == handle then target = ward return target end end  for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if particle.handle == handle then target = particle return target end end end function HPred:GetObjectByPosition(position) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.MinionCount() do local enemy = Game.Minion(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.WardCount() do local enemy = Game.Ward(i); if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.ParticleCount() do local enemy = Game.Particle(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end end  function HPred:GetEnemyHeroByHandle(handle) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.handle == handle then target = enemy return target end end end  function HPred:GetNearestParticleByNames(origin, names) local target local distance = math.max for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) local d = self:GetDistance(origin, particle.pos) if d < distance then distance = d target = particle end end return target, distance end  function HPred:GetPathLength(nodes) local result = 0 for i = 1, #nodes -1 do result = result + self:GetDistance(nodes[i], nodes[i + 1]) end return result end  function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)  if not frequency then frequency = radius end local directionVector = (endPos - origin):Normalized() local checkCount = self:GetDistance(origin, endPos) / frequency for i = 1, checkCount do local checkPosition = origin + directionVector * i * frequency local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then return true end end return false end  function HPred:IsMinionIntersection(location, radius, delay, maxDistance) if not maxDistance then maxDistance = 500 end for i = 1, Game.MinionCount() do local minion = Game.Minion(i) if self:CanTarget(minion) and self:GetDistance(minion.pos, location) < maxDistance then local predictedPosition = self:PredictUnitPosition(minion, delay) if self:GetDistance(location, predictedPosition) <= radius + minion.boundingRadius then return true end end end return false end  function HPred:VectorPointProjectionOnLineSegment(v1, v2, v) assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)") local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y) local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2) local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) } local rS = rL < 0 and 0 or (rL > 1 and 1 or rL) local isOnSegment = rS == rL local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) } return pointSegment, pointLine, isOnSegment end   function HPred:GetRecallingData(unit) for K, Buff in pairs(GetBuffs(unit)) do if Buff.name == "recall" and Buff.duration > 0 then return true, Game.Timer() - Buff.startTime end end return false end  function HPred:GetEnemyByName(name) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.isEnemy and enemy.charName == name then target = enemy return target end end end  function HPred:IsPointInArc(source, origin, target, angle, range) local deltaAngle = math.abs(HPred:Angle(origin, target) - HPred:Angle(source, origin)) if deltaAngle < angle and self:GetDistance(origin, target) < range then return true end end  function HPred:GetEnemyHeroes() local _EnemyHeroes = {} for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy and enemy.isEnemy then table.insert(_EnemyHeroes, enemy) end end return _EnemyHeroes end  function HPred:GetDistanceSqr(p1, p2) return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2 end  function HPred:GetDistance(p1, p2) return math.sqrt(self:GetDistanceSqr(p1, p2)) end
