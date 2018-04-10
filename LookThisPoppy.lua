if myHero.charName ~= "Poppy" or not (_G.SDK and _G.SDK.Orbwalker) then return end

require 'DamageLib'
require 'MapPositionGOS'

local function myTarget(Range)
	local Range = Range or math.huge
	local target = nil
	target = _G.SDK.TargetSelector:GetTarget(Range)
	return target
end

local HKITEM = {[ITEM_1] = HK_ITEM_1,[ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3,[ITEM_4] = HK_ITEM_4,[ITEM_5] = HK_ITEM_5,[ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7,}
local _Q = _Q
local _W = _W
local _E = _E
local _R = _R
local windUp = STATE_WINDUP
local windDown = STATE_WINDDOWN
local myTeam = myHero.team
local neutralTeam = 300
local enemyTeam = 300 - myTeam

local Q = {Range = 430, Speed = math.huge, Delay = 0.35, Width = 85, Collision = false}
local W = {Range = 400}
local E = {Range = 425}
local R = {Range = 1900, miniRange = 400, Speed = 1600, Delay = 0.6, Width = 80, Collision = false}

-- Engine
--
local function castSummoner(summonerName, castPos)
    local castPos = castPos or cursorPos
    if myHero:GetSpellData(SUMMONER_1).name == summonerName and Game.CanUseSpell(SUMMONER_1) == 0 then
        Control.CastSpell(HK_SUMMONER_1, castPos)
    elseif myHero:GetSpellData(SUMMONER_2).name == summonerName and Game.CanUseSpell(SUMMONER_2) == 0 then
        Control.CastSpell(HK_SUMMONER_2, castPos)
    end
end

local function getDistanceSqr(Pos1,Pos2)
    local Pos2 = Pos2 or myHero.pos
    local dx = Pos1.x - Pos2.x
    local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
    return dx^2 + dz^2
end

local function getDistance(Pos1,Pos2)
	return math.sqrt(getDistanceSqr(Pos1,Pos2))
end

local function getDistance2D(p1,p2)
    local p2 = p2 or myHero
    return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2))
end

local function resourcePercent(who,res)
    local who = who or myHero
    local res = res or mana
    if res == mana then
        return who.mana/who.maxMana * 100
    elseif res == health then
        return who.health/who.maxHealth * 100
    end
end

local function onScreen(obj)
	return obj.pos:To2D().onScreen;
end

local function minionsAround(range,pos,team)
    local pos = pos or myHero.pos
    local team = team or enemyTeam
    local Count = 0
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.team == team and not minion.dead and getDistance(pos,minion.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

local function heroesAround(range,pos,team)
    local pos = pos or myHero.pos
    local team = team or enemyTeam
    local Count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.team == team and not hero.dead and getDistance(pos,hero.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

local function randomHero(team)
    local team = team or enemyTeam
    for i = 1, Game.HeroCount(i) do
        local randomHero = Game.Hero(i)
        if randomHero.team == team then
            return randomHero
        end
    end
end

local function randomMinion(team)
    local team = team or enemyTeam
    for i = 1, Game.MinionCount(i) do
        local randomMinion = Game.Minion(i)
        if randomMinion.team == team then
            return randomMinion
        end
    end
end

local function hasBuff(who,buffname)
    local who = who or myHero
    local buffname = buffname or "recall"
    for i = 0, who.buffCount do
		local buff = who:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function hasBuffType(who,type)
    local who = who or myHero
    for i = 0, who.buffCount do 
	local buff = who:GetBuff(i)
		if buff.type == type and Game.Timer() < buff.expireTime then 
			return true
		end
	end
	return false
end

local function onEvade()
    if ExtLibEvade and ExtLibEvade.Evading then return true end
	return false
end

local channelSpells = {
	["FiddleSticks"] = {{slot = _W, type = "dps", channelTime = 5},{slot = _R, type = "dps", channelTime = 1.5}},
	["Janna"] = {{slot = _R, type = "utility", channelTime = 3}},
	["Jhin"] = {{slot = _R, type = "nuke", channelTime = 10}},
	["Karthus"] = {{slot = _R, type = "nuke", channelTime = 3}},
	["Katarina"] = {{slot = _R, type = "dps", channelTime = 2.5}},
	["Malzahar"] = {{slot = _R, type = "disable", channelTime = 2.5}},
	["MissFortune"] = {{slot = _R, type = "dps", channelTime = 3}},
	["Shen"] = {{slot = _R, type = "utility", channelTime = 35}},
	["Warwick"] = {{slot = _R, type = "disable", channelTime = 1.5}},
	["VelKoz"] = {{slot = _R, type = "dps", channelTime = 2.5}},
	["Xerath"] = {{slot = _R, type = "nuke", channelTime = 10}},
}
--
-- Engine

-- Menu
--
local Menu = MenuElement({type = MENU, id = "Menu", name = "Look this Poppy", leftIcon = "https://raw.githubusercontent.com/rugallord/ext/master/icons/poppy.jpg"})

-- Combo
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})

Menu.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "E", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "Wall", name = "Ignore Wall Check", value = true})
Menu.Combo:MenuElement({id = "R", name = "Use R", value = true})

Menu.Combo:MenuElement({type = MENU, id = "Item", name = "Item Usage"})
Menu.Combo.Item:MenuElement({id = "Tiamat", name = "Tiamat", value = true})
Menu.Combo.Item:MenuElement({id = "RavenousHydra", name = "Ravenous Hydra", value = true})
Menu.Combo.Item:MenuElement({id = "TitanicHydra", name = "Titanic Hydra", value = true})
Menu.Combo.Item:MenuElement({id = "YoumuusGhostblade", name = "Youmuu's Ghostblade", value = true})
Menu.Combo.Item:MenuElement({id = "RanduinsOmen", name = "Randuin's Omen", value = true})
Menu.Combo.Item:MenuElement({id = "BilgewaterCutlass", name = "Bilgewater Cutlass", value = true})
Menu.Combo.Item:MenuElement({id = "BladeoftheRuinedKing", name = "Blade of the Ruined King", value = true})

Menu.Combo:MenuElement({type = MENU, id = "Spell", name = "Spell Usage"})
Menu.Combo.Spell:MenuElement({id = "Exhaust", name = "Exhaust", value = true})
Menu.Combo.Spell:MenuElement({id = "Ignite", name = "Ignite", value = true})
Menu.Combo.Spell:MenuElement({id = "Smite", name = "Smite", value = true})
-- Combo

-- Harass
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})

Menu.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "E", name = "Use E", value = true})
Menu.Harass:MenuElement({id = "Wall", name = "Ignore Wall Check", value = false})
Menu.Harass:MenuElement({id = "R", name = "Use R", value = false})

Menu.Harass:MenuElement({type = MENU, id = "Item", name = "Item Usage"})
Menu.Harass.Item:MenuElement({id = "Tiamat", name = "Tiamat", value = true})
Menu.Harass.Item:MenuElement({id = "RavenousHydra", name = "Ravenous Hydra", value = true})
Menu.Harass.Item:MenuElement({id = "TitanicHydra", name = "Titanic Hydra", value = true})
Menu.Harass.Item:MenuElement({id = "YoumuusGhostblade", name = "Youmuu's Ghostblade", value = true})
Menu.Harass.Item:MenuElement({id = "RanduinsOmen", name = "Randuin's Omen", value = true})
Menu.Harass.Item:MenuElement({id = "BilgewaterCutlass", name = "Bilgewater Cutlass", value = true})
Menu.Harass.Item:MenuElement({id = "BladeoftheRuinedKing", name = "Blade of the Ruined King", value = true})

Menu.Harass:MenuElement({type = MENU, id = "Spell", name = "Spell Usage"})
Menu.Harass.Spell:MenuElement({id = "Exhaust", name = "Exhaust", value = true})
Menu.Harass.Spell:MenuElement({id = "Ignite", name = "Ignite", value = true})
Menu.Harass.Spell:MenuElement({id = "Smite", name = "Smite", value = true})
-- Harass

-- Clear
Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})

Menu.Clear:MenuElement({id = "Toggle", name = "Toggle", key = string.byte("T"), toggle = true})

Menu.Clear:MenuElement({type = MENU, id = "Q", name = "Q"})
Menu.Clear.Q:MenuElement({id = "Lane", name = "Lane", value = true})
Menu.Clear.Q:MenuElement({id = "X", name = "Minions hit by", value = 4, min = 1, max = 10})
Menu.Clear.Q:MenuElement({id = "Jungle", name = "Jungle", value = true})

Menu.Clear:MenuElement({type = MENU, id = "E", name = "E"})
Menu.Clear.E:MenuElement({id = "Lane", name = "Lane", value = false})
Menu.Clear.E:MenuElement({id = "Jungle", name = "Jungle", value = true})

Menu.Clear:MenuElement({type = MENU, id = "Item", name = "Item Usage"})
Menu.Clear.Item:MenuElement({id = "Tiamat", name = "Tiamat", value = true})
Menu.Clear.Item:MenuElement({id = "RavenousHydra", name = "Ravenous Hydra", value = true})
Menu.Clear.Item:MenuElement({id = "TitanicHydra", name = "Titanic Hydra", value = true})
-- Clear

-- Flee
Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})

Menu.Flee:MenuElement({id = "W", name = "Use W", value = true})

Menu.Flee:MenuElement({type = MENU, id = "Item", name = "Item Usage"})
Menu.Flee.Item:MenuElement({id = "YoumuusGhostblade", name = "Youmuu's Ghostblade", value = true})
Menu.Flee.Item:MenuElement({id = "RanduinsOmen", name = "Randuin's Omen", value = true})
Menu.Flee.Item:MenuElement({id = "BilgewaterCutlass", name = "Bilgewater Cutlass", value = true})
Menu.Flee.Item:MenuElement({id = "BladeoftheRuinedKing", name = "Blade of the Ruined King", value = true})

Menu.Flee:MenuElement({type = MENU, id = "Spell", name = "Spell Usage"})
Menu.Flee.Spell:MenuElement({id = "Exhaust", name = "Exhaust", value = true})
Menu.Flee.Spell:MenuElement({id = "Smite", name = "Smite", value = true})
-- Flee

-- Auto
Menu:MenuElement({type = MENU, id = "Auto", name = "Auto"})

Menu.Auto:MenuElement({type = MENU, id = "Q", name = "Q"})
Menu.Auto.Q:MenuElement({id = "KS", name = "Use Q Killsteal", value = true})

Menu.Auto:MenuElement({type = MENU, id = "W", name = "W"})
Menu.Auto.W:MenuElement({id = "Dash", name = "Use W vs Dash", value = true})

Menu.Auto:MenuElement({type = MENU, id = "E", name = "E"})
Menu.Auto.E:MenuElement({id = "KS", name = "Use E Killsteal", value = true})
Menu.Auto.E:MenuElement({id = "Int", name = "Use E to Interrupt", value = true})
Menu.Auto.E:MenuElement({type = MENU, id = "Interrupt", name = "Interrupt by Type"})
Menu.Auto.E.Interrupt:MenuElement({id = "dps", name = "Damage Per Second", value = true})
Menu.Auto.E.Interrupt:MenuElement({id = "nuke", name = "Nuke", value = true})
Menu.Auto.E.Interrupt:MenuElement({id = "utility", name = "Utility", value = true})
Menu.Auto.E.Interrupt:MenuElement({id = "disable", name = "Disable", value = true})

Menu.Auto:MenuElement({type = MENU, id = "R", name = "R"})
Menu.Auto.R:MenuElement({id = "KS", name = "Use R Killsteal", value = true})
Menu.Auto.R:MenuElement({id = "Int", name = "Use R to Interrupt", value = true})
Menu.Auto.R:MenuElement({type = MENU, id = "Interrupt", name = "Interrupt by Type"})
Menu.Auto.R.Interrupt:MenuElement({id = "dps", name = "Damage Per Second", value = true})
Menu.Auto.R.Interrupt:MenuElement({id = "nuke", name = "Nuke", value = true})
Menu.Auto.R.Interrupt:MenuElement({id = "utility", name = "Utility", value = true})
Menu.Auto.R.Interrupt:MenuElement({id = "disable", name = "Disable", value = true})

Menu.Auto:MenuElement({type = MENU, id = "Spell", name = "Spell Usage"})
Menu.Auto.Spell:MenuElement({id = "Ignite", name = "Ignite Killsteal", value = true})
Menu.Auto.Spell:MenuElement({type = MENU, id = "Smite", name = "Smite"})
Menu.Auto.Spell.Smite:MenuElement({id = "Smite", name = "Smite Killsteal", value = true})
-- Auto

-- Draw
Menu:MenuElement({type = MENU, id="Draw", name = "Draw"})

Menu.Draw:MenuElement({id = "Q", name = "Draw Q range", value = false})
Menu.Draw:MenuElement({id = "E", name = "Draw E range", value = false})
Menu.Draw:MenuElement({id = "R", name = "Draw R range", value = false})
Menu.Draw:MenuElement({id = "Text", name = "Draw Toggle", value = false})
Menu.Draw:MenuElement({id = "Size", name = "Text Size", value = 10, min = 1, max = 100})
Menu.Draw:MenuElement({id = "xPos", name = "Text X Position", value = 0, min = -300, max = 300, step = 10})
Menu.Draw:MenuElement({id = "yPos", name = "Text Y Position", value = 0, min = -300, max = 300, step = 10})
Menu.Draw:MenuElement({id = "Damage", name = "Draw Combo Damage", value = false})
-- Draw
--
-- Menu

-- Script
--
Callback.Add("Tick", function() onUpdate() end)

function onUpdate()
    if Game.IsChatOpen() or onEvade() or hasBuff() then return end
    onInterrupt()
    onDash()
    onKillsteal()
    if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then onCombo()
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then onHarass()
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then onClear()
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then onFlee()
    end
end

function channelingHero(who,spellkey)
    if not channelSpells[who.charName] then return false end
    local result = false
	for _, spell in pairs(channelSpells[who.charName]) do
		if who:GetSpellData(spell.slot).level > 0 and (who:GetSpellData(spell.slot).currentCd > who:GetSpellData(spell.slot).cd - spell.Duration) then
            if (spellkey == R and (
                (Menu.Auto.R.Interrupt.dps:Value() and spell.type == "dps") or
                (Menu.Auto.R.Interrupt.utility:Value() and spell.type == "utility") or
                (Menu.Auto.R.Interrupt.nuke:Value() and spell.type == "nuke") or
                (Menu.Auto.R.Interrupt.disable:Value() and spell.type == "disable")))
                or
                (spellkey == E and (
                (Menu.Auto.E.Interrupt.dps:Value() and spell.type == "dps") or
                (Menu.Auto.E.Interrupt.utility:Value() and spell.type == "utility") or
                (Menu.Auto.E.Interrupt.nuke:Value() and spell.type == "nuke") or
                (Menu.Auto.E.Interrupt.disable:Value() and spell.type == "disable"))) then
                result = true
                break
            end
		end
	end
	return result
end

function damageOutput(victim)
	local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end
	local total = 0
	local Qdmg = CalcPhysicalDamage(myHero, victim, (20 + 20 * myHero:GetSpellData(_Q).level + 0.8 * myHero.bonusDamage + 0.08 * victim.maxHealth))
    local Edmg = CalcPhysicalDamage(myHero, victim, (40 + 20 * myHero:GetSpellData(_E).level + 0.5 * myHero.bonusDamage))
    local Rdmg = CalcPhysicalDamage(myHero, victim, (55 + 50 * myHero:GetSpellData(_R).level + 0.45 * myHero.bonusDamage))
    local Ignitedmg = (70 + 20 * myHero.levelData.lvl)
    local ChillingSmitedmg = (20 + 8 * myHero.levelData.lvl)
    local BilgewaterCutlass = items[3144]
	local BladeoftheRuinedKing = items[3153]
	local BilgewaterCutlassdmg = CalcMagicalDamage(myHero, victim, (100))
    local BladeoftheRuinedKingdmg = CalcMagicalDamage(myHero, victim, (100))
	if Game.CanUseSpell(_Q) == 0 then
		total = total + Qdmg
	end
	if Game.CanUseSpell(_E) == 0 then
		total = total + Edmg
	end
	if Game.CanUseSpell(_R) == 0 then
		total = total + Rdmg
	end
	if BilgewaterCutlass and myHero:GetSpellData(BilgewaterCutlass).currentCd == 0 then
		total = total + BilgewaterCutlassdmg
	end
	if BladeoftheRuinedKing and myHero:GetSpellData(BladeoftheRuinedKing).currentCd == 0 then
		total = total + BladeoftheRuinedKingdmg
	end
	if (myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Game.CanUseSpell(SUMMONER_1) == 0) or (myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Game.CanUseSpell(SUMMONER_2) == 0) then
		total = total + Ignitedmg
	end
	if (myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and Game.CanUseSpell(SUMMONER_1) == 0) or (myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and Game.CanUseSpell(SUMMONER_2) == 0) then
		total = total + ChillingSmitedmg
	end
	return total
end

function onInterrupt()
    local enemy = randomHero(enemyTeam)
    if enemy and channelingHero(enemy,E) and Menu.Auto.E.Int:Value() and Game.CanUseSpell(_E) == 0 and getDistance(enemy.pos) < E.Range then
        Control.CastSpell(HK_E,enemy)
    elseif enemy and channelingHero(enemy,R) and Menu.Auto.R.Int:Value() and Game.CanUseSpell(_R) == 0 and getDistance(enemy.pos) < R.miniRange then
        Control.CastSpell(HK_R,enemy)
    end
end

function onDash()
    local enemy = randomHero(enemyTeam)
    if enemy and enemy.pathing.isDashing and Menu.Auto.W.Dash:Value() and Game.CanUseSpell(_W) == 0 and getDistance(enemy.pos) < W.Range then
        Control.CastSpell(HK_W)
    end
end

function onKillsteal()
    local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
    end
	local victim = randomHero()
	if victim == nil then return end
    local Qdmg = CalcPhysicalDamage(myHero, victim, (20 + 20 * myHero:GetSpellData(_Q).level + 0.8 * myHero.bonusDamage + 0.08 * victim.maxHealth))
    local Edmg = CalcPhysicalDamage(myHero, victim, (40 + 20 * myHero:GetSpellData(_E).level + 0.5 * myHero.bonusDamage))
    local Rdmg = CalcPhysicalDamage(myHero, victim, (55 + 50 * myHero:GetSpellData(_R).level + 0.45 * myHero.bonusDamage))
    local Ignitedmg = (70 + 20 * myHero.levelData.lvl)
    local ChillingSmitedmg = (20 + 8 * myHero.levelData.lvl)

    if victim and Menu.Auto.Q.KS:Value() and Game.CanUseSpell(_Q) == 0 and Qdmg > victim.health then
        if HPred:CanTarget(victim) then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, victim, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, nil)
            if hitChance and hitChance >= 2 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                Control.CastSpell(HK_Q, aimPosition)
            end
        end
    end
    if victim and Menu.Auto.R.KS:Value() and Game.CanUseSpell(_R) == 0 and Rdmg > victim.health then
        Control.CastSpell(HK_R, victim)
    end
    if victim and Menu.Auto.E.KS:Value() and Game.CanUseSpell(_E) == 0 and Edmg > victim.health then
        Control.CastSpell(HK_E, victim)
    end
    if victim and Menu.Auto.Spell.Ignite:Value() and Ignitedmg > victim.health and getDistance(victim.pos) < 600 then
        castSummoner("SummonerDot",victim)
    end
    if victim and Menu.Auto.Spell.Smite.Smite:Value() and ChillingSmitedmg > victim.health and getDistance(victim.pos) < 500 then
        castSummoner("S5_SummonerSmitePlayerGanker",victim)
    end
end

local function smiteName()
	local smiteName = ""
	if myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" or myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" then
		smiteName = "S5_SummonerSmiteDuel"
	elseif myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" then
		smiteName = "S5_SummonerSmitePlayerGanker"
	elseif myHero:GetSpellData(SUMMONER_1).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_2).name == "SummonerSmite" then
		smiteName = "SummonerSmite"
	end
	return smiteName
end

function onCombo()
    local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end
	local Tiamat = items[3077]
	local RavenousHydra = items[3074]
	local TitanicHydra = items[3748]
	local RanduinsOmen = items[3143]
	local YoumuusGhostblade = items[3142]
    local BilgewaterCutlass = items[3144]
    local BladeoftheRuinedKing = items[3153]
	local victim = myTarget(800)
	if victim == nil then return end
    if victim and Menu.Combo.Q:Value() and Game.CanUseSpell(_Q) == 0 then
        if HPred:CanTarget(victim) then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, victim, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, nil)
            if hitChance and hitChance >= 2 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                Control.CastSpell(HK_Q, aimPosition)
            end
        end
    end
    local Evec = Vector(victim.pos) - Vector(Vector(victim.pos) - Vector(myHero.pos)):Normalized() * -300
    if victim and Menu.Combo.E:Value() and Game.CanUseSpell(_E) == 0 and getDistance(victim.pos) < E.Range then
        if Menu.Combo.Wall:Value() or (not Menu.Combo.Wall:Value() and MapPosition:intersectsWall(LineSegment(victim,Evec))) then
            Control.CastSpell(HK_E,victim)
        end
    end
    if victim and Menu.Combo.R:Value() and Game.CanUseSpell(_R) == 0 and getDistance(victim.pos) < Q.Range and damageOutput(victim) > victim.health then
        Control.CastSpell(HK_R, victim)
	end
	if BilgewaterCutlass and myHero:GetSpellData(BilgewaterCutlass).currentCd == 0 and victim and Menu.Combo.Item.BilgewaterCutlass:Value() and getDistance(myHero.pos,victim.pos) < 550 then
        Control.CastSpell(HKITEM[BilgewaterCutlass], victim)
	end
	if BladeoftheRuinedKing and myHero:GetSpellData(BladeoftheRuinedKing).currentCd == 0 and victim and Menu.Combo.Item.BladeoftheRuinedKing:Value() and getDistance(myHero.pos,victim.pos) < 550 then
        Control.CastSpell(HKITEM[BladeoftheRuinedKing], victim)
	end
	if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0 and victim and Menu.Combo.Item.Tiamat:Value() and myHero.attackData.state == windDown then
        Control.CastSpell(HKITEM[Tiamat], victim)
	end
	if RavenousHydra and myHero:GetSpellData(RavenousHydra).currentCd == 0 and victim and Menu.Combo.Item.RavenousHydra:Value() and myHero.attackData.state == windDown then
        Control.CastSpell(HKITEM[RavenousHydra], victim)
	end
	if TitanicHydra and myHero:GetSpellData(TitanicHydra).currentCd == 0 and victim and Menu.Combo.Item.TitanicHydra:Value() and myHero.attackData.state == windDown then
        Control.CastSpell(HKITEM[TitanicHydra], victim)
	end
	if YoumuusGhostblade and myHero:GetSpellData(YoumuusGhostblade).currentCd == 0 and victim and Menu.Combo.Item.YoumuusGhostblade:Value() and (myHero.ms < victim.ms or getDistance(victim.pos) > 500) then
        Control.CastSpell(HKITEM[YoumuusGhostblade])
	end
	if RanduinsOmen and myHero:GetSpellData(RanduinsOmen).currentCd == 0 and victim and Menu.Combo.Item.RanduinsOmen:Value() and getDistance(myHero.pos,victim.pos) < 500 then
        Control.CastSpell(HKITEM[RanduinsOmen])
	end
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
		if victim and Menu.Combo.Spell.Ignite:Value() and getDistance(victim.pos) < 600 and damageOutput(victim) > victim.health then
        	castSummoner("SummonerDot",victim)
		end
	end
	local smiteName = smiteName()
	if smiteName ~= "" then
		if victim and Menu.Combo.Spell.Smite:Value() and getDistance(victim.pos) < 500 and damageOutput(victim) > victim.health then
        	castSummoner(smiteName,victim)
		end
	end
	if myHero:GetSpellData(SUMMONER_1).name == "Exhaust" or myHero:GetSpellData(SUMMONER_2).name == "Exhaust" then
		if victim and Menu.Combo.Spell.Exhaust:Value() and getDistance(victim.pos) < 650 and damageOutput(victim) > victim.health then
			castSummoner("SummonerExhaust",victim)
		end
	end
end

function onHarass()
    local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end
	local Tiamat = items[3077]
	local RavenousHydra = items[3074]
	local TitanicHydra = items[3748]
	local RanduinsOmen = items[3143]
	local YoumuusGhostblade = items[3142]
    local BilgewaterCutlass = items[3144]
    local BladeoftheRuinedKing = items[3153]
	local victim = myTarget(800)
	if victim == nil then return end
    if victim and Menu.Harass.Q:Value() and Game.CanUseSpell(_Q) == 0 then
        if HPred:CanTarget(victim) then
            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, victim, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, nil)
            if hitChance and hitChance >= 2 and HPred:GetDistance(myHero.pos, aimPosition) <= Q.Range then
                Control.CastSpell(HK_Q, aimPosition)
            end
        end
    end
    local Evec = Vector(victim.pos) - Vector(Vector(victim.pos) - Vector(myHero.pos)):Normalized() * -300
    if victim and Menu.Harass.E:Value() and Game.CanUseSpell(_E) == 0 and getDistance(victim.pos) < E.Range then
        if Menu.Harass.Wall:Value() or (not Menu.Harass.Wall:Value() and MapPosition:intersectsWall(LineSegment(victim,Evec))) then
            Control.CastSpell(HK_E,victim)
        end
    end
    if victim and Menu.Harass.R:Value() and Game.CanUseSpell(_R) == 0 and getDistance(victim.pos) < Q.Range and damageOutput(victim) > victim.health then
        Control.CastSpell(HK_R, victim)
	end
	if BilgewaterCutlass and myHero:GetSpellData(BilgewaterCutlass).currentCd == 0 and victim and Menu.Harass.Item.BilgewaterCutlass:Value() and getDistance(myHero.pos,victim.pos) < 550 then
        Control.CastSpell(HKITEM[BilgewaterCutlass], victim)
	end
	if BladeoftheRuinedKing and myHero:GetSpellData(BladeoftheRuinedKing).currentCd == 0 and victim and Menu.Harass.Item.BladeoftheRuinedKing:Value() and getDistance(myHero.pos,victim.pos) < 550 then
        Control.CastSpell(HKITEM[BladeoftheRuinedKing], victim)
	end
	if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0 and victim and Menu.Harass.Item.Tiamat:Value() and myHero.attackData.state == windDown then
        Control.CastSpell(HKITEM[Tiamat], victim)
	end
	if RavenousHydra and myHero:GetSpellData(RavenousHydra).currentCd == 0 and victim and Menu.Harass.Item.RavenousHydra:Value() and myHero.attackData.state == windDown then
        Control.CastSpell(HKITEM[RavenousHydra], victim)
	end
	if TitanicHydra and myHero:GetSpellData(TitanicHydra).currentCd == 0 and victim and Menu.Harass.Item.TitanicHydra:Value() and myHero.attackData.state == windDown then
        Control.CastSpell(HKITEM[TitanicHydra], victim)
	end
	if YoumuusGhostblade and myHero:GetSpellData(YoumuusGhostblade).currentCd == 0 and victim and Menu.Harass.Item.YoumuusGhostblade:Value() and (myHero.ms < victim.ms or getDistance(victim.pos) > 500) then
        Control.CastSpell(HKITEM[YoumuusGhostblade])
	end
	if RanduinsOmen and myHero:GetSpellData(RanduinsOmen).currentCd == 0 and victim and Menu.Harass.Item.RanduinsOmen:Value() and getDistance(myHero.pos,victim.pos) < 500 then
        Control.CastSpell(HKITEM[RanduinsOmen])
	end
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
		if victim and Menu.Harass.Spell.Ignite:Value() and getDistance(victim.pos) < 600 and damageOutput(victim) > victim.health then
        	castSummoner("SummonerDot",victim)
		end
	end
	local smiteName = smiteName()
	if smiteName ~= "" then
		if victim and Menu.Harass.Spell.Smite:Value() and getDistance(victim.pos) < 500 and damageOutput(victim) > victim.health then
        	castSummoner(smiteName,victim)
		end
	end
	if myHero:GetSpellData(SUMMONER_1).name == "Exhaust" or myHero:GetSpellData(SUMMONER_2).name == "Exhaust" then
		if victim and Menu.Harass.Spell.Exhaust:Value() and getDistance(victim.pos) < 650 and damageOutput(victim) > victim.health then
			castSummoner("SummonerExhaust",victim)
		end
	end
end

function onFlee()
	local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end
	local RanduinsOmen = items[3143]
	local YoumuusGhostblade = items[3142]
    local BilgewaterCutlass = items[3144]
	local BladeoftheRuinedKing = items[3153]
	local victim = myTarget(1900)
	if Menu.Flee.W:Value() and Game.CanUseSpell(_W) == 0 then
        Control.CastSpell(HK_W,victim)
	end
	if YoumuusGhostblade and myHero:GetSpellData(YoumuusGhostblade).currentCd == 0 and Menu.Flee.Item.YoumuusGhostblade:Value() then
        Control.CastSpell(HKITEM[YoumuusGhostblade])
	end
	if BilgewaterCutlass and myHero:GetSpellData(BilgewaterCutlass).currentCd == 0 and victim and Menu.Flee.Item.BilgewaterCutlass:Value() and getDistance(myHero.pos,victim.pos) < 550 then
        Control.CastSpell(HKITEM[BilgewaterCutlass], victim)
	end
	if BladeoftheRuinedKing and myHero:GetSpellData(BladeoftheRuinedKing).currentCd == 0 and victim and Menu.Flee.Item.BladeoftheRuinedKing:Value() and getDistance(myHero.pos,victim.pos) < 550 then
        Control.CastSpell(HKITEM[BladeoftheRuinedKing], victim)
	end
	if RanduinsOmen and myHero:GetSpellData(RanduinsOmen).currentCd == 0 and victim and Menu.Flee.Item.RanduinsOmen:Value() and getDistance(myHero.pos,victim.pos) < 500 then
        Control.CastSpell(HKITEM[RanduinsOmen])
	end
	if victim and Menu.Flee.Spell.Exhaust:Value() and getDistance(victim.pos) < 650 then
        castSummoner("SummonerExhaust",victim)
	end
	if victim and Menu.Flee.Spell.Smite:Value() and getDistance(victim.pos) < 500 then
        castSummoner("S5_SummonerSmitePlayerGanker",victim)
	end
end

function onClear()
	local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end
	local Tiamat = items[3077]
	local RavenousHydra = items[3074]
	local TitanicHydra = items[3748]
	local laneMinion = randomMinion(enemyTeam)
	local jungleMinion = randomMinion(neutralTeam)
	if laneMinion and Menu.Clear.E.Lane:Value() and Game.CanUseSpell(_E) == 0 and getDistance(laneMinion.pos) < E.Range then
		Control.CastSpell(HK_E, laneMinion)
	end
	if jungleMinion and Menu.Clear.E.Jungle:Value() and Game.CanUseSpell(_E) == 0 and getDistance(jungleMinion.pos) < E.Range then
		Control.CastSpell(HK_E, jungleMinion)
	end
	if laneMinion and Menu.Clear.Q.Lane:Value() and Game.CanUseSpell(_Q) == 0 and getDistance(laneMinion.pos) < Q.Range and laneMinion:GetCollision(Q.Width, Q.Speed, Q.Delay) >= Menu.Clear.Q.X:Value() - 1 then
		Control.CastSpell(HK_Q, laneMinion)
	end
	if jungleMinion and Menu.Clear.Q.Jungle:Value() and Game.CanUseSpell(_Q) == 0 and getDistance(jungleMinion.pos) < Q.Range then
		Control.CastSpell(HK_Q, jungleMinion)
	end
	if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0 and laneMinion and Menu.Clear.Item.Tiamat:Value() and myHero.attackData.state == windDown and getDistance(laneMinion.pos) < 200 then
        Control.CastSpell(HKITEM[Tiamat], laneMinion)
	end
	if RavenousHydra and myHero:GetSpellData(RavenousHydra).currentCd == 0 and laneMinion and Menu.Clear.Item.RavenousHydra:Value() and myHero.attackData.state == windDown and getDistance(laneMinion.pos) < 200 then
        Control.CastSpell(HKITEM[RavenousHydra], laneMinion)
	end
	if TitanicHydra and myHero:GetSpellData(TitanicHydra).currentCd == 0 and laneMinion and Menu.Clear.Item.TitanicHydra:Value() and myHero.attackData.state == windDown and getDistance(laneMinion.pos) < 200 then
        Control.CastSpell(HKITEM[TitanicHydra], laneMinion)
	end
	if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0 and jungleMinion and Menu.Clear.Item.Tiamat:Value() and myHero.attackData.state == windDown and getDistance(jungleMinion.pos) < 200 then
        Control.CastSpell(HKITEM[Tiamat], jungleMinion)
	end
	if RavenousHydra and myHero:GetSpellData(RavenousHydra).currentCd == 0 and jungleMinion and Menu.Clear.Item.RavenousHydra:Value() and myHero.attackData.state == windDown and getDistance(jungleMinion.pos) < 200 then
        Control.CastSpell(HKITEM[RavenousHydra], jungleMinion)
	end
	if TitanicHydra and myHero:GetSpellData(TitanicHydra).currentCd == 0 and jungleMinion and Menu.Clear.Item.TitanicHydra:Value() and myHero.attackData.state == windDown and getDistance(jungleMinion.pos) < 200 then
        Control.CastSpell(HKITEM[TitanicHydra], jungleMinion)
	end
end
--
-- Script

-- Draw
--
Callback.Add("Draw", function() onDraw() end)

function onDraw()
	if Menu.Draw.Q:Value() and Game.CanUseSpell(_Q) == 0 then Draw.Circle(myHero.pos, Q.Range, 3,  Draw.Color(255, 000, 000, 255)) end
	if Menu.Draw.E:Value() and Game.CanUseSpell(_E) == 0 then Draw.Circle(myHero.pos, E.Range, 3,  Draw.Color(255, 255, 255, 000)) end
	if Menu.Draw.R:Value() and Game.CanUseSpell(_R) == 0 then Draw.Circle(myHero.pos, R.Range, 3,  Draw.Color(255, 255, 000, 000)) end
	
	local textPos = myHero.pos:To2D()
	local size = Menu.Draw.Size:Value()
	local xPos = Menu.Draw.xPos:Value()
	local yPos = Menu.Draw.yPos:Value()
	if Menu.Draw.Text:Value() then
		if Menu.Clear.Toggle:Value() then
			Draw.Text("CLEAR ENABLED", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("CLEAR DISABLED", size, textPos.x + xPos, textPos.y + yPos, Draw.Color(255, 255, 000, 000)) 
		end
	end

	if Menu.Draw.Damage:Value() then
		local enemy = randomHero(enemyTeam)
		if enemy and enemy.isEnemy and not enemy.dead and enemy.visible then
			local barPos = enemy.hpBar
			local health = enemy.health
			local maxHealth = enemy.maxHealth
			local Damage = damageOutput(enemy)
			if Damage < health then
				Draw.Rect(barPos.x + 20, barPos.y - 7, (Damage / maxHealth ) * 100, 10, Draw.Color(255, 000, 255, 000))
			else
				Draw.Rect(barPos.x + 20, barPos.y - 7, (health / maxHealth ) * 100, 10, Draw.Color(255, 000, 255, 200))
			end
		end
	end
end
--
-- Draw

-- HPred
--
class "HPred"

Callback.Add("Tick", function() HPred:Tick() end)

local _reviveQueryFrequency = 3
local _lastReviveQuery = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
	}

local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		["KatarinaE"] = -255,
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
	}

local _cachedRevives = {}

local _movementHistory = {}

function HPred:Tick()
	if Game.Timer() - _lastReviveQuery < _reviveQueryFrequency then return end
	
	_lastReviveQuery=Game.Timer()
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local nearestDistance = 500
			for i = 1, Game.HeroCount() do
				local t = Game.Hero(i)
				local tDistance = self:GetDistance(particle.pos, t.pos)
				if tDistance < nearestDistance then
					nearestDistance = nearestDistance
					_cachedRevives[particle.networkID]["owner"] = t.charName
					_cachedRevives[particle.networkID]["pos"] = t.pos
					_cachedRevives[particle.networkID]["isEnemy"] = t.isEnemy					
				end
			end
		end
	end
end

function HPred:GetEnemyNexusPosition()
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
		if target and aimPosition then
		return target, aimPosition
	end
	
	target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end

	target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
end

function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			if predictedPos:To2D().onScreen then
				local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
				if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) ^ 2) then
					targetCount = targetCount + 1
				end
			end
		end
	end
	return targetCount
end

function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist)
	local _validTargets = {}
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if self:CanTarget(t) and (not whitelist or whitelist[t.charName]) then			
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision)		
			if hitChance >= minimumHitChance and aimPosition:To2D().onScreen then
				_validTargets[t.charName] = {["hitChance"] = hitChance, ["aimPosition"] = aimPosition}
			end
		end
	end
	
	local rHitChance = 0
	local rAimPosition
	for targetName, targetData in pairs(_validTargets) do
		if targetData.hitChance > rHitChance then
			rHitChance = targetData.hitChance
			rAimPosition = targetData.aimPosition
		end		
	end
	
	if rHitChance >= minimumHitChance then
		return rHitChance, rAimPosition
	end	
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision)
	self:UpdateMovementHistory(target)
	
	local hitChance = 1	
	
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1)
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	
	if _movementHistory and _movementHistory[target.charName] and Game.Timer() - _movementHistory[target.charName]["ChangedAt"] < .25 then
		hitChance = 2
	end

	if not target.pathing or not target.pathing.hasMovePath then
		hitChance = 2
	end	
	
	if movementRadius - target.boundingRadius <= radius /2 then
		hitChance = 3
	end	
	
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 4
		else			
			hitChance = 3
		end
	end
	
	if self:GetDistance(myHero.pos, aimPosition) >= range then
		hitChance = -1
	end
	
	if hitChance > 0 and checkCollision then	
		if self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end
	
	local isRecalling, recallDuration = self:GetRecallingData(unit)	
	if isRecalling and recallDuration > .25 then
		reactionTime = .25
	end
	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:GetDistance(source, dashEndPosition) <= range  and dashEndPosition:To2D().onScreen then				
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and t.pos:To2D().onScreen then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy and revive.pos:To2D().onScreen then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = self:GetEnemyByName(revive.owner)
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					if target and distance < 250 then					
						endPos = target.pos		
					end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * math.min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						if blinkRange == 0 then						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * 150
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(myHero.pos, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:GetDistance(source, endPos) <= range and endPos:To2D().onScreen and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle and _blinkLookupTable[particle.name] and self:GetDistance(source, particle.pos) < range and particle.pos:To2D().onScreen then
			local pPos = particle.pos
			for k,v in pairs(self:GetEnemyHeroes()) do
				local t = v
				if t and t.isEnemy and self:GetDistance(t.pos, pPos) < t.boundingRadius then
					if (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
						target = t
						aimPosition = pPos
						return target,aimPosition
					end
				end
			end
		end
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		local interceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed)
		if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
			target = t
			aimPosition = t.pos	
			return target, aimPosition
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if self:CanTarget(t) and self:GetDistance(source, t.pos) <= range and t.pos:To2D().onScreen then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i);
		if turret.isEnemy and self:GetDistance(source, turret.pos) <= range and turret.pos:To2D().onScreen then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				local interceptPosition = self:GetTeleportOffset(turret.pos,223.31)
				local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt
				if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = turret
					aimPosition =interceptPosition
					return target, aimPosition
				end
			end
		end
	end
	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i);
		if ward.isEnemy and self:GetDistance(source, ward.pos) <= range and ward.pos:To2D().onScreen then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				local interceptPosition = self:GetTeleportOffset(ward.pos,100.01)
				local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt
				if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = ward
					aimPosition = interceptPosition
					return target, aimPosition
				end
			end
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i);
		if minion.isEnemy and self:GetDistance(source, minion.pos) <= range and minion.pos:To2D().onScreen then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then	
				local interceptPosition = self:GetTeleportOffset(minion.pos,143.25)
				local deltaInterceptTime = self:GetSpellInterceptTime(source, interceptPosition, delay, speed) - expiresAt
				if deltaInterceptTime > 0 and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = minion				
					aimPosition = interceptPosition
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = math.atan2(deltaPos.x, deltaPos.z) *  180 / math.pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

function HPred:UpdateMovementHistory(unit)
	if not _movementHistory[unit.charName] then
		_movementHistory[unit.charName] = {}
		_movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["StartPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["PreviousAngle"] = 0
		_movementHistory[unit.charName]["ChangedAt"] = Game.Timer()
	end
	
	if _movementHistory[unit.charName]["EndPos"].x ~=unit.pathing.endPos.x or _movementHistory[unit.charName]["EndPos"].y ~=unit.pathing.endPos.y or _movementHistory[unit.charName]["EndPos"].z ~=unit.pathing.endPos.z then				
		_movementHistory[unit.charName]["PreviousAngle"] = self:Angle(Vector(_movementHistory[unit.charName]["StartPos"].x, _movementHistory[unit.charName]["StartPos"].y, _movementHistory[unit.charName]["StartPos"].z), Vector(_movementHistory[unit.charName]["EndPos"].x, _movementHistory[unit.charName]["EndPos"].y, _movementHistory[unit.charName]["EndPos"].z))
		_movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["StartPos"] = unit.pos
		_movementHistory[unit.charName]["ChangedAt"] = Game.Timer()
	end
	
end

function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

function HPred:CanTarget(target)
	return target.isEnemy and target.alive and target.visible and target.isTargetable
end

function HPred:CanTargetALL(target)
	return target.alive and target.visible and target.isTargetable
end

function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i);
		if ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle.handle == handle then
			target = particle
			return target
		end
	end
end
function HPred:GetObjectByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local enemy = Game.Minion(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local enemy = Game.Ward(i);
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local enemy = Game.Particle(i)
		if enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = math.max
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		local d = self:GetDistance(origin, particle.pos)
		if d < distance then
			distance = d
			target = particle
		end
	end
	return target, distance
end

function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end

function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end

function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if self:CanTarget(minion) and self:GetDistance(minion.pos, location) < maxDistance then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:GetDistance(location, predictedPosition) <= radius + minion.boundingRadius then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end


function HPred:GetRecallingData(unit)
	for K, Buff in pairs(GetBuffs(unit)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true, Game.Timer() - Buff.startTime
		end
	end
	return false
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = math.abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:GetDistance(origin, target) < range then
		return true
	end
end

function HPred:GetEnemyHeroes()
	local _EnemyHeroes = {}
  	for i = 1, Game.HeroCount() do
    	local enemy = Game.Hero(i)
    	if enemy and enemy.isEnemy then
	  		table.insert(_EnemyHeroes, enemy)
  		end
  	end
  	return _EnemyHeroes
end

function HPred:GetDistanceSqr(p1, p2)	
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function HPred:GetDistance(p1, p2)
	return math.sqrt(self:GetDistanceSqr(p1, p2))
end
--
-- HPred
