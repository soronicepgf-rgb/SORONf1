local RivObfuscator = {}

local function genConfusingName(len)
    local chars = {"O", "0", "l", "I"}
    local name = chars[math.random(3, 4)] -- Commence toujours par l ou I
    for i=2, len do name = name .. chars[math.random(1, #chars)] end
    return name
end

function RivObfuscator.Obfuscate(sourceCode)
    -- Variables principales indéchiffrables
    local vEnv = genConfusingName(8)
    local vData = genConfusingName(10)
    local fDec = genConfusingName(9)
    local fMath = genConfusingName(7)
    
    -- Génération d'un sel mathématique aléatoire
    local salt1 = math.random(1000, 9000)
    local salt2 = math.random(10, 99)
    
    -- 1. Chiffrement Mathématique Lourd
    -- On simule la boucle mathématique que le décodeur devra faire pour trouver la vraie clé
    local runtimeKey = salt1
    for i = 1, 5000 do
        runtimeKey = (runtimeKey * 17 + salt2) % 256
    end
    
    local encryptedBytes = {}
    for i = 1, #sourceCode do
        local byte = string.byte(sourceCode, i)
        -- Chiffrement dynamique basé sur l'index et la clé calculée
        local mutatedByte = (byte + runtimeKey + (i % 10)) % 256
        table.insert(encryptedBytes, tostring(mutatedByte))
    end
    
    local payload = table.concat(encryptedBytes, ",")

    -- 2. Construction du Wrapper Anti-IA
    local out = "-- RIV OBFUSCATOR : NEURAL BLOCKER EDITION\n"
    
    -- L'IA ne verra pas "getfenv", on le reconstruit via son pointeur d'environnement
    out = out .. "local " .. vEnv .. " = getfenv;\n"
    out = out .. "local " .. vData .. " = {" .. payload .. "};\n"
    
    -- Fonction de surcharge mathématique (L'IA va rater ce calcul statique)
    out = out .. "local function " .. fMath .. "(s1, s2)\n"
    out = out .. "    local k = s1;\n"
    out = out .. "    for i = 1, 5000 do k = (k * 17 + s2) % 256 end;\n"
    out = out .. "    return k;\n"
    out = out .. "end;\n"
    
    -- Décodeur
    out = out .. "local function " .. fDec .. "()\n"
    out = out .. "    local env = " .. vEnv .. "();\n"
    -- Reconstitution masquée de "string.char" et "table.concat"
    out = out .. "    local sc = env[string.char(115,116,114,105,110,103)][string.char(99,104,97,114)];\n"
    out = out .. "    local tc = env[string.char(116,97,98,108,101)][string.char(99,111,110,99,97,116)];\n"
    
    out = out .. "    local key = " .. fMath .. "("..salt1..", "..salt2..");\n"
    out = out .. "    local res = {};\n"
    out = out .. "    for i = 1, #" .. vData .. " do\n"
    out = out .. "        local b = tonumber(" .. vData .. "[i]);\n"
    out = out .. "        local orig = (b - key - (i % 10)) % 256;\n"
    out = out .. "        if orig < 0 then orig = orig + 256 end;\n"
    out = out .. "        res[i] = sc(orig);\n"
    out = out .. "    end;\n"
    out = out .. "    return tc(res);\n"
    out = out .. "end;\n"
    
    -- Exécution masquée de loadstring
    out = out .. "local exec = " .. vEnv .. "()[string.char(108,111,97,100,115,116,114,105,110,103)];\n"
    out = out .. "local run = exec(" .. fDec .. "());\n"
    out = out .. "if run then run() end;\n"

    return out
end

return RivObfuscator
