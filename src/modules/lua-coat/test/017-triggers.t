#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.baz = { is = 'rw' }
has.bar = {
    is = 'rw',
    trigger = function (self, value)
                  self.baz = value
              end,
}

require 'Test.More'

plan(5)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 017.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new{ baz = 42 }
ok( foo:isa 'Foo', "Foo" )
is( foo.baz, 42 )
foo.bar = 33
is( foo.bar, 33 )
is( foo.baz, 33 )

error_like([[Foo.has.badtrig = { isa = 'number', trigger = 2 }]],
           "The trigger option requires a function",
           "bad trigger")

