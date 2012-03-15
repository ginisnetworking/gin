#!/usr/bin/env lua

require 'Coat'

class 'Person'

has.name = { is = 'rw', isa = 'string' }
has.force = { is = 'rw', isa = 'number', default = 1 }

function method:walk ()
    return self.name .. " walks\n"
end

class 'Soldier'

extends 'Person'

has.force = { '+', default = 3 }

function method:attack ()
    return self.force + math.random( 10 )
end

class 'General'

extends 'Soldier'

has.force = { '+', default = 5 }

require 'Test.More'

plan(29)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 007.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

local mc = require 'Coat.Meta.Class'

man = Person.new{ name = 'John' }
ok( man:isa 'Person', "Person" )
ok( man:isa(Person) )
ok( man:isa(man) )
ok( mc.has( Person, 'name' ) )
ok( mc.has( Person, 'force' ) )
is( man.force, 1 )
ok( man:walk() )

ok( Soldier:isa 'Soldier', "Class Soldier" )
ok( Soldier:isa 'Person' )
ok( Soldier:isa(Person) )
ok( Soldier:isa(man) )

soldier = Soldier.new{ name = 'Dude' }
ok( soldier:isa 'Soldier', "Soldier" )
ok( soldier:isa 'Person' )
ok( soldier:isa(Person) )
ok( soldier:isa(man) )
ok( mc.has( Soldier, 'name' ) )
ok( mc.has( Soldier, 'force' ) )
is( soldier.force, 3 )
ok( soldier:walk() )
ok( soldier:attack() )

general = General.new{ name = 'Smith' }
ok( general:isa 'General', "General" )
ok( general:isa 'Soldier' )
ok( general:isa 'Person' )
ok( mc.has( General, 'name' ) )
ok( mc.has( General, 'force' ) )
is( general.force, 5 )
ok( general:walk() )
ok( general:attack() )

error_like([[man = Person.new{ name = 'John' }; man:isa {}]],
           "bad argument #2 to isa %(string or Object/Class expected%)")

