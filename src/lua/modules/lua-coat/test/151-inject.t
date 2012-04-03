#!/usr/bin/env lua

require 'Coat'
require 'Coat.Role'

role 'Log'

abstract 'Service'
has.logger = { is = 'ro', does = 'Log', inject = true }

class 'Logger'
with 'Log'

class 'ServiceImpl1'
extends 'Service'
bind.Log = 'Logger'

class 'ServiceImpl2'
extends 'Service'
bind.Log = Logger

class 'ServiceImpl3'
extends 'Service'
bind.Log = function ()
    return Logger.new{}
end


require 'Test.More'

plan(17)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 151.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = ServiceImpl1()
ok( foo:isa 'ServiceImpl1', "ServiceImpl1" )
ok( foo:isa 'Service' )
ok( foo.logger:isa 'Logger' )
ok( foo.logger:does 'Log' )

foo = ServiceImpl2()
ok( foo:isa 'ServiceImpl2', "ServiceImpl2" )
ok( foo:isa 'Service' )
ok( foo.logger:isa 'Logger' )
ok( foo.logger:does 'Log' )

foo = ServiceImpl3()
ok( foo:isa 'ServiceImpl3', "ServiceImpl3" )
ok( foo:isa 'Service' )
ok( foo.logger:isa 'Logger' )
ok( foo.logger:does 'Log' )

error_like([[ServiceImpl1.bind.Log = {}]],
           "bad argument #2 to bind %(function or string or Class expected%)")

error_like([[ServiceImpl1.bind.Log = 'Unknown']],
           "module 'Unknown' not found")

error_like([[ServiceImpl1.bind.Log = 'Logger']],
           "Duplicate binding of Log")

class 'ServiceImpl4'
extends 'Service'
error_like([[local foo = ServiceImpl4(); local logger = foo.logger]],
           "No binding found for Log in class ServiceImpl4")

error_like([[Service.has.tracer = { is = 'ro', isa = 'Tracer', inject = true }]],
           "The inject option requires a does option")
