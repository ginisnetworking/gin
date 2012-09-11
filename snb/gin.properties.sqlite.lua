#!/usr/bin/env lua

require('lsqlite3')

db = sqlite3.open("example-db.sqlite3")

db:exec[[ CREATE TABLE test (id, content) ]]
stmt = db:prepare[[ INSERT INTO test VALUES (:key, :value) ]]
stmt:bind_values(1,"Hello World")
stmt:step()
stmt:reset()

local s = ""
for row in db:nrows("SELECT * FROM test") do
	s = s .. "Row ID: "..row.id.."\r\nText: ".. row.content.."\r\n\r\n"
end




