-- 在此修改你需要转的JSON文件
-- 输出文件名为相同路径下的.lua文件
-- 如 :
-- path = '/Users/KelvinMan/Desktop/pets.json'
-- 输出文件为 '/Users/KelvinMan/Desktop/pets.json.lua'

local function split(str,sep)
    if type(str) ~= 'string' then 
        return nil 
    end
    local sep, fields = sep or "\t", {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str,pattern,function(c)
        fields[#fields+1] = c
    end)
    return fields
end

local function analyse(val,lv)

	lv = lv or 0
	
	local t_ = ''
	for i = 1, lv do
		t_ = t_..'\t'
	end

	local str_ = '{'
	
	for k,v in pairs(val) do
	
		local keystr_ = nil
		local valstr_ = nil
		-- 处理key
		if type(k) == 'string' then
			keystr_ = '\''..k..'\''
		else
			keystr_ = tostring(k)
		end
		-- 处理val
		if type(v) == 'table' then
			valstr_ = analyse(v,lv+1)
		elseif type(v) == 'string' then
			valstr_ = '\''..v..'\''	
		elseif type(v) == 'userdata' then
			valstr_ = '\'userdata\''	
		else
			valstr_ = tostring(v)		
		end
		
		str_ = str_..'\n'..t_..'\t['..keystr_..']='..valstr_..','
	end
	str_ = str_..'\n'..t_..'}'
	return str_
end

cjson = require('cjson')



file = io.open(path,'r')
local string_ = file:read('*a')
assert(string_,'can not read '..path)
file:close()
string_ = analyse(cjson.decode(string_))

local arr_ = split(path,'/')
arr_ = split(arr_[#arr_],'.')
local name = arr_[1]
string_ = 'local '..name..' = '..string_..'\nreturn '..name
path = path..'.lua'
file = io.output(path)
if file then
	file:write(string_)
	print('write success '..path)
	file:close()
	local fun_ = loadfile(path)
	assert(fun_,'check loadfile fail!')
	local ret,errMsg = pcall(fun_)
    if not ret then
        print('call fun error '..errMsg)
    else
		if type(errMsg) == 'table' then
			print('call success')
		else
			print('error table type is '..type(errMsg))
		end
    end
else
	print('can not write '..path)
end
