static void lcrypt_ivlength(lua_State *L, int cipher, size_t *iv_length)
{
  if(unlikely(*iv_length < (size_t)cipher_descriptor[cipher].block_length))
  {
    lua_pushstring(L, "IV wrong length");
    (void)lua_error(L);
  }
  *iv_length = (size_t)cipher_descriptor[cipher].block_length;
}

#define LCRYPT_CIPHER_XXX_START(NAME, name)                                                     \
static int lcrypt_cipher_ ## name (lua_State *L)                                                \
{                                                                                               \
  symmetric_ ## NAME *skey;                                                                     \
  int err = CRYPT_OK, *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");                         \
  size_t key_length, iv_length;                                                                 \
  const unsigned char *key = (const unsigned char *)luaL_checklstring(L, 2, &key_length);       \
  const unsigned char *iv = (const unsigned char *)luaL_checklstring(L, 3, &iv_length);         \
  lcrypt_ivlength(L, *cipher, &iv_length);                                                      \
  skey = lua_newuserdata(L, sizeof(symmetric_ ## NAME));                                        \
  luaL_getmetatable(L, "LCRYPT_CIPHER_" #NAME);                                                 \
  (void)lua_setmetatable(L, -2);                                                                \
  memset(skey, 0, sizeof(symmetric_ ## NAME));                                                  \
  if(unlikely((err = name ## _start(*cipher, iv, key, (int)key_length, 0, skey)) != CRYPT_OK))  \
  {                                                                                             \
    skey->cipher = -1;                                                                          \
    lcrypt_error(L, err, NULL);                                                                 \
  }                                                                                             \
  return 1;                                                                                     \
}

#define LCRYPT_CIPHER_XXX_INDEX(NAME, _name)                                                    \
static int lcrypt_cipher_ ## _name ## _index(lua_State *L)                                      \
{                                                                                               \
  symmetric_ ## NAME *skey = luaL_checkudata(L, 1, "LCRYPT_CIPHER_" #NAME);                     \
  if(unlikely(skey->cipher < 0)) return 0;                                                      \
  const char *index = luaL_checkstring(L, 2);                                                   \
  if(strcmp(index, "type") == 0) { lua_pushstring(L, "LCRYPT_CIPHER_" #NAME); return 1; }       \
  if(strcmp(index, "iv") == 0)                                                                  \
  {                                                                                             \
    unsigned char iv[MAXBLOCKSIZE];                                                             \
    unsigned long length = MAXBLOCKSIZE;                                                        \
    lcrypt_error(L, _name ## _getiv(iv, &length, skey), NULL);                                  \
    lua_pushlstring(L, (char*)iv, (size_t)length);                                              \
    return 1;                                                                                   \
  }                                                                                             \
  if(strcmp(index, "block_size") == 0)                                                          \
  {                                                                                             \
    lua_pushinteger(L, cipher_descriptor[skey->cipher].block_length);                           \
    return 1;                                                                                   \
  }                                                                                             \
  if(strcmp(index, "encrypt") == 0)                                                             \
  {                                                                                             \
    lua_pushcfunction(L, lcrypt_cipher_ ## _name ## _encrypt);                                  \
    return 1;                                                                                   \
  }                                                                                             \
  if(strcmp(index, "decrypt") == 0)                                                             \
  {                                                                                             \
    lua_pushcfunction(L, lcrypt_cipher_ ## _name ## _decrypt);                                  \
    return 1;                                                                                   \
  }                                                                                             \
  if(strcmp(index, "cipher_name") == 0)                                                         \
  {                                                                                             \
    lua_pushstring(L, cipher_descriptor[skey->cipher].name);                                    \
    return 1;                                                                                   \
  }                                                                                             \
  if(strcmp(index, "mode_name") == 0)                                                           \
  {                                                                                             \
    lua_pushstring(L, #_name);                                                                  \
    return 1;                                                                                   \
  }                                                                                             \
  return 0;                                                                                     \
}

#define LCRYPT_CIPHER_XXX_NEWINDEX(NAME, name)                                                  \
static int lcrypt_cipher_ ## name ## _newindex(lua_State *L)                                    \
{                                                                                               \
  symmetric_ ## NAME *skey = luaL_checkudata(L, 1, "LCRYPT_CIPHER_" #NAME);                     \
  size_t v_length = 0;                                                                          \
  const char *index = luaL_checkstring(L, 2);                                                   \
  const unsigned char *v = (const unsigned char *)luaL_checklstring(L, 3, &v_length);           \
  if(unlikely(skey->cipher < 0)) return 0;                                                      \
  if(strcmp(index, "iv") == 0)                                                                  \
  {                                                                                             \
    lcrypt_error(L, name ## _setiv(v, v_length, skey), NULL);                                   \
  }                                                                                             \
  return 0;                                                                                     \
}

#define LCRYPT_CIPHER_XXX_GC(NAME, name)                                                        \
static int lcrypt_cipher_ ## name ## _gc(lua_State *L)                                          \
{                                                                                               \
  symmetric_ ## NAME *skey = luaL_checkudata(L, 1, "LCRYPT_CIPHER_" #NAME);                     \
  if(likely(skey->cipher != -1)) lcrypt_error(L, name ## _done(skey), NULL);                    \
  return 0;                                                                                     \
}

#define LCRYPT_CIPHER_XXX_ENCRYPT(NAME, name)                                                   \
static int lcrypt_cipher_ ## name ## _encrypt(lua_State *L)                                     \
{                                                                                               \
  symmetric_ ## NAME *skey = luaL_checkudata(L, 1, "LCRYPT_CIPHER_" #NAME);                     \
  if(likely(skey->cipher >= 0))                                                                 \
  {                                                                                             \
    size_t in_length = 0;                                                                       \
    const unsigned char *in = (const unsigned char *)luaL_checklstring(L, 2, &in_length);       \
    int i, block_length = cipher_descriptor[skey->cipher].block_length;                         \
    int padding_length = in_length + block_length - in_length % block_length;                   \
printf("in_length = %d, padding_length = %d\n", in_length, padding_length);                     \
    unsigned char *out = lcrypt_malloc(L, 2 * (in_length + padding_length));                    \
    memcpy(out + in_length + padding_length, in, in_length);                                    \
    memset(out + in_length + padding_length + in_length, padding_length, padding_length);       \
    in = out + in_length + padding_length;                                                      \
    for(i = 0; i < in_length + padding_length; i += block_length)                               \
    {                                                                                           \
      lcrypt_error(L, name ## _encrypt(in + i, out + i, block_length, skey), out);              \
    }                                                                                           \
    lua_pushlstring(L, (char*)out, in_length + padding_length);                                 \
    free(out);                                                                                  \
    return 1;                                                                                   \
  }                                                                                             \
  return 0;                                                                                     \
}

#define LCRYPT_CIPHER_XXX_DECRYPT(NAME, name)                                                   \
static int lcrypt_cipher_ ## name ## _decrypt(lua_State *L)                                     \
{                                                                                               \
  symmetric_ ## NAME *skey = luaL_checkudata(L, 1, "LCRYPT_CIPHER_" #NAME);                     \
  if(likely(skey->cipher >= 0))                                                                 \
  {                                                                                             \
    size_t in_length = 0;                                                                       \
    const unsigned char *in = (const unsigned char *)luaL_checklstring(L, 2, &in_length);       \
    unsigned char *out = lcrypt_malloc(L, in_length);                                           \
    lcrypt_error(L, name ## _decrypt(in, out, in_length, skey), out);                           \
    in_length -= out[in_length - 1];                                                            \
    lua_pushlstring(L, (char*)out, in_length);                                                  \
    free(out);                                                                                  \
    return 1;                                                                                   \
  }                                                                                             \
  return 0;                                                                                     \
}

#define LCRYPT_CIPHER_XXX(NAME, name)                                                           \
  LCRYPT_CIPHER_XXX_START(NAME, name)                                                           \
  LCRYPT_CIPHER_XXX_NEWINDEX(NAME, name)                                                        \
  LCRYPT_CIPHER_XXX_GC(NAME, name)                                                              \
  LCRYPT_CIPHER_XXX_ENCRYPT(NAME, name)                                                         \
  LCRYPT_CIPHER_XXX_DECRYPT(NAME, name)                                                         \
  LCRYPT_CIPHER_XXX_INDEX(NAME, name)

static int lcrypt_cipher_ecb(lua_State *L)
{
  int err = CRYPT_OK, *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");
  size_t key_length;
  const unsigned char *key = (const unsigned char *)luaL_checklstring(L, 2, &key_length);
  symmetric_ECB *skey = lua_newuserdata(L, sizeof(symmetric_ECB));
  memset(skey, 0, sizeof(symmetric_ECB));
  luaL_getmetatable(L, "LCRYPT_CIPHER_ECB");
  (void)lua_setmetatable(L, -2);
  if(unlikely((err = ecb_start(*cipher, key, (int)key_length, 0, skey)) != CRYPT_OK))
  {
    skey->cipher = -1;
    lcrypt_error(L, err, NULL);
  }
  return 1;
}

LCRYPT_CIPHER_XXX_ENCRYPT(ECB, ecb)
LCRYPT_CIPHER_XXX_DECRYPT(ECB, ecb)

static int lcrypt_cipher_ecb_index(lua_State *L)
{
  symmetric_ECB *skey = luaL_checkudata(L, 1, "LCRYPT_CIPHER_ECB");
  const char *index = luaL_checkstring(L, 2);
  if(unlikely(skey->cipher < 0)) return 0;
  if(strcmp(index, "type") == 0) { lua_pushstring(L, "LCRYPT_CIPHER_ECB"); return 1; }
  if(strcmp(index, "encrypt") == 0)
  {
    lua_pushcfunction(L, lcrypt_cipher_ecb_encrypt);
    return 1;
  }
  if(strcmp(index, "decrypt") == 0)
  {
    lua_pushcfunction(L, lcrypt_cipher_ecb_decrypt);
    return 1;
  }
  if(strcmp(index, "cipher_name") == 0)
  {
    lua_pushstring(L, cipher_descriptor[skey->cipher].name);
    return 1;
  }
  if(strcmp(index, "mode_name") == 0)
  {
    lua_pushstring(L, "ecb");
    return 1;
  }
  return 0;
}

static int lcrypt_cipher_ecb_newindex(lua_State *L)
{
  luaL_checkudata(L, 1, "LCRYPT_CIPHER_ECB");
  return 0;
}

LCRYPT_CIPHER_XXX_GC(ECB, ecb)

static int lcrypt_cipher_ctr(lua_State *L)
{
  symmetric_CTR *skey;
  int err = CRYPT_OK, *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");
  size_t key_length, iv_length;
  const unsigned char *key = (const unsigned char *)luaL_checklstring(L, 2, &key_length);
  const unsigned char *iv = (const unsigned char *)luaL_checklstring(L, 3, &iv_length);
  const char *endian = luaL_optstring(L, 4, "big");
  lcrypt_ivlength(L, *cipher, &iv_length);
  skey = lua_newuserdata(L, sizeof(symmetric_CTR));
  memset(skey, 0, sizeof(symmetric_CTR));
  luaL_getmetatable(L, "LCRYPT_CIPHER_CTR");
  (void)lua_setmetatable(L, -2);
  if(strcmp(endian, "big") == 0)
  {
    err = ctr_start(*cipher, iv, key, (int)key_length, 0, CTR_COUNTER_BIG_ENDIAN, skey);
  }
  else if(strcmp(endian, "little") == 0)
  {
    err = ctr_start(*cipher, iv, key, (int)key_length, 0, CTR_COUNTER_LITTLE_ENDIAN, skey);
  }
  else
  {
    lua_pushstring(L, "Unknown endian");
    (void)lua_error(L);
  }
  if(unlikely(err != CRYPT_OK))
  {
    skey->cipher = -1;
    lcrypt_error(L, err, NULL);
  }
  return 1;
}

LCRYPT_CIPHER_XXX_ENCRYPT(CTR, ctr)
LCRYPT_CIPHER_XXX_DECRYPT(CTR, ctr)
LCRYPT_CIPHER_XXX_INDEX(CTR, ctr)
LCRYPT_CIPHER_XXX_NEWINDEX(CTR, ctr)
LCRYPT_CIPHER_XXX_GC(CTR, ctr)

LCRYPT_CIPHER_XXX(CBC, cbc)
LCRYPT_CIPHER_XXX(CFB, cfb)
LCRYPT_CIPHER_XXX(OFB, ofb)

static int lcrypt_cipher_lrw(lua_State *L)
{
  symmetric_LRW *skey;
  int err = CRYPT_OK, *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");
  size_t key_length, iv_length, tweak_length;
  const unsigned char *key = (const unsigned char *)luaL_checklstring(L, 2, &key_length);
  const unsigned char *iv = (const unsigned char *)luaL_checklstring(L, 3, &iv_length);
  const unsigned char *tweak = (const unsigned char *)luaL_checklstring(L, 4, &tweak_length);
  if(unlikely(tweak_length != 16))
  {
    lua_pushstring(L, "Tweak must be 16 characters");
    (void)lua_error(L);
  }
  lcrypt_ivlength(L, *cipher, &iv_length);
  skey = lua_newuserdata(L, sizeof(symmetric_LRW));
  memset(skey, 0, sizeof(symmetric_LRW));
  luaL_getmetatable(L, "LCRYPT_CIPHER_LRW");
  (void)lua_setmetatable(L, -2);
  if(unlikely((err = lrw_start(*cipher, iv, key, (int)key_length, tweak, 0, skey)) != CRYPT_OK))
  {
    skey->cipher = -1;
    lcrypt_error(L, err, NULL);
  }
  return 1;
}

LCRYPT_CIPHER_XXX_ENCRYPT(LRW, lrw)
LCRYPT_CIPHER_XXX_DECRYPT(LRW, lrw)
LCRYPT_CIPHER_XXX_INDEX(LRW, lrw)
LCRYPT_CIPHER_XXX_NEWINDEX(LRW, lrw)
LCRYPT_CIPHER_XXX_GC(LRW, lrw)

static int lcrypt_cipher_f8(lua_State *L)
{
  symmetric_F8 *skey;
  int err = CRYPT_OK, *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");
  size_t key_length, iv_length, salt_length;
  const unsigned char *key = (const unsigned char *)luaL_checklstring(L, 2, &key_length);
  const unsigned char *iv = (const unsigned char *)luaL_checklstring(L, 3, &iv_length);
  const unsigned char *salt = (const unsigned char *)luaL_checklstring(L, 4, &salt_length);
  lcrypt_ivlength(L, *cipher, &iv_length);
  skey = lua_newuserdata(L, sizeof(symmetric_F8));
  memset(skey, 0, sizeof(symmetric_F8));
  luaL_getmetatable(L, "LCRYPT_CIPHER_F8");
  (void)lua_setmetatable(L, -2);
  if(unlikely((err = f8_start(*cipher, iv, key, (int)key_length, salt, salt_length, 0, skey)) != CRYPT_OK))
  {
    skey->cipher = -1;
    lcrypt_error(L, err, NULL);
  }
  return 1;
}

LCRYPT_CIPHER_XXX_ENCRYPT(F8, f8)
LCRYPT_CIPHER_XXX_DECRYPT(F8, f8)
LCRYPT_CIPHER_XXX_INDEX(F8, f8)
LCRYPT_CIPHER_XXX_NEWINDEX(F8, f8)
LCRYPT_CIPHER_XXX_GC(F8, f8)

#undef LCRYPT_CIPHER_XXX
#undef LCRYPT_CIPHER_XXX_START
#undef LCRYPT_CIPHER_XXX_INDEX
#undef LCRYPT_CIPHER_XXX_NEWINDEX
#undef LCRYPT_CIPHER_XXX_GC


static int lcrypt_cipher_key_size(lua_State *L)
{
  int *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");
  int keysize = luaL_checkint(L, 2);
  lcrypt_error(L, cipher_descriptor[*cipher].keysize(&keysize), NULL);
  lua_pushinteger(L, keysize);
  return 1;
}

static int lcrypt_cipher_index(lua_State *L)
{
  int *cipher = luaL_checkudata(L, 1, "LCRYPT_CIPHER");
  const char *index = luaL_checkstring(L, 2);

  #define RETURN_BLOCK_MODE(name)  { if(strcmp(index, #name) == 0) { lua_pushcfunction(L, lcrypt_cipher_ ## name); return 1; } }
  RETURN_BLOCK_MODE(ecb);  RETURN_BLOCK_MODE(cbc);  RETURN_BLOCK_MODE(ctr);  RETURN_BLOCK_MODE(cfb);
  RETURN_BLOCK_MODE(ofb);  RETURN_BLOCK_MODE(f8);
  if(cipher_descriptor[*cipher].block_length == 16) RETURN_BLOCK_MODE(lrw);
  #undef RETURN_BLOCK_MODE

  if(strcmp(index, "type") == 0) { lua_pushstring(L, "LCRYPT_CIPHER"); return 1; }
  if(strcmp(index, "name") == 0) { lua_pushstring(L, cipher_descriptor[*cipher].name); return 1; }
  if(strcmp(index, "min_key_length") == 0) { lua_pushinteger(L, cipher_descriptor[*cipher].min_key_length); return 1; }
  if(strcmp(index, "max_key_length") == 0) { lua_pushinteger(L, cipher_descriptor[*cipher].max_key_length); return 1; }
  if(strcmp(index, "block_length") == 0) { lua_pushinteger(L, cipher_descriptor[*cipher].block_length); return 1; }
  if(strcmp(index, "key_size") == 0) { lua_pushcfunction(L, lcrypt_cipher_key_size); return 1; }
  if(strcmp(index, "modes") == 0)
  {
    lua_newtable(L);
    #define ADD_MODE(i, name) { lua_pushinteger(L, i); lua_pushstring(L, #name); lua_settable(L, -3); }
    ADD_MODE(1, ecb);   ADD_MODE(2, cbc);   ADD_MODE(3, ctr);   ADD_MODE(4, cfb);
    ADD_MODE(5, ofb);   ADD_MODE(6, f8);
    if(cipher_descriptor[*cipher].block_length == 16) ADD_MODE(7, lrw);
    #undef ADD_MODE
    return 1;
  }

  return 0;
}

static const struct luaL_reg lcrypt_cipher_flib[] =
{
  { "__index", lcrypt_cipher_index },
  { NULL, NULL }
};

#define CIPHER_MODE_FLIB(mode)                                    \
static const struct luaL_reg lcrypt_cipher_ ## mode ## _flib[] =  \
{                                                                 \
  { "__index", lcrypt_cipher_ ## mode ## _index },                \
  { "__newindex", lcrypt_cipher_ ## mode ## _newindex },          \
  { "__gc", lcrypt_cipher_ ## mode ## _gc },                      \
  { NULL, NULL }                                                  \
};
CIPHER_MODE_FLIB(ecb);  CIPHER_MODE_FLIB(cbc);  CIPHER_MODE_FLIB(ctr);
CIPHER_MODE_FLIB(cfb);  CIPHER_MODE_FLIB(ofb);  CIPHER_MODE_FLIB(f8);
CIPHER_MODE_FLIB(lrw);
#undef CIPHER_MODE_FLIB

static void lcrypt_start_ciphers(lua_State *L)
{
  (void)luaL_newmetatable(L, "LCRYPT_CIPHER");  (void)luaL_register(L, NULL, lcrypt_cipher_flib);  lua_pop(L, 1);
  lua_pushstring(L, "ciphers");
  lua_newtable(L);
  #define ADD_CIPHER(L,name)                              \
  {                                                       \
    lua_pushstring(L, #name);                             \
    int *cipher_index = lua_newuserdata(L, sizeof(int));  \
    luaL_getmetatable(L, "LCRYPT_CIPHER");                \
    (void)lua_setmetatable(L, -2);                        \
    *cipher_index = register_cipher(&name ## _desc);      \
    lua_settable(L, -3);                                  \
  }
  ADD_CIPHER(L, blowfish);  ADD_CIPHER(L, xtea);    ADD_CIPHER(L, rc2);     ADD_CIPHER(L, rc5);
  ADD_CIPHER(L, rc6);       ADD_CIPHER(L, saferp);  ADD_CIPHER(L, aes);     ADD_CIPHER(L, twofish);
  ADD_CIPHER(L, des);       ADD_CIPHER(L, des3);    ADD_CIPHER(L, cast5);   ADD_CIPHER(L, noekeon);
  ADD_CIPHER(L, skipjack);  ADD_CIPHER(L, anubis);  ADD_CIPHER(L, khazad);  ADD_CIPHER(L, kseed);
  ADD_CIPHER(L, kasumi);
  #undef ADD_CIPHER
  lua_settable(L, -3);

  #define NEW_MODE_TYPE(NAME, name) (void)luaL_newmetatable(L, "LCRYPT_CIPHER_" #NAME);  (void)luaL_register(L, NULL, lcrypt_cipher_ ## name ## _flib);  lua_pop(L, 1);
  NEW_MODE_TYPE(ECB, ecb);  NEW_MODE_TYPE(CBC, cbc);  NEW_MODE_TYPE(CTR, ctr);
  NEW_MODE_TYPE(CFB, cfb);  NEW_MODE_TYPE(OFB, ofb);  NEW_MODE_TYPE(F8, f8);
  NEW_MODE_TYPE(LRW, lrw);
  #undef NEW_MODE_TYPE
}
