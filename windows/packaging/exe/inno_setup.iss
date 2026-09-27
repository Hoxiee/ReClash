[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
VersionInfoVersion={#GetVersionNumbersString("{{SOURCE_DIR}}\{{EXECUTABLE_NAME}}")}
VersionInfoProductTextVersion={{APP_VERSION}}
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
SetupMutex=ReClashSetupMutex
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
UninstallDisplayName={{DISPLAY_NAME}}
UninstallDisplayIcon={app}\{{EXECUTABLE_NAME}}
; x64 setup stays x64compatible so it also installs under ARM64 emulation;
; the native ARM64 build declares arm64 so it never lands on an x64-only host.
ArchitecturesAllowed={% if ARCH == 'arm64' %}arm64{% else %}x64compatible{% endif %}
ArchitecturesInstallIn64BitMode={% if ARCH == 'arm64' %}arm64{% else %}x64compatible{% endif %}

[Code]
const
  ServiceMissing = 1060;
  ServiceNotActive = 1062;
  ServiceMarkedForDelete = 1072;

procedure KillProcesses;
var
  Processes: TArrayOfString;
  i: Integer;
  ResultCode: Integer;
begin
  Processes := [
    'ReClash.exe',
    'ReClashCore.exe',
    'ReClashHelperService.exe'
  ];

  for i := 0 to GetArrayLength(Processes)-1 do
  begin
    Exec('taskkill', '/f /im ' + Processes[i], '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function RunServiceCommand(Command: String; ServiceName: String; var ResultCode: Integer): Boolean;
begin
  Result := Exec(
    ExpandConstant('{sys}\sc.exe'),
    Command + ' "' + ServiceName + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );
end;

function WaitForServiceRemoval(ServiceName: String): Boolean;
var
  Attempts: Integer;
  ResultCode: Integer;
begin
  for Attempts := 1 to 50 do
  begin
    if not RunServiceCommand('query', ServiceName, ResultCode) then
    begin
      Result := False;
      Exit;
    end;
    if ResultCode = ServiceMissing then
    begin
      Result := True;
      Exit;
    end;
    if (ResultCode <> 0) and (ResultCode <> ServiceMarkedForDelete) then
    begin
      Result := False;
      Exit;
    end;
    Sleep(100);
  end;
  Result := False;
end;

function RemoveHelperService(ServiceName: String): Boolean;
var
  ResultCode: Integer;
begin
  if not RunServiceCommand('stop', ServiceName, ResultCode) then
  begin
    Result := False;
    Exit;
  end;
  if (ResultCode = ServiceMissing) then
  begin
    Result := True;
    Exit;
  end;
  if (ResultCode <> 0) and
     (ResultCode <> ServiceNotActive) and
     (ResultCode <> ServiceMarkedForDelete) then
  begin
    Result := False;
    Exit;
  end;

  if not RunServiceCommand('delete', ServiceName, ResultCode) then
  begin
    Result := False;
    Exit;
  end;
  if ResultCode = ServiceMissing then
  begin
    Result := True;
    Exit;
  end;
  if (ResultCode <> 0) and (ResultCode <> ServiceMarkedForDelete) then
  begin
    Result := False;
    Exit;
  end;
  Result := WaitForServiceRemoval(ServiceName);
end;

procedure UnregisterHelperService;
begin
  // Shipped installers carry no helper service; this only clears a legacy one
  // left by an older ReClash build. Failure never blocks the install.
  RemoveHelperService('ReClashHelperService');
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  UnregisterHelperService;
  KillProcesses;
  Result := '';
end;

function InitializeUninstall(): Boolean;
begin
  UnregisterHelperService;
  KillProcesses;
  Result := True;
end;

[Languages]
{% for locale in LOCALES %}
{% if locale.lang == 'en' %}Name: "english"; MessagesFile: "compiler:Default.isl"{% endif %}
{% if locale.lang == 'ru' %}Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"{% endif %}
{% if locale.lang == 'zh' %}
Name: "chineseSimplified"; MessagesFile: {% if locale.file %}{{ locale.file }}{% else %}"compiler:Languages\ChineseSimplified.isl"{% endif %}
{% endif %}
{% if locale.lang == 'ko' %}
Name: "korean"; MessagesFile: {% if locale.file %}{{ locale.file }}{% else %}"compiler:Languages\Korean.isl"{% endif %}
{% endif %}
{% endfor %}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}

[Files]
Source: "{{SOURCE_DIR}}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[InstallDelete]
Type: files; Name: "{app}\ReClashHelperService.exe"

[UninstallDelete]
Type: files; Name: "{app}\ReClashHelperService.exe"

[Icons]
Name: "{autoprograms}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"; Tasks: desktopicon

[Run]
Filename: "{app}\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: {% if PRIVILEGES_REQUIRED == 'admin' %}runascurrentuser{% endif %} nowait postinstall skipifsilent
