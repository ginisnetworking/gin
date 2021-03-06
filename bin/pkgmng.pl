#!/usr/bin/perl -w 

use strict;

my $pkgdir  = $ARGV[0] || "/tmp/gin/pkgs";
my $srcdir  = $ARGV[1] || "/tmp/gin/src";
my $ptchdir = $ARGV[2] || "/tmp/gin/patches";

my $pkgs   = [

  # luajit and luarocks
  { name    => "luajit", file => "LuaJIT-2.0.0.tar.gz", dest => "lua/luajit",   
    get     => "curl -C - -O http://luajit.org/download/LuaJIT-2.0.0.tar.gz", 
    extract => "tar zxvf $pkgdir/LuaJIT-2.0.0.tar.gz --strip-components 1"},
  { name    => "luarocks", file => "luarocks-2.0.12.tar.gz", dest => "lua/luarocks", 
    get     => "curl -C - -O http://luarocks.org/releases/luarocks-2.0.12.tar.gz", 
    extract => "tar zxvf $pkgdir/luarocks-2.0.12.tar.gz --strip-components 1"},

  # main libraries
  { name    => "zeromq", file => "zeromq-2.2.0.tar.gz", dest => "zeromq",       
    get     => "curl -C - -O http://download.zeromq.org/zeromq-2.2.0.tar.gz", 
    extract => "tar zxvf $pkgdir/zeromq-2.2.0.tar.gz --strip-components 1" },
  { name    => "sqlite", file => "sqlite-autoconf-3071200.tar.gz",  dest => "sqlite",       
    get     => "curl -C - -O http://www.sqlite.org/sqlite-autoconf-3071200.tar.gz",      
    extract => "tar zxvf $pkgdir/sqlite-autoconf-3071200.tar.gz --strip-components 1" },
  { name    => "libev", file => "libev-4.11.tar.gz",  dest => "libev",       
    get     => "curl -C - -O http://dist.schmorp.de/libev/libev-4.11.tar.gz",      
    extract => "tar zxvf $pkgdir/libev-4.11.tar.gz --strip-components 1" },

  # upnp
  { name    => "upnpc", file => "miniupnpc-1.7.tar.gz", dest => "miniupnpc",       
    get     => "curl -C - -O http://miniupnp.free.fr/files/miniupnpc-1.7.tar.gz", 
    extract => "tar zxvf $pkgdir/miniupnpc-1.7.tar.gz --strip-components 1" },
  { name    => "libnatpmp", file => "libnatpmp-20120821.tar.gz", dest => "libnatpmp",       
    get     => "curl -C - -O http://miniupnp.free.fr/files/libnatpmp-20120821.tar.gz", 
    extract => "tar zxvf $pkgdir/libnatpmp-20120821.tar.gz --strip-components 1" },
  
  # cryptography and stuff
  # { name    => "lcrypt", file => "lcrypt.tgz", dest => "lua/modules/lcrypt",
  #   get     => "curl -C - -O http://eder.us/projects/lcrypt/lcrypt.tgz",
  #   extract => "tar zxvf $pkgdir/lcrypt.tgz --strip-components 1"},
  # { name    => "bencode", file => "bencode-1.tar.gz", dest => "lua/modules/bencode",
  #   get     => "curl -L -C - -O https://bitbucket.org/wilhelmy/lua-bencode/downloads/bencode-1.tar.gz",
  #   extract => "tar zxvf $pkgdir/bencode-1.tar.gz --strip-components 1"},
  # { name    => "lua-coat", file => "lua-coat-0.8.6.tar.gz",  dest => "lua/modules/lua-coat", 
  #   get     => "curl -L -C - -O https://github.com/downloads/fperrad/lua-Coat/lua-coat-0.8.6.tar.gz",
  #   extract => "tar zxvf $pkgdir/lua-coat-0.8.6.tar.gz --strip-components 1"},
  # { name    => "lunit", file => "lunit-0.5.tar.gz",  dest => "lua/modules/lunit", 
  #   get     => "curl -C - -O http://www.nessie.de/mroth/lunit/lunit-0.5.tar.gz",
  #   extract => "tar zxvf $pkgdir/lunit-0.5.tar.gz --strip-components 1"},  
  # lib tom crypt
  # { name    => "libtommath", file => "ltm-0.42.0.tar.bz2", dest => "libtommath",   
  #   get     => "curl -C - -O http://libtom.org/files/ltm-0.42.0.tar.bz2",    
  #	 extract => "bunzip2 -c $pkgdir/ltm-0.42.0.tar.bz2|tar xv --strip-components 1"},
  # { name    => "libtomcrypt", file => "crypt-1.17.tar.bz2", dest => "libtomcrypt",  
  #   get     => "curl -C - -O http://libtom.org/files/crypt-1.17.tar.bz2",    
  #   extract => "bunzip2 -c $pkgdir/crypt-1.17.tar.bz2|tar xv --strip-components 1"},

];


my $patches = [
 #  { name => "libtommath", file => "libtommath.patch", dest => "libtommath",
 #    apply => "patch -p 1 < $ptchdir/libtommath.patch" },
 #  { name => "lcrypt", file => "lcrypt.patch", dest => "lua/modules/lcrypt",
 #    apply => "patch -p 1 < $ptchdir/lcrypt.patch" }
];


# Get packages, create dest and extract

system "mkdir -p $srcdir";

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
    system "cd $srcdir/".$pkg->{dest}.";".$pkg->{extract}." 2>/dev/null";
    # Apply patches
    for my $patch (grep { $_->{name} eq $pkg->{name}} @$patches) {
      print "Applying patch $patch->{file} to $patch->{name}...";
      system "cd $srcdir/".$patch->{dest}.";".$patch->{apply};
    }
  } 
}
