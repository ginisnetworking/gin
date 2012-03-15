#!/usr/bin/env lua

require 'Coat'

abstract 'Parent'

has.bar = { is = 'rw' }

class 'Child'
extends 'Parent'

has.baz = { is = 'rw' }

require 'Test.More'

plan(6)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 122.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

child = Child.new{ bar = 1, baz = 2 }
ok( child:isa 'Child', "Child" )
ok( child:isa 'Parent' )
is( child.bar, 1 )
is( child.baz, 2 )

error_like([[local parent = Parent.new()]],
           "Cannot instanciate an abstract class Parent")

error_like([[local parent = Parent()]],
           "Cannot instanciate an abstract class Parent")
