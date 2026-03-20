local RivObfuscator = {}

local function generateString(len)
    local c = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local s = ""
    for i = 1, len do
        local r = math.random(1, #c)
        s = s .. string.sub(c, r, r)
    end
    return s
end

local function generateOpcodes()
    local ops = ""
    for i = 1, 300 do
        ops = ops .. "local op_" .. generateString(8) .. " = " .. math.random(1000, 9999) .. ";\n"
    end
    return ops
end

function RivObfuscator.Obfuscate(source)
    local envVar = generateString(12)
    local dataVar = generateString(15)
    local outVar = generateString(10)
    
    local keyBase = math.random(50, 150)
    
    -- Chiffrement
    local encrypted = {}
    for i = 1, #source do
        local b = string.byte(source, i)
        local k = (keyBase + i) % 256
        table.insert(encrypted, tostring((b + k) % 256))
    end
    local payload = table.concat(encrypted, "\\")

    -- Construction du code généré
    local code = "-- RIV V5 : AI-SANDBOX BLACKLIST\n"
    code = code .. generateOpcodes()
    
    code = code .. "local " .. envVar .. " = getfenv and getfenv() or _ENV;\n"
    
    -- VERROUILLAGE ROBLOX : L'IA plantera ici car elle ne possède pas 'game' ou 'Instance'
    code = code .. "if not " .. envVar .. ".game then return end;\n"
    code = code .. "if type(" .. envVar .. ".game) ~= 'userdata' then return end;\n"
    
    -- La clé dépend de la longueur du nom de la classe de 'game' (DataModel = 9)
    -- Si l'IA essaie de deviner statiquement, elle ratera la clé.
    code = code .. "local engineKey = string.len(" .. envVar .. ".game.ClassName or 'xxxxxxxxx');\n"
    code = code .. "if engineKey ~= 9 then return end;\n"
    
    -- Vraie clé calculée avec la variable Roblox
    local fakeMathBase = keyBase - 9 
    code = code .. "local dynamicKey = " .. fakeMathBase .. " + engineKey;\n"

    code = code .. "local " .. dataVar .. " = string.split('" .. payload .. "', '\\');\n"
    code = code .. "local " .. outVar .. " = {};\n"

    -- Décodeur
    code = code .. "for i = 1, #" .. dataVar .. " do\n"
    code = code .. "    local val = tonumber(" .. dataVar .. "[i]);\n"
    code = code .. "    if val then\n"
    code = code .. "        local k = (dynamicKey + i) % 256;\n"
    code = code .. "        local orig = (val - k) % 256;\n"
    code = code .. "        if orig < 0 then orig = orig + 256 end;\n"
    code = code .. "        table.insert(" .. outVar .. ", string.char(orig));\n"
    code = code .. "    end;\n"
    code = code .. "end;\n"

    -- Exécution
    code = code .. "local exe = " .. envVar .. ".loadstring or " .. envVar .. ".load;\n"
    code = code .. "if exe then\n"
    code = code .. "    local fn = exe(table.concat(" .. outVar .. "));\n"
    code = code .. "    if fn then fn() end;\n"
    code = code .. "end;\n"

    return code
end

return RivObfuscator
