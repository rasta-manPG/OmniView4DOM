class OverlayConfig expands UWindowPageWindow;

var UMenuLabelControl Settings;
var UMenuLabelControl GeneralOptions;
var UMenuLabelControl BehaviourOptions;
var UMenuLabelControl ScoreBoard;
var UMenuLabelControl ProgressBars;
var UMenuLabelControl OverlayControl;
var UMenuLabelControl OverlayStatus;
var UMenuLabelControl HotKeyBind;
var UMenuLabelControl HotKeyMenu;
var UMenuLabelControl Line;
var UMenuLabelControl BestOf5Games; 
var UMenuLabelControl VsLabel;
var UMenuLabelControl OBSCompatibility;

// TEAMS SETTINGS
var UMenuLabelControl TeamsLabel;
var UWindowEditControl RedNameEdit;
var UWindowEditControl BlueNameEdit;
var UWindowEditControl RedMapName1Edit;
var UWindowEditControl RedMapName2Edit;
var UWindowEditControl BlueMapName1Edit;
var UWindowEditControl BlueMapName2Edit;
var UWindowEditControl DeciderMapNameEdit;


var UWindowCheckbox ItemTimer;
var UWindowCheckbox HealthArmor;
var UWindowCheckbox SpectatedPlayerInfo;
var UWindowCheckbox ScoreBoardState;
var UWindowCheckbox ProgressBarsState;
var UWindowCheckbox ShowAccuracy;
var UWindowCheckbox ShowSuicides;
var UWindowCheckbox HighContrastMode;
var UWindowCheckbox MsgLengthKF;
var UWindowCheckbox PlayerNumbers;
var UWindowCheckbox BestOf5GamesState;
var UWindowCheckbox ShoeWinStrikeDots;
var UWindowCheckbox ShowTeamsMapsPicks;
var UWindowCheckbox LiveScoreCheck;
var UWindowCheckbox MovieStyleMode;
var UWindowCheckbox PerformanceChartCheck;
var UWindowCheckbox LiveBaseTicker;

var UWindowComboControl FontSizeChat;
var UWindowComboControl FontSizeKF;
var UWindowComboControl AmpEffects;
var UWindowComboControl CameraModeCombo;
var UWindowComboControl OBSOffset;
var OV4DOMSlider UIScaleSlider;
var UMenuLabelControl UIScaleLabel;
var UWindowCheckbox UIScaleAuto;


var UMenuRaisedButton HotKeyButton;
var UWindowSmallButton OverlayButton;
var UWindowSmallCloseButton CancelButton;
var UWindowSmallButton ResetScoresButton;

var bool bMenu;

var string RealKeyName[255];
var string OldMenuKey;

var overlayhud OHUD;

function Created()
{
  local int CurY;
  //local uwindowwindow child;
  //CurY = 20;

  Super.Created();
  SetAcceptsFocus();

  Settings = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 0.0, 5.0, 240.0, 1.0));
  Settings.SetText ("Basic Settings");
  Settings.Align = TA_Center;
  Settings.SetFont (F_Bold);

  CurY = 20; 

  // --- TEAMS SETTINGS ---
  TeamsLabel = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 10.0, CurY, 225.0, 1.0));
  TeamsLabel.SetText("Teams Settings");
  TeamsLabel.SetFont(F_Bold);
  Cury = Cury + 18;

  // Red Team Name Field
  RedNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10.0, CurY, 105.0, 1.0));
  RedNameEdit.SetText("Red");
  RedNameEdit.SetFont(F_Normal);
  RedNameEdit.SetNumericOnly(false);
  RedNameEdit.SetMaxLength(20);
  RedNameEdit.EditBoxWidth = 85;
  RedNameEdit.bAcceptsFocus = True; // AdaugÄ asta
  RedNameEdit.SetValue(class'OverlaySettings'.default.RedTeamName);
  //Cury = Cury + 18;

  // Red vs Blue Label
  VsLabel = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 118.0, CurY + 3, 10.0, 1.0));
  VsLabel.SetText("vs");
  VsLabel.SetFont(F_Normal);

  // 3. BLUE TEAM 
  BlueNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 130.0, CurY, 105.0, 1.0));
  BlueNameEdit.SetText("Blue");
  BlueNameEdit.EditBoxWidth = 85;
  BlueNameEdit.SetFont(F_Normal);
  BlueNameEdit.SetMaxLength(20);
  BlueNameEdit.SetValue(class'OverlaySettings'.default.BlueTeamName);
  BlueNameEdit.Align = TA_Right; 
  CurY += 18;

  // "MAPS PICKS"
  TeamsLabel = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 10.0, CurY, 225.0, 1.0));
  TeamsLabel.SetText("Maps Picks");
  TeamsLabel.SetFont(F_Bold); // Îl facem Bold ca să iasă în evidență
  //CurY += 18;

  // --- Reset Scores Button ---
  ResetScoresButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 130.0, CurY, 100.0, 16.0));
  ResetScoresButton.SetText("RESET ALL SCORES");
  ResetScoresButton.SetFont(F_Normal);
  ResetScoresButton.SetHelpText("Resets all scores to 0. Use with caution!");
  CurY += 17; 

  // Red Map Pick 1 Name Field
  RedMapName1Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10.0, CurY, 105.0, 1.0));
  RedMapName1Edit.SetText("Red");
  RedMapName1Edit.SetFont(F_Normal);
  RedMapName1Edit.SetNumericOnly(false);
  RedMapName1Edit.SetMaxLength(20);
  RedMapName1Edit.EditBoxWidth = 85;
  RedMapName1Edit.bAcceptsFocus = True; // AdaugÄ asta
  RedMapName1Edit.SetValue(class'OverlaySettings'.default.RedMapPick1Name);

  VsLabel = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 121.0, CurY, 10.0, 1.0));
  VsLabel.SetText("-");
  VsLabel.SetFont(F_Normal);

  // Blue Map Pick 1 Name Field
  BlueMapName1Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', 130.0, CurY, 105.0, 1.0));
  BlueMapName1Edit.SetText("Blue");
  BlueMapName1Edit.EditBoxWidth = 85;
  BlueMapName1Edit.SetFont(F_Normal);
  BlueMapName1Edit.SetMaxLength(20);
  BlueMapName1Edit.SetNumericOnly(false);
  BlueMapName1Edit.bAcceptsFocus = True; // AdaugÄ asta
  BlueMapName1Edit.SetValue(class'OverlaySettings'.default.BlueMapPick1Name);
  BlueMapName1Edit.Align = TA_Right; // Aliniere la dreapta pentru a fi în linie cu numele echipei
  Cury = Cury + 18;

   // Blue Map Pick 2 Name Field
  RedMapName2Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10.0, CurY, 105.0, 1.0));
  RedMapName2Edit.EditBoxWidth = 85;
  RedMapName2Edit.SetFont(F_Normal);
  RedMapName2Edit.SetNumericOnly(false);
  RedMapName2Edit.SetMaxLength(20);
  RedMapName2Edit.bAcceptsFocus = True; // AdaugÄ asta
  RedMapName2Edit.SetValue(class'OverlaySettings'.default.RedMapPick2Name);

  VsLabel = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 121.0, CurY, 10.0, 1.0));
  VsLabel.SetText("-");
  VsLabel.SetFont(F_Normal);

   // Blue Map Pick 2 Name Field
  BlueMapName2Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', 110.0, CurY, 105.0, 1.0));
  BlueMapName2Edit.EditBoxWidth = 85;
  BlueMapName2Edit.SetFont(F_Normal);
  BlueMapName2Edit.SetNumericOnly(false);
  BlueMapName2Edit.SetMaxLength(20);
  BlueMapName2Edit.bAcceptsFocus = True; // AdaugÄ asta
  BlueMapName2Edit.SetValue(class'OverlaySettings'.default.BlueMapPick2Name);
  Cury = Cury + 18;

   // Decider Map Name Field
  DeciderMapNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 45.0, CurY, 120.0, 1.0));
  DeciderMapNameEdit.SetText("Decider");
  DeciderMapNameEdit.EditBoxWidth = 85;
  DeciderMapNameEdit.SetFont(F_Normal);
  DeciderMapNameEdit.SetNumericOnly(false);
  DeciderMapNameEdit.SetMaxLength(20);
  DeciderMapNameEdit.bAcceptsFocus = True; // AdaugÄ asta
  DeciderMapNameEdit.SetValue(class'OverlaySettings'.default.DeciderMapName);
  Cury = Cury + 18;

     // Enable best of 5 games 
  BestOf5GamesState = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 105.0, 1.0));
  BestOf5GamesState.SetText("Enable BO5 games");
  BestOf5GamesState.SetHelpText("");
  BestOf5GamesState.SetFont (F_Normal);
  BestOf5GamesState.bChecked = class'OverlaySettings'.default.bBestOf5GamesState;
  BestOf5GamesState.bDisabled = true;
  
  ShoeWinStrikeDots = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 130.0, CurY, 110.0, 1.0));
  ShoeWinStrikeDots.SetText("Show win strike dots");
  ShoeWinStrikeDots.SetHelpText("");
  ShoeWinStrikeDots.SetFont (F_Normal);
  ShoeWinStrikeDots.bChecked = class'OverlaySettings'.default.bShowWinStrikeDots;
  ShoeWinStrikeDots.bDisabled = true;
  Cury = Cury + 18;

    // Show teams maps picks over score board 
  ShowTeamsMapsPicks = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 100.0, 1.0));
  ShowTeamsMapsPicks.SetText("Show maps picks");
  ShowTeamsMapsPicks.SetHelpText("");
  ShowTeamsMapsPicks.SetFont (F_Normal);
  ShowTeamsMapsPicks.bChecked = class'OverlaySettings'.default.bShowTeamsMapsPicks;
  ShowTeamsMapsPicks.bDisabled = true;

   // Show live score for current map on score board //
  LiveScoreCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 150, CurY, 70.0, 1.0));
  LiveScoreCheck.SetText("Live Score");
  LiveScoreCheck.SetHelpText("");
  LiveScoreCheck.SetFont(F_Normal);
  LiveScoreCheck.bChecked = class'OverlaySettings'.default.bShowLiveMapScore;
  LiveScoreCheck.bDisabled = true;
  CurY += 18;

  ///////////////////////////////////////////////////////
  //Show dinamic graph teams fight /////////////
  PerformanceChartCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 130.0, 1.0));
  PerformanceChartCheck.SetText("Show performance graph");
  PerformanceChartCheck.SetHelpText("");
  PerformanceChartCheck.SetFont(F_Normal);
  PerformanceChartCheck.bChecked = class'OverlaySettings'.default.bShowPerformanceChart;
  PerformanceChartCheck.bDisabled = true;
  /////////////////////////////////////////////////////

  LiveBaseTicker = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 150.0, CurY, 80.0, 1.0));
  LiveBaseTicker.SetText("Points Score");
  LiveBaseTicker.SetHelpText("");
  LiveBaseTicker.SetFont(F_Normal);
  LiveBaseTicker.bChecked = class'OverlaySettings'.default.bLiveBaseTicker;
  LiveBaseTicker.bDisabled = true;
  CurY += 18;

  GeneralOptions = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0, CurY, 225.0, 1.0));
  GeneralOptions.SetText ("Appearance");
  GeneralOptions.SetFont (F_Bold);
  Cury = Cury + 15;

  // item timer on/off //
  ItemTimer = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 90.0, 1.0));
  ItemTimer.SetText("Show item timer");
  ItemTimer.SetHelpText("");
  ItemTimer.SetFont (F_Normal);
  ItemTimer.bChecked = class'OverlaySettings'.default.bShowItemTimer;
  ItemTimer.bDisabled = true;

  // HP and armor on/off //
  HealthArmor = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 110.0, CurY, 125.0, 1.0));
  HealthArmor.SetText("Show health and armor");
  HealthArmor.SetHelpText("");
  HealthArmor.SetFont (F_Normal);
  HealthArmor.bChecked = class'OverlaySettings'.default.bShowHealthArmor;
  HealthArmor.bDisabled = true;
  CurY += 18;

  // Show info for spectated player //
  SpectatedPlayerInfo = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 150.0, 1.0));
  SpectatedPlayerInfo.SetText("Show info for spectated player");
  SpectatedPlayerInfo.SetHelpText("");
  SpectatedPlayerInfo.SetFont (F_Normal);
  SpectatedPlayerInfo.bChecked = class'OverlaySettings'.default.bSpectatedPlayerInfo;
  SpectatedPlayerInfo.bDisabled = true;

  // Movie style mode //
  MovieStyleMode = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 170.0, CurY, 70.0, 1.0));
  MovieStyleMode.SetText("Movie Style");
  MovieStyleMode.SetHelpText("Enable movie-style UI");
  MovieStyleMode.SetFont(F_Normal);
  MovieStyleMode.bChecked = class'OverlaySettings'.default.bMovieStyleMode;
  MovieStyleMode.bDisabled = true;
  CurY += 18;

  // font size for chat //
  FontSizeChat = UWindowComboControl(CreateControl(class'UWindowComboControl', 10.0, CurY, 150.0, 50.0));
  FontSizeChat.SetText ("Font size for chat");
  FontSizeChat.SetHelpText ("");
  FontSizeChat.SetFont (F_Normal);
  FontSizeChat.AddItem ("Small");
  FontSizeChat.AddItem ("Medium");
  FontSizeChat.AddItem ("Large");
  FontSizeChat.SetSelectedIndex (class'OverlaySettings'.default.iFontSizeChat);
  FontSizeChat.EditBoxWidth = 60;
  FontSizeChat.bCanEdit = false;
  Cury = Cury + 18;

  // font size for kill feed //
  FontSizeKF = UWindowComboControl(CreateControl(class'UWindowComboControl', 10.0, CurY, 225.0, 50.0));
  FontSizeKF.SetText ("Font size for kill feed");
  FontSizeKF.SetHelpText ("");
  FontSizeKF.SetFont (F_Normal);
  FontSizeKF.AddItem ("Small");
  FontSizeKF.AddItem ("Medium");
  FontSizeKF.AddItem ("Large");
  FontSizeKF.SetSelectedIndex (class'OverlaySettings'.default.iFontSizeKF);
  FontSizeKF.EditBoxWidth = 60;
  FontSizeKF.bCanEdit = false;
  Cury = Cury + 18;

  // custom messages for kill feed //
  MsgLengthKF = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 225.0, 1.0));
  MsgLengthKF.SetText("Custom messages for kill feed");
  MsgLengthKF.SetHelpText("");
  MsgLengthKF.SetFont (F_Normal);
  MsgLengthKF.bChecked = class'OverlaySettings'.default.bMsgLengthKF;
  MsgLengthKF.bDisabled = true;
  Cury = Cury + 20;

  // UI scale auto checkbox //
  UIScaleAuto = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 90.0, 1.0));
  UIScaleAuto.SetText("Auto UI Scale");
  UIScaleAuto.SetHelpText("Automatically scale UI based on resolution");
  UIScaleAuto.SetFont(F_Normal);
  UIScaleAuto.bChecked = (class'OverlaySettings'.default.fUIScale == 0.0);
  UIScaleAuto.bDisabled = true;
  CurY = CurY + 18;

  // UI scale slider //
  UIScaleLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10.0, CurY, 190.0, 1.0));
  UIScaleLabel.SetText("UI Scale: " $ GetScaleText());
  UIScaleLabel.SetFont(F_Normal);
  CurY = CurY + 18;

  UIScaleSlider = OV4DOMSlider(CreateControl(class'OV4DOMSlider', 10.0, CurY, 200.0, 24.0));
  UIScaleSlider.SetRange(25, 200, 5);
  UIScaleSlider.SliderWidth = 185;
  UIScaleSlider.Align = TA_Right;
  if (class'OverlaySettings'.default.fUIScale == 0.0)
    UIScaleSlider.SetValue(75);
  else
    UIScaleSlider.SetValue(int(class'OverlaySettings'.default.fUIScale * 100));
  CurY = CurY + 18;

  //// options for behaviour ////
  BehaviourOptions = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0, CurY, 225.0, 1.0));
  BehaviourOptions.SetText ("Behaviour");
  BehaviourOptions.SetFont (F_Bold);
  Cury = Cury + 15;

  // hotkey //
  HotKeyMenu = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10.0, CurY + 2, 180.0, 1.0));
  HotKeyMenu.SetText("In-game menu key");
  HotKeyMenu.SetHelpText("");
  HotKeyMenu.SetFont(F_Normal);

  HotKeyButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 140.0, CurY - 2, 80.0, 1.0));
  HotKeyButton.SetHelpText("");
  HotKeyButton.Align = TA_Center;
  HotKeyButton.bDisabled = false;
  HotKeyButton.bAcceptsFocus = false;
  HotKeyButton.bIgnoreLDoubleClick = true;
  HotKeyButton.bIgnoreMDoubleClick = true;
  HotKeyButton.bIgnoreRDoubleClick = true;
  HotKeyButton.NotifyWindow = Self;

  HotKeyBind = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 180.0, CurY + 2, 50.0 + 5.0, 1.0));
  HotKeyBind.SetText("");
  HotKeyBind.SetFont(1);
  Cury = Cury + 20;

   // progress bars on/off //
  ProgressBarsState = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 225.0, 1.0));
  ProgressBarsState.SetText("Enable progress bars %");
  ProgressBarsState.SetHelpText("");
  ProgressBarsState.SetFont (F_Normal);
  ProgressBarsState.bChecked = class'OverlaySettings'.default.bProgressBarsState;
  ProgressBarsState.bDisabled = true;
  Cury = Cury + 18;

  // camera mode combo
  CameraModeCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 10.0, CurY, 225.0, 50.0)); // Ajustează coordonatele
  CameraModeCombo.SetText("Spectated player camera:");
  CameraModeCombo.SetHelpText("");
  CameraModeCombo.SetFont(F_Normal);
  CameraModeCombo.AddItem("First-person");
  CameraModeCombo.AddItem("Third-person");
  CameraModeCombo.SetSelectedIndex(class'OverlaySettings'.default.iCameraMode);
  CameraModeCombo.EditBoxWidth = 70;
  CameraModeCombo.bCanEdit = false;
  Cury = Cury + 18;

  //// options for on screen score board ////
  ScoreBoard = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0, CurY, 225.0, 1.0));
  ScoreBoard.SetText ("On-screen Score Board");
  ScoreBoard.SetFont (F_Bold);
  Cury = Cury + 18;

  // score board on/off //
  ScoreBoardState = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 225.0, 1.0));
  ScoreBoardState.SetText("Enable on-screen score board");
  ScoreBoardState.SetHelpText("");
  ScoreBoardState.SetFont (F_Normal);
  ScoreBoardState.bChecked = class'OverlaySettings'.default.bScoreBoardState;
  ScoreBoardState.bDisabled = true;
  Cury = Cury + 18;

  // display accuracy on/off //
  ShowAccuracy = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 105.0, 1.0));
  ShowAccuracy.SetText("Show accuracy info");
  ShowAccuracy.SetHelpText("");
  ShowAccuracy.SetFont (F_Normal);
  ShowAccuracy.bChecked = class'OverlaySettings'.default.bShowAccuracy;
  ShowAccuracy.bDisabled = true;
  //Cury = Cury + 18;

  ShowSuicides = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 130.0, CurY, 105.0, 1.0));
  ShowSuicides.SetText("Show suicide info");
  ShowSuicides.SetHelpText("");
  ShowSuicides.SetFont (F_Normal);
  ShowSuicides.bChecked = class'OverlaySettings'.default.bShowSuicides;
  ShowSuicides.bDisabled = true;
  Cury = Cury + 18;

  // effects for player with amp //
  AmpEffects = UWindowComboControl(CreateControl(class'UWindowComboControl', 10.0, CurY, 225.0, 50.0));
  AmpEffects.SetText ("Effects for players with amp");
  AmpEffects.SetHelpText ("");
  AmpEffects.SetFont (F_Normal);
  AmpEffects.AddItem ("Off");
  AmpEffects.AddItem ("Min");
  AmpEffects.AddItem ("Max");
  AmpEffects.SetSelectedIndex (class'OverlaySettings'.default.iAmpEffects);
  AmpEffects.EditBoxWidth = 40;
  AmpEffects.bCanEdit = false;
  Cury = Cury + 18;

  // high contrast mode on/off //
  HighContrastMode = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10.0, CurY, 115.0, 1.0));
  HighContrastMode.SetText("Enable contrast mode");
  HighContrastMode.SetHelpText("");
  HighContrastMode.SetFont (F_Normal);
  HighContrastMode.bChecked = class'OverlaySettings'.default.bHighContrastMode;
  HighContrastMode.bDisabled = true;
  //Cury = Cury + 18;

  // show player # on/off //
  PlayerNumbers = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 125.0, CurY, 115.0, 1.0));
  PlayerNumbers.SetText("Show player numbers");
  PlayerNumbers.SetHelpText("");
  PlayerNumbers.SetFont (F_Normal);
  PlayerNumbers.bChecked = class'OverlaySettings'.default.bPlayerNumbers;
  PlayerNumbers.bDisabled = true;
  Cury = Cury + 20;

  // OBS stuff //
  OBSCompatibility = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 0.0, CurY, 240.0, 1.0));
  OBSCompatibility.SetText ("OBS Compatibility");
  OBSCompatibility.Align = TA_Center;
  OBSCompatibility.SetFont (F_Bold);
  Cury = Cury + 20;

  // Offset on top for teams overlay //
  OBSOffset = UWindowComboControl(CreateControl(class'UWindowComboControl', 10.0, CurY, 225.0, 50.0));
  OBSOffset.SetText ("Offset for game info on top");
  OBSOffset.SetHelpText ("");
  OBSOffset.SetFont (F_Normal);
  OBSOffset.AddItem ("None");
  OBSOffset.AddItem ("Small");
  OBSOffset.AddItem ("Medium");
  OBSOffset.AddItem ("Large");
  OBSOffset.SetSelectedIndex (class'OverlaySettings'.default.iOBSOffset);
  OBSOffset.EditBoxWidth = 60;
  OBSOffset.bCanEdit = false;
  Cury = Cury + 20;

  Line = UMenuLabelControl(CreateControl(Class'UMenuLabelControl', 10.0, Cury, 225.0, 1.0));
  Line.SetText ("____________________________________________");
  Line.Align = TA_Center;
  Line.SetFont (F_Normal);
  Cury = Cury + 18;

  // overlay control //
  OverlayControl = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',0.0, CurY, 240.0, 1.0));
  OverlayControl.SetText ("Overlay Control");
  OverlayControl.Align = TA_Center;
  OverlayControl.SetFont (F_Bold);
  Cury = Cury + 18;

  // button //
  OverlayButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton',35.0 , CurY, 175.0, 18.0));
  OverlayButton.SetText( "..." );
  OverlayButton.SetFont (F_Normal);
  OverlayButton.NotifyWindow = Self;
  Cury = Cury + 18;

  // status info //
  OverlayStatus = UMenuLabelControl(CreateControl(Class'UMenuLabelControl',10.0, CurY, 225.0, 1.0));
  OverlayStatus.SetText ("Status:");
  OverlayStatus.Align = TA_Center;
  OverlayStatus.SetFont (F_Normal);
  Cury = Cury + 18;

  //for(Child = LastChildWindow;Child != None; Child = Child.PrevSiblingWindow)
  //Child.bAcceptsFocus=False;

  SetAcceptsFocus();
  LoadExistingKeys();
}


function LoadExistingKeys()
{
  local int i;
  local string KeyName, Alias;

  i = 0;

  for (i = 0; i < 255; i++)
  {
    KeyName = GetPlayerOwner().ConsoleCommand("KEYNAME " $ string(i));
    RealKeyName[i] = KeyName;

    if(KeyName != "")
    {
      Alias = GetPlayerOwner().ConsoleCommand("KEYBINDING " $ KeyName);

      if(Contains(Alias,"|showovo") )
      {
        HotKeyButton.SetText(KeyName);
        OldMenuKey = KeyName;
      }
    }
  }
  return;
}

function DisplayInfo()
{
  if(!HotKeyButton.bDisabled)
  {
  HotKeyBind.SetText("...");
  }
  return;
}

function KeyDown(int Key, float X, float Y)
{
  ProcessKey(Key, RealKeyName[Key]);
  bMenu = false;
  HotKeyButton.bDisabled = false;
  HotKeyBind.SetText("");
}

function ProcessKey(int KeyNo, string KeyName)
{
  if ( (KeyName == "") || (KeyName == "Escape")
  || ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) // function keys
  || ((KeyNo >= 0x30 ) && (KeyNo <= 0x39))) // number keys
  {
  return;
  }

  if(bMenu)
  {
    SetMenuKey(KeyNo, KeyName);
    return;
  }
  return;
}

function SetMenuKey(int KeyNo, string KeyName)
{
  local int i;
  local string TempBind;

  TempBind = GetPlayerOwner().ConsoleCommand("KEYBINDING " $ KeyName);
  TempBind = StrReplace(TempBind,"|showovo","");
  GetPlayerOwner().ConsoleCommand("SET Input " $ KeyName @ TempBind $"|showovo"); // append to existing keybinds
  HotKeyButton.SetText(KeyName);

  for (i = 0; i < 255; i++)
  {
    KeyName = RealKeyName[i];

    if (i == KeyNo) // skip current key
    continue;

    TempBind = GetPlayerOwner().ConsoleCommand("KEYBINDING " $ KeyName);

    if (Contains(TempBind,"|SHOWOVO"))
    {
      TempBind = StrReplace(TempBind,"|showovo","");
      GetPlayerOwner().ConsoleCommand("SET Input "$KeyName@TempBind); // remove |showovo from existing keybind
    }

    if ( Caps(TempBind) == "SHOWOVO"  )
    GetPlayerOwner().ConsoleCommand("SET Input "$KeyName);
  }
  return;
}

function bool Contains(string str, string check)
{
  if (InStr(Caps(str), Caps(check)) > -1)
  return true;
  else
  return false;
}

final function string StrReplace(string str, string replace, string with)
{
  local int i;
  local string Input;

  Input = str;
  str = "";
  i = InStr(Input, Replace);

  while(i != -1)
  {
    str = str$Left(Input, i) $ With;
    Input = Mid(Input, i + Len(Replace));
	i = InStr(Input, Replace);
  }
  return str$Input;
}

function string GetScaleText()
{
  if (class'OverlaySettings'.default.fUIScale == 0.0)
    return "Auto";
  return string(int(class'OverlaySettings'.default.fUIScale * 100)) $ "%";
}

function advSetCustomDeathMsg()
{
  class'OverlayAdvConfig'.static.SetCustomDeathMsg();
}

function advResetToDefaultDeathMsg()
{
  class'OverlayAdvConfig'.static.ResetToDefaultDeathMsg();
}

function loadHUD()
{
  local playerpawn pp;
  pp = root.getplayerowner();

  if (OHUD == none)
  {
    if (pp.myHUD != none)
    pp.myHUD.Destroy();
    pp.myhud = pp.Level.Spawn(class'OverlayHUD', pp);

    if ( class'OverlaySettings'.default.bMsgLengthKF == true )
    advSetCustomDeathMsg();
  }
  else
  {
    advResetToDefaultDeathMsg();
    OHUD.OS.Destroy();
    OHUD.Destroy();
    OHUD = none;
    
    if (pp.Level.Game != None)
        pp.myhud = pp.level.spawn(pp.level.game.hudtype, pp);
    else
        pp.myhud = pp.level.spawn(class'ChallengeDominationHUD', pp);
    
  }
}

function SaveToConfig()
{
 if (OHUD != none)
 {
 class'OverlaySettings'.static.StaticSaveConfig();
 }
}

function Notify(UWindowDialogControl C, byte E)
{
  Super.Notify( C, E );
  if (OverlayStatus == none)
  return;

  if ( OHUD != None)
  OverlayButton.SetText( "Stop" );
  else
  OverlayButton.SetText( "Start" );

  if (OHUD != None )
  {
    switch(E)
	{
      case DE_Click:
      switch(C)
      {
        case OverlayButton:
          loadHUD();
        break;
      case ResetScoresButton:
       MessageBox("RESET SCORES", "Are you sure you want to reset all scores?", MB_YesNo, MR_No);
       break;
        case HotKeyButton:
          if(HotKeyButton != none)
          {
            bMenu = true;
            HotKeyButton.bDisabled = true;
            DisplayInfo();
          }
        break;
      }
      break;

      case DE_Change:
      switch(C)
      {
        case RedNameEdit:
          class'OverlaySettings'.default.RedTeamName = RedNameEdit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;
        case BlueNameEdit:
          class'OverlaySettings'.default.BlueTeamName = BlueNameEdit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;
         case RedMapName1Edit:
          class'OverlaySettings'.default.RedMapPick1Name = RedMapName1Edit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;
        case BlueMapName1Edit:
          class'OverlaySettings'.default.BlueMapPick1Name = BlueMapName1Edit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;  
        case RedMapName2Edit:
          class'OverlaySettings'.default.RedMapPick2Name = RedMapName2Edit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;
        case BlueMapName2Edit:
          class'OverlaySettings'.default.BlueMapPick2Name = BlueMapName2Edit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;  
        case DeciderMapNameEdit:
          class'OverlaySettings'.default.DeciderMapName = DeciderMapNameEdit.GetValue();
          class'OverlaySettings'.static.StaticSaveConfig();
          break;    
        
        case ItemTimer:
          class'OverlaySettings'.default.bShowItemTimer = ItemTimer.bChecked;
          SaveToConfig();
        break;

        case HealthArmor:
          class'OverlaySettings'.default.bShowHealthArmor = HealthArmor.bChecked;
          SaveToConfig();
        break;

        case SpectatedPlayerInfo:
          class'OverlaySettings'.default.bSpectatedPlayerInfo = SpectatedPlayerInfo.bChecked;
          SaveToConfig();
        break;

        case FontSizeChat:
          class'OverlaySettings'.default.iFontSizeChat = FontSizeChat.GetSelectedIndex ();
          SaveToConfig();
        break;

        case FontSizeKF:
          class'OverlaySettings'.default.iFontSizeKF = FontSizeKF.GetSelectedIndex ();
          SaveToConfig();
        break;

        case MsgLengthKF:
          class'OverlaySettings'.default.bMsgLengthKF = MsgLengthKF.bChecked;
          if (MsgLengthKF.bChecked)
             advSetCustomDeathMsg();
          else
             advResetToDefaultDeathMsg();
          SaveToConfig();
        break;

        case UIScaleAuto:
          if (UIScaleAuto.bChecked)
            class'OverlaySettings'.default.fUIScale = 0.0;
          else
            class'OverlaySettings'.default.fUIScale = float(UIScaleSlider.Value) / 100.0;
          UIScaleLabel.SetText("UI Scale: " $ GetScaleText());
          OHUD.ForceResetFonts();
          SaveToConfig();
        break;

        case UIScaleSlider:
          if (!UIScaleAuto.bChecked)
          {
            class'OverlaySettings'.default.fUIScale = float(UIScaleSlider.Value) / 100.0;
            UIScaleLabel.SetText("UI Scale: " $ GetScaleText());
            OHUD.ForceResetFonts();
            SaveToConfig();
          }
        break;

        case ScoreBoardState:
          class'OverlaySettings'.default.bScoreBoardState = ScoreBoardState.bChecked;
          SaveToConfig();
        break;

        case ProgressBarsState:
          class'OverlaySettings'.default.bProgressBarsState = ProgressBarsState.bChecked;
          SaveToConfig();
        break;

        case CameraModeCombo:
          class'OverlaySettings'.default.iCameraMode = CameraModeCombo.GetSelectedIndex();
          class'OverlaySettings'.static.StaticSaveConfig();
        break;

        case BestOf5GamesState:
          class'OverlaySettings'.default.bBestOf5GamesState = BestOf5GamesState.bChecked;
          SaveToConfig();
        break;

        case ShoeWinStrikeDots:
          class'OverlaySettings'.default.bShowWinStrikeDots = ShoeWinStrikeDots.bChecked;
          SaveToConfig();
        break;

        case ShowTeamsMapsPicks:
          class'OverlaySettings'.default.bShowTeamsMapsPicks = ShowTeamsMapsPicks.bChecked;
          SaveToConfig();
         break;

        case LiveScoreCheck:
          class'OverlaySettings'.default.bShowLiveMapScore = LiveScoreCheck.bChecked;
          SaveToConfig();
        break;

        case PerformanceChartCheck:
          class'OverlaySettings'.default.bShowPerformanceChart = PerformanceChartCheck.bChecked;
          SaveToConfig();
        break;

        case LiveBaseTicker:
          class'OverlaySettings'.default.bLiveBaseTicker = LiveBaseTicker.bChecked;
          SaveToConfig();
        break;

        case ShowAccuracy:
          class'OverlaySettings'.default.bShowAccuracy = ShowAccuracy.bChecked;
          SaveToConfig();
        break;

        case ShowSuicides:
          class'OverlaySettings'.default.bShowSuicides = ShowSuicides.bChecked;
          SaveToConfig();
        break;

        case AmpEffects:
          class'OverlaySettings'.default.iAmpEffects = AmpEffects.GetSelectedIndex ();
          SaveToConfig();
        break;

        case HighContrastMode:
          class'OverlaySettings'.default.bHighContrastMode = HighContrastMode.bChecked;
          SaveToConfig();
        break;

        case MovieStyleMode:
          class'OverlaySettings'.default.bMovieStyleMode = MovieStyleMode.bChecked;
          SaveToConfig();

        case PlayerNumbers:
          class'OverlaySettings'.default.bPlayerNumbers = PlayerNumbers.bChecked;
          SaveToConfig();
        break;

        case OBSOffset:
          class'OverlaySettings'.default.iOBSOffset = OBSOffset.GetSelectedIndex ();
          SaveToConfig();
        break;

      }
      break;
    }
  }
  else
  {
    if (root.getplayerowner().myHUD.IsA('OverlayHUD'))
    {
      OHUD = OverlayHUD(root.getplayerowner().myHUD);
      OverlayStatus.SetText("Status: ACTIVE");
      ItemTimer.bChecked = class'OverlaySettings'.default.bShowItemTimer;
      ItemTimer.bDisabled = false;
      HealthArmor.bChecked = class'OverlaySettings'.default.bShowHealthArmor;
      HealthArmor.bDisabled = false;
      SpectatedPlayerInfo.bChecked = class'OverlaySettings'.default.bSpectatedPlayerInfo;
      SpectatedPlayerInfo.bDisabled = false;
      FontSizeChat.SetSelectedIndex(class'OverlaySettings'.default.iFontSizeChat);
      FontSizeKF.SetSelectedIndex(class'OverlaySettings'.default.iFontSizeKF);
      MsgLengthKF.bChecked = class'OverlaySettings'.default.bMsgLengthKF;
      MsgLengthKF.bDisabled = false;
      UIScaleAuto.bChecked = (class'OverlaySettings'.default.fUIScale == 0.0);
      UIScaleAuto.bDisabled = false;
      if (class'OverlaySettings'.default.fUIScale == 0.0)
        UIScaleSlider.SetValue(75);
      else
        UIScaleSlider.SetValue(int(class'OverlaySettings'.default.fUIScale * 100));
      UIScaleLabel.SetText("UI Scale: " $ GetScaleText());
      ScoreBoardState.bChecked = class'OverlaySettings'.default.bScoreBoardState;
      ScoreBoardState.bDisabled = false;
      ProgressBarsState.bChecked = class'OverlaySettings'.default.bProgressBarsState;
      ProgressBarsState.bDisabled = false;
      CameraModeCombo.SetSelectedIndex(class'OverlaySettings'.default.iCameraMode);
      BestOf5GamesState.bChecked = class'OverlaySettings'.default.bBestOf5GamesState;
      BestOf5GamesState.bDisabled = false;
      ShoeWinStrikeDots.bChecked = class'OverlaySettings'.default.bShowWinStrikeDots;
      ShoeWinStrikeDots.bDisabled = false;
      ShowTeamsMapsPicks.bChecked = class'OverlaySettings'.default.bShowTeamsMapsPicks;
      ShowTeamsMapsPicks.bDisabled = false;
      LiveScoreCheck.bChecked = class'OverlaySettings'.default.bShowLiveMapScore;
      LiveScoreCheck.bDisabled = false;
      PerformanceChartCheck.bChecked = class'OverlaySettings'.default.bShowPerformanceChart;
      PerformanceChartCheck.bDisabled = false;
      LiveBaseTicker.bChecked = class'OverlaySettings'.default.bLiveBaseTicker;
      LiveBaseTicker.bDisabled = false;
      ShowAccuracy.bChecked = class'OverlaySettings'.default.bShowAccuracy;
      ShowAccuracy.bDisabled = false;
      ShowSuicides.bChecked = class'OverlaySettings'.default.bShowSuicides;
      ShowSuicides.bDisabled = false;
      AmpEffects.SetSelectedIndex(class'OverlaySettings'.default.iAmpEffects);
      HighContrastMode.bChecked = class'OverlaySettings'.default.bHighContrastMode;
      HighContrastMode.bDisabled = false;
      MovieStyleMode.bChecked = class'OverlaySettings'.default.bMovieStyleMode;
      MovieStyleMode.bDisabled = false;
      PlayerNumbers.bChecked = class'OverlaySettings'.default.bPlayerNumbers;
      PlayerNumbers.bDisabled = false;
    }
    else
    {
      OverlayStatus.SetText("Status: INACTIVE");
      ItemTimer.bDisabled = true;
      HealthArmor.bDisabled = true;
      SpectatedPlayerInfo.bDisabled = true;
      MsgLengthKF.bDisabled = true;
      UIScaleAuto.bDisabled = true;
      ShowAccuracy.bDisabled = true;
      ShowSuicides.bDisabled = true;
      HighContrastMode.bDisabled = true;
      PlayerNumbers.bDisabled = true;
    }

  switch(E)
  {
    case DE_Click:
      switch(C)
      {
        case OverlayButton:
          loadHUD();
        break;

        case HotKeyButton:
          if(HotKeyButton != none)
          {
            bMenu = true;
            HotKeyButton.bDisabled = true;
            DisplayInfo();
          }
        break;
      }
      break;
    }
  }
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
    if (Result == MR_Yes)
    {
        class'OverlaySettings'.default.RedScore1 = 0; class'OverlaySettings'.default.BlueScore1 = 0;
        class'OverlaySettings'.default.RedScore2 = 0; class'OverlaySettings'.default.BlueScore2 = 0;
        class'OverlaySettings'.default.RedScore3 = 0; class'OverlaySettings'.default.BlueScore3 = 0;
        class'OverlaySettings'.default.RedScore4 = 0; class'OverlaySettings'.default.BlueScore4 = 0;
        class'OverlaySettings'.default.RedScore5 = 0; class'OverlaySettings'.default.BlueScore5 = 0;

        class'OverlaySettings'.static.StaticSaveConfig();
        
        Log("OV4DOM: All scores have been reset by streamer after confirmation.");
    }
}

defaultproperties
{
      Settings=None
      GeneralOptions=None
      BehaviourOptions=None
      ScoreBoard=None
      ProgressBars=None
      OverlayControl=None
      OverlayStatus=None
      HotKeyBind=None
      HotKeyMenu=None
      Line=None
      BestOf5Games=None
      VsLabel=None
      OBSCompatibility=None
      TeamsLabel=None
      RedNameEdit=None
      BlueNameEdit=None
      RedMapName1Edit=None
      RedMapName2Edit=None
      BlueMapName1Edit=None
      BlueMapName2Edit=None
      DeciderMapNameEdit=None
      ItemTimer=None
      HealthArmor=None
      SpectatedPlayerInfo=None
      ScoreBoardState=None
      ProgressBarsState=None
      ShowAccuracy=None
      ShowSuicides=None
      HighContrastMode=None
      MsgLengthKF=None
      PlayerNumbers=None
      BestOf5GamesState=None
      ShoeWinStrikeDots=None
      ShowTeamsMapsPicks=None
      LiveScoreCheck=None
      MovieStyleMode=None
      PerformanceChartCheck=None
      LiveBaseTicker=None
      FontSizeChat=None
      FontSizeKF=None
      AmpEffects=None
      CameraModeCombo=None
      OBSOffset=None
      UIScaleSlider=None
      UIScaleLabel=None
      UIScaleAuto=None
      HotKeyButton=None
      OverlayButton=None
      CancelButton=None
      ResetScoresButton=None
      bMenu=False
      RealKeyName(0)=""
      RealKeyName(1)=""
      RealKeyName(2)=""
      RealKeyName(3)=""
      RealKeyName(4)=""
      RealKeyName(5)=""
      RealKeyName(6)=""
      RealKeyName(7)=""
      RealKeyName(8)=""
      RealKeyName(9)=""
      RealKeyName(10)=""
      RealKeyName(11)=""
      RealKeyName(12)=""
      RealKeyName(13)=""
      RealKeyName(14)=""
      RealKeyName(15)=""
      RealKeyName(16)=""
      RealKeyName(17)=""
      RealKeyName(18)=""
      RealKeyName(19)=""
      RealKeyName(20)=""
      RealKeyName(21)=""
      RealKeyName(22)=""
      RealKeyName(23)=""
      RealKeyName(24)=""
      RealKeyName(25)=""
      RealKeyName(26)=""
      RealKeyName(27)=""
      RealKeyName(28)=""
      RealKeyName(29)=""
      RealKeyName(30)=""
      RealKeyName(31)=""
      RealKeyName(32)=""
      RealKeyName(33)=""
      RealKeyName(34)=""
      RealKeyName(35)=""
      RealKeyName(36)=""
      RealKeyName(37)=""
      RealKeyName(38)=""
      RealKeyName(39)=""
      RealKeyName(40)=""
      RealKeyName(41)=""
      RealKeyName(42)=""
      RealKeyName(43)=""
      RealKeyName(44)=""
      RealKeyName(45)=""
      RealKeyName(46)=""
      RealKeyName(47)=""
      RealKeyName(48)=""
      RealKeyName(49)=""
      RealKeyName(50)=""
      RealKeyName(51)=""
      RealKeyName(52)=""
      RealKeyName(53)=""
      RealKeyName(54)=""
      RealKeyName(55)=""
      RealKeyName(56)=""
      RealKeyName(57)=""
      RealKeyName(58)=""
      RealKeyName(59)=""
      RealKeyName(60)=""
      RealKeyName(61)=""
      RealKeyName(62)=""
      RealKeyName(63)=""
      RealKeyName(64)=""
      RealKeyName(65)=""
      RealKeyName(66)=""
      RealKeyName(67)=""
      RealKeyName(68)=""
      RealKeyName(69)=""
      RealKeyName(70)=""
      RealKeyName(71)=""
      RealKeyName(72)=""
      RealKeyName(73)=""
      RealKeyName(74)=""
      RealKeyName(75)=""
      RealKeyName(76)=""
      RealKeyName(77)=""
      RealKeyName(78)=""
      RealKeyName(79)=""
      RealKeyName(80)=""
      RealKeyName(81)=""
      RealKeyName(82)=""
      RealKeyName(83)=""
      RealKeyName(84)=""
      RealKeyName(85)=""
      RealKeyName(86)=""
      RealKeyName(87)=""
      RealKeyName(88)=""
      RealKeyName(89)=""
      RealKeyName(90)=""
      RealKeyName(91)=""
      RealKeyName(92)=""
      RealKeyName(93)=""
      RealKeyName(94)=""
      RealKeyName(95)=""
      RealKeyName(96)=""
      RealKeyName(97)=""
      RealKeyName(98)=""
      RealKeyName(99)=""
      RealKeyName(100)=""
      RealKeyName(101)=""
      RealKeyName(102)=""
      RealKeyName(103)=""
      RealKeyName(104)=""
      RealKeyName(105)=""
      RealKeyName(106)=""
      RealKeyName(107)=""
      RealKeyName(108)=""
      RealKeyName(109)=""
      RealKeyName(110)=""
      RealKeyName(111)=""
      RealKeyName(112)=""
      RealKeyName(113)=""
      RealKeyName(114)=""
      RealKeyName(115)=""
      RealKeyName(116)=""
      RealKeyName(117)=""
      RealKeyName(118)=""
      RealKeyName(119)=""
      RealKeyName(120)=""
      RealKeyName(121)=""
      RealKeyName(122)=""
      RealKeyName(123)=""
      RealKeyName(124)=""
      RealKeyName(125)=""
      RealKeyName(126)=""
      RealKeyName(127)=""
      RealKeyName(128)=""
      RealKeyName(129)=""
      RealKeyName(130)=""
      RealKeyName(131)=""
      RealKeyName(132)=""
      RealKeyName(133)=""
      RealKeyName(134)=""
      RealKeyName(135)=""
      RealKeyName(136)=""
      RealKeyName(137)=""
      RealKeyName(138)=""
      RealKeyName(139)=""
      RealKeyName(140)=""
      RealKeyName(141)=""
      RealKeyName(142)=""
      RealKeyName(143)=""
      RealKeyName(144)=""
      RealKeyName(145)=""
      RealKeyName(146)=""
      RealKeyName(147)=""
      RealKeyName(148)=""
      RealKeyName(149)=""
      RealKeyName(150)=""
      RealKeyName(151)=""
      RealKeyName(152)=""
      RealKeyName(153)=""
      RealKeyName(154)=""
      RealKeyName(155)=""
      RealKeyName(156)=""
      RealKeyName(157)=""
      RealKeyName(158)=""
      RealKeyName(159)=""
      RealKeyName(160)=""
      RealKeyName(161)=""
      RealKeyName(162)=""
      RealKeyName(163)=""
      RealKeyName(164)=""
      RealKeyName(165)=""
      RealKeyName(166)=""
      RealKeyName(167)=""
      RealKeyName(168)=""
      RealKeyName(169)=""
      RealKeyName(170)=""
      RealKeyName(171)=""
      RealKeyName(172)=""
      RealKeyName(173)=""
      RealKeyName(174)=""
      RealKeyName(175)=""
      RealKeyName(176)=""
      RealKeyName(177)=""
      RealKeyName(178)=""
      RealKeyName(179)=""
      RealKeyName(180)=""
      RealKeyName(181)=""
      RealKeyName(182)=""
      RealKeyName(183)=""
      RealKeyName(184)=""
      RealKeyName(185)=""
      RealKeyName(186)=""
      RealKeyName(187)=""
      RealKeyName(188)=""
      RealKeyName(189)=""
      RealKeyName(190)=""
      RealKeyName(191)=""
      RealKeyName(192)=""
      RealKeyName(193)=""
      RealKeyName(194)=""
      RealKeyName(195)=""
      RealKeyName(196)=""
      RealKeyName(197)=""
      RealKeyName(198)=""
      RealKeyName(199)=""
      RealKeyName(200)=""
      RealKeyName(201)=""
      RealKeyName(202)=""
      RealKeyName(203)=""
      RealKeyName(204)=""
      RealKeyName(205)=""
      RealKeyName(206)=""
      RealKeyName(207)=""
      RealKeyName(208)=""
      RealKeyName(209)=""
      RealKeyName(210)=""
      RealKeyName(211)=""
      RealKeyName(212)=""
      RealKeyName(213)=""
      RealKeyName(214)=""
      RealKeyName(215)=""
      RealKeyName(216)=""
      RealKeyName(217)=""
      RealKeyName(218)=""
      RealKeyName(219)=""
      RealKeyName(220)=""
      RealKeyName(221)=""
      RealKeyName(222)=""
      RealKeyName(223)=""
      RealKeyName(224)=""
      RealKeyName(225)=""
      RealKeyName(226)=""
      RealKeyName(227)=""
      RealKeyName(228)=""
      RealKeyName(229)=""
      RealKeyName(230)=""
      RealKeyName(231)=""
      RealKeyName(232)=""
      RealKeyName(233)=""
      RealKeyName(234)=""
      RealKeyName(235)=""
      RealKeyName(236)=""
      RealKeyName(237)=""
      RealKeyName(238)=""
      RealKeyName(239)=""
      RealKeyName(240)=""
      RealKeyName(241)=""
      RealKeyName(242)=""
      RealKeyName(243)=""
      RealKeyName(244)=""
      RealKeyName(245)=""
      RealKeyName(246)=""
      RealKeyName(247)=""
      RealKeyName(248)=""
      RealKeyName(249)=""
      RealKeyName(250)=""
      RealKeyName(251)=""
      RealKeyName(252)=""
      RealKeyName(253)=""
      RealKeyName(254)=""
      OldMenuKey=""
      OHUD=None
}
