#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.x = { is = 'rw', required = true }
has.y = { is = 'rw', isa = 'number' }
has.z = { is = 'ro', default = 42 }

class 'Bar'
extends 'Foo'

has.x = { '+', default = 42 }
has.y = { '+', default = 42 }
has.z = { '+', isa = 'number' }

class 'Baz'
extends 'Foo'

has.x = { '+', required = false }
has.y = { '+', isa = 'string' }
has.z = { '+', is = 'rw' }


require 'Test.More'

plan(12)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 106.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo{ x = 0, y = 0 }
ok( foo:isa 'Foo', "Foo" )
is( foo.x, 0 )
is( foo.y, 0 )
is( foo.z, 42 )

bar = Bar{}
ok( bar:isa 'Bar', "Bar" )
ok( bar:isa 'Foo' )
is( bar.x, 42 )
is( bar.y, 42 )
is( bar.z, 42 )

error_like([[baz = Baz()]],
           "Attribute 'x' is required",
           "required")

error_like([[baz = Baz{ x = 0, y = 'text' }]],
           "Invalid type for attribute 'y' %(got string, expected number%)",
           "isa")

error_like([[baz = Baz{ x = 0 }; baz.z = 0]],
           "Cannot set a read%-only attribute %(z%)",
           "ro")

