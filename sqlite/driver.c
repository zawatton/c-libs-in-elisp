#include <stdio.h>
#include <string.h>
typedef unsigned char u8; typedef unsigned int u32; typedef unsigned long long u64;
extern int sqlite3PutVarint(unsigned char*, u64);
extern u8 sqlite3GetVarint(const unsigned char*, u64*);
extern u8 sqlite3GetVarint32(const unsigned char*, u32*);
extern int sqlite3VarintLen(u64);
extern int sqlite3Strlen30(const char*);
extern u32 sqlite3Get4byte(const u8*);
extern void sqlite3Put4byte(unsigned char*, u32);
int main(void){
  int ok=1;
  u64 vs[]={0,1,127,128,16383,16384,200000ULL,0xdeadbeefULL,0xfedcba9876543210ULL};
  for(int i=0;i<9;i++){ unsigned char b[12]; u64 back=0;
    int e=sqlite3PutVarint(b,vs[i]); int d=sqlite3GetVarint(b,&back);
    if(back!=vs[i]||e!=d) ok=0; }
  u32 w[]={200,16384,1000000u,0xfedcba98u}; 
  for(int i=0;i<4;i++){ unsigned char b[12]; u32 back=0;
    sqlite3PutVarint(b,w[i]); sqlite3GetVarint32(b,&back); if(back!=w[i]) ok=0; }
  unsigned char buf[4]; sqlite3Put4byte(buf,0x12345678u);
  int g4=(sqlite3Get4byte(buf)==0x12345678u)&&buf[0]==0x12&&buf[3]==0x78;
  int sl=sqlite3Strlen30("CREATE TABLE t(a,b,c);");
  int vl=sqlite3VarintLen(300);
  ok = ok && g4 && (sl==22) && (vl==2);
  printf("varint_roundtrip strlen30=%d vlen300=%d get4=%d %s\n", sl, vl, g4, ok?"ALL-OK":"FAIL");
  return ok?0:1;
}
