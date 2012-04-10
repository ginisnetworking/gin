#ifdef USE_NCIPHER
  typedef sbigint lcrypt_bigint;
#else
  typedef void* lcrypt_bigint;
#endif

static lcrypt_bigint* lcrypt_new_bigint(lua_State *L)
{
  lcrypt_bigint *bi = lua_newuserdata(L, sizeof(lcrypt_bigint));
  luaL_getmetatable(L, "LCRYPT_BIGINT");
  (void)lua_setmetatable(L, -2);
  #ifdef USE_NCIPHER
    sbigint_create(bi, NULL, 0);
  #else
    *bi = NULL;
    lcrypt_error(L, ltc_mp.init(bi), NULL);
  #endif
  return bi;
}

static int lcrypt_bigint_add(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_add(bi_a, bi_b, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.add(*bi_a, *bi_b, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_sub(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_sub(bi_a, bi_b, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.sub(*bi_a, *bi_b, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_mul(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_mul(bi_a, bi_b, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.mul(*bi_a, *bi_b, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_div(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_divmod(bi_a, bi_b, bi, NULL) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.mpdiv(*bi_a, *bi_b, *bi, NULL), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_divmod(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_q = lcrypt_new_bigint(L);
  lcrypt_bigint *bi_r = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_divmod(bi_a, bi_b, bi_q, bi_r) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.mpdiv(*bi_a, *bi_b, *bi_q, *bi_r), NULL);
  #endif
  return 2;
}

static int lcrypt_bigint_mod(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_divmod(bi_a, bi_b, NULL, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.mpdiv(*bi_a, *bi_b, NULL, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_invmod(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_invmod(bi_a, bi_b, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.invmod(*bi_a, *bi_b, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_mulmod(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_c = luaL_checkudata(L, 3, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_mulmod(bi_a, bi_b, bi_c, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.mulmod(*bi_a, *bi_b, *bi_c, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_exptmod(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_c = luaL_checkudata(L, 3, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_exptmod(bi_a, bi_b, bi_c, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.exptmod(*bi_a, *bi_b, *bi_c, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_gcd(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_gcd(bi_a, bi_b, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.gcd(*bi_a, *bi_b, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_lcm(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    if(unlikely(sbigint_lcm(bi_a, bi_b, bi) != 0)) return 0;
  #else
    lcrypt_error(L, ltc_mp.lcm(*bi_a, *bi_b, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_unm(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi = lcrypt_new_bigint(L);
  #ifdef USE_NCIPHER
    sbigint_copy(bi, bi_a);
    bi->sign = (bi_a->sign == SBIGINT_POSITIVE) ? SBIGINT_NEGATIVE : SBIGINT_POSITIVE;
  #else
    lcrypt_error(L, ltc_mp.neg(*bi_a, *bi), NULL);
  #endif
  return 1;
}

static int lcrypt_bigint_eq(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  #ifdef USE_NCIPHER
    lua_pushboolean(L, (sbigint_cmp(bi_a, bi_b) == 0) ? 1 : 0);
  #else
    lua_pushboolean(L, (ltc_mp.compare(*bi_a, *bi_b) == LTC_MP_EQ) ? 1 : 0);
  #endif
  return 1;
}

static int lcrypt_bigint_lt(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  #ifdef USE_NCIPHER
    lua_pushboolean(L, (sbigint_cmp(bi_a, bi_b) < 0) ? 1 : 0);
  #else
    lua_pushboolean(L, (ltc_mp.compare(*bi_a, *bi_b) == LTC_MP_LT) ? 1 : 0);
  #endif
  return 1;
}

static int lcrypt_bigint_le(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  lcrypt_bigint *bi_b = luaL_checkudata(L, 2, "LCRYPT_BIGINT");
  #ifdef USE_NCIPHER
    lua_pushboolean(L, (sbigint_cmp(bi_a, bi_b) <= 0) ? 1 : 0);
  #else
    lua_pushboolean(L, (ltc_mp.compare(*bi_a, *bi_b) == LTC_MP_GT) ? 0 : 1);
  #endif
  return 1;
}

static int lcrypt_bigint_tostring(lua_State *L)
{
  lcrypt_bigint *bi_a = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  #ifdef USE_NCIPHER
    unsigned char out[4097];
    int length = sizeof(out);
    sbigint_tostring(bi_a, out + 1, &length);
    if(bi_a->sign == SBIGINT_NEGATIVE || (out[1] & 0x80) == 0x80)
    {
      out[0] = bi_a->sign;
      lua_pushlstring(L, (char*)out, length + 1);
    }
    else
    {
      lua_pushlstring(L, (char*)out + 1, length);
    }
  #else
    size_t out_length = (size_t)ltc_mp.unsigned_size(*bi_a) + 1;
    unsigned char *out = lcrypt_malloc(L, out_length);
    out[0] = (ltc_mp.compare_d(*bi_a, 0) == LTC_MP_LT) ? (unsigned char)0x80 : (unsigned char)0x00;
    lcrypt_error(L, ltc_mp.unsigned_write(*bi_a, out+1), out);
    if(out[0] == 0 && out[1] < 0x7f)
      lua_pushlstring(L, (char*)out+1, out_length-1);
    else
      lua_pushlstring(L, (char*)out, out_length);
    free(out);
  #endif
  return 1;
}

static int lcrypt_bigint_index(lua_State *L)
{
  lcrypt_bigint *bi = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  const char *index = luaL_checkstring(L, 2);
  #ifdef USE_NCIPHER
    if(strcmp(index, "bits") == 0)
    {
      int len = bi->num.nbytes - 1;
      while(len > 0 && bi->num.bytes[len] == 0) len--;
      int bits = len * 8;
      if(bi->num.bytes[len] & 0x80) bits += 8;
      else if(bi->num.bytes[len] & 0x40) bits += 7;
      else if(bi->num.bytes[len] & 0x20) bits += 6;
      else if(bi->num.bytes[len] & 0x10) bits += 5;
      else if(bi->num.bytes[len] & 0x08) bits += 4;
      else if(bi->num.bytes[len] & 0x04) bits += 3;
      else if(bi->num.bytes[len] & 0x02) bits += 2;
      else bits++;
      lua_pushinteger(L, bits);
      return 1;
    }
    if(strcmp(index, "isprime") == 0)
    {
      sbigint c;
      int i, prime = 0;
      if(unlikely(sbigint_is_prime(bi, &c) != 0)) return 0;
      for(i = 0; i < c.num.nbytes; i++) if(c.num.bytes[i] != 0) { prime = 1; break; }
      lua_pushboolean(L, prime);
      return 1;
    }
  #else
    if(strcmp(index, "bits") == 0) { lua_pushinteger(L, ltc_mp.count_bits(*bi)); return 1; }
    if(strcmp(index, "isprime") == 0)
    {
      int ret = LTC_MP_NO;
      lcrypt_error(L, ltc_mp.isprime(*bi, &ret), NULL);
      lua_pushboolean(L, (ret == LTC_MP_YES) ? 1 : 0);
      return 1;
    }
  #endif
  if(strcmp(index, "add") == 0) { lua_pushcfunction(L, lcrypt_bigint_add); return 1; }
  if(strcmp(index, "sub") == 0) { lua_pushcfunction(L, lcrypt_bigint_sub); return 1; }
  if(strcmp(index, "mul") == 0) { lua_pushcfunction(L, lcrypt_bigint_mul); return 1; }
  if(strcmp(index, "div") == 0) { lua_pushcfunction(L, lcrypt_bigint_divmod); return 1; }
  if(strcmp(index, "mod") == 0) { lua_pushcfunction(L, lcrypt_bigint_mod); return 1; }
  if(strcmp(index, "gcd") == 0) { lua_pushcfunction(L, lcrypt_bigint_gcd); return 1; }
  if(strcmp(index, "lcm") == 0) { lua_pushcfunction(L, lcrypt_bigint_lcm); return 1; }
  if(strcmp(index, "invmod") == 0) { lua_pushcfunction(L, lcrypt_bigint_invmod); return 1; }
  if(strcmp(index, "mulmod") == 0) { lua_pushcfunction(L, lcrypt_bigint_mulmod); return 1; }
  if(strcmp(index, "exptmod") == 0) { lua_pushcfunction(L, lcrypt_bigint_exptmod); return 1; }
  return 0;
}

static int lcrypt_bigint_gc(lua_State *L)
{
  #ifdef USE_NCIPHER
    (void)luaL_checkudata(L, 1, "LCRYPT_BIGINT");
  #else
    lcrypt_bigint *bi = luaL_checkudata(L, 1, "LCRYPT_BIGINT");
    if(likely(*bi != NULL))
    {
      ltc_mp.deinit(*bi);
      *bi = NULL;
    }
  #endif
  return 0;
}

static int lcrypt_bigint_create(lua_State *L)
{
  #ifdef USE_NCIPHER
    if(lua_isnumber(L, 1) == 1)
    {
      long n = luaL_checknumber(L, 1);
      lcrypt_bigint *bi = lcrypt_new_bigint(L);
      if(n < 0)
      {
        bi->sign = SBIGINT_NEGATIVE;
        n = -n;
      }
      bi->num.nbytes = 0;
      while(n != 0 || bi->num.nbytes % 4 != 0)
      {
        bi->num.bytes[bi->num.nbytes++] = n & 0xff;
        n >>= 8;
      }
    }
    else
    {
      size_t n_length = 0;
      unsigned char *n = (unsigned char*)luaL_optlstring(L, 1, "", &n_length);
      lcrypt_bigint *bi = lua_newuserdata(L, sizeof(lcrypt_bigint));
      luaL_getmetatable(L, "LCRYPT_BIGINT");
      (void)lua_setmetatable(L, -2);
      sbigint_create(bi, n, n_length);
    }
  #else
    if(lua_isnumber(L, 1) == 1)
    {
      long n = luaL_checknumber(L, 1);
      lcrypt_bigint *bi = lcrypt_new_bigint(L);
      if(n < 0)
      {
        void *temp;
        int err = CRYPT_OK;
        lcrypt_error(L, ltc_mp.init(&temp), NULL);
        if((err = ltc_mp.set_int(temp, -n)) == CRYPT_OK)
        {
          err = ltc_mp.neg(temp, *bi);
        }
        ltc_mp.deinit(temp);
        lcrypt_error(L, err, NULL);
      }
      else
      {
        lcrypt_error(L, ltc_mp.set_int(*bi, n), NULL);
      }
    }
    else
    {
      size_t n_length = 0;
      unsigned char *n = (unsigned char*)luaL_optlstring(L, 1, "", &n_length);
      lcrypt_bigint *bi = lcrypt_new_bigint(L);
      lcrypt_error(L, ltc_mp.unsigned_read(*bi, n, n_length), NULL);
    }
  #endif
  return 1;
}

static const struct luaL_reg lcrypt_bigint_flib[] =
{
  { "__index", lcrypt_bigint_index },
  { "__add", lcrypt_bigint_add },
  { "__sub", lcrypt_bigint_sub },
  { "__mul", lcrypt_bigint_mul },
  { "__div", lcrypt_bigint_div },
  { "__mod", lcrypt_bigint_mod },
  { "__unm", lcrypt_bigint_unm },
  { "__eq", lcrypt_bigint_eq },
  { "__lt", lcrypt_bigint_lt },
  { "__le", lcrypt_bigint_le },
  { "__tostring", lcrypt_bigint_tostring },
  { "__gc", lcrypt_bigint_gc },
  { NULL, NULL }
};

static void lcrypt_start_math(lua_State *L)
{
  (void)luaL_newmetatable(L, "LCRYPT_BIGINT");  (void)luaL_register(L, NULL, lcrypt_bigint_flib);  lua_pop(L, 1);

  #ifndef USE_NCIPHER
    ltc_mp = ltm_desc;
  #endif

  lua_pushstring(L, "bigint"); lua_pushcfunction(L, lcrypt_bigint_create); lua_settable(L, -3);
}
