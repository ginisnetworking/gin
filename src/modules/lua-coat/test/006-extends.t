#!/usr/bin/env lua

require 'Coat'

class 'MyItem'

has.name = { is = 'rw', isa = 'string' }

class 'MyItem3D'

extends( 'Point3D', MyItem )

require 'Test.More'

plan(19)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 006.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

local mc = require 'Coat.Meta.Class'

point2d = Point.new{ x = 2, y = 4}
is( point2d:type(), 'Point', "Point" )
ok( point2d:isa 'Point' )
nok( mc.has( Point, 'z' ) )

point3d = Point3D.new{ x = 1, y = 3, z = 1}
is( point3d:type(), 'Point3D', "Point3D" )
ok( point3d:isa 'Point3D' )
ok( mc.has( Point3D, 'z' ) )

item = MyItem3D.new{ name = 'foo', x = 4, z = 3 }
is( item:type(), 'MyItem3D', "MyItem3D" )
ok( item:isa 'MyItem3D' )
ok( item:isa 'Point3D' )
ok( item:isa 'MyItem' )
is( item.x, 4 )
is( item.y, 0 )
is( item.z, 3 )
is( item.name, 'foo' )
is( item:dump(), [[
obj = MyItem3D {
  name = "foo",
  x = 4,
  y = 0,
  z = 3,
}]], "dump" )

t = {}
for k in pairs(item) do
    t[#t+1] = k
end
table.sort(t)
if _VERSION == 'Lua 5.1' then
    todo("__pairs only with Lua 5.2", 1)
end
is( table.concat(t, ','), 'name,x,y,z', "__pairs" )

error_like([[MyItem3D.extends {}]],
           "bad argument #1 to extends %(string or Class expected%)")

error_like([[MyItem.extends 'MyItem3D']],
           "Circular class structure between 'MyItem' and 'MyItem3D'")

error_like([[class 'MyItem3D']],
           "name conflict for module 'MyItem3D'")

