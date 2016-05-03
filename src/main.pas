unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls,

  LCLType

  ;

type
    TWordDirection=record
      dir          : Byte;
      s_length     : Integer;
      first,
      last         : TPoint;
      mes          : string;
    end;

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    grd_2048M: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure grd_2048MDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure grd_2048MKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grd_2048MMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grd_2048MMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure grd_2048MMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grd_2048MPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private
    { private declarations }
    FEnd1: TPoint;
    FEnd2: TPoint;
    procedure DrawLine(grd : TStringGrid;
                       const PenStyle: TPenStyle; const PenMode: TPenMode);
    function GetDirection(first,last:TPoint):TWordDirection;
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

  first_coord,
  last_coord : TPoint;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption:=Application.Title;
  Randomize;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  x,y : Integer;
begin
  x := Random(grd_2048M.ColCount);
  y := Random(grd_2048M.RowCount);

  grd_2048M.Cells[x,y] := IntToStr( 2 );

end;

procedure TfrmMain.grd_2048MDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  //DrawLine(grd_2048M,psDash, pmXor);
  DrawLine(grd_2048M,psDash, pmXor);
end;

procedure TfrmMain.grd_2048MKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_UP:    ;
    VK_DOWN:  ;
    VK_LEFT:  ;
    VK_RIGHT: ;
  end;
end;

procedure TfrmMain.grd_2048MMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  first_coord := grd_2048M.MouseCoord(x,y);
  DrawLine(grd_2048M,psDash, pmXor);
  // record the start of the line
  FEnd1 := Point(x, y);
  FEnd2 := FEnd1;
  DrawLine(grd_2048M,psDash, pmXor);
end;

procedure TfrmMain.grd_2048MMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssLeft in Shift then
  begin
    // erase the previous line
    DrawLine(grd_2048M,psDash, pmXor);
    // and draw the line for the new position
    FEnd2 := Point(x, y);
    DrawLine(grd_2048M,psDash, pmXor);
    Paint;
    // Panel1.Caption := inttostr( grdWords.MouseCoord(x,y).x ) + ' ' +
    // inttostr( grdWords.MouseCoord(x,y).y );
    // Panel1.Caption := grdWords.Cells[grdWords.MouseCoord(x,y).x,
    // grdWords.MouseCoord(x,y).y];
  end;
end;

procedure TfrmMain.grd_2048MMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  n : integer;
begin
  if Button = mbLeft then
  begin
    // erase the temporary line
    DrawLine(grd_2048M,psDash, pmXor);
    // and draw the final one
    FEnd2 := Point(x, y);
    DrawLine(grd_2048M,psSolid, pmCopy);
    Paint;

    last_coord := grd_2048M.MouseCoord(x,y);

    GetDirection(first_coord,last_coord);
  end;
end;

procedure TfrmMain.grd_2048MPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  myTextStyle : TTextStyle;
begin
  myTextStyle.Alignment := taCenter;
  myTextStyle.Layout:= tlCenter;
  grd_2048M.Canvas.TextStyle := myTextStyle;
end;

procedure TfrmMain.DrawLine(grd : TStringGrid;
                            const PenStyle: TPenStyle;
                            const PenMode: TPenMode);
begin
  // draw the line (or erase the previous one)
  // with FBitmap.Canvas do
  with grd.Canvas do
  begin
    Pen.Color := clYellow;
    Pen.Style := PenStyle;
    Pen.Mode := PenMode;
    MoveTo(FEnd1.x, FEnd1.y);
    LineTo(FEnd2.x, FEnd2.y);
  end;
end;

function TfrmMain.GetDirection(first, last: TPoint): TWordDirection;
var
  x_fark,y_fark,p_fark,m_fark,s_length,sent_ind : integer;
begin
  // 0 = no direction...
  // 1 = left to right
  // 2 = up to down
  // 3 = cross to down
  // 4 = cross to back down
  // 5 = cross to back up
  // 6 = cross to up
  // 7 = right to left
  // 8 = down to up
  result.dir := 0;
  s_length := 0;

  x_fark := last.x-first.x;
  y_fark := last.y-first.y;
  p_fark := abs(x_fark)-abs(y_fark);

  if x_fark<>0 then
    s_length := abs(x_fark)
    else
      if y_fark<>0 then
        s_length := abs(y_fark) ;

  s_length := s_length + 1;

  m_fark := abs( abs(last.x-first.x)- abs(last.y-first.y) );

  if ((x_fark>y_fark) and (y_fark=0)) and (p_fark =m_fark) then
    begin
      Result.dir := 1;

    end;

  if ((x_fark=0) and (y_fark>0)) and ((p_fark<0) and (m_fark>0) ) then
    begin
      Result.dir := 2;

    end;

  if ((x_fark>0) and (y_fark>0)) and ((p_fark=0) and (m_fark=0) ) then
    begin
      Result.dir := 3;

    end;

  if ((x_fark<0) and (y_fark>0)) and ((p_fark=0) and (m_fark=0) ) then
    begin
      Result.dir := 4;

    end;

  if ((x_fark<0) and (y_fark<0)) and ((p_fark=0) and (m_fark=0) ) then
    begin
      Result.dir := 5;

    end;

  if ((x_fark>0) and (y_fark<0)) and ((p_fark=0) and (m_fark=0) ) then
    begin
      Result.dir := 6;

    end;

  if ((x_fark<0) and (y_fark=0)) and ((p_fark>0) and (m_fark>0) ) then
    begin
      Result.dir := 7;

    end;

  if ((x_fark=0) and (y_fark<0)) and ((p_fark<0) and (m_fark>0) ) then
    begin
      Result.dir := 8;

    end;

  if Result.dir>0 then
    begin
      grd_2048MMouseDown(nil,mbLeft,[],first.x,first.y);     // clear last line
      {Result.mes := GetWord(grdWords, first,last,Result.dir,s_length);
      sent_ind := mem_Puzzler.Items.IndexOf(Result.mes);
      if sent_ind<>-1 then
        begin
          mem_Puzzler.Selected[sent_ind] := true;
          ClearWord(grdWords, first,last,Result.dir,s_length);
          grdWordsMouseDown(nil,mbLeft,[],first.x,first.y);     // clear last line



        end; }
    end;

  {Panel4.Caption := 'First: '+
                    inttostr(first.x)+' '+inttostr(first.y) +
                    ' Last: '+
                    inttostr(last.x)+' '+inttostr(last.y) +
                    ' x y F: '+
                    inttostr(x_fark )+' '+inttostr(y_fark) +
                    ' p F: '+
                    inttostr( p_fark ) +
                    ' m F: '+
                    inttostr( m_fark ) +
                    ' Result: '+
                    inttostr( Result.dir ) +
                    ' s_len: '+
                    inttostr( s_length ) +
                    ' mes: '+
                    Result.mes +
                    '';   }


end;

end.

