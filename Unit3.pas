unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, Menus, DateUtils;

type
  { ===================== ЗАПИСИ ===================== }
  { Используем ShortString, чтобы записи можно было писать
    в типизированный файл через file of TVacancy / file of TCandidate. }
  TVacancy = record
    FirmName: ShortString;
    Specialty: ShortString;
    Position: ShortString;
    Salary: Integer;
    VacationDays: Integer;
    NeedHigherEd: Boolean;
    AgeMin: Integer;
    AgeMax: Integer;
  end;

  TCandidate = record
    FIO: ShortString;
    BirthDate: TDate;
    Specialty: ShortString;
    HasHigherEd: Boolean;
    DesiredPosition: ShortString;
    MinSalary: Integer;
  end;

  { ===================== УЗЛЫ СПИСКОВ ===================== }
  PVacancyNode = ^TVacancyNode;
  TVacancyNode = record
    Data: TVacancy;
    Next: PVacancyNode;
    Prev: PVacancyNode;
  end;

  PCandidateNode = ^TCandidateNode;
  TCandidateNode = record
    Data: TCandidate;
    Next: PCandidateNode;
    Prev: PCandidateNode;
  end;

  { ===================== ФОРМА ===================== }
  TForm3 = class(TForm)
    PanelTop: TPanel;
    LabelTitle: TLabel;
    BtnMenu: TButton;
    PanelNav: TPanel;
    LabelSort: TLabel;
    LabelFirm: TLabel;
    BtnVacancies: TButton;
    BtnCandidates: TButton;
    BtnMatch: TButton;
    BtnDeficit: TButton;
    BtnReport: TButton;
    BtnFindVacancy: TButton;
    BtnFindCandidate: TButton;
    BtnResetFilter: TButton;
    ComboSort: TComboBox;
    ComboFirm: TComboBox;
    BtnMatchFirm: TButton;
    StringGrid1: TStringGrid;
    PanelBottom: TPanel;
    LabelStatus: TLabel;
    LblVacCount: TLabel;
    LblCandCount: TLabel;
    PopupMenu1: TPopupMenu;

    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnMenuClick(Sender: TObject);
    procedure BtnVacanciesClick(Sender: TObject);
    procedure BtnCandidatesClick(Sender: TObject);
    procedure BtnMatchClick(Sender: TObject);
    procedure BtnDeficitClick(Sender: TObject);
    procedure BtnReportClick(Sender: TObject);
    procedure BtnFindVacancyClick(Sender: TObject);
    procedure BtnFindCandidateClick(Sender: TObject);
    procedure BtnResetFilterClick(Sender: TObject);
    procedure ComboSortChange(Sender: TObject);
    procedure ComboFirmChange(Sender: TObject);
    procedure BtnMatchFirmClick(Sender: TObject);

  private
    { Указатели на начало и конец списков }
    VacHead, VacTail: PVacancyNode;
    CandHead, CandTail: PCandidateNode;
    VacCount, CandCount: Integer;

    SortColumn: Integer;
    SortAscending: Boolean;
    LastView: Integer;

    { Выбранная фирма для подбора }
    SelectedFirm: string;

    { Работа со списками }
    procedure VacAdd(const V: TVacancy);
    procedure CandAdd(const C: TCandidate);
    procedure VacClear;
    procedure CandClear;
    function  VacGet(Index: Integer): PVacancyNode;
    function  CandGet(Index: Integer): PCandidateNode;
    procedure VacDelete(Index: Integer);
    procedure CandDelete(Index: Integer);

    { Файлы }
    procedure LoadDataFromFiles;
    procedure SaveDataToFiles;

    { Отображение }
    procedure ShowVacanciesGrid;
    procedure ShowCandidatesGrid;
    procedure ClearGrid;
    function  CalculateAge(BirthDate: TDate): Integer;
    procedure UpdateStatus;
    procedure RefreshFirmList;
    procedure ShowVacanciesByFirm(const AFirmName: string);

    { Сортировка }
    procedure SortVacanciesByColumn(Column: Integer; Ascending: Boolean);
    procedure SortCandidatesByColumn(Column: Integer; Ascending: Boolean);

    { Поиск }
    procedure ShowVacanciesGridFiltered(const FilterSpec: string);
    procedure ShowCandidatesGridFiltered(const FilterSpec: string);

    { Меню }
    procedure ShowMainMenu;
    procedure MenuReadFile(Sender: TObject);
    procedure MenuViewData(Sender: TObject);
    procedure MenuSortData(Sender: TObject);
    procedure MenuSearchData(Sender: TObject);
    procedure MenuAddData(Sender: TObject);
    procedure MenuDeleteData(Sender: TObject);
    procedure MenuEditData(Sender: TObject);
    procedure MenuSpecialFuncs(Sender: TObject);
    procedure MenuExitNoSave(Sender: TObject);
    procedure MenuExitWithSave(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

{ ============================================================
  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
  ============================================================ }
function BoolToDaNet(B: Boolean): string;
begin
  if B then Result := 'Да' else Result := 'Нет';
end;

function BoolToDaNetLower(B: Boolean): string;
begin
  if B then Result := 'да' else Result := 'нет';
end;

{ ============================================================
  ДИАЛОГ ВЫБОРА ИЗ СПИСКА
  Создаёт форму программно, без отдельного .dfm-файла.
  Возвращает индекс выбранного элемента или -1 при отмене.
  ============================================================ }
function SelectFromList(const ACaption, APrompt: string;
                        const AItems: array of string): Integer;
var
  Dlg: TForm;
  Lbl: TLabel;
  Cmb: TComboBox;
  BtnOk, BtnCancel: TButton;
  i: Integer;
begin
  Result := -1;

  Dlg := TForm.Create(nil);
  try
    Dlg.Caption      := ACaption;
    Dlg.ClientWidth  := 400;
    Dlg.ClientHeight := 180;
    Dlg.BorderStyle  := bsDialog;
    Dlg.Position     := poMainFormCenter;
    Dlg.Font.Name    := 'Segoe UI';
    Dlg.Font.Size    := 10;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent  := Dlg;
    Lbl.Left    := 20;
    Lbl.Top     := 20;
    Lbl.Caption := APrompt;

    Cmb := TComboBox.Create(Dlg);
    Cmb.Parent      := Dlg;
    Cmb.Left        := 20;
    Cmb.Top         := 50;
    Cmb.Width       := 350;
    Cmb.Style       := csDropDownList;
    for i := Low(AItems) to High(AItems) do
      Cmb.Items.Add(AItems[i]);
    if Cmb.Items.Count > 0 then
      Cmb.ItemIndex := 0;

    BtnOk := TButton.Create(Dlg);
    BtnOk.Parent      := Dlg;
    BtnOk.Left        := 190;
    BtnOk.Top         := 120;
    BtnOk.Width       := 85;
    BtnOk.Height      := 30;
    BtnOk.Caption     := 'ОК';
    BtnOk.Default     := True;
    BtnOk.ModalResult := mrOk;

    BtnCancel := TButton.Create(Dlg);
    BtnCancel.Parent      := Dlg;
    BtnCancel.Left        := 285;
    BtnCancel.Top         := 120;
    BtnCancel.Width       := 85;
    BtnCancel.Height      := 30;
    BtnCancel.Caption     := 'Отмена';
    BtnCancel.Cancel      := True;
    BtnCancel.ModalResult := mrCancel;

    if Dlg.ShowModal = mrOk then
      Result := Cmb.ItemIndex;
  finally
    Dlg.Free;
  end;
end;

{ ============================================================
  ИНИЦИАЛИЗАЦИЯ
  ============================================================ }
procedure TForm3.FormCreate(Sender: TObject);
begin
  VacHead := nil;  VacTail := nil;  VacCount := 0;
  CandHead := nil; CandTail := nil; CandCount := 0;

  SortColumn := -1;
  SortAscending := True;
  LastView := 0;
  SelectedFirm := '';

  KeyPreview := True;

  ComboSort.Items.Clear;
  ComboSort.Items.Add('ФИО / Название ^');
  ComboSort.Items.Add('ФИО / Название v');
  ComboSort.Items.Add('Специальность ^');
  ComboSort.Items.Add('Специальность v');
  ComboSort.Items.Add('Оклад ^');
  ComboSort.Items.Add('Оклад v');
  ComboSort.Items.Add('Возраст ^');
  ComboSort.Items.Add('Возраст v');
  ComboSort.ItemIndex := -1;

  StringGrid1.Options := [goFixedVertLine, goFixedHorzLine, goVertLine,
                          goHorzLine, goRangeSelect, goColSizing, goRowSelect];

  if FileExists(ExtractFilePath(Application.ExeName) + 'firms.dat') or
     FileExists(ExtractFilePath(Application.ExeName) + 'cands.dat') then
    LoadDataFromFiles
  else
    ShowMessage('Файлы данных не найдены. Будут созданы при сохранении.');

  UpdateStatus;
  ShowVacanciesGrid;
  RefreshFirmList;
end;

{ ============================================================
  РАБОТА С ДИНАМИЧЕСКИМИ СПИСКАМИ (New / Dispose)
  ============================================================ }
procedure TForm3.VacAdd(const V: TVacancy);
var
  Node: PVacancyNode;
begin
  New(Node);
  Node^.Data := V;
  Node^.Next := nil;
  Node^.Prev := VacTail;
  if VacTail <> nil then
    VacTail^.Next := Node
  else
    VacHead := Node;
  VacTail := Node;
  Inc(VacCount);
end;

procedure TForm3.CandAdd(const C: TCandidate);
var
  Node: PCandidateNode;
begin
  New(Node);
  Node^.Data := C;
  Node^.Next := nil;
  Node^.Prev := CandTail;
  if CandTail <> nil then
    CandTail^.Next := Node
  else
    CandHead := Node;
  CandTail := Node;
  Inc(CandCount);
end;

procedure TForm3.VacClear;
var
  Node, Tmp: PVacancyNode;
begin
  Node := VacHead;
  while Node <> nil do
  begin
    Tmp := Node^.Next;
    Dispose(Node);
    Node := Tmp;
  end;
  VacHead := nil; VacTail := nil; VacCount := 0;
end;

procedure TForm3.CandClear;
var
  Node, Tmp: PCandidateNode;
begin
  Node := CandHead;
  while Node <> nil do
  begin
    Tmp := Node^.Next;
    Dispose(Node);
    Node := Tmp;
  end;
  CandHead := nil; CandTail := nil; CandCount := 0;
end;

function TForm3.VacGet(Index: Integer): PVacancyNode;
var
  Node: PVacancyNode;
  i: Integer;
begin
  Node := VacHead;
  i := 0;
  while (Node <> nil) and (i < Index) do
  begin
    Node := Node^.Next;
    Inc(i);
  end;
  Result := Node;
end;

function TForm3.CandGet(Index: Integer): PCandidateNode;
var
  Node: PCandidateNode;
  i: Integer;
begin
  Node := CandHead;
  i := 0;
  while (Node <> nil) and (i < Index) do
  begin
    Node := Node^.Next;
    Inc(i);
  end;
  Result := Node;
end;

procedure TForm3.VacDelete(Index: Integer);
var
  Node: PVacancyNode;
begin
  Node := VacGet(Index);
  if Node = nil then Exit;
  if Node^.Prev <> nil then Node^.Prev^.Next := Node^.Next
  else VacHead := Node^.Next;
  if Node^.Next <> nil then Node^.Next^.Prev := Node^.Prev
  else VacTail := Node^.Prev;
  Dispose(Node);
  Dec(VacCount);
end;

procedure TForm3.CandDelete(Index: Integer);
var
  Node: PCandidateNode;
begin
  Node := CandGet(Index);
  if Node = nil then Exit;
  if Node^.Prev <> nil then Node^.Prev^.Next := Node^.Next
  else CandHead := Node^.Next;
  if Node^.Next <> nil then Node^.Next^.Prev := Node^.Prev
  else CandTail := Node^.Prev;
  Dispose(Node);
  Dec(CandCount);
end;

{ ============================================================
  ФАЙЛЫ (ТИПИЗИРОВАННЫЕ)
  ============================================================ }
procedure TForm3.LoadDataFromFiles;
var
  FV: file of TVacancy;
  FC: file of TCandidate;
  V: TVacancy;
  C: TCandidate;
  Path: string;
begin
  VacClear;
  CandClear;

  Path := ExtractFilePath(Application.ExeName);

  if FileExists(Path + 'firms.dat') then
  begin
    AssignFile(FV, Path + 'firms.dat');
    Reset(FV);
    try
      while not Eof(FV) do
      begin
        Read(FV, V);
        VacAdd(V);
      end;
    finally
      CloseFile(FV);
    end;
  end;

  if FileExists(Path + 'cands.dat') then
  begin
    AssignFile(FC, Path + 'cands.dat');
    Reset(FC);
    try
      while not Eof(FC) do
      begin
        Read(FC, C);
        CandAdd(C);
      end;
    finally
      CloseFile(FC);
    end;
  end;

  RefreshFirmList;
end;

procedure TForm3.SaveDataToFiles;
var
  FV: file of TVacancy;
  FC: file of TCandidate;
  NodeV: PVacancyNode;
  NodeC: PCandidateNode;
  Path: string;
begin
  Path := ExtractFilePath(Application.ExeName);

  AssignFile(FV, Path + 'firms.dat');
  Rewrite(FV);
  try
    NodeV := VacHead;
    while NodeV <> nil do
    begin
      Write(FV, NodeV^.Data);
      NodeV := NodeV^.Next;
    end;
  finally
    CloseFile(FV);
  end;

  AssignFile(FC, Path + 'cands.dat');
  Rewrite(FC);
  try
    NodeC := CandHead;
    while NodeC <> nil do
    begin
      Write(FC, NodeC^.Data);
      NodeC := NodeC^.Next;
    end;
  finally
    CloseFile(FC);
  end;

  ShowMessage('Данные сохранены');
end;

{ ============================================================
  ВСПОМОГАТЕЛЬНЫЕ
  ============================================================ }
function TForm3.CalculateAge(BirthDate: TDate): Integer;
var
  Y, M, D: Word;
begin
  DecodeDate(Now, Y, M, D);
  Result := Y - YearOf(BirthDate);
  if (MonthOf(BirthDate) > M) or
     ((MonthOf(BirthDate) = M) and (DayOf(BirthDate) > D)) then
    Dec(Result);
end;

procedure TForm3.ClearGrid;
var
  i: Integer;
begin
  StringGrid1.RowCount := 2;
  for i := 0 to StringGrid1.ColCount - 1 do
    StringGrid1.Cols[i].Clear;
end;

procedure TForm3.UpdateStatus;
begin
  LblVacCount.Caption  := 'Вакансий: '   + IntToStr(VacCount);
  LblCandCount.Caption := 'Кандидатов: ' + IntToStr(CandCount);
end;

{ ============================================================
  ЗАПОЛНЕНИЕ СПИСКА ФИРМ
  ============================================================ }
procedure TForm3.RefreshFirmList;
var
  Node: PVacancyNode;
  Firms: TStringList;
  SaveText: string;
begin
  if ComboFirm = nil then Exit;

  SaveText := ComboFirm.Text;
  Firms := TStringList.Create;
  try
    Firms.Sorted := True;
    Firms.Duplicates := dupIgnore;

    Node := VacHead;
    while Node <> nil do
    begin
      if Trim(string(Node^.Data.FirmName)) <> '' then
        Firms.Add(string(Node^.Data.FirmName));
      Node := Node^.Next;
    end;

    ComboFirm.Items.BeginUpdate;
    try
      ComboFirm.Items.Clear;
      ComboFirm.Items.Assign(Firms);
    finally
      ComboFirm.Items.EndUpdate;
    end;

    if ComboFirm.Items.Count > 0 then
    begin
      if (SaveText <> '') and (ComboFirm.Items.IndexOf(SaveText) >= 0) then
        ComboFirm.ItemIndex := ComboFirm.Items.IndexOf(SaveText)
      else
        ComboFirm.ItemIndex := 0;
      SelectedFirm := ComboFirm.Items[ComboFirm.ItemIndex];
    end
    else
      SelectedFirm := '';
  finally
    Firms.Free;
  end;
end;

{ ============================================================
  ОТОБРАЖЕНИЕ ВАКАНСИЙ ВЫБРАННОЙ ФИРМЫ
  ============================================================ }
procedure TForm3.ShowVacanciesByFirm(const AFirmName: string);
var
  Node: PVacancyNode;
  row: Integer;
begin
  ClearGrid;
  StringGrid1.ColCount := 8;
  StringGrid1.RowCount := 2;

  StringGrid1.Cells[0, 0] := '№';
  StringGrid1.Cells[1, 0] := 'Фирма';
  StringGrid1.Cells[2, 0] := 'Специальность';
  StringGrid1.Cells[3, 0] := 'Должность';
  StringGrid1.Cells[4, 0] := 'Оклад';
  StringGrid1.Cells[5, 0] := 'Отпуск (дн)';
  StringGrid1.Cells[6, 0] := 'ВО';
  StringGrid1.Cells[7, 0] := 'Возраст';

  row := 1;
  Node := VacHead;
  while Node <> nil do
  begin
    if CompareText(string(Node^.Data.FirmName), AFirmName) = 0 then
    begin
      StringGrid1.RowCount := row + 1;
      StringGrid1.Cells[0, row] := IntToStr(row);
      StringGrid1.Cells[1, row] := string(Node^.Data.FirmName);
      StringGrid1.Cells[2, row] := string(Node^.Data.Specialty);
      StringGrid1.Cells[3, row] := string(Node^.Data.Position);
      StringGrid1.Cells[4, row] := IntToStr(Node^.Data.Salary);
      StringGrid1.Cells[5, row] := IntToStr(Node^.Data.VacationDays);
      StringGrid1.Cells[6, row] := BoolToDaNet(Node^.Data.NeedHigherEd);
      StringGrid1.Cells[7, row] := IntToStr(Node^.Data.AgeMin) + '-' +
                                   IntToStr(Node^.Data.AgeMax);
      Inc(row);
    end;
    Node := Node^.Next;
  end;

  if row = 1 then
    ShowMessage('У фирмы "' + AFirmName + '" нет вакансий.');

  LastView := 5;   // 5 = режим «вакансии выбранной фирмы»
  UpdateStatus;
end;

{ ============================================================
  ОТОБРАЖЕНИЕ
  ============================================================ }
procedure TForm3.ShowVacanciesGrid;
var
  i: Integer;
  Node: PVacancyNode;
begin
  ClearGrid;
  StringGrid1.ColCount := 8;
  StringGrid1.RowCount := VacCount + 1;

  StringGrid1.Cells[0, 0] := '№';
  StringGrid1.Cells[1, 0] := 'Фирма';
  StringGrid1.Cells[2, 0] := 'Специальность';
  StringGrid1.Cells[3, 0] := 'Должность';
  StringGrid1.Cells[4, 0] := 'Оклад';
  StringGrid1.Cells[5, 0] := 'Отпуск (дн)';
  StringGrid1.Cells[6, 0] := 'ВО';
  StringGrid1.Cells[7, 0] := 'Возраст';

  Node := VacHead;
  i := 0;
  while Node <> nil do
  begin
    StringGrid1.Cells[0, i+1] := IntToStr(i+1);
    StringGrid1.Cells[1, i+1] := string(Node^.Data.FirmName);
    StringGrid1.Cells[2, i+1] := string(Node^.Data.Specialty);
    StringGrid1.Cells[3, i+1] := string(Node^.Data.Position);
    StringGrid1.Cells[4, i+1] := IntToStr(Node^.Data.Salary);
    StringGrid1.Cells[5, i+1] := IntToStr(Node^.Data.VacationDays);
    StringGrid1.Cells[6, i+1] := BoolToDaNet(Node^.Data.NeedHigherEd);
    StringGrid1.Cells[7, i+1] := IntToStr(Node^.Data.AgeMin) + '-' +
                                 IntToStr(Node^.Data.AgeMax);
    Node := Node^.Next;
    Inc(i);
  end;
  LastView := 0;
  UpdateStatus;
end;

procedure TForm3.ShowCandidatesGrid;
var
  i: Integer;
  Node: PCandidateNode;
begin
  ClearGrid;
  StringGrid1.ColCount := 7;
  StringGrid1.RowCount := CandCount + 1;

  StringGrid1.Cells[0, 0] := '№';
  StringGrid1.Cells[1, 0] := 'ФИО';
  StringGrid1.Cells[2, 0] := 'Дата рождения';
  StringGrid1.Cells[3, 0] := 'Специальность';
  StringGrid1.Cells[4, 0] := 'ВО';
  StringGrid1.Cells[5, 0] := 'Желаемая должность';
  StringGrid1.Cells[6, 0] := 'Мин. оклад';

  Node := CandHead;
  i := 0;
  while Node <> nil do
  begin
    StringGrid1.Cells[0, i+1] := IntToStr(i+1);
    StringGrid1.Cells[1, i+1] := string(Node^.Data.FIO);
    StringGrid1.Cells[2, i+1] := DateToStr(Node^.Data.BirthDate);
    StringGrid1.Cells[3, i+1] := string(Node^.Data.Specialty);
    StringGrid1.Cells[4, i+1] := BoolToDaNet(Node^.Data.HasHigherEd);
    StringGrid1.Cells[5, i+1] := string(Node^.Data.DesiredPosition);
    StringGrid1.Cells[6, i+1] := IntToStr(Node^.Data.MinSalary);
    Node := Node^.Next;
    Inc(i);
  end;
  LastView := 1;
  UpdateStatus;
end;

{ ============================================================
  СОРТИРОВКА
  ============================================================ }
procedure TForm3.SortVacanciesByColumn(Column: Integer; Ascending: Boolean);
var
  i, j, n: Integer;
  NodeI, NodeJ: PVacancyNode;
  Tmp: TVacancy;
  NeedSwap: Boolean;
begin
  n := VacCount;
  for i := 0 to n - 2 do
  begin
    NodeI := VacGet(i);
    for j := i + 1 to n - 1 do
    begin
      NodeJ := VacGet(j);
      case Column of
        1: if Ascending then NeedSwap := CompareText(string(NodeI^.Data.FirmName), string(NodeJ^.Data.FirmName)) > 0
                       else NeedSwap := CompareText(string(NodeI^.Data.FirmName), string(NodeJ^.Data.FirmName)) < 0;
        2: if Ascending then NeedSwap := CompareText(string(NodeI^.Data.Specialty), string(NodeJ^.Data.Specialty)) > 0
                       else NeedSwap := CompareText(string(NodeI^.Data.Specialty), string(NodeJ^.Data.Specialty)) < 0;
        3: if Ascending then NeedSwap := CompareText(string(NodeI^.Data.Position), string(NodeJ^.Data.Position)) > 0
                       else NeedSwap := CompareText(string(NodeI^.Data.Position), string(NodeJ^.Data.Position)) < 0;
        4: if Ascending then NeedSwap := NodeI^.Data.Salary > NodeJ^.Data.Salary
                       else NeedSwap := NodeI^.Data.Salary < NodeJ^.Data.Salary;
        5: if Ascending then NeedSwap := NodeI^.Data.VacationDays > NodeJ^.Data.VacationDays
                       else NeedSwap := NodeI^.Data.VacationDays < NodeJ^.Data.VacationDays;
        6: if Ascending then NeedSwap := Ord(NodeI^.Data.NeedHigherEd) > Ord(NodeJ^.Data.NeedHigherEd)
                       else NeedSwap := Ord(NodeI^.Data.NeedHigherEd) < Ord(NodeJ^.Data.NeedHigherEd);
        7: if Ascending then NeedSwap := NodeI^.Data.AgeMin > NodeJ^.Data.AgeMin
                       else NeedSwap := NodeI^.Data.AgeMin < NodeJ^.Data.AgeMin;
      else
        NeedSwap := False;
      end;
      if NeedSwap then
      begin
        Tmp := NodeI^.Data;
        NodeI^.Data := NodeJ^.Data;
        NodeJ^.Data := Tmp;
      end;
    end;
  end;
  ShowVacanciesGrid;
end;

procedure TForm3.SortCandidatesByColumn(Column: Integer; Ascending: Boolean);
var
  i, j, n: Integer;
  NodeI, NodeJ: PCandidateNode;
  Tmp: TCandidate;
  NeedSwap: Boolean;
begin
  n := CandCount;
  for i := 0 to n - 2 do
  begin
    NodeI := CandGet(i);
    for j := i + 1 to n - 1 do
    begin
      NodeJ := CandGet(j);
      case Column of
        1: if Ascending then NeedSwap := CompareText(string(NodeI^.Data.FIO), string(NodeJ^.Data.FIO)) > 0
                       else NeedSwap := CompareText(string(NodeI^.Data.FIO), string(NodeJ^.Data.FIO)) < 0;
        2: if Ascending then NeedSwap := NodeI^.Data.BirthDate > NodeJ^.Data.BirthDate
                       else NeedSwap := NodeI^.Data.BirthDate < NodeJ^.Data.BirthDate;
        3: if Ascending then NeedSwap := CompareText(string(NodeI^.Data.Specialty), string(NodeJ^.Data.Specialty)) > 0
                       else NeedSwap := CompareText(string(NodeI^.Data.Specialty), string(NodeJ^.Data.Specialty)) < 0;
        4: if Ascending then NeedSwap := Ord(NodeI^.Data.HasHigherEd) > Ord(NodeJ^.Data.HasHigherEd)
                       else NeedSwap := Ord(NodeI^.Data.HasHigherEd) < Ord(NodeJ^.Data.HasHigherEd);
        5: if Ascending then NeedSwap := CompareText(string(NodeI^.Data.DesiredPosition), string(NodeJ^.Data.DesiredPosition)) > 0
                       else NeedSwap := CompareText(string(NodeI^.Data.DesiredPosition), string(NodeJ^.Data.DesiredPosition)) < 0;
        6: if Ascending then NeedSwap := NodeI^.Data.MinSalary > NodeJ^.Data.MinSalary
                       else NeedSwap := NodeI^.Data.MinSalary < NodeJ^.Data.MinSalary;
      else
        NeedSwap := False;
      end;
      if NeedSwap then
      begin
        Tmp := NodeI^.Data;
        NodeI^.Data := NodeJ^.Data;
        NodeJ^.Data := Tmp;
      end;
    end;
  end;
  ShowCandidatesGrid;
end;

procedure TForm3.ComboSortChange(Sender: TObject);
var
  Idx: Integer;
  Asc: Boolean;
begin
  Idx := ComboSort.ItemIndex;
  if Idx < 0 then Exit;
  Asc := (Idx mod 2 = 0);

  if (LastView = 0) or (LastView = 2) then
  begin
    case Idx of
      0, 1: SortVacanciesByColumn(1, Asc);
      2, 3: SortVacanciesByColumn(2, Asc);
      4, 5: SortVacanciesByColumn(4, Asc);
      6, 7: SortVacanciesByColumn(7, Asc);
    end;
  end
  else if (LastView = 1) or (LastView = 3) then
  begin
    case Idx of
      0, 1: SortCandidatesByColumn(1, Asc);
      2, 3: SortCandidatesByColumn(3, Asc);
      4, 5: SortCandidatesByColumn(6, Asc);
      6, 7: SortCandidatesByColumn(2, Asc);
    end;
  end
  else
    ShowMessage('Сортировка доступна в режимах просмотра Вакансий или Кандидатов.');
end;

{ ============================================================
  ВЫБОР ФИРМЫ ИЗ СПИСКА
  ============================================================ }
procedure TForm3.ComboFirmChange(Sender: TObject);
begin
  if ComboFirm.ItemIndex < 0 then Exit;
  SelectedFirm := ComboFirm.Items[ComboFirm.ItemIndex];
  ShowVacanciesByFirm(SelectedFirm);
end;

{ ============================================================
  ПОИСК
  ============================================================ }
procedure TForm3.BtnFindVacancyClick(Sender: TObject);
var
  FilterSpec: string;
begin
  FilterSpec := InputBox('Поиск вакансий',
                         'Введите специальность:', '');
  if Trim(FilterSpec) = '' then Exit;
  ShowVacanciesGridFiltered(FilterSpec);
end;

procedure TForm3.ShowVacanciesGridFiltered(const FilterSpec: string);
var
  row: Integer;
  Node: PVacancyNode;
begin
  ClearGrid;
  StringGrid1.ColCount := 8;
  StringGrid1.RowCount := 2;

  StringGrid1.Cells[0, 0] := '№';
  StringGrid1.Cells[1, 0] := 'Фирма';
  StringGrid1.Cells[2, 0] := 'Специальность';
  StringGrid1.Cells[3, 0] := 'Должность';
  StringGrid1.Cells[4, 0] := 'Оклад';
  StringGrid1.Cells[5, 0] := 'Отпуск (дн)';
  StringGrid1.Cells[6, 0] := 'ВО';
  StringGrid1.Cells[7, 0] := 'Возраст';

  row := 1;
  Node := VacHead;
  while Node <> nil do
  begin
    if Pos(LowerCase(FilterSpec), LowerCase(string(Node^.Data.Specialty))) > 0 then
    begin
      StringGrid1.RowCount := row + 1;
      StringGrid1.Cells[0, row] := IntToStr(row);
      StringGrid1.Cells[1, row] := string(Node^.Data.FirmName);
      StringGrid1.Cells[2, row] := string(Node^.Data.Specialty);
      StringGrid1.Cells[3, row] := string(Node^.Data.Position);
      StringGrid1.Cells[4, row] := IntToStr(Node^.Data.Salary);
      StringGrid1.Cells[5, row] := IntToStr(Node^.Data.VacationDays);
      StringGrid1.Cells[6, row] := BoolToDaNet(Node^.Data.NeedHigherEd);
      StringGrid1.Cells[7, row] := IntToStr(Node^.Data.AgeMin) + '-' +
                                   IntToStr(Node^.Data.AgeMax);
      Inc(row);
    end;
    Node := Node^.Next;
  end;

  if row = 1 then
    ShowMessage('Вакансии по специальности "' + FilterSpec + '" не найдены.');
  LastView := 2;
  UpdateStatus;
end;

procedure TForm3.BtnFindCandidateClick(Sender: TObject);
var
  FilterSpec: string;
begin
  FilterSpec := InputBox('Поиск кандидатов',
                         'Введите специальность:', '');
  if Trim(FilterSpec) = '' then Exit;
  ShowCandidatesGridFiltered(FilterSpec);
end;

procedure TForm3.ShowCandidatesGridFiltered(const FilterSpec: string);
var
  row: Integer;
  Node: PCandidateNode;
begin
  ClearGrid;
  StringGrid1.ColCount := 7;
  StringGrid1.RowCount := 2;

  StringGrid1.Cells[0, 0] := '№';
  StringGrid1.Cells[1, 0] := 'ФИО';
  StringGrid1.Cells[2, 0] := 'Дата рождения';
  StringGrid1.Cells[3, 0] := 'Специальность';
  StringGrid1.Cells[4, 0] := 'ВО';
  StringGrid1.Cells[5, 0] := 'Желаемая должность';
  StringGrid1.Cells[6, 0] := 'Мин. оклад';

  row := 1;
  Node := CandHead;
  while Node <> nil do
  begin
    if Pos(LowerCase(FilterSpec), LowerCase(string(Node^.Data.Specialty))) > 0 then
    begin
      StringGrid1.RowCount := row + 1;
      StringGrid1.Cells[0, row] := IntToStr(row);
      StringGrid1.Cells[1, row] := string(Node^.Data.FIO);
      StringGrid1.Cells[2, row] := DateToStr(Node^.Data.BirthDate);
      StringGrid1.Cells[3, row] := string(Node^.Data.Specialty);
      StringGrid1.Cells[4, row] := BoolToDaNet(Node^.Data.HasHigherEd);
      StringGrid1.Cells[5, row] := string(Node^.Data.DesiredPosition);
      StringGrid1.Cells[6, row] := IntToStr(Node^.Data.MinSalary);
      Inc(row);
    end;
    Node := Node^.Next;
  end;

  if row = 1 then
    ShowMessage('Кандидаты по специальности "' + FilterSpec + '" не найдены.');
  LastView := 3;
  UpdateStatus;
end;

procedure TForm3.BtnResetFilterClick(Sender: TObject);
begin
  SortColumn := -1;
  SortAscending := True;
  ComboSort.ItemIndex := -1;
  LastView := 0;
  ShowVacanciesGrid;
end;

{ ============================================================
  КНОПКИ
  ============================================================ }
procedure TForm3.BtnMenuClick(Sender: TObject);
begin
  ShowMainMenu;
end;

procedure TForm3.BtnVacanciesClick(Sender: TObject);
begin
  ComboSort.ItemIndex := -1;
  ShowVacanciesGrid;
end;

procedure TForm3.BtnCandidatesClick(Sender: TObject);
begin
  ComboSort.ItemIndex := -1;
  ShowCandidatesGrid;
end;

{ ============================================================
  СФ: ПОДБОР КАНДИДАТОВ (общий, с записью в файл)
  ============================================================ }
procedure TForm3.BtnMatchClick(Sender: TObject);
var
  VNode: PVacancyNode;
  CNode: PCandidateNode;
  row, Age, MatchCount: Integer;
  IsMatch: Boolean;
  Report: TStringList;
begin
  ClearGrid;
  StringGrid1.ColCount := 5;
  StringGrid1.RowCount := 2;
  StringGrid1.Cells[0, 0] := 'Фирма / Вакансия';
  StringGrid1.Cells[1, 0] := 'Кандидат (ФИО)';
  StringGrid1.Cells[2, 0] := 'Специальность';
  StringGrid1.Cells[3, 0] := 'ВО';
  StringGrid1.Cells[4, 0] := 'Возраст';

  Report := TStringList.Create;
  try
    Report.Add('РЕЗУЛЬТАТЫ ПОДБОРА КАНДИДАТОВ');
    Report.Add('');

    row := 1;
    MatchCount := 0;
    VNode := VacHead;
    while VNode <> nil do
    begin
      CNode := CandHead;
      while CNode <> nil do
      begin
        Age := CalculateAge(CNode^.Data.BirthDate);
        IsMatch := True;

        if CompareText(string(VNode^.Data.Specialty), string(CNode^.Data.Specialty)) <> 0 then
          IsMatch := False;
        if CompareText(string(VNode^.Data.Position), string(CNode^.Data.DesiredPosition)) <> 0 then
          IsMatch := False;
        if VNode^.Data.NeedHigherEd and (not CNode^.Data.HasHigherEd) then
          IsMatch := False;
        if (Age < VNode^.Data.AgeMin) or (Age > VNode^.Data.AgeMax) then
          IsMatch := False;
        if CNode^.Data.MinSalary > VNode^.Data.Salary then
          IsMatch := False;

        if IsMatch then
        begin
          Inc(MatchCount);
          StringGrid1.RowCount := row + 1;
          StringGrid1.Cells[0, row] := string(VNode^.Data.FirmName) + ' (' + string(VNode^.Data.Position) + ')';
          StringGrid1.Cells[1, row] := string(CNode^.Data.FIO);
          StringGrid1.Cells[2, row] := string(CNode^.Data.Specialty);
          StringGrid1.Cells[3, row] := BoolToDaNet(CNode^.Data.HasHigherEd);
          StringGrid1.Cells[4, row] := IntToStr(Age);

          Report.Add(Format('Фирма: %s | Должность: %s | Кандидат: %s | Спец.: %s | ВО: %s | Возраст: %d',
            [string(VNode^.Data.FirmName), string(VNode^.Data.Position), string(CNode^.Data.FIO),
             string(CNode^.Data.Specialty),
             BoolToDaNet(CNode^.Data.HasHigherEd), Age]));
          Inc(row);
        end;
        CNode := CNode^.Next;
      end;
      VNode := VNode^.Next;
    end;

    if MatchCount = 0 then
    begin
      Report.Add('Совпадений не найдено.');
      ShowMessage('Совпадений не найдено.');
    end;

    Report.SaveToFile(ExtractFilePath(Application.ExeName) + 'match_report.txt');
    ShowMessage('Результаты подбора сохранены');
  finally
    Report.Free;
  end;

  LastView := 4;
  ComboSort.ItemIndex := -1;
end;

{ ============================================================
  СФ: ПОДБОР КАНДИДАТОВ ДЛЯ ВЫБРАННОЙ ФИРМЫ
  ============================================================ }
procedure TForm3.BtnMatchFirmClick(Sender: TObject);
var
  VNode: PVacancyNode;
  CNode: PCandidateNode;
  row, Age, MatchCount: Integer;
  IsMatch: Boolean;
  Report: TStringList;
  FirmName: string;
begin
  if (ComboFirm = nil) or (ComboFirm.ItemIndex < 0) or (ComboFirm.Items.Count = 0) then
  begin
    ShowMessage('Сначала выберите фирму из списка.');
    Exit;
  end;

  FirmName := ComboFirm.Items[ComboFirm.ItemIndex];
  SelectedFirm := FirmName;

  ClearGrid;
  StringGrid1.ColCount := 6;
  StringGrid1.RowCount := 2;
  StringGrid1.Cells[0, 0] := 'Фирма';
  StringGrid1.Cells[1, 0] := 'Должность';
  StringGrid1.Cells[2, 0] := 'Кандидат (ФИО)';
  StringGrid1.Cells[3, 0] := 'Специальность';
  StringGrid1.Cells[4, 0] := 'ВО';
  StringGrid1.Cells[5, 0] := 'Возраст';

  Report := TStringList.Create;
  try
    Report.Add('ПОДБОР КАНДИДАТОВ ДЛЯ ФИРМЫ: ' + FirmName);
    Report.Add('');

    row := 1;
    MatchCount := 0;
    VNode := VacHead;
    while VNode <> nil do
    begin
      if CompareText(string(VNode^.Data.FirmName), FirmName) = 0 then
      begin
        CNode := CandHead;
        while CNode <> nil do
        begin
          Age := CalculateAge(CNode^.Data.BirthDate);
          IsMatch := True;

          if CompareText(string(VNode^.Data.Specialty), string(CNode^.Data.Specialty)) <> 0 then
            IsMatch := False;
          if CompareText(string(VNode^.Data.Position), string(CNode^.Data.DesiredPosition)) <> 0 then
            IsMatch := False;
          if VNode^.Data.NeedHigherEd and (not CNode^.Data.HasHigherEd) then
            IsMatch := False;
          if (Age < VNode^.Data.AgeMin) or (Age > VNode^.Data.AgeMax) then
            IsMatch := False;
          if CNode^.Data.MinSalary > VNode^.Data.Salary then
            IsMatch := False;

          if IsMatch then
          begin
            Inc(MatchCount);
            StringGrid1.RowCount := row + 1;
            StringGrid1.Cells[0, row] := FirmName;
            StringGrid1.Cells[1, row] := string(VNode^.Data.Position);
            StringGrid1.Cells[2, row] := string(CNode^.Data.FIO);
            StringGrid1.Cells[3, row] := string(CNode^.Data.Specialty);
            StringGrid1.Cells[4, row] := BoolToDaNet(CNode^.Data.HasHigherEd);
            StringGrid1.Cells[5, row] := IntToStr(Age);

            Report.Add(Format('Фирма: %s | Должность: %s | Кандидат: %s | Спец.: %s | ВО: %s | Возраст: %d',
              [FirmName, string(VNode^.Data.Position), string(CNode^.Data.FIO),
               string(CNode^.Data.Specialty),
               BoolToDaNet(CNode^.Data.HasHigherEd), Age]));
            Inc(row);
          end;
          CNode := CNode^.Next;
        end;
      end;
      VNode := VNode^.Next;
    end;

    if MatchCount = 0 then
    begin
      Report.Add('Для фирмы "' + FirmName + '" совпадений не найдено.');
      ShowMessage('Для фирмы "' + FirmName + '" совпадений не найдено.');
    end;

    Report.SaveToFile(ExtractFilePath(Application.ExeName) + 'match_firm_report.txt');
    ShowMessage('Результаты подбора для фирмы "' + FirmName +
                '" сохранены в match_firm_report.txt');
  finally
    Report.Free;
  end;

  LastView := 6;   // 6 = режим «подбор для фирмы»
  ComboSort.ItemIndex := -1;
end;

{ ============================================================
  ДЕФИЦИТНЫЕ СПЕЦИАЛИСТЫ (с записью в файл)
  ============================================================ }
procedure TForm3.BtnDeficitClick(Sender: TObject);
var
  VNode: PVacancyNode;
  CNode: PCandidateNode;
  CandCountForVac, Age, i: Integer;
  IsMatch: Boolean;
  DeficitList: TStringList;
begin
  DeficitList := TStringList.Create;
  try
    DeficitList.Add('СПИСОК ДЕФИЦИТНЫХ СПЕЦИАЛИСТОВ');
    DeficitList.Add('Критерий: кандидатов < 10% от общего числа вакансий');
    DeficitList.Add('');

    VNode := VacHead;
    while VNode <> nil do
    begin
      CandCountForVac := 0;
      CNode := CandHead;
      while CNode <> nil do
      begin
        Age := CalculateAge(CNode^.Data.BirthDate);
        IsMatch := True;

        if CompareText(string(VNode^.Data.Specialty), string(CNode^.Data.Specialty)) <> 0 then
          IsMatch := False;
        if CompareText(string(VNode^.Data.Position), string(CNode^.Data.DesiredPosition)) <> 0 then
          IsMatch := False;
        if VNode^.Data.NeedHigherEd and (not CNode^.Data.HasHigherEd) then
          IsMatch := False;
        if (Age < VNode^.Data.AgeMin) or (Age > VNode^.Data.AgeMax) then
          IsMatch := False;
        if CNode^.Data.MinSalary > VNode^.Data.Salary then
          IsMatch := False;

        if IsMatch then Inc(CandCountForVac);
        CNode := CNode^.Next;
      end;

      if CandCountForVac < (VacCount * 0.1) then
        DeficitList.Add(Format('Фирма: %s | Должность: %s | Кандидатов: %d',
                               [string(VNode^.Data.FirmName), string(VNode^.Data.Position), CandCountForVac]));
      VNode := VNode^.Next;
    end;

    if DeficitList.Count <= 3 then
      DeficitList.Add('Дефицита не обнаружено (по критерию 10%).');

    ClearGrid;
    StringGrid1.ColCount := 1;
    StringGrid1.RowCount := DeficitList.Count;
    for i := 0 to DeficitList.Count - 1 do
      StringGrid1.Cells[0, i] := DeficitList[i];

    DeficitList.SaveToFile(ExtractFilePath(Application.ExeName) + 'deficit_report.txt');
    ShowMessage('Отчет по дефициту сохранен в deficit_report.txt');

    LastView := 4;
    ComboSort.ItemIndex := -1;
  finally
    DeficitList.Free;
  end;
end;

procedure TForm3.BtnReportClick(Sender: TObject);
var
  Report: TStringList;
  VNode: PVacancyNode;
  CNode: PCandidateNode;
begin
  Report := TStringList.Create;
  try
    Report.Add('ПОЛНЫЙ ОТЧЕТ БИРЖИ ТРУДА');
    Report.Add('');
    Report.Add('ВАКАНСИИ');
    VNode := VacHead;
    while VNode <> nil do
    begin
      Report.Add(Format('%s; %s; %s; Оклад: %d; Отпуск: %d; ВО: %s; Возраст: %d-%d',
        [string(VNode^.Data.FirmName), string(VNode^.Data.Specialty), string(VNode^.Data.Position),
         VNode^.Data.Salary, VNode^.Data.VacationDays,
         BoolToDaNet(VNode^.Data.NeedHigherEd),
         VNode^.Data.AgeMin, VNode^.Data.AgeMax]));
      VNode := VNode^.Next;
    end;

    Report.Add('');
    Report.Add('КАНДИДАТЫ');
    CNode := CandHead;
    while CNode <> nil do
    begin
      Report.Add(Format('%s; %s; %s; ВО: %s; Желаемая должность: %s; Мин. оклад: %d',
        [string(CNode^.Data.FIO), DateToStr(CNode^.Data.BirthDate), string(CNode^.Data.Specialty),
         BoolToDaNet(CNode^.Data.HasHigherEd),
         string(CNode^.Data.DesiredPosition), CNode^.Data.MinSalary]));
      CNode := CNode^.Next;
    end;

    Report.SaveToFile(ExtractFilePath(Application.ExeName) + 'full_report.txt');
    ShowMessage('Полный отчет сохранен в full_report.txt');
  finally
    Report.Free;
  end;
end;

{ ============================================================
  ГЛАВНОЕ МЕНЮ (10 пунктов)
  ============================================================ }
procedure TForm3.ShowMainMenu;
var
  Item: TMenuItem;

  function AddItem(const ACaption: string; AOnClick: TNotifyEvent): TMenuItem;
  begin
    Result := TMenuItem.Create(PopupMenu1);
    Result.Caption := ACaption;
    Result.OnClick := AOnClick;
    PopupMenu1.Items.Add(Result);
  end;

begin
  PopupMenu1.Items.Clear;

  AddItem('1. Чтение данных из файла',              MenuReadFile);
  AddItem('2. Просмотр всего списка',               MenuViewData);
  AddItem('3. Сортировка данных',                   MenuSortData);
  AddItem('4. Поиск данных',                        MenuSearchData);
  AddItem('5. Добавление данных в список',          MenuAddData);
  AddItem('6. Удаление данных из списка',           MenuDeleteData);
  AddItem('7. Редактирование данных',               MenuEditData);
  AddItem('8. Подбор кандидатов и дефицит',         MenuSpecialFuncs);
  AddItem('9. Выход без сохранения',                MenuExitNoSave);
  AddItem('10. Выход с сохранением',                MenuExitWithSave);

  PopupMenu1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

{ ============================================================
  ОБРАБОТЧИКИ ПУНКТОВ МЕНЮ
  ============================================================ }
procedure TForm3.MenuReadFile(Sender: TObject);
begin
  LoadDataFromFiles;
  ShowVacanciesGrid;
  ShowMessage('Данные загружены');
end;

procedure TForm3.MenuViewData(Sender: TObject);
var
  Choice: Integer;
begin
  Choice := SelectFromList('Просмотр данных',
                           'Какой список просмотреть?',
                           ['Вакансии', 'Кандидаты']);

  if Choice = 0 then
    ShowVacanciesGrid
  else if Choice = 1 then
    ShowCandidatesGrid;
end;

procedure TForm3.MenuSortData(Sender: TObject);
begin
  ShowMessage('Выберите столбец и направление в выпадающем списке «Сортировка».');
  ComboSort.DroppedDown := True;
end;

procedure TForm3.MenuSearchData(Sender: TObject);
var
  Choice: Integer;
begin
  Choice := SelectFromList('Поиск данных',
                           'В каком списке искать?',
                           ['Вакансии', 'Кандидаты']);

  if Choice = 0 then
    BtnFindVacancyClick(Sender)
  else if Choice = 1 then
    BtnFindCandidateClick(Sender);
end;

procedure TForm3.MenuAddData(Sender: TObject);
var
  Choice: Integer;
  V: TVacancy;
  C: TCandidate;
  Res: string;
begin
  Choice := SelectFromList('Добавление данных',
                           'В какой список добавить запись?',
                           ['Вакансии', 'Кандидаты']);

  if Choice = 0 then
  begin
    V.FirmName := ShortString(InputBox('Добавление вакансии', 'Название фирмы:', ''));
    if V.FirmName = '' then Exit;
    V.Specialty    := ShortString(InputBox('Добавление вакансии', 'Специальность:', ''));
    V.Position     := ShortString(InputBox('Добавление вакансии', 'Должность:', ''));
    V.Salary       := StrToIntDef(InputBox('Добавление вакансии', 'Оклад:', '0'), 0);
    V.VacationDays := StrToIntDef(InputBox('Добавление вакансии', 'Дней отпуска:', '0'), 0);
    Res            := InputBox('Добавление вакансии', 'Требуется ВО? (да/нет):', 'нет');
    V.NeedHigherEd := LowerCase(Trim(Res)) = 'да';
    V.AgeMin       := StrToIntDef(InputBox('Добавление вакансии', 'Мин. возраст:', '18'), 18);
    V.AgeMax       := StrToIntDef(InputBox('Добавление вакансии', 'Макс. возраст:', '65'), 65);
    if V.AgeMin > V.AgeMax then
    begin
      ShowMessage('Ошибка: мин. возраст больше макс.');
      Exit;
    end;
    VacAdd(V);
    ShowVacanciesGrid;
    RefreshFirmList;
  end
  else if Choice = 1 then
  begin
    C.FIO := ShortString(InputBox('Добавление кандидата', 'ФИО:', ''));
    if C.FIO = '' then Exit;
    C.BirthDate := StrToDateDef(
      InputBox('Добавление кандидата', 'Дата рождения (ДД.ММ.ГГГГ):', '01.01.1990'), Now);
    C.Specialty := ShortString(InputBox('Добавление кандидата', 'Специальность:', ''));
    Res := InputBox('Добавление кандидата', 'Наличие ВО? (да/нет):', 'нет');
    C.HasHigherEd := LowerCase(Trim(Res)) = 'да';
    C.DesiredPosition := ShortString(InputBox('Добавление кандидата', 'Желаемая должность:', ''));
    C.MinSalary := StrToIntDef(InputBox('Добавление кандидата', 'Мин. оклад:', '0'), 0);
    CandAdd(C);
    ShowCandidatesGrid;
  end;
end;

procedure TForm3.MenuDeleteData(Sender: TObject);
var
  Choice, Row: Integer;
begin
  Choice := SelectFromList('Удаление данных',
                           'Из какого списка удалить запись?',
                           ['Вакансии', 'Кандидаты']);

  if Choice = -1 then Exit;

  Row := StringGrid1.Row;
  if Row < 1 then
  begin
    ShowMessage('Выделите строку для удаления.');
    Exit;
  end;

  if Choice = 0 then
  begin
    if StringGrid1.Cells[1, 0] <> 'Фирма' then
    begin
      ShowMessage('Сначала переключитесь на список Вакансий.');
      Exit;
    end;
    if Row - 1 < VacCount then
    begin
      VacDelete(Row - 1);
      ShowVacanciesGrid;
      RefreshFirmList;
    end;
  end
  else if Choice = 1 then
  begin
    if StringGrid1.Cells[1, 0] <> 'ФИО' then
    begin
      ShowMessage('Сначала переключитесь на список Кандидатов.');
      Exit;
    end;
    if Row - 1 < CandCount then
    begin
      CandDelete(Row - 1);
      ShowCandidatesGrid;
    end;
  end;
end;

procedure TForm3.MenuEditData(Sender: TObject);
var
  Choice, Row: Integer;
  Res: string;
  VNode: PVacancyNode;
  CNode: PCandidateNode;
begin
  Choice := SelectFromList('Редактирование данных',
                           'В каком списке редактировать запись?',
                           ['Вакансии', 'Кандидаты']);

  if Choice = -1 then Exit;

  Row := StringGrid1.Row;
  if Row < 1 then
  begin
    ShowMessage('Выделите строку для редактирования.');
    Exit;
  end;

  if Choice = 0 then
  begin
    if StringGrid1.Cells[1, 0] <> 'Фирма' then
    begin
      ShowMessage('Сначала переключитесь на список Вакансий.');
      Exit;
    end;

    VNode := VacGet(Row - 1);
    if VNode = nil then Exit;
    VNode^.Data.FirmName := ShortString(InputBox('Редактирование вакансии', 'Название фирмы:',
                                      string(VNode^.Data.FirmName)));
    if VNode^.Data.FirmName = '' then Exit;
    VNode^.Data.Specialty := ShortString(InputBox('Редактирование вакансии', 'Специальность:',
                                      string(VNode^.Data.Specialty)));
    VNode^.Data.Position := ShortString(InputBox('Редактирование вакансии', 'Должность:',
                                     string(VNode^.Data.Position)));
    VNode^.Data.Salary := StrToIntDef(InputBox('Редактирование вакансии', 'Оклад:',
                                     IntToStr(VNode^.Data.Salary)), VNode^.Data.Salary);
    VNode^.Data.VacationDays := StrToIntDef(InputBox('Редактирование вакансии', 'Дней отпуска:',
                                     IntToStr(VNode^.Data.VacationDays)), VNode^.Data.VacationDays);
    Res := InputBox('Редактирование вакансии', 'Требуется ВО? (да/нет):',
                    BoolToDaNetLower(VNode^.Data.NeedHigherEd));
    VNode^.Data.NeedHigherEd := LowerCase(Trim(Res)) = 'да';
    VNode^.Data.AgeMin := StrToIntDef(InputBox('Редактирование вакансии', 'Мин. возраст:',
                                     IntToStr(VNode^.Data.AgeMin)), VNode^.Data.AgeMin);
    VNode^.Data.AgeMax := StrToIntDef(InputBox('Редактирование вакансии', 'Макс. возраст:',
                                     IntToStr(VNode^.Data.AgeMax)), VNode^.Data.AgeMax);
    ShowVacanciesGrid;
    RefreshFirmList;
  end
  else if Choice = 1 then
  begin
    if StringGrid1.Cells[1, 0] <> 'ФИО' then
    begin
      ShowMessage('Сначала переключитесь на список Кандидатов.');
      Exit;
    end;

    CNode := CandGet(Row - 1);
    if CNode = nil then Exit;
    CNode^.Data.FIO := ShortString(InputBox('Редактирование кандидата', 'ФИО:',
                                 string(CNode^.Data.FIO)));
    if CNode^.Data.FIO = '' then Exit;
    CNode^.Data.BirthDate := StrToDateDef(
      InputBox('Редактирование кандидата', 'Дата рождения (ДД.ММ.ГГГГ):',
               DateToStr(CNode^.Data.BirthDate)), CNode^.Data.BirthDate);
    CNode^.Data.Specialty := ShortString(InputBox('Редактирование кандидата', 'Специальность:',
                                      string(CNode^.Data.Specialty)));
    Res := InputBox('Редактирование кандидата', 'Наличие ВО? (да/нет):',
                    BoolToDaNetLower(CNode^.Data.HasHigherEd));
    CNode^.Data.HasHigherEd := LowerCase(Trim(Res)) = 'да';
    CNode^.Data.DesiredPosition := ShortString(InputBox('Редактирование кандидата', 'Желаемая должность:',
                                            string(CNode^.Data.DesiredPosition)));
    CNode^.Data.MinSalary := StrToIntDef(InputBox('Редактирование кандидата', 'Мин. оклад:',
                                     IntToStr(CNode^.Data.MinSalary)), CNode^.Data.MinSalary);
    ShowCandidatesGrid;
  end;
end;

procedure TForm3.MenuSpecialFuncs(Sender: TObject);
var
  Choice: Integer;
begin
  Choice := SelectFromList('Специальные функции',
                           'Выберите специальную функцию:',
                           ['Подбор кандидатов (все фирмы)',
                            'Подбор для выбранной фирмы',
                            'Дефицитные специалисты']);

  if Choice = 0 then
    BtnMatchClick(Sender)
  else if Choice = 1 then
    BtnMatchFirmClick(Sender)
  else if Choice = 2 then
    BtnDeficitClick(Sender);
end;

procedure TForm3.MenuExitNoSave(Sender: TObject);
begin
  if MessageDlg('Выйти без сохранения? Все несохранённые данные будут потеряны.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    VacClear;
    CandClear;
    Application.Terminate;
  end;
end;

procedure TForm3.MenuExitWithSave(Sender: TObject);
begin
  SaveDataToFiles;
  VacClear;
  CandClear;
  Application.Terminate;
end;

{ ============================================================
  НАВИГАЦИЯ КЛАВИАТУРОЙ
  ============================================================ }
procedure TForm3.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    ShowMainMenu;
    Key := 0;
  end;
end;

end.