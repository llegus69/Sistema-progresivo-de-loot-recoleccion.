
--[[
    ====================================================
          SISTEMA PROGRESIVO DE LOOT PROFESIONES
    ====================================================
    
    Creador: Lleguito
    Para: Comunidad WoW (servidores AzerothCore + Eluna 3.3.5a)
    Versión: 2026 - Progresivo por skill
    Descripción: Duplica loot de profesiones de recolección (hierbas, minería, desuello)
                 con probabilidad basada en la habilidad actual del jugador.
                 
    
    Comandos GM (en /say):
    - duplicate toggle       → Activar/Desactivar
    - duplicate status       → Ver estado actual
    
    ¡Disfruta y comparte en la comunidad!
    ====================================================
--]]


-- Configuración inicial:
DuplicateLootEnabled = true -- False para descativar

-- IDs de profesiones de recolección
local SKILL_MINING    = 186
local SKILL_HERBALISM = 182
local SKILL_SKINNING  = 393

local function OnLootItem(event, player, item, count)
    if not DuplicateLootEnabled then
        return
    end
    
    local class    = item:GetClass()
    local subClass = item:GetSubClass()
    
    -- Solo items de profesiones: Hierbas(9), Minerales(7), Cueros(6)
    if class ~= 7 or (subClass ~= 9 and subClass ~= 7 and subClass ~= 6) then
        return
    end
    
    -- Determinar qué skill corresponde al loot (basado en subclase)
    local skillId = 0
    if subClass == 9 then     -- Hierbas
        skillId = SKILL_HERBALISM
    elseif subClass == 7 then -- Minerales
        skillId = SKILL_MINING
    elseif subClass == 6 then -- Cueros
        skillId = SKILL_SKINNING
    end
    
    if skillId == 0 then
        return
    end
    
    local skillValue = player:GetSkillValue(skillId)
    
    -- Probabilidad = skill / 10 (ej: 75 → 7%, 450 → 45%)
    local chance = math.floor(skillValue / 8)  -- Puedes cambiar a /15, /8, etc.
    
    -- Opcional: cap máximo (descomenta si quieres limitar)
    -- chance = math.min(chance, 50)
    
    -- Si chance >=1 y random cae dentro → bonus
    if chance > 0 and math.random(1, 100) <= chance then
        player:AddItem(item:GetEntry(), count)
        player:SendBroadcastMessage("|cFF00FF00¡Tu habilidad te recompensa!|r Recibiste x2 de |cFFFFFFFF" .. item:GetName() .. "|r (" .. count .. " extra) |r")
    end
end

RegisterPlayerEvent(32, OnLootItem)  -- PLAYER_EVENT_ON_LOOT_ITEM

local function OnChat(event, player, msg, Type, lang)
    if not player:IsGM() then
        return
    end
    
    local lowerMsg = string.lower(msg)
    
    -- Toggle
    if lowerMsg == "duplicate toggle" or lowerMsg == "duplicatetoggle" then
        DuplicateLootEnabled = not DuplicateLootEnabled
        local status = DuplicateLootEnabled and "|cFF00FF00ACTIVADO|r" or "|cFFFF0000DESACTIVADO|r"
        player:SendBroadcastMessage("|cFFFFFFFFDuplicar loot profesiones: " .. status .. " (prob por skill)|r")
        return
    end
    
    -- Status (muestra config actual)
    if lowerMsg == "duplicate status" then
        local status = DuplicateLootEnabled and "|cFF00FF00ACTIVADO|r" or "|cFFFF0000DESACTIVADO|r"
        player:SendBroadcastMessage("|cFFFFFFFFDuplicar loot profesiones: " .. status .. " | Fórmula: skill / 10 %|r")
        return
    end
end

RegisterPlayerEvent(18, OnChat)  -- PLAYER_EVENT_ON_CHAT

print("[Sistema progresivo de loot de recoleccion] Cargado correctamente")
