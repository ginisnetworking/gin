
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
LUAJITDIR:=$(SRCDIR)/lua/luajit
LUAROCKSDIR:=$(SRCDIR)/lua/luarocks
LUAMODULES:=$(SRCDIR)/lua/modules
ZEROMQDIR:=$(SRCDIR)/zeromq
SQLITEDIR:=$(SRCDIR)/sqlite
LIBEVDIR:=$(SRCDIR)/libev
# not being used
# LIBTOMCRYPTDIR=$(SRCDIR)/libtomcrypt
# LIBTOMMATHDIR=$(SRCDIR)/libtommath

# Gin directory
GINDIR=$(HOME)/gin

# Targets start here.
all: checksrc \
    luajit luarocks \
	zeromq zeromqrock \
	sqlite sqliterock \
	libev libevrock \
	nixio handlers \
	lzlib sha2 \
	libnatpmp miniupnp luaportmapper \
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
	make -C $(LUAJITDIR) PREFIX=$(BUILDDIR) INSTALL_INC=$(BUILDDIR)/include install
	sh -c "ln -s $(BUILDDIR)/bin/luajit-2.0.0 $(BUILDDIR)/bin/lua; true"
	# change flags to include -lpthread, linux bug, see: https://github.com/Neopallium/lua-zmq#readme

luajitclean: 
	rm -rf $(LUAJITDIR)

# --- Configure and compile luarocks ---------------------------------------------------------------
luarocks: luajit luarocksconf 
	$(MAKE) -C $(LUAROCKSDIR) install

luarocksconf:
	cd $(LUAROCKSDIR) && \
	[ -f config.unix ] || ./configure --prefix=$(BUILDDIR) --with-lua=$(BUILDDIR) --with-lua-include=$(BUILDDIR)/include/

luarocksclean:
	rm -rf $(LUAROCKSDIR)

# --- Configure and compile zeromq -----------------------------------------------------------------
zeromq: zeromqconf
	$(MAKE) -C $(ZEROMQDIR) install

zeromqconf:
	cd $(ZEROMQDIR) && \
	[ -f Makefile ] || sh -c "./autogen.sh;./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR) --includedir=$(BUILDDIR)/include/"

zeromqclean:
	$(MAKE) -C $(ZEROMQDIR) clean
	cd $(ZEROMQDIR) && rm Makefile || true
	
zeromqrock: luarocks zeromq
	# get from here: https://github.com/Neopallium/lua-zmq
	luarocks install ZEROMQ_DIR=$(BUILDDIR) ZEROMQ_INCDIR=$(BUILDDIR)/include/ \
		"https://raw.github.com/Neopallium/lua-zmq/master/rockspecs/lua-zmq-scm-1.rockspec" && \
	luarocks install "https://raw.github.com/Neopallium/lua-llthreads/master/rockspecs/lua-llthreads-scm-0.rockspec" && \
    luarocks install "https://raw.github.com/Neopallium/lua-zmq/master/rockspecs/lua-zmq-threads-scm-0.rockspec"	
			
# --- Configure and compile sqlite -----------------------------------------------------------------

sqlite: sqliteconf
	$(MAKE) -C $(SQLITEDIR) install

sqliteconf: 
	cd $(SQLITEDIR) && \
	[ -f Makefile ] || ./configure --prefix=$(BUILDDIR)

sqliteclean: 
	$(MAKE) -C $(SQLITEDIR) clean

sqliterock: luarocks sqlite
	luarocks install lsqlite3 SQLITE_DIR=$(BUILDDIR)

# --- Configure and compile libev  -----------------------------------------------------------------

libev: libevconf
	$(MAKE) -C $(LIBEVDIR) install

libevconf: 
	cd $(LIBEVDIR) && \
	[ -f Makefile ] || ./configure --prefix=$(BUILDDIR)
	
libevclean:
	$(MAKE) -C $(LIBEVDIR) clean
	
libevrock: luarocks libev
	luarocks install LIBEV_DIR=$(BUILDDIR) \
  		"https://raw.github.com/brimworks/lua-ev/master/rockspec/lua-ev-scm-1.rockspec"

# --- Configure and compile nixio  -----------------------------------------------------------------

nixio: luarocks
	luarocks install "https://raw.github.com/Neopallium/nixio/master/nixio-scm-0.rockspec"

# --- lzlib rock -----------------------------------------------------------------------------------

lzlib: luarocks	
	luarocks install lzlib
	
sha2: luarocks
	luarocks install sha2
	
handlers: luarocks
	luarocks install "https://raw.github.com/Neopallium/lua-handlers/master/lua-handler-scm-0.rockspec" && \
	luarocks install "https://github.com/Neopallium/lua-handlers/raw/master/lua-handler-zmq-scm-0.rockspec" && \
	luarocks install "https://raw.github.com/Neopallium/lua-handlers/master/lua-handler-nixio-scm-0.rockspec"
	
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

# --- Screws'n'Bolts -------------------------------------------------------------------------------

luaportmapper:
	cd $(SNBDIR) && \
	gcc -Wall -shared -fPIC -o $(BUILDDIR)/lib/lua/5.1/luaportmapper.so \
		-I$(BUILDDIR)/include/luajit-2.0 -I$(BUILDDIR)/include -I$(BUILDDIR)/include/miniupnpc \
		-L$(BUILDDIR)/lib -lminiupnpc -lnatpmp -lluajit-5.1 luaportmapper.c

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
	sqlite sqliteconf sqliteclean 

# (end of Makefile)


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


# https://github.com/Neopallium/pluto
