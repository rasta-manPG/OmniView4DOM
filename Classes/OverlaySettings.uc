class OverlaySettings extends Info config(OV4DOM);

var config bool bShowItemTimer, bShowHealthArmor, bMsgLengthKF, bSpectatedPlayerInfo, bScoreBoardState, bProgressBarsState, bBestOf5GamesState, 
bShowTeamsMapsPicks,bShowLiveMapScore,bShowPerformanceChart,bLiveBaseTicker,bShowWinStrikeDots,bShowAccuracy, bShowSuicides,bHighContrastMode,bMovieStyleMode ,bPlayerNumbers, bShowShield, bShowAmp, bShowKeg, bShowArmor, bShowPads, bShowBoots;


var config bool bSpectatedPlayerName, bSpectatedPlayerWeapon, bSpectatedPlayerAmmo;

var config int iAmpEffects, iFontSizeChat, iFontSizeKF, iOBSOffset;
var config float fUIScale;

var config string RedTeamName;
var config string BlueTeamName;
var config string RedMapPick1Name;
var config string BlueMapPick1Name;
var config string RedMapPick2Name;
var config string BlueMapPick2Name;
var config string DeciderMapName;
var(Scores) config int RedScore1, BlueScore1;
var(Scores) config int RedScore2, BlueScore2;
var(Scores) config int RedScore3, BlueScore3;
var(Scores) config int RedScore4, BlueScore4;
var(Scores) config int RedScore5, BlueScore5;
var config int iCameraMode;



var config string IH_DM, trans_DM, enforcer_DM, bio_DM, shock_DM, pulse_DM, ripper_DM, mini_DM, flak_DM, RL_DM, sniper_DM, IG_DM,
Fall_DM, Drowned_DM, Burned_DM, Corroded_DM, MaleSuicide_DM, FemaleSuicide_DM;

defaultproperties
{
      bShowItemTimer=True
      bShowHealthArmor=True
      bMsgLengthKF=True
      bSpectatedPlayerInfo=True
      bScoreBoardState=True
      bProgressBarsState=True
      bBestOf5GamesState=True
      bShowTeamsMapsPicks=True
      bShowLiveMapScore=True
      bShowPerformanceChart=True
      bLiveBaseTicker=True
      bShowWinStrikeDots=True
      bShowAccuracy=True
      bShowSuicides=True
      bHighContrastMode=False
      bMovieStyleMode=True
      bPlayerNumbers=True
      bShowShield=True
      bShowAmp=True
      bShowKeg=True
      bShowArmor=False
      bShowPads=False
      bShowBoots=False
      bSpectatedPlayerName=True
      bSpectatedPlayerWeapon=True
      bSpectatedPlayerAmmo=False
      iAmpEffects=2
      iFontSizeChat=1
      iFontSizeKF=1
      iOBSOffset=3
      fUIScale=1.000000
      RedTeamName="RED TEAM"
      BlueTeamName="BLUE TEAM"
      RedMapPick1Name="metal"
      BlueMapPick1Name="Cryptic(fout pick)"
      RedMapPick2Name="RED MAP 2 PICK"
      BlueMapPick2Name="BLUE MAP 2 PICK"
      DeciderMapName="DECIDER MAP"
      RedScore1=293
      BlueScore1=198
      RedScore2=0
      BlueScore2=0
      RedScore3=0
      BlueScore3=0
      RedScore4=0
      BlueScore4=0
      RedScore5=0
      BlueScore5=0
      iCameraMode=0
      IH_DM="%k  >  I H  >  %o"
      trans_DM="%k  >  T L  >  %o"
      enforcer_DM="%k  >  E N F  >  %o"
      bio_DM="%k  >  B I O  >  %o"
      shock_DM="%k  >  S H O C K  >  %o"
      pulse_DM="%k  >  P U L S E  >  %o"
      ripper_DM="%k  >  R I P P E R  >  %o"
      mini_DM="%k  >  M I N I  >  %o"
      flak_DM="%k  >  F L A K  >  %o"
      RL_DM="%k  >  R L  >  %o"
      sniper_DM="%k  >  S N I P E R  >  %o"
      IG_DM="%k  > >  >  %o"
      Fall_DM="  >  F A L L"
      Drowned_DM="  >  D R O W N E D"
      Burned_DM="  >  B U R N E D"
      Corroded_DM="  >  S L I M E D"
      MaleSuicide_DM="  >  S E L F"
      FemaleSuicide_DM="  >  S E L F"
}
