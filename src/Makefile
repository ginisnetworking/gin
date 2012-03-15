
BUILDDIR=`pwd`/build
SRCDIR=`pwd`/src

# Targets start here.
all: sqlite gin

clean: sqliteclean ginclean buildclean

gin: 
	cd ${SRCDIR}/gin && $(MAKE) macosx && $(MAKE) install

ginclean: 	
	cd ${SRCDIR}/gin && $(MAKE) clean

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
.PHONY: all clean gin sqlite ginclean sqliteconf sqliteclean buildclean

# (end of Makefile)
