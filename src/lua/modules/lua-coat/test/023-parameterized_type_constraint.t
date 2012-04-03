#!/usr/bin/env lua

require 'Coat'
require 'Coat.Types'

class 'A'

has.array_of_str = { is = 'rw', isa = 'table<string>' }
has.another_array_of_str = { is = 'rw', isa = 'table<string>' }
has.hash_of_a = { is = 'rw', isa = 'table<string,A>' }
has.hash_of_num = { is = 'rw', isa = 'table<string,number>' }
has.many_a = { is = 'rw', isa = 'table<A>' }

class 'B'

has.x = { is = 'rw', isa = 'number' }

require 'Test.More'

plan(14)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 023.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

a = A()
ok( a:isa 'A' )

many_a = {}
for _ = 1, 10 do table.insert(many_a, A() ) end
many_b = {}
for _ = 1, 10 do table.insert(many_b, B() ) end

lives_ok( function () a.many_a = many_a end, "array of objects A accepted" )

error_like(function () a.many_a = many_b end,
           "Value for attribute 'many_a' does not validate type constraint 'table<A>'",
           "array of objects B refused")

lives_ok( function () a.hash_of_a = { one = A(), two = a } end, "hash of A accepted" )

error_like(function () a.hash_of_a = { one = A(), two = B() } end,
           "Value for attribute 'hash_of_a' does not validate type constraint 'table<string,A>'",
           "Hash of mixed A and B objects refused")

error_like(function () a.hash_of_a = 123 end,
           "Invalid type for attribute 'hash_of_a' %(got number, expected table%)",
           "value refused : not a table")

lives_ok(function () a.hash_of_num = { one = 1, two = 2, three = 3 } end, "hash of Num accepted" )

error_like(function () a.hash_of_num = { one = 1, two = 2, three = 'foo' } end,
           "Value for attribute 'hash_of_num' does not validate type constraint 'table<string,number>'",
           "hash mixed of num and str refused")

error_like(function () a.hash_of_num = { one = 1, two = 2, [true] = 3 } end,
           "Value for attribute 'hash_of_num' does not validate type constraint 'table<string,number>'",
           "hash mixed of num and str refused")

lives_ok( function () a.array_of_str = { 'Foo', 'Bar', 'Baz' } end, "array_of_str accepted" )

lives_ok( function () a.another_array_of_str = a.array_of_str end, "copy of array_of_str accepted" )

error_like(function () a.array_of_str = 23 end,
           "Invalid type for attribute 'array_of_str' %(got number, expected table%)",
           "array_of_str refused : not a table")

error_like(function () a.array_of_str = { 23, 'Foo' } end,
           "Value for attribute 'array_of_str' does not validate type constraint 'table<string>'",
           "mixed array refused")

is( a:dump(), [[
obj = A {
  another_array_of_str = {
    [1] = "Foo",
    [2] = "Bar",
    [3] = "Baz",
  },
  array_of_str = obj.another_array_of_str,
  hash_of_a = {
    ["one"] = A {},
    ["two"] = obj,
  },
  hash_of_num = {
    ["one"] = 1,
    ["three"] = 3,
    ["two"] = 2,
  },
  many_a = {
    [1] = A {},
    [2] = A {},
    [3] = A {},
    [4] = A {},
    [5] = A {},
    [6] = A {},
    [7] = A {},
    [8] = A {},
    [9] = A {},
    [10] = A {},
  },
}]], "dump" )

