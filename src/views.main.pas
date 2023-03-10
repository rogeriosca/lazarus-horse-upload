unit Views.Main;

{$MODE DELPHI}{$H+}

interface

uses Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons, Horse;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    btnStart: TBitBtn;
    btnStop: TBitBtn;
    edtPort: TEdit;
    Label1: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    procedure Status;
    procedure Start;
    procedure Stop;
  end;

var
  FrmMain: TFrmMain;

implementation

procedure DoUpload(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var fs: TFileStream;
    i: integer;
    ok: boolean;
    pastaUpload: string;
begin
  {É esperado receber uma requisição do tipo MultiPart com arquivos}

  pastaUpload:= 'C:\testeUpload\';
  ForceDirectories(pastaUpload);

  ok:= true;
  for i:=0 to Req.RawWebRequest.Files.Count-1 do begin
    try
      fs:= TFileStream.Create( pastaUpload + Req.RawWebRequest.Files[i].FileName, fmCreate or fmOpenWrite );
      fs.CopyFrom(Req.RawWebRequest.Files[i].Stream, Req.RawWebRequest.Files[i].Stream.Size);
      FreeAndNil(fs);
    except
      ok:=false;
      Break;
    end;
  end;

  if ok then
    Res.Send( 'Arquivos recebidos com sucesso').Status(201)
  else
    Res.Send('Erro ao gravar o arquivo').Status(500);
end;

{$R *.lfm}

procedure TFrmMain.btnStartClick(Sender: TObject);
begin
  Start;
  Status;
end;

procedure TFrmMain.btnStopClick(Sender: TObject);
begin
  Stop;
  Status;
end;

procedure TFrmMain.Status;
begin
  btnStop.Enabled := THorse.IsRunning;
  btnStart.Enabled := not THorse.IsRunning;
  edtPort.Enabled := not THorse.IsRunning;
end;

procedure TFrmMain.Start;
begin
  Thorse.Post('/upload', DoUpload);
  THorse.Listen(StrToInt(edtPort.Text));
end;

procedure TFrmMain.Stop;
begin
  THorse.StopListen;
end;

end.

