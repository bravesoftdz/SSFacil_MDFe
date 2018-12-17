unit UMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, ComCtrls, jpeg, Menus,
  ToolWin, Types, UCBase, UCDBXConn, ActnList, ImgList, ShellAPI, ExtCtrls, RLConsts, IniFiles, Midaslib, DBClient, SqlExpr,
  frxpngimage,  FixBDE4GbBug;

type
  TfMenu = class(TForm)
    MainMenu1: TMainMenu;
    Cadastro1: TMenuItem;
    UCDBXConn1: TUCDBXConn;
    UCSettings1: TUCSettings;
    Administrao1: TMenuItem;
    CadastrodeUsurios1: TMenuItem;
    PerfildeUsurios1: TMenuItem;
    LogdoSistema1: TMenuItem;
    N1: TMenuItem;
    rocarSenha1: TMenuItem;
    EfetuarLogoff1: TMenuItem;
    ActionList1: TActionList;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    alCliente: TAction;
    alNotaFiscal: TAction;
    alProduto: TAction;
    alMovimentos: TAction;
    alSaida: TAction;
    tbPessoa: TToolButton;
    alTransportador: TAction;
    alFornecedor: TAction;
    Image2: TImage;
    alCompras: TAction;
    alPedido: TAction;
    tbManifesto: TToolButton;
    N19: TMenuItem;
    N9: TMenuItem;
    lbDatabase: TLabel;
    Label3: TLabel;
    ToolButton1: TToolButton;
    UCControls1: TUCControls;
    ToolButton2: TToolButton;
    UserControl1: TUserControl;
    ToolButton3: TToolButton;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EfetuarLogoff1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ToolButton5Click(Sender: TObject);
    procedure UserControl1AfterLogin(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure tbPessoaClick(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure tbManifestoClick(Sender: TObject);
  private
    { Private declarations }
    procedure prc_Habilita_Menu;

    //ffrmCadPais: TfrmCadPais;
  public
    { Public declarations }
    vTipoPessoa: String;
    vPath: String;
    vTipo_Reg_Cons_Fat: String;
    vTipo_Reg_Pedido: String; //P=Pedido  C=Compras
    vVersao: String;

    procedure OpenForm(FClass: TFormClass; vEstado: TWindowState; TipoPessoa: String = '');
    procedure GetBuildInfo(exeName: String; var V1, V2, V3, V4: word);
    function GetBuildInfoAsString: string;
  end;

var
  fMenu: TfMenu;

implementation

uses DmdDatabase, uUtilPadrao, UCadProprietario, UCadVeiculo, UCadCondutor,
  UCadSeguradora, UCadMDFe;

{$R *.dfm}

procedure TfMenu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := Cafree;
end;

procedure TfMenu.OpenForm(FClass: TFormClass; vEstado: TWindowState; TipoPessoa: String = '');
var
  existe: TForm;
  j: Byte;
begin
  existe := nil;
  for j := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[j] is FClass then
      existe := Screen.Forms[j];
  end;

  if not (existe = nil) then
  begin
    existe.BringToFront;
    existe.SetFocus;
  end
  else
  begin
    Application.CreateForm(FClass,existe);
    existe.FormStyle := fsMDIChild;
    if existe.Name = 'frmCadPessoa' then
      vTipoPessoa := TipoPessoa;
    existe.Show;
  end;
  existe.WindowState := vEstado;
end;

procedure TfMenu.EfetuarLogoff1Click(Sender: TObject);
begin
  UserControl1.Logoff;
end;

procedure TfMenu.FormCreate(Sender: TObject);
var
  TaskBarH: THandle;
  TaskBarR: TRect;
  //vDia, vMes, vAno: Word;
//  i: Integer;
begin
  UserControl1.Execute;
  vPath := ExtractFilePath(Application.ExeName);
  lbDatabase.Caption := dmDatabase.scoDados.Params.Values['DATABASE'];

   // obtem o retangulo com o taskbar
  TaskBarH := FindWindow('Shell_TrayWnd', nil);
  GetWindowRect(TaskBarH, TaskBarR);
  // altura do taskbar = TaskBarR.
  Image2.Top  := Height - (Screen.Height - TaskBarR.Top) - Image2.Height - 32;
  Image2.Left := Screen.Width - Image2.Width - 16;

  vVersao := GetBuildInfoAsString;
  if vVersao <> '0.0.0.0' then
  begin
    Caption := Caption + ' - v' + vVersao;
  end;           
end;

procedure TfMenu.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if MessageDlg('Encerrar o programa SSF�cil?',mtConfirmation,[mbYes,mbNo],0) = mrNo then
    CanClose := False
  else
    CanClose := True;
end;

procedure TfMenu.ToolButton5Click(Sender: TObject);
begin
  Close;
end;

procedure TfMenu.GetBuildInfo(exeName: String; var V1, V2, V3, V4: word);
var
  VerInfoSize, VerValueSize, Dummy: DWORD;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(exeName), Dummy);
  if VerInfoSize > 0 then
  begin
    GetMem(VerInfo,VerInfoSize);
    try
      if GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo) then
      begin
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        with VerValue^ do
        begin
          V1 := dwFileVersionMS shr 16;
          V2 := dwFileVersionMS and $FFFF;
          V3 := dwFileVersionLS shr 16;
          V4 := dwFileVersionLS and $FFFF;
        end;
      end;
    finally
      FreeMem(VerInfo,VerInfoSize);
    end;
  end;
end;

function TfMenu.GetBuildInfoAsString: string;
var
  V1, V2, V3, V4: word;
begin
  GetBuildInfo(GetCurrentDir + '\SSFacil.EXE', V1, V2, V3, V4);
  Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' +
    IntToStr(V3) + '.' + IntToStr(V4);
end;

procedure TfMenu.UserControl1AfterLogin(Sender: TObject);
begin
  prc_Habilita_Menu;
end;

procedure TfMenu.FormShow(Sender: TObject);
begin
  prc_Habilita_Menu;

  lbDatabase.Top  := Image2.Top - 15;
  lbDatabase.Left := Image2.Left - 269;
end;

procedure TfMenu.prc_Habilita_Menu;
begin
  vUsuario := UserControl1.CurrentUser.LoginName;
end;

procedure TfMenu.ToolButton2Click(Sender: TObject);
begin
  OpenForm(TfrmCadProprietario,wsMaximized,'');
end;

procedure TfMenu.ToolButton1Click(Sender: TObject);
begin
  OpenForm(TfrmCadVeiculo,wsMaximized,'');
end;

procedure TfMenu.tbPessoaClick(Sender: TObject);
begin
  OpenForm(TfrmCadCondutor,wsMaximized,'');
end;

procedure TfMenu.ToolButton3Click(Sender: TObject);
begin
  OpenForm(TfrmCadSeguradora,wsMaximized,'');
end;

procedure TfMenu.tbManifestoClick(Sender: TObject);
begin
  OpenForm(TfrmCadMDFe,wsMaximized,'');
end;

initialization
  RLConsts.SetVersion(3,72,'B');

end.
