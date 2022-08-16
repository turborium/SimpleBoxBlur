unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls;

type
  TFormMain = class(TForm)
    ImageSource: TImage;
    LabelSource: TLabel;
    ImageDestination: TImage;
    LabelDestination: TLabel;
    TrackBarBlurSize: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure TrackBarBlurSizeChange(Sender: TObject);
  private
    procedure Blur;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}


{$POINTERMATH ON}

type
  TPixel = packed record
    B, G, R, Nope: Byte;
  end;

  PPixel = ^TPixel;

function BoxBlur(const Source: TBitmap; const Size: Integer): TBitmap;

  procedure DoBlur(var Src, Dest: array of TPixel; Width, Height: Integer);
  var
    Y: Integer;
    X: Integer;
    Color: TPixel;
  begin
    for Y := 1 to Height - 2 do
    begin
      for X := 1 to Width - 2 do
      begin
        Color.R := (
          Src[(Y - 1) * Width + (X - 1)].R + Src[(Y - 1) * Width + (X + 0)].R + Src[(Y - 1) * Width + (X + 1)].R +
          Src[(Y + 0) * Width + (X - 1)].R + Src[(Y + 0) * Width + (X + 0)].R + Src[(Y + 0) * Width + (X + 1)].R +
          Src[(Y + 1) * Width + (X - 1)].R + Src[(Y + 1) * Width + (X + 0)].R + Src[(Y + 1) * Width + (X + 1)].R
          ) div 9;
        Color.G := (
          Src[(Y - 1) * Width + (X - 1)].G + Src[(Y - 1) * Width + (X + 0)].G + Src[(Y - 1) * Width + (X + 1)].G +
          Src[(Y + 0) * Width + (X - 1)].G + Src[(Y + 0) * Width + (X + 0)].G + Src[(Y + 0) * Width + (X + 1)].G +
          Src[(Y + 1) * Width + (X - 1)].G + Src[(Y + 1) * Width + (X + 0)].G + Src[(Y + 1) * Width + (X + 1)].G
          ) div 9;
        Color.B := (
          Src[(Y - 1) * Width + (X - 1)].B + Src[(Y - 1) * Width + (X + 0)].B + Src[(Y - 1) * Width + (X + 1)].B +
          Src[(Y + 0) * Width + (X - 1)].B + Src[(Y + 0) * Width + (X + 0)].B + Src[(Y + 0) * Width + (X + 1)].B +
          Src[(Y + 1) * Width + (X - 1)].B + Src[(Y + 1) * Width + (X + 0)].B + Src[(Y + 1) * Width + (X + 1)].B
          ) div 9;

        Dest[Y * Width + X] := Color;
      end;
    end;
  end;

var
  Y: Integer;
  X: Integer;
  P: PPixel;
  SourcePixels, BlurPixels, Temp: array of TPixel;
  Width, Height: Integer;
  I: Integer;
begin
  Assert(Size > 0);

  Result := TBitmap.Create;
  Result.Assign(Source);
  Result.PixelFormat := pf32bit;// blue green red nope

  Width := Result.Width + 2;
  Height := Result.Height + 2;

  SetLength(SourcePixels, Width * Height);
  SetLength(BlurPixels, Width * Height);

  for Y := 0 to Result.Height - 1 do
  begin
    P := Result.ScanLine[Y];
    for X := 0 to Result.Width - 1 do
    begin
      SourcePixels[(Y + 1) * Width + (X + 1)] := P[X];
    end;
  end;

  // blur
  for I := 1 to Size do
  begin
    DoBlur(SourcePixels, BlurPixels, Width, Height);
    if I < Size then
    begin
      Temp := SourcePixels;
      SourcePixels := BlurPixels;
      BlurPixels := Temp;
    end;
  end;

  for Y := 0 to Result.Height - 1 do
  begin
    P := Result.ScanLine[Y];
    for X := 0 to Result.Width - 1 do
    begin
      P[X] := BlurPixels[(Y + 1) * Width + (X + 1)];
    end;
  end;
end;


{ TFormMain }

procedure TFormMain.Blur;
var
  SourceBitmap, BlurredBitmap: TBitmap;
begin
  SourceBitmap := TBitmap.Create();
  try
    SourceBitmap.Assign(ImageSource.Picture.Graphic);

    BlurredBitmap := BoxBlur(SourceBitmap, TrackBarBlurSize.Position);
    try
      ImageDestination.Picture.Assign(BlurredBitmap);
    finally
      BlurredBitmap.Free;
    end;
  finally
    SourceBitmap.Free;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Blur();
end;

procedure TFormMain.TrackBarBlurSizeChange(Sender: TObject);
begin
  Blur();
end;

end.
