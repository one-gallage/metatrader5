// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ErangaGallage

//  ________  _______    ______   __    __   ______    ______          ______    ______   __        __         ______    ______   ________ 
// /        |/       \  /      \ /  \  /  | /      \  /      \        /      \  /      \ /  |      /  |       /      \  /      \ /        |
// $$$$$$$$/ $$$$$$$  |/$$$$$$  |$$  \ $$ |/$$$$$$  |/$$$$$$  |      /$$$$$$  |/$$$$$$  |$$ |      $$ |      /$$$$$$  |/$$$$$$  |$$$$$$$$/ 
// $$ |__    $$ |__$$ |$$ |__$$ |$$$  \$$ |$$ | _$$/ $$ |__$$ |      $$ | _$$/ $$ |__$$ |$$ |      $$ |      $$ |__$$ |$$ | _$$/ $$ |__    
// $$    |   $$    $$< $$    $$ |$$$$  $$ |$$ |/    |$$    $$ |      $$ |/    |$$    $$ |$$ |      $$ |      $$    $$ |$$ |/    |$$    |   
// $$$$$/    $$$$$$$  |$$$$$$$$ |$$ $$ $$ |$$ |$$$$ |$$$$$$$$ |      $$ |$$$$ |$$$$$$$$ |$$ |      $$ |      $$$$$$$$ |$$ |$$$$ |$$$$$/    
// $$ |_____ $$ |  $$ |$$ |  $$ |$$ |$$$$ |$$ \__$$ |$$ |  $$ |      $$ \__$$ |$$ |  $$ |$$ |_____ $$ |_____ $$ |  $$ |$$ \__$$ |$$ |_____ 
// $$       |$$ |  $$ |$$ |  $$ |$$ | $$$ |$$    $$/ $$ |  $$ |      $$    $$/ $$ |  $$ |$$       |$$       |$$ |  $$ |$$    $$/ $$       |
// $$$$$$$$/ $$/   $$/ $$/   $$/ $$/   $$/  $$$$$$/  $$/   $$/        $$$$$$/  $$/   $$/ $$$$$$$$/ $$$$$$$$/ $$/   $$/  $$$$$$/  $$$$$$$$/ 

#property version   "1.00"
#property description "tilly_daily_data"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrSteelBlue,clrPaleVioletRed,clrDimGray


input color TextColor           = clrWhite;          // Text color
input color ButtonColor         = clrSteelBlue;      // Background color
input color AreaColor           = C'72,72,72';       // Area color
input color SymbolColor         = clrPaleVioletRed;  // Symbol color
input color LabelsColor         = clrDarkGray;       // Labels color
input color ValuesNeutralColor  = clrDimGray;        // Color for unchanged values
input color ValuesPositiveColor = clrMediumSeaGreen; // Color for positive values
input color ValuesNegativeColor = clrPaleVioletRed;  // Color for negative values
input int   XPosition           = 20;                // Horizontal shift
input int   YPosition           = -100;                // Vertical shift
input ENUM_BASE_CORNER Corner   = CORNER_LEFT_LOWER;// Display corner
input int   CandleShift         = 7;                 // Candle shift
input int   TimeFontSize        = 10;                // Font size for timer
input int   TimerShift          = 4;                 // Timer shift

double candleOpen[],candleHigh[],candleLow[],candleClose[],candleColor[];

#define prefix "@tilly_daily_data_"
#define cnameA    prefix + "Area" 
#define lnameA    prefix + "Symbol" 
#define lnameB    prefix + "Clock" 
#define lnameC    prefix + "Range" 
#define lnameD    prefix + "Change" 
#define lnameE    prefix + "DistH" 
#define lnameS    prefix + "Spread" 
#define clockName prefix + "Timer"

int  atrHandle;

int OnInit()
{  
   SetIndexBuffer(0,candleOpen ,INDICATOR_DATA);
   SetIndexBuffer(1,candleHigh ,INDICATOR_DATA);
   SetIndexBuffer(2,candleLow  ,INDICATOR_DATA);
   SetIndexBuffer(3,candleClose,INDICATOR_DATA);
   SetIndexBuffer(4,candleColor,INDICATOR_COLOR_INDEX);
   PlotIndexSetInteger(0,PLOT_SHIFT,CandleShift);
   setControls();
   atrHandle = iATR(NULL,0,30);
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), prefix);
   ChartRedraw();
	EventKillTimer();
}

void OnTimer( ) {	refreshData(); }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   //refreshData(); 
   return(rates_total);
}

void refreshData()
{
   static bool inRefresh = false;
   if (inRefresh) return;
   inRefresh = true;   
   
   int bars = ArraySize(candleClose);
   ENUM_TIMEFRAMES period = PERIOD_D1;
   if (_Period>= PERIOD_D1) period=PERIOD_W1;
   if (_Period>= PERIOD_W1) period=PERIOD_MN1;
   static datetime times[1]; CopyTime(_Symbol,0,0,1,times);
   static MqlRates rates[1]; 
   if (CopyRates(_Symbol,period,0,1,rates)<1) { inRefresh=false; return; }

     
      candleOpen [bars-1] = rates[0].open;
      candleClose[bars-1] = rates[0].close;
      candleHigh [bars-1] = rates[0].high;
      candleLow  [bars-1] = rates[0].low;
      candleColor[bars-1] = 2; 
      if (candleOpen[bars-1]<candleClose[bars-1]) candleColor[bars-1]=0;
      if (candleOpen[bars-1]>candleClose[bars-1]) candleColor[bars-1]=1;

         
      ObjectSetDouble(0,cnameA,OBJPROP_PRICE,0,rates[0].high);
      ObjectSetDouble(0,cnameA,OBJPROP_PRICE,1,rates[0].low );
      ObjectSetInteger(0,cnameA,OBJPROP_TIME,0,rates[0].time);
      ObjectSetInteger(0,cnameA,OBJPROP_TIME,1,times[0]);
            
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,bars-1);
      double pipModifier=1;
      if (_Digits==3 || _Digits==5) pipModifier=10;
      double ask = (double)SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double bid = (double)SymbolInfoDouble(_Symbol,SYMBOL_BID);
      setBasicValue(lnameA,DoubleToString(rates[0].close,_Digits)                             ,XPosition,YPosition+20,Corner);
      setBasicValue(lnameB,DoubleToString((rates[0].high-rates[0].low)  /_Point/pipModifier,1),XPosition,YPosition+38,Corner);
      setBasicValue(lnameC,DoubleToString((rates[0].close-rates[0].open)/_Point/pipModifier,1),XPosition,YPosition+56,Corner);
      setBasicValue(lnameD,DoubleToString((rates[0].high-rates[0].close)/_Point/pipModifier,1),XPosition,YPosition+74,Corner);
      setBasicValue(lnameE,DoubleToString((rates[0].close-rates[0].low) /_Point/pipModifier,1),XPosition,YPosition+92,Corner);
      setBasicValue(lnameS,DoubleToString((ask-bid)/_Point/pipModifier,1)                     ,XPosition,YPosition+110,Corner);
   
      ShowClock(); ChartRedraw();
      inRefresh=false;
}


int     heightTotal; 

void setControls()
{
   int heightBasic  = 128;
   int heightSwap   = 56;
   int heightCandle = 20;
   int heightArea   = 20;
   int heightTimer  = 20;
   heightTotal  =  YPosition+heightArea+heightBasic+heightCandle+heightSwap+heightTimer;
   
   int pos = YPosition;
   
   ObjectSetInteger(0,cnameA,OBJPROP_COLOR,AreaColor);
   ObjectSetInteger(0,cnameA,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,cnameA,OBJPROP_BACK,true);
      
   setBasicLabel(lnameA,Symbol()            ,XPosition,YPosition+20,Corner,SymbolColor,13);
   setBasicLabel(lnameB,"range"             ,XPosition,YPosition+38,Corner,LabelsColor);
   setBasicLabel(lnameC,"change"            ,XPosition,YPosition+56,Corner,LabelsColor);
   setBasicLabel(lnameD,"distance from high",XPosition,YPosition+74,Corner,LabelsColor);
   setBasicLabel(lnameE,"distance from low" ,XPosition,YPosition+92,Corner,LabelsColor);
   setBasicLabel(lnameS,"spread"            ,XPosition,YPosition+110,Corner,LabelsColor);
}


void setButton(string name, string caption, int xposition, int yposition, color textColor, color backColor, int corner)
{
   int relXPosition = xposition; if (corner==2 || corner==3) relXPosition  = 190+xposition;
   int relYPosition = yposition; if (corner==1 || corner==2) relYPosition  = heightTotal-yposition+YPosition;
   
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,relXPosition);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,relYPosition);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,190);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,18);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,caption);
}

void setBasicLabel(string name, string label, int xposition, int yposition, int corner, color labelColor, int fontSize=10, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, int displacement=0)
{
   int relXPosition = xposition;              if (corner==2 || corner==3) relXPosition = 190+xposition;
   int relYPosition = yposition+displacement; if (corner==1 || corner==2) relYPosition = heightTotal-yposition-displacement+YPosition;

   
   if (ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
      ObjectSetInteger(0,name,OBJPROP_COLOR,labelColor);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,relXPosition);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,relYPosition);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
      ObjectSetString(0,name,OBJPROP_FONT,"Arial");
      ObjectSetString(0,name,OBJPROP_TEXT,label);
}

void setBasicValue(string name, string value, int xposition, int yposition, int corner, int fontSize=12, int displacement=0 )
{
   double dvalue = StringToDouble(value);
   color  cvalue = ValuesNeutralColor;
   
      if (dvalue>0) cvalue = ValuesPositiveColor;
      if (dvalue<0) cvalue = ValuesNegativeColor;
      if (corner==0 || corner==1) xposition += 190;
      if (corner==2 || corner==3) xposition -= 190;
      setBasicLabel(name+"v",value,xposition,yposition,corner,cvalue,fontSize,ANCHOR_RIGHT_UPPER,displacement);
}



void ShowClock()
{
   int periodMinutes = periodToMinutes(Period());
   int shift         = periodMinutes*TimerShift*60;
   int currentTime   = (int)TimeCurrent();
   int localTime     = (int)TimeLocal();
   int barTime       = (int)iTime();
   int diff          = (int)MathMax(round((currentTime-localTime)/3600.0)*3600,-24*3600);

      color  theColor;
      string time = getTime(barTime+periodMinutes*60-localTime-diff,theColor);
      time = (TerminalInfoInteger(TERMINAL_CONNECTED)) ? time : time+" x";

             
      if(ObjectFind(0,clockName) < 0)
         ObjectCreate(0,clockName,OBJ_TEXT,0,barTime+shift,0);
         ObjectSetString(0,clockName,OBJPROP_TEXT,time);
         ObjectSetString(0,clockName,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,clockName,OBJPROP_FONTSIZE,TimeFontSize);
         ObjectSetInteger(0,clockName,OBJPROP_COLOR,theColor);
         if (ChartGetInteger(0,CHART_SHIFT,0)==0 && (shift >=0))
               ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime-shift*3);
         else  ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime+shift);


      double price[]; if (CopyClose(Symbol(),0,0,1,price)<=0) return;
      double atr[];   if (CopyBuffer(atrHandle,0,0,1,atr)<=0) return;
             price[0] += 3.0*atr[0]/4.0;
             

      bool visible = ((ChartGetInteger(0,CHART_VISIBLE_BARS,0)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0)) > 0);
      if ( visible && price[0]>=ChartGetDouble(0,CHART_PRICE_MAX,0))
            ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]-1.5*atr[0]);
      else  ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]);
}


string getTime(int times, color& theColor)
{
   string stime = "";
   int    seconds;
   int    minutes;
   int    hours;
   
   
   if (times < 0) {
         theColor = ValuesNegativeColor; times = (int)fabs(times); }
   else  theColor = ValuesPositiveColor;
   seconds = (times%60);
   hours   = (times-times%3600)/3600;
   minutes = (times-seconds)/60-hours*60;

  
   if (hours>0)
   if (minutes < 10)
         stime = stime+(string)hours+":0";
   else  stime = stime+(string)hours+":";
         stime = stime+(string)minutes;
   if (seconds < 10)
         stime = stime+":0"+(string)seconds;
   else  stime = stime+":" +(string)seconds;
   return(stime);
}

datetime iTime(ENUM_TIMEFRAMES forPeriod=PERIOD_CURRENT)
{
   datetime times[]; if (CopyTime(Symbol(),forPeriod,0,1,times)<=0) return(TimeLocal());
   return(times[0]);
}

int periodToMinutes(int period)
{
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

   if (period==PERIOD_CURRENT) 
       period = Period();   
            for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);   
}
