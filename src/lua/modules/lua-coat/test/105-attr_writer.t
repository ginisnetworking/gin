#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.bar = { is = 'rw' }

require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 105.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new{ bar = 1 }
ok( foo:isa 'Foo', "Foo" )
is( foo.bar, 1 )
is( foo:_set_bar(3), 3 )
is( foo:_get_bar(), 3 )
is( foo.bar, 3 )
is( foo:_set_bar(nil), nil )
is( foo:_get_bar(), nil )
is( foo.bar, nil )

