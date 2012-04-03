
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
all: luajit luarocks sqlite zeromq gin

clean: luajitclean luarocksclean zeromqclean zeromqrockclean sqliteclean  ginclean
	
buildclean: 
	echo $(BUILDDIR)
	rm -rf $(BUILDDIR)/*
	
# Gin components -----------------------------------------------------------------------------------
gin: 
	$(MAKE) -C $(GINDIR) macosx && $(MAKE) install

ginclean: 	
	$(MAKE) -C $(GINDIR) clean

# Compile luajit -----------------------------------------------------------------------------------
luajit:
	PREFIX=$(BUILDDIR) $(MAKE) -C $(LUAJITDIR) install

luajitclean: 
	$(MAKE) -C $(LUAJITDIR) clean

# Configure and compile luarocks -------------------------------------------------------------------
luarocks: luajit luarocksconf
	$(MAKE) -C $(LUAROCKSDIR) install

luarocksconf:
	cd $(LUAROCKSDIR) && ./configure --prefix=$(BUILDDIR)

luarocksclean:
	$(MAKE) -C $(LUAROCKSDIR) clean

# Configure and compile zeromq ---------------------------------------------------------------------
zeromq: zeromqconf
	$(MAKE) -C $(ZEROMQDIR) install
		
zeromqconf:
	cd $(ZEROMQDIR) && ./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR)
	
zeromqclean:
	$(MAKE) -C $(ZEROMQDIR) clean
	
zeromqrock: luarocks zeromq	
	cd $(LUAMODULES)
	$(BUILDDIR)/bin/luarocks make rockspecs/lua-zmq-scm-0.rockspec	
	
zeromqrockclean: 
	$(MAKE) -C $(LUAMODULES)/lua-zmq clean
	
# Configure and compile sqlite ---------------------------------------------------------------------
sqlite: sqliteconf
	$(MAKE) -C $(SQLITEDIR) install

sqliteconf: 
	cd $(SQLITEDIR) && ./configure --prefix=$(BUILDDIR)

sqliteclean: 
	$(MAKE) -C $(SQLITEDIR) clean

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all clean buildclean \
	gin ginclean \
	luajit luajitclean \
	luarocks luarocksconf luarocksclean \
	sqlite sqliteconf sqliteclean \
	zeromq zeromqconf zeromqclean

# (end of Makefile)
