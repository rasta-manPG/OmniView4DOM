class OverlayConfigWindow expands UWindowFramedWindow;

function BeginPlay()
{
  Super.BeginPlay();
  WindowTitle = "OmniView4DOM";
  ClientClass = class'OverlayConfigTab';
  bSizable = false;
  bStatusBar = true;
  StatusBarText = "Version 1.0";
  bLeaveOnscreen = true;
}

function Created()
{
  Super.Created();
  SetSize(250, 670);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}

function Close (optional bool bByParent)
{
  Super.Close(bByParent);
  WindowConsole(GetPlayerOwner().Player.Console).CloseUWindow();
}

defaultproperties
{
}
