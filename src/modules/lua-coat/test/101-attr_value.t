#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.attr = { is = 'rw' }

require 'Test.More'

plan(5)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 101.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new()
is( foo.attr, nil )
foo.attr = 2
is( foo.attr, 2 )
foo.attr = false
is( foo.attr, false )
foo.attr = nil
is( foo.attr, nil )

foo = Foo.new{ attr = function () return 42 end }
is( foo.attr, 42 )
