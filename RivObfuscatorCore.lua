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
    local tableVarName = generateRandomName(10)
    local byteVarName = generateRandomName(6)
    local outputTableVar = generateRandomName(9) -- Nouvelle variable pour l'optimisation

    local byteCodeArray = {}
    for i = 1, #sourceCode do
        table.insert(byteCodeArray, string.byte(sourceCode, i) + 14)
    end
    local encryptedString = table.concat(byteCodeArray, "|")
    -- Génération du code avec l'optimisation "table.concat" pour un décodage instantané
    local finalCode = "local " .. tableVarName .. " = string.split('" .. encryptedString .. "', '|');\n"
    finalCode = finalCode .. "local " .. decoderName .. " = function()\n"
    finalCode = finalCode .. "    local " .. outputTableVar .. " = {};\n"
    finalCode = finalCode .. "    for _, " .. byteVarName .. " in ipairs(" .. tableVarName .. ") do\n"
    finalCode = finalCode .. "        if " .. byteVarName .. " ~= '' then\n"
    finalCode = finalCode .. "            table.insert(" .. outputTableVar .. ", string.char(tonumber(" .. byteVarName .. ") - 14));\n"
    finalCode = finalCode .. "        end;\n"
    finalCode = finalCode .. "    end;\n"
    finalCode = finalCode .. "    return table.concat(" .. outputTableVar .. ");\n"
    finalCode = finalCode .. "end;\n"
    finalCode = finalCode .. "local execute = loadstring(" .. decoderName .. "());\n"
    finalCode = finalCode .. "if execute then execute(); end;\n"
    return finalCode
end
return RivObfuscator.
