object Form3: TForm3
  Left = 0
  Top = 0
  Caption = #1041#1048#1056#1046#1040' '#1058#1056#1059#1044#1040
  ClientHeight = 661
  ClientWidth = 950
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 17
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 950
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 948
    object LabelTitle: TLabel
      Left = 60
      Top = 15
      Width = 115
      Height = 21
      Caption = #1041#1048#1056#1046#1040' '#1058#1056#1059#1044#1040
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BtnMenu: TButton
      Left = 10
      Top = 10
      Width = 40
      Height = 30
      Caption = '==='
      TabOrder = 0
      OnClick = BtnMenuClick
    end
  end
  object PanelNav: TPanel
    Left = 0
    Top = 50
    Width = 950
    Height = 130
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 948
    object LabelSort: TLabel
      Left = 490
      Top = 60
      Width = 75
      Height = 17
      Caption = #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072':'
    end
    object LabelFirm: TLabel
      Left = 30
      Top = 95
      Width = 43
      Height = 17
      Caption = #1060#1080#1088#1084#1072':'
    end
    object BtnVacancies: TButton
      Left = 30
      Top = 15
      Width = 120
      Height = 35
      Caption = #1042#1072#1082#1072#1085#1089#1080#1080
      TabOrder = 0
      OnClick = BtnVacanciesClick
    end
    object BtnCandidates: TButton
      Left = 170
      Top = 15
      Width = 120
      Height = 35
      Caption = #1050#1072#1085#1076#1080#1076#1072#1090#1099
      TabOrder = 1
      OnClick = BtnCandidatesClick
    end
    object BtnMatch: TButton
      Left = 310
      Top = 15
      Width = 140
      Height = 35
      Caption = #1055#1086#1076#1073#1086#1088' '#1082#1072#1085#1076#1080#1076#1072#1090#1072
      TabOrder = 2
      OnClick = BtnMatchClick
    end
    object BtnDeficit: TButton
      Left = 470
      Top = 15
      Width = 120
      Height = 35
      Caption = #1044#1077#1092#1080#1094#1080#1090
      TabOrder = 3
      OnClick = BtnDeficitClick
    end
    object BtnReport: TButton
      Left = 610
      Top = 15
      Width = 120
      Height = 35
      Caption = #1054#1090#1095#1077#1090
      TabOrder = 4
      OnClick = BtnReportClick
    end
    object BtnFindVacancy: TButton
      Left = 30
      Top = 55
      Width = 140
      Height = 25
      Caption = #1055#1086#1080#1089#1082' '#1074#1072#1082#1072#1085#1089#1080#1080
      TabOrder = 5
      OnClick = BtnFindVacancyClick
    end
    object BtnFindCandidate: TButton
      Left = 180
      Top = 55
      Width = 140
      Height = 25
      Caption = #1055#1086#1080#1089#1082' '#1082#1072#1085#1076#1080#1076#1072#1090#1072
      TabOrder = 6
      OnClick = BtnFindCandidateClick
    end
    object BtnResetFilter: TButton
      Left = 330
      Top = 55
      Width = 140
      Height = 25
      Caption = #1057#1073#1088#1086#1089#1080#1090#1100' '#1092#1080#1083#1100#1090#1088
      TabOrder = 7
      OnClick = BtnResetFilterClick
    end
    object ComboSort: TComboBox
      Left = 565
      Top = 55
      Width = 220
      Height = 25
      Style = csDropDownList
      TabOrder = 8
      OnChange = ComboSortChange
      Items.Strings = (
        #212#200#206' / '#205#224#231#226#224#237#232#229' '#8593
        #212#200#206' / '#205#224#231#226#224#237#232#229' '#8595
        #209#239#229#246#232#224#235#252#237#238#241#242#252' '#8593
        #209#239#229#246#232#224#235#252#237#238#241#242#252' '#8595
        #206#234#235#224#228' '#8593
        #206#234#235#224#228' '#8595
        #194#238#231#240#224#241#242' '#8593
        #194#238#231#240#224#241#242' '#8595)
    end
    object ComboFirm: TComboBox
      Left = 100
      Top = 92
      Width = 300
      Height = 25
      Style = csDropDownList
      TabOrder = 9
      OnChange = ComboFirmChange
    end
    object BtnMatchFirm: TButton
      Left = 420
      Top = 92
      Width = 250
      Height = 25
      Caption = #1055#1086#1076#1073#1086#1088' '#1082#1072#1085#1076#1080#1076#1072#1090#1086#1074' '#1076#1083#1103' '#1092#1080#1088#1084#1099
      TabOrder = 10
      OnClick = BtnMatchFirmClick
    end
  end
  object StringGrid1: TStringGrid
    Left = 0
    Top = 180
    Width = 950
    Height = 410
    Align = alClient
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
    TabOrder = 2
    ExplicitWidth = 948
    ExplicitHeight = 402
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 590
    Width = 950
    Height = 71
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitTop = 582
    ExplicitWidth = 948
    object LabelStatus: TLabel
      Left = 30
      Top = 25
      Width = 40
      Height = 17
      Caption = #1057#1090#1072#1090#1091#1089':'
    end
    object LblVacCount: TLabel
      Left = 150
      Top = 25
      Width = 68
      Height = 17
      Caption = #1042#1072#1082#1072#1085#1089#1080#1081': 0'
    end
    object LblCandCount: TLabel
      Left = 300
      Top = 25
      Width = 84
      Height = 17
      Caption = #1050#1072#1085#1076#1080#1076#1072#1090#1086#1074': 0'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 360
    Top = 200
  end
end
