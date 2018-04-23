local neutral = 300
local friend = myHero.team
local foe = neutral - friend

local mathhuge = math.huge
local mathsqrt = math.sqrt
local mathpow = math.pow
local mathmax = math.max
local mathfloor = math.floor

local HKITEM = {[ITEM_1] = HK_ITEM_1,[ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3,[ITEM_4] = HK_ITEM_4,[ITEM_5] = HK_ITEM_5,[ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7}
local HKSPELL = {[SUMMONER_1] = HK_SUMMONER_1,[SUMMONER_2] = HK_SUMMONER_2,}

local function Ready(slot)
	return myHero:GetSpellData(slot).currentCd == 0 and myHero:GetSpellData(slot).level ~= 0 and myHero.mana >= myHero:GetSpellData(slot).mana and Game.CanUseSpell(slot) == 0
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
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then 
            return "Clear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
            return "LastHit"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    elseif _G.gsoSDK then
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

local function Mp(source)
    local source = source or myHero
    return source.mana/source.maxMana * 100
end

local function ClosestInjuredHero(range,team,life,includeMe)
    local includeMe = includeMe or true
    local life = life or 101
    local bestHero = nil
    local closest = math.huge
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if GetDistance(hero.pos) < range and hero.team == team and not hero.dead and Hp(hero) < life then
            if includeMe == false and hero.isMe then return end
            local Distance = GetDistance(hero.pos, mousePos)
            if Distance < closest then
                bestHero = hero
                closest = Distance
            end
        end
    end
    return bestHero
end

local function HeroesAround(range, pos, team)
    local pos = pos or myHero.pos
    local team = team or foe
    local Count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.team == team and not hero.dead and GetDistance(pos, hero.pos) < range then
			Count = Count + 1
		end
	end
	return Count
end

local function BuffByType(wich,time)
	for i = 0, myHero.buffCount do 
	local buff = myHero:GetBuff(i)
		if buff.type == wich and buff.duration > time then 
			return true
		end
	end
	return false
end

local function ExistSpell(spellname)
    if myHero:GetSpellData(SUMMONER_1).name == spellname or myHero:GetSpellData(SUMMONER_2).name == spellname then
        return true
    end
    return false
end

local function SummonerSlot(spellname)
    if myHero:GetSpellData(SUMMONER_1).name == spellname then
        return SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name == spellname then
        return SUMMONER_2
    end
end

class "Helper"

function Helper:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Helper:LoadSpells()
    Q = { Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Width = myHero:GetSpellData(_Q).width, Speed = myHero:GetSpellData(_Q).speed}
    W = { Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_W).delay, Width = myHero:GetSpellData(_W).width, Speed = myHero:GetSpellData(_W).speed}
    E = { Range = myHero:GetSpellData(_E).range, Delay = myHero:GetSpellData(_E).delay, Width = myHero:GetSpellData(_E).width, Speed = myHero:GetSpellData(_E).speed}
    R = { Range = myHero:GetSpellData(_R).range, Delay = myHero:GetSpellData(_R).delay, Width = myHero:GetSpellData(_R).width, Speed = myHero:GetSpellData(_R).speed}
end

function Helper:LoadMenu()
    Helper = MenuElement({type = MENU, id = "Helper", name = "Rugal Helper"})
    
    for k = 1, Game.HeroCount() do
        local hero = Game.Hero(k)
        local heroName = hero.charName
        if hero.isMe then
    Helper:MenuElement({id = heroName, name = "Helper " ..heroName, type = MENU})
    
    Helper[heroName]:MenuElement({value = true, id = "Enable", name = "Enable"})

    Helper[heroName]:MenuElement({type = MENU, id = "Combo", name = "Combo"})

    Helper[heroName].Combo:MenuElement({id = "Q", name = "Q", type = MENU})
    Helper[heroName].Combo.Q:MenuElement({id = "Enable", name = "Enable Q", value = true})
    Helper[heroName].Combo.Q:MenuElement({id = "Use", name = "Use Q", key = string.byte("Q")})
    Helper[heroName].Combo.Q:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Combo:MenuElement({id = "W", name = "W", type = MENU})
    Helper[heroName].Combo.W:MenuElement({id = "Enable", name = "Enable W", value = true})
    Helper[heroName].Combo.W:MenuElement({id = "Use", name = "Use W", key = string.byte("W")})
    Helper[heroName].Combo.W:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Combo:MenuElement({id = "E", name = "E", type = MENU})
    Helper[heroName].Combo.E:MenuElement({id = "Enable", name = "Enable E", value = true})
    Helper[heroName].Combo.E:MenuElement({id = "Use", name = "Use E", key = string.byte("E")})
    Helper[heroName].Combo.E:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Combo:MenuElement({id = "R", name = "R", type = MENU})
    Helper[heroName].Combo.R:MenuElement({id = "Enable", name = "Enable R", value = true})
    Helper[heroName].Combo.R:MenuElement({id = "Use", name = "Use R", key = string.byte("R")})
    Helper[heroName].Combo.R:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})
    
    Helper[heroName]:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    
    Helper[heroName].Harass:MenuElement({id = "Q", name = "Q", type = MENU})
    Helper[heroName].Harass.Q:MenuElement({id = "Enable", name = "Enable Q", value = true})
    Helper[heroName].Harass.Q:MenuElement({id = "Use", name = "Use Q", key = string.byte("Q")})
    Helper[heroName].Harass.Q:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Harass:MenuElement({id = "W", name = "W", type = MENU})
    Helper[heroName].Harass.W:MenuElement({id = "Enable", name = "Enable W", value = true})
    Helper[heroName].Harass.W:MenuElement({id = "Use", name = "Use W", key = string.byte("W")})
    Helper[heroName].Harass.W:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Harass:MenuElement({id = "E", name = "E", type = MENU})
    Helper[heroName].Harass.E:MenuElement({id = "Enable", name = "Enable E", value = true})
    Helper[heroName].Harass.E:MenuElement({id = "Use", name = "Use E", key = string.byte("E")})
    Helper[heroName].Harass.E:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Harass:MenuElement({id = "R", name = "R", type = MENU})
    Helper[heroName].Harass.R:MenuElement({id = "Enable", name = "Enable R", value = true})
    Helper[heroName].Harass.R:MenuElement({id = "Use", name = "Use R", key = string.byte("R")})
    Helper[heroName].Harass.R:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})
    
    Helper[heroName]:MenuElement({type = MENU, id = "Clear", name = "Clear"})
    
    Helper[heroName].Clear:MenuElement({id = "Q", name = "Q", type = MENU})
    Helper[heroName].Clear.Q:MenuElement({id = "Enable", name = "Enable Q", value = true})
    Helper[heroName].Clear.Q:MenuElement({id = "Use", name = "Use Q", key = string.byte("Q")})
    Helper[heroName].Clear.Q:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Clear:MenuElement({id = "W", name = "W", type = MENU})
    Helper[heroName].Clear.W:MenuElement({id = "Enable", name = "Enable W", value = true})
    Helper[heroName].Clear.W:MenuElement({id = "Use", name = "Use W", key = string.byte("W")})
    Helper[heroName].Clear.W:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Clear:MenuElement({id = "E", name = "E", type = MENU})
    Helper[heroName].Clear.E:MenuElement({id = "Enable", name = "Enable E", value = true})
    Helper[heroName].Clear.E:MenuElement({id = "Use", name = "Use E", key = string.byte("E")})
    Helper[heroName].Clear.E:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Clear:MenuElement({id = "R", name = "R", type = MENU})
    Helper[heroName].Clear.R:MenuElement({id = "Enable", name = "Enable R", value = true})
    Helper[heroName].Clear.R:MenuElement({id = "Use", name = "Use R", key = string.byte("R")})
    Helper[heroName].Clear.R:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})
    
    Helper[heroName]:MenuElement({type = MENU, id = "Flee", name = "Flee"})
    
    Helper[heroName].Flee:MenuElement({id = "Q", name = "Q", type = MENU})
    Helper[heroName].Flee.Q:MenuElement({id = "Enable", name = "Enable Q", value = true})
    Helper[heroName].Flee.Q:MenuElement({id = "Use", name = "Use Q", key = string.byte("Q")})
    Helper[heroName].Flee.Q:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Flee:MenuElement({id = "W", name = "W", type = MENU})
    Helper[heroName].Flee.W:MenuElement({id = "Enable", name = "Enable W", value = true})
    Helper[heroName].Flee.W:MenuElement({id = "Use", name = "Use W", key = string.byte("W")})
    Helper[heroName].Flee.W:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Flee:MenuElement({id = "E", name = "E", type = MENU})
    Helper[heroName].Flee.E:MenuElement({id = "Enable", name = "Enable E", value = true})
    Helper[heroName].Flee.E:MenuElement({id = "Use", name = "Use E", key = string.byte("E")})
    Helper[heroName].Flee.E:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})

    Helper[heroName].Flee:MenuElement({id = "R", name = "R", type = MENU})
    Helper[heroName].Flee.R:MenuElement({id = "Enable", name = "Enable R", value = true})
    Helper[heroName].Flee.R:MenuElement({id = "Use", name = "Use R", key = string.byte("R")})
    Helper[heroName].Flee.R:MenuElement({id = "How", name = "Spell type", drop = {"Skillshot","Point Target","Cursor","No target"}})
    
    Helper[heroName]:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
    Helper[heroName].Draw:MenuElement({id = "Q", name = "Q Range", value = true})
    Helper[heroName].Draw:MenuElement({id = "W", name = "W Range", value = true})
    Helper[heroName].Draw:MenuElement({id = "E", name = "E Range", value = true})
    Helper[heroName].Draw:MenuElement({id = "R", name = "R Range", value = true})
        end
    end
end

function Helper:Tick()
    local mode = GetMode()
    if mode == "Combo" then
        self:Combo()
    end
    if mode == "Harass" then
        self:Harass()
    end
    if mode == "Clear" then
        self:Clear()
    end
    if mode == "Flee" then
        self:Flee()
    end
end

function Helper:Combo()
    -- Q
    if Helper[myHero.charName].Combo.Q.Use:Value() and Helper[myHero.charName].Combo.Q.Enable:Value() then
        local how = Helper[myHero.charName].Combo.Q.How:Value()
        local target = GetTarget(Q.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(Q.Speed, Q.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_Q)
            EnableOrb(true)
        end
    end
    -- W
    if Helper[myHero.charName].Combo.W.Use:Value() and Helper[myHero.charName].Combo.W.Enable:Value() then
        local how = Helper[myHero.charName].Combo.W.How:Value()
        local target = GetTarget(W.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(W.Speed, W.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_W)
            EnableOrb(true)
        end
    end
    -- E
    if Helper[myHero.charName].Combo.E.Use:Value() and Helper[myHero.charName].Combo.E.Enable:Value() then
        local how = Helper[myHero.charName].Combo.E.How:Value()
        local target = GetTarget(E.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(E.Speed, E.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_E)
            EnableOrb(true)
        end
    end
    -- R
    if Helper[myHero.charName].Combo.R.Use:Value() and Helper[myHero.charName].Combo.R.Enable:Value() then
        local how = Helper[myHero.charName].Combo.R.How:Value()
        local target = GetTarget(R.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(R.Speed, R.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_R)
            EnableOrb(true)
        end
    end
end

function Helper:Harass()
    -- Q
    if Helper[myHero.charName].Harass.Q.Use:Value() and Helper[myHero.charName].Harass.Q.Enable:Value() then
        local how = Helper[myHero.charName].Harass.Q.How:Value()
        local target = GetTarget(Q.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(Q.Speed, Q.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_Q)
            EnableOrb(true)
        end
    end
    -- W
    if Helper[myHero.charName].Harass.W.Use:Value() and Helper[myHero.charName].Harass.W.Enable:Value() then
        local how = Helper[myHero.charName].Harass.W.How:Value()
        local target = GetTarget(W.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(W.Speed, W.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_W)
            EnableOrb(true)
        end
    end
    -- E
    if Helper[myHero.charName].Harass.E.Use:Value() and Helper[myHero.charName].Harass.E.Enable:Value() then
        local how = Helper[myHero.charName].Harass.E.How:Value()
        local target = GetTarget(E.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(E.Speed, E.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_E)
            EnableOrb(true)
        end
    end
    -- R
    if Helper[myHero.charName].Harass.R.Use:Value() and Helper[myHero.charName].Harass.R.Enable:Value() then
        local how = Helper[myHero.charName].Harass.R.How:Value()
        local target = GetTarget(R.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(R.Speed, R.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_R)
            EnableOrb(true)
        end
    end
end

function Helper:Clear()
    -- Q
    if Helper[myHero.charName].Clear.Q.Use:Value() and Helper[myHero.charName].Clear.Q.Enable:Value() then
        local how = Helper[myHero.charName].Clear.Q.How:Value()
        local target = GetClearMinion(Q.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(Q.Speed, Q.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_Q)
            EnableOrb(true)
        end
    end
    -- W
    if Helper[myHero.charName].Clear.W.Use:Value() and Helper[myHero.charName].Clear.W.Enable:Value() then
        local how = Helper[myHero.charName].Clear.W.How:Value()
        local target = GetClearMinion(W.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(W.Speed, W.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_W)
            EnableOrb(true)
        end
    end
    -- E
    if Helper[myHero.charName].Clear.E.Use:Value() and Helper[myHero.charName].Clear.E.Enable:Value() then
        local how = Helper[myHero.charName].Clear.E.How:Value()
        local target = GetClearMinion(E.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(E.Speed, E.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_E)
            EnableOrb(true)
        end
    end
    -- R
    if Helper[myHero.charName].Clear.R.Use:Value() and Helper[myHero.charName].Clear.R.Enable:Value() then
        local how = Helper[myHero.charName].Clear.R.How:Value()
        local target = GetClearMinion(R.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(R.Speed, R.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_R)
            EnableOrb(true)
        end
    end
end

function Helper:Flee()
    -- Q
    if Helper[myHero.charName].Flee.Q.Use:Value() and Helper[myHero.charName].Flee.Q.Enable:Value() then
        local how = Helper[myHero.charName].Flee.Q.How:Value()
        local target = GetTarget(Q.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(Q.Speed, Q.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_Q, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_Q, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_Q, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_Q)
            EnableOrb(true)
        end
    end
    -- W
    if Helper[myHero.charName].Flee.W.Use:Value() and Helper[myHero.charName].Flee.W.Enable:Value() then
        local how = Helper[myHero.charName].Flee.W.How:Value()
        local target = GetTarget(W.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(W.Speed, W.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_W, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_W, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_W, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_W)
            EnableOrb(true)
        end
    end
    -- E
    if Helper[myHero.charName].Flee.E.Use:Value() and Helper[myHero.charName].Flee.E.Enable:Value() then
        local how = Helper[myHero.charName].Flee.E.How:Value()
        local target = GetTarget(E.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(E.Speed, E.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_E, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_E, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_E, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_E)
            EnableOrb(true)
        end
    end
    -- R
    if Helper[myHero.charName].Flee.R.Use:Value() and Helper[myHero.charName].Flee.R.Enable:Value() then
        local how = Helper[myHero.charName].Flee.R.How:Value()
        local target = GetTarget(R.Range)
        if how == 1 and target then
            if target then
                local aimPosition = target:GetPrediction(R.Speed, R.Delay)
                EnableOrb(false)
                Control.CastSpell(HK_R, aimPosition)
                EnableOrb(true)
            end
        elseif how == 2 and target then
            EnableOrb(false)
            Control.CastSpell(HK_R, target)
            EnableOrb(true)
        elseif how == 3 then
            EnableOrb(false)
            Control.CastSpell(HK_R, Game.cursorPos())
            EnableOrb(true)
        elseif how == 4 then
            EnableOrb(false)
            Control.CastSpell(HK_R)
            EnableOrb(true)
        end
    end
end

function Helper:Draw()
    if myHero.dead then return end
    if Helper[myHero.charName].Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
    if Helper[myHero.charName].Draw.W:Value() and Ready(_W) then Draw.Circle(myHero.pos, W.Range, 3,  Draw.Color(255, 000, 255, 000)) end
    if Helper[myHero.charName].Draw.E:Value() and Ready(_E) then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
    if Helper[myHero.charName].Draw.R:Value() and Ready(_R) then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
end

local loaded = false
Callback.Add("Load", function()
    if loaded == false then
        Helper()
        loaded = true
    end
end)
