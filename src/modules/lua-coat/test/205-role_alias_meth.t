#!/usr/bin/env lua

require 'Coat.Role'

role 'Foo'

local function m1 (self)
    return "m1"
end

method.m1 = m1

function method:m2 ()
    return m1(self) .. "m2"
end

class 'A'
with 'Foo'

class 'B'
with( 'Foo', { alias = { m1 = 'foo_m1', m2 = 'foo_m2' } } )

class 'C'
with( 'Foo', { alias = { m1 = 'foo_m1', m2 = 'foo_m2' },
               excludes = { 'm1', 'm2' } } )


require 'Test.More'

plan(19)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 205.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

a = A.new()
ok( a:isa 'A', "A" )
ok( a.m1 )
ok( a.m2 )
is( a:m1(), 'm1' )
is( a:m2(), 'm1m2' )

b = B.new()
ok( b:isa 'B', "B" )
ok( b.m1 )
ok( b.m2 )
ok( b.foo_m1 )
ok( b.foo_m2 )
is( b:m1(), 'm1' )
is( b:m2(), 'm1m2' )

c = C.new()
ok( c:isa 'C', "C" )
is( c.m1, nil )
is( c.m2, nil )
ok( c.foo_m1 )
ok( c.foo_m2 )
is( c:foo_m1(), 'm1' )
is( c:foo_m2(), 'm1m2' )

