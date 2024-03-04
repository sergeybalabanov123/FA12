unit DFiles;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses SysUtils,Forms,Dialogs, FileUtil;

const bufsiz=256*256;//size in TRec

var buf: array[0..bufsiz-1] of byte;
  handle:integer;
//----------------------------------

    procedure WriteDataFile(fname:string; size:integer);
    procedure ReadDataFile(fname:string; size:integer);


implementation


procedure ReadDataFile(fname:string; size:integer);
begin
handle:=FileOpen(fname,  fmOpenReadWrite);
if (handle<>-1)then
begin
Fileseek(handle,0,fsFromBeginning);
FileRead(handle,buf,size);
FileClose(handle);
end;
end;


procedure WriteDataFile(fname:string; size:integer);
begin
handle:=FileOpen(fname,  fmOpenReadWrite);
if (handle<>-1)then
FileSeek(handle,0,fsFromBeginning)
else
handle:=FileCreate(fname);
FileWrite(handle,buf,size);
FileClose(handle);
end;




initialization



end.
