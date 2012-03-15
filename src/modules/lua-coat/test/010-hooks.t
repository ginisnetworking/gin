#!/usr/bin/env lua

require 'Coat'

class 'Parent'

function method:pushelem (elem)
    table.insert( _G.list, elem )
end

class 'Child'
extends 'Parent'

function before:pushelem (elem)
    table.insert( _G.list, 'before1:' .. elem )
end

function before:pushelem (elem)
    table.insert( _G.list, 'before2:' .. elem )
end

function after:pushelem (elem)
    table.insert( _G.list, 'after1:' .. elem )
end

function before:pushelem (elem)
    table.insert( _G.list, 'before3:' .. elem )
end

function after:pushelem (elem)
    table.insert( _G.list, 'after2:' .. elem )
end

function after:pushelem (elem)
    table.insert( _G.list, 'after3:' .. elem )
end

require 'Test.More'

plan(9)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 010.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

p = Parent.new()
ok( p:isa 'Parent', "Simple" )
ok( p.pushelem )
_G.list = {}
p:pushelem 'Coat'
eq_array( _G.list, { 'Coat' } )

c = Child.new()
ok( c:isa 'Child', "Multiple" )
ok( c:isa 'Parent' )
ok( c.pushelem )
_G.list = {}
c:pushelem 'Coat'
eq_array( _G.list, {
        'before3:Coat',
        'before2:Coat',
        'before1:Coat',
                'Coat',
        'after1:Coat',
        'after2:Coat',
        'after3:Coat',
} )

error_like([[function Child.after:push_elem () end]],
           "Cannot after non%-existent method push_elem in class Child")

error_like([[function Child.before:push_elem () end]],
           "Cannot before non%-existent method push_elem in class Child")

