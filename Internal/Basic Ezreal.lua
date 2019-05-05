--Okay, this script will be descriptive. You can use it and take examples from here or learn to write your own way
--Okay, let's go!


--Let's add the champion: Ezreal. 
if GetObjectName(GetMyHero()) ~= "Ezreal" then 
    return
end

--Here Variables:
local function HealthCool(unit)
    return GetCurrentHP(unit)
end

local target = GetCurrentTarget();
local GameDelay = 0;
local GetCurrent = 100;

--[[Usually you need to declare the Range of Spells but since the GoS API PROVIDES this for people we do not need!
Exemple:
local Q_Range = 1150;
local W_Range = 1150;
local E_Range = 475;
local R_Range = math.huge;

Info: https://leagueoflegends.fandom.com/wiki/Ezreal
]]

--But you can define:
local S_Ez = {
	Q_Ez = {Ranger = 1150, Delay = 0.25 , Speed = 2000 , Width = 80, collision = true},
	W_Ez = {Ranger = 1150, Delay = 0.25 , Speed = 1600 , Width = 80},
	E_Ez = {Ranger = 475, Delay = 0.25 , Speed = 2000 , Width = 50},
	R_Ez = {Ranger = 5000, Delay = 1.0 , Speed = 2000 , Width = 160},
}

--^^Info: https://leagueoflegends.fandom.com/wiki/Ezreal


--You can use LIB, the GoS API requires it!
--Libs: I will use these two.
require ("OpenPredict") -- Prediction!!
require ("DamageLib") -- KillSteal, to calculate the damage.


--Here: Some platforms need to add some module for Orbwalking to work > Here is the cado:
function Orbwalking()
	if _G.IOW_Loaded and IOW:Orbwalking() then
		return IOW:Orbwalking()
	elseif _G.PW_Loaded and PW:Orbwalking() then
		return PW:Orbwalking()
	elseif _G.DAC_Loaded and DAC:Orbwalking() then
		return DAC:Orbwalking()
	elseif _G.AutoCarry_Loaded and DACR:Orbwalking() then
		return DACR:Orbwalking()
	elseif _G.SLW_Loaded and SLW:Orbwalking() then
		return SLW:Orbwalking()
	elseif GoSWalkLoaded and GoSWalk.CurrentMode then
		return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
	end
end
--[[You can set -> Orbwalking == "Combo", different in function]]


-------------------
-- Menu creation --
-------------------

-- Here we will define the menu --
local EzrealScript = Menu("Ezreal", "Ezreal 1v") -- Menu(ID, Name for Menu)
-- Combo;
EzrealScript:SubMenu("EzC", "Combo->Settings") --SubMenu(ID, Name for SubMenu)
EzrealScript.EzC:Boolean("cQ", "Use->Q", true) 
EzrealScript.EzC:Boolean("cW", "Use->W", true)
EzrealScript.EzC:Boolean("cE", "Use->E", false)
EzrealScript.EzC:Key("RManual", "Manual -> R", string.byte("T"))
--Harass;
EzrealScript:SubMenu("EzH", "Harass->Settings")
EzrealScript.EzH:Boolean("hQ", "Use->Q", true)
EzrealScript.EzH:Boolean("hW", "Use->W", true)
--Lane;
EzrealScript:SubMenu("EzC", "Clear->Settings")
EzrealScript.EzC:Boolean("Q", "Use Q", true)
EzrealScript.EzC:Slider("ManaQQ", "Min. Mana", 60, 0, 100, 1)
--Kill;
EzrealScript:SubMenu("EzK", "Kill->Settings")
EzrealScript.EzK:Boolean("Q", "Use Q", true)
--Drawings;
EzrealScript:SubMenu("EzD", "Draw->Settings")
EzrealScript.EzD:Boolean("Q", "Draw Q", false)
EzrealScript.EzD:Boolean("W", "Draw W", false)
EzrealScript.EzD:Boolean("E", "Draw E", false)
EzrealScript.EzD:Boolean("R", "Draw R", false)
EzrealScript.EzD:Boolean("DDS", "Draw Damage Spells", true)
--You can add information in the Menu.
EzrealScript:Info("Creator:", "_Tulio1")
--^^Here you can add anything that will be in your script, Harass, JungleClear, Misc, Use Items. Feel free to customize your script.
--I do not usually add LANECLEAR to my scripts. But here I will add!



--Well let's start making our script work.
--Here we can set as much as OnTick and if you have OnUpdate (If you have in the API)
OnTick(function(myHero)
    DamageCalculator();
    --which should be used for heavy calculations and hundreds of calls to GotBuff functions, etc without losing any performance (causing FPS lag)
    --Are we defining the Drawings here? Here are the functions such as: COMBO.
    target = GetCurrentTarget();
    if myHero.dead then return end
    --Here you can define your functions! But I love doing everything together.
    KillSteal();
    --Let's start with the Combo:
        -->Combo:
    if Orbwalking() == "Combo" then
        --> Q
        if EzrealScript.EzC.cQ:Value() and Ready(_Q) and ValidTarget(target, S_Ez.Q_Ez.Ranger) then
            --You could have done a function Ezreal_Use_Q (); It does, but I love doing it.
            if GetDistance(target) < S_Ez.Q_Ez.Ranger then
                local Pred_Q = GetPrediction(target, 1150, 0.25, 2000, 80, true) --Prediciton: GetLinearAOEPrediction or GetPrediction.
                if Pred_Q.hitChance > 1 then
                    CastSkillShot(_Q --[[(or 0 = _Q)]], Pred_Q.castPos)
                end
            end
		end	
 		--> W 
		if EzrealScript.EzC.cW:Value() and Ready(_W) and ValidTarget(target, S_Ez.W_Ez.Ranger) then
            if GetDistance(target) < S_Ez.W_Ez.Ranger then
                local Pred_W = GetPrediction(target, 1150, 0.25, 2000, 80, true)
                if Pred_W.hitChance > 0.3 then
                    CastSkillShot(_W --[[(or 1 = _W)]], Pred_W.castPos)
                end
            end
        end
        -->	E
		if EzrealScript.EzC.cE:Value() then
			if Ready(_E) then
				if ValidTarget(target, S_Ez.E_Ez.Ranger + GetRange(myHero)) then
					CastSkillShot(_E, GetMousePos())
                else 
                    if GetDistance(target) >= 700 and Ready(_E) then
                        local OriginPos = GetOrigin(target);
                        if GetCurrentHP(target) < getdmg("E", target, myHero) then --getdmg -> require ("DamageLib") 
                            local Pred_E = GetPrediction(target, 465, 0.25, 1000, 50, false)
                            if Pred_E.hitChance > 0.3 then
                                CastSkillShot(_E --[[(or 2 = _E)]], Pred_E.castPos)
                            end	
                        end 
                    end 
                end
			end
        end
        -->
        if EzrealScript.EzC.RManual:Value() then
            if Ready(_R) and ValidTarget(target, Spells.R.range) then
                if GetCurrentHP(target) < getdmg("R", target, myHero) then
                    local Pred_R = GetPrediction(target, 3500, 1, 2000, 160, true)
                    if Pred_R.hitChance > 0.8 then
                        CastSkillShot(_R, Pred_R.castPos)
                    end
                end
            end
        end
    end
    --Go Harass:
    if Orbwalking() == "Harass" then
        --You can set Mana for harass but I do not usually add!
        if EzrealScript.EzH.hQ:Value() and Ready(_Q) and ValidTarget(target, S_Ez.Q_Ez.Ranger) then
            --You could have done a function Ezreal_Use_Q (); It does, but I love doing it.
            if GetDistance(target) < S_Ez.Q_Ez.Ranger then
                local Pred_Q = GetPrediction(target, 1150, 0.25, 2000, 80, true) --Prediciton: GetLinearAOEPrediction or GetPrediction.
                if Pred_Q.hitChance > 1 then
                    CastSkillShot(_Q --[[(or 0 = _Q)]], Pred_Q.castPos)
                end
            end
		end	
 		--> W 
		if EzrealScript.EzH.hW:Value() and Ready(_W) and ValidTarget(target, S_Ez.W_Ez.Ranger) then
            if GetDistance(target) < S_Ez.W_Ez.Ranger then
                local Pred_W = GetPrediction(target, 1150, 0.25, 2000, 80, true)
                if Pred_W.hitChance > 0.9 then
                    CastSkillShot(_W --[[(or 1 = _W)]], Pred_W.castPos)
                end
            end
        end
    end
    --Go Lane:
    if Orbwalking() == "LaneClear" then
		if EzrealScript.EzC.Q:Value() then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
                    if GetCurrent * GetCurrentMana(myHero) / GetMaxMana(myHero) > EzrealScript.EzC.ManaQQ:Value() then
                        local rangeAA = GetRange(myHero); --returns the attack range of an object
						if ValidTarget(minion, S_Ez.Q_Ez.Ranger) and GetDistance(minion) > rangeAA then
							if Ready(_Q) then
								CastSkillShot(_Q, GetOrigin(minion))
							end
						end
					end
				end
			end
		end
	end
end)

function KillSteal()
    for _, Entity in pairs(GetEnemyHeroes()) do
        if Ready(_Q) and ValidTarget(Entity, S_Ez.Q_Ez.Ranger) and EzrealScript.EzK.Q:Value() then
            if GetCurrentHP(Entity) < getdmg("Q", Entity, myHero) then
                if GetDistance(target) < S_Ez.Q_Ez.Ranger then
                    local Pred_Q = GetPrediction(target, 1150, 0.25, 2000, 80, true) --Prediciton: GetLinearAOEPrediction or GetPrediction.
                    if Pred_Q.hitChance > 1 then
                        CastSkillShot(_Q --[[(or 0 = _Q)]], Pred_Q.castPos)
                    end
                end
            end
        end 
    end
end

--The Damage:
local DamageSpells = {
	["Q"] = 35 + 20*GetCastLevel(myHero,0) + GetBonusDmg(myHero)*1.1 + GetBonusAP(myHero)*0.4,
    --["W"] = W does not scale any more.
    ["E"] = 10 + 25*GetCastLevel(myHero,2) + GetBonusDmg(myHero)*1 + GetBonusAP(myHero)*0.3,
    ["R"] = 350 + 150*GetCastLevel(myHero,3) + GetBonusDmg(myHero)*1 + GetBonusAP(myHero)*0.2,
} 
function DamageCalculator(spell) --Spells! _Q, _W, _E, _R
	return DamageSpells[spell]
end

OnDraw(function(myHero)
    --Here we define the drawings, you can make up to triangle
    if myHero.dead then return end -- "You're getting crazy? If my hero is dead, will the drawings appear?" - Not your beast, see that the "return"  
    local myorigin = GetOrigin(myHero); -- Set where you are this is important!
    
--Spell -> Q
    if EzrealScript.EzD.Q:Value() then 
        DrawCircle(myorigin, Spells.Q.range, 1, 25, 0xFFFFFF00) --DrawCircle(origin.x,origin.y,origin.z,300,0,0,0xffffffff); --draws a circle around object (params: x,y,z,radius,width,quality,colorARGB);
    end
--Spell -> W
    if EzrealScript.EzD.W:Value() then 
        DrawCircle(myorigin, Spells.W.range, 1, 25, 0xFFFFFF00) 
    end
--Spell -> E
    if EzrealScript.EzD.E:Value() then 
        DrawCircle(myorigin, Spells.E.range, 1, 25, 0xFFFFFF00) 
    end
--Spell -> R
    if EzrealScript.EzD.R:Value() then 
        DrawCircle(myorigin, Spells.R.range, 1, 25, 0xFFFFFF00) 
    end
    --The Damage: Let's do the Damage calulator!
    for _, Entity in pairs(GetEnemyHeroes()) do
        if EzrealScript.EzD.DDS:Value() then
            if Entity.dead then return end 
            if GetCurrentHP(Entity) < getdmg("R", Entity, myHero) then
                DrawText("Kill that bastard!",30, Entity.pos2D.x-10, Entity.pos2D.y-50, 0xFFFFFF00)
            end
            if ValidTarget(Entity, 1500) then
                local DamageDraw = 0 
                if Ready(_Q) and EzrealScript.DrawDMG.Q:Value() then 
                    DamageDraw = DamageCalculator("Q")
                end
                if Ready(_W) and EzrealScript.DrawDMG.E:Value() then 
                    DamageDraw = DamageCalculator("E")
                end
                if Ready(_R) and EzrealScript.DrawDMG.R:Value() then 
                    DamageDraw = DamageCalculator("R")
                end
                DamageDraw = CalcDamage(myHero, Entity, 0, DamageDraw)

                if DamageDraw >= GetCurrentHP(Entity) then 
                    DamageDraw = GetCurrentHP(Entity)
                end
                DrawDmgOverHpBar(Entity, HealthCool(Entity), 0, DamageDraw, 0xFFFFFF00) -- DrawDmgOverHpBar(unit,health,ADDmg,APDmg,Color)  Draws a damage line onto the hp bar.
               
            end
        end
	end
end)

