#define MyAppName "CmdStartup"
#define MyAppVersion "1.0"
#define MyAppPublisher "RadSoft"
#define CmdStartupFile "%USERPROFILE%\" + MyAppName + ".bat"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{065DFD77-F549-42FD-8B16-BDCE3C367A70}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DisableWelcomePage=no
DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
DisableDirPage=yes
DefaultGroupName={#MyAppPublisher}
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename={#MyAppName}Setup
AppModifyPath="{app}\{#MyAppName}Setup.exe" /modify=1
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64 arm64 ia64
SetupIconFile={#MyAppName}.ico
UninstallDisplayIcon={app}\{#MyAppName}Setup.exe

[Code]
#ifdef UNICODE
#define AW "W"
#define AWSizeOffset 1
#else
#define AW "A"
#define AWSizeOffset 2
#endif

function ExpandEnvironmentStrings(lpSrc: String; lpDst: String; nSize: DWORD): DWORD;
external 'ExpandEnvironmentStrings{#AW}@kernel32.dll stdcall';

function ExpandEnvVars(const Input: String): String;
var
  Buf: String;
  BufSize: DWORD;
begin
  BufSize := ExpandEnvironmentStrings(Input, #0, 0);
  if BufSize > 0 then
  begin
    SetLength(Buf, BufSize);  // The internal representation is probably +1 (0-termination)
    if ExpandEnvironmentStrings(Input, Buf, BufSize) = 0 then
      RaiseException(Format('Expanding env. strings failed. %s', [SysErrorMessage(DLLGetLastError)]));
    Result := Copy(Buf, 1, BufSize - {#AWSizeOffset});
  end
  else
    RaiseException(Format('Expanding env. strings failed. %s', [SysErrorMessage(DLLGetLastError)]));
end;

var
  Page: TInputQueryWizardPage;
  CmdStartupFile: String;

function GetCmdStartupFile(Param: string): String;
begin
  Result := CmdStartupFile;
end;

function GetCmdStartupFileDir(Param: string): String;
begin
  Result := ExpandEnvVars(ExtractFileDir(CmdStartupFile));
end;

function GetCmdStartupFileName(Param: string): String;
begin
  Result := ExpandEnvVars(ExtractFileName(CmdStartupFile));
end;

procedure InitializeWizard;
begin
  Page := CreateInputQueryPage(wpWelcome,
    'Select {#MyAppName} Location', 'Where is the {#MyAppName} script located?',
    'Select where the {#MyAppName} script is located, then click Next.');

  Page.Add('&Location of the {#MyAppName} script:', False);

  Page.Values[0] := ExpandConstant('{#CmdStartupFile}');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = Page.ID then
    CmdStartupFile := Page.Values[0];
  Result := True;
end;

procedure AddToReadyMemo(var Memo: string; Info, NewLine: string);
begin
  if Info <> '' then
    Memo := Memo + Info + Newline + NewLine;
end;

function UpdateReadyMemo(
  Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo,
  MemoGroupInfo, MemoTasksInfo: String): String;
begin
  if IsAdminInstallMode() then
    Result := Result + 'Install for all users' + Newline + NewLine
  else
    Result := Result + 'Install for current user only' + Newline + NewLine;

  Result := Result + '{#MyAppName} script:' + Newline;
  Result := Result + Space + CmdStartupFile + Newline + NewLine;

  AddToReadyMemo(Result, MemoUserInfoInfo, NewLine);
  AddToReadyMemo(Result, MemoDirInfo, NewLine);
  AddToReadyMemo(Result, MemoTypeInfo, NewLine);
  AddToReadyMemo(Result, MemoComponentsInfo, NewLine);
  AddToReadyMemo(Result, MemoGroupInfo, NewLine);
  AddToReadyMemo(Result, MemoTasksInfo, NewLine);
end;

[CustomMessages]
NameAndVersion=%1 v%2

[Files]
Source: "{srcexe}"; DestDir: "{app}"; Flags: external
Source: "CmdStartup.bat"; DestDir: "{code:GetCmdStartupFileDir}"; DestName: "{code:GetCmdStartupFileName}"; Flags: onlyifdoesntexist uninsneveruninstall

[Registry]
Root: HKA; Subkey: "Software\Microsoft\Command Processor"; ValueType: string; ValueName: "Autorun"; ValueData: "if exist ""{code:GetCmdStartupFile}"" call ""{code:GetCmdStartupFile}"""; Flags: uninsdeletevalue

[Icons]
Name: "{group}\Edit {#MyAppName}"; Filename: "Notepad.exe"; Parameters: """{code:GetCmdStartupFile}""";

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

