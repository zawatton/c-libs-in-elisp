#include <stdio.h>
#include <string.h>
typedef unsigned char xmlChar;
/* the only libxml2-internal extern xmlstring.c references (error path; not exercised) */
void xmlErrMemory(void *ctxt, const char *extra){ (void)ctxt; (void)extra; }
extern int xmlStrlen(const xmlChar *);
extern int xmlStrEqual(const xmlChar *, const xmlChar *);
extern int xmlStrcmp(const xmlChar *, const xmlChar *);
extern int xmlStrncmp(const xmlChar *, const xmlChar *, int);
extern int xmlStrcasecmp(const xmlChar *, const xmlChar *);
extern const xmlChar *xmlStrchr(const xmlChar *, xmlChar);
extern const xmlChar *xmlStrstr(const xmlChar *, const xmlChar *);
extern int xmlUTF8Strlen(const xmlChar *);
extern int xmlStrPrintf(xmlChar *, int, const char *, ...);   /* variadic */
int main(void){
  const xmlChar *doc = (const xmlChar*)"<book><title>NeLisp</title></book>";
  const xmlChar *hit = xmlStrstr(doc, (const xmlChar*)"<title>");
  long off = hit ? (long)(hit - doc) : -1;
  xmlChar pbuf[64];
  int pn = xmlStrPrintf(pbuf, (int)sizeof pbuf, "%s=%d/%s", "tag", 42, "v");  /* variadic */
  int ok = (xmlStrlen(doc)==34)
        && (xmlStrEqual((xmlChar*)"NeLisp",(xmlChar*)"NeLisp")==1)
        && (xmlStrcmp((xmlChar*)"abc",(xmlChar*)"abd")<0)
        && (xmlStrncmp((xmlChar*)"abcZZ",(xmlChar*)"abcQQ",3)==0)
        && (xmlStrcasecmp((xmlChar*)"Hello",(xmlChar*)"hello")==0)
        && (off==6)
        && (xmlStrchr(doc,(xmlChar)'>') == doc+5)
        && (xmlUTF8Strlen((xmlChar*)"NeLisp")==6)
        && (strcmp((char*)pbuf,"tag=42/v")==0) && (pn==8);
  printf("strlen=%d utf8=%d title@%ld printf=[%s](%d) %s\n",
         xmlStrlen(doc), xmlUTF8Strlen((xmlChar*)"NeLisp"), off, (char*)pbuf, pn,
         ok?"ALL-OK":"FAIL");
  return ok?0:1;
}
