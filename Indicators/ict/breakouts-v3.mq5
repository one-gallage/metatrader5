

//+------------------------------------------------------------------+
//|                                            BrahmastraV3_Beta.mq5 |
//|                          Copyright 2018, Vishal Sharma, mrrich06 |
//|                           Creation Date:2019/07/12 Time:11:43:52 |
//+------------------------------------------------------------------+

//#property link "https://www.earnforex.com/forum/threads/90-accurate-indicator-super-signal-for-mt5-little-modification-needed.30433/"

//---- indicator version number
#property version   "3.00"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrFireBrick
#property indicator_label1  "ShuVi Up"
#property indicator_label2  "ShuVi Down"
#property indicator_width1  1
#property indicator_width2  1
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input int leftbars      = 2;
input int rightbars     = 2;
int shift         = 0;
 
//For Alet---------------------------------------
input int    TriggerCandle=1;
input bool   EnableNativeAlerts = false;
input bool   EnableSoundAlerts  = false;
input string SoundFileName="alert.wav";
datetime LastAlertTime = D'01.01.1970';
int LastAlertDirection = 0;
//+----------------------------------------------+
//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,167);
   PlotIndexSetInteger(1,PLOT_ARROW,167);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initialization done
  }
//+------------------------------------------------------------------+
//|  Accelerator/Decelerator Oscillator                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // size of the price[] array
                const int prev_calculated,  // bars handled on a previous call
                const datetime &time[],     // Time
                const double &Open[],       // Open
                const double &High[],       // High
                const double &Low[],        // Low
                const double &Close[],      // Close
                const long &TickVolume[],   // Tick Volume
                const long &Volume[],       // Real Volume
                const int &Spread[])        // Spread
  {
   int i,j;
   int limit;
   int countup=0;
   int countdown=0;
//--- I need leftbars+rightbars+1 to calculate the indicator
   if(rates_total<leftbars+rightbars+1)
      return(0);
//---
   if(prev_calculated<leftbars+rightbars+1)
     {
      limit=leftbars;
      //--- clean up arrays
      ArrayInitialize(ExtUpperBuffer,0);
      ArrayInitialize(ExtLowerBuffer,0);
     }
   else
     {
      limit=rates_total-(leftbars+rightbars+1);
     }
//--- we calculate the indicator
   for(i=limit;i<=rates_total-leftbars-1;i++)
     {
      for(j=1;j<=leftbars;j++)
        {
         if(High[i]>High[i+j]) countup=countup+1;
         if(Low[i]<Low[i+j]) countdown=countdown+1;
        }
      for(j=1;j<=rightbars;j++)
        {
         if(High[i]>High[i-j]) countup=countup+1;
         if(Low[i]<Low[i-j]) countdown=countdown+1;
        }
      if(countup==leftbars+rightbars)
         ExtUpperBuffer[i+shift]=High[i];
 
      else ExtUpperBuffer[i+shift]=ExtUpperBuffer[i+shift-1];
 
      if(countdown==leftbars+rightbars)
         ExtLowerBuffer[i+shift]=Low[i];
 
      else ExtLowerBuffer[i+shift]=ExtLowerBuffer[i+shift-1];
      countup=0;
      countdown=0;
     }
 
//For Alert----------------------------------------------------------
   if(((TriggerCandle>0) && (time[0]>LastAlertTime)) || (TriggerCandle==0))
     {
 
      string Text;
      // Up Arrow Alert
      if((ExtUpperBuffer[TriggerCandle]>0) && ((TriggerCandle>0) || ((TriggerCandle==0) && (LastAlertDirection!=1))))
        {
         printf("Alert function of BUY Arrow has been run.");
         Text="BrahmastraV3: "+Symbol()+" - "+EnumToString(Period())+" - Up.";
         if(EnableNativeAlerts) Alert(Text);
         if(EnableSoundAlerts) PlaySound(SoundFileName);
         LastAlertTime=time[0];
         LastAlertDirection=1;
        }
      // Down Arrow Alert
      if((ExtLowerBuffer[TriggerCandle]>0) && ((TriggerCandle>0) || ((TriggerCandle==0) && (LastAlertDirection!=-1))))
        {
         printf("Alert function of SELL Arrow has been run.");
         Text="BrahmastraV3: "+Symbol()+" - "+EnumToString(Period())+" - Down.";
         if(EnableNativeAlerts) Alert(Text);
         if(EnableSoundAlerts) PlaySound(SoundFileName);
         LastAlertTime=time[0];
         LastAlertDirection=-1;
        }
     }
//-------------------------------------------------------------------  
 
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
 
//+------------------------------------------------------------------+

