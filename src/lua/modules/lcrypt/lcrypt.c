//  gcc -Wall -O3 -shared -fPIC -DLITTLE_ENDIAN -DLTM_DESC -DLTC_SOURCE -DUSE_LTM -I/usr/include/tomcrypt -I/usr/include/tommath -lz -lutil -ltomcrypt -ltommath lcrypt.c -o /usr/lib64/lua/5.1/lcrypt.so
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <zlib.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include <tomcrypt.h>

#ifdef USE_NCIPHER
  #include "ncipher.h"
  extern NFastApp_Connection nfast_conn;
  extern NFast_AppHandle nfast_app;
#else
  #include <util.h>
#endif

#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)

#define ADD_FUNCTION(L,name) { lua_pushstring(L, #name); lua_pushcfunction(L, lcrypt_ ## name); lua_settable(L, -3); }
#define ADD_CONSTANT(L,name) { lua_pushstring(L, #name); lua_pushinteger(L, name); lua_settable(L, -3); }

static void lcrypt_error(lua_State *L, int err, void *tofree)
{
  if(unlikely(err != CRYPT_OK))
  {
    if(tofree != NULL) free(tofree);
    lua_pushstring(L, error_to_string(err));
    (void)lua_error(L);
  }
}

static void* lcrypt_malloc(lua_State *L, size_t size)
{
  void *ret = malloc(size);
  if(unlikely(ret == NULL))
  {
    lua_pushstring(L, "Out of memory");
    (void)lua_error(L);
  }
  memset(ret, 0, size);
  return ret;
}

#include "lcrypt_ciphers.c"
#include "lcrypt_hashes.c"
#include "lcrypt_math.c"
#include "lcrypt_bits.c"

static int lcrypt_tohex(lua_State *L)
{
  const char digits[] = "0123456789ABCDEF";
  size_t in_length = 0, spacer_length = 0, prepend_length = 0;
  const unsigned char *in;
  const char *spacer, *prepend;
  int i, j, pos = 0;
  if(unlikely(lua_isnil(L, 1))) { lua_pushlstring(L, "", 0); return 1; }
  in = (const unsigned char*)luaL_checklstring(L, 1, &in_length);
  if(unlikely(in_length == 0)) { lua_pushlstring(L, "", 0); return 1; }
  spacer = luaL_optlstring(L, 2, "", &spacer_length);
  prepend = luaL_optlstring(L, 3, "", &prepend_length);
  char *result = lcrypt_malloc(L, prepend_length + in_length * 2 + (in_length - 1) * spacer_length);
  for(j = 0; j < (int)prepend_length; j++) result[pos++] = prepend[j];
  result[pos++] = digits[(*in >> 4) & 0x0f];
  result[pos++] = digits[*in++ & 0x0f];
  for(i = 1; i < (int)in_length; i++)
  {
    for(j = 0; j < (int)spacer_length; j++) result[pos++] = spacer[j];
    result[pos++] = digits[(*in >> 4) & 0x0f];
    result[pos++] = digits[*in++ & 0x0f];
  }
  lua_pushlstring(L, result, pos);
  free(result);
  return 1;
}

static int lcrypt_fromhex(lua_State *L)
{
  size_t in_length;
  const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 1, &in_length);
  unsigned char result[in_length];
  int i, d = -1, e = -1, pos = 0;
  for(i = 0; i < (int)in_length; i++)
  {
    if(d == -1)
    {
      if(*in >= '0' && *in <= '9')
        d = *in - '0';
      else if(*in >= 'A' && *in <= 'F')
        d = *in - 'A' + 10;
      else if(*in >= 'a' && *in <= 'f')
        d = *in - 'a' + 10;
    }
    else if(e == -1)
    {
      if(*in >= '0' && *in <= '9')
        e = *in - '0';
      else if(*in >= 'A' && *in <= 'F')
        e = *in - 'A' + 10;
      else if(*in >= 'a' && *in <= 'f')
        e = *in - 'a' + 10;
    }
    if(d >= 0 && e >= 0)
    {
      result[pos++] = d << 4 | e;
      d = e = -1;
    }
    in++;
  }
  lua_pushlstring(L, (char*)result, pos);
  return 1;
}

static int lcrypt_compress(lua_State *L)
{
  int err;
  size_t inlen;
  const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 1, &inlen);
  uLongf outlen = compressBound(inlen);
  unsigned char *out = lcrypt_malloc(L, outlen);
  if(unlikely((err = compress(out, &outlen, in, inlen)) != Z_OK))
  {
    free(out);
    lua_pushstring(L, zError(err));
    return lua_error(L);
  }
  lua_pushlstring(L, (char*)out, outlen);
  free(out);
  return 1;
}

static int lcrypt_uncompress(lua_State *L)
{
  int i, err;
  size_t inlen;
  const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 1, &inlen);
  uLongf outlen = inlen << 1;
  unsigned char *out = NULL;
  for(i = 2; i < 16; i++)
  {
    out = lcrypt_malloc(L, outlen);
    if(likely((err = uncompress(out, &outlen, in, inlen)) == Z_OK)) break;
    if(unlikely(err != Z_BUF_ERROR))
    {
      free(out);
      lua_pushstring(L, zError(err));
      return lua_error(L);
    }
    free(out);
    outlen = inlen << i;
  }
  if(unlikely(err == Z_BUF_ERROR))
  {
    free(out);
    lua_pushstring(L, zError(err));
    return lua_error(L);
  }
  lua_pushlstring(L, (char*)out, outlen);
  free(out);
  return 1;
}

static int lcrypt_base64_encode(lua_State *L)
{
  size_t inlen;
  const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 1, &inlen);
  unsigned long outlen = (inlen + 3) * 4 / 3;
  unsigned char *out = malloc(outlen);
  if(out == NULL) return 0;
  lcrypt_error(L, base64_encode(in, inlen, out, &outlen), out);
  lua_pushlstring(L, (char*)out, outlen);
  free(out);
  return 1;
}

static int lcrypt_base64_decode(lua_State *L)
{
  size_t inlen;
  const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 1, &inlen);
  unsigned long outlen = inlen * 3 / 4;
  unsigned char *out = malloc(outlen);
  if(out == NULL) return 0;
  lcrypt_error(L, base64_decode(in, inlen, out, &outlen), out);
  lua_pushlstring(L, (char*)out, outlen);
  free(out);
  return 1;
}

static int lcrypt_xor(lua_State *L)
{
  int i;
  size_t a_length, b_length;
  const unsigned char *a = (const unsigned char*)luaL_checklstring(L, 1, &a_length);
  const unsigned char *b = (const unsigned char*)luaL_checklstring(L, 2, &b_length);
  unsigned char *c = NULL;
  if(a_length > b_length)
  {
    size_t temp = a_length;
    a_length = b_length;
    b_length = temp;
    c = (void*)a; a = b; b = c;
  }
  c = lcrypt_malloc(L, b_length);
  for(i = 0; i < a_length; i++) c[i] = a[i] ^ b[i];
  for(; i < b_length; i++) c[i] = b[i];
  lua_pushlstring(L, (char*)c, b_length);
  free(c);
  return 1;
}

static int lcrypt_sleep(lua_State *L)
{
  usleep(1000000.0 * luaL_checknumber(L, 1));
  return(0);
}

static int lcrypt_time(lua_State *L)
{
  double ret;
  struct timeval tv;
  gettimeofday(&tv, NULL);
  ret = (double)tv.tv_sec + (double)tv.tv_usec / 1000000.0;
  lua_pushnumber(L, ret);
  return(1);
}

static int lcrypt_random(lua_State *L)
{
  int len = luaL_checkint(L, 1);
  #ifdef USE_NCIPHER
    M_Command command;
    M_Reply reply;
    M_Status rc;
    memset(&command, 0, sizeof(command));
    memset(&reply, 0, sizeof(reply));
    command.cmd = Cmd_GenerateRandom;
    command.args.generaterandom.lenbytes = len;
    if(unlikely((rc = NFastApp_Transact(nfast_conn, NULL, &command, &reply, NULL)) != Status_OK))
    {
      lua_pushstring(L, NF_Lookup(rc, NF_Status_enumtable));
      (void)lua_error(L);
    }
    if(unlikely(reply.status != Status_OK))
    {
      lua_pushstring(L, NF_Lookup(reply.status, NF_Status_enumtable));
      (void)lua_error(L);
    }
    if(unlikely(len != reply.reply.generaterandom.data.len))
    {
      lua_pushstring(L, "Wrong length returned");
      (void)lua_error(L);
    }
    lua_pushlstring(L, reply.reply.generaterandom.data.ptr, len);
    NFastApp_Free_Reply(nfast_app, NULL, NULL, &reply);
  #else
    FILE *fp;
    char *buffer = lcrypt_malloc(L, len);
    if(unlikely((fp = fopen("/dev/urandom", "rb")) == NULL))
    {
      lua_pushstring(L, "Unable to open /dev/urandom.");
      (void)lua_error(L);
    }
    if(unlikely(fread(buffer, len, 1, fp) != 1))
    {
      fclose(fp);
      lua_pushstring(L, "Unable to read /dev/urandom.");
      (void)lua_error(L);
    }
    fclose(fp);
    lua_pushlstring(L, buffer, len);
    free(buffer);
  #endif
  return 1;
}

static FILE *lgetfile(lua_State *L, int index)
{
  FILE **fp = lua_touserdata(L, index);
  if(unlikely(fp == NULL)) return NULL;
  if(lua_getmetatable(L, index))
  {
    lua_getfield(L, LUA_REGISTRYINDEX, LUA_FILEHANDLE);
    if(lua_rawequal(L, -1, -2))
    {
      lua_pop(L, 2);
      return *fp;
    }
    lua_pop(L, 2);
  }
  return NULL;
}

static int lcrypt_tcsetattr(lua_State* L)
{
  struct termios old, new;
  FILE *fp = lgetfile(L, 1);
  if(unlikely(fp == NULL)) return 0;
  if(unlikely(tcgetattr(fileno(fp), &old) != 0)) return 0;
  new = old;
  new.c_iflag = luaL_optint(L, 2, old.c_iflag);
  new.c_oflag = luaL_optint(L, 3, old.c_oflag);
  new.c_cflag = luaL_optint(L, 4, old.c_cflag);
  new.c_lflag = luaL_optint(L, 5, old.c_lflag);
  if(unlikely(tcsetattr(fileno(fp), TCSAFLUSH, &new) != 0)) return 0;
  lua_pushinteger(L, new.c_iflag);
  lua_pushinteger(L, new.c_oflag);
  lua_pushinteger(L, new.c_cflag);
  lua_pushinteger(L, new.c_lflag);
  return 4;
}

static int lcrypt_flag_add(lua_State *L)
{
  uint32_t a = luaL_checkint(L, 1);
  uint32_t b = luaL_checkint(L, 2);
  lua_pushinteger(L, a | b);
  return 1;
}

static int lcrypt_flag_remove(lua_State *L)
{
  uint32_t a = luaL_checkint(L, 1);
  uint32_t b = luaL_checkint(L, 2);
  lua_pushinteger(L, a & ~b);
  return 1;
}

#ifndef USE_NCIPHER

typedef struct
{
  int fd;
  int pid;
  char *command;
} lcrypt_spawn_t;

static int lcrypt_spawn(lua_State *L)
{
  int fd, pid, argc;
  #define MAX_ARGUMENT 128
  const char *command = luaL_checkstring(L, 1); 
  char *cmd = strdup(command);
  char *pos = cmd, *p;
  char *argv[MAX_ARGUMENT];
  for(argc = 0; argc < MAX_ARGUMENT-1; argc++)
  {
    // eat whitespace
    while(*pos == ' ' || *pos == '\t' || *pos == '\n' || *pos == '\r')
    {
      if(*pos == '\\') for(p = pos; *p != '\0'; p++) *p = *(p + 1);
      pos++;
    }
    // start of argument found
    argv[argc] = pos;
    if(*argv[argc] == '"' || *argv[argc] == '\'') // quoted argument
    {
      pos++;
      while(*pos != *argv[argc] && *pos != '\0')
      {
        if(*pos == '\\') for(p = pos; *p != '\0'; p++) *p = *(p + 1);
        pos++;
      }
      argv[argc]++;
    }
    else // non-quoted argument
    {
      while(*pos != ' ' && *pos != '\t' && *pos != '\n' && *pos != '\r' && *pos != '\0')
      {
        if(*pos == '\\') for(p = pos; *p != '\0'; p++) *p = *(p + 1);
        pos++;
      }
    }
    if(*pos == '\0') break;
    *pos++ = '\0';
  }
  argv[++argc] = NULL;

  errno = 0;
  pid = forkpty(&fd, NULL, NULL, NULL);
  if(pid == 0) // child
  {
    execvp(argv[0], argv);
    // if we get here, it's an error!
    perror("'unable to spawn process");
    return 0;
  }
  else if(errno != 0)
  {
    lua_pushnil(L);
    lua_pushstring(L, strerror(errno));
    return 2;
  }
  else
  {
    lcrypt_spawn_t *lsp = lua_newuserdata(L, sizeof(lcrypt_spawn_t));
    lsp->fd = fd;
    lsp->pid = pid;
    lsp->command = cmd;
    luaL_getmetatable(L, "LSPAWN");
    (void)lua_setmetatable(L, -2);
    return 1;
  }
}

static int lcrypt_spawn_close(lua_State *L)
{
  lcrypt_spawn_t *lsp = (lcrypt_spawn_t*)luaL_checkudata(L, 1, "LSPAWN");
  if(lsp->pid > 0)
  {
    (void)kill(lsp->pid, SIGQUIT);
    lsp->pid = -1;
  }
  if(lsp->fd >= 0)
  {
    (void)close(lsp->fd);
    lsp->fd = -1;
  }
  if(lsp->command != NULL)
  {
    free(lsp->command);
    lsp->command = NULL;
  }
  return 0;
}

static int lcrypt_spawn_read(lua_State *L)
{
  lcrypt_spawn_t *lsp = (lcrypt_spawn_t*)luaL_checkudata(L, 1, "LSPAWN");
  int count = luaL_optint(L, 2, 4096);
  char *buffer;
  if(lsp->fd < 0)
  {
    lua_pushstring(L, "Spawn closed");
    lua_error(L);
    return 0;
  }
  if((buffer = malloc(count)) == NULL)
  {
    lua_pushnil(L);
    lua_pushstring(L, "Unable to allocate memory");
    return 2;
  }
  count = read(lsp->fd, buffer, count);
  if(errno != 0)
  {
    free(buffer);
    lua_pushnil(L);
    lua_pushstring(L, strerror(errno));
    return 2;
  }
  lua_pushlstring(L, buffer, count);
  free(buffer);
  return 1;
}

static int lcrypt_spawn_write(lua_State *L)
{
  lcrypt_spawn_t *lsp = (lcrypt_spawn_t*)luaL_checkudata(L, 1, "LSPAWN");
  size_t in_length = 0;
  const char* in = luaL_checklstring(L, 2, &in_length);
  if(lsp->fd < 0)
  {
    lua_pushstring(L, "closed");
    lua_error(L);
    return 0;
  }
  write(lsp->fd, in, in_length);
  if(errno != 0)
  {
    lua_pushstring(L, strerror(errno));
    return 1;
  }
  return 0;
}

static int lcrypt_spawn_index(lua_State *L)
{
  (void)luaL_checkudata(L, 1, "LSPAWN");
  const char *index = luaL_checkstring(L, 2);
  if(strcmp(index, "read") == 0)
    lua_pushcfunction(L, lcrypt_spawn_read);
  else if(strcmp(index, "write") == 0)
    lua_pushcfunction(L, lcrypt_spawn_write);
  else if(strcmp(index, "close") == 0)
    lua_pushcfunction(L, lcrypt_spawn_close);
  else
    return 0;
  return 1;
}

static const luaL_Reg lcrypt_spawn_flib[] =
{
  {"__gc",  lcrypt_spawn_close},
  {NULL, NULL}
};

#endif

static const luaL_Reg lcryptlib[] =
{
  {"tohex",         lcrypt_tohex},
  {"fromhex",       lcrypt_fromhex},
  {"compress",      lcrypt_compress},
  {"uncompress",    lcrypt_uncompress},
  {"base64_encode", lcrypt_base64_encode},
  {"base64_decode", lcrypt_base64_decode},
  {"xor",           lcrypt_xor},
  {"sleep",         lcrypt_sleep},
  {"time",          lcrypt_time},
  {"random",        lcrypt_random},
  {"tcsetattr",     lcrypt_tcsetattr},
  {"flag_add",      lcrypt_flag_add},
  {"flag_remove",   lcrypt_flag_remove},
  #ifndef USE_NCIPHER
    {"spawn",         lcrypt_spawn},
  #endif
  {NULL, NULL}
};

int luaopen_lcrypt(lua_State *L);
int luaopen_lcrypt(lua_State *L)
{
  luaL_register(L, "lcrypt", lcryptlib);

  #ifndef USE_NCIPHER
    (void)luaL_newmetatable(L, "LSPAWN");
    lua_pushliteral(L, "__index");
    lua_pushcfunction(L, lcrypt_spawn_index);
    lua_rawset(L, -3);
    luaL_register(L, NULL, lcrypt_spawn_flib);
  #endif

  lua_getglobal(L, "lcrypt");

  lcrypt_start_ciphers(L);
  lcrypt_start_hashes(L);
  lcrypt_start_math(L);
  lcrypt_start_bits(L);

  lua_pushstring(L, "iflag");
  lua_newtable(L);
  ADD_CONSTANT(L, IGNBRK);  ADD_CONSTANT(L, BRKINT);  ADD_CONSTANT(L, IGNPAR);  ADD_CONSTANT(L, PARMRK);
  ADD_CONSTANT(L, INPCK);   ADD_CONSTANT(L, ISTRIP);  ADD_CONSTANT(L, INLCR);   ADD_CONSTANT(L, IGNCR);
  ADD_CONSTANT(L, ICRNL);   ADD_CONSTANT(L, IXON);    ADD_CONSTANT(L, IXANY);   ADD_CONSTANT(L, IXOFF);
  lua_settable(L, -3);

  lua_pushstring(L, "oflag");
  lua_newtable(L);
  #ifdef OLCUC
    ADD_CONSTANT(L, OLCUC);
  #endif
  #ifdef OFILL
    ADD_CONSTANT(L, OFILL);
  #endif
  #ifdef OFDEL
    ADD_CONSTANT(L, OFDEL);
  #endif
  #ifdef NLDLY
    ADD_CONSTANT(L, NLDLY);
  #endif
  #ifdef CRDLY
    ADD_CONSTANT(L, CRDLY);
  #endif
  #ifdef TABDLY
    ADD_CONSTANT(L, TABDLY);
  #endif
  #ifdef BSDLY
    ADD_CONSTANT(L, BSDLY);
  #endif
  #ifdef VTDLY
    ADD_CONSTANT(L, VTDLY);
  #endif
  #ifdef FFDLY
    ADD_CONSTANT(L, FFDLY);
  #endif
  ADD_CONSTANT(L, OPOST);   ADD_CONSTANT(L, ONLCR);   ADD_CONSTANT(L, OCRNL);   ADD_CONSTANT(L, ONOCR);
  ADD_CONSTANT(L, ONLRET);
  lua_settable(L, -3);

  lua_pushstring(L, "cflag");
  lua_newtable(L);
  ADD_CONSTANT(L, CS5);     ADD_CONSTANT(L, CS6);     ADD_CONSTANT(L, CS7);     ADD_CONSTANT(L, CS8);
  ADD_CONSTANT(L, CSTOPB);  ADD_CONSTANT(L, CREAD);   ADD_CONSTANT(L, PARENB);  ADD_CONSTANT(L, PARODD);
  ADD_CONSTANT(L, HUPCL);   ADD_CONSTANT(L, CLOCAL);
  lua_settable(L, -3);

  lua_pushstring(L, "lflag");
  lua_newtable(L);
  ADD_CONSTANT(L, ISIG);    ADD_CONSTANT(L, ICANON);  ADD_CONSTANT(L, ECHO);    ADD_CONSTANT(L, ECHOE);
  ADD_CONSTANT(L, ECHOK);   ADD_CONSTANT(L, ECHONL);  ADD_CONSTANT(L, NOFLSH);  ADD_CONSTANT(L, TOSTOP);
  ADD_CONSTANT(L, IEXTEN);
  lua_settable(L, -3);

  lua_pop(L, 1);
  return 1;
}
