
require('lsqlite3')

local ginDatabase = {}


--[[
cache = ginDatabase:new("cache", true)
objdb = ginDatabase:new("objects")

cache:put("teste")
objdb:put("zocrap")
print(cache:get("teste"))
print(objdb:get("teste"))
]]

local function hashify(value)
	return "teste"
end

function ginDatabase:new(database, inMemory)
	assert(database)
	if (inMemory == nil) then
		inMemory = false
	end
	local object = setmetatable({}, self) -- create new obj
	self.__index = self
	self         = object -- new object is the new self

	self.dbname = database
	if (inMemory) then
		self.db = sqlite3.open_memory()
		self.db:exec("CREATE TABLE objects (key varchar(255) primary key, value text);")
	else
		self.db = sqlite3.open(self.dbname)
		self.db:exec("CREATE TABLE IF NOT EXISTS objects (key varchar(255) primary key, value text);")
	end

	if (self.db:isopen()) then
		return object
	end
	return nil;
end

-- hos: hash or string
function ginDatabase:get(hos)
	assert(hos) -- key can't be nil
	assert(self.db)
	local r = nil
	local stmt = self.db:prepare([[ SELECT value FROM objects WHERE key = "]] .. hos .. [["]])
	local stmtStatus = stmt:step()
	if (stmtStatus == sqlite3.ROW) then
		r = stmt:get_uvalues() -- This function returns a list with the values of all columns in the current result row of a query.
		stmt:finalize() -- This function frees prepared statement stmt.
	end
	return r
end

function ginDatabase:put(value)
	assert(value)
	assert(self.db)
	local key = hashify(value)
	local stmt = self.db:prepare[[ INSERT INTO objects VALUES (:key, :value) ]]
	stmt:bind_values(key, value)
	return stmt:step() -- if return not equal to sqlite3.DONE, an error occurred
end
