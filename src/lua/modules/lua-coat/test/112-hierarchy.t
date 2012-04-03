#!/usr/bin/env lua

require 'Coat.Role'

role 'MyApp.Biz'

class 'MyApp.Bar'

class 'MyApp.Bar.Foo'
with 'MyApp.Biz'
has.bar = { is = 'rw' }

class 'MyApp.Baz'

class 'MyApp.Baz.Foo'
with 'MyApp.Biz'
has.baz = { is = 'rw' }

require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 112.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

bar = MyApp.Bar.new()
ok( bar:isa 'MyApp.Bar', "MyApp.Bar" )

foo = MyApp.Bar.Foo.new()
ok( foo:isa 'MyApp.Bar.Foo', "MyApp.Bar.Foo" )
ok( foo:does 'MyApp.Biz' )
foo.bar = 'bar'
is( foo.bar, 'bar' )

foo = MyApp.Baz.new()
ok( foo:isa 'MyApp.Baz', "MyApp.Baz" )

foo = MyApp.Baz.Foo.new()
ok( foo:isa 'MyApp.Baz.Foo', "MyApp.Baz.Foo" )
ok( foo:does 'MyApp.Biz' )
foo.baz = 'baz'
is( foo.baz, 'baz' )

