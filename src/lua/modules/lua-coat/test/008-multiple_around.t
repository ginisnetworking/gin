#!/usr/bin/env lua

require 'Coat'

class 'Parent'

function method:orig (...)
    local val = ...
    table.insert( _G.seen, 'orig : ' .. val )
    return 1
end

class 'Child'
extends 'Parent'

function around:orig (func, ...)
    local val = ...
    table.insert( _G.seen, 'around 1 before : ' .. val)
    local result = func(self, ...)
    table.insert( _G.seen, 'around 1 after' )
    return result + 1
end

function around:orig (func, ...)
    local val = ...
    table.insert( _G.seen, 'around 2 before : ' .. val)
    local result = func(self, ...)
    table.insert( _G.seen, 'around 2 after' )
    return result + 1
end

require 'Test.More'

plan(9)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 008.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

p = Parent.new()
ok( p:isa 'Parent', "Simple" )
ok( p.orig )
_G.seen = {}
p:orig 'val'
eq_array( _G.seen, { 'orig : val' } )

c = Child.new()
ok( c:isa 'Child', "MultipleAround" )
ok( c:isa 'Parent' )
ok( c.orig )
_G.seen = {}
is( c:orig 'val', 3 )
eq_array( _G.seen, {
        'around 2 before : val',
                'around 1 before : val',
                        'orig : val',
                'around 1 after',
        'around 2 after',
} )

error_like([[function Child.around:_orig_ () end]],
           "Cannot around non%-existent method _orig_ in class Child")

