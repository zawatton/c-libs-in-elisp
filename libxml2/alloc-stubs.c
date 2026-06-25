/* libxml2 allocator hooks (normally in xmlmemory.c) — supplied so the
   gcc REFERENCE build of the whole xmlstring TU links.  The
   nelisp-cfront object self-provides these as zero-init bss (the
   exercised functions don't allocate), so it does not link this file. */
#include <stdlib.h>
void *(*xmlMalloc)(size_t) = malloc;
void *(*xmlMallocAtomic)(size_t) = malloc;
void *(*xmlRealloc)(void *, size_t) = realloc;
void  (*xmlFree)(void *) = free;
char *(*xmlMemStrdup)(const char *) = NULL;
