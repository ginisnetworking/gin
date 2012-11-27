
local encoder = { }

-- new encoder/decoder -------------------------------------------------------

function encoder:new (type) 
    local type = type or "gencoder"
	local status, lib = pcall (require, type)
	if (not status) then error("encoder: could not load encoder for type '"..type.."': ".. lib) end	
	return lib:new()   
end

return encoder