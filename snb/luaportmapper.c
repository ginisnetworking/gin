#include <lua.h>                               /* Always include this */
#include <lauxlib.h>                           /* Always include this */
#include <lualib.h>                            /* Always include this */

#include "natpmp.h"

void upnp_init(void) {}
void upnp_discover(void) {}
void upnp_map_add(const char* address, int port) {}
void upnp_map_remove(int port) {}

void natpmp_init(void) {}
int natpmp_map(lua_State *L) {
	int r;
	int forcegw = 0; int gateway = 0;
	natpmp_t natpmp;
	uint16_t rport = lua_tonumber(L, 1);
	uint16_t lport = lua_tonumber(L, 2);
	printf("Will try to map gateway port: %d to local port: %d\n", rport, lport);
	r = initnatpmp(&natpmp, forcegw, gateway);
	closenatpmp(&natpmp);
	return 0;
}
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
 * gcc -Wall -shared -fPIC -o luaportmapper.so -I /Users/fra/code/gin/build/include/luajit-2.0 -I /Users/fra/code/gin/build/include -L /Users/fra/code/gin/build/lib -lnatpmp -lluajit-5.1 luaportmapper.c 
 * DYLD_LIBRARY_PATH=/Users/fra/code/gin/build/lib lua test.luaportmapper.lua
 * */

int luaopen_luaportmapper(lua_State *L) {
	lua_register(L, "hello", hello);
	lua_register(L, "natpmp_map", natpmp_map);
	return 0;
}

