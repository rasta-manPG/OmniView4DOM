class OV4DOM expands Mutator;

var bool init;
var PlayerPawn PlayerOwner;

simulated function Tick(float DeltaTime) {
    if (Level.NetMode != NM_DedicatedServer) {
        if (!bHUDMutator) RegisterHUDMutator();
    }
}

function InterceptHUD(canvas C)
{
  local OverlayHUD OHUD;

  if (PlayerOwner.myHUD != none)
  PlayerOwner.myHUD.Destroy();

  OHUD = PlayerOwner.Level.Spawn(class'OverlayHUD', PlayerOwner);

  PlayerOwner.myHUD = OHUD;

  init = true;
}

function PostRender(canvas C)
{
  Super.PostRender(C);

  PlayerOwner = C.Viewport.Actor;

  if (PlayerOwner != none && !init )
  InterceptHUD(C);
}

defaultproperties
{
      Init=False
      PlayerOwner=None
}
