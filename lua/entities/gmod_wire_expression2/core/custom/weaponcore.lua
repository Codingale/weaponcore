E2Lib.RegisterExtension("CodingaleWeaponCore", false)

local function ValidPly( ply )
    return IsValid(ply) and ply:IsPlayer()
end

local function hasAccess(ply) -- TODO: Rewrite permissions to a ULX/CPPI system.
    return ply:IsAdmin()
end

local function getWeaponByClass(ply, weap)

    for k,v in pairs(ply:GetWeapons()) do
        if v:GetClass() == weap then
            return v
        end
    end

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TODO: relocate?

local OKWeapons = { }
OKWeapons["weapon_para"] = true
OKWeapons["weapon_crowbar"] = true
OKWeapons["weapon_stunstick"] = true
OKWeapons["weapon_physcannon"] = true
OKWeapons["weapon_physgun"] = true
OKWeapons["weapon_pistol"] = true
OKWeapons["weapon_357"] = true
OKWeapons["weapon_smg1"] = true
OKWeapons["weapon_ar2"] = true
OKWeapons["weapon_shotgun"] = true
OKWeapons["weapon_crossbow"] = true
OKWeapons["weapon_frag"] = true
OKWeapons["weapon_rpg"] = true
OKWeapons["weapon_slam"] = true
OKWeapons["weapon_bugbait"] = true
OKWeapons["item_ml_grenade"] = true
OKWeapons["item_ar2_grenade"] = true
OKWeapons["item_ammo_ar2_altfire"] = true
OKWeapons["gmod_camera"] = true
OKWeapons["gmod_tool"] = true

-- TODO: find a way to get base weapons / verify this is all of them. (least that don't get returned by weapons.Get)

function isWeapon(swepName) 
    if OKWeapons[swepName] then return true end
    return weapons.Get(swepName) ~= nil	
end

e2function entity entity:plyGive(string class)
    if not ValidPly(this) then return NULL end
    if not hasAccess(self.player) then return NULL end
    if not isWeapon(class) then return NULL end
    
return this:Give(class) or NULL
end

e2function void entity:plyGiveAmmo(string ammotype, number count)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:GiveAmmo(count, ammotype, false)
end

e2function void entity:plySetAmmo(string ammotype, number count)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:SetAmmo(count, ammotype)
end

-----
e2function void entity:plySelectWeapon(string weapon)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:SelectWeapon(weapon)
end

-----
e2function void entity:plyDropWeapon(string weapon)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end
	
    this:DropNamedWeapon(weapon)
end

e2function void entity:plyDropWeapon(entity weapon)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end
	
    this:DropWeapon(weapon)
end

-----------------------------------------------------------------
e2function void entity:plyStripWeapon(string weapon)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:StripWeapon(weapon)
end

e2function void entity:plyStripWeapon(entity weapon)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:StripWeapon(weapon:GetClass())
end

e2function void entity:plyStripWeapons()
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:StripWeapons()
end

e2function void entity:plyStripAmmo()
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end

    this:StripAmmo()
end

e2function void entity:plySetClip1(ammo)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end
    if not (this:IsWeapon() or this:IsPlayer()) then return end

    local weap = this
    if this:IsPlayer() then
       weap = this:GetActiveWeapon()
    end

    weap:SetClip1(ammo)
end

e2function void entity:plySetClip2(ammo)
    if not ValidPly(this) then return end
    if not hasAccess(self.player) then return end
    if not (this:IsWeapon() or this:IsPlayer()) then return end

    local weap = this

    if this:IsPlayer() then
        weap = this:GetActiveWeapon()
    end

    weap:SetClip2(ammo)
end

e2function entity entity:getWeapon(string class)
    if not ValidPly(this) or not this:HasWeapon(class) then return NULL end
    return getWeaponByClass(this, class) or NULL
end

e2function array entity:getWeapons()
    if not ValidPly(this) then return {} end
    return this:GetWeapons()
end


e2function number entity:hasWeapon(string weapon)
    if not ValidPly(this) then return 0 end
    return this:HasWeapon(weapon) and 1 or 0
end

------------------------------------------------------------------------------

local registered_e2s_switch = {}
local weaponPly = nil
local weaponOld = nil
local weaponNext = nil
local weaponswitchclk = 0

registerCallback("destruct", function(self)
    registered_e2s_switch[self.entity] = nil
end)

hook.Add("PlayerSwitchWeapon", "Expresion2PlayerSwitchWeapon", function(ply, oldWeapon, newWeapon)
    weaponPly = ply
    weaponOld = oldWeapon
    weaponNext = newWeapon
    weaponswitchclk = 1

    for ent, _ in pairs(registered_e2s_switch) do
        ent:Execute()
    end

    weaponswitchclk = 0
end)

e2function void runOnWeaponSwitch(activate)
    if activate ~= 0 then
        registered_e2s_switch[self.entity] = true
    else
        registered_e2s_switch[self.entity] = nil
    end
end
 
e2function number weaponSwitchClk()
   return weaponswitchclk
end

e2function entity lastWeaponSwitchPlayer()
	return weaponPly or NULL
end

e2function entity lastWeaponSwitchOld()
    return weaponOld or NULL
end

e2function entity lastWeaponSwitchNext()
    return weaponNext or NULL
end

------------------------------------------------------------------------------

local registered_e2s_equip = {}
local weaponEquiped = NULL
local weaponequipclk = 0

registerCallback("destruct", function(self)
    registered_e2s_equip[self.entity] = nil
end)

hook.Add("WeaponEquip", "Expresion2WeaponEquip", function(weapon)
    timer.Simple(0, function() -- executes next tick
        weaponEquiped = weapon
        weaponequipclk = 1

        for ent,_ in pairs(registered_e2s_equip) do
            ent:Execute()	
        end
        weaponequipclk = 0
    end)
end)

e2function void runOnWeaponEquip(activate)
	if activate ~= 0 then
		registered_e2s_equip[self.entity] = true
	else
		registered_e2s_equip[self.entity] = nil
	end
end
 
e2function number weaponEquipClk()
	return weaponequipclk
end

e2function entity lastWeaponEquip()
	return weaponEquiped or NULL
end
