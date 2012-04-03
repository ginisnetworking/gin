#!/usr/bin/env lua

require 'Coat'

class 'Foo'
has.field_from_foo_string = { is = 'rw', isa = 'string' }
has.field_from_foo_int = { is = 'rw', isa = 'number', default = 1 }

class 'Bar'
extends 'Foo'
has.field_from_bar = { is = 'rw' }

class 'Baz'
extends 'Bar'
has.field_from_baz = { is = 'rw' }
-- we redefine an attribute of an inherited class
has.field_from_foo_int = { '+', default = 2 }

class 'Biz'
has.field_from_biz = { is = 'rw' }

class 'BalBaz'
extends( 'Bar', 'Biz' )

require 'Test.More'

plan(22)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 011.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new()
ok( foo:isa 'Foo', "Foo" )
is( foo.field_from_foo_string, nil )
is( foo.field_from_foo_int, 1 )

bar = Bar.new()
ok( bar:isa 'Bar', "Bar" )
is( bar.field_from_foo_string, nil )
is( bar.field_from_bar, nil )
is( bar.field_from_foo_int, 1 )

baz = Baz.new()
ok( baz:isa 'Baz', "Baz" )
is( baz.field_from_foo_string, nil )
is( baz.field_from_bar, nil )
is( baz.field_from_baz, nil )
is( baz.field_from_foo_int, 2 )

biz = Biz.new()
ok( biz:isa 'Biz', "Biz" )
is( biz.field_from_biz, nil )

bal = BalBaz.new()
ok( bal:isa 'BalBaz', "BalBaz" )
is( bal.field_from_foo_string, nil )
is( bal.field_from_bar, nil )
is( bal.field_from_biz, nil )
is( bal.field_from_foo_int, 1 )

error_like([[Baz.has.no_field = { '+', default = 42 }]],
           "Cannot overload unknown attribute no_field")

error_like([[Baz.has.field_from_bar = { is = 'rw' }]],
           "Duplicate definition of attribute field_from_bar")

function Baz.method:callIt ()
    return true
end
error_like([[Baz.has.callIt = { is = 'rw' }]],
           "Overwrite definition of method callIt")

