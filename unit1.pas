unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, ComCtrls, StdCtrls, Grids, Global, SynaSer, SerialPotok,
  lclintf, Buttons, ExtCtrls, EditBtn,stack,crc16, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn7: TBitBtn;
    BitBtn5: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    bOn: TButton;
    bOff: TButton;
    bApply: TButton;
    Button4: TButton;
    Button7: TButton;
    cbReq1: TCheckBox;
    cbPort: TComboBox;
    cgOut: TCheckGroup;
    Edit3: TEdit;
    GroupBox1: TGroupBox;
    Label19: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    sg6: TStringGrid;
    tb1: TProgressBar;
    TrackBar1: TTrackBar;
    tsCal: TTabSheet;
    CheckBox1: TCheckBox;
    chbPriem: TCheckBox;
    Memo1: TMemo;
    PageControl1: TPageControl;
    sg1: TStringGrid;
    TabSheet1: TTabSheet;
    Timer1: TTimer;
    procedure bApplyClick(Sender: TObject);
    procedure bOffClick(Sender: TObject);
    procedure bOnClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure cbPortChange(Sender: TObject);
    procedure cgOutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sg6DrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect;
      aState: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);

  private
    { private declarations }
  public

    procedure OpenCom;


    { public declarations }
  end;


procedure SendBufCRC16(len:integer);
procedure DealData;
procedure SetOut(w:word);

procedure GetState;
var
  Form1: TForm1;
 MyThread:TMyThread;
 count:integer;
implementation

{$R *.lfm}


//
procedure SetOut(w:word);
begin

tx232buf[1]:=1;
tx232buf[2]:=3;
tx232buf[3]:=64;
tx232buf[4]:=W;
tx232buf[5]:=W shr 8;
SendBufCRC16(6);
sleep(100);
sleep(100);
GetState;
end;


procedure GetState;
begin
tx232buf[1]:=1;
tx232buf[2]:=1;
tx232buf[3]:=65;
SendBufCRC16(4);
sleep(100);
end;


procedure BlockAnalys;
 var cmd: byte;
  w:word;
//  f:single;
  i:integer;
//  fsum:single;
begin
w:=0;
cmd:= block_body[0];
if cmd=65 then  //State
   begin

       Move(block_body[1],w,1); //  outp
      for i:=0 to 7 do
      begin
      if w and (1 shl i)=0  then form1.sg6.Cells[1,1+i]:='0'
      else form1.sg6.Cells[1,1+i]:='1';
      end;
    //принимакм 12 single в массив
       Move(block_body[2],fl,48); //
       // по полочкам
       form1.sg6.Cells[2,1]:=floattostrf(fl[0],fffixed,3,1);  //   f1ma
       form1.sg6.Cells[2,2]:=floattostrf(fl[1],fffixed,3,1);  //   f2ma
       form1.sg6.Cells[3,1]:=floattostrf(fl[2],fffixed,3,3);  //   f1V
       form1.sg6.Cells[3,2]:=floattostrf(fl[3],fffixed,3,3);  //   f2V

       form1.sg6.Cells[3,5]:=floattostrf(fl[4],fffixed,3,3);  //   fa2+
       form1.sg6.Cells[4,5]:=floattostrf(fl[5],fffixed,3,3);  //   fa2-

       form1.sg6.Cells[3,6]:=floattostrf(fl[6],fffixed,3,3);  //   fa3+
       form1.sg6.Cells[4,6]:=floattostrf(fl[7],fffixed,3,3);  //   fa3-

       form1.sg6.Cells[3,7]:=floattostrf(fl[8],fffixed,3,3);  //   fa4+
       form1.sg6.Cells[4,7]:=floattostrf(fl[9],fffixed,3,3);  //   fa4-

       form1.sg6.Cells[3,8]:=floattostrf(fl[10],fffixed,3,3);  //   fa5+
       form1.sg6.Cells[4,8]:=floattostrf(fl[11],fffixed,3,3);  //   fa5-

   end;

if form1.tb1.Position >99 then  form1.tb1.Position:=0
else form1.tb1.Position:=form1.tb1.Position+1;
end;

procedure NewPacketAnalys;
var crc16,i,ind:word;
 NumBlocks,Bsize:byte;
 begin
rxsize:=rxcount;
Move(rx232buf,rxbuf,rxsize);

crc16:=rx232buf[rxsize-1]+rx232buf[rxsize-2]*256;
if crc16<>crc16_it(rxbuf,rxsize-2,0) then exit;
//debug

   begin
   numBlocks:=rxbuf[1];
   Bsize:=rxbuf[2];
   ind:=2;
//   cmd:=rxbuf[3];

   for i:=0 to numBlocks-1 do
   begin
   bsize:= rxbuf[ind]; Inc(ind);
  // cmd:= rxbuf[ind]; Inc(ind);
   Move(rxbuf[ind],block_body,Bsize);
   BlockAnalys;
   ind+=Bsize;
   end;

   end;

end;

//  27.07 переход на переменную длину пакета
procedure DealData;
var nbs:integer;
 len:word;
begin
t2:=GetTickCount;

interval:=t2-t1;


if interval>60 then
   begin

   rxcount:=0;
   NewPause:=interval;
   end;
t1:=t2;
    nbs:=Comport1.WaitingData;
        if (nbs > 0 )then
       begin
    ComPort1.RecvBuffer(@rx232buf[rxcount],nbs);
   // Move(@rx232buf[rxcount],uiarr.b,nbs);
    rxcount+=nbs;

    count+=nbs;
    end;
//if rx232buf[0]<>$aa then  rxcount:=0;
if (rxcount>5) then   //вычисляем конец пакета
begin
if rx232buf[0]=$0 then len:=28
else len:=rx232buf[1]*(rx232buf[2]+1);
if rxcount>=len+4 then
begin
NewPacketAnalys;
rxcount:=0;
end;
end;


end;


procedure SendBufCRC16(len:integer);
var crc16:word;
begin
tx232buf[0]:=$AA;
crc16:=crc16_it(tx232buf,len,0);
tx232buf[len+1]:=crc16;
tx232buf[len]:=crc16 shr 8;
ComPort1.SendBuffer(@tx232buf,len+2);
end;






procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
 dir:=extractFilePath(Application.ExeName);



//получаем имена портов
GetSerialPortNames;
if numPorts<1 then ShowMessage('А нету портов')
else begin
comport1:=TBlockSerial.Create;
for i:=0 to NumPorts-1 do
cbPort.Items.Add(serNames[i]);
//выбираем дальний
cbPort.ItemIndex:=cbPort.Items.Count-1;
cbPortChange(Form1);

end;

t1:=GetTickCount;
MyThread := TMyThread.Create(true);
MyThread.Resume;
for i:=1 to sg1.RowCount-1 do
begin
  sg1.Cells[0,i]:=inttostr(i-1);
  sg1.Cells[1,i]:=inttostr(i-1);
  end;


end;


procedure TForm1.FormDestroy(Sender: TObject);
begin

MyThread.Terminate;
MyThread.Free;
comport1.Free;

end;

procedure TForm1.sg6DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (acol>2) and (acol<6)  and (arow>0) then
  begin
  sg6.canvas.Font.Color:=clRed;
  sg6.Canvas.TextOut(aRect.Left+4, aRect.Top+2, Sg6.Cells[ACol, ARow]);
  end;
end;












procedure TForm1.Timer1Timer(Sender: TObject);
begin
if cbReq1.Checked then
begin
GetState;
end;

end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  edit3.Text:=inttostr(TrackBar1.Position)+' мс';
  timer1.Interval:=TrackBar1.Position;
end;





procedure TForm1.OpenCom;
label next22;
  var i:integer;
begin
try     ComPort1.Free;    except  end;
i:=cbPort.ItemIndex+1;
Next22:
dec(i);
if i<0 then exit;

   ComPort1:=TBlockSerial.Create;

   ComPort1.Connect(cbPort.Items[i]);


if ComPort1.LastError<>0 then goto Next22; //пробуем подключится к след
ComPort1.config(921600,8,'N',0,false,false);
if ComPort1.Handle>0 then  memo1.Lines.Add('hello');
cbPort.ItemIndex:=i;
comport1.RTS:=False;
comport1.DTR:=True;
Comport1.Purge;
end;




procedure TForm1.cbPortChange(Sender: TObject);
begin
if cbPort.itemIndex>=0 then
openCom;
end;

procedure TForm1.cgOutClick(Sender: TObject);
begin

end;

procedure TForm1.bOnClick(Sender: TObject);
var i:integer;
begin
 for i:=0 to 7 do cgOut.Checked[i]:=True;
  bApplyClick(form1);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  GetState;
end;

procedure TForm1.bOffClick(Sender: TObject);
var i:integer;
begin
 for i:=0 to 7 do cgOut.Checked[i]:=False;
 bApplyClick(form1);
end;

procedure TForm1.bApplyClick(Sender: TObject);
var i:integer;
 outp:word;
begin
outp:=0;
 for i:=0 to 7 do  if cgOut.Checked[i] then  outp:=outp or (1 shl i);
SetOut(outp);
//for i:=0 to 15 do  if cgOut.Checked[i] then sg6.Cells[1,i+1]:='1'
//else  sg6.Cells[1,i+1]:='0';
end;

end.

