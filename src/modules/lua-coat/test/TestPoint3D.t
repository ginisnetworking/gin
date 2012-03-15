#!/usr/bin/env lua

require 'Test.More'

plan(31)

if not require_ok 'Point3D' then
    skip_rest "no lib"
    os.exit()
end

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o Point3D.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

a = Point3D{x = 1, y = 2, z = 3}
is( a:type(), 'Point3D', "new" )
ok( a:isa 'Point3D' )
ok( a:isa 'Point' )
type_ok( a.x, 'number', "accessors")
type_ok( a.y, 'number')
type_ok( a.z, 'number')
is( a.x, 1 )
is( a.y, 2 )
is( a.z, 3 )
is( tostring(a), "(1, 2, 3)", "stringify" )

ok( a:can 'draw', "method draw" )
ok( Point:can 'draw' )
type_ok( a.draw, 'function' )
is( a:draw(), "drawing Point3D(1, 2, 3)" )

a = Point3D()
is( a:type(), 'Point3D', "new (default)" )
type_ok( a.x, 'number')
type_ok( a.y, 'number')
type_ok( a.z, 'number')
is( a.x, 0 )
is( a.y, 0 )
is( a.z, 0 )
is( tostring(a), "(0, 0, 0)", "stringify" )

a.x = 1
a.y = 2
a.z = 3
type_ok( a.x, 'number', "mutator")
type_ok( a.y, 'number')
type_ok( a.z, 'number')
is( a.x, 1 )
is( a.y, 2 )
is( a.z, 3 )
is( tostring(a), "(1, 2, 3)", "stringify" )

error_like([[a = Point3D{x = "x", y = "y", z = "z"}]],
           "Invalid type for attribute",
           "new (bad)")

