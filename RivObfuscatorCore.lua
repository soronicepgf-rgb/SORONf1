local RivObfuscator = {}

local function generateRandomName(length)
    local chars = {"l", "I"}
    local name = ""
    for i = 1, length do
        name = name .. chars[math.random(1, #chars)]
    end
    return name
end

function RivObfuscator.Obfuscate(sourceCode)
    local decoderName = generateRandomName(8)
    local stringVarName = generateRandomName(12)
    local tableVarName = generateRandomName(10)
    local byteVarName = generateRandomName(6)
    
    local byteCodeArray = {}
    for i = 1, #sourceCode do
        table.insert(byteCodeArray, string.byte(sourceCode, i) + 14)
    end
    -- On utilise "|" comme séparateur, c'est beaucoup plus sûr que les slashs
    local encryptedString = table.concat(byteCodeArray, "|")

    -- J'ai retiré les commentaires internes pour éviter le bug de saut de ligne
    local finalCode = [[
local ]]..tableVarName..[[ = string.split("]]..encryptedString..[[", "|")
local ]]..stringVarName..[[ = ""
local ]]..decoderName..[[ = function()
    for _, ]]..byteVarName..[[ in ipairs(]]..tableVarName..[[) do
        if ]]..byteVarName..[[ ~= "" then
            ]]..stringVarName..[[ = ]]..stringVarName..[[ .. string.char(tonumber(]]..byteVarName..[[) - 14)
        end
    end
    return ]]..stringVarName..[[
end
local execute = loadstring(]]..decoderName..[[())
if execute then execute() end
]]

    return finalCode
end

return RivObfuscator
