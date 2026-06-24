typedef unsigned char u8;
typedef unsigned int u32;
typedef unsigned long long u64;
extern unsigned long strlen(const char*);
extern void *memcpy(void*, const void*, unsigned long);
 int sqlite3Strlen30(const char *z){
  if( z==0 ) return 0;
  return 0x3fffffff & (int)strlen(z);
}
static int putVarint64(unsigned char *p, u64 v){
  int i, j, n;
  u8 buf[10];
  if( v & (((u64)0xff000000)<<32) ){
    p[8] = (u8)v;
    v >>= 8;
    for(i=7; i>=0; i--){
      p[i] = (u8)((v & 0x7f) | 0x80);
      v >>= 7;
    }
    return 9;
  }
  n = 0;
  do{
    buf[n++] = (u8)((v & 0x7f) | 0x80);
    v >>= 7;
  }while( v!=0 );
  buf[0] &= 0x7f;
  ;
  for(i=0, j=n-1; j>=0; j--, i++){
    p[i] = buf[j];
  }
  return n;
}
 int sqlite3PutVarint(unsigned char *p, u64 v){
  if( v<=0x7f ){
    p[0] = v&0x7f;
    return 1;
  }
  if( v<=0x3fff ){
    p[0] = ((v>>7)&0x7f)|0x80;
    p[1] = v&0x7f;
    return 2;
  }
  return putVarint64(p,v);
}
 u8 sqlite3GetVarint(const unsigned char *p, u64 *v){
  u32 a,b,s;
  if( ((signed char*)p)[0]>=0 ){
    *v = *p;
    return 1;
  }
  if( ((signed char*)p)[1]>=0 ){
    *v = ((u32)(p[0]&0x7f)<<7) | p[1];
    return 2;
  }
  ;
  ;
  a = ((u32)p[0])<<14;
  b = p[1];
  p += 2;
  a |= *p;
  if (!(a&0x80))
  {
    a &= 0x001fc07f;
    b &= 0x7f;
    b = b<<7;
    a |= b;
    *v = a;
    return 3;
  }
  a &= 0x001fc07f;
  p++;
  b = b<<14;
  b |= *p;
  if (!(b&0x80))
  {
    b &= 0x001fc07f;
    a = a<<7;
    a |= b;
    *v = a;
    return 4;
  }
  b &= 0x001fc07f;
  s = a;
  p++;
  a = a<<14;
  a |= *p;
  if (!(a&0x80))
  {
    b = b<<7;
    a |= b;
    s = s>>18;
    *v = ((u64)s)<<32 | a;
    return 5;
  }
  s = s<<7;
  s |= b;
  p++;
  b = b<<14;
  b |= *p;
  if (!(b&0x80))
  {
    a &= 0x001fc07f;
    a = a<<7;
    a |= b;
    s = s>>18;
    *v = ((u64)s)<<32 | a;
    return 6;
  }
  p++;
  a = a<<14;
  a |= *p;
  if (!(a&0x80))
  {
    a &= 0xf01fc07f;
    b &= 0x001fc07f;
    b = b<<7;
    a |= b;
    s = s>>11;
    *v = ((u64)s)<<32 | a;
    return 7;
  }
  a &= 0x001fc07f;
  p++;
  b = b<<14;
  b |= *p;
  if (!(b&0x80))
  {
    b &= 0xf01fc07f;
    a = a<<7;
    a |= b;
    s = s>>4;
    *v = ((u64)s)<<32 | a;
    return 8;
  }
  p++;
  a = a<<15;
  a |= *p;
  b &= 0x001fc07f;
  b = b<<8;
  a |= b;
  s = s<<4;
  b = p[-4];
  b &= 0x7f;
  b = b>>3;
  s |= b;
  *v = ((u64)s)<<32 | a;
  return 9;
}
 u8 sqlite3GetVarint32(const unsigned char *p, u32 *v){
  u32 a,b;
  a = *p;
  if (!(a&0x80))
  {
    *v = a;
    return 1;
  }
  p++;
  b = *p;
  if (!(b&0x80))
  {
    a &= 0x7f;
    a = a<<7;
    *v = a | b;
    return 2;
  }
  p++;
  a = a<<14;
  a |= *p;
  if (!(a&0x80))
  {
    a &= (0x7f<<14)|(0x7f);
    b &= 0x7f;
    b = b<<7;
    *v = a | b;
    return 3;
  }
  {
    u64 v64;
    u8 n;
    n = sqlite3GetVarint(p-2, &v64);
    ;
    if( (v64 & ((((u64)1)<<32)-1))!=v64 ){
      *v = 0xffffffff;
    }else{
      *v = (u32)v64;
    }
    return n;
  }
}
 int sqlite3VarintLen(u64 v){
  int i;
  for(i=1; (v >>= 7)!=0; i++){ ; }
  return i;
}
 u32 sqlite3Get4byte(const u8 *p){
  u32 x;
  memcpy(&x,p,4);
  return __builtin_bswap32(x);
}
 void sqlite3Put4byte(unsigned char *p, u32 v){
  u32 x = __builtin_bswap32(v);
  memcpy(p,&x,4);
}
