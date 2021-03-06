#include <lua.h>                               /* Always include this */
#include <lauxlib.h>                           /* Always include this */
#include <lualib.h>                            /* Always include this */
#include <string.h> /* memset */
#include <stdlib.h> /* free */
#ifdef SYSTEM_MINIUPNP
  #include <miniupnpc/miniupnpc.h>
  #include <miniupnpc/upnpcommands.h>
  #include <miniupnpc/upnperrors.h>
#else
  #include "miniupnpc.h"
  #include "upnpcommands.h"
  #include "upnperrors.h"
#endif

#ifdef SYS_DARWIN
  #define HAVE_MINIUPNP_16 1
#endif


#include "natpmp.h"

/* protofix() checks if protocol is "UDP" or "TCP"
 * returns NULL if not */
const char * protofix(const char * proto)
{
	static const char proto_tcp[4] = { 'T', 'C', 'P', 0};
	static const char proto_udp[4] = { 'U', 'D', 'P', 0};
	int i, b;
	for(i=0, b=1; i<4; i++)
		b = b && (   (proto[i] == proto_tcp[i])
		          || (proto[i] == (proto_tcp[i] | 32)) );
	if(b)
		return proto_tcp;
	for(i=0, b=1; i<4; i++)
		b = b && (   (proto[i] == proto_udp[i])
		          || (proto[i] == (proto_udp[i] | 32)) );
	if(b)
		return proto_udp;
	return 0;
}

void upnp_map_add(
	struct UPNPUrls * urls,
	struct IGDdatas * data,
	const char * iaddr,
	const char * iport,
	const char * eport,
    const char * proto,
    const char * leaseDuration) {

	char externalIPAddress[40];
	char intClient[40];
	char intPort[6];
	char duration[16];
	int r;

	if(!iaddr || !iport || !eport || !proto)
	{
		fprintf(stderr, "Wrong arguments\n");
		return;
	}
	proto = protofix(proto);
	if(!proto)
	{
		fprintf(stderr, "invalid protocol\n");
		return;
	}

	UPNP_GetExternalIPAddress(urls->controlURL,
	                          data->first.servicetype,
							  externalIPAddress);
	if(externalIPAddress[0])
		printf("ExternalIPAddress = %s\n", externalIPAddress);
	else
		printf("GetExternalIPAddress failed.\n");

	r = UPNP_AddPortMapping(urls->controlURL, data->first.servicetype,
	                        eport, iport, iaddr, "GiN", proto, 0, leaseDuration);
	if(r!=UPNPCOMMAND_SUCCESS)
		printf("AddPortMapping(%s, %s, %s) failed with code %d (%s)\n",
		       eport, iport, iaddr, r, strupnperror(r));

	r = UPNP_GetSpecificPortMappingEntry(urls->controlURL,
	                                 data->first.servicetype,
    	                             eport, proto,
									 intClient, intPort, 0/*desc*/,
	                                 NULL/*enabled*/, duration);
	if(r!=UPNPCOMMAND_SUCCESS)
		printf("GetSpecificPortMappingEntry() failed with code %d (%s)\n",
		       r, strupnperror(r));

	if(intClient[0]) {
		printf("InternalIP:Port = %s:%s\n", intClient, intPort);
		printf("external %s:%s %s is redirected to internal %s:%s (duration=%s)\n",
		       externalIPAddress, eport, proto, intClient, intPort, duration);
	}
}
void upnp_map_remove(struct UPNPUrls * urls,
               struct IGDdatas * data,
			   const char * eport,
			   const char * proto) {
	int r;
	if(!proto || !eport)
	{
		fprintf(stderr, "invalid arguments\n");
		return;
	}
	proto = protofix(proto);
	if(!proto)
	{
		fprintf(stderr, "protocol invalid\n");
		return;
	}
	r = UPNP_DeletePortMapping(urls->controlURL, data->first.servicetype, eport, proto, 0);
	printf("UPNP_DeletePortMapping() returned : %d\n", r);
}

int upnp_map_check(lua_State *L) {

	static struct UPNPUrls urls;
	static struct IGDdatas data;
	struct UPNPDev *devlist;
//	struct UPNPDev *device;

	const char* iport = lua_tostring(L, 1);
	const char* eport = lua_tostring(L, 2);

	int upnperror = 0;
	int i = 0;
	int rc = 0;
	char lanaddr[64];
	printf("TB : init_upnp()\n");
	memset(&urls, 0, sizeof(struct UPNPUrls));
	memset(&data, 0, sizeof(struct IGDdatas));
	devlist = upnpDiscover(2000, NULL/*multicast interface*/, NULL/*minissdpd socket path*/, 0/*sameport*/, 0/*ipv6*/, &upnperror);
	i = UPNP_GetValidIGD(devlist, &urls, &data, lanaddr, sizeof(lanaddr));


	int r;
	char index[6];
	char intClient[40];
	char intPort[6];
	char extPort[6];
	char protocol[4];
	char desc[80];
	char enabled[6];
	char rHost[64];
	char duration[16];
	/*unsigned int num=0;
	UPNP_GetPortMappingNumberOfEntries(urls->controlURL, data->servicetype, &num);
	printf("PortMappingNumberOfEntries : %u\n", num);*/
	printf(" i protocol exPort->inAddr:inPort description remoteHost leaseTime\n");
	do {
		snprintf(index, 6, "%d", i);
		rHost[0] = '\0'; enabled[0] = '\0';
		duration[0] = '\0'; desc[0] = '\0';
		extPort[0] = '\0'; intPort[0] = '\0'; intClient[0] = '\0';
		r = UPNP_GetGenericPortMappingEntry(urls.controlURL,
		                               data.first.servicetype,
		                               index,
		                               extPort, intClient, intPort,
									   protocol, desc, enabled,
									   rHost, duration);
		if(r==0)
		/*
			printf("%02d - %s %s->%s:%s\tenabled=%s leaseDuration=%s\n"
			       "     desc='%s' rHost='%s'\n",
			       i, protocol, extPort, intClient, intPort,
				   enabled, duration,
				   desc, rHost);
				   */
			printf("%2d %s %5s->%s:%-5s '%s' '%s' %s\n",
			       i, protocol, extPort, intClient, intPort,
			       desc, rHost, duration);
			if (strcmp(eport, extPort) == 0) {
				printf("I'm returning more than 1 (found mapping there with the external port %s)\n", extPort);
				rc++;
			}
			if (strcmp(iport, intPort) == 0) {
				printf("I'm returning more than 1 (found mapping there with the internal port %s)\n", intPort);
				rc++;
			}
		else
			printf("GetGenericPortMappingEntry() returned %d (%s)\n",
			       r, strupnperror(r));
		i++;
	} while(r==0);


	freeUPNPDevlist(devlist);
	lua_pushnumber(L, rc);
	return 1;

}

/* TODO: consider either use lua registry to store upnp initialization or make helper functions to deal with upnp initialization and discovery
*/
int upnp_unmap(lua_State *L) {
	static struct UPNPUrls urls;
	static struct IGDdatas data;
	struct UPNPDev *devlist;
	struct UPNPDev *device;
	const char* eport = lua_tostring(L, -1);
	int upnperror = 0;
	int i;
	char lanaddr[64];
	printf("TB : init_upnp()\n");
	memset(&urls, 0, sizeof(struct UPNPUrls));
	memset(&data, 0, sizeof(struct IGDdatas));
	devlist = upnpDiscover(2000, NULL/*multicast interface*/, NULL/*minissdpd socket path*/, 0/*sameport*/, 0/*ipv6*/, &upnperror);
	for(device = devlist; device; device = device->pNext) {
		printf(" desc: %s\n st: %s\n\n", device->descURL, device->st);
	}
	i = UPNP_GetValidIGD(devlist, &urls, &data, lanaddr, sizeof(lanaddr));
	printf("Local LAN ip address : %s\n", lanaddr);
	upnp_map_remove(&urls, &data, eport, "TCP");
	freeUPNPDevlist(devlist);
	return 0;
}

int upnp_map(lua_State *L) {
	static struct UPNPUrls urls;
	static struct IGDdatas data;
	struct UPNPDev *devlist;
	struct UPNPDev *device;
	const char* iport = lua_tostring(L, 1);
	const char* eport = lua_tostring(L, 2);
	int upnperror = 0;
	int i;
	char lanaddr[64];
	printf("TB : init_upnp()\n");
	memset(&urls, 0, sizeof(struct UPNPUrls));
	memset(&data, 0, sizeof(struct IGDdatas));
	devlist = upnpDiscover(2000, NULL/*multicast interface*/, NULL/*minissdpd socket path*/, 0/*sameport*/, 0/*ipv6*/, &upnperror);
	for(device = devlist; device; device = device->pNext) {
		printf(" desc: %s\n st: %s\n\n", device->descURL, device->st);
	}
	i = UPNP_GetValidIGD(devlist, &urls, &data, lanaddr, sizeof(lanaddr));
	printf("Local LAN ip address : %s\n", lanaddr);
	upnp_map_add(&urls, &data, lanaddr, iport, eport, "TCP", "0");
	freeUPNPDevlist(devlist);
	return 0;
}

int upnp_get_igd(lua_State *L) {
	static struct UPNPUrls urls;
	static struct IGDdatas data;
	struct UPNPDev *devlist;
	struct UPNPDev *device;
	int upnperror = 0;
	int i;
	char lanaddr[64];
	char externalIPAddress[40];
	printf("TB : init_upnp()\n");
	memset(&urls, 0, sizeof(struct UPNPUrls));
	memset(&data, 0, sizeof(struct IGDdatas));
	devlist = upnpDiscover(2000, NULL/*multicast interface*/, NULL/*minissdpd socket path*/, 0/*sameport*/, 0/*ipv6*/, &upnperror);
	for(device = devlist; device; device = device->pNext) {
		printf(" desc: %s\n st: %s\n\n", device->descURL, device->st);
	}
	i = UPNP_GetValidIGD(devlist, &urls, &data, lanaddr, sizeof(lanaddr));

	UPNP_GetExternalIPAddress(urls.controlURL, data.first.servicetype, externalIPAddress);
	printf("External ip address : %s\n", externalIPAddress);
	printf("Local LAN ip address : %s\n", lanaddr);
        lua_pushstring(L, externalIPAddress);
        lua_pushstring(L, lanaddr);
	freeUPNPDevlist(devlist);
	return 2;
}

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
 * gcc -Wall -shared -fPIC -o luaportmapper.so -I /Users/fra/code/gin/build/include/luajit-2.0 -I $HOME/code/gin/build/include -I $HOME/code/gin/build/include/miniupnpc -L$HOME/code/gin/build/lib -lminiupnpc -lnatpmp -lluajit-5.1 luaportmapper.c 
 * DYLD_LIBRARY_PATH=/Users/fra/code/gin/build/lib lua test.luaportmapper.lua
 * */

int luaopen_luaportmapper(lua_State *L) {
	lua_register(L, "hello", hello);
	lua_register(L, "natpmp_map", natpmp_map);
	lua_register(L, "upnp_map", upnp_map);
	lua_register(L, "upnp_unmap", upnp_unmap);
	lua_register(L, "upnp_get_igd", upnp_get_igd);
	lua_register(L, "upnp_map_check", upnp_map_check);
	return 0;
}

