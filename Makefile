
# Base directories
HOME:=$(PWD)
BUILDDIR:=$(HOME)/build
SRCDIR:=$(HOME)/src

# Libraries' directories
LUADIR:=$(SRCDIR)/lua
ZEROMQDIR:=$(SRCDIR)/zeromq
SQLITEDIR:=$(SRCDIR)/sqlite

# Gin directory
GINDIR=$(SRCDIR)/gin

# Targets start here.
all: sqlite zeromq gin

clean: sqliteclean zeromqclean ginclean buildclean
	
buildclean: 
	echo $(BUILDDIR)
	rm -rf $(BUILDDIR)/*
	
# Gin components

gin: 
	$(MAKE) -C ${GINDIR} macosx && $(MAKE) install

ginclean: 	
	$(MAKE) -C ${GINDIR} clean

# configure and compile zeromq
zeromq: zeromqconf
	$(MAKE) -C ${ZEROMQDIR} install
		
zeromqconf:
	cd ${ZEROMQDIR} && ./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR)
	
zeromqclean:
	$(MAKE) -C ${ZEROMQDIR} clean
	
# configure and compile sqlite	
sqlite: sqliteconf
	$(MAKE) -C ${SQLITEDIR} install

sqliteconf: 
	cd ${SQLITEDIR} && ./configure --prefix=$(BUILDDIR)

sqliteclean: 
	$(MAKE) -C ${SQLITEDIR} clean

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all clean buildclean \
	gin ginclean \
	sqlite sqliteconf sqliteclean \
	zeromq zeromqconf zeromqclean

# (end of Makefile)
