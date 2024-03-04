unit Global;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  SysUtils,SynaSer;

const BUFSIZE=32;
      MEMSIZ=32768;

type tSwitch=record
us:byte;
dt:byte;
num:array [0..5] of byte;
end;
type tDAC3=record
pid:byte;
DAC_max:word;
DAC_min:word;
DAC_add:word;
us_delay:word;
end;
  // один канал во всей красе

type tADC=record

num:integer; //размер выборки
ADC:array[0..4095] of word;//оригинал выборки
X:array[0..4095] of double;
diff:integer; //канал дифф-простой
adcSredn:integer;
Xsredn: double;
sko:double;
tomvma:double; // коеф аеревода в mv ma
end;

type tADC8 =packed record
b:array [0..32767] of byte;
i:array [0..4095] of integer;
end;

var
  timcount:integer;
   tauW: array [0..100] of single;
   fl: array [0..20] of single;
   no_calibr:integer;
   curchan:byte;
   curdac:word;
   CalibrState:byte;
   CalibrChan:byte;
  uiarr: tADC8;
  vdd:single;
  on:byte;
  rxsize: integer;
  block_body: array[0..255] of byte;
  rxbuf: array[0..255] of byte;
  sredn,sko: array [0..7] of double;

  dir,uodir,uidir,rtddir,F16dir:string;
  // переменные калибровки UO
  uoX1,uoX2,uoX3: integer;// DAC1 DAC2
  uoU1,uoU2,uoU3:double;  //значения с калибратора
  a,b,b0:double; //
  uoDac:word;
  stat: array[0..12] of tADC;
  // 4,5- массивы резисторов
//переменные DAC
  posDacAmpl,posDACmin,posDacmax,posURef:integer;
  DAC_max:word;
  DAC_min:word;
  DAC_add:word;

  us_delay:word;
   ms_delay:word;
    DAC1:word;
    DAC2:word;
    DACF16:word;
//переменные ADC
   offset:integer;
   gain: array[0..9] of double;
    mv: array[0..9] of double;
   //ключи
   chan:byte;

   regime:byte;
  ComPort1: TBlockSerial;

  rx232Buf: array[0..$ffff] of byte;
  tx232Buf: array[0..$ffff] of byte;
  DAC3: tDAC3;
//  bufFull:integer; //флаг когда буфер заполнен
  t1,t2,Interval:integer;

  myadr:byte;
  newPause: integer;

//  timecount:integer;
  datadir:string;

//  first:boolean;
  opened:boolean;
  intADC:word; //интервал АЦП

implementation

initialization
   //токовые диф каналы
   stat[1].diff:=1;
   stat[2].diff:=1;


  Gain[0]:=1;
  Gain[1]:=2/2.370;///1;//1.132;
  Gain[2]:=2/1.993;////1;//0.943;
  Gain[3]:=1;
  Gain[4]:=1;
  Gain[5]:=1;
  Gain[6]:=1;
  Gain[7]:=1;
  Gain[8]:=1;
  Gain[9]:=1;
end.
