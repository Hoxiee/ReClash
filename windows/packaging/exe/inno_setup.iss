[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
ArchitecturesAllowed={{ARCH}}
ArchitecturesInstallIn64BitMode={{ARCH}}

[Code]
const
  ServiceMissing = 1060;
  ServiceNotActive = 1062;
  ServiceMarkedForDelete = 1072;
  QueryAndSynchronize = $00101000;
  WaitCompleted = 0;

function EnumWindows(Callback: LongWord; Param: LongWord): Boolean;
  external 'EnumWindows@user32.dll stdcall';
function GetWindowThreadProcessId(Window: HWND; var Pid: LongWord): LongWord;
  external 'GetWindowThreadProcessId@user32.dll stdcall';
function OpenProcess(Access: LongWord; Inherit: Boolean; Pid: LongWord): THandle;
  external 'OpenProcess@kernel32.dll stdcall';
function QueryFullProcessImageName(Process: THandle; Flags: LongWord; Path: String; var Size: LongWord): Boolean;
  external 'QueryFullProcessImageNameW@kernel32.dll stdcall';
function WaitForSingleObject(Handle: THandle; Timeout: LongWord): LongWord;
  external 'WaitForSingleObject@kernel32.dll stdcall';
function CloseHandle(Handle: THandle): Boolean;
  external 'CloseHandle@kernel32.dll stdcall';
function RegisterWindowMessage(Name: String): LongWord;
  external 'RegisterWindowMessageW@user32.dll stdcall';
function PostMessage(Window: HWND; Message: LongWord; WParam: LongWord; LParam: LongWord): Boolean;
  external 'PostMessageW@user32.dll stdcall';

var
  ShutdownMessage: LongWord;
  ShutdownHandles: TArrayOfInteger;
  ShutdownFailed: Boolean;

function ShutdownInstalledWindow(Window: HWND; Param: LongWord): Boolean;
var
  Pid: LongWord;
  Process: THandle;
  Size: LongWord;
  Path: String;
  Count: Integer;
begin
  Result := True;
  GetWindowThreadProcessId(Window, Pid);
  Process := OpenProcess(QueryAndSynchronize, False, Pid);
  if Process = 0 then Exit;
  Size := 32768;
  SetLength(Path, Size);
  if QueryFullProcessImageName(Process, 0, Path, Size) then
  begin
    SetLength(Path, Size);
    if CompareText(Path, ExpandConstant('{app}\{{EXECUTABLE_NAME}}')) = 0 then
    begin
      Count := GetArrayLength(ShutdownHandles);
      SetArrayLength(ShutdownHandles, Count + 1);
      ShutdownHandles[Count] := Process;
      if not PostMessage(Window, ShutdownMessage, 0, 0) then ShutdownFailed := True;
      Exit;
    end;
  end;
  CloseHandle(Process);
end;

function ShutdownInstalledApp(): Boolean;
var
  i: Integer;
begin
  SetArrayLength(ShutdownHandles, 0);
  ShutdownFailed := False;
  ShutdownMessage := RegisterWindowMessage('ReClash.InstalledProductMaintenance');
  if ShutdownMessage = 0 then
  begin
    Result := False;
    Exit;
  end;
  Result := EnumWindows(CreateCallback(@ShutdownInstalledWindow), 0);
  Result := Result and not ShutdownFailed;
  for i := 0 to GetArrayLength(ShutdownHandles) - 1 do
  begin
    if WaitForSingleObject(ShutdownHandles[i], 20000) <> WaitCompleted then Result := False;
    CloseHandle(ShutdownHandles[i]);
  end;
  SetArrayLength(ShutdownHandles, 0);
end;

function RunServiceCommand(Command: String; var ResultCode: Integer): Boolean;
begin
  Result := Exec(ExpandConstant('{sys}\sc.exe'), Command + ' "ReClashHelperService"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

function UnregisterHelperService(): Boolean;
var
  Value: String;
  Expected: String;
  ResultCode: Integer;
  Attempt: Integer;
begin
  Result := True;
  if not RegKeyExists(HKLM, 'SYSTEM\CurrentControlSet\Services\ReClashHelperService') then Exit;
  if not RegQueryStringValue(HKLM, 'SYSTEM\CurrentControlSet\Services\ReClashHelperService', 'ImagePath', Value) then
  begin
    Result := False;
    Exit;
  end;
  Value := Trim(Value);
  if (Length(Value) > 0) and (Value[1] = '"') then
  begin
    Delete(Value, 1, 1);
    Attempt := Pos('"', Value);
    if Attempt = 0 then
    begin
      Result := False;
      Exit;
    end;
    Value := Copy(Value, 1, Attempt - 1);
  end
  else
  begin
    Attempt := Pos(' --', Value);
    if Attempt > 0 then Value := Copy(Value, 1, Attempt - 1);
  end;
  Expected := ExpandConstant('{app}\ReClashHelperService.exe');
  if CompareText(Value, Expected) <> 0 then
  begin
    Result := False;
    Exit;
  end;
  if not RunServiceCommand('stop', ResultCode) then
  begin
    Result := False;
    Exit;
  end;
  if (ResultCode <> 0) and (ResultCode <> ServiceMissing) and (ResultCode <> ServiceNotActive) and (ResultCode <> ServiceMarkedForDelete) then
  begin
    Result := False;
    Exit;
  end;
  if not RunServiceCommand('delete', ResultCode) then
  begin
    Result := False;
    Exit;
  end;
  if (ResultCode <> 0) and (ResultCode <> ServiceMissing) and (ResultCode <> ServiceMarkedForDelete) then
  begin
    Result := False;
    Exit;
  end;
  for Attempt := 1 to 200 do
  begin
    if not RunServiceCommand('query', ResultCode) then
    begin
      Result := False;
      Exit;
    end;
    if ResultCode = ServiceMissing then Exit;
    if (ResultCode <> 0) and (ResultCode <> ServiceMarkedForDelete) then
    begin
      Result := False;
      Exit;
    end;
    Sleep(100);
  end;
  Result := False;
end;

procedure ClearStaleProxy;
var
  AppPath: String;
  ResultCode: Integer;
begin
  AppPath := ExpandConstant('{app}\\{{EXECUTABLE_NAME}}');
  if FileExists(AppPath) then
  begin
    Exec(AppPath, '--clear-stale-proxy', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function PointsIntoApp(Value: String): Boolean;
begin
  Result := Pos(Lowercase(AddBackslash(ExpandConstant('{app}'))), Lowercase(Value)) > 0;
end;

// Remove registrations only while their commands still point into this install.
procedure RemoveUserRegistrations;
var
  Schemes: TArrayOfString;
  Value: String;
  i: Integer;
begin
  if RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', '{{APP_NAME}}', Value) and PointsIntoApp(Value) then
  begin
    RegDeleteValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', '{{APP_NAME}}');
    RegDeleteValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run', '{{APP_NAME}}');
  end;

  Schemes := ['clash', 'clashmeta', 'reclash', 'incy', 'happ', 'hysteria', 'hysteria2', 'hy2', 'hysteria2+realm', 'hy2+realm', 'tuic', 'trojan', 'vless', 'vmess', 'ss', 'ssr', 'socks', 'socks5', 'socks5h', 'anytls', 'mierus'];
  for i := 0 to GetArrayLength(Schemes)-1 do
  begin
    if RegQueryStringValue(HKCU, 'Software\Classes\' + Schemes[i] + '\shell\open\command', '', Value) and PointsIntoApp(Value) then
    begin
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Classes\' + Schemes[i]);
    end;
    if RegQueryStringValue(HKCU, 'Software\Classes\ReClash.Url.' + Schemes[i] + '\shell\open\command', '', Value) and PointsIntoApp(Value) then
    begin
      RegDeleteValue(HKCU, 'Software\Classes\' + Schemes[i] + '\OpenWithProgids', 'ReClash.Url.' + Schemes[i]);
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Classes\ReClash.Url.' + Schemes[i]);
      RegDeleteValue(HKCU, 'Software\ReClash\UrlHandler\URLAssociations', Schemes[i]);
    end;
  end;
  if not RegKeyExists(HKCU, 'Software\Classes\ReClash.Url.reclash') then
  begin
    RegDeleteValue(HKCU, 'Software\RegisteredApplications', 'ReClash');
    RegDeleteKeyIncludingSubkeys(HKCU, 'Software\ReClash\UrlHandler');
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  if not ShutdownInstalledApp() then
  begin
    Result := 'Close ReClash in this installation before continuing.';
    Exit;
  end;
  if not UnregisterHelperService() then
    Result := 'The installed ReClash service could not be safely removed.';
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    ClearStaleProxy;
  end;
end;

function InitializeUninstall(): Boolean;
begin
  Result := ShutdownInstalledApp();
  if not Result then Exit;
  Result := UnregisterHelperService();
  if Result then ClearStaleProxy;
end;

// path_provider names these folders after CompanyName and ProductName in
// windows/runner/Runner.rc.
procedure RemoveUserData;
begin
  DelTree(ExpandConstant('{userappdata}\com.follow\clash'), True, True, True);
  DelTree(ExpandConstant('{localappdata}\com.follow\clash'), True, True, True);
  RemoveDir(ExpandConstant('{userappdata}\com.follow'));
  RemoveDir(ExpandConstant('{localappdata}\com.follow'));
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    RemoveUserRegistrations;
    if not UninstallSilent and (MsgBox(CustomMessage('RemoveUserData'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES) then
    begin
      RemoveUserData;
    end;
  end;
end;

[Languages]
{% for locale in LOCALES %}
{% if locale.lang == 'en' %}Name: "english"; MessagesFile: "compiler:Default.isl"{% endif %}
{% if locale.lang == 'hy' %}Name: "armenian"; MessagesFile: "compiler:Languages\\Armenian.isl"{% endif %}
{% if locale.lang == 'bg' %}Name: "bulgarian"; MessagesFile: "compiler:Languages\\Bulgarian.isl"{% endif %}
{% if locale.lang == 'ca' %}Name: "catalan"; MessagesFile: "compiler:Languages\\Catalan.isl"{% endif %}
{% if locale.lang == 'zh' %}
Name: "chineseSimplified"; MessagesFile: {% if locale.file %}{{ locale.file }}{% else %}"compiler:Languages\\ChineseSimplified.isl"{% endif %}
{% endif %}
{% if locale.lang == 'co' %}Name: "corsican"; MessagesFile: "compiler:Languages\\Corsican.isl"{% endif %}
{% if locale.lang == 'cs' %}Name: "czech"; MessagesFile: "compiler:Languages\\Czech.isl"{% endif %}
{% if locale.lang == 'da' %}Name: "danish"; MessagesFile: "compiler:Languages\\Danish.isl"{% endif %}
{% if locale.lang == 'nl' %}Name: "dutch"; MessagesFile: "compiler:Languages\\Dutch.isl"{% endif %}
{% if locale.lang == 'fi' %}Name: "finnish"; MessagesFile: "compiler:Languages\\Finnish.isl"{% endif %}
{% if locale.lang == 'fr' %}Name: "french"; MessagesFile: "compiler:Languages\\French.isl"{% endif %}
{% if locale.lang == 'de' %}Name: "german"; MessagesFile: "compiler:Languages\\German.isl"{% endif %}
{% if locale.lang == 'he' %}Name: "hebrew"; MessagesFile: "compiler:Languages\\Hebrew.isl"{% endif %}
{% if locale.lang == 'is' %}Name: "icelandic"; MessagesFile: "compiler:Languages\\Icelandic.isl"{% endif %}
{% if locale.lang == 'it' %}Name: "italian"; MessagesFile: "compiler:Languages\\Italian.isl"{% endif %}
{% if locale.lang == 'ja' %}Name: "japanese"; MessagesFile: "compiler:Languages\\Japanese.isl"{% endif %}
{% if locale.lang == 'no' %}Name: "norwegian"; MessagesFile: "compiler:Languages\\Norwegian.isl"{% endif %}
{% if locale.lang == 'pl' %}Name: "polish"; MessagesFile: "compiler:Languages\\Polish.isl"{% endif %}
{% if locale.lang == 'pt' %}Name: "portuguese"; MessagesFile: "compiler:Languages\\Portuguese.isl"{% endif %}
{% if locale.lang == 'ru' %}Name: "russian"; MessagesFile: "compiler:Languages\\Russian.isl"{% endif %}
{% if locale.lang == 'sk' %}Name: "slovak"; MessagesFile: "compiler:Languages\\Slovak.isl"{% endif %}
{% if locale.lang == 'sl' %}Name: "slovenian"; MessagesFile: "compiler:Languages\\Slovenian.isl"{% endif %}
{% if locale.lang == 'es' %}Name: "spanish"; MessagesFile: "compiler:Languages\\Spanish.isl"{% endif %}
{% if locale.lang == 'tr' %}Name: "turkish"; MessagesFile: "compiler:Languages\\Turkish.isl"{% endif %}
{% if locale.lang == 'uk' %}Name: "ukrainian"; MessagesFile: "compiler:Languages\\Ukrainian.isl"{% endif %}
{% endfor %}

[CustomMessages]
english.RemoveUserData=Also delete your profiles and settings?

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[InstallDelete]
Type: files; Name: "{app}\ReClashHelperService.exe"

[UninstallDelete]
Type: files; Name: "{app}\ReClashHelperService.exe"

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
[Run]
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: runasoriginaluser nowait postinstall skipifsilent
