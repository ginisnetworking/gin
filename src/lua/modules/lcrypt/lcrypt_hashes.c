typedef struct
{
  int hash;
  hash_state state;
} lcrypt_hash;

static int lcrypt_hash_add(lua_State *L)
{
  lcrypt_hash *h = luaL_checkudata(L, 1, "LCRYPT_HASH_STATE");
  if(likely(h->hash >= 0))
  {
    size_t in_length = 0;
    const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 2, &in_length);
    lcrypt_error(L, hash_descriptor[h->hash].process(&h->state, in, (unsigned long)in_length), NULL);
  }
  return 0;
}

static int lcrypt_hash_done(lua_State *L)
{
  lcrypt_hash *h = luaL_checkudata(L, 1, "LCRYPT_HASH_STATE");
  if(likely(h->hash >= 0))
  {
    unsigned char out[hash_descriptor[h->hash].hashsize];
    lcrypt_error(L, hash_descriptor[h->hash].done(&h->state, out), NULL);
    lua_pushlstring(L, (char*)out, hash_descriptor[h->hash].hashsize);
  }
  memset(h, 0, sizeof(lcrypt_hash));
  h->hash = -1;
  return 1;
}

static int lcrypt_hash_state_gc(lua_State *L)
{
  lcrypt_hash *h = luaL_checkudata(L, 1, "LCRYPT_HASH_STATE");
  if(likely(h->hash >= 0))
  {
    unsigned char out[hash_descriptor[h->hash].hashsize];
    lcrypt_error(L, hash_descriptor[h->hash].done(&h->state, out), NULL);
    memset(h, 0, sizeof(lcrypt_hash));
    h->hash = -1;
  }
  return 0;
}

static int lcrypt_hash_hash(lua_State *L)
{
  int *hash = luaL_checkudata(L, 1, "LCRYPT_HASH");
  size_t in_length = 0;
  const unsigned char *in = (const unsigned char*)luaL_optlstring(L, 2, "", &in_length);
  lcrypt_hash *h = lua_newuserdata(L, sizeof(lcrypt_hash));
  luaL_getmetatable(L, "LCRYPT_HASH_STATE");
  (void)lua_setmetatable(L, -2);
  h->hash = -1;
  lcrypt_error(L, hash_descriptor[*hash].init(&h->state), NULL);
  if(in_length > 0)
  {
    lcrypt_error(L, hash_descriptor[*hash].process(&h->state, in, (unsigned long)in_length), NULL);
  }
  h->hash = *hash;
  return 1;
}

static int lcrypt_hash_hmac(lua_State *L)
{
  int *hash = luaL_checkudata(L, 1, "LCRYPT_HASH");
  size_t key_length = 0, in_length = 0;
  const unsigned char *key = (const unsigned char*)luaL_checklstring(L, 2, &key_length);
  const unsigned char *in = (const unsigned char*)luaL_optlstring(L, 3, "", &in_length);
  hmac_state *h = lua_newuserdata(L, sizeof(hmac_state));
  luaL_getmetatable(L, "LCRYPT_HMAC_STATE");
  (void)lua_setmetatable(L, -2);
  lcrypt_error(L, hmac_init(h, *hash, key, key_length), NULL);
  if(in_length > 0)
  {
    lcrypt_error(L, hmac_process(h, in, (unsigned long)in_length), NULL);
  }
  return 1;
}

static int lcrypt_hmac_add(lua_State *L)
{
  hmac_state *h = luaL_checkudata(L, 1, "LCRYPT_HMAC_STATE");
  if(likely(h->hash >= 0))
  {
    size_t in_length = 0;
    const unsigned char *in = (const unsigned char*)luaL_checklstring(L, 2, &in_length);
    lcrypt_error(L, hmac_process(h, in, (unsigned long)in_length), NULL);
  }
  return 0;
}

static int lcrypt_hmac_done(lua_State *L)
{
  hmac_state *h = luaL_checkudata(L, 1, "LCRYPT_HMAC_STATE");
  if(likely(h->hash >= 0))
  {
    unsigned long out_length = hash_descriptor[h->hash].hashsize;
    unsigned char out[out_length];
    lcrypt_error(L, hmac_done(h, out, &out_length), NULL);
    lua_pushlstring(L, (char*)out, out_length);
    memset(h, 0, sizeof(hmac_state));
    h->hash = -1;
    return 1;
  }
  return 0;
}

static int lcrypt_hmac_state_gc(lua_State *L)
{
  hmac_state *h = luaL_checkudata(L, 1, "LCRYPT_HMAC_STATE");
  if(likely(h->hash >= 0))
  {
    unsigned long out_length = hash_descriptor[h->hash].hashsize;
    unsigned char out[out_length];
    lcrypt_error(L, hmac_done(h, out, &out_length), NULL);
    memset(h, 0, sizeof(hmac_state));
    h->hash = -1;
  }
  return 0;
}

static int lcrypt_hash_index(lua_State *L)
{
  int *h = luaL_checkudata(L, 1, "LCRYPT_HASH");
  const char *index = luaL_checkstring(L, 2);
  if(strcmp(index, "type") == 0) { lua_pushstring(L, "LCRYPT_HASH"); return 1; }
  if(strcmp(index, "name") == 0) { lua_pushstring(L, hash_descriptor[*h].name); return 1; }
  if(strcmp(index, "hash_size") == 0) { lua_pushinteger(L, hash_descriptor[*h].hashsize); return 1; }
  if(strcmp(index, "block_size") == 0) { lua_pushinteger(L, hash_descriptor[*h].blocksize); return 1; }
  if(strcmp(index, "hash") == 0) { lua_pushcfunction(L, lcrypt_hash_hash); return 1; }
  if(strcmp(index, "hmac") == 0) { lua_pushcfunction(L, lcrypt_hash_hmac); return 1; }
  return 0;
}

static int lcrypt_hash_state_index(lua_State *L)
{
  lcrypt_hash *h = luaL_checkudata(L, 1, "LCRYPT_HASH_STATE");
  if(likely(h->hash >= 0))
  {
    const char *index = luaL_checkstring(L, 2);
    if(strcmp(index, "type") == 0) { lua_pushstring(L, "LCRYPT_HASH_STATE"); return 1; }
    if(strcmp(index, "name") == 0) { lua_pushstring(L, hash_descriptor[h->hash].name); return 1; }
    if(strcmp(index, "hash_size") == 0) { lua_pushinteger(L, hash_descriptor[h->hash].hashsize); return 1; }
    if(strcmp(index, "block_size") == 0) { lua_pushinteger(L, hash_descriptor[h->hash].blocksize); return 1; }
    if(strcmp(index, "add") == 0) { lua_pushcfunction(L, lcrypt_hash_add); return 1; }
    if(strcmp(index, "done") == 0) { lua_pushcfunction(L, lcrypt_hash_done); return 1; }
  }
  return 0;
}

static int lcrypt_hmac_state_index(lua_State *L)
{
  hmac_state *h = luaL_checkudata(L, 1, "LCRYPT_HMAC_STATE");
  if(likely(h->hash >= 0))
  {
    const char *index = luaL_checkstring(L, 2);
    if(strcmp(index, "type") == 0) { lua_pushstring(L, "LCRYPT_HMAC_STATE"); return 1; }
    if(strcmp(index, "hash") == 0) { lua_pushstring(L, hash_descriptor[h->hash].name); return 1; }
    if(strcmp(index, "hash_size") == 0) { lua_pushinteger(L, hash_descriptor[h->hash].hashsize); return 1; }
    if(strcmp(index, "block_size") == 0) { lua_pushinteger(L, hash_descriptor[h->hash].blocksize); return 1; }
    if(strcmp(index, "add") == 0) { lua_pushcfunction(L, lcrypt_hmac_add); return 1; }
    if(strcmp(index, "done") == 0) { lua_pushcfunction(L, lcrypt_hmac_done); return 1; }
  }
  return 0;
}

static const struct luaL_reg lcrypt_hash_flib[] =
{
  { "__index", lcrypt_hash_index },
  { NULL, NULL }
};

static const struct luaL_reg lcrypt_hash_state_flib[] =
{
  { "__index", lcrypt_hash_state_index },
  { "__gc", lcrypt_hash_state_gc },
  { NULL, NULL }
};

static const struct luaL_reg lcrypt_hmac_state_flib[] =
{
  { "__index", lcrypt_hmac_state_index },
  { "__gc", lcrypt_hmac_state_gc },
  { NULL, NULL }
};

static void lcrypt_start_hashes(lua_State *L)
{
  (void)luaL_newmetatable(L, "LCRYPT_HASH");  (void)luaL_register(L, NULL, lcrypt_hash_flib);  lua_pop(L, 1);
  lua_pushstring(L, "hashes");
  lua_newtable(L);
  #define ADD_HASH(L,name)                                \
  {                                                       \
    lua_pushstring(L, #name);                             \
    int *hash_index = lua_newuserdata(L, sizeof(int));    \
    luaL_getmetatable(L, "LCRYPT_HASH");                  \
    (void)lua_setmetatable(L, -2);                        \
    *hash_index = register_hash(&name ## _desc);          \
    lua_settable(L, -3);                                  \
  }
  ADD_HASH(L, whirlpool);  ADD_HASH(L, sha512);  ADD_HASH(L, sha384);  ADD_HASH(L, rmd320);
  ADD_HASH(L, sha256);     ADD_HASH(L, rmd256);  ADD_HASH(L, sha224);  ADD_HASH(L, tiger);
  ADD_HASH(L, sha1);       ADD_HASH(L, rmd160);  ADD_HASH(L, rmd128);  ADD_HASH(L, md5);
  ADD_HASH(L, md4);        ADD_HASH(L, md2);
  #undef ADD_HASH
  lua_settable(L, -3);

  (void)luaL_newmetatable(L, "LCRYPT_HASH_STATE");  (void)luaL_register(L, NULL, lcrypt_hash_state_flib);  lua_pop(L, 1);
  (void)luaL_newmetatable(L, "LCRYPT_HMAC_STATE");  (void)luaL_register(L, NULL, lcrypt_hmac_state_flib);  lua_pop(L, 1);
}
