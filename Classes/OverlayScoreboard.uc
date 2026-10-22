class OverlayScoreboard extends Info;

var int redPlayerCount, bluePlayerCount;
var int RedMax,RedSecond;
var int BlueMax,BlueSecond;
var int SavedScreen;
var int LiveRedPoints[3];
var int LiveBluePoints[3];

var bool UTS_installed;

struct PlayerStats
{
  var int PlayerNumber;
  var string PlayerName;
  var int Frags;
  var int Kills;
  var int Deaths;
  var int Suicides;
  var int Efficiency;
  var int Score;
  var bool gotAmp;
  var PlayerReplicationInfo PRI;
  var Pawn PlayerOwner;
  var int PointScores[6]; 
  var int TotalPoints; 
};

var PlayerStats RedPlayer[4];
var PlayerStats BluePlayer[4];
var OverlayHUD OH;
var Canvas CanvasX;
var FontInfo MyFonts;
var Font  Font469_12b, Font469_16, Font469_16b, Font469_18b, Font469_12, Font469_18, Font469_20,Font469_20b,Font469_24b, Font469_24, Font469_26b, Font469_28b,Font469_32b, Font469_32,Font469_38b, Font469_38;

//////////////
// LET'S GO //
//////////////


function UpdateAndSort()
{
  local float TotalDomPoints;
  local int i, j;
  local ReplicationInfo RI;
  local PlayerReplicationInfo TargetPRI;
  local int cID;

  redPlayerCount = 0;
  bluePlayerCount = 0;
  cID = 0;

  foreach Level.AllActors(class'ReplicationInfo', RI)
  {
    if (InStr(string(RI.Class), "SmarterDOMPRI") == -1)
        continue;


    TargetPRI = None;
    if (PlayerReplicationInfo(RI.Owner) != None)
        TargetPRI = PlayerReplicationInfo(RI.Owner);
    else if (Pawn(RI.Owner) != None)
        TargetPRI = Pawn(RI.Owner).PlayerReplicationInfo;
    else if (RI.Owner != None && PlayerReplicationInfo(RI.Owner.Owner) != None)
        TargetPRI = PlayerReplicationInfo(RI.Owner.Owner);

    if (TargetPRI != None && !TargetPRI.bIsSpectator && TargetPRI.Team != 255)
    {
        TotalDomPoints = 0;
        for (i = 0; i < 6; i++)
        {
            TotalDomPoints += SmarterDOMPRI(RI).PointScores[i];
        }
        
        UpdatePlayerStats(TargetPRI.Team, RI, TargetPRI, cID);
        
        cID++;
    }
  }

  // Red Max și Second 
  for (j = 0; j < redPlayerCount; j++)
  {
      if (redPlayer[j].Score > RedMax) {
          RedSecond = RedMax; 
          RedMax = redPlayer[j].Score;
      } else if (redPlayer[j].Score > RedSecond && redPlayer[j].Score < RedMax) {
          RedSecond = redPlayer[j].Score;
      }
  }

  for (j = 0; j < bluePlayerCount; j++)
  {
      if (bluePlayer[j].Score > BlueMax) {
          BlueSecond = BlueMax; 
          BlueMax = bluePlayer[j].Score;
      } else if (bluePlayer[j].Score > BlueSecond && bluePlayer[j].Score < BlueMax) {
          BlueSecond = bluePlayer[j].Score;
      }
  }

  SortScores(redPlayerCount, 0);
  SortScores(bluePlayerCount, 1);

  if (redPlayerCount > 0) RedMax = redPlayer[0].TotalPoints;
  if (redPlayerCount > 1) RedSecond = redPlayer[1].TotalPoints;

  if (bluePlayerCount > 0) BlueMax = bluePlayer[0].TotalPoints;
  if (bluePlayerCount > 1) BlueSecond = bluePlayer[1].TotalPoints;
}

function SortScores(int N, byte Team)
{
    local int i, j, Max;
    local PlayerStats TempStats;

    if (N <= 1) return; 

    for (i = 0; i < N - 1; i++)
    {
        Max = i;
        for (j = i + 1; j < N; j++)
        {
            if (Team == 0)
            {
                if (redPlayer[j].Score > redPlayer[Max].Score)
                    Max = j;
            }
            else
            {
                if (bluePlayer[j].Score > bluePlayer[Max].Score)
                    Max = j;
            }
        }
        if (Max != i)
        {
            if (Team == 0)
            {
                TempStats = redPlayer[Max];
                redPlayer[Max] = redPlayer[i];
                redPlayer[i] = TempStats;
            }
            else
            {
                TempStats = bluePlayer[Max];
                bluePlayer[Max] = bluePlayer[i];
                bluePlayer[i] = TempStats;
            }
        }
    }
}

// create usable player IDs //
function INT realPlayerID(int ID)
{
  local int j;

  for (j = 0; j < 4; j++)
    if (ID == redPlayer[j].PlayerNumber)
    return redPlayer[j].PRI.PlayerID;

  for (j = 0; j < 4; j++)
    if (ID == bluePlayer[j].PlayerNumber)
    return bluePlayer[j].PRI.PlayerID;

  return -1;
}

function PlayerStats findStatByPRI(PlayerReplicationInfo PRI)
{
  local int j;
  local PlayerStats empty;

  if (PRI == None || PRI.Team > 1) 
    return empty;

  if (PRI.Team == 0)
  {
    for (j = 0; j < 4; j++)
    {
      if (redPlayer[j].PRI == PRI)
        return redPlayer[j];
    }
  }
  else if (PRI.Team == 1)
  {
    for (j = 0; j < 4; j++)
    {
      if (bluePlayer[j].PRI == PRI)
        return bluePlayer[j];
    }
  }

  return empty;
}

function UpdatePlayerStats(byte Team, ReplicationInfo RI, PlayerReplicationInfo PRI, int cID)
{
    local float TotalDomPoints;
    local int i;
    local SmarterDOMPRI SDomPRI;

    SDomPRI = SmarterDOMPRI(RI);
    TotalDomPoints = 0;

    if (SDomPRI != None)
    {
        for (i = 0; i < 6; i++)
        {
            TotalDomPoints += SDomPRI.PointScores[i];
        }
    }

    if (Team == 0)
    {
        RedPlayer[redPlayerCount] = getPlayerData(RI, PRI, cID, int(TotalDomPoints));
        redPlayerCount++;
    }
    else
    {
        BluePlayer[bluePlayerCount] = getPlayerData(RI, PRI, cID, int(TotalDomPoints));
        bluePlayerCount++;
    }


}

function PlayerStats GetPlayerData(ReplicationInfo RI, PlayerReplicationInfo PRI,int cID, int DomScore)
{
  local PlayerStats TempStats;
  local SmarterDOMPRI SDomPRI;
  local int i;
  

  SDomPRI = SmarterDOMPRI(RI);
 

  if (Pawn(PRI.Owner) != None && Pawn(PRI.Owner).Weapon != None)
  {
    TempStats.gotAMP = (Pawn(PRI.Owner).Weapon.Texture == FireTexture'UnrealShare.Belt_fx.UDamageFX');
    if (TempStats.gotAMP && PRI.TimeAcc == -1)
      PRI.TimeAcc = 30;
  }

  if (Pawn(PRI.Owner) != None && Pawn(PRI.Owner).Health <= 0)
    PRI.TimeAcc = -1;

  TempStats.PlayerNumber = cID;
  TempStats.PlayerName = PRI.PlayerName;
  
 
  
  if (SDomPRI != None)
  {
   
    TempStats.Frags = SDomPRI.Kills - TempStats.Suicides;
    TempStats.Suicides = int(SDomPRI.Kills - PRI.Score);

    if (TempStats.Suicides < 0) TempStats.Suicides = 0;
    
    TempStats.TotalPoints = DomScore;

    TempStats.Score = DomScore;
      
    
    for (i = 0; i < 6; i++)
    {
    TempStats.PointScores[i] = int(SDomPRI.PointScores[i]);
    }
  }
  else
  {
    TempStats.Frags = int(PRI.Score);
    TempStats.Suicides = 0;
    TempStats.Score = int(PRI.Score);
  }


  // Eficency
  if (TempStats.Frags + PRI.Deaths <= 0)
    TempStats.Efficiency = 0;
  else
    TempStats.Efficiency = int((float(TempStats.Frags) / (float(PRI.Deaths) + float(TempStats.Frags))) * 100);



  TempStats.PRI = PRI;
  TempStats.PlayerOwner = Pawn(PRI.Owner);  

  return TempStats;
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

simulated function Timer()
{
  local int j;

  for (j = 0; j < 4; j++)
  {
    if (bluePlayer[j].PRI != none )
    {
      if (bluePlayer[j].PRI.TimeAcc > 0 )
      bluePlayer[j].PRI.TimeAcc--;
      else
      bluePlayer[j].PRI.TimeAcc = -1;
    }

    if (redPlayer[j].PRI != none )
    {
      if (redPlayer[j].PRI.TimeAcc > 0 )
      redPlayer[j].PRI.TimeAcc--;
      else
      redPlayer[j].PRI.TimeAcc = -1;
    }
  }
}


function PostRender(canvas canvas)
{
  local int i,j,k,z;
  local int CurX, CurY;
  local string CurrentText;
  local float XL, YL, ResScale;
  local PlayerStats CurrentPlayer;
  local ReplicationInfo SRI;
  local ENetRole oldrole;
  local int Acc,AccTmp,AccTmp2;
  local SmarterDOMGameReplicationInfo SD_GRI;
  local string PName;
  local float PointCenters[3];
  local float TempX;             
  local float TableStart;
  local string PScoreStr; 
  local int MaxScore, DomTeam;
  local string DominatorName;
  local int AccOffset;
  local int SuicidesOffset;
  local float ColWidth;


  Acc = -1;
  if (canvasx == none)
  canvasx = canvas;

  updateAndSort();

  if ( (Canvas.ClipX < 2250 && Canvas.ClipX >= 1750) || (Canvas.ClipY < 1150 && Canvas.ClipY >= 900) )
  {
  ResScale=0.75;
  }
  else if ( Canvas.ClipX < 1750 || Canvas.ClipY < 900 )
  {
  ResScale=0.5;
  }
  else
  {
  ResScale=1.00;
  }

  if (SavedScreen != Canvas.ClipX+Canvas.ClipY)
  {
    Font469_12b = none;
    Font469_16 = none;
    Font469_16b = none;
    Font469_18b = none;
    SavedScreen = Canvas.ClipX+Canvas.ClipY;
  }

  if (Font469_12b == none)
    Font469_12b = Canvas.CreateFont(FF_Arial, 12 * ResScale, false, false, false, false, true);
  if (Font469_16 == none)
  Font469_16 =  Canvas.CreateFont(FF_Arial, 16 * ResScale, false, false, false, false, true);
  if (Font469_16b == none)
  Font469_16b =  Canvas.CreateFont(FF_Arial, 16 * ResScale, true, false, false, false, true);
  if (Font469_18b == none)
  Font469_18b =  Canvas.CreateFont(FF_Arial, 18 * ResScale, true, false, false, false, true);
  if (Font469_12 == none)
  Font469_12 = Canvas.CreateFont(FF_Arial, 12 * ResScale, false, false, false, false, false);
  if (Font469_18 == none)
  Font469_18 = Canvas.CreateFont(FF_Arial, 18 * ResScale, false, false, false, false, false);
  if (Font469_26b == none)
  Font469_26b = Canvas.CreateFont(FF_Arial, 26 * ResScale, true, false, false, false, true);
  if (Font469_28b == none)
  Font469_28b = Canvas.CreateFont(FF_Arial, 28 * ResScale, true, false, false, false, true);


  if ( class'OverlaySettings'.default.bScoreBoardState )
  {

    Canvas.SetPos(0, Canvas.ClipY * 0.43);
    Canvas.DrawColor = SetColor(4, 4, 4);
    Canvas.Style = ERenderStyle.STY_Translucent;

    if ( class'OverlaySettings'.default.bShowAccuracy )
    AccOffset = 55;
    if ( class'OverlaySettings'.default.bShowSuicides )
    SuicidesOffset = 50;

    
    CurX = 90 * ResScale;
    CurY = Canvas.ClipY * 0.43 + 2 * ResScale;

    
    Canvas.DrawColor = SetColor(255, 255, 255);
    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.Font = Font469_16;
    DrawTextLeft(Canvas, "Player", 10 * ResScale, CurY);

    CurrentText = "Kills";
    Canvas.Font = Font469_16b;
    Canvas.StrLen(CurrentText, XL, YL);
    CurX += XL + 65 * ResScale;
    Canvas.Font = Font469_16;
    DrawTextLeft(canvas,CurrentText,CurX, CurY, false, true);

    if ( class'OverlaySettings'.default.bShowSuicides )
    {
      CurrentText = "S";
      Canvas.Font = Font469_16b;
      Canvas.StrLen(CurrentText, XL, YL);
      CurX += XL + 37 * ResScale;
      Canvas.Font = Font469_16;
      DrawTextLeft(canvas,CurrentText,CurX, CurY, false, true);
    }

    CurrentText = "Eff.";
    Canvas.Font = Font469_16b;
    Canvas.StrLen("100%", XL, YL);
    Canvas.Font = Font469_16;
    CurX += XL + 4 * ResScale;
    DrawTextLeft(canvas,CurrentText,CurX, CurY, false, true);

    if ( class'OverlaySettings'.default.bShowAccuracy )
    {
      CurrentText = "Acc.";
      Canvas.Font = Font469_16b;
      Canvas.StrLen("100%", XL, YL);
      CurX += XL + 10 * ResScale;
      Canvas.Font = Font469_16;
      DrawTextLeft(canvas,CurrentText,CurX, CurY, false, true);
    }  
  // >>> Points header <<<
    CurrentText = "Tpts";
    Canvas.Font = Font469_16b;
    Canvas.StrLen(CurrentText, XL, YL); // Rezervăm spațiu pentru 4 cifre
    CurX += XL + 17 * ResScale;
    Canvas.Font = Font469_16;
    DrawTextLeft(canvas, CurrentText, CurX, CurY, false, true);

    CurX += XL + 15 * ResScale; 
   

    if (SD_GRI == None) 
    {
        foreach AllActors(class'SmarterDOMGameReplicationInfo', SD_GRI)
        {
            if (SD_GRI != None) break; 
        }
    }
    if (SD_GRI != None)
    {
        for (i = 0; i < 3; i++)
        {
            PName = SD_GRI.PointNames[i];
            if (PName == "" || PName == "None") break;

              // Shorten point name if it's too long, with a max pixel width of 90 * ResScale
               PName = shortenName(PName, 9, 90 * ResScale);

            Canvas.Font = Font469_16b;
            Canvas.StrLen(PName, XL, YL);
            ColWidth = XL;
            if (ColWidth < 90 * ResScale) 
                ColWidth = 90 * ResScale;
             PointCenters[i] = CurX + (ColWidth / 2);
            DrawTextLeft(canvas, PName, PointCenters[i] - (XL / 2), CurY, false, true);
            CurX += ColWidth + (10 * ResScale);
        }
    }

    CurY += 26 * ResScale;


    for (i = 0; i < 2; i++)
    {
      if (i==0)
      z = redPlayerCount;
      else
      z = bluePlayerCount;

      for (j = 0; j < z; j++)
      {
        if (i==0)
        {
          CurrentPlayer = redPlayer[j];
          if (CurrentPlayer.PRI == None) continue;
          if(j % 2 == 0)
          {
            if ( class'OverlaySettings'.default.bHighContrastMode )
            Canvas.DrawColor = SetColor(10, 10, 10);
            else
            Canvas.DrawColor = SetColor(128, 0, 0);
          }
          else
          {
            if ( class'OverlaySettings'.default.bHighContrastMode )
            Canvas.DrawColor = SetColor(4, 4, 4);
            else
            Canvas.DrawColor = SetColor(100, 0, 0);
          }
        }
        else
        {
          CurrentPlayer = bluePlayer[j];
          if (CurrentPlayer.PRI == None) continue;
          if(j % 2 == 0)
          {
            if ( class'OverlaySettings'.default.bHighContrastMode )
            Canvas.DrawColor = SetColor(10, 10, 10);
            else
            Canvas.DrawColor = SetColor(0, 0, 120);
          }
          else
          {
            if ( class'OverlaySettings'.default.bHighContrastMode )
	        Canvas.DrawColor = SetColor(4, 4, 4);
	        else
            Canvas.DrawColor = SetColor(0, 0, 100);
          }
        }
// highlight spectated player //
    if (OH.PawnOwner != OH.PlayerOwner && CurrentPlayer.PlayerName == OH.PawnOwner.PlayerReplicationInfo.PlayerName)
    Canvas.DrawColor = SetColor(60,60,60);

// draw background //
    Canvas.SetPos(0, CurY - 2 * ResScale);
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawRect(Texture'white_1x1', ( 615 + AccOffset + SuicidesOffset ) * ResScale, 22 * ResScale);

    if ( class'OverlaySettings'.default.bHighContrastMode )
    {
      Canvas.SetPos( (615 + AccOffset + SuicidesOffset) * ResScale, CurY - 2 * ResScale);
      if ( i == 0)
      {
      Canvas.DrawColor = SetColor(100, 0, 0);
      }
      else
      {
      Canvas.DrawColor = SetColor(0, 0, 120);
      }

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawRect(Texture'white_1x1', 2 * ResScale, 22 * ResScale);
    }

// amp bar //
    if ( class'OverlaySettings'.default.iAmpEffects == 2 && CurrentPlayer.PRI.TimeAcc != -1 )
    {
      TableStart = 0; 
      Canvas.Style = 3;
      Canvas.SetPos(TableStart, CurY - 2 * ResScale);
      Canvas.DrawColor = SetColor(58,24,84);

      if ( class'OverlaySettings'.default.bHighContrastMode )
      Canvas.Style = ERenderStyle.STY_Translucent;
      else
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.DrawRect(Texture'white_1x1', (((615+AccOffset+SuicidesOffset)/30)*CurrentPlayer.PRI.TimeAcc)* ResScale, 22 * ResScale);
    }

    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawColor = SetColor(255, 255, 255);

// draw player info //
    if ( class'OverlaySettings'.default.bPlayerNumbers )
    {
      Canvas.Font = Font469_16;
      DrawTextRight(canvas, string(CurrentPlayer.PlayerNumber), 10 * ResScale, CurY, false, true);
    }

    Canvas.Font = Font469_18b;

    DrawTextLeft(canvas, shortenName(CurrentPlayer.PlayerName, 19, 120), 12 * ResScale, CurY - 2 * ResScale, False, True);

    CurX = 55 * ResScale; 



    Canvas.Font = Font469_16b;
    CurrentText = "Kills";
    Canvas.StrLen(CurrentText, XL, YL);
    CurX += XL + 100 * ResScale;

    // --- DINAMIC FRAGS ---
    if (CurrentPlayer.Frags >= 100)
        Canvas.DrawColor = SetColor(0, 255, 0);   // VERDE Elite (peste 100)
    else
        Canvas.DrawColor = SetColor(255, 255, 255); // ALB Normal

    DrawTextLeft(canvas,string(CurrentPlayer.Frags), CurX, CurY, false, true);

    Canvas.DrawColor = SetColor(255, 255, 255);

    if ( class'OverlaySettings'.default.bShowSuicides && UTS_installed)
    {
      CurrentText = "S";
      Canvas.Font = Font469_16b;
      Canvas.StrLen(CurrentText, XL, YL);
      CurX += XL + 35 * ResScale;
      Canvas.Font = Font469_16;
      DrawTextLeft(canvas,string(CurrentPlayer.Suicides),CurX, CurY, false, true);
    }

    Canvas.Font = Font469_16b;
    CurrentText = "Eff.";
    Canvas.StrLen("100%", XL, YL);
    CurX += XL + 1 * ResScale;

    if (CurrentPlayer.Efficiency >= 50)
        Canvas.DrawColor = SetColor(0, 255, 0); 
    else
        Canvas.DrawColor = SetColor(255, 255, 255); 
  
    DrawTextLeft(canvas, string(CurrentPlayer.Efficiency)$"%", CurX, CurY, false, true);


    if ( class'OverlaySettings'.default.bShowAccuracy && UTS_installed)
    {
      foreach Level.AllActors (class 'ReplicationInfo', SRI)
      {
        if (InStr(""$sri.class, "UTSReplicationInfo") == -1 )
        continue;

        if (SRI.Owner == none || CurrentPlayer.PRI == none || PlayerPawn(SRI.Owner).PlayerReplicationinfo != CurrentPlayer.PRI )
        continue;

        oldrole = SRI.Role;
        SRI.Role = ROLE_Authority;

        AccTmp = int(SRI.GetPropertyText("zzHitCount"));
  	    AccTmp2 = int(SRI.GetPropertyText("zzShotCount"));

        if ( AccTmp2 > 0 )
  	    Acc = int((float(AccTmp) / float(AccTmp2) * 100));
  	    else
  	    Acc = 0;

        SRI.ROLE = oldrole;
      }

        CurrentText = "Acc.";
  	    Canvas.StrLen("100%", XL, YL);
        CurX += XL + 10 * ResScale;

      if (UTS_installed && Acc != -1)
      {
        // ---  DINAMIC ACCURACY ---
        if (Acc >= 40)
            Canvas.DrawColor = SetColor(0, 255, 0);   // VERDE (peste 40%)
        else
            Canvas.DrawColor = SetColor(255, 255, 255); // ALB (sub 40%)
  	    DrawTextLeft(canvas,string(Acc)$"%", CurX, CurY, false, true);
      }
    }
     Canvas.DrawColor = SetColor(255, 255, 255); 
     Canvas.Font = Font469_16b; // Font Bold pentru 
     CurrentText = "0000";
     Canvas.StrLen(CurrentText, XL, YL);
     CurX += XL + 18 * ResScale;

    // --- Tpts ---
    if (CurrentPlayer.TotalPoints > 0) 
    {
        if (CurrentPlayer.PRI.Team == 0) 
        {
            if (CurrentPlayer.TotalPoints == RedMax)
                Canvas.DrawColor = SetColor(0, 255, 0);  
            else if (CurrentPlayer.TotalPoints == RedSecond && RedSecond != 0)
                Canvas.DrawColor = SetColor(255, 255, 0); 
            else
                Canvas.DrawColor = SetColor(255, 255, 255);
        }
        else if (CurrentPlayer.PRI.Team == 1) 
        {
            if (CurrentPlayer.TotalPoints == BlueMax)
                Canvas.DrawColor = SetColor(0, 255, 0);   
            else if (CurrentPlayer.TotalPoints == BlueSecond && BlueSecond != 0)
                Canvas.DrawColor = SetColor(255, 255, 0); 
            else
                Canvas.DrawColor = SetColor(255, 255, 255);
        }
    }
    else { Canvas.DrawColor = SetColor(100, 100, 100); } // GRI

    DrawTextLeft(canvas, string(int(CurrentPlayer.TotalPoints)), CurX, CurY, false, true);
    
    Canvas.DrawColor = SetColor(255, 255, 255); 


    // --- DOMINATION POINTS ---
    if (SD_GRI != None)
    {
        Canvas.DrawColor = SetColor(255, 255, 255); 

        for (k = 0; k < 3; k++)
        {
            if (SD_GRI.PointNames[k] == "" || SD_GRI.PointNames[k] == "None") break;
            
            PScoreStr = string(CurrentPlayer.PointScores[k]);
            Canvas.StrLen(PScoreStr, XL, YL);
            TempX = PointCenters[k] - (XL / 2);
            DrawTextLeft(canvas, PScoreStr, TempX, CurY, false, true);                                  
        }
    }

// AMP square //
    if ( class'OverlaySettings'.default.iAmpEffects == 1 && CurrentPlayer.PRI.TimeAcc != -1 )
    {
      Canvas.DrawColor = SetColor(58, 24, 84);
      Canvas.Style = ERenderStyle.STY_Normal;
      Canvas.SetPos((580 + AccOffset + SuicidesOffset) * ResScale, CurY - 2 * ResScale);
      Canvas.DrawRect(Texture'white_1x1', 12 * ResScale, 22 * ResScale);
    }

    CurY += 26 * ResScale;
    CurX = 150 * ResScale;
  }



CurY+= 2 * ResScale;
}

// --- START: DOMINATOR MACHINES ---
if (SD_GRI != None)
  {
    Canvas.SetPos(0, CurY);
    Canvas.DrawColor = SetColor(4, 4, 4);
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.DrawRect(Texture'white_1x1', (615 + AccOffset + SuicidesOffset) * ResScale, 24 * ResScale);

    Canvas.Font = Font469_18b;
    Canvas.DrawColor = SetColor(255, 200, 50); // GALBEN
    Canvas.Style = ERenderStyle.STY_Normal;
    DrawTextLeft(Canvas, "Dominator Machines", 10 * ResScale, CurY + (4 * ResScale));

  
    for (k = 0; k < 3; k++)
    {
        if (SD_GRI.PointNames[k] == "" || SD_GRI.PointNames[k] == "None") break;

        MaxScore = 0; 
        DominatorName = ""; 
        DomTeam = 255; 

        
        // Check Red Team
        for (j = 0; j < redPlayerCount; j++) {
            if (redPlayer[j].PointScores[k] > MaxScore) {
                MaxScore = redPlayer[j].PointScores[k];
                DominatorName = redPlayer[j].PlayerName;
                DomTeam = 0;
            }
        }
        // Check Blue Team
        for (j = 0; j < bluePlayerCount; j++) {
            if (bluePlayer[j].PointScores[k] > MaxScore) {
                MaxScore = bluePlayer[j].PointScores[k];
                DominatorName = bluePlayer[j].PlayerName;
                DomTeam = 1;
            }
        }

        
        if (MaxScore > 0)
        {
            DominatorName = GetCleanName(DominatorName);
            
            if (Len(DominatorName) > 8) 
                DominatorName = Left(DominatorName, 8);

            if (DomTeam == 0)      
                Canvas.DrawColor = SetColor(255, 50, 50); 
            else if (DomTeam == 1) 
                Canvas.DrawColor = SetColor(0, 200, 255); 
            
            Canvas.StrLen(DominatorName, XL, YL);
            TempX = PointCenters[k] - (XL / 2);
            
            DrawTextShadow(Canvas, DominatorName, TempX, CurY + (4 * ResScale), Canvas.DrawColor);
        }

    }// --- END: DOMINATOR MACHINES ---
  }
  
   //----Draw LibeBase Score Ticker----
if ( class'OverlaySettings'.default.bLiveBaseTicker )
   DrawLiveBaseTicker(Canvas);

}
if ( class'OverlaySettings'.default.bProgressBarsState )

DrawTeamProgressBars(Canvas); // Preia calculele și desenează barele din stânga jos

}



function DrawLiveBaseTicker(Canvas Canvas)
{

local float TickerY, ResScale, BaseCenter, XL, YL;
local int i, j, k;
local string RedStr, BlueStr, PName;
local float BaseXL, BaseYL;
local SmarterDOMGameReplicationInfo SD_GRI;
local float SpacingX,CenterShift;
local float OBSOffset; 
    
  

    if (Canvas == None) return;

    
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
    {
        ResScale = class'OverlaySettings'.default.fUIScale;
    }

    
    if (SD_GRI == None) 
    {
        foreach AllActors(class'SmarterDOMGameReplicationInfo', SD_GRI)
        {
            if (SD_GRI != None) break; 
        }
    }

    if (SD_GRI == None || redPlayerCount == 0 || bluePlayerCount == 0)
        return;

    
    // --- 2. CALCULĂM SUMELE MATEMATICE PE BAZE (Salvare în variabile globale) ---
    for (k = 0; k < 3; k++)
    {
        LiveRedPoints[k] = 0;
        LiveBluePoints[k] = 0;
    }
    for (j = 0; j < redPlayerCount; j++) 
    {
        for (k = 0; k < 3; k++) LiveRedPoints[k] += int(RedPlayer[j].PointScores[k]);
    }
    for (j = 0; j < bluePlayerCount; j++) 
    {
        for (k = 0; k < 3; k++) LiveBluePoints[k] += int(BluePlayer[j].PointScores[k]);
    }

    
    if ( class'OverlaySettings'.default.iOBSOffset == 0 )
        OBSOffset = 0;
    else if ( class'OverlaySettings'.default.iOBSOffset == 1 )
        OBSOffset = 15;
    else if ( class'OverlaySettings'.default.iOBSOffset == 2 )
        OBSOffset = 30;
    else if ( class'OverlaySettings'.default.iOBSOffset == 3 )
        OBSOffset = 45;

    
    if (OH != None)
    {
    TickerY = (112 + OBSOffset * ResScale) * ResScale;
    }
    else
    {
    TickerY = (112 + OBSOffset * ResScale);
    }

 
    SpacingX = 200 * ResScale;    
    CenterShift = (Canvas.ClipX * 0.5) + (25 * ResScale);

    
    if (ResScale >= 1.4 && OH != None)      Canvas.Font = OH.Font469_28b;  
    else if (ResScale >= 1.1 && OH != None) Canvas.Font = OH.Font469_26b; 
    else if (ResScale >= 0.8 && OH != None)  Canvas.Font = OH.Font469_24b; 
    else if (OH != None)                    Canvas.Font = OH.Font469_20b; 

    Canvas.Style = ERenderStyle.STY_Normal; 


    for (i = 0; i < 3; i++)
    {
        if (ResScale >= 1.4 && OH != None)      Canvas.Font = OH.Font469_28b;  
        else if (ResScale >= 1.1 && OH != None) Canvas.Font = OH.Font469_26b; 
        else if (ResScale >= 0.8 && OH != None) Canvas.Font = OH.Font469_24b; 
        else if (OH != None)                    Canvas.Font = OH.Font469_20b; 

        PName = SD_GRI.PointNames[i];
        
        if (PName == "" || PName == "None") 
            continue;

        if (Len(PName) > 7)
        {
            PName = Left(PName, 6) $ "."; 
        }       

        Canvas.StrLen(PName, BaseXL, BaseYL);
        
        if (i == 0)      BaseCenter = CenterShift - SpacingX;    
        else if (i == 1) BaseCenter = CenterShift;
        else if (i == 2) BaseCenter = CenterShift + SpacingX;

        // A. point name (yellow)
        Canvas.DrawColor = SetColor(255, 220, 100); 
        DrawTextShadow(Canvas, PName, BaseCenter - (BaseXL / 2.0), TickerY, Canvas.DrawColor);

        // B. red score 
        Canvas.DrawColor = SetColor(255, 0, 0);
        RedStr = string(LiveRedPoints[i]);
        Canvas.StrLen(RedStr, XL, YL);
        DrawTextShadow(Canvas, RedStr, BaseCenter - (BaseXL / 2.0) - (12 * ResScale) - XL, TickerY, Canvas.DrawColor);

        // C. blue score
        Canvas.DrawColor = SetColor(0, 255, 255);
        BlueStr = string(LiveBluePoints[i]);
        DrawTextShadow(Canvas, BlueStr, BaseCenter + (BaseXL / 2.0) + (12 * ResScale), TickerY, Canvas.DrawColor);    
        
    }
}

function DrawTeamProgressBars(Canvas Canvas)
{
    local float TotalTime, RedRatio, BarWidth, BarHeight, BarX, CurrentPosY, ScaleRatio, ResScale;
    local string RedPct, BluePct;
    local int i;


    
    ResScale = Canvas.ClipX / 1920.0;
    if (OH != None)
        ScaleRatio = (OH.HUDScale / 0.4) * ResScale;
    else
        ScaleRatio = 1.0 * ResScale;

    BarWidth = 7 * ScaleRatio; 
    BarHeight = 33 * ScaleRatio; 
    BarX = 45 * ScaleRatio;
    
    Canvas.Style = ERenderStyle.STY_Normal; 
    Canvas.bNoSmooth = True;
    if (OH != None) Canvas.Font = OH.Font469_16b; // Fontul mic de procente

    for (i = 0; i < 3; i++)
    {
        if (i == 0)      CurrentPosY = Canvas.ClipY - (397 * ScaleRatio); 
        else if (i == 1) CurrentPosY = Canvas.ClipY - (313 * ScaleRatio); 
        else if (i == 2) CurrentPosY = Canvas.ClipY - (229 * ScaleRatio); 

        
        TotalTime = float(LiveRedPoints[i] + LiveBluePoints[i]);

        // White contour
        Canvas.SetPos(BarX - ScaleRatio, CurrentPosY - ScaleRatio);
        Canvas.DrawColor = SetColor(255, 255, 255);
        Canvas.DrawRect(Texture'white_1x1', BarWidth + (2 * ScaleRatio), BarHeight + (2 * ScaleRatio));
        
        // Grey contour
        Canvas.SetPos(BarX, CurrentPosY);
        Canvas.DrawColor = SetColor(40, 40, 40);
        Canvas.DrawRect(Texture'white_1x1', BarWidth, BarHeight);

        if (TotalTime > 0)
        {
            RedRatio = float(LiveRedPoints[i]) / TotalTime;
            BluePct = string(int((1.0 - RedRatio) * 100)) $ "%";
            RedPct = string(int(RedRatio * 100)) $ "%";

            // (Cyan)
            Canvas.SetPos(BarX, CurrentPosY);
            Canvas.DrawColor = SetColor(0, 255, 255);
            Canvas.DrawRect(Texture'white_1x1', BarWidth, BarHeight * (1.0 - RedRatio));

            //  Red
            Canvas.SetPos(BarX, CurrentPosY + (BarHeight * (1.0 - RedRatio)));
            Canvas.DrawColor = SetColor(255, 0, 0);
            Canvas.DrawRect(Texture'white_1x1', BarWidth, BarHeight * RedRatio);

            // % Cyan
            Canvas.DrawColor = SetColor(0, 255, 255);
            Canvas.SetPos(BarX + BarWidth + (5 * ScaleRatio), CurrentPosY + (BarHeight * (1.0 - RedRatio)) / 2 - (5 * ScaleRatio)); 
            DrawTextShadow(Canvas, BluePct, BarX + BarWidth + (5 * ScaleRatio), CurrentPosY + (BarHeight * (1.0 - RedRatio)) / 2 - (5 * ScaleRatio), Canvas.DrawColor);

            // % Red
            Canvas.DrawColor = SetColor(255, 0, 0);
            Canvas.SetPos(BarX + BarWidth + (5 * ScaleRatio), CurrentPosY + (BarHeight * (1.0 - RedRatio)) + (BarHeight * RedRatio) / 2 - (5 * ScaleRatio));
            DrawTextShadow(Canvas, RedPct, BarX + BarWidth + (5 * ScaleRatio), CurrentPosY + (BarHeight * (1.0 - RedRatio)) + (BarHeight * RedRatio) / 2 - (5 * ScaleRatio), Canvas.DrawColor);
        }
    }
}

function DrawTextShadow(Canvas C, string T, float X, float Y, color TextColor)
{
    if (C == None || C.Font == None)
        return;

    // draw shadow
    C.DrawColor = SetColor(0, 0, 0);
    C.SetPos(X + 1 , Y + 1 ); 
    C.DrawText(T);

    // draw text
    C.DrawColor = TextColor;
    C.SetPos(X, Y);
    C.DrawText(T);
}

function string GetCleanName(string S)
{
    local string Out, Char;
    local int i, AscVal;

    Out = "";
    for (i = 0; i < Len(S); i++)
    {
        Char = Mid(S, i, 1);
        AscVal = Asc(Char);

        // keep: A-Z (65-90), a-z (97-122) and 0-9 (48-57)
        if ((AscVal >= 65 && AscVal <= 90) || 
            (AscVal >= 97 && AscVal <= 122) || 
            (AscVal >= 48 && AscVal <= 57))
        {
            Out $= Char;
        }
    }
    
    // Shorten to 10 chars max to ensure it fits in the UI
    if (Len(Out) > 10)
        Out = Left(Out, 10);
        
    return Out;
}

function DrawTextRight(Canvas Canvas,string text, int X, int Y,optional bool hidezeros,optional bool dropshadow)
{
  local float w,h;
  local color oldcolor;
  local int oldstyle;

  oldcolor = canvas.drawcolor;
  oldstyle = canvas.style;
  Canvas.StrLen(text, w, h);

  if (dropshadow)
  {
    Canvas.Style = 1;
	Canvas.DrawColor = SetColor(0,0,0);
	Canvas.SetPos(X-w-1,Y-1);

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

  Canvas.SetPos(X-w, Y);

  if (hidezeros)
  {
    if (Text != "0" && Text != "0%")
    Canvas.DrawText(Text);
  }
  else
  Canvas.DrawText(text);
}

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

function DrawTextHighlighted(Canvas Canvas,string text, int X, int Y,optional bool hidezeros,optional bool dropshadow)  //not in use atm
{
  local color oldcolor;
  local int oldstyle,xo;
  local int Offsets[8];
  Offsets[0] = 1;
  Offsets[1] = 0;
  Offsets[2] = -1;
  Offsets[3] = 0;
  Offsets[4] = 0;
  Offsets[5] = 1;
  Offsets[6] = 0;
  Offsets[7] = -1;

  oldcolor = canvas.drawcolor;
  oldstyle = canvas.style;

  Canvas.Style = 1;
  Canvas.DrawColor = SetColor(90,90,0);

  for( xo = 0 ; xo < 4 ; xo++ )
  {
    Canvas.SetPos(X+Offsets[xo*2],Y+Offsets[(xo*2)+1]);
    Canvas.DrawText(text);
  }

  Canvas.DrawColor = oldcolor;
  Canvas.Style = oldstyle;
  Canvas.SetPos(X, Y);
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

defaultproperties
{
      redPlayerCount=0
      bluePlayerCount=0
      RedMax=0
      RedSecond=0
      BlueMax=0
      BlueSecond=0
      SavedScreen=0
      LiveRedPoints(0)=0
      LiveRedPoints(1)=0
      LiveRedPoints(2)=0
      LiveBluePoints(0)=0
      LiveBluePoints(1)=0
      LiveBluePoints(2)=0
      UTS_installed=True
      RedPlayer(0)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      RedPlayer(1)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      RedPlayer(2)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      RedPlayer(3)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      BluePlayer(0)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      BluePlayer(1)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      BluePlayer(2)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      BluePlayer(3)=(PlayerNumber=0,PlayerName="",Frags=0,Kills=0,Deaths=0,Suicides=0,Efficiency=0,Score=0,gotAmp=False,PRI=None,PlayerOwner=None,PointScores[0]=0,PointScores[1]=0,PointScores[2]=0,PointScores[3]=0,PointScores[4]=0,PointScores[5]=0,TotalPoints=0)
      OH=None
      CanvasX=None
      MyFonts=None
      Font469_12b=None
      Font469_16=None
      Font469_16b=None
      Font469_18b=None
      Font469_12=None
      Font469_18=None
      Font469_20=None
      Font469_20b=None
      Font469_24b=None
      Font469_24=None
      Font469_26b=None
      Font469_28b=None
      Font469_32b=None
      Font469_32=None
      Font469_38b=None
      Font469_38=None
}
