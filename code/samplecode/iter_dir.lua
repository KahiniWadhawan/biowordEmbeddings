-- Lua implementation of PHP scandir function
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    --print("processing doc ")
    --print(i)
    local pfile = popen('ls "'..directory..'"')
    print(pfile:lines())
    for filename in pfile:lines() do
        --i = i + 1
        file_path = directory..filename
        print(file_path)
        --t[i] = filename
    end
    pfile:close()
    --print(t)
    return t
end

scandir('/Users/kahiniwadhawan/Dropbox/MSthesis/KahiniCode/data/tokenizedFiles/TextWinTokenFiles/')
