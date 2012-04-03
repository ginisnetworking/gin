#!/usr/bin/env lua

require 'Coat'

class 'Foo'
has.cntCall = { is = 'rw', default = 0 }

function overload:__tostring ()
    return self._CLASS
end

function method:sum (...)
    self.cntCall = self.cntCall + 1
    local arg = {...}
    local res = 0
    for i = 1, #arg do res = res + arg[i] end
    return res
end


require 'Test.More'

plan(17)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 161.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo()
ok( foo:isa 'Foo', "Foo" )
is( foo.cntCall, 0 )
is( foo:sum(1, 2), 3 )
is( foo.cntCall, 1 )
is( foo:sum(1, 2), 3 )
is( foo.cntCall, 2 )
Foo.memoize "sum"
is( foo:sum(1, 2), 3 )
is( foo.cntCall, 3 )
is( foo:sum(1, 2), 3 )
is( foo.cntCall, 3 )
is( foo:sum(1, 2, 3), 6 )
is( foo.cntCall, 4 )
is( foo:sum(1, 2, 3), 6 )
is( foo.cntCall, 4 )

local n = 0
for k, v in pairs(require 'Coat.Meta.Class'._CACHE) do
    diag(k .. " -> " .. v)
    n = n + 1
end
is( n, 2 )

error_like([[Foo.memoize {}]],
           "bad argument #1 to memoize %(string expected, got table%)")

error_like([[Foo.memoize 'add']],
           "Cannot memoize non%-existent method add in class Foo")


