#!/usr/bin/env lua

--[[
sqlite3 gin.properties.sqlite3
SQLite version 3.7.12 2012-05-14 01:41:23
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> CREATE TABLE properties (key varchar(255) primary key, value text);
sqlite> select * from sqlite_master;
table|properties|properties|3|CREATE TABLE properties (key varchar(255) primary key, value text)
index|sqlite_autoindex_properties_1|properties|4|
sqlite> 
]]

require('lsqlite3')

local db = nil

function load(database)
	database = database or [[gin.properties.sqlite3]]
	db = sqlite3.open(database)
	return db
end

-- TODO: check how to convert key for use in bind_values - bad argument #1 to 'bind_values' (:sqlite3:vm expected, got number)
function getProperty(key)
	assert (key) -- key can't be nil
	db = db or load()
--	local stmt = db:prepare([[ SELECT content FROM test WHERE id = ?]])
--	out = stmt.bind_values(key)
--	stmt:step()
	local stmt = db:prepare([[ SELECT value FROM properties WHERE key = "]] .. key .. [["]])
	stmt:step() -- This function must be called to evaluate the (next iteration of the) prepared statement stmt.
	local r = stmt:get_uvalues() -- This function returns a list with the values of all columns in the current result row of a query.
	stmt:finalize() -- This function frees prepared statement stmt.
	return r
end

function setProperty(key, val)
	assert(key)
	assert(val)
	db = db or load()
	local stmt = db:prepare[[ INSERT INTO properties VALUES (:key, :value) ]]
	stmt:bind_values(key, val)
	stmt:step()
	-- stmt:reset() -- This function resets SQL statement stmt, so that it is ready to be re-executed.
end

print( setProperty("teste", "isto é um teste com um acento"))
print( getProperty("teste") )





