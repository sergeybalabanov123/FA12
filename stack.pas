unit stack;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Global;
type
  TPacket = packed record
     case Integer of
        0: (b: array [0..31] of byte);
        1: (w: array [0..15] of word);
        2: (si: array [0..15] of SmallInt);
       end;
  const MaxArr=4095;
  procedure AddPacket;
var parr: array[0..8191] of TPacket;
    arr: TPacket;
    i:integer;
    head,tail:integer;
implementation
procedure AddPacket;
begin
Move(rx232buf,parr[head],32);
inc(head);
if head>MaxArr then head:=0;
end;

initialization
for i:=0 to 31 do
parr[0].b[i]:=i+1;
parr[0].w[2]:=123;

end.

