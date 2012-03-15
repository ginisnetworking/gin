#!/usr/bin/env lua

require 'Coat'

class 'Foo'
has.bar = { is = 'ro', required = true }
has.baz = { is = 'rw', default = 100, required = true }
has.boo = { is = 'rw', lazy = true, default = 50, required = true }
has.subobject = { isa = 'Bar' }

require 'Test.More'

plan(13)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 016.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new{ bar = 10, baz = 20, boo = 100 }
ok( foo:isa 'Foo', "Foo1" )
is( foo.bar, 10 )
is( foo.baz, 20 )
is( foo.boo, 100 )

foo = Foo.new{ bar = 10, boo = 5 }
ok( foo:isa 'Foo', "Foo2" )
is( foo.bar, 10 )
is( foo.baz, 100 )
is( foo.boo, 5 )

foo = Foo.new{ bar = 10 }
ok( foo:isa 'Foo', "Foo3" )
is( foo.bar, 10 )
is( foo.baz, 100 )
is( foo.boo, 50 )

error_like([[foo = Foo.new()]],
           "Attribute 'bar' is required",
           "Foo4")

