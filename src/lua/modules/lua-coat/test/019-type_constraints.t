#!/usr/bin/env lua

require 'Coat'
require 'Coat.Types'

class 'NumberFactory'

subtype.Natural = {
    as = 'number',
    where = function (n) return n > 0 end,
    message = "%d is not a Natural number",
}

subtype.MyApp.Month = {
    as = 'Natural',
    where = function (n) return n <= 12 end,
    message = "%d is not a month"
}

subtype.MyApp.MyMod.WinterMonth = {
    as = 'MyApp.Month',
    where = function (n) return n >= 10 end,
    message = "%d is not a month of winter"
}

enum.MyApp.Colour = { 'Red', 'Green', 'Blue' }

has.n = { is = 'rw', isa = 'Natural' }
has.f = { is = 'rw', isa = 'number' }
has.month = { is = 'rw', isa = 'MyApp.Month' }
has.winter = { is = 'rw', isa = 'MyApp.MyMod.WinterMonth' }
has.col = { is = 'rw', isa = 'MyApp.Colour' }

require 'Test.More'

plan(21)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 019.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

factory = NumberFactory()
factory.n = 24
is( factory.n , 24, "Natural" )
error_like([[local factory = NumberFactory(); factory.n = "text"]],
           "Invalid type for attribute 'n' %(got string, expected number%)")
error_like([[local factory = NumberFactory(); factory.n = 0]],
           "0 is not a Natural number")

factory.f = 2.0
is( factory.f, 2.0, "Float" )
error_like([[local factory = NumberFactory(); factory.f = "text"]],
           "Invalid type for attribute 'f' %(got string, expected number%)")

factory.month = 1
is( factory.month, 1, "Month" )
factory.month = 12
is( factory.month, 12 )
error_like([[local factory = NumberFactory(); factory.month = 0]],
           "0 is not a Natural number")
error_like([[local factory = NumberFactory(); factory.month = 14]],
           "14 is not a month")

factory.winter = 12
is( factory.winter, 12, "WinterMonth" )
error_like([[local factory = NumberFactory(); factory.winter = 0]],
           "0 is not a Natural number")
error_like([[local factory = NumberFactory(); factory.winter = 14]],
           "14 is not a month")
error_like([[local factory = NumberFactory(); factory.winter = 8]],
           "8 is not a month of winter")

factory.col = 'Red'
is( factory.col, 'Red', "Colour" )
factory.col = 'Green'
is( factory.col, 'Green' )
factory.col = 'Blue'
is( factory.col, 'Blue' )
error_like([[local factory = NumberFactory(); factory.col = 'Yellow']],
           "Value for attribute 'col' does not validate type constraint 'MyApp.Colour'")
error_like([[local factory = NumberFactory(); factory.col = 'Blu']],
           "Value for attribute 'col' does not validate type constraint 'MyApp.Colour'")

error_like([[enum.Alone = { 'One' }]],
           "You must have at least two values to enumerate through")

error_like([[enum.Natural = { 'One', 'Two' }]],
           "Duplicate definition of type Natural")

error_like([[subtype.Natural = { as = 'string', where = function (s) return s == 'natural' end }]],
           "Duplicate definition of type Natural")

