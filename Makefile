
# Base directories
HOME:=$(PWD)
BUILDDIR:=$(HOME)/build
SRCDIR:=$(HOME)/src

# Libraries' directories
LUADIR:=$(SRCDIR)/lua/lua
LUAJITDIR:=$(SRCDIR)/lua/luajit
LUAROCKSDIR:=$(SRCDIR)/lua/luarocks
LUAMODULES:=$(SRCDIR)/lua/modules
ZEROMQDIR:=$(SRCDIR)/zeromq
SQLITEDIR:=$(SRCDIR)/sqlite

# Gin directory
GINDIR=$(SRCDIR)/gin

# Targets start here.
all: luajit luarocks \
	zeromq \
	sqlite \
	lzlib \
	llthreads \
	gin

clean: srcclean buildclean

srcclean: luajitclean luarocksclean \
	zeromqclean  \
	sqliteclean \
	lzlibclean \
	llthreadsclean \
	ginclean
	
buildclean: 
	echo Removing $(BUILDDIR) ...
	rm -rf $(BUILDDIR)/*

# --- Compile luajit -------------------------------------------------------------------------------
luajit:
	PREFIX=$(BUILDDIR) $(MAKE) -C $(LUAJITDIR) install

luajitclean: 
	$(MAKE) -C $(LUAJITDIR) clean

# --- Configure and compile luarocks ---------------------------------------------------------------
luarocks: luajit luarocksconf
	$(MAKE) -C $(LUAROCKSDIR) install

luarocksconf:
	cd $(LUAROCKSDIR) && \
	[ -f Makefile ] || ./configure --prefix=$(BUILDDIR)

luarocksclean:
	$(MAKE) -C $(LUAROCKSDIR) clean

# --- Configure and compile zeromq -----------------------------------------------------------------
zeromq: zeromqlib zeromqrock

zeromqclean: zeromqlibclean zeromqrockclean

zeromqlib: zeromqlibconf
	$(MAKE) -C $(ZEROMQDIR) install
		
zeromqlibconf:
	cd $(ZEROMQDIR) && \
	[ -f Makefile ] || ./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR)
	
zeromqlibclean:
	$(MAKE) -C $(ZEROMQDIR) clean
	
zeromqrock: luarocks zeromqlib
	cd $(LUAMODULES)/lua-zmq && \
	$(BUILDDIR)/bin/luarocks make rockspecs/lua-zmq-scm-0.rockspec	
	
zeromqrockclean: 
	$(MAKE) -C $(LUAMODULES)/lua-zmq clean
	
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
	rm $(LUAMODULES)/lsqlite3/lsqlite3.o
	rm $(LUAMODULES)/lsqlite3/lsqlite3.so

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
	rm $(LUAMODULES)/lua-llthreads/llthreads.so
	rm $(LUAMODULES)/lua-llthreads/src/pre_generated-llthreads.nobj.o
	
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
	llthreads llthreadsclean
	
# (end of Makefile)
