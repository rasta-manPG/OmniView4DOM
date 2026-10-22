class OverlayHUD extends ChallengeDominationHUD;

#exec TEXTURE IMPORT FILE=Textures\white_1x1.pcx NAME=white_1x1 MIPS=Off
#exec TEXTURE IMPORT FILE=Textures\amp_icon.pcx NAME=amp_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=Textures\armor_icon.bmp NAME=armor_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=Textures\belt_icon.pcx mp NAME=belt_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=Textures\pads_icon.pcx NAME=pads_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=Textures\health_icon.pcx NAME=health_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=Textures\boots_icon.pcx NAME=boots_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=Textures\timer_checkmark_icon.pcx NAME=timer_checkmark_icon MIPS=Off FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumZero.pcx GROUP="Icons" NAME=NumZero MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumOne.pcx GROUP="Icons" NAME=NumOne MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumTwo.pcx GROUP="Icons" NAME=NumTwo MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumThree.pcx GROUP="Icons" NAME=NumThree MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumFour.pcx GROUP="Icons" NAME=NumFour MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumFive.pcx GROUP="Icons" NAME=NumFive MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumSix.pcx GROUP="Icons" NAME=NumSix MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumSeven.pcx GROUP="Icons" NAME=NumSeven MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumEight.pcx GROUP="Icons" NAME=NumEight MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumNine.pcx GROUP="Icons" NAME=NumNine MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumDash.pcx GROUP="Icons" NAME=NumDash MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT FILE=TEXTURES\NumSimc.pcx GROUP="Icons" NAME=NumSimc MIPS=OFF FLAGS=2

var texture BigNums[10];


var int StartTime, Overtime;
var int AmpCount, BeltCount;
var int savedArmor;
var int IdentifiedID;
var int SavedPitch, LockTimer, AutoAdjustCamDelay;
var int MaxDist;

var float gametime, lasttime;
var float HealthBlink;

var bool b3rdPersonRotationLock;
var bool bHadWarmup;
var bool HealthBlinkUp;
var bool bHideID;

var float LastLogTime;       

var config int RedScoreHistory[200];
var config int BlueScoreHistory[200];
var config int HistoryCount;
var config string CurrentMapName; 

const KILLFEED_LINES = 8;
const KILLFEED_EXTRA_LIFETIME = 4;
const IDENTIFY_FADE_SECONDS = 2;

struct TPowerupTime
{
  var float timeleft;
  var bool inited;
};

struct TeamPossession {
    var float RedTime;
    var float BlueTime;
};
var TeamPossession PointStats[16]; 
var int NumPoints;

var TPowerupTime ptimes[10];
var UDamage AMP;
var UT_Shieldbelt BELT;
var OverlayScoreboard OS;
var DomHUDOverlay DomSource;
var HUDLocalizedMessage KillMessageQueue[KILLFEED_LINES];
var HUDLocalizedMessage ChatMessageQueue[4];
var Canvas CanvasX;
var Font Font469_12, Font469_12b, Font469_16, Font469_16b, Font469_18, Font469_18b, Font469_20, Font469_20b, Font469_24, Font469_24b, Font469_26b, Font469_28b, Font469_32, Font469_38b;
var int SavedScreen;



//////////////
// LET'S GO //
//////////////

function Destroyed()
{
  class'OverlayAdvConfig'.static.ResetToDefaultDeathMsg();
  Super.Destroyed();
}

simulated function PostNetBeginPlay()

{
  showovo();
}

simulated function PostBeginPlay()
{
    local int i;

    Super.PostBeginPlay();

    if (Level.TimeSeconds < 5.0)
    {
        HistoryCount = 0;
        for (i = 0; i < 200; i++)
        {
            RedScoreHistory[i] = 0;
            BlueScoreHistory[i] = 0;
        }
        SaveConfig();
    }
    
    LastLogTime = Level.TimeSeconds;
}

    

exec function ViewPlayerNum(int ID)
{
  local int realID;

  realID = OS.realPlayerID(ID);
  Spectator(PlayerOwner).ViewPlayerNum(RealID);
}

exec function showovo()
{
  local OverlayConfig OC;
  WindowConsole(PlayerPawn(Owner).Player.Console).bQuickKeyEnable = True;
  WindowConsole(PlayerPawn(Owner).Player.Console).LaunchUWindow();
  OC = OverlayConfig(WindowConsole(PlayerPawn(Owner).Player.Console).Root.CreateWindow(class'OverlayConfigWindow',10,10,150,100));
  if (OC != None)
      OC.ShowWindow();
  OC.ShowWindow();
}

event Tick (float delta)
{
  Super.Tick (delta);


  if (HealthBlink <= 0.0)
  HealthBlinkUp = true;
  if (HealthBlink >= 0.5)
  HealthBlinkUp = false;

  if (HealthBlinkUp)
  HealthBlink += delta;
  else if (!HealthBlinkUp)
  HealthBlink -= delta;

  if (Owner.Level.Pauser == "")
  gametime += delta;

  if (PlayerOwner != PawnOwner  )
  {
    if (IdentifiedID != 0 && PawnOwner.PlayerReplicationInfo.PlayerID != IdentifiedID-1 )
    {
      Spectator(owner).ViewPlayerNum(IdentifiedID-1);
      IdentifiedID = 0;
    }

    if (SavedPitch != PlayerPawn(Owner).ViewRotation.Pitch)
    {
      LockTimer = 0;
      SavedPitch = PlayerPawn(Owner).ViewRotation.Pitch;
    }
  }

  if (PlayerPawn(Owner).GameReplicationInfo != none )
  {
    if (PlayerPawn(Owner).GameReplicationInfo.RemainingTime != 0 )
    PlayerPawn(Owner).GameReplicationInfo.ElapsedTime = 0;
  }
}

function Spawned()
{

   OS = Level.Spawn(class'OverlayScoreboard', self);
  
  if (OS != None)
  {
      OS.OH = self;
      OS.SetTimer(1, true);
  }

  foreach Level.allactors (class 'UDamage', AMP)
  {
    AmpCount++;
  }

  foreach Level.allactors (class 'UT_Shieldbelt', BELT)
  {
    BeltCount++;
  }

  if (Owner != None && PlayerPawn(Owner) != None && PlayerPawn(Owner).GameReplicationInfo != None)
  {
      StartTime = PlayerPawn(Owner).GameReplicationInfo.RemainingTime;
  }
  else
  {
      StartTime = 0; 
  }

  Super.Spawned();
}

function ForceResetFonts()
{
  Font469_12 = None;
  Font469_12b = None;
  Font469_16 = None;
  Font469_16b = None;
  Font469_18 = None;
  Font469_18b = None;
  Font469_20 = None;
  Font469_20b = None;
  Font469_24 = None;
  Font469_24b = None;
  Font469_26b = None;
  Font469_28b = None;
  Font469_32 = None;
  Font469_38b = None;
  SavedScreen = 0;
}

// testing stuff for renderer //
exec function highdetail()
{
level.bHighDetailMode = true;
}

exec function lowdetail()
{
level.bHighDetailMode = false;
}
// /testing stuff for renderer //

function bool Contains(string str, string check)
{
  if (InStr(Caps(str), Caps(check)) > -1)
  return true;
  else
  return false;
}

function bool IsInWarmup()
{
  if ( PlayerPawn(Owner).GameReplicationInfo != none && StartTime == PlayerPawn(Owner).GameReplicationInfo.RemainingTime && !bHadWarmUp)
  {
  return true;
  }
  else
  {
  bHadWarmup = true;
  return false;
  }
}

function bool gotShieldBelt(Pawn InputPlayer)
{
  local UT_ShieldBeltEffect BELT;
  local bool foundBeltOwner;

  if (InputPlayer == none)
  return false;

  if (!Level.bHighDetailMode)
  {
    if (Contains(string(InputPlayer.Texture),"BELT_FX.SHIELDBELT") )
    return true;
    else
    return false;
  }
  else
  {
    foreach Level.allactors (class 'UT_ShieldbeltEffect', BELT)
    {
      if (BELT.Owner == InputPlayer)
      {
        foundBeltOwner = true;
        break;
      }
    }
  return foundBeltOwner;
  }
}

simulated function bool TraceIdentifyX()
{
  local actor Other;
  local vector HitLocation, HitNormal, StartTrace, EndTrace;

  StartTrace = PawnOwner.Location;
  StartTrace.Z += PawnOwner.BaseEyeHeight;
  EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * 1500.0;
  Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

  if ( Pawn(Other) != None )
  {
    if ( Pawn(Other).bIsPlayer && !Other.bHidden )
    {
      IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
      IdentifyFadeTime = IDENTIFY_FADE_SECONDS;
    }
  }

  if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || IdentifyTarget.bFeigningDeath )
  return false;

  return true;
}

simulated function SetIDColor( Canvas Canvas, int type )
{
  if ( type == 0 )
  Canvas.DrawColor = AltTeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
  else
  Canvas.DrawColor = TeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
  if ( !TraceIdentifyX())
  return false;

  if( IdentifyTarget.PlayerName != "" )
  {
    Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
    DrawTwoColorID(Canvas,IdentifyName, IdentifyTarget.PlayerName, Canvas.ClipY - 256 * Scale);
  }
  return true;
}

simulated function DrawTwoColorID( canvas Canvas, string TitleString, string ValueString, int YStart )
{
  local float XL, YL, XOffset;

  Canvas.Style = Style;
  Canvas.StrLen(ValueString, XL, YL);
  XOffset = Canvas.ClipX/2 - (XL)/2;
  Canvas.SetPos(XOffset, YStart);
  SetIDColor(Canvas,1);
  Canvas.DrawText(ValueString);
  Canvas.DrawColor = WhiteColor;
  Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
}

simulated function FindDomMutator()
{
    local Mutator M;

    if (DomSource != None || Level.Game == None) 
        return;

    if (Owner == None || PlayerPawn(Owner) == None)
        return;

    for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
    {
        if (DomHUDOverlay(M) != None)
        {
            DomSource = DomHUDOverlay(M);
            break;
        }
    }
}



function UpdateScoreHistory(TournamentGameReplicationInfo TGRI)
{
    local int i;
    local string MapName;

    if (TGRI == None || TGRI.Teams[0] == None || TGRI.Teams[1] == None)
        return;

    // --- Detection map change/restart ---
    MapName = Level.Title; 
    if (CurrentMapName != MapName)
    {
        HistoryCount = 0;
        for (i = 0; i < 200; i++)
        {
            RedScoreHistory[i] = 0;
            BlueScoreHistory[i] = 0;
        }
        LastLogTime = Level.TimeSeconds;
        CurrentMapName = MapName;
        SaveConfig();
        return; 
    }

    // --- Showing warmup mode ---
    if (IsInWarmup())
    {
        HistoryCount = 0;
        LastLogTime = Level.TimeSeconds; 
        return;
    }

   
    if (Level.TimeSeconds - LastLogTime >= 5.0 && HistoryCount < 200)
    {
        RedScoreHistory[HistoryCount] = int(TGRI.Teams[0].Score);
        BlueScoreHistory[HistoryCount] = int(TGRI.Teams[1].Score);
        
        HistoryCount++;
        LastLogTime = Level.TimeSeconds;

        SaveConfig(); 
    }
}

// draw overlay //
simulated function PostRender( canvas Canvas )
{
  local int i;
  local Texture TempTex;
  local float TempScale, TempValue, TempX,TempY;
  local int Offsets[8];
  local float ResScale, OBSOffset;
  local int CurrentPosY;
  local ReplicationInfo RI;
  local ENetRole oldrole;

  local NavigationPoint N;
	local Texture CPTexture;
	local int X, Y;
	local float XL, YL;
	local ControlPoint CP;

  local float BaseOffset, ScoreScale,TimeScale,TargetX;
  local int Val;

  local string DisplayText;
  local float BaseY;
  local int MapsToWin;
  local float DotsY,DotsScale;
  local int RedWins, BlueWins;
 


  Offsets[0] = 1;
  Offsets[1] = 0;
  Offsets[2] = -1;
  Offsets[3] = 0;
  Offsets[4] = 0;
  Offsets[5] = 1;
  Offsets[6] = 0;
  Offsets[7] = -1;

  if ( class'OverlaySettings'.default.iOBSOffset == 0 )
    OBSOffset = 0;
  else if ( class'OverlaySettings'.default.iOBSOffset == 1 )
    OBSOffset = 25;
  else if ( class'OverlaySettings'.default.iOBSOffset == 2 )
    OBSOffset = 50;
      else if ( class'OverlaySettings'.default.iOBSOffset == 3 )
    OBSOffset = 75;


    bHideID = true;
 
   Super(HUD).PostRender( Canvas );

  HUDSetup(canvas);

  
if (PlayerOwner.GameReplicationInfo != None && PlayerOwner.GameReplicationInfo.RemainingTime == 0 && !bForceScores)
{
    
    SaveFinalScore(); 
}

// make sure player exists //
  if ( (PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
  return;

  if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None)
  || (PawnOwner.PlayerReplicationInfo == None)
  || ((PlayerOwner.bShowMenu || PlayerOwner.bShowScores) && (Canvas.ClipX < 640)) )
  return;

  if (OS != none && !PlayerOwner.bShowScores)
  OS.PostRender(Canvas);

// set fonts //
  if (class'OverlaySettings'.default.fUIScale == 0.0)
  {
    if ( (Canvas.ClipX < 2250 && Canvas.ClipX >= 1750) || (Canvas.ClipY < 1150 && Canvas.ClipY >= 900) )
      ResScale = 1.0;
    else if ( Canvas.ClipX < 1750 || Canvas.ClipY < 900 )
      ResScale = 1.25;
    else
      ResScale = 0.75;
  }
  else
    ResScale = class'OverlaySettings'.default.fUIScale;

  

  if (SavedScreen != Canvas.ClipX+Canvas.ClipY)
  {
    Font469_12 = none;
    Font469_12b = none;
    Font469_16 = none;
    Font469_16b = none;
    Font469_18 = none;
    Font469_18b = none;
    Font469_20 = none;
    Font469_20b = none;
    Font469_24 = none;
    Font469_24b = none;
    Font469_26b = none;
    Font469_28b = none;
    Font469_32 = none;
    Font469_38b = none;
    SavedScreen = Canvas.ClipX+Canvas.ClipY;
  }


  if (Font469_12 == none)
    Font469_12 = Canvas.CreateFont(FF_Arial, 12 * ResScale, false, false, false, false, true);
  if (Font469_16 == none)
    Font469_16 = Canvas.CreateFont(FF_Arial, 16 * ResScale, false, false, false, false, true);
  if (Font469_16b == none)
    Font469_16b = Canvas.CreateFont(FF_Arial, 16 * ResScale, true, false, false, false, true);
  if (Font469_12b == none)
    Font469_12b = Canvas.CreateFont(FF_Arial, 12 * ResScale, true, false, false, false, true);
  if (Font469_18 == none)
    Font469_18 = Canvas.CreateFont(FF_Arial, 18 * ResScale, false, false, false, false, true);
  if (Font469_18b == none)
    Font469_18b = Canvas.CreateFont(FF_Arial, 18 * ResScale, true, false, false, false, true);
  if (Font469_20 == none)
    Font469_20 = Canvas.CreateFont(FF_Arial, 20 * ResScale, false, false, false, false, true);
  if (Font469_20b == none)
    Font469_20b = Canvas.CreateFont(FF_Arial, 20 * ResScale, true, false, false, false, true);
  if (Font469_24 == none)
    Font469_24 = Canvas.CreateFont(FF_Arial, 28 * ResScale, false, false, false, false, true);
  if (Font469_24b == none)
    Font469_24b = Canvas.CreateFont(FF_Arial, 24 * ResScale, true, false, false, false, true);
  if (Font469_26b == none)
    Font469_26b = Canvas.CreateFont(FF_Arial, 26 * ResScale, true, false, false, false, true);
  if (Font469_28b == none)
    Font469_28b = Canvas.CreateFont(FF_Arial, 28 * ResScale, true, false, false, false, true);
  if (Font469_32 == none)
    Font469_32 = Canvas.CreateFont(FF_Arial, 32 * (Scale*1.25), false, false, false, false, true);
  if (Font469_38b == none)
    Font469_38b = Canvas.CreateFont(FF_Arial, 72 * Scale * ResScale, true, false, false, false, true);


// draw chat text input //
  if ( PlayerOwner.Player.Console.bTyping )
  DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);

// draw chat and kill feed //
  DrawChat(Canvas);
  DrawKillFeed(Canvas);

// draw centered messages (you killed.. returned the flag..) //
  DrawCenterMessages(Canvas);


// F1 scoreboard //
  if ( PlayerOwner.bShowScores || bForceScores )
  {
    if ( (PlayerOwner.Scoring == None) && (PlayerOwner.ScoringType != None) )
    PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
	  if ( PlayerOwner.Scoring != None )
	  {
    	PlayerOwner.Scoring.OwnerHUD = self;
    	PlayerOwner.Scoring.ShowScores(Canvas);
    	if ( PlayerOwner.Player.Console.bTyping )
    	  DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
    	  return;
      }
  }

  if ( (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) && !bHideCenterMessages )
  DisplayProgressMessage(Canvas); //

// Display Identification Info
  if ( PawnOwner == PlayerOwner )
  DrawIdentifyInfo(Canvas);

  // Display info of spectated player
  if ( ( class'OverlaySettings'.default.bSpectatedPlayerInfo ) && (PawnOwner != PlayerOwner) && (PawnOwner.PlayerReplicationInfo != None) )
  {
	  Canvas.bCenter = true;
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor = SetColor(255, 255, 255);

    if ( class'OverlaySettings'.default.bSpectatedPlayerName )
    {
      Canvas.Font = Font469_24b;
      DrawTextLeft( Canvas, PawnOwner.PlayerReplicationInfo.PlayerName, 4, Canvas.ClipY - 190 * Scale );
    }

    if ( class'OverlaySettings'.default.bSpectatedPlayerWeapon )
    {
      Canvas.Font = Font469_18;

      if ( class'OverlaySettings'.default.bSpectatedPlayerAmmo && PawnOwner.Health > 0 && PawnOwner.Weapon.AmmoType != None )
      {
        RI = PawnOwner.PlayerReplicationInfo;
        oldrole = RI.Role;
        RI.Role = ROLE_Authority;

        DrawTextLeft( Canvas, PawnOwner.Weapon.ItemName $" (" $PawnOwner.Weapon.AmmoType.AmmoAmount $")", 4, Canvas.ClipY - 142 * Scale );

        RI.ROLE = oldrole;
      }
      else if ( PawnOwner.Health > 0 )
      DrawTextLeft( Canvas, PawnOwner.Weapon.ItemName, 4, Canvas.ClipY - 142 * Scale );
    }

    Canvas.bCenter = false;
  }

  
// crosshair and weapons postrender //
  if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) )
  {
  Canvas.DrawColor = WhiteColor;
  PawnOwner.Weapon.PostRender(Canvas);
  if ( !PawnOwner.Weapon.bOwnsCrossHair )
  DrawCrossHair(Canvas, 0,0 );
  }

// draw back ground for HP and armor //
  Canvas.DrawColor = SetColor(4, 4, 4);
  Canvas.Style = ERenderStyle.STY_Translucent;


  if ( class'OverlaySettings'.default.bShowHealthArmor )
  {
// bottom center left
    Canvas.SetPos(Canvas.ClipX * 0.5 - 250 * Scale, Canvas.ClipY * 1 - 112 * Scale);
    if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator && PawnOwner.Health >= 50 )
    Canvas.DrawRect(Texture'white_1x1', 240 * Scale, 100 * Scale);
    else if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator && PawnOwner.Health < 50 )
    {
    Canvas.DrawColor = SetColor(4 + 60*HealthBlink, 4 + 60*HealthBlink, 4 + 60*HealthBlink);
    Canvas.DrawRect(Texture'white_1x1', 240 * Scale, 100 * Scale);
    Canvas.DrawColor = SetColor(4, 4, 4);
    }

// bottom center
    Canvas.SetPos(Canvas.ClipX * 0.5 - 2 * Scale, Canvas.ClipY * 1 - 112 * Scale);
    if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator )
    Canvas.DrawRect(Texture'white_1x1', 4 * Scale, 100 * Scale);

// bottom center right
    Canvas.SetPos(Canvas.ClipX * 0.5 + 10 * Scale, Canvas.ClipY * 1 - 112 * Scale);
    if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator )
    Canvas.DrawRect(Texture'white_1x1', 240 * Scale, 100 * Scale);
  }


// --- Show Team Maps Picks ---
if ( class'OverlaySettings'.default.bShowTeamsMapsPicks )
{
Canvas.Font = Font469_18; 
Canvas.Style = ERenderStyle.STY_Normal;


if (class'OverlaySettings'.default.bBestOf5GamesState)
    BaseY = Canvas.ClipY * 0.30; 
else
    BaseY = Canvas.ClipY * 0.33; 

// 1. RED MAP PICK 1 //
DisplayText = GetSmartScore(class'OverlaySettings'.default.RedMapPick1Name, class'OverlaySettings'.default.RedScore1, class'OverlaySettings'.default.BlueScore1);
DrawTextShadow(Canvas, DisplayText, 20 * Scale, BaseY, SetColor(255, 0, 0));

// 2. BLUE MAP PICK 1 //
DisplayText = GetSmartScore(class'OverlaySettings'.default.BlueMapPick1Name, class'OverlaySettings'.default.RedScore2, class'OverlaySettings'.default.BlueScore2);
DrawTextShadow(Canvas, DisplayText, 20 * Scale, BaseY + (45 * Scale), SetColor(0, 255, 255));

if (class'OverlaySettings'.default.bBestOf5GamesState)
{
    // 3. RED MAP PICK 2 //
    DisplayText = GetSmartScore(class'OverlaySettings'.default.RedMapPick2Name, class'OverlaySettings'.default.RedScore3, class'OverlaySettings'.default.BlueScore3);
    DrawTextShadow(Canvas, DisplayText, 20 * Scale, BaseY + (90 * Scale), SetColor(255, 0, 0));

    // 4. BLUE MAP PICK 2 //
    DisplayText = GetSmartScore(class'OverlaySettings'.default.BlueMapPick2Name, class'OverlaySettings'.default.RedScore4, class'OverlaySettings'.default.BlueScore4);
    DrawTextShadow(Canvas, DisplayText, 20 * Scale, BaseY + (135 * Scale), SetColor(0, 255, 255));

    // 5. DECIDER (BO5) //
    DisplayText = GetSmartScore(class'OverlaySettings'.default.DeciderMapName, class'OverlaySettings'.default.RedScore5, class'OverlaySettings'.default.BlueScore5);
    DrawTextShadow(Canvas, DisplayText, 20 * Scale, BaseY + (180 * Scale), SetColor(255, 255, 0));
}
else
{
    // 3. DECIDER (BO3) //
    DisplayText = GetSmartScore(class'OverlaySettings'.default.DeciderMapName, class'OverlaySettings'.default.RedScore5, class'OverlaySettings'.default.BlueScore5);
    DrawTextShadow(Canvas, DisplayText, 20 * Scale, BaseY + (90 * Scale), SetColor(255, 255, 0));
}
}


RedWins = 0; BlueWins = 0;

// Check each map pick score and count wins for each team. We assume that a higher score means a win for that map pick.
if (class'OverlaySettings'.default.RedScore1 > class'OverlaySettings'.default.BlueScore1) RedWins++;
else if (class'OverlaySettings'.default.BlueScore1 > class'OverlaySettings'.default.RedScore1) BlueWins++;

if (class'OverlaySettings'.default.RedScore2 > class'OverlaySettings'.default.BlueScore2) RedWins++;
else if (class'OverlaySettings'.default.BlueScore2 > class'OverlaySettings'.default.RedScore2) BlueWins++;

if (class'OverlaySettings'.default.RedScore3 > class'OverlaySettings'.default.BlueScore3) RedWins++;
else if (class'OverlaySettings'.default.BlueScore3 > class'OverlaySettings'.default.RedScore3) BlueWins++;

if (class'OverlaySettings'.default.RedScore4 > class'OverlaySettings'.default.BlueScore4) RedWins++;
else if (class'OverlaySettings'.default.BlueScore4 > class'OverlaySettings'.default.RedScore4) BlueWins++;

if (class'OverlaySettings'.default.RedScore5 > class'OverlaySettings'.default.BlueScore5) RedWins++;
else if (class'OverlaySettings'.default.BlueScore5 > class'OverlaySettings'.default.RedScore5) BlueWins++;


if (class'OverlaySettings'.default.bBestOf5GamesState)
    MapsToWin = 3;
else
    MapsToWin = 2;


if (class'OverlaySettings'.default.bMovieStyleMode)
{

 // --- ULTRA-SMOOTH TOP GRADIENT -MOVIE MODE---
    Canvas.Style = ERenderStyle.STY_Translucent;
    
    for (i = 0; i < 30; i++)
    {
        Val = 30 - i; 
        if (Val < 0) Val = 0;
        
        Canvas.DrawColor = SetColor(Val, Val, Val); 

        Canvas.SetPos(0, i * 3 * ResScale); // Benzi mai înguste (3px)
        Canvas.DrawRect(Texture'white_1x1', Canvas.ClipX, 3 * ResScale);
    }
    
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor = WhiteColor;

    // --- BOTTOM SHADOW GRADIENT ---
    Canvas.Style = ERenderStyle.STY_Translucent;
    
  
    for (i = 0; i < 30; i++)
    {
        Val = 25 - i; 
        if (Val < 0) Val = 0;
        
        Canvas.DrawColor = SetColor(Val, Val, Val); 

        Canvas.SetPos(0, Canvas.ClipY - (i * 3 * ResScale)); 
        
        Canvas.DrawRect(Texture'white_1x1', Canvas.ClipX, 3 * ResScale);
    }
    
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor = WhiteColor;

}  

if (TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo) != None)
{
    BaseOffset = 180 * ResScale; 
    ScoreScale = 2.5 * ResScale; 
    DotsScale = 1.2 * ResScale; 

 
    DotsY = (38 + OBSOffset * ResScale) * Scale + (38 * ScoreScale);

    // 1. RED SCORE
    Canvas.DrawColor = SetColor(255, 0, 0);
    DrawBigNumShadow(Canvas, int(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[0].Score), 
        Canvas.ClipX * 0.5 - BaseOffset - (100 * ResScale), (32 + OBSOffset * ResScale) * Scale, ScoreScale);

    if (class'OverlaySettings'.default.bShowWinStrikeDots)
    {
    
    // 2. RED DOTS
    DrawSeriesDots(Canvas, Canvas.ClipX * 0.445 - BaseOffset - (95 * ResScale), 
        DotsY, RedWins, MapsToWin, SetColor(255, 0, 0), DotsScale);

    }   

    // 3. BLUE SCORE
    Canvas.DrawColor = SetColor(0, 255, 255);
    DrawBigNumShadow(Canvas, int(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[1].Score), 
        Canvas.ClipX * 0.51 + BaseOffset, (32 + OBSOffset * ResScale) * Scale, ScoreScale);

    if (class'OverlaySettings'.default.bShowWinStrikeDots)
    {
       

    // 4. BLUE DOTS
    DrawSeriesDots(Canvas, Canvas.ClipX * 0.60 + BaseOffset, 
        DotsY, BlueWins, MapsToWin, SetColor(0, 255, 255), DotsScale);

  }

         // 3. TEAM NAMES
    Canvas.Font = Font469_38b;
    Canvas.Style = ERenderStyle.STY_Normal;
    CurrentPosY = (45 + OBSOffset * ResScale) * Scale;

    // RED TEAM NAME 
    Canvas.DrawColor = SetColor(255, 0, 0);
    Canvas.TextSize(class'OverlaySettings'.default.RedTeamName, TempX, TempY);
    Canvas.SetPos(Canvas.ClipX * 0.5 - BaseOffset - (150 * ResScale) - TempX, CurrentPosY);
    DrawTextShadow(Canvas, class'OverlaySettings'.default.RedTeamName, Canvas.ClipX * 0.5 - BaseOffset - (150 * ResScale) - TempX, CurrentPosY, Canvas.DrawColor);

    // BLUE TEAM NAME 
    Canvas.DrawColor = SetColor(0, 255, 255);
    Canvas.TextSize(class'OverlaySettings'.default.BlueTeamName, TempX, TempY);
    Canvas.SetPos(Canvas.ClipX * 0.52 + BaseOffset + (150 * ResScale), CurrentPosY);
    DrawTextShadow(Canvas, class'OverlaySettings'.default.BlueTeamName, Canvas.ClipX * 0.52 + BaseOffset + (150 * ResScale), CurrentPosY, Canvas.DrawColor);
}

  if ( class'OverlaySettings'.default.bShowHealthArmor && !PawnOwner.PlayerReplicationInfo.bIsSpectator )
  {
//green accent bottom center left
    Canvas.DrawColor = SetColor(0, 45, 0);
    Canvas.Style = ERenderStyle.STY_Normal;

    Canvas.SetPos(Canvas.ClipX * 0.5 - 262  * Scale, Canvas.ClipY * 1 - 112 * Scale);
    Canvas.DrawRect(Texture'white_1x1', 12 * Scale, 100 * Scale);

// yellow accent bottom center right
    Canvas.DrawColor = SetColor(255, 200, 0);
    Canvas.Style = ERenderStyle.STY_Normal;

    Canvas.SetPos(Canvas.ClipX * 0.5 + 250  * Scale, Canvas.ClipY * 1 - 112 * Scale);
    Canvas.DrawRect(Texture'white_1x1', 12 * Scale, 100 * Scale);

// icon for HP //
    Canvas.Style = ERenderStyle.STY_Normal;

    TempTex = Texture'health_icon';
    TempScale = 0.35 * Scale;
    TempValue = 1-(FClamp(PawnOwner.Health,0,100) / 100);
    TempX = Canvas.ClipX * 0.5 - ((100 - 128 * 0.35) * 0.5 + 128 * 0.35) * Scale;
    TempY = Canvas.ClipY * 1 - (112 - (100 - 128 * 0.35) * 0.5) * Scale;

    Canvas.DrawColor = SetColor(255, 255, 255);
    Canvas.SetPos(TempX,TempY);
    Canvas.DrawIcon(TempTex, TempScale);

    Canvas.DrawColor = SetColor(100, 100, 100);
    Canvas.SetPos(TempX,TempY);
    Canvas.DrawTile(TempTex, 128 * TempScale, TempValue * TempScale * 128, 0, 0, 128, 128 * TempValue );

// icon for armor //
    TempTex = Texture'armor_icon';
    TempScale = 0.35 * Scale;
    TempValue = 1-(FClamp(savedArmor,0,100) / 100);
    TempX = Canvas.ClipX * 0.5 + (100 - 128 * 0.35) * 0.5 * Scale;
    TempY = Canvas.ClipY * 1 - (112 - (100 - 128 * 0.35) * 0.5) * Scale;

    Canvas.DrawColor = SetColor(255, 255, 255);
    Canvas.SetPos(TempX,TempY);
    Canvas.DrawIcon(TempTex, TempScale);

    Canvas.DrawColor = SetColor(100, 100, 100);
    Canvas.SetPos(TempX,TempY);
    Canvas.DrawTile(TempTex, 128 * TempScale, TempValue * TempScale * 128, 0, 0, 128, 128 * TempValue );
  }


// --- DRAW GAME TIME ---
if (PlayerOwner.GameReplicationInfo != None)
{
    i = PlayerOwner.GameReplicationInfo.RemainingTime;
    if (i <= 0) i = 0;

    TimeScale = 1.35 * ResScale; 
    TargetX = (Canvas.ClipX * 0.5) - (40 * TimeScale); 

    DrawTime(Canvas, TargetX, (35 + OBSOffset * ResScale) * Scale, i, TimeScale);
}

// display HP and armor amount //
  if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator && class'OverlaySettings'.default.bShowHealthArmor )
  {
    DrawBigNum(Canvas, Max(0, PawnOwner.Health), Canvas.ClipX * 0.5 - 236 * Scale, Canvas.ClipY * 1 - 95 * Scale, 1.75);
    DrawArmor(Canvas);
  }

// draw timer for power ups //
  if ( class'OverlaySettings'.default.bShowItemTimer )
  DrawItemTimer(canvas);

     
     if (class'OverlaySettings'.default.iCameraMode == 0)
      Spectator(PlayerOwner).bBehindView = false; // First person
    else if (class'OverlaySettings'.default.iCameraMode == 1)
      Spectator(PlayerOwner).bBehindView = true;  // Third person



// --- DRAW CONTROL POINT ICONS AND NAMES (DOMINATION) ---
  X = 0;
	Y = Canvas.ClipY - 384 * Scale;
	Canvas.Style = Style;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('ControlPoint') )
		{
			CP = ControlPoint(N);
			if (CP.ControllingTeam != None) 
				CPTexture = TeamIcon[CP.ControllingTeam.TeamIndex];
			else
				CPTexture = texture'I_TeamN';

			Canvas.DrawColor = BaseColor;
			Canvas.SetPos(X,Y);
			Canvas.DrawIcon(CPTexture, Scale);//Scale);
			Y -= 140 * Scale;
		}

	// separate name drawing to reduce texture changes
	Y = Canvas.ClipY - 384 * Scale;
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('ControlPoint') )
		{
			CP = ControlPoint(N);
			if (CP.ControllingTeam != None) 
				Canvas.DrawColor = TeamColor[CP.ControllingTeam.TeamIndex];
			else
				Canvas.DrawColor = WhiteColor;
			Canvas.SetPos(0, 0);
			Canvas.StrLen(CP.PointName, XL, YL);
			Canvas.SetPos(0, Y + 96 * Scale - YL);
			DrawTextShadow(Canvas, CP.PointName, 0, Y + 96 * Scale - YL, Canvas.DrawColor);

			Y -= 140 * Scale;
		}


    if (TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo) != None)
    {
     UpdateScoreHistory(TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo));
    }


    if (class'OverlaySettings'.default.bShowPerformanceChart)
    {
    DrawPerformanceChart(Canvas);
    }
}



// Helper function to draw win strike dots for each team
simulated function DrawSeriesDots(Canvas C, float X, float Y, int CurrentWins, int TotalNeeded, color WinColor, float ExtraScale)
{
    local int d;
    local float DotSize, Spacing;

    DotSize = 12 * ExtraScale;
    Spacing = 16 * ExtraScale;

    for (d = 0; d < TotalNeeded; d++)
    {
        if (d < CurrentWins)
            C.DrawColor = WinColor;
        else
            C.DrawColor = SetColor(60, 60, 60);

        C.SetPos(X + (d * Spacing), Y);
        C.DrawTile(Texture'white_1x1', DotSize, DotSize, 0, 0, 1, 1);
    }
}

// Helper function to draw map name with score and winner indicator
simulated function DrawMapRowWithWinner(Canvas C, string T, float X, float Y, color TextColor, int RScore, int BScore)
{
    local float XL, YL;

    // 1. Shadow text
    DrawTextShadow(C, T, X, Y, TextColor);

    C.TextSize(T, XL, YL);

    // 3. Draw the small square indicator if there's a winner for this map
    if (RScore > 0 || BScore > 0)
    {
        // Set color based on who won
        if (RScore > BScore)
            C.DrawColor = SetColor(255, 0, 0); 
        else if (BScore > RScore)
            C.DrawColor = SetColor(0, 255, 255); 
        else
            C.DrawColor = SetColor(200, 200, 200); // Tie or no score

        C.SetPos(X + XL + (15 * Scale), Y + (YL * 0.2));
        
        C.DrawTile(Texture'WhiteTexture', 12 * Scale, 12 * Scale, 0, 0, 1, 1);
    }
}

// Helper function to clean map names by removing extensions and converting to uppercase
simulated function string CleanMapName(string MapName)
{
    local int DotPos;
    local string Cleaned;

    Cleaned = MapName;
    DotPos = InStr(Cleaned, ".");

    if (DotPos != -1)
    {
        Cleaned = Left(Cleaned, DotPos);
    }

    return Caps(Cleaned);
}

// Function to save final scores to .ini based on current map
function SaveFinalScore()
{
    local string CurrentMap;
    local TournamentGameReplicationInfo TGRI;
    local int R, B;

    TGRI = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);
    if (TGRI == None) return;

    R = int(TGRI.Teams[0].Score);
    B = int(TGRI.Teams[1].Score);
    CurrentMap = CleanMapName(Level.Title);

    if (InStr(CurrentMap, CleanMapName(class'OverlaySettings'.default.RedMapPick1Name)) != -1) {
        class'OverlaySettings'.default.RedScore1 = R; class'OverlaySettings'.default.BlueScore1 = B;
    }
    else if (InStr(CurrentMap, CleanMapName(class'OverlaySettings'.default.BlueMapPick1Name)) != -1) {
        class'OverlaySettings'.default.RedScore2 = R; class'OverlaySettings'.default.BlueScore2 = B;
    }
    else if (InStr(CurrentMap, CleanMapName(class'OverlaySettings'.default.RedMapPick2Name)) != -1) {
        class'OverlaySettings'.default.RedScore3 = R; class'OverlaySettings'.default.BlueScore3 = B;
    }
    else if (InStr(CurrentMap, CleanMapName(class'OverlaySettings'.default.BlueMapPick2Name)) != -1) {
        class'OverlaySettings'.default.RedScore4 = R; class'OverlaySettings'.default.BlueScore4 = B;
    }
    else if (InStr(CurrentMap, CleanMapName(class'OverlaySettings'.default.DeciderMapName)) != -1) {
        class'OverlaySettings'.default.RedScore5 = R; class'OverlaySettings'.default.BlueScore5 = B;
    }

    // Save scores to .ini
    class'OverlaySettings'.static.StaticSaveConfig();
}

// Remove or override any default status drawing (health, armor, etc.) if needed
simulated function DrawStatus(Canvas Canvas)
{
   
}
// Helper function to draw text with a shadow for better visibility
function DrawTextShadow(Canvas C, string T, float X, float Y, color TextColor)
{
    // Black shadow text behind the main text for better visibility
    C.DrawColor = SetColor(0, 0, 0);
    C.SetPos(X + 1, Y + 1);
    C.DrawText(T);

    // Color main text
    C.DrawColor = TextColor;
    C.SetPos(X, Y);
    C.DrawText(T);
}
// Helper function to draw big numbers with a shadow effect
simulated function DrawBigNumShadow(Canvas C, int Value, float X, float Y, float ScaleSize)
{
    local color OriginalColor;
    OriginalColor = C.DrawColor;

    
    C.DrawColor = SetColor(0, 0, 0);
    DrawBigNum(C, Value, X + (2 * Scale), Y + (2 * Scale), ScaleSize);

   
    C.DrawColor = OriginalColor;
    DrawBigNum(C, Value, X, Y, ScaleSize);
}


function DrawTime(Canvas Canvas, float X, float Y, int Seconds, float ExtraSize)
{
  local int Min, Sec;
  local float Step;

  Min = Seconds / 60;
  Sec = Seconds % 60;
  
  
  Step = 25 * ExtraSize; 

  Canvas.Style = ERenderStyle.STY_Normal; 
  Canvas.DrawColor = SetColor(255, 255, 255, 255);

 //Manual drawing of time digits to allow for custom styling and scaling, especially for the separator ":"

  // 1. Minute Tens
  Canvas.SetPos(X, Y);
  DrawTimeDigit(Canvas, ((Min/10)%10), 0, ExtraSize);

  // 2. Minute Units
  Canvas.SetPos(X + Step, Y);
  DrawTimeDigit(Canvas, (Min%10), 0, ExtraSize);

  // 3. SEPARATOR ":" 
  Canvas.SetPos(X + (Step * 1.8), Y); 
  DrawTimeDigit(Canvas, 0, 0, ExtraSize, true);

  // 4. Seconds Tens
  Canvas.SetPos(X + (Step * 2.6), Y);
  DrawTimeDigit(Canvas, ((Sec/10)%10), 0, ExtraSize);

  // 5. Seconds Units
  Canvas.SetPos(X + (Step * 3.6), Y);
  DrawTimeDigit(Canvas, (Sec%10), 0, ExtraSize);
}

simulated function DrawTimeDigit(Canvas Canvas, int d, int Step, float UpScale, optional bool Semi )
{

  Canvas.Style = ERenderStyle.STY_Translucent;

  Canvas.DrawColor = SetColor(255,255,255,1);

  if (Semi)
  {
    // Separatorul ":"
    if (Texture'NumSimc' != None)
        Canvas.DrawIcon(Texture'NumSimc', UpScale);
    return;
  }

  // Draw the digit using the BigNums array, which should contain textures for digits 0-9
  if (BigNums[d] != None)
      Canvas.DrawIcon(BigNums[d], UpScale);
}

// This function returns a string with the map name and score for the given map, based on the current live score and the saved score from .ini. It prioritizes the live score if the map is currently being played, otherwise it shows the saved score if available, and if not it just shows the map name.
simulated function string GetSmartScore(string ConfigMapName, int SavedRed, int SavedBlue)
{
    local string CurrentMap;
    local TournamentGameReplicationInfo TGRI;
    local int LiveRed, LiveBlue;

    if (ConfigMapName == "") return "";

    CurrentMap = CleanMapName(Level.Title);
    TGRI = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);

    // 1. Live score for map being played -> Show live score
    if (InStr(CurrentMap, CleanMapName(ConfigMapName)) != -1 || InStr(CleanMapName(ConfigMapName), CurrentMap) != -1)
    {
        if (TGRI != None)
        {
            if (class'OverlaySettings'.default.bShowLiveMapScore || TGRI.bStopCountDown)
            {
                LiveRed = int(TGRI.Teams[0].Score);
                LiveBlue = int(TGRI.Teams[1].Score);
                return ConfigMapName @ "[" $ LiveRed $ "-" $ LiveBlue $ "]";
            }
            else 
            {
                return ConfigMapName;
            }
        }
    }
    
    // 2. Saved score for maps not being played -> Show saved score if available
    if (SavedRed > 0 || SavedBlue > 0)
    {
        return ConfigMapName @ "[" $ SavedRed $ "-" $ SavedBlue $ "]";
    }

    // 3. Only map name -> Show map name
    return ConfigMapName;
}


function DrawPerformanceChart(Canvas Canvas)
{
    local float ChartX, ChartY, ChartW, ChartH, TextY, GridY;
    local float StepX, MaxScoreScale, ResScale;
    local int i, j;
    local float PointX1, PointY1, PointX2, PointY2;
    local color AxisColor;

    
    ResScale = Canvas.ClipX / 1920.0;
    ChartW = 375 * ResScale; 
    ChartH = 225 * ResScale; 
    ChartX = 15 * ResScale;  
    ChartY = 60 * ResScale;  

    Canvas.SetPos(ChartX, ChartY);
    Canvas.DrawColor= SetColor(4, 4, 4);
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawRect(Texture'white_1x1', ChartW, ChartH);
    Canvas.Style = ERenderStyle.STY_Normal;

    
    Canvas.Font = Font469_16b;
    Canvas.DrawColor = SetColor(255, 255, 255);
    Canvas.SetPos(ChartX + (ChartW / 2) - (25 * ResScale), ChartY + (5 * ResScale));
    Canvas.DrawText("TOTAL", false);

    
    if (IsInWarmup())
    {
        Canvas.Font = Font469_12b;
        Canvas.DrawColor = SetColor(255, 50, 50);
        Canvas.SetPos(ChartX + (20 * ResScale), ChartY + (5 * ResScale));
        Canvas.DrawText("[ WARMUP MODE ]", false);
    }


    // --- Draw Axes ---
    
    AxisColor = SetColor(120, 120, 120, 255);
    DrawLine(Canvas, ChartX + (35 * ResScale), ChartY + (25 * ResScale), ChartX + (35 * ResScale), ChartY + ChartH - (25 * ResScale), AxisColor);
    DrawLine(Canvas, ChartX + (35 * ResScale), ChartY + ChartH - (25 * ResScale), ChartX + ChartW - (25 * ResScale), ChartY + ChartH - (25 * ResScale), AxisColor);
    DrawLine(Canvas, ChartX + ChartW - (25 * ResScale), ChartY + (25 * ResScale), ChartX + ChartW - (25 * ResScale), ChartY + ChartH - (25 * ResScale), AxisColor);

    // Three horizontal grid lines
    Canvas.DrawColor = SetColor(40, 40, 40);

    for (i = 1; i <= 3; i++)
    {
        GridY = (ChartY + ChartH - (25 * ResScale)) - (i * (ChartH - (50 * ResScale)) / 3);
        for (j = 0; j < (ChartW - (60 * ResScale)); j += (6 * ResScale))
        {
            Canvas.SetPos(ChartX + (35 * ResScale) + j, GridY);
            Canvas.DrawRect(Texture'white_1x1', 2 * ResScale, 1); 
        }
    }

    // Axe text and labels
    Canvas.Font = Font469_12;
    Canvas.DrawColor = SetColor(150, 150, 150);

    for (i = 0; i <= 3; i++) {
        GridY = (ChartY + ChartH - (25 * ResScale)) - (i * (ChartH - (50 * ResScale)) / 3);
        Canvas.SetPos(ChartX + (10 * ResScale), GridY - (5 * ResScale));
        Canvas.DrawText(string(i * 5), false);
        Canvas.SetPos(ChartX + ChartW - (20 * ResScale), GridY - (5 * ResScale));
        Canvas.DrawText(string(i * 100), false);
    }
    // original axes for 0, 5, 10, 15 seconds with fixed step
    TextY = ChartY + ChartH - (22 * ResScale);
    StepX = (ChartW - (60 * ResScale)) / 180.0; 

    Canvas.SetPos(ChartX + (33 * ResScale), TextY); Canvas.DrawText("0", false);
    Canvas.SetPos(ChartX + (35 * ResScale) + (30 * StepX) - (10 * ResScale), TextY); Canvas.DrawText("2.5", false);
    Canvas.SetPos(ChartX + (35 * ResScale) + (60 * StepX) - (5 * ResScale), TextY); Canvas.DrawText("5", false);
    Canvas.SetPos(ChartX + (35 * ResScale) + (90 * StepX) - (10 * ResScale), TextY); Canvas.DrawText("7.5", false);
    Canvas.SetPos(ChartX + (35 * ResScale) + (120 * StepX) - (8 * ResScale), TextY); Canvas.DrawText("10", false);
    Canvas.SetPos(ChartX + (35 * ResScale) + (150 * StepX) - (12 * ResScale), TextY); Canvas.DrawText("12.5", false);
    Canvas.SetPos(ChartX + (35 * ResScale) + (180 * StepX) - (10 * ResScale), TextY); Canvas.DrawText("15", false);

    Canvas.Font = Font469_12b; 
    Canvas.DrawColor = SetColor(255, 50, 50);

    Canvas.SetPos(ChartX + (ChartW * 0.25), ChartY + ChartH - (12 * ResScale));
    Canvas.DrawText("- Red Team", false);

    Canvas.DrawColor = SetColor(0, 200, 255);

    Canvas.SetPos(ChartX + (ChartW * 0.60), ChartY + ChartH - (12 * ResScale));
    Canvas.DrawText("- Blue Team", false);

    if (HistoryCount < 2) return;

    // --- 6. RENDERING LINII  ---
    MaxScoreScale = 300.0; 

    // red line
    
    Canvas.DrawColor = SetColor(255, 50, 50);

    for (i = 0; i < HistoryCount - 1; i++)
    {
        PointX1 = ChartX + (35 * ResScale) + (i * StepX);
        PointY1 = (ChartY + ChartH - (25 * ResScale)) - ((Float(RedScoreHistory[i]) / MaxScoreScale) * (ChartH - (50 * ResScale)));
        PointX2 = ChartX + (35 * ResScale) + ((i + 1) * StepX);
        PointY2 = (ChartY + ChartH - (25 * ResScale)) - ((Float(RedScoreHistory[i + 1]) / MaxScoreScale) * (ChartH - (50 * ResScale)));
        DrawLine(Canvas, PointX1, PointY1, PointX2, PointY2, Canvas.DrawColor);
    }

    // blue line
   
    Canvas.DrawColor = SetColor(0, 200, 255);

    for (i = 0; i < HistoryCount - 1; i++)
    {
        PointX1 = ChartX + (35 * ResScale) + (i * StepX);
        PointY1 = (ChartY + ChartH - (25 * ResScale)) - ((Float(BlueScoreHistory[i]) / MaxScoreScale) * (ChartH - (50 * ResScale)));
        PointX2 = ChartX + (35 * ResScale) + ((i + 1) * StepX);
        PointY2 = (ChartY + ChartH - (25 * ResScale)) - ((Float(BlueScoreHistory[i + 1]) / MaxScoreScale) * (ChartH - (50 * ResScale)));
        DrawLine(Canvas, PointX1, PointY1, PointX2, PointY2, Canvas.DrawColor);
    }
}



function DrawLine(Canvas C, float X1, float Y1, float X2, float Y2, color Color)
{
    local float DX, DY, Steps, StepX, StepY, PosX, PosY;
    local int i;
    local float Thickness; 

    DX = X2 - X1;
    DY = Y2 - Y1;

    if (DX < 0.0) DX = -DX;
    if (DY < 0.0) DY = -DY;

    if (DX > DY)
        Steps = DX;
    else
        Steps = DY;

    if (Steps < 1.0)
        Steps = 1.0;

    StepX = (X2 - X1) / Steps;
    StepY = (Y2 - Y1) / Steps;

    C.DrawColor = Color;

    // --- Configure thickness ---
    Thickness = 2.0; 

    for (i = 0; i <= int(Steps); i++)
    {
        PosX = X1 + StepX * i;
        PosY = Y1 + StepY * i;
        
        C.SetPos(PosX, PosY - (Thickness / 2.0));
        
        C.DrawRect(Texture'white_1x1', Thickness, Thickness);
    }
}



function Timer()
{
  local int i,j;
  Super.Timer();


  LockTimer++;
// Age the chat message queue original) //
  for (i=0; i<4; i++)
  {
    // Purge expired messages.
    if ( (ChatMessageQueue[i].Message != None) && (Level.TimeSeconds >= ChatMessageQueue[i].EndOfLife) )
    ClearMessage(ChatMessageQueue[i]);
  }

// Clean empty slots //
  for (i=0; i<3; i++)
  {
    if ( ChatMessageQueue[i].Message == None )
    {
      for (j=i; j<4; j++)
      {
        if ( ChatMessageQueue[j].Message != None )
        {
          CopyMessage(ChatMessageQueue[i],ChatMessageQueue[j]);
          ClearMessage(ChatMessageQueue[j]);
          break;
        }
      }
    }
  }
// Age the kill message queue //
  for (i=0; i<KILLFEED_LINES; i++)
  {
// Purge expired messages.
    if ( (KillMessageQueue[i].Message != None) && (Level.TimeSeconds >= KillMessageQueue[i].EndOfLife) )
    ClearMessage(KillMessageQueue[i]);
  }

// Clean empty slots //
  for (i=0; i<KILLFEED_LINES-1; i++)
  {
    if ( KillMessageQueue[i].Message == None )
    {
      for (j=i; j<KILLFEED_LINES; j++)
      {
        if ( KillMessageQueue[j].Message != None )
        {
          CopyMessage(KillMessageQueue[i],KillMessageQueue[j]);
          ClearMessage(KillMessageQueue[j]);
          break;
        }
      }
    }
  }
}

// function to corretly display custom death messages //
function string returnDeathMessage(Object Weapon)
{
  local string WeaponName;

  WeaponName = GetItemName(String(Weapon));

  if (Contains(WeaponName,"ImpactHammer") )
    return class'impacthammer'.default.DeathMessage;
  else if (Contains(WeaponName,"Translocator") )
    return class'Translocator'.default.DeathMessage;
  else if (Contains(WeaponName,"Enforcer") )
    return class'Enforcer'.default.DeathMessage;
  else if (Contains(WeaponName,"BioRifle") )
    return class'UT_BioRifle'.default.DeathMessage;
  else if (Contains(WeaponName,"SuperShockRifle") )
    return class'SuperShockRifle'.default.DeathMessage;
  else if (Contains(WeaponName,"ShockRifle") )
    return class'ShockRifle'.default.DeathMessage;
  else if (Contains(WeaponName,"PulseGun") )
    return class'PulseGun'.default.DeathMessage;
  else if (Contains(WeaponName,"Ripper") )
    return class'Ripper'.default.DeathMessage;
  else if (Contains(WeaponName,"Minigun") )
    return class'Minigun2'.default.DeathMessage;
  else if (Contains(WeaponName,"FlakCannon") )
    return class'UT_FlakCannon'.default.DeathMessage;
  else if (Contains(WeaponName,"Eightball") )
    return class'UT_EightBall'.default.DeathMessage;
  else if (Contains(WeaponName,"SniperRifle") )
    return class'SniperRifle'.default.DeathMessage;
  else
    return "UNKNOWN WEAPON: "$string(Weapon);
}

// Deal with a localized messages //
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
{
  local int i;

  // Block messages ControlPointMessage
    // Blocking "Control Point [Nook] now controlled by..."
  if (Message.Name == 'ControlPointMessage' || Message.Name == 'CTFMessage')
      return;

  if ( ClassIsChildOf( Message, class'PickupMessagePlus' ) )
  PickupTime = Level.TimeSeconds;

  if ( !Message.Default.bIsSpecial )
  {
    if (!ClassIsChildOf(Message, class'DeathMessagePlus')  && !ClassIsChildOf(Message, class'MultiKillMessage') && !Contains(String(Message),"IGPlus_DeathMessagePlus")  )
    {
      if ( ClassIsChildOf(Message, class'SayMessagePlus') ||
      ClassIsChildOf(Message, class'TeamSayMessagePlus') )
      {
        FaceTexture = RelatedPRI_1.TalkTexture;

        if ( FaceTexture != None )
        FaceTime = Level.TimeSeconds + 3;
      }
// Find an empty slot  //
      for (i=0; i<4; i++)
      {
        if ( ChatMessageQueue[i].Message == None )
        {
          ChatMessageQueue[i].Message = Message;
          ChatMessageQueue[i].Switch = Switch;
          ChatMessageQueue[i].RelatedPRI = RelatedPRI_1;
          ChatMessageQueue[i].OptionalObject = OptionalObject;
          ChatMessageQueue[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
          if ( Message.Default.bComplexString )
          ChatMessageQueue[i].StringMessage = CriticalString;
          else
          ChatMessageQueue[i].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
          return;
        }
      }
// No empty slots.  Force a message out //
      for (i=0; i<3; i++)
      CopyMessage(ChatMessageQueue[i], ChatMessageQueue[i+1]);

      ChatMessageQueue[3].Message = Message;
      ChatMessageQueue[3].Switch = Switch;
      ChatMessageQueue[3].RelatedPRI = RelatedPRI_1;
      ChatMessageQueue[3].OptionalObject = OptionalObject;
      ChatMessageQueue[3].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;

      if ( Message.Default.bComplexString )
      ChatMessageQueue[3].StringMessage = CriticalString;
      else
      ChatMessageQueue[3].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
      return;
    }

  else
  {
    if ( ClassIsChildOf(Message, class'SayMessagePlus') || ClassIsChildOf(Message, class'TeamSayMessagePlus') )
    {
      FaceTexture = RelatedPRI_1.TalkTexture;

      if ( FaceTexture != None )
      FaceTime = Level.TimeSeconds + 3;
    }

    if ( class'OverlaySettings'.default.bMsgLengthKF)
    class'OverlayAdvConfig'.static.SetCustomDeathMsg();

// Find an empty slot //
    for (i=0; i<KILLFEED_LINES; i++)
    {
      if ( KillMessageQueue[i].Message == None )
      {
        KillMessageQueue[i].Message = Message;
        KillMessageQueue[i].Switch = Switch;
        KillMessageQueue[i].RelatedPRI = RelatedPRI_1;
        KillMessageQueue[i].OptionalObject = OptionalObject;
        KillMessageQueue[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds + KILLFEED_EXTRA_LIFETIME;

        if ( Message.Default.bComplexString )
        KillMessageQueue[i].StringMessage = CriticalString;

        else
        {
          if (RelatedPRI_1 != none && RelatedPRI_2 != none && OptionalObject != none )
          {
            Class<Weapon>(OptionalObject).Default.DeathMessage=returnDeathMessage(OptionalObject);
            KillMessageQueue[i].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
          }
          else
          KillMessageQueue[i].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
        }
        return;
      }
    }
// No empty slots.  Force a message out //
    for (i=0; i<KILLFEED_LINES-1; i++)
      CopyMessage(KillMessageQueue[i], KillMessageQueue[i+1]);
      KillMessageQueue[KILLFEED_LINES-1].Message = Message;
	  KillMessageQueue[KILLFEED_LINES-1].Switch = Switch;
	  KillMessageQueue[KILLFEED_LINES-1].RelatedPRI = RelatedPRI_1;
	  KillMessageQueue[KILLFEED_LINES-1].OptionalObject = OptionalObject;
	  KillMessageQueue[KILLFEED_LINES-1].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds+ KILLFEED_EXTRA_LIFETIME;

      if ( Message.Default.bComplexString )
      KillMessageQueue[i].StringMessage = CriticalString;

      else
      {
        if (RelatedPRI_1 != none && RelatedPRI_2 != none && OptionalObject != none )
        {
          Class<Weapon>(OptionalObject).Default.DeathMessage=returnDeathMessage(OptionalObject);
          KillMessageQueue[i].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
        }
        else
        KillMessageQueue[i].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
      }
      return;
    }
  }

  else
  {
    if ( CriticalString == "" )
    CriticalString = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

    if ( Message.Default.bIsUnique )
    {
      for (i=0; i<10; i++)
      {
        if (LocalMessages[i].Message != None)
        {
          if ((LocalMessages[i].Message == Message) || (LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, 24, 640) == Message.Static.GetOffset(Switch, 24, 640)) )
          {
            LocalMessages[i].Message = Message;
            LocalMessages[i].Switch = Switch;
            LocalMessages[i].RelatedPRI = RelatedPRI_1;
            LocalMessages[i].OptionalObject = OptionalObject;
            LocalMessages[i].LifeTime = Message.Default.Lifetime;
            LocalMessages[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
            LocalMessages[i].StringMessage = CriticalString;
            LocalMessages[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
            LocalMessages[i].XL = 0;
            return;
          }
        }
      }
    }

    for (i=0; i<10; i++)
    {
      if (LocalMessages[i].Message == None)
      {
        LocalMessages[i].Message = Message;
        LocalMessages[i].Switch = Switch;
        LocalMessages[i].RelatedPRI = RelatedPRI_1;
	    LocalMessages[i].OptionalObject = OptionalObject;
        LocalMessages[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
        LocalMessages[i].StringMessage = CriticalString;
        LocalMessages[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
        LocalMessages[i].LifeTime = Message.Default.Lifetime;
        LocalMessages[i].XL = 0;
        return;
      }
    }
// No empty slots.  Force a message out //
    for (i=0; i<9; i++)
      CopyMessage(LocalMessages[i],LocalMessages[i+1]);
      LocalMessages[9].Message = Message;
      LocalMessages[9].Switch = Switch;
      LocalMessages[9].RelatedPRI = RelatedPRI_1;
      LocalMessages[9].OptionalObject = OptionalObject;
      LocalMessages[9].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
      LocalMessages[9].StringMessage = CriticalString;
	  LocalMessages[9].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
	  LocalMessages[9].LifeTime = Message.Default.Lifetime;
	  LocalMessages[9].XL = 0;
	  return;
  }
}


// Entry point for string messages //
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
  local int i;
  local Class<LocalMessage> MessageClass;

  switch (MsgType)
  {
    case 'Say':
      MessageClass = class'SayMessagePlus';
    break;

    case 'TeamSay':
      MessageClass = class'TeamSayMessagePlus';
    break;

    case 'CriticalEvent':
      MessageClass = class'CriticalStringPlus';
      LocalizedMessage( MessageClass, 0, None, None, None, Msg );
    return;

	default:
	  MessageClass= class'StringMessagePlus';
	break;
  }

  if ( ClassIsChildOf(MessageClass, class'SayMessagePlus') || ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') )
  {
    FaceTexture = PRI.TalkTexture;
	FaceTeam = TeamColor[PRI.Team];

    if ( FaceTexture != None )
	FaceTime = Level.TimeSeconds + 3;

    if ( Msg == "" )
	return;
  }

  if (!ClassIsChildOf(MessageClass, class'DeathMessagePlus') && MsgType != 'DeathMessage'  && !ClassIsChildOf(MessageClass, class'MultiKillMessage'))
  {
    for (i=0; i<4; i++)
	{
      if ( ChatMessageQueue[i].Message == None )
      {
// Add the message here //
        ChatMessageQueue[i].Message = MessageClass;
        ChatMessageQueue[i].Switch = 0;
		ChatMessageQueue[i].RelatedPRI = PRI;
		ChatMessageQueue[i].OptionalObject = None;
		ChatMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;

        if ( MessageClass.Default.bComplexString )
		ChatMessageQueue[i].StringMessage = Msg;
		else
		ChatMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
	  return;
	  }
	}

// No empty slots.  Force a message out //
	for (i=0; i<3; i++)
	CopyMessage(ChatMessageQueue[i],ChatMessageQueue[i+1]);
    ChatMessageQueue[3].Message = MessageClass;
	ChatMessageQueue[3].Switch = 0;
	ChatMessageQueue[3].RelatedPRI = PRI;
	ChatMessageQueue[3].OptionalObject = None;
	ChatMessageQueue[3].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;

    if ( MessageClass.Default.bComplexString )
	ChatMessageQueue[3].StringMessage = Msg;
	else
	ChatMessageQueue[3].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
  }
  else
  {
    for (i=0; i<KILLFEED_LINES; i++)
	{
	  if ( KillMessageQueue[i].Message == None )
        {
// Add the message here //
          KillMessageQueue[i].Message = MessageClass;
          KillMessageQueue[i].Switch = 0;
          KillMessageQueue[i].RelatedPRI = PRI;
          KillMessageQueue[i].OptionalObject = None;
          KillMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds+KILLFEED_EXTRA_LIFETIME;

          if ( MessageClass.Default.bComplexString )
          KillMessageQueue[i].StringMessage = Msg$MessageClass;
          else
          KillMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
        return;
		}
	}
// No empty slots.  Force a message out //
	for (i=0; i<KILLFEED_LINES-1; i++)
    CopyMessage(KillMessageQueue[i],KillMessageQueue[i+1]);
    KillMessageQueue[KILLFEED_LINES-1].Message = MessageClass;
	KillMessageQueue[KILLFEED_LINES-1].Switch = 0;
	KillMessageQueue[KILLFEED_LINES-1].RelatedPRI = PRI;
	KillMessageQueue[KILLFEED_LINES-1].OptionalObject = None;
	KillMessageQueue[KILLFEED_LINES-1].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds+KILLFEED_EXTRA_LIFETIME;

    if ( MessageClass.Default.bComplexString )
	KillMessageQueue[KILLFEED_LINES-1].StringMessage = Msg;
	else
	KillMessageQueue[KILLFEED_LINES-1].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
  }
}

function DrawKillFeed(Canvas canvas)
{
  local float XL, YL, YPos;
  local int i, j, k;

// Master message short queue control loop //
  if ( class'OverlaySettings'.default.iFontSizeKF == 2)
    Canvas.Font = Font469_20;
  else if ( class'OverlaySettings'.default.iFontSizeKF == 1)
    Canvas.Font = Font469_18;
  else if ( class'OverlaySettings'.default.iFontSizeKF == 0)
    Canvas.Font = Font469_16;

  Canvas.StrLen("TEST", XL, YL);
  YPos = 0;

  for (i=0; i<KILLFEED_LINES-1; i++)
  {
    if ( KillMessageQueue[i].Message != None )
    {
      j++;
      if ( bResChanged || (KillMessageQueue[i].XL == 0) )
      {
        if ( KillMessageQueue[i].Message.Default.bComplexString )
        Canvas.StrLen(KillMessageQueue[i].Message.Static.AssembleString(self, KillMessageQueue[i].Switch, KillMessageQueue[i].RelatedPRI, KillMessageQueue[i].StringMessage), KillMessageQueue[i].XL, KillMessageQueue[i].YL);
	    else
	    Canvas.StrLen(KillMessageQueue[i].StringMessage, KillMessageQueue[i].XL, KillMessageQueue[i].YL);

        Canvas.StrLen("TEST", XL, YL);
		KillMessageQueue[i].numLines = 1;

        if ( KillMessageQueue[i].YL > YL )
		{
		  KillMessageQueue[i].numLines++;

          for (k=2; k<KILLFEED_LINES-i; k++)
		  {
		    if (KillMessageQueue[i].YL > YL*k)
			KillMessageQueue[i].numLines++;
		  }
		}
	  }
// Keep track of the amount of lines a message overflows, to offset the next message with //
	  YPos += KillMessageQueue[i].numLines;
	  if ( YPos > KILLFEED_LINES )
	  break;

      if ( KillMessageQueue[i].Message.Default.bComplexString )
	  {
// Use this for string messages with multiple colors //
        KillMessageQueue[i].Message.Static.RenderComplexMessage(Canvas, KillMessageQueue[i].XL,  YL, KillMessageQueue[i].StringMessage, KillMessageQueue[i].Switch, KillMessageQueue[i].RelatedPRI, None, KillMessageQueue[i].OptionalObject);
      }
      else
      {
          Canvas.DrawColor = SetColor(255,255,255);
          DrawTextRight(canvas, KillMessageQueue[i].StringMessage, Canvas.ClipX-6, 2 + YL * (YPos-1) );
      }
    }
  }
}

function DrawChat(Canvas Canvas)
{
  local float OldOriginX;
  local float XL, YL, YPos;
  local int i, j, k;

  OldOriginX = Canvas.OrgX;

// Master message short queue control loop //
  if ( class'OverlaySettings'.default.iFontSizeChat == 2)
    Canvas.Font = Font469_20;
  else if ( class'OverlaySettings'.default.iFontSizeChat == 1)
    Canvas.Font = Font469_18;
  else if ( class'OverlaySettings'.default.iFontSizeChat == 0)
    Canvas.Font = Font469_16;

  Canvas.StrLen("TEST", XL, YL);
  Canvas.SetClip(768*Scale - 10, Canvas.ClipY);
  bDrawFaceArea = false;

  for (i=0; i<4; i++)
  {
    if ( ChatMessageQueue[i].Message != None )
    {
      j++;
      if ( bResChanged || (ChatMessageQueue[i].XL == 0) )
      {
        if ( ChatMessageQueue[i].Message.Default.bComplexString )
        Canvas.StrLen(ChatMessageQueue[i].Message.Static.AssembleString(self, ChatMessageQueue[i].Switch, ChatMessageQueue[i].RelatedPRI, ChatMessageQueue[i].StringMessage), ChatMessageQueue[i].XL, ChatMessageQueue[i].YL);
	    else
        Canvas.StrLen(ChatMessageQueue[i].StringMessage, ChatMessageQueue[i].XL, ChatMessageQueue[i].YL);

        Canvas.StrLen("TEST", XL, YL);
		ChatMessageQueue[i].numLines = 1;
		if ( ChatMessageQueue[i].YL > YL )
		{
		  ChatMessageQueue[i].numLines++;
		  for (k=2; k<4-i; k++)
		  {
		  if (ChatMessageQueue[i].YL > YL*k)
		  ChatMessageQueue[i].numLines++;
		  }
		}
	  }
// Keep track of the amount of lines a message overflows, to offset the next message with //
      Canvas.SetPos(6, 2 + YL * YPos);
      YPos += ChatMessageQueue[i].numLines;

      if ( YPos > 4 )
      break;

      if ( ChatMessageQueue[i].Message.Default.bComplexString )
	  {
// Use this for string messages with multiple colors //
        ChatMessageQueue[i].Message.Static.RenderComplexMessage(Canvas, ChatMessageQueue[i].XL,  YL, ChatMessageQueue[i].StringMessage, ChatMessageQueue[i].Switch, ChatMessageQueue[i].RelatedPRI, None, ChatMessageQueue[i].OptionalObject);
      }
	  else
	  {
	    Canvas.DrawColor = ChatMessageQueue[i].Message.Default.DrawColor;
		Canvas.DrawText(ChatMessageQueue[i].StringMessage, False);
	  }
	}
  }

  Canvas.DrawColor = WhiteColor;
  Canvas.SetClip(OldClipX, Canvas.ClipY);
  Canvas.SetOrigin(OldOriginX, Canvas.OrgY);
}

function DrawCenterMessages(Canvas Canvas)
{
  local int i, M;
  local float FadeValue;

  if ( !bHideCenterMessages )
  {
// Master localized message control loop //
    for (i=0; i<10; i++)
    {
      if (LocalMessages[i].Message != None)
      {
        if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
        {
          Canvas.Style = ERenderStyle.STY_Translucent;
          FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);

          if (FadeValue > 0.0)
          {
            if ( bResChanged || (LocalMessages[i].XL == 0) )
            {
              if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
              LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
              else
              LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );

              Canvas.Font = LocalMessages[i].StringFont;
              Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
              LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
            }

            Canvas.Font = LocalMessages[i].StringFont;
            Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
			Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
			Canvas.DrawText( LocalMessages[i].StringMessage, False );
		  }
		}

        else
        {
          if ( bResChanged || (LocalMessages[i].XL == 0) )
          {
            if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
            LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
            else
            LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );

            Canvas.Font = LocalMessages[i].StringFont;
            Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
            LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
          }

          Canvas.Font = LocalMessages[i].StringFont;
          Canvas.Style = ERenderStyle.STY_Normal;
          Canvas.DrawColor = LocalMessages[i].DrawColor;
          Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
          Canvas.DrawText( LocalMessages[i].StringMessage, False );
        }
      }
    }

    if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) )
    {
      if ( TimeMessageClass == None )
      TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

      if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300) && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
	  {
	    LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;

        if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
        {
          bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );

          if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
          TellTime(5);
          else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
          TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
        }

        else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
        {
          M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
          TellTime(5 - M);
        }
      }
    }
  }
  Canvas.Style = ERenderStyle.STY_Normal;
}

simulated function DrawArmor(Canvas Canvas)
{
  local int ArmorAmount, CurAbs, i, thxepic;
  local PlayerReplicationInfo PRI;
  local ENetRole oldrole;
  local inventory Inv, BestArmor;
  local bool bShieldbelt, bThighArmor, bChestArmor;
  local float ChestAmount, ThighAmount;

  thxepic = -1;

  foreach Level.AllActors (class 'PlayerReplicationInfo', PRI)
  {
    if ( InStr(CAPS(PRI.class), "BBPLAYERREPLICATIONINFO") == -1 )
    continue;

    if ( PawnOwner != PRI.Owner )
    continue;

    oldrole = PRI.Role;
    PRI.Role = ROLE_Authority;
    thxepic = int(PRI.GetPropertyText("Armor"));
    savedArmor = thxepic;
    PRI.Role = oldrole;
  }

  if (thxepic != -1 )
  {
    if ( gotShieldBelt(PawnOwner) )
    Canvas.DrawColor = SetColor(255, 200, 0);

    DrawBigNum(Canvas, Min(150, thxepic), Canvas.ClipX * 0.5 + (128 * 0.35 * 2) * Scale, Canvas.ClipY * 1 - 94 * Scale, 1.75);
  }
  else
  {
    ArmorAmount = 0;
    CurAbs = 0;
    i = 0;
    BestArmor=None;

    for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
      if (Inv.bIsAnArmor)
      {
      if ( Inv.IsA('UT_Shieldbelt') )
      bShieldbelt = true;
      else if ( Inv.IsA('Thighpads') )
      {
        ThighAmount += Inv.Charge;
        bThighArmor = true;
      }
      else
      {
        bChestArmor = true;
        ChestAmount += Inv.Charge;
      }
      ArmorAmount += Inv.Charge;
      }
      else
      {
        i++;
        if ( i > 100 )
        break;
      }
    }

    if ( bShieldBelt )
    Canvas.DrawColor = SetColor(255, 200, 0);

    DrawBigNum(Canvas, Min(150,ArmorAmount), Canvas.ClipX * 0.5 + (128 * 0.35 * 2) * Scale, Canvas.ClipY * 1 - 94 * Scale, 1.75);
    savedArmor=ArmorAmount;
  }
}

function DrawItemTimer (Canvas canvas) // based on the item timer from UTV by Fnordia and SJ //
{
  local Inventory p;
  local string n;
  local int i, j, CurY;
  //local byte Team;
  //local float Distance;

  bHidden = true;

  CurY = Canvas.ClipY * 0.5;
  Canvas.Font = Font469_32;

  foreach Level.allactors (class 'Inventory', p)
  {
    if (p.IsA('UDamage'))
    {
      n = "AMP";
      if (!class'OverlaySettings'.default.bShowAmp)
        n = "none";
    }
    else if (p.IsA('UT_ShieldBelt'))
    {
      n = "SHIELD";
      if (!class'OverlaySettings'.default.bShowShield)
        n = "none";
    }
    else if (p.IsA('HealthPack'))
    {
      n = "KEG";
      if (!class'OverlaySettings'.default.bShowKeg)
        n = "none";
    }
    else if (p.IsA('Armor2'))
    {
      n = "ARMOR";
      if (!class'OverlaySettings'.default.bShowArmor)
        n = "none";
    }
    else if (p.IsA('ThighPads'))
    {
      n = "PADS";
      if (!class'OverlaySettings'.default.bShowPads)
        n = "none";
    }
    else if (p.IsA('UT_Jumpboots'))
    {
      n = "BOOTS";
      if (!class'OverlaySettings'.default.bShowBoots)
        n = "none";
    }
    else
    {
      n = "none";
    }

    if (n == "none")
    continue;
    if (p.bHeldItem || (p.owner != none))
    continue;
    if (p.bHidden)
    {
      if (!(ptimes [i].inited))
      {
        ptimes [i].timeleft = p.RespawnTime;
        ptimes [i].inited = true;
      }
      ptimes [i].timeleft -= (gametime - lasttime);
    }
    else
    {
      ptimes [i].inited = false;
      ptimes [i].timeleft = p.RespawnTime;
    }

    if (ptimes[i].timeleft < 0 )
    ptimes[i].timeleft = p.respawntime;

    if (n == "SHIELD")
    {
      Canvas.DrawColor = SetColor(4, 4, 4);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.SetPos(Canvas.ClipX * 1 - 125 * (Scale*1.25), CurY);
      Canvas.DrawRect(Texture'white_1x1', 125 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(255, 200, 0);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 133 * (Scale*1.25) , CurY);
      Canvas.DrawRect(Texture'white_1x1', 8 * (Scale*1.25), 50 * (Scale*1.25));

      /*if ( BeltCount > 1 && !IsInWarmup() )
      {
        returnClosestTeamPointAndDistance(P,Team,Distance);

        if (Team == 0)
        {
          Canvas.DrawColor = SetColor(128, 0, 0);
        }
        else
        {
          Canvas.DrawColor = SetColor(0, 0, 168);
        }
      }
      else
      Canvas.DrawColor = SetColor(255, 255, 255);*/

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.SetPos(Canvas.ClipX * 1 - 116 * (Scale*1.25), CurY + 9 * (Scale*1.25));
    Canvas.DrawTile(Texture'belt_icon', 32 * (Scale*1.25), 32 * (Scale*1.25), 0, 0, 128, 128);
    }

    if (n == "AMP")
    {
      Canvas.DrawColor = SetColor(4, 4, 4);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.SetPos(Canvas.ClipX * 1 - 125 * (Scale*1.25), CurY);
      Canvas.DrawRect(Texture'white_1x1', 125 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(58, 24, 84);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 133 * (Scale*1.25) , CurY);
      Canvas.DrawRect(Texture'white_1x1', 8 * (Scale*1.25), 50 * (Scale*1.25));

      /*if (AmpCount > 1 && !IsInWarmup() )
      {
        returnClosestTeamPointAndDistance(P,Team,Distance);
          if (Team == 0)
          {
          Canvas.DrawColor = SetColor(128, 0, 0);
          }
          else
          {
          Canvas.DrawColor = SetColor(0, 0, 168);
          }
      }
      else
      Canvas.DrawColor = SetColor(255, 255, 255);*/

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.SetPos(Canvas.ClipX * 1 - 116 * (Scale*1.25), CurY + 9 * (Scale*1.25));
    Canvas.DrawTile(Texture'amp_icon', 32 * (Scale*1.25), 32 * (Scale*1.25), 0, 0, 128, 128);
    }

    if (n == "KEG")
    {
      Canvas.DrawColor = SetColor(4, 4, 4);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.SetPos(Canvas.ClipX * 1 - 125 * (Scale*1.25), CurY);
      Canvas.DrawRect(Texture'white_1x1', 125 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(255, 100, 100);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 133 * (Scale*1.25) , CurY);
      Canvas.DrawRect(Texture'white_1x1', 8 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(255, 255, 255);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 116 * (Scale*1.25), CurY + 9 * (Scale*1.25));
      Canvas.DrawTile(Texture'health_icon', 32 * (Scale*1.25), 32 * (Scale*1.25), 0, 0, 128, 128);
    }

    if (n == "ARMOR")
    {
      Canvas.DrawColor = SetColor(4, 4, 4);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.SetPos(Canvas.ClipX * 1 - 125 * (Scale*1.25), CurY);
      Canvas.DrawRect(Texture'white_1x1', 125 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(200, 200, 200);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 133 * (Scale*1.25) , CurY);
      Canvas.DrawRect(Texture'white_1x1', 8 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(255, 255, 255);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 116 * (Scale*1.25), CurY + 9 * (Scale*1.25));
      Canvas.DrawTile(Texture'armor_icon', 32 * (Scale*1.25), 32 * (Scale*1.25), 0, 0, 128, 128);
    }

    if (n == "PADS")
    {
      Canvas.DrawColor = SetColor(4, 4, 4);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.SetPos(Canvas.ClipX * 1 - 125 * (Scale*1.25), CurY);
      Canvas.DrawRect(Texture'white_1x1', 125 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(200, 200, 200);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 133 * (Scale*1.25) , CurY);
      Canvas.DrawRect(Texture'white_1x1', 8 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(255, 255, 255);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 116 * (Scale*1.25), CurY + 9 * (Scale*1.25));
      Canvas.DrawTile(Texture'pads_icon', 32 * (Scale*1.25), 32 * (Scale*1.25), 0, 0, 128, 128);
    }

    if (n == "BOOTS")
    {
      Canvas.DrawColor = SetColor(4, 4, 4);
      Canvas.Style = ERenderStyle.STY_Translucent;
      Canvas.SetPos(Canvas.ClipX * 1 - 125 * (Scale*1.25), CurY);
      Canvas.DrawRect(Texture'white_1x1', 125 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(140, 140, 140);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 133 * (Scale*1.25) , CurY);
      Canvas.DrawRect(Texture'white_1x1', 8 * (Scale*1.25), 50 * (Scale*1.25));

      Canvas.DrawColor = SetColor(255, 255, 255);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos(Canvas.ClipX * 1 - 116 * (Scale*1.25), CurY + 9 * (Scale*1.25));
      Canvas.DrawTile(Texture'boots_icon', 32 * (Scale*1.25), 32 * (Scale*1.25), 0, 0, 128, 128);
    }

  Canvas.Style = ERenderStyle.STY_Normal;
  Canvas.DrawColor = SetColor(255, 255, 255);

  j = ptimes [i].timeleft / level.timedilation;

  if (ptimes [i].inited)
  {
  DrawTextRight(canvas, string(j), Canvas.ClipX * 1 - 18 * (Scale*1.25), CurY + 8 * (Scale*1.25));
  }
  else
  {
  DrawTextRight(canvas, "UP", Canvas.ClipX * 1 - 18 * (Scale*1.25), CurY + 8 * (Scale*1.25));
  }

  i++;

  CurY += 54 * (Scale*1.25);
  }
  lasttime = gametime;
}
// 

function DrawTextLeft(Canvas Canvas,string text, int X, int Y,optional bool hidezeros,optional bool dropshadow)
{
  local color oldcolor;
  local int oldstyle;

  oldcolor = canvas.drawcolor;
  oldstyle = canvas.style;

  if (dropshadow)
  {
    Canvas.Style = 1;
    Canvas.DrawColor = SetColor(0,0,0);
	Canvas.SetPos(X-1,Y-1);

    if (hidezeros)
    {
      if (Text != "0" && Text != "0%")
      Canvas.DrawText(Text);
    }
    else
    Canvas.DrawText(text);
    Canvas.DrawColor = oldcolor;
    Canvas.Style = oldstyle;
  }

  Canvas.SetPos(X, Y);

  if (hidezeros)
  {
    if (Text != "0" && Text != "0%")
    Canvas.DrawText(Text);
  }
  else
  Canvas.DrawText(text);
}

function DrawTextRight(Canvas Canvas,string text, int X, int Y)
{
  local float w,h;

  Canvas.StrLen(text, w, h);
  Canvas.SetPos(X-w, Y);
  Canvas.DrawText(text);
}

function color SetColor( byte Red, byte Green, byte Blue, optional float Alpha )
{
  local color MyColor;

  if (Alpha == 0.0)
  Alpha = 1;

  MyColor.R = Red * Alpha;
  MyColor.G = Green *  Alpha;
  MyColor.B = Blue * Alpha;
  MyColor.A = 0;

  Return MyColor;
}

simulated function DrawDigit(Canvas Canvas, int d, int Step, float UpScale, out byte bMinus )
{
  if ( bMinus == 1 )
  {
    Canvas.CurX -= Step;
    Canvas.DrawIcon(Texture'NumDash', UpScale);
    bMinus = 0;
  }
  if ( d == 1 )
  Canvas.CurX -= 0.5 * Step;
  Canvas.DrawIcon(BigNums[d], UpScale);
}

function string shortenName(string PlayerName, int NoChars,optional float MaxPixel)
{
local float XL,YL;

  if (MaxPixel != 0)
  {
    do
    {
      CanvasX.StrLen(Left(PlayerName,NoChars), XL, YL);
      NoChars--;
    }
    until(XL < MaxPixel);
  }


  if (Len(PlayerName) > NoChars)
  return Left(PlayerName,NoChars)$"..";
  else
  return PlayerName;
}

defaultproperties
{
      BigNums(0)=Texture'OV4DOM.Icons.NumZero'
      BigNums(1)=Texture'OV4DOM.Icons.NumOne'
      BigNums(2)=Texture'OV4DOM.Icons.NumTwo'
      BigNums(3)=Texture'OV4DOM.Icons.NumThree'
      BigNums(4)=Texture'OV4DOM.Icons.NumFour'
      BigNums(5)=Texture'OV4DOM.Icons.NumFive'
      BigNums(6)=Texture'OV4DOM.Icons.NumSix'
      BigNums(7)=Texture'OV4DOM.Icons.NumSeven'
      BigNums(8)=Texture'OV4DOM.Icons.NumEight'
      BigNums(9)=Texture'OV4DOM.Icons.NumNine'
      StartTime=0
      Overtime=0
      AmpCount=0
      BeltCount=0
      savedArmor=0
      IdentifiedID=0
      SavedPitch=0
      LockTimer=0
      AutoAdjustCamDelay=0
      MaxDist=0
      gametime=0.000000
      lasttime=0.000000
      HealthBlink=0.000000
      b3rdPersonRotationLock=False
      bHadWarmup=False
      HealthBlinkUp=False
      bHideID=False
      LastLogTime=0.000000
      RedScoreHistory(0)=32
      RedScoreHistory(1)=33
      RedScoreHistory(2)=35
      RedScoreHistory(3)=37
      RedScoreHistory(4)=38
      RedScoreHistory(5)=39
      RedScoreHistory(6)=40
      RedScoreHistory(7)=42
      RedScoreHistory(8)=43
      RedScoreHistory(9)=44
      RedScoreHistory(10)=45
      RedScoreHistory(11)=47
      RedScoreHistory(12)=48
      RedScoreHistory(13)=48
      RedScoreHistory(14)=49
      RedScoreHistory(15)=50
      RedScoreHistory(16)=51
      RedScoreHistory(17)=52
      RedScoreHistory(18)=52
      RedScoreHistory(19)=53
      RedScoreHistory(20)=53
      RedScoreHistory(21)=54
      RedScoreHistory(22)=55
      RedScoreHistory(23)=57
      RedScoreHistory(24)=59
      RedScoreHistory(25)=60
      RedScoreHistory(26)=60
      RedScoreHistory(27)=61
      RedScoreHistory(28)=62
      RedScoreHistory(29)=64
      RedScoreHistory(30)=66
      RedScoreHistory(31)=69
      RedScoreHistory(32)=71
      RedScoreHistory(33)=72
      RedScoreHistory(34)=74
      RedScoreHistory(35)=76
      RedScoreHistory(36)=0
      RedScoreHistory(37)=0
      RedScoreHistory(38)=0
      RedScoreHistory(39)=0
      RedScoreHistory(40)=0
      RedScoreHistory(41)=0
      RedScoreHistory(42)=0
      RedScoreHistory(43)=0
      RedScoreHistory(44)=0
      RedScoreHistory(45)=0
      RedScoreHistory(46)=0
      RedScoreHistory(47)=0
      RedScoreHistory(48)=0
      RedScoreHistory(49)=0
      RedScoreHistory(50)=0
      RedScoreHistory(51)=0
      RedScoreHistory(52)=0
      RedScoreHistory(53)=0
      RedScoreHistory(54)=0
      RedScoreHistory(55)=0
      RedScoreHistory(56)=0
      RedScoreHistory(57)=0
      RedScoreHistory(58)=0
      RedScoreHistory(59)=0
      RedScoreHistory(60)=0
      RedScoreHistory(61)=0
      RedScoreHistory(62)=0
      RedScoreHistory(63)=0
      RedScoreHistory(64)=0
      RedScoreHistory(65)=0
      RedScoreHistory(66)=0
      RedScoreHistory(67)=0
      RedScoreHistory(68)=0
      RedScoreHistory(69)=0
      RedScoreHistory(70)=0
      RedScoreHistory(71)=0
      RedScoreHistory(72)=0
      RedScoreHistory(73)=0
      RedScoreHistory(74)=0
      RedScoreHistory(75)=0
      RedScoreHistory(76)=0
      RedScoreHistory(77)=0
      RedScoreHistory(78)=0
      RedScoreHistory(79)=0
      RedScoreHistory(80)=0
      RedScoreHistory(81)=0
      RedScoreHistory(82)=0
      RedScoreHistory(83)=0
      RedScoreHistory(84)=0
      RedScoreHistory(85)=0
      RedScoreHistory(86)=0
      RedScoreHistory(87)=0
      RedScoreHistory(88)=0
      RedScoreHistory(89)=0
      RedScoreHistory(90)=0
      RedScoreHistory(91)=0
      RedScoreHistory(92)=0
      RedScoreHistory(93)=0
      RedScoreHistory(94)=0
      RedScoreHistory(95)=0
      RedScoreHistory(96)=0
      RedScoreHistory(97)=0
      RedScoreHistory(98)=0
      RedScoreHistory(99)=0
      RedScoreHistory(100)=0
      RedScoreHistory(101)=0
      RedScoreHistory(102)=0
      RedScoreHistory(103)=0
      RedScoreHistory(104)=0
      RedScoreHistory(105)=0
      RedScoreHistory(106)=0
      RedScoreHistory(107)=0
      RedScoreHistory(108)=0
      RedScoreHistory(109)=0
      RedScoreHistory(110)=0
      RedScoreHistory(111)=0
      RedScoreHistory(112)=0
      RedScoreHistory(113)=0
      RedScoreHistory(114)=0
      RedScoreHistory(115)=0
      RedScoreHistory(116)=0
      RedScoreHistory(117)=0
      RedScoreHistory(118)=0
      RedScoreHistory(119)=0
      RedScoreHistory(120)=0
      RedScoreHistory(121)=0
      RedScoreHistory(122)=0
      RedScoreHistory(123)=0
      RedScoreHistory(124)=0
      RedScoreHistory(125)=0
      RedScoreHistory(126)=0
      RedScoreHistory(127)=0
      RedScoreHistory(128)=0
      RedScoreHistory(129)=0
      RedScoreHistory(130)=0
      RedScoreHistory(131)=0
      RedScoreHistory(132)=0
      RedScoreHistory(133)=0
      RedScoreHistory(134)=0
      RedScoreHistory(135)=0
      RedScoreHistory(136)=0
      RedScoreHistory(137)=0
      RedScoreHistory(138)=0
      RedScoreHistory(139)=0
      RedScoreHistory(140)=0
      RedScoreHistory(141)=0
      RedScoreHistory(142)=0
      RedScoreHistory(143)=0
      RedScoreHistory(144)=0
      RedScoreHistory(145)=0
      RedScoreHistory(146)=0
      RedScoreHistory(147)=0
      RedScoreHistory(148)=0
      RedScoreHistory(149)=0
      RedScoreHistory(150)=0
      RedScoreHistory(151)=0
      RedScoreHistory(152)=0
      RedScoreHistory(153)=0
      RedScoreHistory(154)=0
      RedScoreHistory(155)=0
      RedScoreHistory(156)=0
      RedScoreHistory(157)=0
      RedScoreHistory(158)=0
      RedScoreHistory(159)=0
      RedScoreHistory(160)=0
      RedScoreHistory(161)=0
      RedScoreHistory(162)=0
      RedScoreHistory(163)=0
      RedScoreHistory(164)=0
      RedScoreHistory(165)=0
      RedScoreHistory(166)=0
      RedScoreHistory(167)=0
      RedScoreHistory(168)=0
      RedScoreHistory(169)=0
      RedScoreHistory(170)=0
      RedScoreHistory(171)=0
      RedScoreHistory(172)=0
      RedScoreHistory(173)=0
      RedScoreHistory(174)=0
      RedScoreHistory(175)=0
      RedScoreHistory(176)=0
      RedScoreHistory(177)=0
      RedScoreHistory(178)=0
      RedScoreHistory(179)=0
      RedScoreHistory(180)=0
      RedScoreHistory(181)=0
      RedScoreHistory(182)=0
      RedScoreHistory(183)=0
      RedScoreHistory(184)=0
      RedScoreHistory(185)=0
      RedScoreHistory(186)=0
      RedScoreHistory(187)=0
      RedScoreHistory(188)=0
      RedScoreHistory(189)=0
      RedScoreHistory(190)=0
      RedScoreHistory(191)=0
      RedScoreHistory(192)=0
      RedScoreHistory(193)=0
      RedScoreHistory(194)=0
      RedScoreHistory(195)=0
      RedScoreHistory(196)=0
      RedScoreHistory(197)=0
      RedScoreHistory(198)=0
      RedScoreHistory(199)=0
      BlueScoreHistory(0)=19
      BlueScoreHistory(1)=21
      BlueScoreHistory(2)=22
      BlueScoreHistory(3)=23
      BlueScoreHistory(4)=25
      BlueScoreHistory(5)=27
      BlueScoreHistory(6)=28
      BlueScoreHistory(7)=29
      BlueScoreHistory(8)=31
      BlueScoreHistory(9)=33
      BlueScoreHistory(10)=34
      BlueScoreHistory(11)=35
      BlueScoreHistory(12)=36
      BlueScoreHistory(13)=38
      BlueScoreHistory(14)=40
      BlueScoreHistory(15)=42
      BlueScoreHistory(16)=45
      BlueScoreHistory(17)=46
      BlueScoreHistory(18)=48
      BlueScoreHistory(19)=50
      BlueScoreHistory(20)=52
      BlueScoreHistory(21)=54
      BlueScoreHistory(22)=56
      BlueScoreHistory(23)=57
      BlueScoreHistory(24)=58
      BlueScoreHistory(25)=60
      BlueScoreHistory(26)=61
      BlueScoreHistory(27)=63
      BlueScoreHistory(28)=65
      BlueScoreHistory(29)=66
      BlueScoreHistory(30)=67
      BlueScoreHistory(31)=67
      BlueScoreHistory(32)=68
      BlueScoreHistory(33)=69
      BlueScoreHistory(34)=70
      BlueScoreHistory(35)=71
      BlueScoreHistory(36)=0
      BlueScoreHistory(37)=0
      BlueScoreHistory(38)=0
      BlueScoreHistory(39)=0
      BlueScoreHistory(40)=0
      BlueScoreHistory(41)=0
      BlueScoreHistory(42)=0
      BlueScoreHistory(43)=0
      BlueScoreHistory(44)=0
      BlueScoreHistory(45)=0
      BlueScoreHistory(46)=0
      BlueScoreHistory(47)=0
      BlueScoreHistory(48)=0
      BlueScoreHistory(49)=0
      BlueScoreHistory(50)=0
      BlueScoreHistory(51)=0
      BlueScoreHistory(52)=0
      BlueScoreHistory(53)=0
      BlueScoreHistory(54)=0
      BlueScoreHistory(55)=0
      BlueScoreHistory(56)=0
      BlueScoreHistory(57)=0
      BlueScoreHistory(58)=0
      BlueScoreHistory(59)=0
      BlueScoreHistory(60)=0
      BlueScoreHistory(61)=0
      BlueScoreHistory(62)=0
      BlueScoreHistory(63)=0
      BlueScoreHistory(64)=0
      BlueScoreHistory(65)=0
      BlueScoreHistory(66)=0
      BlueScoreHistory(67)=0
      BlueScoreHistory(68)=0
      BlueScoreHistory(69)=0
      BlueScoreHistory(70)=0
      BlueScoreHistory(71)=0
      BlueScoreHistory(72)=0
      BlueScoreHistory(73)=0
      BlueScoreHistory(74)=0
      BlueScoreHistory(75)=0
      BlueScoreHistory(76)=0
      BlueScoreHistory(77)=0
      BlueScoreHistory(78)=0
      BlueScoreHistory(79)=0
      BlueScoreHistory(80)=0
      BlueScoreHistory(81)=0
      BlueScoreHistory(82)=0
      BlueScoreHistory(83)=0
      BlueScoreHistory(84)=0
      BlueScoreHistory(85)=0
      BlueScoreHistory(86)=0
      BlueScoreHistory(87)=0
      BlueScoreHistory(88)=0
      BlueScoreHistory(89)=0
      BlueScoreHistory(90)=0
      BlueScoreHistory(91)=0
      BlueScoreHistory(92)=0
      BlueScoreHistory(93)=0
      BlueScoreHistory(94)=0
      BlueScoreHistory(95)=0
      BlueScoreHistory(96)=0
      BlueScoreHistory(97)=0
      BlueScoreHistory(98)=0
      BlueScoreHistory(99)=0
      BlueScoreHistory(100)=0
      BlueScoreHistory(101)=0
      BlueScoreHistory(102)=0
      BlueScoreHistory(103)=0
      BlueScoreHistory(104)=0
      BlueScoreHistory(105)=0
      BlueScoreHistory(106)=0
      BlueScoreHistory(107)=0
      BlueScoreHistory(108)=0
      BlueScoreHistory(109)=0
      BlueScoreHistory(110)=0
      BlueScoreHistory(111)=0
      BlueScoreHistory(112)=0
      BlueScoreHistory(113)=0
      BlueScoreHistory(114)=0
      BlueScoreHistory(115)=0
      BlueScoreHistory(116)=0
      BlueScoreHistory(117)=0
      BlueScoreHistory(118)=0
      BlueScoreHistory(119)=0
      BlueScoreHistory(120)=0
      BlueScoreHistory(121)=0
      BlueScoreHistory(122)=0
      BlueScoreHistory(123)=0
      BlueScoreHistory(124)=0
      BlueScoreHistory(125)=0
      BlueScoreHistory(126)=0
      BlueScoreHistory(127)=0
      BlueScoreHistory(128)=0
      BlueScoreHistory(129)=0
      BlueScoreHistory(130)=0
      BlueScoreHistory(131)=0
      BlueScoreHistory(132)=0
      BlueScoreHistory(133)=0
      BlueScoreHistory(134)=0
      BlueScoreHistory(135)=0
      BlueScoreHistory(136)=0
      BlueScoreHistory(137)=0
      BlueScoreHistory(138)=0
      BlueScoreHistory(139)=0
      BlueScoreHistory(140)=0
      BlueScoreHistory(141)=0
      BlueScoreHistory(142)=0
      BlueScoreHistory(143)=0
      BlueScoreHistory(144)=0
      BlueScoreHistory(145)=0
      BlueScoreHistory(146)=0
      BlueScoreHistory(147)=0
      BlueScoreHistory(148)=0
      BlueScoreHistory(149)=0
      BlueScoreHistory(150)=0
      BlueScoreHistory(151)=0
      BlueScoreHistory(152)=0
      BlueScoreHistory(153)=0
      BlueScoreHistory(154)=0
      BlueScoreHistory(155)=0
      BlueScoreHistory(156)=0
      BlueScoreHistory(157)=0
      BlueScoreHistory(158)=0
      BlueScoreHistory(159)=0
      BlueScoreHistory(160)=0
      BlueScoreHistory(161)=0
      BlueScoreHistory(162)=0
      BlueScoreHistory(163)=0
      BlueScoreHistory(164)=0
      BlueScoreHistory(165)=0
      BlueScoreHistory(166)=0
      BlueScoreHistory(167)=0
      BlueScoreHistory(168)=0
      BlueScoreHistory(169)=0
      BlueScoreHistory(170)=0
      BlueScoreHistory(171)=0
      BlueScoreHistory(172)=0
      BlueScoreHistory(173)=0
      BlueScoreHistory(174)=0
      BlueScoreHistory(175)=0
      BlueScoreHistory(176)=0
      BlueScoreHistory(177)=0
      BlueScoreHistory(178)=0
      BlueScoreHistory(179)=0
      BlueScoreHistory(180)=0
      BlueScoreHistory(181)=0
      BlueScoreHistory(182)=0
      BlueScoreHistory(183)=0
      BlueScoreHistory(184)=0
      BlueScoreHistory(185)=0
      BlueScoreHistory(186)=0
      BlueScoreHistory(187)=0
      BlueScoreHistory(188)=0
      BlueScoreHistory(189)=0
      BlueScoreHistory(190)=0
      BlueScoreHistory(191)=0
      BlueScoreHistory(192)=0
      BlueScoreHistory(193)=0
      BlueScoreHistory(194)=0
      BlueScoreHistory(195)=0
      BlueScoreHistory(196)=0
      BlueScoreHistory(197)=0
      BlueScoreHistory(198)=0
      BlueScoreHistory(199)=0
      HistoryCount=36
      CurrentMapName="Cryptic"
      PointStats(0)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(1)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(2)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(3)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(4)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(5)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(6)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(7)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(8)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(9)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(10)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(11)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(12)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(13)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(14)=(RedTime=0.000000,BlueTime=0.000000)
      PointStats(15)=(RedTime=0.000000,BlueTime=0.000000)
      NumPoints=0
      ptimes(0)=(timeleft=0.000000,inited=False)
      ptimes(1)=(timeleft=0.000000,inited=False)
      ptimes(2)=(timeleft=0.000000,inited=False)
      ptimes(3)=(timeleft=0.000000,inited=False)
      ptimes(4)=(timeleft=0.000000,inited=False)
      ptimes(5)=(timeleft=0.000000,inited=False)
      ptimes(6)=(timeleft=0.000000,inited=False)
      ptimes(7)=(timeleft=0.000000,inited=False)
      ptimes(8)=(timeleft=0.000000,inited=False)
      ptimes(9)=(timeleft=0.000000,inited=False)
      Amp=None
      BELT=None
      OS=None
      DomSource=None
      KillMessageQueue(0)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(1)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(2)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(3)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(4)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(5)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(6)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      KillMessageQueue(7)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      ChatMessageQueue(0)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      ChatMessageQueue(1)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      ChatMessageQueue(2)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      ChatMessageQueue(3)=(Message=None,Switch=0,RelatedPRI=None,OptionalObject=None,EndOfLife=0.000000,LifeTime=0.000000,bDrawing=False,numLines=0,StringMessage="",DrawColor=(R=0,G=0,B=0,A=0),StringFont=None,XL=0.000000,YL=0.000000,YPos=0.000000)
      CanvasX=None
      Font469_12=None
      Font469_12b=None
      Font469_16=None
      Font469_16b=None
      Font469_18=None
      Font469_18b=None
      Font469_20=None
      Font469_20b=None
      Font469_24=None
      Font469_24b=None
      Font469_26b=None
      Font469_28b=None
      Font469_32=None
      Font469_38b=None
      SavedScreen=0
}
