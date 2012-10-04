#!/env/bin lua

json = require("json")
print (json.encode( json.decode( json.encode( { 1, 2, 'fred', {first='mars',second='venus',third='earth'} } ))))
