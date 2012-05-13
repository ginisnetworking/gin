
# Base directories
HOME:=$(PWD)
BUILDDIR:=$(HOME)/build
SRCDIR:=$(HOME)/src

PKG_CONFIG_PATH=$(BUILDDIR)/lib/pkgconfig

# Libraries' directories
#LUADIR:=$(SRCDIR)/lua/lua
LUAJITDIR:=$(SRCDIR)/lua/luajit
LUAROCKSDIR:=$(SRCDIR)/lua/luarocks
LUAMODULES:=$(SRCDIR)/lua/modules
ZEROMQDIR:=$(SRCDIR)/zeromq
SQLITEDIR:=$(SRCDIR)/sqlite
LIBTOMCRYPTDIR=$(SRCDIR)/libtomcrypt
LIBTOMMATHDIR=$(SRCDIR)/libtommath

# Gin directory
GINDIR=$(SRCDIR)/gin

# Targets start here.
all: luajit luarocks \
	zeromq nixio \
	sqlite \
	libtom \
	llthreads \
	luastdlib \
	gin

clean: srcclean buildclean

srcclean: luajitclean luarocksclean \
	zeromqclean nixioclean \
	sqliteclean \
	libtomclean \
	llthreadsclean \
	luastdlibclean \
	ginclean
	
buildclean: 
	echo Removing $(BUILDDIR) ...
	rm -rf $(BUILDDIR)/*

# --- Compile luajit -------------------------------------------------------------------------------
luajit:
#	PREFIX=$(BUILDDIR) $(MAKE) -C $(LUAJITDIR) install
	make -C $(LUAJITDIR) PREFIX=$(BUILDDIR) install
	sh -c "ln -s $(BUILDDIR)/lib/libluajit-51.2.0.0.dylib $(BUILDDIR)/lib/libluajit.dylib; true"
	sh -c "ln -s $(BUILDDIR)/lib/libluajit-5.1.so.2 $(BUILDDIR)/lib/libluajit.so; true"
	sh -c "ln -s $(BUILDDIR)/bin/luajit-2.0.0-beta10 $(BUILDDIR)/bin/lua; true"
	sh -c "ln -s $(BUILDDIR)/lib/pkgconfig/luajit.pc $(BUILDDIR)/lib/pkgconfig/lua5.1.pc; true"

luajitclean: 
	$(MAKE) -C $(LUAJITDIR) clean

# --- Configure and compile luarocks ---------------------------------------------------------------
luarocks: luajit luarocksconf
	$(MAKE) -C $(LUAROCKSDIR) install

luarocksconf:
	cd $(LUAROCKSDIR) && \
	[ -f config.unix ] || ./configure --prefix=$(BUILDDIR) --with-lua=$(BUILDDIR) --with-lua-include=$(BUILDDIR)/include/luajit-2.0

luarocksclean:
	$(MAKE) -C $(LUAROCKSDIR) clean
	cd $(LUAROCKSDIR) && rm config.unix

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
	cd $(ZEROMQDIR) && rm Makefile
	
zeromqrock: luarocks zeromqlib
	cd $(LUAMODULES)/lua-zmq && \
	$(BUILDDIR)/bin/luarocks make rockspecs/lua-zmq-scm-0.rockspec	
	
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
	$(MAKE) -C $(LIBTOMMATHDIR) clean
	
libtomcrypt: libtommath
	DESTDIR=$(BUILDDIR) INSTALL_USER=`id -nu` INSTALL_GROUP=`id -ng` NODOCS=1 $(MAKE) -C $(LIBTOMCRYPTDIR) install

libtomcryptclean:
	$(MAKE) -C $(LIBTOMCRYPTDIR) clean

lcrypt:
	TOMCRYPT=../../../libtomcrypt/ LUA=../../luajit/ TARGET=../../../../build/ $(MAKE) -C $(LUAMODULES)/lcrypt install

lcryptclean:
	$(MAKE) -C $(LUAMODULES)/lcrypt clean

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
	sh -c "aclocal ; automake --add-missing; autoconf; ./configure" && \
	cp stdlib.rockspec rockspecs/stdlib-26-1.rockspec
	
luastdlibclean:
	cd $(LUAMODULES)/lua-stdlib && \
	rm -r build-aux rockspecs Makefile configure
	
# --- Gin components -------------------------------------------------------------------------------
gin: 
	$(MAKE) -C $(GINDIR) && $(MAKE) install

ginclean: 	
	$(MAKE) -C $(GINDIR) clean

# --- List of make targets -------------------------------------------------------------------------

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all clean srcclean buildclean \
	gin ginclean \
	luajit luajitclean \
	luarocks luarocksconf luarocksclean \
	sqlite sqliteconf sqliteclean \
	lzlib lzlibclean \
	llthreads llthreadsclean \
	luastdlib luastdlibconf luastdlibclean
	
# (end of Makefile)
