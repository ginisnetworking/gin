#!/usr/bin/perl -w 

use strict;

my $pkgdir  = $ARGV[0] || "/Users/pmgc/Workspace/gin/pkgs";
my $srcdir  = $ARGV[1] || "/Users/pmgc/Workspace/gin/src";
my $ptchdir = $ARGV[2] || "/Users/pmgc/Workspace/gin/patches";

my $pkgs   = [

  # luajit and luarocks
  { name    => "luajit", file => "LuaJIT-2.0.0-beta10.tar.gz", dest => "lua/luajit",   
    get     => "curl -C - -O http://luajit.org/download/LuaJIT-2.0.0-beta10.tar.gz", 
    extract => "tar zxvf $pkgdir/LuaJIT-2.0.0-beta10.tar.gz --strip-components 1"},
  { name    => "luarocks", file => "luarocks-2.0.8.tar.gz", dest => "lua/luarocks", 
    get     => "curl -C - -O http://luarocks.org/releases/luarocks-2.0.8.tar.gz", 
    extract => "tar zxvf $pkgdir/luarocks-2.0.8.tar.gz --strip-components 1"},

  # main libraries
  { name    => "zeromq", file => "zeromq-2.2.0.tar.gz", dest => "zeromq",       
    get     => "curl -C - -O http://download.zeromq.org/zeromq-2.2.0.tar.gz", 
    extract => "tar zxvf $pkgdir/zeromq-2.2.0.tar.gz --strip-components 1" },
  { name    => "sqlite", file => "sqlite-autoconf-3071200.tar.gz",  dest => "sqlite",       
    get     => "curl -C - -O http://www.sqlite.org/sqlite-autoconf-3071200.tar.gz",      
    extract => "tar zxvf $pkgdir/sqlite-autoconf-3071200.tar.gz --strip-components 1" },
  { name    => "libtommath", file => "ltm-0.42.0.tar.bz2", dest => "libtommath",   
    get     => "curl -C - -O http://libtom.org/files/ltm-0.42.0.tar.bz2",    
    extract => "bunzip2 -c $pkgdir/ltm-0.42.0.tar.bz2 | tar zxv --strip-components 1"},
  { name    => "libtomcrypt", file => "crypt-1.17.tar.bz2", dest => "libtomcrypt",  
    get     => "curl -C - -O http://libtom.org/files/crypt-1.17.tar.bz2",    
    extract => "bunzip2 -c $pkgdir/crypt-1.17.tar.bz2|tar zxv --strip-components 1"},

  # lua modules 
  { name    => "lsqlite3", file => "lsqlite3_svn08.zip", dest => "lua/modules/lsqlite3",
    get     => "curl -C - http://lua.sqlite.org/index.cgi/zip/lsqlite3_svn08.zip?uuid=svn_8 -o lsqlite3_svn08.zip",
    extract => "unzip $pkgdir/lsqlite3_svn08.zip; mv lsqlite3_svn08/* .; rmdir lsqlite3_svn08"},
  { name    => "luazmq", file => "lua-zmq.tar.gz", dest => "lua/modules/lua-zmq",
    get     => "curl -L -C - https://github.com/iamaleksey/lua-zmq/tarball/master -o lua-zmq.tar.gz",
    extract => "tar zxvf $pkgdir/lua-zmq.tar.gz --strip-components 1"},
  { name    => "lcrypt", file => "lcrypt.tgz", dest => "lua/modules/lcrypt",
    get     => "curl -C - -O http://eder.us/projects/lcrypt/lcrypt.tgz",
    extract => "tar zxvf $pkgdir/lcrypt.tgz --strip-components 1"},
  { name    => "llthreads", file => "llthreads.tar.gz", dest => "lua/modules/lua-llthreads",
    get     => "curl -L -C - https://github.com/Neopallium/lua-llthreads/tarball/master -o llthreads.tar.gz",
    extract => "tar zxvf $pkgdir/llthreads.tar.gz --strip-components 1"},
  { name    => "lua-stdlib", file => "lua-stdlib.tar.gz", dest => "lua/modules/lua-stdlib",
    get     => "curl -L -C - https://github.com/rrthomas/lua-stdlib/tarball/origin -o lua-stdlib.tar.gz",
    extract => "tar zxvf $pkgdir/lua-stdlib.tar.gz --strip-components 1"},
  { name    => "nixio", file => "nixio.tar.gz", dest => "lua/modules/nixio",
    get     => "curl -L -C - https://github.com/Neopallium/nixio/tarball/master -o nixio.tar.gz",
    extract => "tar zxvf $pkgdir/nixio.tar.gz --strip-components 1"},
  { name    => "bencode", file => "bencode-1.tar.gz", dest => "lua/modules/bencode",
    get     => "curl -L -C - -O https://bitbucket.org/wilhelmy/lua-bencode/downloads/bencode-1.tar.gz",
    extract => "tar zxvf $pkgdir/bencode-1.tar.gz --strip-components 1"},
  { name    => "lua-coat", file => "lua-coat-0.8.6.tar.gz",  dest => "lua/modules/lua-coat", 
    get     => "curl -L -C - -O https://github.com/downloads/fperrad/lua-Coat/lua-coat-0.8.6.tar.gz",
    extract => "tar zxvf $pkgdir/lua-coat-0.8.6.tar.gz --strip-components 1"},
  { name    => "lunit", file => "lunit-0.5.tar.gz",  dest => "lua/modules/lunit", 
    get     => "curl -C - -O http://www.nessie.de/mroth/lunit/lunit-0.5.tar.gz",
    extract => "tar zxvf $pkgdir/lunit-0.5.tar.gz --strip-components 1"},  
];


my $patches = [
   { name => "libtommath", file => "libtommath.patch", dest => "libtommath",
     apply => "patch -p 1 < $ptchdir/libtommath.patch" },
   { name => "lcrypt", file => "lcrypt.patch", dest => "lua/modules/lcrypt",
     apply => "patch -p 1 < $ptchdir/lcrypt.patch" }
];


# Get packages, create dest and extract

for my $pkg (@$pkgs) {
  
  print "Checking package file for $pkg->{name}: ".$pkg->{file}."\n";
  unless (-f $pkgdir."/".$pkg->{file}) {
    print "Getting $pkg->{name}: ".$pkg->{get}."...\n";
    system "cd $pkgdir;".$pkg->{get};
  }
  
  print "Checking destination dir for $pkg->{name}: ".$pkg->{dest}."\n";
  unless (-d $srcdir."/".$pkg->{dest}) {
    # Create destination directory
    print "Creating destination for $pkg->{name}: ".$pkg->{dest}."...\n";
    system "cd $srcdir; mkdir -p ".$pkg->{dest};
    # Extract package
    print "Extracting source for $pkg->{name}...\n";
    system "cd $srcdir/".$pkg->{dest}.";".$pkg->{extract};
    # Apply patches
    for my $patch (grep { $_->{name} eq $pkg->{name}} @$patches) {
      print "Applying patch $patch->{file} to $patch->{name}...";
      system "cd $srcdir/".$patch->{dest}.";".$patch->{apply};
    }
  } 
}
