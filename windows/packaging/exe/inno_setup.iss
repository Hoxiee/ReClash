[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
VersionInfoVersion={#GetVersionNumbersString("{{SOURCE_DIR}}\\{{EXECUTABLE_NAME}}")}
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
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
ArchitecturesAllowed={{ARCH}}
ArchitecturesInstallIn64BitMode={{ARCH}}

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
    'ReClashHelperService.exe',
    'FlClashHelperService.exe'
  ];

  for i := 0 to GetArrayLength(Processes)-1 do
  begin
    Exec('taskkill', '/f /im ' + Processes[i], '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function RunServiceCommand(Command: String; ServiceName: String; var ResultCode: Integer): Boolean;
begin
  Result := Exec(
    ExpandConstant('{sys}\\sc.exe'),
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

function UnregisterHelperService(): Boolean;
begin
  Result := RemoveHelperService('ReClashHelperService');
  if not RemoveHelperService('FlClashHelperService') then
  begin
    Result := False;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if not UnregisterHelperService then
  begin
    Result := 'Could not remove the legacy ReClash Helper service.';
    Exit;
  end;
  KillProcesses;
  Result := '';
end;

function InitializeUninstall(): Boolean;
begin
  Result := UnregisterHelperService;
  if Result then
  begin
    KillProcesses;
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

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[InstallDelete]
Type: files; Name: "{app}\\ReClashHelperService.exe"
Type: files; Name: "{app}\\FlClashHelperService.exe"

[UninstallDelete]
Type: files; Name: "{app}\\ReClashHelperService.exe"
Type: files; Name: "{app}\\FlClashHelperService.exe"

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
[Run]
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: {% if PRIVILEGES_REQUIRED == 'admin' %}runascurrentuser{% endif %} nowait postinstall skipifsilent
