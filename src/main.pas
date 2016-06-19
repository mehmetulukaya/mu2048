unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls,

  LCLType, ExtCtrls, ComCtrls
  {$IFDEF LINUX}
    ,resource, elfreader, versiontypes,versionresource
  {$ELSE}
    ,windows
  {$ENDIF}

  ;

type
  TDirSimple=(dirsLeft,
              dirsRight,
              dirsUp,
              dirsDown);

  TDir = (dirNowhere=0,
          dirLefToRight,
          dirUpToDown,
          dirCrossToDown,
          dirCrossToBackDown,
          dirCrossToBackUp,
          dirCrossToUp,
          dirRightToLeft,
          dirDownToUp);

type TgrdArr = array of array of Integer;


  { TfrmMain }

  TfrmMain = class(TForm)
    btnStart: TButton;
    btnUndo: TButton;
    btnCancel: TButton;
    cmb_Game_Type: TComboBox;
    cmb_Game_Level: TComboBox;
    edt_Moves_H: TEdit;
    edt_Score_M: TEdit;
    edt_Moves_M: TEdit;
    edt_StartNumber: TEdit;
    edt_Score_H: TEdit;
    grd_2048H: TStringGrid;
    grd_2048M: TStringGrid;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lbl_Machine: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbl_Human: TLabel;
    tmrComputer: TTimer;
    tmrGeneral: TTimer;
    btnPause: TToggleBox;
    TrackBar1: TTrackBar;
    procedure btnCancelClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure cmb_Game_LevelChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure grd_2048HDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure grd_2048HMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grd_2048HMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure grd_2048HMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grd_2048HPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure grd_2048MPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure tmrComputerTimer(Sender: TObject);
    procedure tmrGeneralTimer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { private declarations }
    FEnd1: TPoint;
    FEnd2: TPoint;
    procedure DrawLine(grd : TStringGrid;
                       const PenStyle: TPenStyle; const PenMode: TPenMode);
    function GetDirection(first,last:TPoint):TDir;
    procedure ClearLine(grd : TStringGrid);
  public
    { public declarations }

    procedure MakeMouseDir(direction: TDir);
    procedure GenerateRandom(grd:TStringGrid;base:Integer;var arr:TgrdArr);
    procedure StartNewGame(grd:TStringGrid);

    procedure ClearGrid(grd:TStringGrid;var arr:TgrdArr);
    function IsGrdClear(grd:TStringGrid):Boolean;
    function IsGrdFull(grd:TStringGrid):Boolean;
    function IsGameOver(var grd: TStringGrid; var arr: TgrdArr): Boolean;

    function WhichWay(var grd: TStringGrid; var arr: TgrdArr): Integer;
    function WhichWayII(var grd: TStringGrid; var arr: TgrdArr): Integer;

    procedure SaveGridValues(var grdOrgArr,grdBackArr:TgrdArr);
    procedure LoadGridValues(var grdBackArr,grdOrgArr:TgrdArr);

    procedure SetLength2D(var arr:TgrdArr;Dim1,Dim2:Integer);

    procedure MoveCells(grd:TStringGrid;
                       var arr:TgrdArr;
                       var arr_back:TgrdArr;
                       var Move_X:Integer;
                       dir:TDirSimple);
    function MoveToLeft(grd:TStringGrid;var arr:TgrdArr):Boolean;
    function MoveToRight(grd:TStringGrid;var arr:TgrdArr):Boolean;
    function MoveToUp(grd:TStringGrid;var arr:TgrdArr):Boolean;
    function MoveToDown(grd:TStringGrid;var arr:TgrdArr):Boolean;

    procedure ShowNumbers(grd:TStringGrid;var grdArr:TgrdArr);

    procedure ReportScore(var grd: TStringGrid; var edt_Score: TEdit);

  end;

var
  frmMain: TfrmMain;

  first_coord,
  last_coord : TPoint;

  started : Boolean=False;
  compt_started : Boolean=False;

  arr_grd_Human : TgrdArr;
  arr_grd_Human_Backup : TgrdArr;
  arr_grd_Computer : TgrdArr;
  arr_grd_Computer_Backup : TgrdArr;

  BaseNum : Integer;
  Move_H,
  Move_M : Integer;

  Saved : Boolean=False;
  versionnum : string;

implementation

{$R *.lfm}

{ TfrmMain }

{$IFDEF LINUX}
Function GetProgramVersion (Out Version : String) : Boolean;

Var
   RS : TResources;
   E : TElfResourceReader;
   VR : TVersionResource;
   I : Integer;

begin
   Version:='';
   RS:=TResources.Create;
   try
     E:=TElfResourceReader.Create;
     try
       Rs.LoadFromFile(ParamStr(0),E);
     finally
       E.Free;
     end;
     VR:=Nil;
     I:=0;
     While (VR=Nil) and (I<RS.Count) do
       begin
       if RS.Items[i] is TVersionResource then
          VR:=TVersionResource(RS.Items[i]);
       Inc(I);
       end;
     Result:=(VR<>Nil);
     if Result then
       For I:=0 to 3 do
         begin
         If (Version<>'') then
           Version:=Version+'.';
         Version:=Version+IntToStr(VR.FixedInfo.FileVersion[I]);
         end;
   Finally
     RS.FRee;
   end;
end;
{$ENDIF}

{$IFDEF WIN32}
function Sto_GetFmtFileVersion(const FileName: string = '';
  const Fmt: string = '%d.%d.%d.%d'): string;
var
  sFileName: string;
  iBufferSize: DWORD;
  iDummy: DWORD;
  pBuffer: Pointer;
  pFileInfo: Pointer;
  iVer: array[1..4] of word;
begin
  // set default value
    Result    := '';
    // get filename of exe/dll if no filename is specified
    sFileName := FileName;
    if (sFileName = '') then
    begin
      // prepare buffer for path and terminating #0
      SetLength(sFileName, MAX_PATH + 1);
      SetLength(sFileName,
        GetModuleFileName(hInstance, PChar(sFileName), MAX_PATH + 1));
    end;
    // get size of version info (0 if no version info exists)
    iBufferSize := GetFileVersionInfoSize(PChar(sFileName), iDummy);
    if (iBufferSize > 0) then
    begin
      GetMem(pBuffer, iBufferSize);
      try
        // get fixed file info (language independent)
        GetFileVersionInfo(PChar(sFileName), 0, iBufferSize, pBuffer);
        VerQueryValue(pBuffer, '\', pFileInfo, iDummy);
        // read version blocks
        iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
        iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
        iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
        iVer[4] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
      finally
        FreeMem(pBuffer);
      end;
      // format result string
      Result := Format(Fmt, [iVer[1], iVer[2], iVer[3], iVer[4]]);
    end;
end;
{$ENDIF}


function VisibleContrast(BackGroundColor : TColor):TColor;
const
 cHalfBrightness = ((0.3 * 255.0) + (0.59 * 255.0) + (0.11 * 255.0)) / 2.0;
var
 Brightness : double;
begin
 with TRGBQuad(BackGroundColor) do
  BrightNess := (0.3 * rgbRed) + (0.59 * rgbGreen) + (0.11 * rgbBlue);
 if (Brightness>cHalfBrightNess) then
  result := clblack
 else
  result := clwhite;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  {$IFDEF LINUX}
    GetProgramVersion( versionnum );
  {$ELSE}
    versionnum := 'Version: '+Sto_GetFmtFileVersion(Application.ExeName,'%d.%d.%d.%d');
  {$ENDIF}
  Caption:=Application.Title+' '+versionnum;
  Randomize;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not started then
    Exit;

  case key of
    VK_SPACE  : begin
       btnPause.Checked:=not btnPause.Checked;
    end;
  end;

  if btnPause.Checked then
    Exit;

  case key of
    VK_SPACE  : begin
    end;
    VK_UP:   MoveCells(grd_2048H,
                       arr_grd_Human,
                       arr_grd_Human_Backup,
                       Move_H,
                       dirsUp);
    VK_DOWN: MoveCells(grd_2048H,
                       arr_grd_Human,
                       arr_grd_Human_Backup,
                       Move_H,
                       dirsDown);
    VK_LEFT: MoveCells(grd_2048H,
                       arr_grd_Human,
                       arr_grd_Human_Backup,
                       Move_H,
                       dirsLeft);
    VK_RIGHT:MoveCells(grd_2048H,
                       arr_grd_Human,
                       arr_grd_Human_Backup,
                       Move_H,
                       dirsRight);
    VK_BACK: LoadGridValues(arr_grd_Human_Backup,arr_grd_Human);
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  cmb_Game_LevelChange(nil);
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  BaseNum := StrToInt(edt_StartNumber.Text);
  if IsGrdClear(grd_2048H) then
    begin
      StartNewGame(grd_2048H);
    end
    else
    begin
      if Application.
           MessageBox('Do you want to start a new game?',
                       PChar(Application.Title),
                       MB_YESNO)=mrYes then
        begin
          ClearGrid(grd_2048H,arr_grd_Human);
          ClearGrid(grd_2048M,arr_grd_Computer);
          lbl_Human.Caption:='....';
          lbl_Machine.Caption:='....';
          StartNewGame(grd_2048H);
        end;
    end;
  SaveGridValues(arr_grd_Human,arr_grd_Human_Backup);
end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
begin
  if Application.
       MessageBox('Do you want to cancel this game?',
                   PChar(Application.Title),
                   MB_YESNO)=mrYes then
    begin
      ClearGrid(grd_2048H,arr_grd_Human);
      ClearGrid(grd_2048M,arr_grd_Computer);
      lbl_Human.Caption:='....';
      lbl_Machine.Caption:='....';
      started:=False;
      compt_started:=False;
      Move_H:=0;
      Move_M:=0;
    end;
end;

procedure TfrmMain.btnUndoClick(Sender: TObject);
begin
  LoadGridValues(arr_grd_Human_Backup,arr_grd_Human);
end;

procedure TfrmMain.cmb_Game_LevelChange(Sender: TObject);
begin
  grd_2048H.Width:=263;
  grd_2048H.Height:=242;

  grd_2048M.Width:=263;
  grd_2048M.Height:=242;

  grd_2048H.ColCount:= cmb_Game_Level.ItemIndex+3;
  grd_2048H.RowCount:= cmb_Game_Level.ItemIndex+3;

  grd_2048M.ColCount:= cmb_Game_Level.ItemIndex+3;
  grd_2048M.RowCount:= cmb_Game_Level.ItemIndex+3;

  grd_2048H.DefaultColWidth:=(grd_2048H.Width div grd_2048H.ColCount);
  grd_2048H.DefaultRowHeight:=(grd_2048H.Height div grd_2048H.RowCount);

  grd_2048M.DefaultColWidth:=(grd_2048M.Width div grd_2048M.ColCount);
  grd_2048M.DefaultRowHeight:=(grd_2048M.Height div grd_2048M.RowCount);

  grd_2048H.Font.Size:=20-(cmb_Game_Level.ItemIndex*cmb_Game_Level.ItemIndex);
  grd_2048M.Font.Size:=20-(cmb_Game_Level.ItemIndex*cmb_Game_Level.ItemIndex);

  grd_2048H.Width:=grd_2048H.Width+4;
  grd_2048H.Height:=grd_2048H.Height+3;

  grd_2048M.Width:=grd_2048M.Width+4;
  grd_2048M.Height:=grd_2048M.Height+3;

  with grd_2048H do
  begin
    SetLength2D(arr_grd_Human,ColCount,RowCount);
    SetLength2D(arr_grd_Human_Backup,ColCount,RowCount);

    SetLength2D(arr_grd_Computer,ColCount,RowCount);
    SetLength2D(arr_grd_Computer_Backup,ColCount,RowCount);
  end;

  Move_H:=0;
  Move_M:=0;
  ClearGrid(grd_2048H,arr_grd_Human);
  ClearGrid(grd_2048M,arr_grd_Computer);
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  started:=False;
  compt_started:=False;
end;

procedure TfrmMain.grd_2048HDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  // for refreshing
  DrawLine(grd_2048H,psDash, pmXor);

end;

procedure TfrmMain.grd_2048HMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  first_coord := grd_2048H.MouseCoord(x,y);
  DrawLine(grd_2048H,psDash, pmXor);
  // record the start of the line
  FEnd1 := classes.Point(x, y);
  FEnd2 := FEnd1;
  DrawLine(grd_2048H,psDash, pmXor);
end;

procedure TfrmMain.grd_2048HMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssLeft in Shift then
  begin
    // erase the previous line
    DrawLine(grd_2048H,psDash, pmXor);
    // and draw the line for the new position
    FEnd2 := classes.Point(x, y);
    DrawLine(grd_2048H,psDash, pmXor);
    Paint;
  end;
end;

procedure TfrmMain.grd_2048HMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    // erase the temporary line
    DrawLine(grd_2048H,psDash, pmXor);
    // and draw the final one
    FEnd2 := classes.Point(x, y);
    DrawLine(grd_2048H,psSolid, pmCopy);
    Paint;

    last_coord := grd_2048H.MouseCoord(x,y);

    MakeMouseDir(GetDirection(first_coord,last_coord));
  end;
end;

procedure TfrmMain.grd_2048HPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  myTextStyle : TTextStyle;
  val : Integer;
begin
  myTextStyle.Alignment := taCenter;
  myTextStyle.Layout:= tlCenter;

  with grd_2048H do
  begin
    Canvas.TextStyle := myTextStyle;

    if Cells[aCol,aRow]='' then
      Exit;

    try
      val := StrToInt(Cells[aCol,aRow]);
    finally
      if (val<=BaseNum) then
        Canvas.Brush.Color:= clCream;

      if (val>BaseNum) and
         (val<=(BaseNum*2)) then
        Canvas.Brush.Color:= TColor($00DDEE);

      if (val>(BaseNum*2)) and
         (val<=(BaseNum*4)) then
        Canvas.Brush.Color:= TColor($00EEEE);

      if (val>(BaseNum*4)) and
         (val<=(BaseNum*8)) then
        Canvas.Brush.Color:= clYellow;

      if (val>(BaseNum*8)) and
         (val<=(BaseNum*16)) then
        Canvas.Brush.Color:= clAqua;

      if (val>(BaseNum*16)) and
         (val<=(BaseNum*32)) then
        Canvas.Brush.Color:= clLime;

      if (val>(BaseNum*32)) and
         (val<=(BaseNum*64)) then
        Canvas.Brush.Color:= clGreen;

      if (val>(BaseNum*64)) and
         (val<=(BaseNum*128)) then
        Canvas.Brush.Color:= clBlue;

      if (val>(BaseNum*128)) and
         (val<=(BaseNum*256)) then
        Canvas.Brush.Color:= clRed;

      if (val>(BaseNum*256)) and
         (val<=(BaseNum*512)) then
        Canvas.Brush.Color:= clPurple;

      if (val>(BaseNum*512)) and
         (val<=(BaseNum*1024)) then
        Canvas.Brush.Color:= clMaroon;

      if (val>(BaseNum*1024)) and
         (val<=(BaseNum*2048)) then
        Canvas.Brush.Color:= clNavy;

      if val>(BaseNum*2048) then
        Canvas.Brush.Color:= clBlack;

      Canvas.Font.Color:=VisibleContrast(Canvas.Brush.Color);
    end;
  end;
end;

procedure TfrmMain.grd_2048MPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  myTextStyle : TTextStyle;
  val : Integer;
begin
  myTextStyle.Alignment := taCenter;
  myTextStyle.Layout:= tlCenter;

  with grd_2048M do
  begin
    Canvas.TextStyle := myTextStyle;

    if Cells[aCol,aRow]='' then
      Exit;

    try
      val := StrToInt(Cells[aCol,aRow]);
    finally
      if (val<=BaseNum) then
        Canvas.Brush.Color:= clCream;

      if (val>BaseNum) and
         (val<=(BaseNum*2)) then
        Canvas.Brush.Color:= TColor($00DDEE);

      if (val>(BaseNum*2)) and
         (val<=(BaseNum*4)) then
        Canvas.Brush.Color:= TColor($00EEEE);

      if (val>(BaseNum*4)) and
         (val<=(BaseNum*8)) then
        Canvas.Brush.Color:= clYellow;

      if (val>(BaseNum*8)) and
         (val<=(BaseNum*16)) then
        Canvas.Brush.Color:= clAqua;

      if (val>(BaseNum*16)) and
         (val<=(BaseNum*32)) then
        Canvas.Brush.Color:= clLime;

      if (val>(BaseNum*32)) and
         (val<=(BaseNum*64)) then
        Canvas.Brush.Color:= clGreen;

      if (val>(BaseNum*64)) and
         (val<=(BaseNum*128)) then
        Canvas.Brush.Color:= clBlue;

      if (val>(BaseNum*128)) and
         (val<=(BaseNum*256)) then
        Canvas.Brush.Color:= clRed;

      if (val>(BaseNum*256)) and
         (val<=(BaseNum*512)) then
        Canvas.Brush.Color:= clPurple;

      if (val>(BaseNum*512)) and
         (val<=(BaseNum*1024)) then
        Canvas.Brush.Color:= clMaroon;

      if (val>(BaseNum*1024)) and
         (val<=(BaseNum*2048)) then
        Canvas.Brush.Color:= clNavy;

      if val>(BaseNum*2048) then
        Canvas.Brush.Color:= clBlack;

      Canvas.Font.Color:=VisibleContrast(Canvas.Brush.Color);
    end;
  end;
end;

var
  cnt:Integer=0;
  old_comp_state:Integer=0;
  comp_state:Integer=0;
procedure TfrmMain.tmrComputerTimer(Sender: TObject);
begin
  if cmb_Game_Type.ItemIndex<>1 then
    Exit;

  if btnPause.Checked then
    Exit;

  if not compt_started then
    Exit;

  comp_state := WhichWay(grd_2048M,arr_grd_Computer);

  case comp_state of
    1: MoveCells(grd_2048M,
                 arr_grd_Computer,
                 arr_grd_Computer_Backup,
                 Move_M,
                 dirsLeft);
    2: MoveCells(grd_2048M,
                 arr_grd_Computer,
                 arr_grd_Computer_Backup,
                 Move_M,
                 dirsRight);
    3: MoveCells(grd_2048M,
                 arr_grd_Computer,
                 arr_grd_Computer_Backup,
                 Move_M,
                 dirsUp);
    4: MoveCells(grd_2048M,
                 arr_grd_Computer,
                 arr_grd_Computer_Backup,
                 Move_M,
                 dirsDown);
  end;

end;

procedure TfrmMain.tmrGeneralTimer(Sender: TObject);
var
  condition:Boolean;
begin

  if cmb_Game_Type.ItemIndex<>1 then
    begin
      condition := started;
    end
    else
    begin
      condition := started or compt_started;
    end;

  edt_StartNumber.Enabled:=not condition;
  cmb_Game_Type.Enabled:=not condition;

  TrackBar1.Enabled:=not condition;

  edt_Moves_H.Enabled:=not condition;
  edt_Moves_M.Enabled:=not condition;
  edt_Score_H.Enabled:=not condition;
  edt_Score_M.Enabled:=not condition;

  btnCancel.Enabled:=condition;
  btnUndo.Enabled:=condition;
  btnStart.Enabled:=not condition;

  cmb_Game_Type.Enabled:=not condition;
  cmb_Game_Level.Enabled:=not condition;

  //grd_2048H.Enabled:=not started;
  //grd_2048M.Enabled:=not started;

  ReportScore(grd_2048H,edt_Score_H);

  edt_Moves_H.Text:=IntToStr(Move_H);
  edt_Moves_M.Text:=IntToStr(Move_M);
  if condition then
    begin
      ShowNumbers(grd_2048H,arr_grd_Human);
      ShowNumbers(grd_2048M,arr_grd_Computer);
    end;
  ReportScore(grd_2048M,edt_Score_M);
end;

procedure TfrmMain.TrackBar1Change(Sender: TObject);
begin
  tmrComputer.Interval:=TrackBar1.Position;
end;

procedure TfrmMain.DrawLine(grd : TStringGrid;
                            const PenStyle: TPenStyle;
                            const PenMode: TPenMode);
begin
  // draw the line (or erase the previous one)
  with grd.Canvas do
  begin
    Pen.Color := clYellow;
    Pen.Style := PenStyle;
    Pen.Mode := PenMode;
    MoveTo(FEnd1.x, FEnd1.y);
    LineTo(FEnd2.x, FEnd2.y);
  end;
end;

function TfrmMain.GetDirection(first, last: TPoint): TDir;
var
  x_fark,y_fark,p_fark,m_fark,s_length : integer;
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

  result := dirNowhere;
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

  if ((x_fark>y_fark) and (y_fark=0)) then
    begin
      Result := dirLefToRight;

    end;

  if ((x_fark=0) and (y_fark>0)) then
    begin
      Result := dirUpToDown;

    end;

  if ((x_fark>0) and (y_fark>0)) then
    begin
      Result := dirCrossToDown;

    end;

  if ((x_fark<0) and (y_fark>0))  then
    begin
      Result := dirCrossToBackDown;

    end;

  if ((x_fark<0) and (y_fark<0))  then
    begin
      Result := dirCrossToBackUp;

    end;

  if ((x_fark>0) and (y_fark<0))  then
    begin
      Result := dirCrossToUp;

    end;

  if ((x_fark<0) and (y_fark=0))  then
    begin
      Result := dirRightToLeft;

    end;

  if ((x_fark=0) and (y_fark<0))  then
    begin
      Result := dirDownToUp;

    end;

  //grd_2048MMouseDown(nil,mbLeft,[],first.x,first.y);     // clear last line

  // for debug only
  {Caption := 'First: '+
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
                    inttostr( Ord(Result) ) +
                    ' s_len: '+
                    inttostr( s_length ) +
                    ' mes: '+
                    '' +
                    '';}


end;

procedure TfrmMain.ClearLine(grd: TStringGrid);
begin
  first_coord := grd_2048H.MouseCoord(0,0);
  DrawLine(grd_2048H,psDash, pmXor);
  // record the start of the line
  FEnd1 := classes.Point(0, 0);
  FEnd2 := FEnd1;
  DrawLine(grd_2048H,psDash, pmXor);
  grd.Clean;
end;

procedure TfrmMain.MakeMouseDir(direction: TDir);
begin
  if btnPause.Checked then
    Exit;

  if started then
  case direction of
    dirNowhere:;
    dirLefToRight      : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsRight);
    dirUpToDown        : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsDown);
    dirCrossToDown     : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsDown);
    dirCrossToBackDown : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsDown);
    dirCrossToBackUp   : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsUp);
    dirCrossToUp       : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsUp);
    dirRightToLeft     : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsLeft);
    dirDownToUp        : MoveCells(grd_2048H,
                                   arr_grd_Human,
                                   arr_grd_Human_Backup,
                                   Move_H,
                                   dirsUp);
  end;

end;

procedure TfrmMain.GenerateRandom(grd: TStringGrid; base: Integer;
  var arr: TgrdArr);
var
  tout : TDateTime;
  c,r  : Integer;
begin
  tout := now + (1/24/60/60)*(1/2);
  with grd do
  begin
    repeat
      c := Random(ColCount);
      r := Random(RowCount);
    until (Cells[c,r]='') or (now>tout);
    if tout>=now then
        arr[c][r]:=base;
  end;
  ShowNumbers(grd,arr_grd_Human);
end;

procedure TfrmMain.StartNewGame(grd: TStringGrid);
begin
  started := True;
  Move_H:=0;
  GenerateRandom(grd,BaseNum,arr_grd_Human);
  GenerateRandom(grd,BaseNum,arr_grd_Human);
  if cmb_Game_Type.ItemIndex=1 then
    begin
      compt_started:=True;
      Move_M:=0;
      SaveGridValues(arr_grd_Human,arr_grd_Computer);
    end;
end;

procedure TfrmMain.ClearGrid(grd: TStringGrid; var arr: TgrdArr);
var
  r,c : Integer;
begin
  ClearLine(grd);
  for r := 0 to grd.RowCount-1 do
    for c := 0 to grd.ColCount-1 do
      begin
        arr[c][r]:=0;
      end;
end;

function TfrmMain.IsGrdClear(grd: TStringGrid): Boolean;
var
  r,c : Integer;
begin
  Result := True;
  for r := 0 to grd.RowCount-1 do
    for c := 0 to grd.ColCount-1 do
      if (grd.Cells[c,r]<>'') then
      begin
        Result:=False;
        Break;
      end;
end;

function TfrmMain.IsGrdFull(grd: TStringGrid): Boolean;
var
  r,c : Integer;
begin
  Result := True;
  for r := 0 to grd.RowCount-1 do
    for c := 0 to grd.ColCount-1 do
      if (grd.Cells[c,r]='') then
      begin
        Result:=False;
        Break;
      end;
end;

function TfrmMain.IsGameOver(var grd: TStringGrid; var arr: TgrdArr): Boolean;
var
  xc,xr,r,c : Integer;
begin
  Result := True;

  if Not IsGrdFull(grd) then
    begin
      Result:=False;
      Exit;
    end;

  // check all directions for possibilities
  // to left
  for r:= 0 to Pred(grd.RowCount) do
    for c:=0 to (grd.ColCount) do
      with grd do
      begin
        xc := c;
        repeat
          dec(xc);
          if xc-1<0 then
            Break;
          if arr[xc-1][r]=arr[xc][r] then
            begin
              Result:=False;
              Break;
            end;
        until xc<=0;
      end;

  // to right
  for r:= 0 to Pred(grd.RowCount) do
    for c:=(grd.ColCount) downto 0 do
      with grd do
      begin
        xc := c-1;
        repeat
          inc(xc);
          if xc+1>=grd.ColCount then
            Break;

          if arr[xc+1][r]=arr[xc][r] then
            begin
              Result:=False;
              Break;
            end;
        until xc>=grd.ColCount;
      end;
  // to up
  for c:=0 to Pred(grd.ColCount) do
    for r:= 0 to (grd.RowCount) do
    with grd do
    begin
      xr := r;
      repeat
        dec(xr);
        if xr-1<0 then
          Break;

        if arr[c][xr-1]=arr[c][xr] then
          begin
            Result:=False;
            Break;
          end;
      until xr<=0;
    end;

  // to down
  for c:=0 to Pred(grd.ColCount) do
    for r:= (grd.RowCount) downto 0 do
      with grd do
      begin
        xr := r-1;
        repeat
          inc(xr);
          if xr+1>=grd.RowCount then
            Break;
          if arr[c][xr+1]=arr[c][xr] then
            begin
              Result:=False;
              Break;
            end;
        until xr>=grd.RowCount;
      end;

end;

var
  max:integer=0;
  whc_cnt:integer=0;
function TfrmMain.WhichWay(var grd: TStringGrid; var arr: TgrdArr): Integer;
var
  max_way,
  xc,xr,r,c : Integer;
begin
  max_way :=0;
  Result :=-1;

  inc(whc_cnt);
  if whc_cnt>4 then
    begin
      whc_cnt:=1;
      max:=0;
    end;
  //max:=0;
  // check all directions for possibilities
  // to left
  //if whc_cnt=1 then
  if max_way=0 then
  for r:= 0 to Pred(grd.RowCount) do
    for c:=0 to (grd.ColCount) do
      with grd do
      begin
        xc := c;
        repeat
          dec(xc);
          if xc-1<0 then
            Break;
          if arr[xc-1][r]=arr[xc][r] then
            begin
              if (arr[xc][r]>max) then
                begin
                  max:=arr[xc-1][r];
                  max_way:=1;
                end;
              Break;
            end;
        until (xc<=0) or (max_way<>0);
      end;

  // to right
  //if whc_cnt=2 then
  if max_way=0 then
  for r:= 0 to Pred(grd.RowCount) do
    for c:=(grd.ColCount) downto 0 do
      with grd do
      begin
        xc := c-1;
        repeat
          inc(xc);
          if xc+1>=grd.ColCount then
            Break;

          if arr[xc+1][r]=arr[xc][r] then
            begin
              if (arr[xc][r]>max) then
                begin
                  max:=arr[xc][r];
                  max_way:=2;
                end;
              Break;
            end;
        until (xc>=grd.ColCount) or (max_way<>0);
      end;

  // to up
  //if whc_cnt=3 then
  if max_way=0 then
  for c:=0 to Pred(grd.ColCount) do
    for r:= 0 to (grd.RowCount) do
    with grd do
    begin
      xr := r;
      repeat
        dec(xr);
        if xr-1<0 then
          Break;

        if arr[c][xr-1]=arr[c][xr] then
          begin
            if (arr[c][xr]>max) then
              begin
                max:=arr[c][xr];
                max_way:=3;
              end;
            Break;
          end;
      until (xr<=0) or (max_way<>0);
    end;

  // to down
  //if whc_cnt=4 then
  if max_way=0 then
  for c:=0 to Pred(grd.ColCount) do
    for r:= (grd.RowCount) downto 0 do
      with grd do
      begin
        xr := r-1;
        repeat
          inc(xr);
          if xr+1>=grd.RowCount then
            Break;
          if arr[c][xr+1]=arr[c][xr] then
            begin
              if (arr[c][xr]>max) then
                begin
                  max:=arr[c][xr];
                  max_way:=4;
                end;
              Break;
            end;
        until (xr>=grd.RowCount) or (max_way<>0);
      end;

  if max_way=0 then
    max_way:=whc_cnt;

  Result:=max_way;
end;

function TfrmMain.WhichWayII(var grd: TStringGrid; var arr: TgrdArr): Integer;
var
  max_way,
  xc,xr,r,c : Integer;
begin
  max_way :=0;
  Result :=-1;

  // check all directions for possibilities
  // to left
  //if whc_cnt=1 then
  for r:= 0 to Pred(grd.RowCount) do
    for c:=0 to (grd.ColCount) do
      with grd do
      begin
        xc := c;
        repeat
          dec(xc);
          if xc-1<0 then
            Break;
          if arr[xc-1][r]=arr[xc][r] then
            begin
              if (arr[xc][r]>=max) then
                begin
                  max:=arr[xc-1][r];
                  max_way:=1;
                end;
              Break;
            end;
        until (xc<=0) or (max_way<>0);
      end;
end;

procedure TfrmMain.SaveGridValues(var grdOrgArr, grdBackArr: TgrdArr);
var
  lc,lr,
  c,r:Integer;
begin
  lc := length(grdOrgArr)-1;
  lr := length(grdOrgArr[0])-1;
  for c:=0 to lc do
    for r:=0 to lr do
      grdBackArr[c][r] := grdOrgArr[c][r];
  Saved:=True;
end;

procedure TfrmMain.LoadGridValues(var grdBackArr, grdOrgArr: TgrdArr);
var
  lc,lr,
  c,r:Integer;
begin
  lc := length(grdOrgArr)-1;
  lr := length(grdOrgArr[0])-1;
  for c:=0 to lc do
    for r:=0 to lr do
      grdOrgArr[c][r] := grdBackArr[c][r];
  if Saved then
    begin
      Dec(Move_H);
      Saved:=False;
    end;
end;

procedure TfrmMain.SetLength2D(var arr: TgrdArr; Dim1, Dim2: Integer);
var
  Cnt : Integer;
begin
  SetLength(arr,Dim1);
  for Cnt:=0 to Dim1-1 do
    SetLength(arr[Cnt],Dim2);
end;

procedure TfrmMain.MoveCells(grd: TStringGrid; var arr: TgrdArr;
  var arr_back: TgrdArr; var Move_X: Integer; dir: TDirSimple);
begin
  if IsGameOver(grd,arr) then
    begin
      // ShowMessage('Game is over!');
      case grd.Name of
        'grd_2048H':begin
                      lbl_Human.Caption:='Game is over!';
                      started:=False;
        end;
        'grd_2048M':begin
                      lbl_Machine.Caption:='Game is over!';
                      compt_started:=False;
        end;
      end;
      Exit;
    end;

  SaveGridValues(arr,arr_back);
  case dir of
    dirsRight :if MoveToRight(grd,arr) then
                 begin
                   GenerateRandom(grd,BaseNum,arr);
                   Inc(Move_X);
                 end;
    dirsLeft  :if MoveToLeft(grd,arr) then
                 begin
                   GenerateRandom(grd,BaseNum,arr);
                   Inc(Move_X);
                 end;
    dirsUp    :if MoveToUp(grd,arr) then
                 begin
                   GenerateRandom(grd,BaseNum,arr);
                   Inc(Move_X);
                 end;
    dirsDown  :if MoveToDown(grd,arr) then
                 begin
                   GenerateRandom(grd,BaseNum,arr);
                   Inc(Move_X);
                 end
    else
      Exit;
  end;
  tmrGeneralTimer(nil);
  grd.Update;

end;

function TfrmMain.MoveToLeft(grd: TStringGrid; var arr: TgrdArr): Boolean;
var
  xc,c,r : Integer;
  quit_loop : Boolean;
begin
  Result:=False;
  for r:= 0 to Pred(grd.RowCount) do
    begin
      quit_loop := False;
      c:=0;
      while not quit_loop do
      begin
        inc(c);
        if c>=grd.ColCount then
          Break;
        xc := c;
        if arr[xc-1][r]=arr[xc][r] then
          begin
            arr[xc-1][r]:=arr[xc-1][r]+arr[xc][r];
            arr[xc][r]:=0;
            Result:=True;
          end;
      end;

      quit_loop := False;
      c:=0;
      while not quit_loop do
      begin
        inc(c);
        if c>grd.ColCount then
          Break;

        with grd do
        begin
          xc := c;
          repeat

            dec(xc);
            if xc-1<0 then
              Break;
            if arr[xc-1][r]=0 then
              begin
                arr[xc-1][r]:=arr[xc][r];
                arr[xc][r]:=0;
                Result:=True;
              end;
          until xc<=0;
        end; // with grp
      end;
      if Result then
        Continue;
    end;
  tmrGeneralTimer(nil);
end;


function TfrmMain.MoveToRight(grd: TStringGrid; var arr: TgrdArr): Boolean;
var
  xc,c,r : Integer;
  quit_loop : Boolean;
begin
  Result:=False;
  for r:= 0 to Pred(grd.RowCount) do
    begin
      quit_loop := False;
      c:=grd.ColCount;
      while not quit_loop do
      begin
        dec(c);
        if c<=0 then
          Break;
        xc := c;
        if arr[xc-1][r]=arr[xc][r] then
          begin
            arr[xc][r]:=arr[xc-1][r]+arr[xc][r];
            arr[xc-1][r]:=0;
            Result:=True;
          end;
      end;

      quit_loop := False;
      c:=grd.ColCount;
      while not quit_loop do
      begin
        dec(c);
        if c<0 then
          Break;

        with grd do
        begin
          xc := c-1;
          repeat
            inc(xc);
            if xc+1>=grd.ColCount then
              Break;

            if arr[xc+1][r]=0 then
              begin
                arr[xc+1][r]:=arr[xc][r];
                arr[xc][r]:=0;
                Result:=True;
              end;
          until xc>=grd.ColCount;
          tmrGeneralTimer(nil);
        end;
      end;
      if Result then
        Continue;
    end;
  tmrGeneralTimer(nil);
end;

function TfrmMain.MoveToUp(grd: TStringGrid; var arr: TgrdArr): Boolean;
var
  xr,c,r : Integer;
  quit_loop : Boolean;
begin
  Result:=False;
  for c:= 0 to Pred(grd.ColCount) do
    begin
      quit_loop := False;
      r:=-1;
      while not quit_loop do
      begin
        inc(r);
        if r>grd.RowCount then
          Break;

        xr := r;
        if arr[c][xr+1]=arr[c][xr] then
          begin
            arr[c][xr]:=arr[c][xr+1]+arr[c][xr];
            arr[c][xr+1]:=0;
            Result:=True;
          end;
      end;

      quit_loop := False;
      r:=0;
      while not quit_loop do
      begin
        inc(r);
        if r>grd.RowCount then
          Break;
        with grd do
        begin
          xr := r;
          repeat
            dec(xr);
            if xr-1<0 then
              Break;

            if arr[c][xr-1]=0 then
              begin
                arr[c][xr-1]:=arr[c][xr];
                arr[c][xr]:=0;
                Result:=True;
              end;
          until xr<=0;
        end;
      end;
    end;
  tmrGeneralTimer(nil);
end;

function TfrmMain.MoveToDown(grd: TStringGrid; var arr: TgrdArr): Boolean;
var
  xr,c,r : Integer;
  quit_loop : Boolean;
begin
  Result:=False;
  for c:= 0 to Pred(grd.ColCount) do
    begin
      quit_loop := False;
      r:=grd.RowCount;
      while not quit_loop do
      begin
        dec(r);
        if r<0 then
          Break;
        xr := r;
        if arr[c][xr-1]=arr[c][xr] then
          begin
            arr[c][xr]:=arr[c][xr-1]+arr[c][xr];
            arr[c][xr-1]:=0;
            Result:=True;
          end;
      end;

      quit_loop := False;
      r:=grd.RowCount;
      while not quit_loop do
      begin
        dec(r);
        if r<0 then
          Break;
        with grd do
        begin
          xr := r-1;
          repeat
            inc(xr);
            if xr+1>=grd.RowCount then
              Break;

            if arr[c][xr+1]=0 then
              begin
                arr[c][xr+1]:=arr[c][xr];
                arr[c][xr]:=0;
                Result:=True;
              end;
          until xr>=grd.RowCount;
        end;
      end;
    end; // for
  tmrGeneralTimer(nil);
end;

procedure TfrmMain.ShowNumbers(grd: TStringGrid; var grdArr: TgrdArr);
var
  c,r:Integer;
begin
  with grd do
  begin
    for c:=0 to Pred(grd.ColCount) do
      for r:= 0 to Pred(grd.RowCount) do
        begin
          if grdArr[c][r]<>0 then
            Cells[c,r]:=IntToStr(grdArr[c][r])
            else
              Cells[c,r]:='';
        end;
  end;
end;

procedure TfrmMain.ReportScore(var grd: TStringGrid; var edt_Score: TEdit);
var
  score,
  c,r:Integer;
begin
  score := 0;
  for c:=0 to Pred(grd.ColCount) do
    for r:=0 to Pred(grd.RowCount) do
      if grd.Cells[c,r]<>'' then
        score := score + StrToInt(grd.Cells[c,r]);
  edt_Score.Text:= IntToStr(score);
end;



end.

