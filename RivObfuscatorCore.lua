-- =========================================================================
-- ⚡ RIV OBFUSCATOR CORE PRO V3.0 (MODULAIRE & POLYMORPHIQUE) ⚡
-- =========================================================================
local RivObfuscator = {}

-- Utilitaire pour noms aléatoires complexes (mélange lIl, 0O, _ )
local function genComplexName(len)
    local chars = {"l", "I", "u", "v"}
    local name = chars[math.random(1, #chars)]
    for i = 2, len do name = name .. chars[math.random(1, #chars)] end
    return name
end

-- Module de génération de Junk Code massive (Génère ~100-150 lignes inutiles)
local function generateJunkBlock()
    local junk = "-- [[ DECOY LOGIC START ]]\nlocal " .. genComplexName(10) .. " = {}\n"
    local tName = genComplexName(11)
    junk = junk .. "local " .. tName .. " = {math.pi, math.random(1,99), string.byte('R')}\n"
    
    -- Génération de 50 variables mathématiques interactives mais inutiles
    for i=1, 50 do
        local v1, v2, v3 = genComplexName(8), genComplexName(8), genComplexName(9)
        junk = junk .. "local " .. v1 .. " = math.cos(" .. i .. ") * " .. math.random(10,50) .. ";\n"
        junk = junk .. "local " .. v2 .. " = " .. v1 .. " / 2 + table.insert(" .. tName .. ", " .. v1 .. ");\n"
        if i % 3 == 0 then
            junk = junk .. "local " .. v3 .. " = function(a) return a * " .. i .. " end;\n"
            junk = junk .. tName .. "[1] = " .. tName .. "[1] + " .. v3 .. "(" .. v1 .. ");\n"
        end
    end

    -- Génération de fausses tables de conversion
    local mapName = genComplexName(12)
    junk = junk .. "local " .. mapName .. " = { [120]=5, [99]=12, ["..math.random(100,200).."]=function() return 1 end };\n"
    for j=1, 20 do
        junk = junk .. mapName .. "[" .. math.random(10,300) .. "] = " .. mapName .. "[120] + math.sin("..j..");\n"
    end
    
    junk = junk .. "-- [[ DECOY LOGIC END ]]\n\n"
    return junk
end

-- Génération de bruit aléatoire (lettres) à insérer dans le payload
local function getNoise()
    local noise = ""
    local noiseLen = math.random(1, 3)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i=1, noiseLen do
        local idx = math.random(1, #chars)
        noise = noise .. string.sub(chars, idx, idx)
    end
    return noise
end

function RivObfuscator.Obfuscate(sourceCode)
    -- --- 1. PRÉPARATION & NOMMAGE --- --
    -- Génération massive de Junk Code pour noyer le poisson
    local junkCodeBlock = generateJunkBlock()
    
    -- Variables principales du décodeur (Noms complexes)
    local dataStrName = genComplexName(15) -- Chaîne de données chiffrée
    local outputTableName = genComplexName(14) -- Table de sortie
    local mainDecoderName = genComplexName(13) -- Fonction décodeur
    local pointerName = genComplexName(9) -- Pointeur de boucle
    local charByteName = genComplexName(7) -- Stockage temporaire d'octet
    local finalExecName = genComplexName(11) -- Stockage loadstring masqué

    -- --- 2. ENCRYPTAGE POLYMORPHIQUE DYNAMIQUE & BRUIT --- --
    local byteCodeArray = {}
    
    for i = 1, #sourceCode do
        local originalByte = string.byte(sourceCode, i)
        
        -- Algorithme Polymorphique : La clé change selon la position (i)
        -- Formule : (Byte + (i * 2) + 10)
        local key = (i * 2) + 10
        local encryptedByte = originalByte + key
        
        -- On stocke l'octet chiffré
        table.insert(byteCodeArray, tostring(encryptedByte))
        
        -- Insertion de BRUIT aléatoire (lettres) après l'octet
        table.insert(byteCodeArray, getNoise())
    end
    
    -- On assemble le tout avec un séparateur complexe "@"
    local rawPayload = table.concat(byteCodeArray, "@")
    local finalPayload = getNoise() .. "@" .. rawPayload .. "@" .. getNoise() -- Bruit au début et fin

    -- --- 3. CONSTRUCTION DU WRAPPER COMPLEXE --- --
    -- Titre Pro & Junk Code Massive
    local finalCode = "-- [[ OBFUSCATED BY RIV PRO V3.0 - DYNAMIC & POLYMORPHIC EQUATION ]]\n"
    finalCode = finalCode .. "-- [[ DÉCOMPILATION IMPOSSIBLE - MACHINE VIRTUELLE MATHÉMATIQUE ACTIVE ]]\n\n"
    finalCode = finalCode .. junkCodeBlock -- <--- Injection de ~100-150 lignes de Junk

    -- Données chiffrées avec bruit
    finalCode = finalCode .. "local " .. dataStrName .. " = \"" .. finalPayload .. "\";\n"
    
    -- Décodeur complexe State-Machine
    finalCode = finalCode .. "local " .. mainDecoderName .. " = function()\n"
    finalCode = finalCode .. "    local " .. outputTableName .. " = {};\n"
    finalCode = finalCode .. "    local raw_data = string.split(" .. dataStrName .. ", \"@\");\n"
    
    -- Plus de Junk Code à l'intérieur du décodeur pour perturber l'analyse
    finalCode = finalCode .. "    local decoy_math = {math.sin(1), math.cos(90)};\n"
    finalCode = finalCode .. "    decoy_math[1] = decoy_math[2] * table.getn(raw_data);\n\n"
    
    -- Boucle de décodage avec inversion de l'équation mathématique dynamique
    finalCode = finalCode .. "    local real_index = 1;\n"
    finalCode = finalCode .. "    for i = 1, #raw_data do\n"
    finalCode = finalCode .. "        local entry = raw_data[i];\n"
    finalCode = finalCode .. "        local val = tonumber(entry);\n"
    finalCode = finalCode .. "        if val then\n" -- Si c'est un nombre (pas du bruit)
    finalCode = finalCode .. "            -- Inversion de l'équation : Byte = (Chiffré - (real_index * 2) - 10)\n"
    finalCode = finalCode .. "            local original = val - (real_index * 2) - 10;\n"
    finalCode = finalCode .. "            table.insert(" .. outputTableName .. ", string.char(original));\n"
    finalCode = finalCode .. "            real_index = real_index + 1;\n"
    finalCode = finalCode .. "        else\n"
    finalCode = finalCode .. "             -- Gestion du bruit : Junk mathématique aléatoire\n"
    finalCode = finalCode .. "             decoy_math[2] = decoy_math[2] + decoy_math[1];\n"
    finalCode = finalCode .. "        end;\n"
    finalCode = finalCode .. "    end;\n"
    
    finalCode = finalCode .. "    return table.concat(" .. outputTableName .. ");\n"
    finalCode = finalCode .. "end;\n\n"

    -- MASQUAGE DE LOADSTRING (Utilisation de getfenv et byte-assembly)
    finalCode = finalCode .. "local l,o,a,d,s,t,r,i,n,g_ = 108,111,97,100,115,116,114,105,110,103;\n"
    finalCode = finalCode .. "local " .. finalExecName .. " = getfenv()[string.char(l,o,a,d,s,t,r,i,n,g_)]( " .. mainDecoderName .. "() );\n"
    finalCode = finalCode .. "if " .. finalExecName .. " then " .. finalExecName .. "() end;\n"

    return finalCode
end

return RivObfuscator
