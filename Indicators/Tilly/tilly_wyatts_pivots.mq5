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
#property description "tilly_wyatts_pivots"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_buffers    0
#property indicator_plots      0
//----
input int              CountPeriods=20;
input ENUM_TIMEFRAMES  TimePeriod=PERIOD_D1;
input bool             PlotPivots=true;
input bool             PlotPivotLabels=false;
input bool             PlotPivotPrices=false;
input ENUM_LINE_STYLE  StylePivots=STYLE_SOLID;
input int              WidthPivots=2;
input color            ColorRes=clrRed;
input color            ColorPP=clrGray;
input color            ColorSup=clrGreen;
input bool             PlotMidpoints=false;
input ENUM_LINE_STYLE  StyleMidpoints=STYLE_DASH;
input int              WidthMidpoints=1;
input color            ColorM35=clrRed;
input color            ColorM02=clrGreen;
input bool             PlotZones=false;
input color            ColorBuyZone=clrLightGreen;
input color            ColorSellZone=clrPink;
input bool             PlotBorders=true;
input ENUM_LINE_STYLE  StyleBorder=STYLE_SOLID;
input int              WidthBorder=2;
input color            ColorBorder=clrBlack;
input bool             PlotFibots=true;
input bool             PlotFibotLabels=false;
input bool             PlotFibotPrices=false;
input ENUM_LINE_STYLE  StyleFibots1=STYLE_DOT;
input ENUM_LINE_STYLE  StyleFibots2=STYLE_SOLID;
input int              WidthFibots1=1;
input int              WidthFibots2=1;
input color            ColorFibots=clrDodgerBlue;
input bool             PlotYesterdayOHLC=false;
input bool             PlotOHLCPrices=false;
input ENUM_LINE_STYLE  StyleOHLC=STYLE_DOT;
input int              WidthOHLC=1;
input color            ColorO=clrGold;
input color            ColorH=clrRed;
input color            ColorL=clrGreen;
input color            ColorC=clrMagenta;
//----
string   period;
datetime timestart,timeend;
double   open,
close,
high,
low;
double   PP,// Pivot Levels
R1,
R2,
R3,
S1,
S2,
S3,
M0,
M1,
M2,
M3,
M4,
M5,
f214,// Fibot Levels
f236,
f382,
f50,
f618,
f764,
f786,
rangeopen1,// OHLC Levels
rangeopen2,
rangeclose1,
rangeclose2;

int      shift;
int nTimePeriod,nCountPeriods=1;

void LevelsDelete(string name)
{

   ObjectDelete(0,"R3"+name);
   ObjectDelete(0,"R2"+name);
   ObjectDelete(0,"R1"+name);
   ObjectDelete(0,"PP"+name);
   ObjectDelete(0,"S1"+name);
   ObjectDelete(0,"S2"+name);
   ObjectDelete(0,"S3"+name);

   ObjectDelete(0,"R3P"+name);
   ObjectDelete(0,"R2P"+name);
   ObjectDelete(0,"R1P"+name);
   ObjectDelete(0,"PPP"+name);
   ObjectDelete(0,"S1P"+name);
   ObjectDelete(0,"S2P"+name);
   ObjectDelete(0,"S3P"+name);

   ObjectDelete(0,"R3L"+name);
   ObjectDelete(0,"R2L"+name);
   ObjectDelete(0,"R1L"+name);
   ObjectDelete(0,"PPL"+name);
   ObjectDelete(0,"S1L"+name);
   ObjectDelete(0,"S2L"+name);
   ObjectDelete(0,"S3L"+name);

   ObjectDelete(0,"M0"+name);
   ObjectDelete(0,"M1"+name);
   ObjectDelete(0,"M2"+name);
   ObjectDelete(0,"M3"+name);
   ObjectDelete(0,"M4"+name);
   ObjectDelete(0,"M5"+name);

   ObjectDelete(0,"M0P"+name);
   ObjectDelete(0,"M1P"+name);
   ObjectDelete(0,"M2P"+name);
   ObjectDelete(0,"M3P"+name);
   ObjectDelete(0,"M4P"+name);
   ObjectDelete(0,"M5P"+name);

   ObjectDelete(0,"M0L"+name);
   ObjectDelete(0,"M1L"+name);
   ObjectDelete(0,"M2L"+name);
   ObjectDelete(0,"M3L"+name);
   ObjectDelete(0,"M4L"+name);
   ObjectDelete(0,"M5L"+name);

   ObjectDelete(0,"BZ"+name);
   ObjectDelete(0,"SZ"+name);

   ObjectDelete(0,"BDU"+name);
   ObjectDelete(0,"BDD"+name);
   ObjectDelete(0,"BDL"+name);
   ObjectDelete(0,"BDR"+name);

   ObjectDelete(0,"f214a"+name);
   ObjectDelete(0,"f236a"+name);
   ObjectDelete(0,"f382a"+name);
   ObjectDelete(0,"f50a"+name);
   ObjectDelete(0,"f618a"+name);
   ObjectDelete(0,"f764a"+name);
   ObjectDelete(0,"f786a"+name);

   ObjectDelete(0,"f214b"+name);
   ObjectDelete(0,"f236b"+name);
   ObjectDelete(0,"f382b"+name);
   ObjectDelete(0,"f50b"+name);
   ObjectDelete(0,"f618b"+name);
   ObjectDelete(0,"f764b"+name);
   ObjectDelete(0,"f786b"+name);

   ObjectDelete(0,"f214p"+name);
   ObjectDelete(0,"f236p"+name);
   ObjectDelete(0,"f382p"+name);
   ObjectDelete(0,"f50p"+name);
   ObjectDelete(0,"f618p"+name);
   ObjectDelete(0,"f764p"+name);
   ObjectDelete(0,"f786p"+name);

   ObjectDelete(0,"f214l"+name);
   ObjectDelete(0,"f236l"+name);
   ObjectDelete(0,"f382l"+name);
   ObjectDelete(0,"f50l"+name);
   ObjectDelete(0,"f618l"+name);
   ObjectDelete(0,"f764l"+name);
   ObjectDelete(0,"f786l"+name);

   ObjectDelete(0,"open"+name);
   ObjectDelete(0,"high"+name);
   ObjectDelete(0,"low"+name);
   ObjectDelete(0,"close"+name);

   ObjectDelete(0,"openp"+name);
   ObjectDelete(0,"highp"+name);
   ObjectDelete(0,"lowp"+name);
   ObjectDelete(0,"closep"+name);

}

bool PlotTrend(const long              chart_ID=0,
               string                  name="trendline",
               const int               subwindow=0,
               datetime                time1=0,
               double                  price1=0,
               datetime                time2=0,
               double                  price2=0,
               const color             clr=clrBlack,
               const ENUM_LINE_STYLE   style=STYLE_SOLID,
               const int               width=2,
               const bool              back=true,
               const bool              selection=false,
               const bool              ray=false,
               const bool              hidden=true)
{

   ResetLastError();
   if(ObjectFind(chart_ID,name)!=subwindow)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_TREND,subwindow,time1,price1,time2,price2))
        {
         Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
         return(false);
        }
     }
   else
     {
      ObjectMove(chart_ID,name,0,time1,price1);
      ObjectMove(chart_ID,name,1,time2,price2);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);

   return(true);
}

bool PlotRectangle(const long        chart_ID=0,
                   string            name="rectangle",
                   const int         subwindow=0,
                   datetime          time1=0,
                   double            price1=1,
                   datetime          time2=0,
                   double            price2=0,
                   const color       clr=clrGray,
                   const bool        back=true,
                   const bool        selection=false,
                   const bool        hidden=true)
{

   if(ObjectFind(chart_ID,name)!=subwindow)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,subwindow,time1,price1,time2,price2))
        {
         Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
         return(false);
        }
     }
   else
     {
      ObjectMove(chart_ID,name,0,time1,price1);
      ObjectMove(chart_ID,name,1,time2,price2);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,true);

   return(true);
}

bool PlotText(const long        chart_ID=0,
              string            name="text",
              const int         subwindow=0,
              datetime          time1=0,
              double            price1=0,
              const string      text="text",
              const string      font="Arial",
              const int         font_size=10,
              const color       clr=clrGray,
              const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_UPPER,
              const bool        back=true,
              const bool        selection=false,
              const bool        hidden=true)
{

   if(ObjectFind(chart_ID,name)!=subwindow)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_TEXT,subwindow,time1,price1))
        {
         Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
         return(false);
        }
     }
   else
     {
      ObjectMove(chart_ID,name,0,time1,price1);
     }
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);

   return(true);
}

void LevelsDraw(int      shft,
                datetime tmestrt,
                datetime tmend,
                string   name,
                bool     future,
                const double &fClose[])
{

   high  = iHigh(NULL,TimePeriod,shft);
   low   = iLow(NULL,TimePeriod,shft);
   open  = iOpen(NULL,TimePeriod,shft);
   if(future==false){close=iClose(NULL,TimePeriod,shft);}else{close=fClose[shft];}

   PP=(high+low+close)/3.0;

   R1 = 2*PP-low;
   R2 = PP+(high - low);
   R3 = (2*PP)+(high-(2*low));

   S1 = 2*PP-high;
   S2 = PP-(high - low);
   S3 = (2*PP)-((2*high)-low);

   M0=0.5*(S2+S3);
   M1=0.5*(S1+S2);
   M2=0.5*(PP+S1);
   M3=0.5*(PP+R1);
   M4=0.5*(R1+R2);
   M5=0.5*(R2+R3);
   double range=(high-low)/100;
   f214 = low+range*(100-21.4);
   f236 = low+range*(100-23.6);
   f382 = low+range*(100-38.2);
   f50  = low+range*(100-50);
   f618 = low+range*(38.2);
   f764 = low+range*(23.6);
   f786 = low+range*(21.4);

   if(!range) range=_Point/100;
   rangeopen1  = (open-low)/range;
   rangeopen2  = 100-((open-low)/range);
   rangeclose1 = (close-low)/range;
   rangeclose2 = 100-((close-low)/range);

   if(PlotPivots)
     {
      PlotTrend(0,"R3"+name,0,tmestrt,R3,tmend,R3,ColorRes,StylePivots,WidthPivots,true,false,false,true);
      PlotTrend(0,"R2"+name,0,tmestrt,R2,tmend,R2,ColorRes,StylePivots,WidthPivots,true,false,false,true);
      PlotTrend(0,"R1"+name,0,tmestrt,R1,tmend,R1,ColorRes,StylePivots,WidthPivots,true,false,false,true);
      PlotTrend(0,"PP"+name,0,tmestrt,PP,tmend,PP,ColorPP,StylePivots,WidthPivots,true,false,false,true);
      PlotTrend(0,"S1"+name,0,tmestrt,S1,tmend,S1,ColorSup,StylePivots,WidthPivots,true,false,false,true);
      PlotTrend(0,"S2"+name,0,tmestrt,S2,tmend,S2,ColorSup,StylePivots,WidthPivots,true,false,false,true);
      PlotTrend(0,"S3"+name,0,tmestrt,S3,tmend,S3,ColorSup,StylePivots,WidthPivots,true,false,false,true);
      if(PlotPivotLabels)
        {
         PlotText(0,"R3L"+name,0,tmend,R3,"R3","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R2L"+name,0,tmend,R2,"R2","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R1L"+name,0,tmend,R1,"R1","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"PPL"+name,0,tmend,PP,"PP","Arial",8,ColorPP,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S1L"+name,0,tmend,S1,"S1","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S2L"+name,0,tmend,S2,"S2","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S3L"+name,0,tmend,S3,"S3","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
        }
      if(PlotPivotPrices)
        {
         PlotText(0,"R3P"+name,0,tmestrt,R3,DoubleToString(R3,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"R2P"+name,0,tmestrt,R2,DoubleToString(R2,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"R1P"+name,0,tmestrt,R1,DoubleToString(R1,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"PPP"+name,0,tmestrt,PP,DoubleToString(PP,4),"Arial",8,ColorPP,ANCHOR_LEFT_UPPER);
         PlotText(0,"S1P"+name,0,tmestrt,S1,DoubleToString(S1,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"S2P"+name,0,tmestrt,S2,DoubleToString(S2,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"S3P"+name,0,tmestrt,S3,DoubleToString(S3,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
        }
     }

   if(PlotMidpoints)
     {
      PlotTrend(0,"M0"+name,0,tmestrt,M0,tmend,M0,ColorM02,StyleMidpoints,WidthMidpoints,true,false,false,true);
      PlotTrend(0,"M1"+name,0,tmestrt,M1,tmend,M1,ColorM02,StyleMidpoints,WidthMidpoints,true,false,false,true);
      PlotTrend(0,"M2"+name,0,tmestrt,M2,tmend,M2,ColorM02,StyleMidpoints,WidthMidpoints,true,false,false,true);
      PlotTrend(0,"M3"+name,0,tmestrt,M3,tmend,M3,ColorM35,StyleMidpoints,WidthMidpoints,true,false,false,true);
      PlotTrend(0,"M4"+name,0,tmestrt,M4,tmend,M4,ColorM35,StyleMidpoints,WidthMidpoints,true,false,false,true);
      PlotTrend(0,"M5"+name,0,tmestrt,M5,tmend,M5,ColorM35,StyleMidpoints,WidthMidpoints,true,false,false,true);
      if(PlotPivotLabels)
        {
         PlotText(0,"M0L"+name,0,tmend,M0,"M0","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M1L"+name,0,tmend,M1,"M1","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M2L"+name,0,tmend,M2,"M2","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M3L"+name,0,tmend,M3,"M3","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M4L"+name,0,tmend,M4,"M4","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M5L"+name,0,tmend,M5,"M5","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
        }
      if(PlotPivotPrices)
        {
         PlotText(0,"M0P"+name,0,tmestrt,M0,DoubleToString(M0,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"M1P"+name,0,tmestrt,M1,DoubleToString(M1,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"M2P"+name,0,tmestrt,M2,DoubleToString(M2,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"M3P"+name,0,tmestrt,M3,DoubleToString(M3,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"M4P"+name,0,tmestrt,M4,DoubleToString(M4,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"M5P"+name,0,tmestrt,M5,DoubleToString(M5,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
        }
     }

   if(PlotZones)
     {
      PlotRectangle(0,"BZ"+name,0,tmestrt,M1,tmend,S2,ColorBuyZone);
      PlotRectangle(0,"SZ"+name,0,tmestrt,M4,tmend,R2,ColorSellZone);
     }

   if(PlotBorders)
     {
      //PlotTrend(0,"BDU"+name,0,tmestrt,R2,tmend,R2,ColorBorder,StyleBorder,WidthBorder);     
      //PlotTrend(0,"BDD"+name,0,tmestrt,S2,tmend,S2,ColorBorder,StyleBorder,WidthBorder);     
      PlotTrend(0,"BDL"+name,0,tmestrt,R2,tmestrt,S2,ColorBorder,StyleBorder,WidthBorder,true,false,false,true);
      PlotTrend(0,"BDR"+name,0,tmend,R2,tmend,S2,ColorBorder,StyleBorder,WidthBorder,true,false,false,true);
     }

   if(PlotFibots)
     {
      PlotTrend(0,"f214a"+name,0,tmestrt,f214,tmend,f214,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f382a"+name,0,tmestrt,f382,tmend,f382,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f50a"+name,0,tmestrt,f50,tmend,f50,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f618a"+name,0,tmestrt,f618,tmend,f618,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f786a"+name,0,tmestrt,f786,tmend,f786,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f214b"+name,0,tmestrt+nTimePeriod/6,f214,tmend,f214,ColorFibots,StyleFibots2);
      PlotTrend(0,"f382b"+name,0,tmestrt+nTimePeriod/6,f382,tmend,f382,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f50b"+name,0,tmestrt+nTimePeriod/6,f50,tmend,f50,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f618b"+name,0,tmestrt+nTimePeriod/6,f618,tmend,f618,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f786b"+name,0,tmestrt+nTimePeriod/6,f786,tmend,f786,ColorFibots,StyleFibots2,WidthFibots2);
      if(PlotFibotLabels)
        {
         PlotText(0,"f214l"+name,0,tmend,f214,"21.4%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
         PlotText(0,"f382l"+name,0,tmend,f382,"38.2%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
         PlotText(0,"f50l"+name,0,tmend,f50,"50%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
         PlotText(0,"f618l"+name,0,tmend,f618,"61.8%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
         PlotText(0,"f786l"+name,0,tmend,f786,"78.6%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
        }
      if(PlotFibotPrices)
        {
         PlotText(0,"f214p"+name,0,tmestrt,f214,DoubleToString(f214,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
         PlotText(0,"f382p"+name,0,tmestrt,f382,DoubleToString(f382,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
         PlotText(0,"f50p"+name,0,tmestrt,f50,DoubleToString(f50,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
         PlotText(0,"f618p"+name,0,tmestrt,f618,DoubleToString(f618,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
         PlotText(0,"f786p"+name,0,tmestrt,f786,DoubleToString(f786,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
        }
     }

   if(PlotYesterdayOHLC)
     {
      PlotTrend(0,"open"+name,0,tmestrt,open,tmestrt+nTimePeriod/6,open,ColorO,StyleOHLC,WidthOHLC,true,false,false,true);
      PlotTrend(0,"high"+name,0,tmestrt,high,tmestrt+nTimePeriod/6,high,ColorH,StyleOHLC,WidthOHLC,true,false,false,true);
      PlotTrend(0,"low"+name,0,tmestrt,low,tmestrt+nTimePeriod/6,low,ColorL,StyleOHLC,WidthOHLC,true,false,false,true);
      PlotTrend(0,"close"+name,0,tmestrt,close,tmestrt+nTimePeriod/6,close,ColorC,StyleOHLC,WidthOHLC,true,false,false,true);
      if(PlotOHLCPrices)
        {
         PlotText(0,"openp"+name,0,tmestrt+nTimePeriod/6,open,DoubleToString(rangeopen1,1)+"/"+DoubleToString(rangeopen2,1)+"%","Arial",8,ColorO,6);
         PlotText(0,"closep"+name,0,tmestrt+nTimePeriod/6,close,DoubleToString(rangeclose1,1)+"/"+DoubleToString(rangeclose2,1)+"%","Arial",8,ColorC,6);
        }
     }

}

string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
{

   return(StringSubstr(EnumToString(timeframe),7,-1));

}

void OnInit()
{

   period=GetStringTimeframe(TimePeriod);
   nTimePeriod=PeriodSeconds(TimePeriod);
   if(!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE) && !MQLInfoInteger(MQL_DEBUG)) nCountPeriods=CountPeriods;
   ChartRedraw(0);
}

void OnDeinit(const int reason)
{

   for(shift=0;shift<=CountPeriods;shift++) {
      LevelsDelete(period+string(shift));
   }
   LevelsDelete("F"+period);
   Comment("");
   ChartRedraw(0);
}

int OnCalculate(
                const int rates_total,   
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double& High[],     
                const double& Low[],      
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
{

   ArraySetAsSeries(Close,true);

   int limit;
   if(prev_calculated>rates_total || prev_calculated<=0) {
      limit=rates_total-1;
   }
   else limit=rates_total-prev_calculated; 
   if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_DEBUG)) if(!limit) return(prev_calculated);

   // for(shift=nCountPeriods-1;shift>=0;shift--) //--remove the 0th cycle 
   for(shift=nCountPeriods;shift>0;shift--) {

      timestart = iTime(NULL,TimePeriod,shift-1); // timestart = iTime(NULL,TimePeriod,shift);
      timeend   = timestart+nTimePeriod;

      //if(shift == 1) {
      //   timeend   = timestart+ (2*nTimePeriod); //--show the last levels to the 0th cycle
      //}      

      LevelsDraw(shift,timestart,timeend,period+string(shift),false,Close); // LevelsDraw(shift+1,timestart,timeend,period+string(shift),false,Close);
   }

   // ChartRedraw(0);
   return(prev_calculated);
}
//+------------------------------------------------------------------+


