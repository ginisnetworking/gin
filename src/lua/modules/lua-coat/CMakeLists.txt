# lua-Coat : <http://fperrad.github.com/lua-Coat/>

project ( lua-coat NONE )
cmake_minimum_required ( VERSION 2.6 )
include ( dist.cmake )

install_lua_module ( Coat               src/Coat.lua )
install_lua_module ( Coat.Meta.Class    src/Coat/Meta/Class.lua )
install_lua_module ( Coat.Meta.Role     src/Coat/Meta/Role.lua )
install_lua_module ( Coat.Role          src/Coat/Role.lua )
install_lua_module ( Coat.Types         src/Coat/Types.lua )
install_lua_module ( Coat.UML           src/Coat/UML.lua )
install_lua_module ( Coat.file          src/Coat/file.lua )
install_lua_executable ( coat2dot       src/coat2dot )

install_data ( CHANGES COPYRIGHT README.md )
install_test ( test/ )
