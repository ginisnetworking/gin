#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.read = { is = 'ro', isa = 'number' }
has.write = { is = 'rw', default = 3, isa = 'number' }
has.reset = { is = 'ro', reset = true }

require 'Test.More'

plan(22)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 014.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new{ read = 4, write = 5, reset = 7 }
is( foo.read, 4, "Foo" )
is( foo.write, 5 )
foo.write = 7
is( foo.write, 7 )
is( foo.reset, 7 )
foo.reset = nil
is( foo.reset, nil)
foo.reset = 12
is( foo.reset, 12 )

error_like([[local foo = Foo.new{ read = 4, write = 5, reset = 7 }; foo.read = 5]],
           "Cannot set a read%-only attribute %(read%)")

error_like([[local foo = Foo.new{ read = 4, write = 5, reset = 7 }; foo.read = nil]],
           "Cannot set a read%-only attribute %(read%)")

error_like([[local foo = Foo.new{ read = 4, write = 5, reset = 7 }; foo.reset = 12]],
           "Cannot set a read%-only attribute %(reset%)")

foo = Foo.new()
is( foo.read, nil, "Foo (default)" )
foo.read = 2
is( foo.read, 2 )
is( foo.write, 3 )
foo.write = 7
is( foo.write, 7 )
foo.reset = 7
is( foo.reset, 7 )
foo.reset = nil
is( foo.reset, nil )
foo.reset = 12
is( foo.reset, 12 )

error_like([[local foo = Foo.new(); foo.read = 2; foo.read = 5]],
           "Cannot set a read%-only attribute %(read%)")

error_like([[local foo = Foo.new(); foo.read = 2; foo.read = nil]],
           "Cannot set a read%-only attribute %(read%)")

error_like([[local foo = Foo.new(); foo.reset = 7; foo.reset = 12]],
           "Cannot set a read%-only attribute %(reset%)")

error_like([[local foo = Foo.new(); foo.bad = 5]],
           "Cannot set 'bad' %(unknown%)")

is( foo.bad, nil )

error_like([[Foo.has.field = { is = 'ro', reset = true, required = true }]],
           "The reset option is incompatible with required option")

