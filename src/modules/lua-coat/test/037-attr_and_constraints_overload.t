#!/usr/bin/env lua

require 'Coat.Types'

subtype.Positive = {
    as = 'number',
    where = function (n) return n > 0 end
}

subtype.Range10 = {
    as = 'Positive',
    where = function (n) return n < 10 end
}

class 'Parent'
has.name = { is = 'rw', isa = 'string' }
has.lazy_classname = { is = 'ro', lazy = true,
    default = function () return "Parent" end,
}
has.type_constrained = { is = 'rw', isa = 'Positive',
    default = 5.5
}

class 'Child'
extends 'Parent'
has.name = { '+', default = "Junior" }
has.lazy_classname = { '+', default = function () return "Child" end }
has.type_constrained = { '+', isa = 'Range10', default = 7.5 }


require 'Test.More'

plan(17)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 037.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Parent.new()
ok( foo:isa 'Parent', "Parent" )
is( foo.name, nil )
foo.name = 'John'
is( foo.name, 'John' )
is( foo.lazy_classname, 'Parent' )
error_like([[local foo = Parent.new(); foo.lazy_classname = 'Object']],
           "Cannot set a read%-only attribute %(lazy_classname%)")
is( foo.type_constrained, 5.5 )
foo.type_constrained = 10.5
is( foo.type_constrained, 10.5 )
error_like([[local foo = Parent.new(); foo.type_constrained = -0.5]],
           "Value for attribute 'type_constrained' does not validate type constraint 'Positive'")

foo = Child.new()
ok( foo:isa 'Child', "Child" )
ok( foo:isa 'Parent' )
is( foo.name, 'Junior' )
foo.name = 'John'
is( foo.name, 'John' )
is( foo.lazy_classname, 'Child' )
error_like([[local foo = Child.new(); foo.lazy_classname = 'Object']],
           "Cannot set a read%-only attribute %(lazy_classname%)")
is( foo.type_constrained, 7.5 )
foo.type_constrained = 9.5
is( foo.type_constrained, 9.5 )
error_like([[local foo = Child.new(); foo.type_constrained = -0.5]],
           "Value for attribute 'type_constrained' does not validate type constraint 'Positive'")

