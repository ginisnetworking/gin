#!/usr/bin/env lua

require 'Coat.Types'

coerce.MyApp.B = { ['MyApp.A'] = function (val) return MyApp.B{ x = 3 } end }

class 'MyApp.A'
has.x = { is = 'rw', isa = 'number' }
has.b = { is = 'rw', isa = 'MyApp.B', coerce = true }
has.c = { is = 'rw', isa = 'MyApp.C' }

class 'MyApp.B'
has.x = { is = 'rw', isa = 'number' }

class 'MyApp.C'
has.x = { is = 'rw', isa = 'number' }

require 'Test.More'

plan(7)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 024.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

a = MyApp.A{ x = 1 }
b = MyApp.B{ x = 2 }
ok( a:isa 'MyApp.A' )
ok( b:isa 'MyApp.B' )
a.b = b
is( a.b.x, 2 )
a.b = a
is( a.b.x, 3 ) -- coerced
is( a:dump(), [[
obj = MyApp.A {
  b = MyApp.B {
    x = 3,
  },
  x = 1,
}]], "dump" )

error_like([[local a = MyApp.A{ x = 1 }; a.c = MyApp.A.new()]],
           "Invalid type for attribute 'c' %(got MyApp.A, expected MyApp.C%)")

error_like([[local a = MyApp.A{ x = 1 }; a.c = "text"]],
           "Invalid type for attribute 'c' %(got string, expected MyApp.C%)")

