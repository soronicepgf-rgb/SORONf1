local RivObfuscator = {}

-- Table de caractères pour le Base64
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Fonction de chiffrement Base64 (Vraie logique, pas de décor)
local function b64Encode(data)
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte()
        for i=8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i=1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
        return b64chars:sub(c+1, c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Générateur de noms illisibles
local function genName(len)
    local chars = {"l", "I", "V", "v"}
    local name = chars[math.random(1, #chars)]
    for i=2, len do name = name .. chars[math.random(1, #chars)] end
    return name
end

function RivObfuscator.Obfuscate(sourceCode)
    -- 1. VRAI Chiffrement Bitwise XOR
    local xorKey = math.random(50, 200)
    local xored = ""
    for i = 1, #sourceCode do
        local a = string.byte(sourceCode, i)
        local b = xorKey
        local res = 0
        local mul = 1
        -- Simulation du XOR (Obligatoire car bit32 n'est pas dispo partout)
        for j = 1, 8 do
            if (a % 2) ~= (b % 2) then res = res + mul end
            a = math.floor(a / 2)
            b = math.floor(b / 2)
            mul = mul * 2
        end
        xored = xored .. string.char(res)
    end

    -- 2. Encodage Base64 du résultat XOR
    local payload = b64Encode(xored)
    local payloadChunks = {}
    
    -- Découpage de la chaîne en morceaux pour complexifier la lecture
    for i = 1, #payload, 60 do
        table.insert(payloadChunks, string.sub(payload, i, i+59))
    end

    -- Variables dynamiques
    local vData = genName(8)
    local vEnv = genName(9)
    local fXor = genName(10)
    local fB64 = genName(11)
    local fMap = genName(7)

    -- 3. Construction du script final (Structure lourde mais 100% utile)
    local out = "-- RIV OBFUSCATOR V4: PURE LOGIC (DOUBLE ENCRYPTION)\n"
    out = out .. "local " .. vEnv .. " = getfenv;\n"
    -- Mappage des fonctions Roblox pour les masquer
    out = out .. "local " .. fMap .. " = { b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', g = string.gsub, c = string.char, s = string.sub, f = math.floor };\n"
    
    -- Injection des données
    out = out .. "local " .. vData .. " = {\n"
    for _, chunk in ipairs(payloadChunks) do
        out = out .. "    '" .. chunk .. "',\n"
    end
    out = out .. "};\n"

    -- Architecture du Décodeur Base64 Intégré
    out = out .. "local function " .. fB64 .. "(tbl)\n"
    out = out .. "    local data = table.concat(tbl);\n"
    out = out .. "    data = " .. fMap .. ".g(data, '[^'.." .. fMap .. ".b..'=]', '');\n"
    out = out .. "    local dec = " .. fMap .. ".g(data, '.', function(x)\n"
    out = out .. "        if (x == '=') then return '' end;\n"
    out = out .. "        local r, f = '', (string.find(" .. fMap .. ".b, x)-1);\n"
    out = out .. "        for i=6, 1, -1 do\n"
    out = out .. "            local bit = (f % 2^i - f % 2^(i-1) > 0 and '1' or '0');\n"
    out = out .. "            r = r .. bit;\n"
    out = out .. "        end;\n"
    out = out .. "        return r;\n"
    out = out .. "    end);\n"
    out = out .. "    local final = " .. fMap .. ".g(dec, '%d%d%d?%d?%d?%d?%d?%d?', function(x)\n"
    out = out .. "        if (#x ~= 8) then return '' end;\n"
    out = out .. "        local c = 0;\n"
    out = out .. "        for i=1, 8 do\n"
    out = out .. "            if " .. fMap .. ".s(x, i, i) == '1' then c = c + 2^(8-i) end;\n"
    out = out .. "        end;\n"
    out = out .. "        return " .. fMap .. ".c(c);\n"
    out = out .. "    end);\n"
    out = out .. "    return final;\n"
    out = out .. "end;\n"

    -- Architecture du Décodeur XOR par Machine d'État (Control Flow Flattening)
    -- Ça remplace une simple boucle par une logique éclatée et très dure à suivre.
    out = out .. "local function " .. fXor .. "(data, key)\n"
    out = out .. "    local state = 1;\n"
    out = out .. "    local res = {};\n"
    out = out .. "    local idx = 1;\n"
    out = out .. "    local len = #data;\n"
    out = out .. "    while state ~= 5 do\n"
    out = out .. "        if state == 1 then\n"
    out = out .. "            if idx > len then state = 5 else state = 2 end\n"
    out = out .. "        elseif state == 2 then\n"
    out = out .. "            local a = string.byte(data, idx);\n"
    out = out .. "            local b = key;\n"
    out = out .. "            local r = 0;\n"
    out = out .. "            local m = 1;\n"
    out = out .. "            for j=1, 8 do\n"
    out = out .. "                if (a % 2) ~= (b % 2) then r = r + m end;\n"
    out = out .. "                a = " .. fMap .. ".f(a / 2);\n"
    out = out .. "                b = " .. fMap .. ".f(b / 2);\n"
    out = out .. "                m = m * 2;\n"
    out = out .. "            end;\n"
    out = out .. "            table.insert(res, " .. fMap .. ".c(r));\n"
    out = out .. "            state = 3;\n"
    out = out .. "        elseif state == 3 then\n"
    out = out .. "            idx = idx + 1;\n"
    out = out .. "            state = 1;\n"
    out = out .. "        end;\n"
    out = out .. "    end;\n"
    out = out .. "    return table.concat(res);\n"
    out = out .. "end;\n"

    -- Exécution finale masquée via getfenv
    out = out .. "local raw = " .. fXor .. "(" .. fB64 .. "(" .. vData .. "), " .. xorKey .. ");\n"
    out = out .. "local call = " .. vEnv .. "()[" .. fMap .. ".c(108,111,97,100,115,116,114,105,110,103)](raw);\n"
    out = out .. "if call then call() end;\n"

    return out
end

return RivObfuscator
