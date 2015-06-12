#include "../runtime.c"

int32 buf[128];
void _printtsth(int32 *str, int32 num)
{
  _print(str);
  itoah(num, buf);
  _print(buf);
  _print("\n");
}

void bootentry()
{
  int x = 0xab;
  _printtsth("result=",inline verilog exec(x) {} return ({8'b0,x[7:0],8'b0,x[7:0]}));
  _testhalt();
}
