#!/usr/bin/env lua

require 'Coat'

class 'Spanish'

function method.uno ()
    return 1
end

function method.dos ()
    return 2
end

has.nombre = { is = 'rw', isa = 'string' }

class 'English'
has.translate = {
    is = 'ro',
    default = function () return Spanish.new() end,
    handles = {
        one = 'uno',
        two = 'dos',
        _get_name = '_get_nombre',
        _set_name = '_set_nombre',
        bad = '_bad_',
        '_bad', -- equiv: _bad = '_bad'
    },
}

require 'Test.More'

plan(16)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 027.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Spanish.new()
ok( foo:isa "Spanish", "Spanish" )
ok( foo.uno )
is( foo:uno(), 1 )
ok( foo.dos )
is( foo:dos(), 2 )
foo.nombre = 'Juan'
is( foo.nombre, 'Juan' )

foo = English.new()
ok( foo:isa 'English', "English" )
ok( foo.translate:isa 'Spanish')
ok( foo.one )
is( foo:one(), 1 )
ok( foo.two )
is( foo:two(), 2 )
foo.name = 'John'
is( foo.name, 'John' )
ok( foo.bad )

error_like([[local foo = English.new(); foo:bad()]],
           "Cannot delegate bad from translate %(_bad_%)")

error_like([[local foo = English.new(); foo:_bad()]],
           "Cannot delegate _bad from translate %(_bad%)")

