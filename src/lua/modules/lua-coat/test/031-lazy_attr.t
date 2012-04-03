#!/usr/bin/env lua

require 'Coat'

class 'A'
has.x = { isa = 'number', is = 'rw', lazy = true, default = 2 }
has.y = { isa = 'number', is = 'rw', default = 2 }

class 'Foo'
has.dir = { is = 'rw', isa = 'string' }
has.name = { is = 'rw', isa = 'string' }
has.path = { is = 'rw', isa = 'string', lazy = true,
    default = function (self)
        return self.dir .. '/' .. self.name
    end,
}

require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 031.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

a = A.new()
ok( a:isa 'A', "A" )
is( a._VALUES.x, nil )
is( a._VALUES.y, 2 )
is( a.x, 2 )

error_like([[A.has.z = { isa = 'number', is = 'rw', lazy = true }]],
           "The lazy option implies the builder or default option",
           "bad")

foo = Foo.new{ dir = '/tmp', name = 'file' }
ok( foo:isa 'Foo', "Foo" )
is( foo.name , 'file' )
is( foo.path, '/tmp/file' )

