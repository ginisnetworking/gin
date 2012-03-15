#!/usr/bin/env lua

require 'Coat'
require 'Coat.Types'
require 'Coat.file'

class 'Foo'

has.log = { is = 'rw', isa = 'file' }

class 'Bar'

subtype.OpenedFile = {
    as = 'file',
    where = function (f) return io.type(f) == 'file' end,
}

has.log = { is = 'rw', isa = 'OpenedFile' }


require 'Test.More'

plan(6)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 141.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

f = io.tmpfile()
type_ok( f, 'userdata', "file is a userdata" )
is( io.type(f), 'file' )
foo = Foo.new{ log = f }
ok( foo:isa 'Foo', "isa" )

bar = Bar.new{ log = f }
ok( bar:isa 'Bar', "isa" )
f:close()
is( io.type(f), 'closed file' )
error_like(function () baz = Bar.new{ log = f } end,
           "Value for attribute 'log' does not validate type constraint 'OpenedFile'")


