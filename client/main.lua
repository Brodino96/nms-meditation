local meditating = false ---@type boolean
local interval = Config.interval * 1000 ---@type number

local function stopMeditation()
    meditating = false
    ExecuteCommand("e c")
    exports["alzamani"]:enableHands()
end

local function initMeditate()

    local currentMana = exports["barra"]:readMana()
    local maxMana = exports["barra"]:MaxMana() / 2
    if currentMana > maxMana then
        return lib.notify({ type = "error", title = "Non riesci più ad assorbire mana"})
    end

    meditating = true
    local playerPed = PlayerPedId()
    local oldHealth = GetEntityHealth(playerPed)
    ExecuteCommand("e wait5")
    Wait(100)
    ExecuteCommand("e meditate")
    Wait(200)

    exports["alzamani"]:disableHands()

    CreateThread(function ()
        while meditating do
            Wait(0)
            playerPed = PlayerPedId()
            local currentHealth = GetEntityHealth(playerPed)
            if currentHealth < oldHealth or IsPedWalking(playerPed) or not IsEntityPlayingAnim(playerPed, "missclothing", "idle_storeclerk", 3) then
                lib.notify({ type = "error", title = "Hai perso la concentrazione" })
                stopMeditation()
            end

            oldHealth = currentHealth
        end
    end)

    CreateThread(function ()
        while meditating do
            Wait(interval)
            TriggerEvent("decreaseMana", (-Config.manaToAdd))
            currentMana = exports["barra"]:readMana()
            if currentMana > maxMana then
                lib.notify({ type = "error", title = "Hai già raggiunto la metà del tuo mana massimo"})
                stopMeditation()
            end
        end
    end)

end

RegisterCommand("meditate", function ()
    if meditating then
        stopMeditation()
    else
        initMeditate()
    end
end, false)