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
#property description "tilly_market_killzones"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input bool   UseRectangles    = false;        // Display as Rectangle Zones
input int    NumberOfDays     = 20;           // Days to display
input group  " "      
input color  S1Color          = clrLightPink; // Tokyo color
input color  S2Color          = clrLightSkyBlue; // London color
input color  S3Color          = clrMintCream;  // NewYork color
input group  " " 
input color  NewDayColor      = clrOrangeRed;// NewDay color
input color  TrueDayColor     = clrGold;     // TrueDay color
input color  LevelCloseColor  = clrMintCream;      // Close Price Level color
input color  LevelHLColor     = clrDarkSlateGray;  // High/Low Price Level color

string   prefix;

void OnInit()
{
   string shortname = "tilly_market_killzones";
   prefix = "@"+ shortname+"_";

   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
}
   
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, prefix);
   ChartRedraw();
}

int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
{
  
   
   int limit;   
   if (prev_calculated>rates_total || prev_calculated<=0) {      
      limit = rates_total-NumberOfDays;       // starting index for calculation of all bars
   }
   else {
      limit = rates_total-prev_calculated; // starting index for calculation of new bars which is 1
   }   
   
   static int lookback = 0;
   if (lookback != limit) {
      lookback = limit;
      //Print("lookback:",lookback);
   }else {
      //Print("one time per bar ------------------lookback:",lookback);
      return(rates_total);
   }
      
   ArraySetAsSeries(time,true);  
   ArraySetAsSeries(open,true);   
   ArraySetAsSeries(high,true);     
   ArraySetAsSeries(low,true);     
   ArraySetAsSeries(close,true);   
   
   datetime dt=TimeCurrent();
   for(int i=0; i<NumberOfDays; i++) {
      //if (UseS1) DrawSession(dt, string(i)+"_Tokyo_KZ", S1Begin, S1End, S1Color, "Tokyo_KZ", high, low);
      //if (UseS2) DrawSession(dt, string(i)+"_London_KZ", S2Begin, S2End, S2Color, "London_KZ", high, low);
      //if (UseS3) DrawSession(dt, string(i)+"_NewYork_KZ", S3Begin, S3End, S3Color, "NewYork_KZ", high, low);
      
      DrawTimeSeparator(dt, string(i)+"_NewDay", "0:00", NewDayColor, "NewDay", 3);  

      DrawTimeSeparator(dt, string(i)+"_Tokyo_1s", "2:00", S1Color, "Tokyo_1s", 1);      
      DrawTimeSeparator(dt, string(i)+"_Tokyo_2s", "3:30", S1Color, "Tokyo_2s", 1);
      DrawTimeSeparator(dt, string(i)+"_Tokyo_3s", "5:00", S1Color, "Tokyo_3s", 1);  
          
      //DrawTimeSeparator(dt, string(i)+"_TrueDay", "7:00", S1Color,"TrueDay", 1);
      
      DrawTimeSeparator(dt, string(i)+"_Europe_AM", "8:30", S2Color,"Europe_AM", 1);       
      DrawTimeSeparator(dt, string(i)+"_Frankfurt_1s", "10:00", S2Color,"Frankfurt_1s", 1);     
      DrawTimeSeparator(dt, string(i)+"_Frankfurt_2s", "11:30", S2Color,"Frankfurt_2s", 1);
      
      DrawTimeSeparator(dt, string(i)+"_NewYork_1s", "16:30", S3Color,"NewYork_1s", 1);     
      DrawTimeSeparator(dt, string(i)+"_NewYork_2s", "18:00", S3Color,"NewYork_2s", 1);             
            
      DrawPriceLevels(dt, string(i)+"_Price", "0:00");
      
      dt=decreaseDateTradeDay(dt);
      MqlDateTime ttt;
      TimeToStruct(dt,ttt);
      while(ttt.day_of_week>5) {
         //---- Decrease date on one trading day 
         dt=decreaseDateTradeDay(dt);
         TimeToStruct(dt,ttt);
      }
   }
   
   return(rates_total);
}

void DrawSession(datetime dt,string name,string tb,string te,color clr,string text, const double &High[],const double &Low[])
{

   datetime t1,t2;
   double p1,p2;
   int b1,b2;

   t1=StringToTime(TimeToString(dt,TIME_DATE)+" "+tb);
   t2=StringToTime(TimeToString(dt,TIME_DATE)+" "+te);
   b1=iBarShift(NULL,PERIOD_M5,t1);
   b2=iBarShift(NULL,PERIOD_M5,t2);
 
   int res=b1-b2;
   int extr=MathMax(0,ArrayMaximum(High,b2,res));
   p1=High[extr]; 
   extr=MathMax(0,ArrayMinimum(Low,b2,res));
   p2=Low[extr];

   if(UseRectangles) {
      SetRectangle(0, name, 0, t1, p1, t2 ,p2, clr, text);
   } else {
      DrawTimeSeparator(dt, name+"_Begin", tb, clr, name+"_Begin", 1);
      DrawTimeSeparator(dt, name+"_End", te, clr, name+"_End", 1);
   }   
   
}

void DrawTimeSeparator(datetime dt,string name,string tb,color clr,string text, int width)
{

   datetime t1;
   int b1;

   t1=StringToTime(TimeToString(dt,TIME_DATE)+" "+tb);
   b1=iBarShift(NULL,PERIOD_M5,t1);
 
   SetVLine(0, name, 0, t1, clr, text, width);
}

void DrawPriceLevels(datetime dt,string name,string tb)
{

   datetime new_dt, t1,t2,tr1;
   double d1_close, tr_open, d1_high, d1_low;
   int b1, btr1;
   
   t1=StringToTime(TimeToString(dt,TIME_DATE)+" "+tb);   
   new_dt = dt + (23 * PeriodSeconds(PERIOD_H1)); // extend to the next day
   t2=StringToTime(TimeToString(new_dt,TIME_DATE)+" "+tb);  
   
   b1=iBarShift(NULL, PERIOD_D1, dt) +1;
   
   d1_close = iClose(NULL, PERIOD_D1, b1);   
   SetHLine(0, name+"_Close", 0, t1, t2, d1_close, LevelCloseColor, name+"_Close");
   
   tr1 = StringToTime(TimeToString(dt,TIME_DATE)+" "+ "7:00");
   btr1 = iBarShift(NULL,PERIOD_M10,tr1) +1;  
   tr_open = iOpen(NULL, PERIOD_M10, btr1);
   SetHLine(0, name+"_TrueOpen", 0, tr1, t2, tr_open, TrueDayColor, name+"_TrueOpen"); 
   
   
   d1_high = iHigh(NULL, PERIOD_D1, b1);  
   SetHLine(0, name+"_High", 0, t1, t2, d1_high, LevelHLColor, name+"_High"); 
   
   d1_low = iLow(NULL, PERIOD_D1, b1); 
   SetHLine(0, name+"_Low", 0, t1, t2, d1_low, LevelHLColor, name+"_Low");  

}

datetime decreaseDateTradeDay(datetime dt)
{

   MqlDateTime ttt;
   TimeToStruct(dt,ttt);
   int ty=ttt.year;
   int tm=ttt.mon;
   int td=ttt.day;
   int th=ttt.hour;
   int ti=ttt.min;

   td--;
   if(td==0) {
      tm--;

      if(!tm) {
         ty--;
         tm=12;
      }

      if(tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
      if(tm==2) if(!MathMod(ty,4)) td=29; else td=28;
      if(tm==4 || tm==6 || tm==9 || tm==11) td=30;
   }

   string text;
   StringConcatenate(text,ty,".",tm,".",td," ",th,":",ti);
   return(StringToTime(text));
}

void SetRectangle
(
long     chart_id,      // chart ID
string   obj_name,      // object name
int      nwin,          // window index
datetime time1,         // time 1
double   price1,        // price 1
datetime time2,         // time 2
double   price2,        // price 2
color    Color,         // line color
string   text           // text
)
{

   string name = prefix + obj_name;
   if(ObjectFind(chart_id,name)<0) {
      ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP, text); 
      ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); 
   } else {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
   }
}

void SetVLine
(
long     chart_id,      // chart ID
string   obj_name,      // object name
int      nwin,          // window index
datetime time,          // time 1
color    Color,         // line color
string   text,          // text
int      width          // width
)
{

   string name = prefix + obj_name;
   if(ObjectFind(chart_id,name)<0) {
      ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time,0,0,0);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP, text); 
      ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); 
      ObjectSetInteger(chart_id,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(chart_id,name,OBJPROP_RAY,false); 
   } else {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,0);
   }
}

void SetHLine
(
long     chart_id,      // chart ID
string   obj_name,      // object name
int      nwin,          // window index
datetime time1,         // time 1
datetime time2,         // time 2
double   price,         // price 
color    Color,         // line color
string   text           // text
)
{

   string name = prefix + obj_name;
   if(ObjectFind(chart_id,name)<0) {
      ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price,time2,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP, text);
      ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); 
      ObjectSetInteger(chart_id,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,1); 
      ObjectSetInteger(chart_id,name,OBJPROP_RAY,false); 
   } else {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price);
      ObjectMove(chart_id,name,1,time2,price);
   }
}

//+------------------------------------------------------------------+

