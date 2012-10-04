#!/env/bin lua

bencode = require("bencode")
print (bencode.encode( bencode.decode( bencode.encode( { 1, 2, 'fred', {first='mars',second='venus',third='earth'} } ))))
