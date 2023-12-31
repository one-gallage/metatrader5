//+------------------------------------------------------------------+
//|                                             market-killzones.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property version   "1.00"
#property description "market-killzones"

//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers
#property indicator_buffers 0
//---- only 0 plots are used
#property indicator_plots   0

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int    NumberOfDays=10;
input string S1Begin   ="02:45";       // Tokyo killzone begin
input string S1End     ="06:15";       // Tokyo killzone end
input color  S1Color   =clrBeige;     // Tokyo killzone color
input string S2Begin   ="07:45";       // London killzone begin
input string S2End     ="11:15";       // London killzone end
input color  S2Color   =clrAliceBlue;  // London killzone color
input string S3Begin   ="14:45";       // NewYork killzone begin
input string S3End     ="18:15";       // NewYork killzone end
input color  S3Color   =clrBisque;  // NewYork killzone color

//+-----------------------------------+
string prefix;
//+------------------------------------------------------------------+  
//| i-Sessions indicator initialization function                     |
//+------------------------------------------------------------------+
void OnInit()
  {
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"-";

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"market-killzones");

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| i-Sessions deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//--- delete objects
   ObjectsDeleteAll(0,prefix);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| i-Sessions iteration function                                    |
//+------------------------------------------------------------------+
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

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   datetime dt=TimeCurrent();
   for(int i=0; i<NumberOfDays; i++)
     {
      DrawRectangle(dt,prefix+"Tokyo"+string(i),S1Begin,S1End,S1Color,high,low,"Tokyo-KZ");
      DrawRectangle(dt,prefix+"London"+string(i),S2Begin,S2End,S2Color,high,low,"London-KZ");
      DrawRectangle(dt,prefix+"NewYork"+string(i),S3Begin,S3End,S3Color,high,low,"NewYork-KZ");
      dt=decDateTradeDay(dt);
      MqlDateTime ttt;
      TimeToStruct(dt,ttt);

      while(ttt.day_of_week>5)
        {
         dt=decDateTradeDay(dt);
         TimeToStruct(dt,ttt);
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Drawing objects in the chart                                     |
//| Parameters:                                                      |
//|   dt - date of the trading day                                   |
//|   no - name of the object                                        |
//|   tb - starting time of the session                              |
//|   te - ending time of the session                                |
//+------------------------------------------------------------------+
void DrawRectangle(datetime dt,string name,string tb,string te,color clr,const double &High[],const double &Low[], string text)
  {
//----
   datetime t1,t2;
   double p1,p2;
   int b1,b2;
//----
   t1=StringToTime(TimeToString(dt,TIME_DATE)+" "+tb);
   t2=StringToTime(TimeToString(dt,TIME_DATE)+" "+te);
//----
   b1=iBarShift(NULL,0,t1);
   b2=iBarShift(NULL,0,t2);
//----  
   int res=b1-b2;
   int extr=MathMax(0,ArrayMaximum(High,b2,res));
   p1=High[extr];
   extr=MathMax(0,ArrayMinimum(Low,b2,res));
   p2=Low[extr];
//----
   SetRectangle(0,name,0,t1,p1,t2,p2,clr,false,text);
//----
  }
//+------------------------------------------------------------------+
//| Decrease date on one trading day                                 |
//| Parameters:                                                      |
//|   dt - date of the trading day                                   |
//+------------------------------------------------------------------+
datetime decDateTradeDay(datetime dt)
  {
//----
   MqlDateTime ttt;
   TimeToStruct(dt,ttt);
   int ty=ttt.year;
   int tm=ttt.mon;
   int td=ttt.day;
   int th=ttt.hour;
   int ti=ttt.min;
//----
   td--;
   if(td==0)
     {
      tm--;

      if(!tm)
        {
         ty--;
         tm=12;
        }

      if(tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
      if(tm==2) if(!MathMod(ty,4)) td=29; else td=28;
      if(tm==4 || tm==6 || tm==9 || tm==11) td=30;
     }

   string text;
   StringConcatenate(text,ty,".",tm,".",td," ",th,":",ti);
//----
   return(StringToTime(text));
  }
//+------------------------------------------------------------------+  
//| iBarShift() function                                             |
//+------------------------------------------------------------------+  
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
//| Creating rectangle object:                                       |
//+------------------------------------------------------------------+
void CreateRectangle
(
long     chart_id,      // chart ID
string   name,          // object name
int      nwin,          // window index
datetime time1,         // time 1
double   price1,        // price 1
datetime time2,         // time 2
double   price2,        // price 2
color    Color,         // line color
bool     background,    // line background display
string   text           // text
)
//----
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   //ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); // tooltip disabling
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP, text); // tooltip disabling
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the rectangle object                          |
//+------------------------------------------------------------------+
void SetRectangle
(
long     chart_id,      // chart ID
string   name,          // object name
int      nwin,          // window index
datetime time1,         // time 1
double   price1,        // price 1
datetime time2,         // time 2
double   price2,        // price 2
color    Color,         // line color
bool     background,    // line background display
string   text           // text
)
//----
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+

