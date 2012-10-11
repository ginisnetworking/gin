
# Base directories
HOME:=$(PWD)
BUILDDIR:=$(HOME)/build
SRCDIR:=$(HOME)/src
SNBDIR:=$(HOME)/snb
PKGDIR:=$(HOME)/pkgs
PTCHDIR:=$(HOME)/patches

PATH:=$(PATH):$(shell pwd)/build/bin
PKG_CONFIG_PATH=$(BUILDDIR)/lib/pkgconfig

#Libraries' directories
LUADIR:=$(SRCDIR)/lua/lua
LUAJITPKG=LuaJIT-2.0.0-beta10
LUAJITDIR:=$(SRCDIR)/lua/luajit
LUAROCKSDIR:=$(SRCDIR)/lua/luarocks
LUAMODULES:=$(SRCDIR)/lua/modules
ZEROMQDIR:=$(SRCDIR)/zeromq
SQLITEDIR:=$(SRCDIR)/sqlite
LIBTOMCRYPTDIR=$(SRCDIR)/libtomcrypt
LIBTOMMATHDIR=$(SRCDIR)/libtommath

# Gin directory
GINDIR=$(HOME)/gin

# Targets start here.
all: checksrc \
    luajit luarocks \
	llthreads \
	zeromq nixio \
	sqlite \
	libnatpmp \
	miniupnp \
	libtom \
	luastdlib \
	gin

checksrc:
	mkdir -p $(BUILDDIR)
	perl bin/pkgmng.pl $(PKGDIR) $(SRCDIR) $(PTCHDIR)

clean: srcclean buildclean

srcclean: 
	@echo Removing $(SRCDIR) ...
	rm -rf $(SRCDIR)/*

buildclean: 
	@echo Removing $(BUILDDIR) ...
	rm -rf $(BUILDDIR)/*

# --- Compile luajit -------------------------------------------------------------------------------
luajit:
	make -C $(LUAJITDIR) PREFIX=$(BUILDDIR) install
	sh -c "ln -s $(BUILDDIR)/lib/libluajit-51.2.0.0.dylib $(BUILDDIR)/lib/libluajit.dylib; true"
	sh -c "ln -s $(BUILDDIR)/lib/libluajit-5.1.so.2 $(BUILDDIR)/lib/libluajit.so; true"
	sh -c "ln -s $(BUILDDIR)/bin/luajit-2.0.0-beta10 $(BUILDDIR)/bin/lua; true"
	sh -c "ln -s $(BUILDDIR)/lib/pkgconfig/luajit.pc $(BUILDDIR)/lib/pkgconfig/lua5.1.pc; true"

luajitclean: 
	rm -rf $(LUAJITDIR)

# --- Configure and compile luarocks ---------------------------------------------------------------
luarocks: luajit luarocksconf 
	$(MAKE) -C $(LUAROCKSDIR) install

luarocksconf:
	cd $(LUAROCKSDIR) && \
	[ -f config.unix ] || ./configure --prefix=$(BUILDDIR) --with-lua=$(BUILDDIR) --with-lua-include=$(BUILDDIR)/include/luajit-2.0

luarocksclean:
	rm -rf $(LUAROCKSDIR)

# --- Configure and compile zeromq -----------------------------------------------------------------
zeromq: zeromqlib zeromqrock 

zeromqclean: zeromqlibclean zeromqrockclean

zeromqlib: zeromqlibconf
	$(MAKE) -C $(ZEROMQDIR) install

zeromqlibconf:
	cd $(ZEROMQDIR) && \
	[ -f Makefile ] || sh -c "./autogen.sh;./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR) --includedir=$(BUILDDIR)/include/luajit-2.0"

zeromqlibclean:
	$(MAKE) -C $(ZEROMQDIR) clean
	cd $(ZEROMQDIR) && rm Makefile || true
	
zeromqrock: luarocks llthreads zeromqlib
	cd $(LUAMODULES)/lua-zmq && \
	$(BUILDDIR)/bin/luarocks make ZEROMQ_INCDIR=$(BUILDDIR)/include/luajit-2.0 ZEROMQ_LIBDIR=$(BUILDDIR)/lib rockspecs/lua-zmq-scm-1.rockspec && \
	 	$(BUILDDIR)/bin/luarocks make ZEROMQ_INCDIR=$(BUILDDIR)/include/luajit-2.0 ZEROMQ_LIBDIR=$(BUILDDIR)/lib rockspecs/lua-zmq-threads-scm-0.rockspec

zeromqrockclean: 
	$(MAKE) -C $(LUAMODULES)/lua-zmq clean

# --- Configure and compile nixio  -----------------------------------------------------------------

nixio: luarocks
	cd $(LUAMODULES)/nixio && \
	$(BUILDDIR)/bin/luarocks make nixio-scm-0.rockspec

nixioclean:
	$(MAKE) -C $(LUAMODULES)/nixio clean

# --- Configure and compile sqlite -----------------------------------------------------------------

sqlite: sqlitelib sqliterock

sqliteclean: sqlitelibclean sqliterockclean

sqlitelib: sqlitelibconf
	$(MAKE) -C $(SQLITEDIR) install

sqlitelibconf: 
	cd $(SQLITEDIR) && \
	[ -f Makefile ] || ./configure --prefix=$(BUILDDIR)

sqlitelibclean: 
	$(MAKE) -C $(SQLITEDIR) clean

sqliterock: luarocks sqlitelib
	cd $(LUAMODULES)/lsqlite3 && \
	$(BUILDDIR)/bin/luarocks make lsqlite3-0.8-1.rockspec	

sqliterockclean:
	sh -c "[ -f $(LUAMODULES)/lsqlite3/lsqlite3.o ] && rm $(LUAMODULES)/lsqlite3/lsqlite3.o; true"
	sh -c "[ -f $(LUAMODULES)/lsqlite3/lsqlite3.so ] && rm $(LUAMODULES)/lsqlite3/lsqlite3.so; true"

# --- libtom stuff ---------------------------------------------------------------------------------

libtom: libtommath libtomcrypt lcrypt

libtomclean: libtommathclean libtomcryptclean lcryptclean

libtommath:
	DESTDIR=$(BUILDDIR) INSTALL_USER=`id -nu` INSTALL_GROUP=`id -ng` $(MAKE) -C $(LIBTOMMATHDIR) install

libtommathclean:
	rm -rf $(LIBTOMMATHDIR)

libtomcrypt: libtommath
	DESTDIR=$(BUILDDIR) CFLAGS="-g3 -DLTC_NO_ASM -DUSE_LTM -DLTM_DESC -I$(BUILDDIR)/include -L$(BUILDDIR)/lib" \
	LIBPATH="/lib" INCPATH="/include" INSTALL_USER=`id -nu` INSTALL_GROUP=`id -ng` \
	NODOCS=1 $(MAKE) -C $(LIBTOMCRYPTDIR) install

libtomcryptclean:
	rm -rf $(LIBTOMCRYPTDIR) 

lcrypt:
	TOMCRYPT=$(LIBTOMCRYPTDIR) LUA=$(LUAJITDIR) TARGET=$(BUILDDIR) $(MAKE) -C $(LUAMODULES)/lcrypt install

lcryptclean:
	rm -rf $(LUAMODULES)/lcrypt 

# --- lzlib rock -----------------------------------------------------------------------------------

lzlib: luarocks	
	cd $(LUAMODULES)/lzlib && \
	$(BUILDDIR)/bin/luarocks make rockspecs/lzlib-0.3-3.rockspec 

lzlibclean: 
	$(MAKE) -C $(LUAMODULES)/lzlib clean

# --- lua-llthreads rock ---------------------------------------------------------------------------

llthreads: luarocks	
	cd $(LUAMODULES)/lua-llthreads && \
	$(BUILDDIR)/bin/luarocks make rockspecs/lua-llthreads-scm-0.rockspec

llthreadsclean:	
	sh -c "[ -f $(LUAMODULES)/lua-llthreads/llthreads.so ] && rm $(LUAMODULES)/lua-llthreads/llthreads.so; true"
	sh -c "[ -f $(LUAMODULES)/lua-llthreads/src/pre_generated-llthreads.nobj.o ] && rm $(LUAMODULES)/lua-llthreads/src/pre_generated-llthreads.nobj.o; true"

# --- lua-stdlib rock ------------------------------------------------------------------------------	

luastdlib: luarocks luastdlibconf
	cd $(LUAMODULES)/lua-stdlib && \
	$(BUILDDIR)/bin/luarocks make rockspecs/stdlib-26-1.rockspec

luastdlibconf:
	cd $(LUAMODULES)/lua-stdlib && \
	mkdir -p build-aux && \
	mkdir -p rockspecs && \
	sh -c "aclocal -I m4; automake --add-missing; autoconf; ./configure" && \
	cp stdlib.rockspec rockspecs/stdlib-26-1.rockspec

luastdlibclean:
	cd $(LUAMODULES)/lua-stdlib && \
	rm -r build-aux rockspecs Makefile configure

# --- miniupnp and libnatpmp -----------------------------------------------------------------------
miniupnp: miniupnpc

libnatpmp:
	cd $(SRCDIR)/libnatpmp && \
	INSTALLPREFIX=$(BUILDDIR) make && \
	INSTALLPREFIX=$(BUILDDIR) make install

libnatpmpclean:
	rm $(BUILDDIR)/include/natpmp.h $(BUILDDIR)/lib/libnatpmp.a $(BUILDDIR)/lib/libnatpmp.dylib $(BUILDDIR)/bin/natpmpc $(BUILDDIR)/lib/libnatpmp.1.dylib

miniupnpc:
	cd $(SRCDIR)/miniupnpc && \
	INSTALLPREFIX=$(BUILDDIR) make && \
	INSTALLPREFIX=$(BUILDDIR) make install

miniupnpcclean:
	rm -rf $(BUILDDIR)/include/miniupnpc $(BUILDDIR)/lib/libminiupnpc.* $(BUILDDIR)/bin/upnpc $(BUILDDIR)/bin/external-ip

miniupnpclean: libnatpmpclean miniupnpcclean

# --- Screws'n'Bolts
luaportmapper:
	cd $(SNBDIR) && \
	gcc -Wall -shared -fPIC -o $(SNBDIR)/luaportmapper.so -I $(BUILDDIR)/include/luajit-2.0 -I $(BUILDDIR)/include -I $(BUILDDIR)/include/miniupnpc -L$(BUILDDIR)/lib -lminiupnpc -lnatpmp -lluajit-5.1 luaportmapper.c

testluaportmapper:
	cd $(SNBDIR) && \
	LD_LIBRARY_PATH=$(BUILDDIR)/lib:$(SNBDIR):$(LD_LIBRARY_PATH) $(BUILDDIR)/bin/lua $(SNBDIR)/test.luaportmapper.lua
# --- Gin components -------------------------------------------------------------------------------
gin: 
	$(MAKE) -C $(GINDIR)

ginclean: 	
	$(MAKE) -C $(GINDIR) clean

# --- List of make targets -------------------------------------------------------------------------

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all clean \
    srccheck srcclean \
    srcclean buildclean \
	gin ginclean \
	luajit luajitclean \
	luarocks luarocksconf luarocksclean \
	sqlite sqliteconf sqliteclean \
	lzlib lzlibclean \
	llthreads llthreadsclean \
	luastdlib luastdlibconf luastdlibclean

# (end of Makefile)

