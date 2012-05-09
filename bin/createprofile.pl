#!/usr/bin/perl -w

my $newpath = $ARGV[0];
print "#!/bin/sh\n" ;
print qq{export PATH="\$PATH:$newpath"\n}
