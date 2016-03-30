-- Used to escape "'s by toCSV
function escapeCSV (s)
    if string.find(s, '[,"]') then
        s = '"' .. string.gsub(s, '"', '""') .. '"'
    end
    return s
end

-- Convert from CSV string to table (converts a single line of a CSV file)
function fromCSV (s)
    s = s .. ','        -- ending comma
    local t = {}        -- table to collect fields
    local fieldstart = 1
    repeat
        -- next field is quoted? (start with `"'?)
        if string.find(s, '^"', fieldstart) then
            local a, c
            local i  = fieldstart
            repeat
                -- find closing quote
                a, i, c = string.find(s, '"("?)', i+1)
            until c ~= '"'    -- quote not followed by quote?
            if not i then error('unmatched "') end
            local f = string.sub(s, fieldstart+1, i-1)
            table.insert(t, (string.gsub(f, '""', '"')))
            fieldstart = string.find(s, ',', i) + 1
        else                -- unquoted; find next comma
        local nexti = string.find(s, ',', fieldstart)
        table.insert(t, string.sub(s, fieldstart, nexti-1))
        fieldstart = nexti + 1
        end
    until fieldstart > string.len(s)
    return t
end

-- Convert from table to CSV string
function toCSV (tt)
    local s = ""
    -- ChM 23.02.2014: changed pairs to ipairs
    -- assumption is that fromCSV and toCSV maintain data as ordered array
    for _,p in ipairs(tt) do
        s = s .. "," .. escapeCSV(p)
    end
    return string.sub(s, 2)      -- remove first comma
end


--function write(path, data, sep)
--    sep = sep or ','
--    local file = assert(io.open(path, "w"))
--
--    for i=1,#data do
--        for j=1,#data[i] do
--            if j>1 then file:write(sep) end
--            file:write(data[i][j])
--        end
--        file:write('\n')
--    end
--    file:close()
--end

function write(path, data, sep)
    sep = sep or ','
    local file = assert(io.open(path, "w"))

    for i=1,#data do
        file:write(data[i])
        file:write('\n')
    end
    file:close()
end



tt = {}
for i=1,10 do
    table.insert(tt,i,'i')
end

print(tt)
--print(type(toCSV(tt)))

print(#tt[1])
write("data/csv2.csv",tt)