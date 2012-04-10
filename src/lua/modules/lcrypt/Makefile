CFLAGS += -O3 -Wall -DLITTLE_ENDIAN -DLTM_DESC -DLTC_SOURCE -DUSE_LTM -fPIC \
	-I$(TOMCRYPT)/src/headers -I$(LUA)/src -I../src

all: lcrypt.so lcrypt.o 

install: all
	cp lcrypt.so $(TARGET)/lib/lua/5.1/

lcrypt.so: lcrypt.o
	$(CC) $(CFLAGS) -shared -L$(TARGET)/lib -lm -lz -lutil -ltomcrypt -ltommath -lluajit lcrypt.o -o $@

lcrypt.o: lcrypt.c lcrypt_ciphers.c lcrypt_hashes.c lcrypt_math.c lcrypt_bits.c
	$(CC) $(CFLAGS) -c lcrypt.c -o $@

clean:
	rm -f lcrypt.o lcrypt.so
