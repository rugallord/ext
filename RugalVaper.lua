local neutral = 300
local friend = myHero.team
local foe = neutral - friend

local mathhuge = math.huge
local mathsqrt = math.sqrt
local mathpow = math.pow
local mathmax = math.max
local mathfloor = math.floor

local function Ready(slot)
    return Game.CanUseSpell(slot) == 0
end

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

local function GetMode()
    if _G.SDK then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
            return "Harass"	
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]     then return "Clear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
            return "LastHit"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    elseif _G.gsoSDK.Orbwalker then
        return _G.gsoSDK.Orbwalker:UOL_GetMode()
    else
        return GOS.GetMode()
    end
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

local function CalcPhysicalDamage(source, target, amount)
    local ArmorPenPercent = source.armorPenPercent
    local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
    local BonusArmorPen = source.bonusArmorPenPercent
    local armor = target.armor
    local bonusArmor = target.bonusArmor
    local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)
    if armor < 0 then
        value = 2 - 100 / (100 - armor)
    elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
        value = 1
    end
    return value * amount
  end

local function CalcMagicalDamage(source, target, amount)
    local mr = target.magicResist
    local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)  
    if mr < 0 then
        value = 2 - 100 / (100 - mr)
    elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
        value = 1
    end
    return value * amount
end

local function ClosestHero(range,team)
    local bestHero = nil
    local closest = math.huge
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

local function ClosestMinion(range,team)
    local bestMinion = nil
    local closest = math.huge
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if GetDistance(minion.pos) < range and minion.team == team and not minion.dead then
            local Distance = GetDistance(minion.pos, mousePos)
            if Distance < closest then
                bestMinion = minion
                closest = Distance
            end
        end
    end
    return bestMinion
end

local function GetClearMinion(range)
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if GetDistance(minion.pos) < range and not minion.dead and (minion.team == neutral or minion.team == foe) then
            return minion
        end
    end
end

local function Hp(source)
    local source = source or myHero
    return source.health/source.maxHealth * 100
end

local function Mana(source)
    local source = source or myHero
    return source.mana/source.maxMana * 100
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
    W = { Range = 325}
    E = { Range = 300}
    R = { Range = 0}
end

function DrMundo:LoadMenu()
	DrMundo = MenuElement({type = MENU, id = "DrMundo", name = "Rugal Vaper "..myHero.charName})
    DrMundo:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    DrMundo.Combo:MenuElement({id = "Q", name = "Q", value = true})
    DrMundo.Combo:MenuElement({id = "W", name = "W", value = true})
    DrMundo.Combo:MenuElement({id = "E", name = "E", value = true})
    DrMundo:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    DrMundo.Harass:MenuElement({id = "T", name = "Toggle Spells", key = string.byte("S"), toggle = true, value = true})
    DrMundo.Harass:MenuElement({id = "AQ", name = "Auto Q", value = true})
    DrMundo.Harass:MenuElement({id = "Q", name = "Q", value = true})
    DrMundo.Harass:MenuElement({id = "W", name = "W", value = true})
    DrMundo.Harass:MenuElement({id = "E", name = "E", value = true})
    DrMundo:MenuElement({type = MENU, id = "Clear", name = "Clear"})
    DrMundo.Clear:MenuElement({id = "T", name = "Toggle Spells", key = string.byte("A"), toggle = true, value = true})
    DrMundo.Clear:MenuElement({id = "Q", name = "Q", value = true})
    DrMundo.Clear:MenuElement({id = "W", name = "W", value = true})
    DrMundo.Clear:MenuElement({id = "E", name = "E", value = true})
    DrMundo:MenuElement({type = MENU, id = "Lasthit", name = "Lasthit"})
    DrMundo.Lasthit:MenuElement({id = "T", name = "Toggle Spells", key = string.byte("A"), toggle = true, value = true})
    DrMundo.Lasthit:MenuElement({id = "Q", name = "Q", value = true})
    DrMundo:MenuElement({type = MENU, id = "Flee", name = "Flee"})
    DrMundo.Flee:MenuElement({id = "Q", name = "Q", value = true})
    DrMundo:MenuElement({type = MENU, id = "Lifesaver", name = "Life Saver"})
    DrMundo.Lifesaver:MenuElement({id = "R", name = "R", value = true})
    DrMundo.Lifesaver:MenuElement({id = "HP", name = "Hp threshold", value = 15, min = -1, max = 101})
	DrMundo:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    DrMundo.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    DrMundo.Draw:MenuElement({id = "W", name = "W range", value = true})
    DrMundo.Draw:MenuElement({id = "Harass", name = "Harass Status", type = MENU})
    DrMundo.Draw.Harass:MenuElement({id = "Text", name = "Text Enabled", value = true})
    DrMundo.Draw.Harass:MenuElement({id = "Size", name = "Text Size", value = 10, min = 1, max = 100})
    DrMundo.Draw.Harass:MenuElement({id = "xPos", name = "Text X Position", value = -50, min = -1000, max = 1000, step = 10})
    DrMundo.Draw.Harass:MenuElement({id = "yPos", name = "Text Y Position", value = -140, min = -1000, max = 1000, step = 10})
    DrMundo.Draw:MenuElement({id = "Clear", name = "Clear Status", type = MENU})
    DrMundo.Draw.Clear:MenuElement({id = "Text", name = "Text Enabled", value = true})
    DrMundo.Draw.Clear:MenuElement({id = "Size", name = "Text Size", value = 10, min = 1, max = 100})
    DrMundo.Draw.Clear:MenuElement({id = "xPos", name = "Text X Position", value = -50, min = -1000, max = 1000, step = 10})
    DrMundo.Draw.Clear:MenuElement({id = "yPos", name = "Text Y Position", value = -130, min = -1000, max = 1000, step = 10})
    DrMundo.Draw:MenuElement({id = "Lasthit", name = "Lasthit Status", type = MENU})
    DrMundo.Draw.Lasthit:MenuElement({id = "Text", name = "Text Enabled", value = true})
    DrMundo.Draw.Lasthit:MenuElement({id = "Size", name = "Text Size", value = 10, min = 1, max = 100})
    DrMundo.Draw.Lasthit:MenuElement({id = "xPos", name = "Text X Position", value = -50, min = -1000, max = 1000, step = 10})
    DrMundo.Draw.Lasthit:MenuElement({id = "yPos", name = "Text Y Position", value = -120, min = -1000, max = 1000, step = 10})
end

function DrMundo:Tick()
    if Hp() < DrMundo.Lifesaver.HP:Value() and DrMundo.Lifesaver.R:Value() then
        self:CastR()
    end
    if DrMundo.Harass.T:Value() then
        local Qtarget = GetTarget(Q.Range)
        if Qtarget and DrMundo.Harass.AQ:Value() then
            self:CastQ(Qtarget)
        end
    end
    local mode = GetMode()
    if mode == "Combo" then
        local Qtarget = GetTarget(Q.Range)
        if Qtarget and DrMundo.Combo.Q:Value() then
            self:CastQ(Qtarget)
        end
        local Wtarget = GetTarget(W.Range) 
        if Wtarget and DrMundo.Combo.W:Value() then
            self:CastW()
        end
        local Etarget = GetTarget(E.Range) 
        if Etarget and DrMundo.Combo.E:Value() then
            self:CastE()
        end
    end
    if mode == "Harass" and DrMundo.Harass.T:Value() then
        local Qtarget = GetTarget(Q.Range)
        if Qtarget and DrMundo.Harass.Q:Value() then
            self:CastQ(Qtarget)
        end
        local Wtarget = GetTarget(W.Range) 
        if Wtarget and DrMundo.Harass.W:Value() then
            self:CastW()
        end
        local Etarget = GetTarget(E.Range) 
        if Etarget and DrMundo.Harass.E:Value() then
            self:CastE()
        end
    end
    if mode == "Clear" and DrMundo.Clear.T:Value() then
        local Qtarget = GetClearMinion(Q.Range)
        if Qtarget and DrMundo.Clear.Q:Value() then
            self:CastQMinion(Qtarget)
        end
        local Wtarget = GetClearMinion(W.Range)
        if Wtarget and DrMundo.Clear.W:Value() then
            self:CastW()
        end
        local Etarget = GetClearMinion(E.Range)
        if Etarget and DrMundo.Clear.E:Value() then
            self:CastE()
        end
    end
    if (mode == "Lasthit" or mode == "LastHit") and DrMundo.Lasthit.T:Value() then
        local Qtarget = self:GetQMinion()
        if Qtarget and DrMundo.Lasthit.Q:Value() and GetDistance(Qtarget.pos) > 400 then
            self:CastQMinion(Qtarget)
        end
    end
    if mode == "Flee" then
        local Qtarget = ClosestHero(Q.Range,foe)
        if Qtarget and DrMundo.Flee.Q:Value() then
            self:CastQ(Qtarget)
        end
    end
end

function DrMundo:CastQ(target)
	if Ready(_Q) then
        if target and HPred:CanTarget(target) then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, true, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        end
    end
end

function DrMundo:CastQMinion(target)
	if Ready(_Q) then
        if target then
            local pred = target:GetPrediction(Q.Speed, Q.Delay)
            if target:GetCollision(Q.Width, Q.Speed, Q.Delay) <= 1 then
                Control.CastSpell(HK_Q, pred)
            end
        end
    end
end

function DrMundo:CastW()
	if Ready(_W) and myHero:GetSpellData(_W).toggleState ~= 2 then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function DrMundo:CastE()
	if Ready(_E) then
        EnableOrb(false)
        Control.CastSpell(HK_E)
        EnableOrb(true)
    end
end

function DrMundo:CastR()
	if Ready(_R) then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function DrMundo:GetQMinion()
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        local Qdamage = 30 + 50 * myHero:GetSpellData(_Q).level
        if GetDistance(minion.pos) < Q.Range and not minion.dead and minion.team == foe and Qdamage > minion.health then
            return minion
        end
    end
end

function DrMundo:Draw()
    local target = GetTarget(2000)
    if DrMundo.dead then return end
    if DrMundo.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if DrMundo.Draw.W:Value() and Ready(_W) then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    local textPos = myHero.pos:To2D()
    if DrMundo.Draw.Harass.Text:Value() then
        local size = DrMundo.Draw.Harass.Size:Value()
	    local xPos = DrMundo.Draw.Harass.xPos:Value()
	    local yPos = DrMundo.Draw.Harass.yPos:Value()
        if DrMundo.Harass.T:Value() then
		    Draw.Text("HARASS ON", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 000, 255, 000))
	    else
            Draw.Text("HARASS OFF", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 255, 000, 000))
        end
    end
    if DrMundo.Draw.Clear.Text:Value() then
        local size = DrMundo.Draw.Clear.Size:Value()
	    local xPos = DrMundo.Draw.Clear.xPos:Value()
	    local yPos = DrMundo.Draw.Clear.yPos:Value()
        if DrMundo.Clear.T:Value() then
		    Draw.Text("CLEAR ON", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 000, 255, 000))
	    else
            Draw.Text("CLEAR OFF", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 255, 000, 000))
        end
    end
    if DrMundo.Draw.Lasthit.Text:Value() then
        local size = DrMundo.Draw.Lasthit.Size:Value()
	    local xPos = DrMundo.Draw.Lasthit.xPos:Value()
	    local yPos = DrMundo.Draw.Lasthit.yPos:Value()
        if DrMundo.Lasthit.T:Value() then
		    Draw.Text("LASTHIT ON", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 000, 255, 000))
	    else
            Draw.Text("LASTHIT OFF", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 255, 000, 000))
        end
	end
end

class "Jayce"

function Jayce:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Jayce:LoadSpells()
    Q = { Range = 1050, Delay = 0.25, Width = 75, Speed = 1450}
    W = { Range = myHero.range}
    E = { Range = 650}
    EQ = { Range = 1470, Delay = 0.25, Width = 105, Speed = 1890}
    Q2 = { Range = 600}
    W2 = { Range = 285}
    E2 = { Range = 240}
    R = { Range = 0}
end

function Jayce:LoadMenu()
	Jayce = MenuElement({type = MENU, id = "Jayce", name = "Rugal Vaper "..myHero.charName})
    Jayce:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    Jayce.Combo:MenuElement({id = "Q", name = "Q", value = true})
    Jayce.Combo:MenuElement({id = "W", name = "W", value = true})
    Jayce.Combo:MenuElement({id = "EQ", name = "EQ", value = true})
    Jayce.Combo:MenuElement({id = "Q2", name = "Melee Q", value = true})
    Jayce.Combo:MenuElement({id = "W2", name = "Melee W", value = true})
    Jayce.Combo:MenuElement({id = "E2", name = "Melee E", value = true})
    Jayce:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    Jayce.Harass:MenuElement({id = "T", name = "Toggle Spells", key = string.byte("S"), toggle = true, value = true})
    Jayce.Harass:MenuElement({id = "AQ", name = "Auto Q", value = true})
    Jayce.Harass:MenuElement({id = "AEQ", name = "Auto EQ", value = true})
    Jayce.Harass:MenuElement({id = "Q", name = "Q", value = true})
    Jayce.Harass:MenuElement({id = "W", name = "W", value = true})
    Jayce.Harass:MenuElement({id = "EQ", name = "EQ", value = true})
    Jayce.Harass:MenuElement({id = "Q2", name = "Melee Q", value = true})
    Jayce.Harass:MenuElement({id = "W2", name = "Melee W", value = true})
    Jayce.Harass:MenuElement({id = "E2", name = "Melee E", value = true})
    Jayce:MenuElement({type = MENU, id = "Clear", name = "Clear"})
    Jayce.Clear:MenuElement({id = "T", name = "Toggle Spells", key = string.byte("A"), toggle = true, value = true})
    Jayce.Clear:MenuElement({id = "Q", name = "Q", value = true})
    Jayce.Clear:MenuElement({id = "W", name = "W", value = true})
    Jayce.Clear:MenuElement({id = "EQ", name = "EQ", value = true})
    Jayce.Clear:MenuElement({id = "Q2", name = "Melee Q", value = true})
    Jayce.Clear:MenuElement({id = "W2", name = "Melee W", value = true})
    Jayce.Clear:MenuElement({id = "E2", name = "Melee E", value = true})
    Jayce:MenuElement({type = MENU, id = "Flee", name = "Flee"})
    Jayce.Flee:MenuElement({id = "E", name = "E", value = true})
    Jayce.Flee:MenuElement({id = "E2", name = "Melee E", value = true})
	Jayce:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Jayce.Draw:MenuElement({id = "Q", name = "Q range", value = true})
    Jayce.Draw:MenuElement({id = "W", name = "W range", value = true})
    Jayce.Draw:MenuElement({id = "E", name = "E range", value = true})
    Jayce.Draw:MenuElement({id = "Harass", name = "Harass Status", type = MENU})
    Jayce.Draw.Harass:MenuElement({id = "Text", name = "Text Enabled", value = true})
    Jayce.Draw.Harass:MenuElement({id = "Size", name = "Text Size", value = 10, min = 1, max = 100})
    Jayce.Draw.Harass:MenuElement({id = "xPos", name = "Text X Position", value = -50, min = -1000, max = 1000, step = 10})
    Jayce.Draw.Harass:MenuElement({id = "yPos", name = "Text Y Position", value = -140, min = -1000, max = 1000, step = 10})
    Jayce.Draw:MenuElement({id = "Clear", name = "Clear Status", type = MENU})
    Jayce.Draw.Clear:MenuElement({id = "Text", name = "Text Enabled", value = true})
    Jayce.Draw.Clear:MenuElement({id = "Size", name = "Text Size", value = 10, min = 1, max = 100})
    Jayce.Draw.Clear:MenuElement({id = "xPos", name = "Text X Position", value = -50, min = -1000, max = 1000, step = 10})
    Jayce.Draw.Clear:MenuElement({id = "yPos", name = "Text Y Position", value = -130, min = -1000, max = 1000, step = 10})
end

function Jayce:Tick()
    local form = self:CurrentForm()
    if Jayce.Harass.T:Value() then
        if form == "Ranged" then
            local EQtarget = GetTarget(EQ.Range)
            if EQtarget and Jayce.Harass.AEQ:Value() and Ready(_Q) then
                local Evector = 
                self:CastE(EQtarget)
                self:CastEQ(EQtarget)
            end
            local Qtarget = GetTarget(Q.Range)
            if Qtarget and Jayce.Harass.AQ:Value() then
                self:CastQ(Qtarget)
            end
        end
    end
    local mode = GetMode()
    if mode == "Combo" then
        if form == "Ranged" then
            local EQtarget = GetTarget(EQ.Range)
            if EQtarget and Jayce.Combo.EQ:Value() and Ready(_Q) then
                self:CastE(EQtarget)
                self:CastEQ(EQtarget)
            end
            local Qtarget = GetTarget(Q.Range)
            if Qtarget and Jayce.Combo.Q:Value() then
                self:CastQ(Qtarget)
            end
            local Wtarget = GetTarget(W.Range) 
            if Wtarget and Jayce.Combo.W:Value() then
                self:CastW()
            end
        else
            local Wtarget = GetTarget(W2.Range) 
            if Wtarget and Jayce.Combo.W2:Value() then
                self:CastW()
            end
            local Etarget = GetTarget(E2.Range)
            if Etarget and Jayce.Combo.E2:Value() then
                self:CastE2(Etarget)
            end
            local Qtarget = GetTarget(Q2.Range)
            if Qtarget and Jayce.Combo.Q2:Value() then
                self:CastQ2(Qtarget)
            end
        end
    end
    if mode == "Harass" and Jayce.Harass.T:Value() then
        if form == "Ranged" then
            local EQtarget = GetTarget(EQ.Range)
            if EQtarget and Jayce.Harass.EQ:Value() and Ready(_Q) then
                self:CastE(EQtarget)
                self:CastEQ(EQtarget)
            end
            local Qtarget = GetTarget(Q.Range)
            if Qtarget and Jayce.Harass.Q:Value() then
                self:CastQ(Qtarget)
            end
            local Wtarget = GetTarget(W.Range) 
            if Wtarget and Jayce.Harass.W:Value() then
                self:CastW()
            end
        else
            local Wtarget = GetTarget(W2.Range) 
            if Wtarget and Jayce.Harass.W2:Value() then
                self:CastW()
            end
            local Etarget = GetTarget(E2.Range)
            if Etarget and Jayce.Harass.E2:Value() then
                self:CastE2(Etarget)
            end
            local Qtarget = GetTarget(Q2.Range)
            if Qtarget and Jayce.Harass.Q2:Value() then
                self:CastQ2(Qtarget)
            end
        end
    end
    if mode == "Clear" and Jayce.Clear.T:Value() then
        if form == "Ranged" then
            local EQtarget = GetClearMinion(EQ.Range)
            if EQtarget and Jayce.Clear.EQ:Value() and Ready(_Q) then
                self:CastE(EQtarget)
                self:CastEQ(EQtarget)
            end
            local Qtarget = GetClearMinion(Q.Range)
            if Qtarget and Jayce.Clear.Q:Value() then
                self:CastQ(Qtarget)
            end
            local Wtarget = GetClearMinion(W.Range) 
            if Wtarget and Jayce.Clear.W:Value() then
                self:CastW()
            end
        else
            local Wtarget = GetClearMinion(W2.Range) 
            if Wtarget and Jayce.Clear.W2:Value() then
                self:CastW()
            end
            local Etarget = GetClearMinion(E2.Range)
            if Etarget and Jayce.Clear.E2:Value() then
                self:CastE2(Etarget)
            end
            local Qtarget = GetClearMinion(Q2.Range)
            if Qtarget and Jayce.Clear.Q2:Value() then
                self:CastQ2(Qtarget)
            end
        end
    end
    if mode == "Flee" then
        if form == "Ranged" then
            local vec = myHero.pos:Extended(mousePos, 200)
            if Jayce.Flee.E:Value() then
                self:CastE(vec)
            end
        else
            local Etarget = ClosestHero(E2.Range,foe)
            if Etarget and Jayce.Flee.E2:Value() then
                self:CastE2(Etarget)
            end
        end
    end
end

function Jayce:CurrentForm()
    if myHero.range >= 350 then
        return "Ranged"
    else
        return "Melee"
    end
end

function Jayce:CastQ(target)
	if Ready(_Q) then
        if target and HPred:CanTarget(target) then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.Range, Q.Delay, Q.Speed, Q.Width, true, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        end
    end
end

function Jayce:CastEQ(target)
	if Ready(_Q) and Ready(_E) then
        if target and HPred:CanTarget(target) then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target, EQ.Range, EQ.Delay, EQ.Speed, EQ.Width, true, nil)
            if hitChance and hitChance >= 1 and HPred:GetDistance(myHero.pos, aimPosition) <= EQ.Range then
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        end
    end
end

function Jayce:CastQ2(target)
	if Ready(_Q) then
        EnableOrb(false)
        Control.CastSpell(HK_Q,target)
        EnableOrb(true)
    end
end

function Jayce:CastW()
	if Ready(_W) then
        EnableOrb(false)
        Control.CastSpell(HK_W)
        EnableOrb(true)
    end
end

function Jayce:CastE(pos)
	if Ready(_E) then
        EnableOrb(false)
        Control.CastSpell(HK_E,pos)
        EnableOrb(true)
    end
end

function Jayce:CastE2(target)
	if Ready(_E) then
        EnableOrb(false)
        Control.CastSpell(HK_E,target)
        EnableOrb(true)
    end
end

function Jayce:CastR()
	if Ready(_R) then
        EnableOrb(false)
        Control.CastSpell(HK_R)
        EnableOrb(true)
    end
end

function Jayce:Draw()
    local target = GetTarget(2000)
    if Jayce.dead then return end
    local form = self:CurrentForm()
    if form == "Ranged" then
        if Jayce.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
        if Jayce.Draw.W:Value() and Ready(_W) then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
        if Jayce.Draw.E:Value() and Ready(_E) then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    else
        if Jayce.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, Q2.Range, 3,  Draw.Color(255, 000, 000, 255)) end
        if Jayce.Draw.W:Value() and Ready(_W) then Draw.Circle(myHero.pos, W2.Range, 3,  Draw.Color(255, 000, 255, 000)) end
        if Jayce.Draw.E:Value() and Ready(_E) then Draw.Circle(myHero.pos, E2.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    end
    local textPos = myHero.pos:To2D()
    if Jayce.Draw.Harass.Text:Value() then
        local size = Jayce.Draw.Harass.Size:Value()
	    local xPos = Jayce.Draw.Harass.xPos:Value()
	    local yPos = Jayce.Draw.Harass.yPos:Value()
        if Jayce.Harass.T:Value() then
		    Draw.Text("HARASS ON", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 000, 255, 000))
	    else
            Draw.Text("HARASS OFF", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 255, 000, 000))
        end
    end
    if Jayce.Draw.Clear.Text:Value() then
        local size = Jayce.Draw.Clear.Size:Value()
	    local xPos = Jayce.Draw.Clear.xPos:Value()
	    local yPos = Jayce.Draw.Clear.yPos:Value()
        if Jayce.Clear.T:Value() then
		    Draw.Text("CLEAR ON", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 000, 255, 000))
	    else
            Draw.Text("CLEAR OFF", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 255, 000, 000))
        end
    end
end

local loaded = false
Callback.Add("Load", function()
    if _G[myHero.charName] and loaded == false then
        _G[myHero.charName]()
        loaded = true
    end
end)

-- HPred
class "HPred"  Callback.Add("Tick", function() HPred:Tick() end)  local _reviveQueryFrequency = 3 local _lastReviveQuery = Game.Timer() local _reviveLookupTable = { ["LifeAura.troy"] = 4, ["ZileanBase_R_Buf.troy"] = 3, ["Aatrox_Base_Passive_Death_Activate"] = 3 }  local _blinkSpellLookupTable = { ["EzrealArcaneShift"] = 475, ["RiftWalk"] = 500, ["EkkoEAttack"] = 0, ["AlphaStrike"] = 0, ["KatarinaE"] = -255, ["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, }  local _blinkLookupTable = { "global_ss_flash_02.troy", "Lissandra_Base_E_Arrival.troy", "LeBlanc_Base_W_return_activation.troy" }  local _cachedRevives = {}  local _movementHistory = {}  function HPred:Tick() if Game.Timer() - _lastReviveQuery < _reviveQueryFrequency then return end  _lastReviveQuery=Game.Timer() for _, revive in pairs(_cachedRevives) do if Game.Timer() > revive.expireTime + .5 then _cachedRevives[_] = nil end end  for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then _cachedRevives[particle.networkID] = {} _cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name] local nearestDistance = 500 for i = 1, Game.HeroCount() do local t = Game.Hero(i) local tDistance = self:GetDistance(particle.pos, t.pos) if tDistance < nearestDistance then nearestDistance = nearestDistance _cachedRevives[particle.networkID]["owner"] = t.charName _cachedRevives[particle.networkID]["pos"] = t.pos _cachedRevives[particle.networkID]["isEnemy"] = t.isEnemy end end end end end  function HPred:GetEnemyNexusPosition() if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end end   function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision) local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash) if target and aimPosition then return target, aimPosition end  target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius) if target and aimPosition then return target, aimPosition end end  function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies) local targetCount = 0 for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed) if predictedPos:To2D().onScreen then local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos) if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) ^ 2) then targetCount = targetCount + 1 end end end end return targetCount end  function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist) local _validTargets = {} for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTarget(t) and (not whitelist or whitelist[t.charName]) then local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision) if hitChance >= minimumHitChance and aimPosition:To2D().onScreen then _validTargets[t.charName] = {["hitChance"] = hitChance, ["aimPosition"] = aimPosition} end end end  local rHitChance = 0 local rAimPosition for targetName, targetData in pairs(_validTargets) do if targetData.hitChance > rHitChance then rHitChance = targetData.hitChance rAimPosition = targetData.aimPosition end end  if rHitChance >= minimumHitChance then return rHitChance, rAimPosition end end  function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision) self:UpdateMovementHistory(target)  local hitChance = 1  local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed) local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed) local reactionTime = self:PredictReactionTime(target, .1) local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)  if _movementHistory and _movementHistory[target.charName] and Game.Timer() - _movementHistory[target.charName]["ChangedAt"] < .25 then hitChance = 2 end  if not target.pathing or not target.pathing.hasMovePath then hitChance = 2 end  if movementRadius - target.boundingRadius <= radius /2 then hitChance = 3 end  if target.activeSpell and target.activeSpell.valid then if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then hitChance = 4 else hitChance = 3 end end  if self:GetDistance(myHero.pos, aimPosition) >= range then hitChance = -1 end  if hitChance > 0 and checkCollision then if self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then hitChance = -1 end end  return hitChance, aimPosition end  function HPred:PredictReactionTime(unit, minimumReactionTime) local reactionTime = minimumReactionTime  if unit.activeSpell and unit.activeSpell.valid then local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer() if windupRemaining > 0 then reactionTime = windupRemaining end end  local isRecalling, recallDuration = self:GetRecallingData(unit) if isRecalling and recallDuration > .25 then reactionTime = .25 end  return reactionTime end  function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)  local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then local dashEndPosition = t:GetPath(1) if self:GetDistance(source, dashEndPosition) <= range  and dashEndPosition:To2D().onScreen then local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed) local deltaInterceptTime =skillInterceptTime - dashTimeRemaining if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then target = t aimPosition = dashEndPosition return target, aimPosition end end end end end  function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.pos:To2D().onScreen then local success, timeRemaining = self:HasBuff(t, "zhonyasringshield") if success then local spellInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) local deltaInterceptTime = spellInterceptTime - timeRemaining if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end end end  function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for _, revive in pairs(_cachedRevives) do if revive.isEnemy and revive.pos:To2D().onScreen then local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed) if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then target = self:GetEnemyByName(revive.owner) aimPosition = revive.pos return target, aimPosition end end end end  function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer() if windupRemaining > 0 then local endPos local blinkRange = _blinkSpellLookupTable[t.activeSpell.name] if type(blinkRange) == "table" then local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange) if target and distance < 250 then endPos = target.pos end elseif blinkRange > 0 then endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z) endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * math.min(self:GetDistance(t.activeSpell.startPos,endPos), range) else local blinkTarget = self:GetObjectByHandle(t.activeSpell.target) if blinkTarget then local offsetDirection  if blinkRange == 0 then offsetDirection = (blinkTarget.pos - t.pos):Normalized() elseif blinkRange == -1 then offsetDirection = (t.pos-blinkTarget.pos):Normalized() elseif blinkRange == -255 then if radius > 250 then endPos = blinkTarget.pos end end  if offsetDirection then endPos = blinkTarget.pos - offsetDirection * 150 end  end end  local interceptTime = self:GetSpellInterceptTime(myHero.pos, endPos, delay,speed) local deltaInterceptTime = interceptTime - windupRemaining if self:GetDistance(source, endPos) <= range and endPos:To2D().onScreen and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then target = t aimPosition = endPos return target,aimPosition end end end end end  function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius) local target local aimPosition for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if particle and _blinkLookupTable[particle.name] and self:GetDistance(source, particle.pos) < range and particle.pos:To2D().onScreen then local pPos = particle.pos for k,v in pairs(self:GetEnemyHeroes()) do local t = v if t and t.isEnemy and self:GetDistance(t.pos, pPos) < t.boundingRadius then if (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then target = t aimPosition = pPos return target,aimPosition end end end end end end  function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) local interceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end  function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.HeroCount() do local t = Game.Hero(i) if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen then local immobileTime = self:GetImmobileTime(t)  local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed) if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then target = t aimPosition = t.pos return target, aimPosition end end end end  function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius) local target local aimPosition for i = 1, Game.TurretCount() do local turret = Game.Turret(i); if turret.isEnemy and self:GetDistance(source, turret.pos) <= range and turret.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(turret.pos,223.31) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = turret aimPosition =interceptPosition return target, aimPosition end end end end  for i = 1, Game.WardCount() do local ward = Game.Ward(i); if ward.isEnemy and self:GetDistance(source, ward.pos) <= range and ward.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(ward.pos,100.01) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = ward aimPosition = interceptPosition return target, aimPosition end end end end  for i = 1, Game.MinionCount() do local minion = Game.Minion(i); if minion.isEnemy and self:GetDistance(source, minion.pos) <= range and minion.pos:To2D().onScreen then local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target") if hasBuff then local interceptPosition = self:GetTeleportOffset(minion.pos,143.25) local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then target = minion aimPosition = interceptPosition return target, aimPosition end end end end end  function HPred:GetTargetMS(target) local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms return ms end  function HPred:Angle(A, B) local deltaPos = A - B local angle = math.atan2(deltaPos.x, deltaPos.z) *  180 / math.pi if angle < 0 then angle = angle + 360 end return angle end  function HPred:UpdateMovementHistory(unit) if not _movementHistory[unit.charName] then _movementHistory[unit.charName] = {} _movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos _movementHistory[unit.charName]["StartPos"] = unit.pathing.endPos _movementHistory[unit.charName]["PreviousAngle"] = 0 _movementHistory[unit.charName]["ChangedAt"] = Game.Timer() end  if _movementHistory[unit.charName]["EndPos"].x ~=unit.pathing.endPos.x or _movementHistory[unit.charName]["EndPos"].y ~=unit.pathing.endPos.y or _movementHistory[unit.charName]["EndPos"].z ~=unit.pathing.endPos.z then _movementHistory[unit.charName]["PreviousAngle"] = self:Angle(Vector(_movementHistory[unit.charName]["StartPos"].x, _movementHistory[unit.charName]["StartPos"].y, _movementHistory[unit.charName]["StartPos"].z), Vector(_movementHistory[unit.charName]["EndPos"].x, _movementHistory[unit.charName]["EndPos"].y, _movementHistory[unit.charName]["EndPos"].z)) _movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos _movementHistory[unit.charName]["StartPos"] = unit.pos _movementHistory[unit.charName]["ChangedAt"] = Game.Timer() end  end  function HPred:PredictUnitPosition(unit, delay) local predictedPosition = unit.pos local timeRemaining = delay local pathNodes = self:GetPathNodes(unit) for i = 1, #pathNodes -1 do local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1]) local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)  if timeRemaining > nodeTraversalTime then timeRemaining =  timeRemaining - nodeTraversalTime predictedPosition = pathNodes[i + 1] else local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized() predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining break; end end return predictedPosition end  function HPred:IsChannelling(target, interceptTime) if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then return true end end  function HPred:HasBuff(target, buffName, minimumDuration) local duration = minimumDuration if not minimumDuration then duration = 0 end local durationRemaining for i = 1, target.buffCount do local buff = target:GetBuff(i) if buff.duration > duration and buff.name == buffName then durationRemaining = buff.duration return true, durationRemaining end end end  function HPred:GetTeleportOffset(origin, magnitude) local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude return teleportOffset end  function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed) local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed return interceptTime end  function HPred:CanTarget(target) return target.isEnemy and target.alive and target.visible and target.isTargetable end  function HPred:CanTargetALL(target) return target.alive and target.visible and target.isTargetable end  function HPred:UnitMovementBounds(unit, delay, reactionTime) local startPosition = self:PredictUnitPosition(unit, delay)  local radius = 0 local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit) if (deltaDelay >0) then radius = self:GetTargetMS(unit) * deltaDelay end return startPosition, radius end  function HPred:GetImmobileTime(unit) local duration = 0 for i = 0, unit.buffCount do local buff = unit:GetBuff(i); if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then duration = buff.duration end end return duration end  function HPred:GetSlowedTime(unit) local duration = 0 for i = 0, unit.buffCount do local buff = unit:GetBuff(i); if buff.count > 0 and buff.duration > duration and buff.type == 10 then duration = buff.duration return duration end end return duration end  function HPred:GetPathNodes(unit) local nodes = {} table.insert(nodes, unit.pos) if unit.pathing.hasMovePath then for i = unit.pathing.pathIndex, unit.pathing.pathCount do path = unit:GetPath(i) table.insert(nodes, path) end end return nodes end  function HPred:GetObjectByHandle(handle) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.handle == handle then target = enemy return target end end  for i = 1, Game.MinionCount() do local minion = Game.Minion(i) if minion.handle == handle then target = minion return target end end  for i = 1, Game.WardCount() do local ward = Game.Ward(i); if ward.handle == handle then target = ward return target end end  for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) if particle.handle == handle then target = particle return target end end end function HPred:GetObjectByPosition(position) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.MinionCount() do local enemy = Game.Minion(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.WardCount() do local enemy = Game.Ward(i); if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end  for i = 1, Game.ParticleCount() do local enemy = Game.Particle(i) if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then target = enemy return target end end end  function HPred:GetEnemyHeroByHandle(handle) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.handle == handle then target = enemy return target end end end  function HPred:GetNearestParticleByNames(origin, names) local target local distance = math.max for i = 1, Game.ParticleCount() do local particle = Game.Particle(i) local d = self:GetDistance(origin, particle.pos) if d < distance then distance = d target = particle end end return target, distance end  function HPred:GetPathLength(nodes) local result = 0 for i = 1, #nodes -1 do result = result + self:GetDistance(nodes[i], nodes[i + 1]) end return result end  function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)  if not frequency then frequency = radius end local directionVector = (endPos - origin):Normalized() local checkCount = self:GetDistance(origin, endPos) / frequency for i = 1, checkCount do local checkPosition = origin + directionVector * i * frequency local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then return true end end return false end  function HPred:IsMinionIntersection(location, radius, delay, maxDistance) if not maxDistance then maxDistance = 500 end for i = 1, Game.MinionCount() do local minion = Game.Minion(i) if self:CanTarget(minion) and self:GetDistance(minion.pos, location) < maxDistance then local predictedPosition = self:PredictUnitPosition(minion, delay) if self:GetDistance(location, predictedPosition) <= radius + minion.boundingRadius then return true end end end return false end  function HPred:VectorPointProjectionOnLineSegment(v1, v2, v) assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)") local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y) local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2) local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) } local rS = rL < 0 and 0 or (rL > 1 and 1 or rL) local isOnSegment = rS == rL local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) } return pointSegment, pointLine, isOnSegment end   function HPred:GetRecallingData(unit) for K, Buff in pairs(GetBuffs(unit)) do if Buff.name == "recall" and Buff.duration > 0 then return true, Game.Timer() - Buff.startTime end end return false end  function HPred:GetEnemyByName(name) local target for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy.isEnemy and enemy.charName == name then target = enemy return target end end end  function HPred:IsPointInArc(source, origin, target, angle, range) local deltaAngle = math.abs(HPred:Angle(origin, target) - HPred:Angle(source, origin)) if deltaAngle < angle and self:GetDistance(origin, target) < range then return true end end  function HPred:GetEnemyHeroes() local _EnemyHeroes = {} for i = 1, Game.HeroCount() do local enemy = Game.Hero(i) if enemy and enemy.isEnemy then table.insert(_EnemyHeroes, enemy) end end return _EnemyHeroes end  function HPred:GetDistanceSqr(p1, p2) return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2 end  function HPred:GetDistance(p1, p2) return math.sqrt(self:GetDistanceSqr(p1, p2)) end
