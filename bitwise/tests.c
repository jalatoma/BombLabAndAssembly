// DO NOT MODIFY THIS FILE
/* Testing Code */

#include <limits.h>
#include <math.h>

/* Routines used by floation point test code */

/* Convert from bit level representation to floating point number */
float u2f(unsigned u) {
  union {
    unsigned u;
    float f;
  } a;
  a.u = u;
  return a.f;
}

/* Convert from floating point number to bit-level representation */
unsigned f2u(float f) {
  union {
    unsigned u;
    float f;
  } a;
  a.f = f;
  return a.u;
}

int test_bitXor(int x, int y)
{
  return x^y;
}
int test_isZero(int x) {
  return x == 0;
}

int test_allOddBits(int x) {
  int i;
  for (i = 1; i < 32; i+=2)
      if ((x & (1<<i)) == 0)
   return 0;
  return 1;
}

int test_fitsBits(int x, int n) {
  int TMin_n = -(1 << (n-1));
  // This convoluted way of generating TMax avoids overflow
  int TMax_n = (int) ((1u << (n-1)) - 1u);
  return x >= TMin_n && x <= TMax_n;
}

unsigned test_floatAbsVal(unsigned uf) {
  float f = u2f(uf);
  unsigned unf = f2u(-f);
  if (isnan(f))
    return uf;
  /* An unfortunate hack to get around a limitation of the BDD Checker */
  if ((int) uf < 0)
      return unf;
  else
      return uf;
}

int test_floatIsEqual(unsigned uf, unsigned ug) {
    float f = u2f(uf);
    float g = u2f(ug);
    return f == g;
}

int test_getByte(int x, int n) {
    unsigned char byte;
    switch(n) {
    case 0:
      byte = x;
      break;
    case 1:
      byte = x >> 8;
      break;
    case 2:
      byte = x >> 16;
      break;
    default:
      byte = x >> 24;
      break;
    }
    return (int) (unsigned) byte;
}

int test_addOK(int x, int y) {
    long long lsum = (long long) x + y;
    return lsum == (int) lsum;
}

int test_bitMask(int highbit, int lowbit) {
  int result = 0;
  int i;
  for (i = lowbit; i <= highbit; i++)
    result |= 1 << i;
  return result;
}

int test_replaceByte(int x, int n, int c) {
    switch(n) {
    case 0:
      x = (x & 0xFFFFFF00) | c;
      break;
    case 1:
      x = (x & 0xFFFF00FF) | (c << 8);
      break;
    case 2:
      x = (x & 0xFF00FFFF) | (c << 16);
      break;
    default:
      x = (x & 0x00FFFFFF) | (c << 24);
      break;
    }
    return x;
}

int test_isPower2(int x) {
  int i;
  for (i = 0; i < 31; i++) {
    if (x == 1<<i)
      return 1;
  }
  return 0;
}

unsigned test_floatScale4(unsigned uf) {
  float f = u2f(uf);
  float tf = 4*f;
  if (isnan(f))
    return uf;
  else
    return f2u(tf);
}
// DO NOT MODIFY THIS FILE
