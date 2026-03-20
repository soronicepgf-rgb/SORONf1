--[[
    RivObfuscator v2.0 - Multi-Layer Lua Obfuscator
    Couches: Encodage XOR + Caesar shift + Chunking + Faux variables + Anti-debug
]]

local RivObfuscator = {}

-- ============================================================
-- UTILITAIRES INTERNES
-- ============================================================

local CHARS_LOOKALIKE = {"l", "I", "1", "lI", "Il", "lIl", "IlI", "llI", "Ill", "lll", "III"}

local function randomName(minLen, maxLen)
    minLen = minLen or 6
    maxLen = maxLen or 14
    local len = math.random(minLen, maxLen)
    local name = CHARS_LOOKALIKE[math.random(1, 2)] -- commence par l ou I (valide en Lua)
    for i = 2, len do
        name = name .. CHARS_LOOKALIKE[math.random(1, #CHARS_LOOKALIKE)]
    end
    return name
end

local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- Génère une clé XOR aléatoire (tableau de N octets)
local function generateXorKey(length)
    local key = {}
    for i = 1, length do
        key[i] = math.random(1, 127)
    end
    return key
end

-- ============================================================
-- COUCHE 1 : ENCODAGE XOR + DÉCALAGE VARIABLE PAR POSITION
-- ============================================================

local function encodeLayer1(source, xorKey)
    local out = {}
    local klen = #xorKey
    for i = 1, #source do
        local b = string.byte(source, i)
        local k = xorKey[((i - 1) % klen) + 1]
        local shift = (i % 7) + 3
        local encoded = ((b ~ k) + shift) % 256
        table.insert(out, encoded)
    end
    return out
end

-- ============================================================
-- COUCHE 2 : DÉCOUPAGE EN CHUNKS + ORDRE MÉLANGÉ
-- ============================================================

local function encodeLayer2(byteArray, chunkSize)
    chunkSize = chunkSize or math.random(4, 9)
    local chunks = {}
    local i = 1
    local idx = 0
    while i <= #byteArray do
        local chunk = {}
        for j = i, math.min(i + chunkSize - 1, #byteArray) do
            table.insert(chunk, byteArray[j])
        end
        table.insert(chunks, {index = idx, data = chunk})
        idx = idx + 1
        i = i + chunkSize
    end

    -- On mélange les chunks et on retient l'ordre original
    local order = {}
    for k = 1, #chunks do order[k] = k end
    shuffleTable(order)

    local shuffledChunks = {}
    local orderMap = {}
    for pos, origIdx in ipairs(order) do
        shuffledChunks[pos] = chunks[origIdx]
        orderMap[pos] = chunks[origIdx].index
    end

    return shuffledChunks, orderMap, chunkSize
end

-- ============================================================
-- COUCHE 3 : ENCODAGE BASE-LIKE (valeurs → strings hex-like)
-- ============================================================

local function toHexStr(n)
    return string.format("%02x", n)
end

-- ============================================================
-- GÉNÉRATION DU CODE OBFUSQUÉ
-- ============================================================

function RivObfuscator.Obfuscate(sourceCode)
    math.randomseed(os.clock() * 1e9)

    -- Noms de variables tous différents et lookalike
    local usedNames = {}
    local function newName(min, max)
        local n
        repeat n = randomName(min, max) until not usedNames[n]
        usedNames[n] = true
        return n
    end

    -- Variables principales
    local vChunkTable   = newName(8, 12)
    local vOrderTable   = newName(8, 12)
    local vXorKey       = newName(8, 12)
    local vDecodeFunc   = newName(8, 12)
    local vReorder      = newName(8, 12)
    local vAssemble     = newName(8, 12)
    local vResult       = newName(6, 10)
    local vI            = newName(4, 6)
    local vJ            = newName(4, 6)
    local vK            = newName(4, 6)
    local vTemp         = newName(5, 8)
    local vOut          = newName(5, 8)
    local vB            = newName(4, 6)
    local vS            = newName(4, 6)
    local vPos          = newName(4, 7)
    local vChunk        = newName(5, 8)
    local vByte         = newName(4, 6)
    local vFinal        = newName(6, 10)
    local vExec         = newName(6, 9)
    local vAntiDbg      = newName(8, 12)

    -- Faux noms / leurres (variables jamais utilisées mais déclarées)
    local fakeVars = {}
    for i = 1, math.random(6, 12) do
        table.insert(fakeVars, newName(5, 10))
    end

    -- == Encodage ==
    local xorKey = generateXorKey(math.random(8, 16))
    local encoded = encodeLayer1(sourceCode, xorKey)
    local chunkSize = math.random(5, 10)
    local shuffledChunks, orderMap = encodeLayer2(encoded, chunkSize)

    -- == Sérialisation de la clé XOR ==
    local xorKeyStr = "{"
    for i, v in ipairs(xorKey) do
        xorKeyStr = xorKeyStr .. v
        if i < #xorKey then xorKeyStr = xorKeyStr .. "," end
    end
    xorKeyStr = xorKeyStr .. "}"

    -- == Sérialisation des chunks (en hex) ==
    local chunkLines = {}
    for pos, chunk in ipairs(shuffledChunks) do
        local hexVals = {}
        for _, b in ipairs(chunk.data) do
            table.insert(hexVals, '"' .. toHexStr(b) .. '"')
        end
        table.insert(chunkLines, "{" .. table.concat(hexVals, ",") .. "}")
    end
    local chunkTableStr = "{\n"
    for _, cl in ipairs(chunkLines) do
        chunkTableStr = chunkTableStr .. "    " .. cl .. ",\n"
    end
    chunkTableStr = chunkTableStr .. "}"

    -- == Sérialisation de l'ordre ==
    local orderStr = "{"
    for i, v in ipairs(orderMap) do
        orderStr = orderStr .. v
        if i < #orderMap then orderStr = orderStr .. "," end
    end
    orderStr = orderStr .. "}"

    -- == Fausses variables (leurres) ==
    local fakeDecls = ""
    for _, fv in ipairs(fakeVars) do
        local fakeVal = math.random(0, 99999)
        fakeDecls = fakeDecls .. "local " .. fv .. " = " .. fakeVal .. ";\n"
    end

    -- == Code final ==
    local code = ""

    -- En-tête leurres
    code = code .. fakeDecls .. "\n"

    -- Déclaration clé XOR
    code = code .. "local " .. vXorKey .. " = " .. xorKeyStr .. ";\n"

    -- Déclaration chunks mélangés
    code = code .. "local " .. vChunkTable .. " = " .. chunkTableStr .. ";\n"

    -- Déclaration ordre
    code = code .. "local " .. vOrderTable .. " = " .. orderStr .. ";\n\n"

    -- Fonction de réordonnancement
    code = code .. "local " .. vReorder .. " = function(" .. vChunk .. ", " .. vS .. ")\n"
    code = code .. "    local " .. vOut .. " = {};\n"
    code = code .. "    local " .. vPos .. " = 1;\n"
    code = code .. "    for " .. vI .. " = 1, #" .. vS .. " do\n"
    code = code .. "        local " .. vK .. " = " .. vS .. "[" .. vI .. "] + 1;\n"
    code = code .. "        for " .. vJ .. " = 1, #" .. vChunk .. "[" .. vK .. "] do\n"
    code = code .. "            " .. vOut .. "[" .. vPos .. "] = " .. vChunk .. "[" .. vK .. "][" .. vJ .. "];\n"
    code = code .. "            " .. vPos .. " = " .. vPos .. " + 1;\n"
    code = code .. "        end;\n"
    code = code .. "    end;\n"
    code = code .. "    return " .. vOut .. ";\n"
    code = code .. "end;\n\n"

    -- Fonction de décodage XOR + shift
    code = code .. "local " .. vDecodeFunc .. " = function(" .. vB .. ", " .. vI .. ", " .. vK .. ")\n"
    code = code .. "    local " .. vTemp .. " = tonumber(" .. vB .. ", 16);\n"
    code = code .. "    local " .. vS .. " = (" .. vI .. " % 7) + 3;\n"
    code = code .. "    local " .. vJ .. " = " .. vTemp .. " - " .. vS .. ";\n"
    code = code .. "    if " .. vJ .. " < 0 then " .. vJ .. " = " .. vJ .. " + 256; end;\n"
    code = code .. "    local " .. vPos .. " = ((" .. vI .. " - 1) % #" .. vK .. ") + 1;\n"
    code = code .. "    return " .. vJ .. " ~ " .. vK .. "[" .. vPos .. "];\n"
    code = code .. "end;\n\n"

    -- Reconstruction ordre réel
    -- On reconstruit l'ordre réel (inverse du shuffle)
    local realOrder = {}
    for i = 1, #orderMap do realOrder[i] = 0 end
    for pos, origIdx in ipairs(orderMap) do
        realOrder[origIdx + 1] = pos - 1
    end
    local realOrderStr = "{"
    for i, v in ipairs(realOrder) do
        realOrderStr = realOrderStr .. v
        if i < #realOrder then realOrderStr = realOrderStr .. "," end
    end
    realOrderStr = realOrderStr .. "}"

    local vRealOrder = newName(8, 12)
    code = code .. "local " .. vRealOrder .. " = " .. realOrderStr .. ";\n"

    -- Assemblage final
    code = code .. "local " .. vAssemble .. " = function()\n"
    code = code .. "    local " .. vTemp .. " = " .. vReorder .. "(" .. vChunkTable .. ", " .. vRealOrder .. ");\n"
    code = code .. "    local " .. vOut .. " = {};\n"
    code = code .. "    for " .. vI .. " = 1, #" .. vTemp .. " do\n"
    code = code .. "        local " .. vB .. " = " .. vDecodeFunc .. "(" .. vTemp .. "[" .. vI .. "], " .. vI .. ", " .. vXorKey .. ");\n"
    code = code .. "        table.insert(" .. vOut .. ", string.char(" .. vB .. "));\n"
    code = code .. "    end;\n"
    code = code .. "    return table.concat(" .. vOut .. ");\n"
    code = code .. "end;\n\n"

    -- Anti-debug basique (détecte si debug.getinfo est actif)
    code = code .. "local " .. vAntiDbg .. " = (debug and debug.getinfo) and 1 or 0;\n"
    code = code .. "if " .. vAntiDbg .. " == 0 then\n"

    -- Exécution
    code = code .. "    local " .. vResult .. " = " .. vAssemble .. "();\n"
    code = code .. "    local " .. vFinal .. " = loadstring(" .. vResult .. ");\n"
    code = code .. "    if " .. vFinal .. " then\n"
    code = code .. "        local " .. vExec .. ", " .. vTemp .. " = pcall(" .. vFinal .. ");\n"
    code = code .. "    end;\n"
    code = code .. "end;\n"

    return code
end

-- ============================================================
-- TEST RAPIDE (à commenter en production)
-- ============================================================

-- local testCode = [[print("Hello from RivObfuscator v2!")]]
-- print(RivObfuscator.Obfuscate(testCode))

return RivObfuscator
