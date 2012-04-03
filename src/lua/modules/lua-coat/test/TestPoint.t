#!/usr/bin/env lua

require 'Test.More'

plan(29)

if not require_ok 'Point' then
    skip_rest "no lib"
    os.exit()
end

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o Point.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

a = Point{x = 1, y = 2}
is( a:type(), 'Point', "new" )
ok( a:isa 'Point' )
type_ok( a._get_x, 'function', "accessors" )
type_ok( a._get_y, 'function' )
type_ok( a._set_x, 'function' )
type_ok( a._set_y, 'function' )
type_ok( a.x, 'number')
type_ok( a.y, 'number')
is( a.x, 1 )
is( a.y, 2 )
is( tostring(a), "(1, 2)", "stringify" )

ok( a:can 'draw', "method draw" )
ok( Point:can 'draw' )
type_ok( a.draw, 'function' )
is( a:draw(), "drawing Point(1, 2)" )

a = Point()
is( a:type(), 'Point', "new (default)" )
type_ok( a.x, 'number')
type_ok( a.y, 'number')
is( a.x, 0 )
is( a.y, 0 )
is( tostring(a), "(0, 0)", "stringify" )

a.x = 1
a.y = 2
type_ok( a.x, 'number', "mutator")
type_ok( a.y, 'number')
is( a.x, 1 )
is( a.y, 2 )
is( tostring(a), "(1, 2)" )
error_like([[a.x = "number expected"]],
           "Invalid type for attribute",
           "check type")

error_like([[a = Point{x = "x", y = "y"}]],
           "Invalid type for attribute",
           "new (bad)")

