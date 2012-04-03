#!/usr/bin/env lua

require 'Coat'

class 'Foo'
has.x = { is = 'rw', isa = 'number' }
has.s = { is = 'rw', isa = 'string' }
has.c = { is = 'rw', isa = 'function' }
has.subobject = { is = 'rw', isa = 'Bar' }

class 'Bar'
has.x = { is = 'rw' }

class 'Baz'

require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 013.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new()
foo.x = 43
is( foo.x, 43 )
foo.s = "text"
is( foo.s, "text" )
foo.c = function () return 3 end
is( foo.c(), 3 )
foo.subobject = Bar.new()
ok( foo.subobject:isa 'Bar' )

error_like([[local foo = Foo.new(); foo.x = "text"]],
           "Invalid type for attribute 'x' %(got string, expected number%)")

error_like([[local foo = Foo.new(); foo.s = 2]],
           "Invalid type for attribute 's' %(got number, expected string%)")

error_like([[local foo = Foo.new(); foo.c = 2]],
           "Invalid type for attribute 'c' %(got number, expected function%)")

error_like([[local foo = Foo.new(); foo.subobject = Baz.new()]],
           "Invalid type for attribute 'subobject' %(got Baz, expected Bar%)")

