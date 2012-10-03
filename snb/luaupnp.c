#include <lua.h>                               /* Always include this */
#include <lauxlib.h>                           /* Always include this */
#include <lualib.h>                            /* Always include this */

/*
 *The second structure, C2lua, is a stack. Pushing elements into this stack is done by using the following functions:

 void           lua_pushnumber           (double n);
 void           lua_pushstring           (char *s);
 void           lua_pushcfunction        (lua_CFunction f);
 void           lua_pushusertag          (void *u, int tag);
 void           lua_pushnil              (void);
 void           lua_pushobject           (lua_Object object);
 plus the macro:
 void           lua_pushuserdata         (void *u);
 * */
int hello(lua_State *L) {
  const char* astring = lua_tostring(L, -1);
  printf("Got this as an argument: %s\n", astring);
  lua_pushstring(L, astring);
  return 1; //one return value
}

/*
 * gcc -Wall -shared -fPIC -o luaupnp.so -I /home/fra/code/gin/build/include/luajit-2.0/ -L /home/fra/code/gin/build/lib -lluajit-5.1 luaupnp.c
 *
 * */

int luaopen_luaupnp(lua_State *L) {
  lua_register(L, "hello", hello);
  return 0;
}

