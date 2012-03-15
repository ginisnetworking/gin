
LUA     := lua
VERSION := $(shell cd src && $(LUA) -e "m = require [[Coat]]; print(m._VERSION)")
TARBALL := lua-coat-$(VERSION).tar.gz
ifndef REV
  REV   := 1
endif

LUAVER  := 5.1
PREFIX  := /usr/local
DPREFIX := $(DESTDIR)$(PREFIX)
BINDIR  := $(DPREFIX)/bin
LIBDIR  := $(DPREFIX)/share/lua/$(LUAVER)

all: dist.cmake
	@echo "Nothing to build here, you can just make install"

install:
	mkdir -p $(BINDIR)
	cp src/coat2dot                 $(BINDIR)
	mkdir -p $(LIBDIR)/Coat/Meta
	cp src/Coat.lua                 $(LIBDIR)
	cp src/Coat/Role.lua            $(LIBDIR)/Coat
	cp src/Coat/Types.lua           $(LIBDIR)/Coat
	cp src/Coat/UML.lua             $(LIBDIR)/Coat
	cp src/Coat/file.lua            $(LIBDIR)/Coat
	cp src/Coat/Meta/Class.lua      $(LIBDIR)/Coat/Meta
	cp src/Coat/Meta/Role.lua       $(LIBDIR)/Coat/Meta

uninstall:
	rm -f $(BINDIR)/coat2dot
	rm -f $(LIBDIR)/Coat.lua
	rm -f $(LIBDIR)/Coat/Role.lua
	rm -f $(LIBDIR)/Coat/Types.lua
	rm -f $(LIBDIR)/Coat/UML.lua
	rm -f $(LIBDIR)/Coat/file.lua
	rm -f $(LIBDIR)/Coat/Meta/Class.lua
	rm -f $(LIBDIR)/Coat/Meta/Role.lua

manifest_pl := \
use strict; \
use warnings; \
my @files = qw{MANIFEST}; \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    next if m{^doc/\.}; \
    next if m{^doc/google}; \
    next if m{^rockspec/}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl := \
use strict; \
use warnings; \
use Digest::MD5; \
open my $$FH, q{<}, q{$(TARBALL)} \
    or die qq{Cannot open $(TARBALL) ($$!)}; \
binmode $$FH; \
my %config = ( \
    version => q{$(VERSION)}, \
    rev     => q{$(REV)}, \
    md5     => Digest::MD5->new->addfile($$FH)->hexdigest(), \
); \
close $$FH; \
while (<>) { \
    s{@(\w+)@}{$$config{$$1}}g; \
    print; \
}

version:
	@echo $(VERSION)

CHANGES: dist.info
	perl -i.bak -pe "s{^$(VERSION).*}{q{$(VERSION)  }.localtime()}e" CHANGES

dist.info:
	perl -i.bak -pe "s{^version.*}{version = \"$(VERSION)\"}" dist.info

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

doc:
	git read-tree --prefix=doc/ -u remotes/origin/gh-pages

dist.cmake:
	wget https://raw.github.com/LuaDist/luadist/master/dist.cmake

MANIFEST: doc dist.cmake
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	[ -d lua-Coat-$(VERSION) ] || ln -s . lua-Coat-$(VERSION)
	perl -ne 'print qq{lua-Coat-$(VERSION)/$$_};' MANIFEST | \
	    tar -zc -T - -f $(TARBALL)
	rm lua-Coat-$(VERSION)
	rm -rf doc
	git rm doc/*

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in > rockspec/lua-coat-$(VERSION)-$(REV).rockspec

install-rock: clean dist rockspec
	perl -pe 's{http://cloud.github.com/downloads/fperrad/lua-Coat/}{};' \
	    rockspec/lua-coat-$(VERSION)-$(REV).rockspec > lua-coat-$(VERSION)-$(REV).rockspec
	luarocks install lua-coat-$(VERSION)-$(REV).rockspec

ifdef LUA_PATH
  export LUA_PATH:=$(LUA_PATH);../test/?.lua
else
  export LUA_PATH=;;../test/?.lua
endif
#export GEN_PNG=1

check: test

test:
	cd src && prove --exec=$(LUA) ../test/*.t

coverage:
	rm -f src/luacov.stats.out src/luacov.report.out
	cd src && prove --exec="$(LUA) -lluacov" ../test/*.t
	cd src && luacov

README.html: README.md
	Markdown.pl README.md > README.html

clean:
	rm -rf doc
	rm -f MANIFEST *.bak src/luacov.*.out src/*.png test/*.png *.rockspec README.html

realclean: clean
	rm -f dist.cmake

.PHONY: test rockspec CHANGES dist.info

