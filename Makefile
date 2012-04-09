
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
	zeromq zeromqrock \
	sqlite \
	lzlib \
	gin

clean: luajitclean luarocksclean \
	zeromqclean zeromqrockclean \
	sqliteclean \
	lzlibclean \
	ginclean
	
buildclean: 
	echo Removing $(BUILDDIR) ...
	rm -rf $(BUILDDIR)/*

# Compile luajit -----------------------------------------------------------------------------------
luajit:
	PREFIX=$(BUILDDIR) $(MAKE) -C $(LUAJITDIR) install

luajitclean: 
	$(MAKE) -C $(LUAJITDIR) clean

# Configure and compile luarocks -------------------------------------------------------------------
luarocks: luajit luarocksconf
	$(MAKE) -C $(LUAROCKSDIR) install

luarocksconf:
	cd $(LUAROCKSDIR) && \
	[ -f Makefile ] || ./configure --prefix=$(BUILDDIR)

luarocksclean:
	$(MAKE) -C $(LUAROCKSDIR) clean

# Configure and compile zeromq ---------------------------------------------------------------------
zeromq: zeromqconf
	$(MAKE) -C $(ZEROMQDIR) install
		
zeromqconf:
	cd $(ZEROMQDIR) && \
	[ -f Makefile ] || ./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR)
	
zeromqclean:
	$(MAKE) -C $(ZEROMQDIR) clean
	
zeromqrock: luarocks zeromq	
	cd $(LUAMODULES)/lua-zmq && \
	$(BUILDDIR)/bin/luarocks make rockspecs/lua-zmq-scm-0.rockspec	
	
zeromqrockclean: 
	$(MAKE) -C $(LUAMODULES)/lua-zmq clean
	
# Configure and compile sqlite ---------------------------------------------------------------------
sqlite: sqliteconf
	$(MAKE) -C $(SQLITEDIR) install

sqliteconf: 
	cd $(SQLITEDIR) && \
	[ -f Makefile ] || ./configure --prefix=$(BUILDDIR)

sqliteclean: 
	$(MAKE) -C $(SQLITEDIR) clean

# lzlib rock ---------------------------------------------------------------------------------------

lzlib: luarocks	
	cd $(LUAMODULES)/lzlib && \
	$(BUILDDIR)/bin/luarocks make rockspecs/lzlib-0.3-3.rockspec 
	
lzlibclean: 
	$(MAKE) -C $(LUAMODULES)/lzlib clean
	
# Gin components -----------------------------------------------------------------------------------
gin: 
	$(MAKE) -C $(GINDIR) && $(MAKE) install

ginclean: 	
	$(MAKE) -C $(GINDIR) clean

# List of make targets -----------------------------------------------------------------------------

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all clean buildclean \
	gin ginclean \
	luajit luajitclean \
	luarocks luarocksconf luarocksclean \
	sqlite sqliteconf sqliteclean \
	zeromq zeromqconf zeromqclean

# (end of Makefile)
