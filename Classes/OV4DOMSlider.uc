class OV4DOMSlider extends UWindowHSliderControl;

var float TrackHeight;

function Created()
{
    Super.Created();
    TrackWidth = 8;
    TrackHeight = 8;
}

function float CheckValue(float Test)
{
    local float TempF;
    local float NewValue;

    NewValue = Test;

    if (Step != 0)
    {
        TempF = NewValue / Step;
        if (TempF >= 0)
            NewValue = int(TempF + 0.5) * Step;
        else
            NewValue = int(TempF - 0.5) * Step;
    }

    if (NewValue < MinValue)
        NewValue = MinValue;
    if (NewValue > MaxValue)
        NewValue = MaxValue;

    return NewValue;
}

function MouseLeave()
{
    Super.MouseLeave();
    if (HelpText != "")
        ToolTip("");
}

function MouseEnter()
{
    local int CutPos, CutPos2;

    Super.MouseEnter();

    if (HelpText != "")
    {
        CutPos = InStr(HelpText, "\\n");

        CutPos2 = InStr(HelpText, Chr(13));
        if ((CutPos == -1 && CutPos2 >= 0) || (CutPos >= 0 && CutPos2 >= 0 && CutPos2 < CutPos))
            CutPos = CutPos2;

        CutPos2 = InStr(HelpText, Chr(10));
        if ((CutPos == -1 && CutPos2 >= 0) || (CutPos >= 0 && CutPos2 >= 0 && CutPos2 < CutPos))
            CutPos = CutPos2;

        if (CutPos >= 0)
            ToolTip(Left(HelpText, CutPos));
        else
            ToolTip(HelpText);
    }
}

function RClick(float X, float Y)
{
    local UWindowMessageBox W;

    if (HelpText == "")
        return;
    W = MessageBox(Text, HelpText, MB_OK, MR_OK);
    W.bLeaveOnscreen = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
    local float W, H;

    Super(UWindowDialogControl).BeforePaint(C, X, Y);

    TextSize(C, Text, W, H);
    WinHeight = FMax(H + 1, TrackHeight + 8);

    switch (Align)
    {
    case TA_Left:
        SliderDrawX = WinWidth - SliderWidth;
        TextX = 0;
        break;
    case TA_Right:
        SliderDrawX = 0;
        TextX = WinWidth - W;
        break;
    case TA_Center:
        SliderDrawX = (WinWidth - SliderWidth) / 2;
        TextX = (WinWidth - W) / 2;
        break;
    }

    SliderDrawY = (WinHeight - 2) / 2;
    TextY = (WinHeight - H) / 2;

    TrackStart = SliderDrawX + (SliderWidth - TrackWidth) * ((Value - MinValue) / (MaxValue - MinValue));
}

function Paint(Canvas C, float X, float Y)
{
    local float S;
    local Texture T;
    local Region R;

    if (Root.GUIScale > 1)
        S = float(int(Root.GUIScale)) / Root.GUIScale;
    else
        S = 1;

    T = GetLookAndFeelTexture();

    if (Text != "")
    {
        C.DrawColor = TextColor;
        ClipText(C, TextX, TextY, Text);
        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
    }

    R = LookAndFeel.HLine;
    DrawStretchedTextureSegment(C, SliderDrawX, SliderDrawY, SliderWidth, R.H * S, R.X, R.Y, R.W, R.H, T);
    DrawUpBevel(C, TrackStart, SliderDrawY - (TrackHeight / 2), TrackWidth, TrackHeight, T);
}

defaultproperties
{
      TrackHeight=16.000000
      TrackWidth=10.000000
}
