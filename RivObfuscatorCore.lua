-- ==========================================
-- RIV OBFUSCATOR CORE (Hébergé sur GitHub)
-- ==========================================

local RivObfuscator = {}

-- Fonction pour générer des noms de variables illisibles (ex: lIlIlIlI)
local function generateRandomName(length)
    local chars = {"l", "I"} -- L minuscule et i majuscule (très dur à différencier)
    local name = ""
    for i = 1, length do
        name = name .. chars[math.random(1, #chars)]
    end
    return name
end

-- La fonction principale d'obfuscation
function RivObfuscator.Obfuscate(sourceCode)
    -- 1. On génère des noms de variables aléatoires pour le décodeur
    local decoderName = generateRandomName(8)
    local stringVarName = generateRandomName(12)
    local tableVarName = generateRandomName(10)
    local byteVarName = generateRandomName(6)
    
    -- 2. On transforme le code source en une suite de nombres (Bytes)
    local byteCodeArray = {}
    for i = 1, #sourceCode do
        -- On ajoute une fausse couche de calcul (+14) pour embrouiller les pistes
        table.insert(byteCodeArray, string.byte(sourceCode, i) + 14)
    end
    local encryptedString = table.concat(byteCodeArray, "\\")

    -- 3. On construit le script final (le "Wrapper")
    -- C'est ce script que l'utilisateur final verra dans son Roblox Studio.
    local finalCode = [[
-- OBFUSCATED BY RIV PRO V1.0
-- Do not attempt to modify this script.

local ]]..tableVarName..[[ = string.split("]]..encryptedString..[[", "\\")
local ]]..stringVarName..[[ = ""
local ]]..decoderName..[[ = function()
    for _, ]]..byteVarName..[[ in ipairs(]]..tableVarName..[[) do
        if ]]..byteVarName..[[ ~= "" then
            -- On annule la fausse couche de calcul (-14)
            ]]..stringVarName..[[ = ]]..stringVarName..[[ .. string.char(tonumber(]]..byteVarName..[[) - 14)
        end
    end
    return ]]..stringVarName..[[
end

-- Exécution via loadstring (Nécessite ServerScriptService ou un exécuteur pour fonctionner)
local execute = loadstring(]]..decoderName..[[())
if execute then execute() end
]]

    return finalCode
end

return RivObfuscator
