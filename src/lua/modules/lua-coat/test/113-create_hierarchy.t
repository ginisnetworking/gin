#!/usr/bin/env lua

require 'Coat.Role'

class 'MyApp.Foo.Bar'
has.baz = { is = 'rw' }

require 'Test.More'

plan(2)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 113.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = MyApp.Foo.Bar.new()
ok( foo:isa 'MyApp.Foo.Bar' )
foo.baz = 'baz'
is( foo.baz, 'baz' )

