HOME=`pwd`
BUILDDIR=$(HOME)/build
SRCDIR=$(HOME)/src

# Targets start here.
all: sqlite zeromq gin

clean: sqliteclean zeromqclean ginclean buildclean

gin: 
	cd ${SRCDIR}/gin && $(MAKE) macosx && $(MAKE) install

ginclean: 	
	cd ${SRCDIR}/gin && $(MAKE) clean

# configure and compile zeromq
zeromq: zeromqconf
	cd ${SRCDIR}/zeromq && $(MAKE) install
	
zeromqconf:
	cd ${SRCDIR}/zeromq && ./configure --with-pic --with-gcov=no --prefix=$(BUILDDIR)
	
zeromqclean:
	cd ${SRCDIR}/zeromq && $(MAKE) clean
	
# configure and compile sqlite	
sqlite: sqliteconf
	cd ${SRCDIR}/sqlite && $(MAKE) install

sqliteconf: 
	cd ${SRCDIR}/sqlite && [ -f Makefile ] || ./configure --prefix=$(BUILDDIR)

sqliteclean: 
	cd ${SRCDIR}/sqlite && $(MAKE) clean

buildclean: 
	echo $(BUILDDIR)
	rm -rf $(BUILDDIR)/*

# list targets that do not create files (but not all makes understand .PHONY)
.PHONY: all clean gin ginclean sqlite sqliteconf sqliteclean buildclean zeromq zeromqconf zeromqclean

# (end of Makefile)
