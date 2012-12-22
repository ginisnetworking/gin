
require('lsqlite3')
require('sha2')

local ginDatabase = {}

local function hashify(value)
	return sha2.sha256hex(value) -- bintohex(sha2.sha256(value))
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
		self.db:exec("CREATE TABLE objects (key char(64) primary key, value text);")
		self.db:exec("CREATE TABLE associations (tag varchar(255) primary key, hash char(64));")
	else
		self.db = sqlite3.open(self.dbname)
		self.db:exec("CREATE TABLE IF NOT EXISTS objects (key char(64) primary key, value text);")
		self.db:exec("BEGIN; CREATE TABLE IF NOT EXISTS associations (tag varchar(255), hash char(64), UNIQUE(tag, hash)); CREATE INDEX associations_tag_idx ON associations(tag); CREATE INDEX associations_hash_idx ON associations(hash); COMMIT;")
	end

	self.stmtLookup = self.db:prepare([[ SELECT value FROM objects WHERE key like :key ]])

	if (self.db:isopen()) then
		return object
	end

	return nil;
end

function ginDatabase:cleanup()
	self.stmtLookup:finalize()
end

-- hos: hash or string
function ginDatabase:get(hos)
	assert(hos) -- key can't be nil
	assert(self.db)
	assert(self.stmtLookup)
	self.stmtLookup:bind_values(hos)
	if (self.stmtLookup:step() == sqlite3.ROW) then
		return self.stmtLookup:get_uvalues() -- This function returns a list with the values of all columns in the current result row of a query.
	end
	return nil
end

function ginDatabase:put(value)
	assert(value)
	assert(self.db)
	local key  = hashify(value)
	local stmt = self.db:prepare[[ INSERT INTO objects VALUES (:key, :value) ]]
	stmt:bind_values(key, value)
	return stmt:step() -- if return not equal to sqlite3.DONE, an error occurred
end

function ginDatabase:associate(tag, key)
	assert(tag)
	assert(key)
	assert(self.db)
	local stmt = self.db:prepare[[ INSERT INTO associations VALUES (:tag, :key) ]]
	stmt:bind_values(tag, key)
	return stmt:step() -- if return not equal to sqlite3.DONE, an error occurred
end

function ginDatabase:search(substring)
	assert(substring) -- key can't be nil
	assert(self.db)
	return nil
end

--[[
hash_teste = hashify("teste");
cache = ginDatabase:new("cache", true)
objdb = ginDatabase:new("objects")

cache:put("teste")
print(objdb:put("teste"))
print(objdb.db:errmsg())

print(cache:get(hash_teste))
print(objdb:get(hash_teste))

print(objdb:associate("Tag de exemplo", hash_teste))
print(objdb.db:errmsg())

objdb:cleanup();
cache:cleanup();
]]