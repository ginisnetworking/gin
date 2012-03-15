#!/usr/bin/env lua

require 'Coat'

class 'Parent'
has.foo = { is = 'rw' }
function method:bar () return 'bar' end
function method:baz () return 'baz' end

class 'Child'
extends 'Parent'
function override:bar () return 'BAR' end

require 'Test.More'

plan(15)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 102.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

p = Parent.new()
ok( p:isa 'Parent', "Parent" )
ok( p.bar )
ok( p.baz )
is( p:bar(), 'bar' )
is( p:baz(), 'baz' )

c = Child.new()
ok( c:isa 'Child', "Child" )
ok( c:isa 'Parent' )
ok( c.bar )
ok( c.baz )
is( c:bar(), 'BAR' )
is( c:baz(), 'baz' )

error_like([[Child.override.biz = function (self) return 'BIZ' end]],
           "Cannot override non%-existent method biz in class Child",
           "bad 1")

error_like([[Child.method.baz = function (self) return 'baz' end]],
           "Duplicate definition of method baz",
           "bad 2")

error_like([[Parent.method.baz = function (self) return 'baz' end]],
           "Duplicate definition of method baz",
           "bad 3")

error_like([[Child.method.foo = function () end]],
           "Overwrite definition of attribute foo",
           "bad 4")

