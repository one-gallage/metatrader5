//+------------------------------------------------------------------+
//|                                                         tilly.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 18
#property indicator_plots   18

input ENUM_APPLIED_PRICE src = PRICE_CLOSE;     //Source
input int      per = 10;                        //Sampling Period
input double   mult = 3;                        //Range Multiplier
input bool     DrawArrows      = false;         // Draw Signal Arrows?
input bool     AlertsOn        = true;          // Turn alerts on?
bool           AlertsOnCurrent = false;         // Alert on current bar?
bool           AlertsMessage   = false;          // Display messageas on alerts?
bool           AlertsSound     = false;         // Play sound on alerts?
bool           AlertsEmail     = false;         // Send email on alerts?
bool           AlertsNotify    = true;          // Send push notification on alerts?
bool           useHA = false;                   //Use Heiken Ashi

//--- plot abschange
#property indicator_label1  "abschange"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot avrange
#property indicator_label2  "avrange"
#property indicator_type2   DRAW_NONE
#property indicator_color2  clrNONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot smoothrng
#property indicator_label3  "smoothrng"
#property indicator_type3   DRAW_NONE
#property indicator_color3  clrNONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot rngfilt
#property indicator_label4  "rngfilt"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDodgerBlue,clrDeepPink,clrSilver
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3
//--- plot upward
#property indicator_label5  "upward"
#property indicator_type5   DRAW_NONE
#property indicator_color5  clrNONE
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot downward
#property indicator_label6  "downward"
#property indicator_type6   DRAW_NONE
#property indicator_color6  clrNONE
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot hband
#property indicator_label7  "hband"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDodgerBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot lband
#property indicator_label8  "lband"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrDeepPink
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot filtcolor
#property indicator_label9  "filtcolor"
#property indicator_type9   DRAW_NONE
#property indicator_color9  clrNONE
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot label1
#property indicator_label10  "label1"
#property indicator_type10   DRAW_NONE
#property indicator_color10  clrNONE
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot barcolor
#property indicator_label11  "barcolor"
#property indicator_type11   DRAW_COLOR_CANDLES
#property indicator_color11  clrLime, clrGreen,clrRed,clrMaroon,clrOrange
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- plot Buy
#property indicator_label12  "Buy"
#property indicator_type12   DRAW_NONE
#property indicator_color12  clrNONE
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1
//--- plot Sell
#property indicator_label13  "Sell"
#property indicator_type13   DRAW_ARROW
#property indicator_color13  clrNONE
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1

//--- indicator buffers
double         abschangeBuffer[];
double         avrangeBuffer[];
double         smoothrngBuffer[];
double         rngfiltBuffer[];
double         rngfiltColors[];
double         upwardBuffer[];
double         downwardBuffer[];
double         hbandBuffer[];
double         lbandBuffer[];
double         filtcolorBuffer[];
double         barcolorBuffer[];
double         Label1Buffer1[];
double         Label1Buffer2[];
double         Label1Buffer3[];
double         Label1Buffer4[];
double         Label1Colors[];
double         BuyBuffer[];
double         SellBuffer[];

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,prefix);
   ChartRedraw();
}

int ashi_handle=0;
int atr_handle=0;
string prefix;
  
int OnInit()
{  

   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"-";
   SetIndexBuffer(0,abschangeBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,avrangeBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,smoothrngBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,rngfiltBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,rngfiltColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,upwardBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,downwardBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,hbandBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,lbandBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,filtcolorBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,barcolorBuffer,INDICATOR_DATA);
   SetIndexBuffer(11,Label1Buffer1,INDICATOR_DATA);
   SetIndexBuffer(12,Label1Buffer2,INDICATOR_DATA);
   SetIndexBuffer(13,Label1Buffer3,INDICATOR_DATA);
   SetIndexBuffer(14,Label1Buffer4,INDICATOR_DATA);
   SetIndexBuffer(15,Label1Colors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(16,BuyBuffer,INDICATOR_DATA);
   SetIndexBuffer(17,SellBuffer,INDICATOR_DATA);

   ArraySetAsSeries(abschangeBuffer,true);
   ArraySetAsSeries(avrangeBuffer,true);
   ArraySetAsSeries(smoothrngBuffer,true);
   ArraySetAsSeries(rngfiltBuffer,true);
   ArraySetAsSeries(rngfiltColors,true);
   ArraySetAsSeries(upwardBuffer,true);
   ArraySetAsSeries(downwardBuffer,true);
   ArraySetAsSeries(hbandBuffer,true);
   ArraySetAsSeries(lbandBuffer,true);
   ArraySetAsSeries(filtcolorBuffer,true);
   ArraySetAsSeries(barcolorBuffer,true);
   ArraySetAsSeries(Label1Buffer1,true);
   ArraySetAsSeries(Label1Buffer2,true);
   ArraySetAsSeries(Label1Buffer3,true);
   ArraySetAsSeries(Label1Buffer4,true);
   ArraySetAsSeries(Label1Colors,true);
   ArraySetAsSeries(BuyBuffer,true);
   ArraySetAsSeries(SellBuffer,true);
   PlotIndexSetDouble(16,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(17,PLOT_EMPTY_VALUE,0.0);
   atr_handle=iATR(_Symbol, PERIOD_CURRENT, 14);
   if(useHA) {
      ashi_handle=iCustom(_Symbol, PERIOD_CURRENT, "Examples\\Heiken_Ashi");
   }   

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

   int BARS=MathMax(Bars(_Symbol,PERIOD_CURRENT)-100-prev_calculated,1);
   int wper=2*per-1;
   for(int i=BARS;i>=0;i--)
   {
      abschangeBuffer[i]=MathAbs(price(i, src)-price(i+1, src));
   }
   for(int i=BARS;i>=0;i--)
   {
      double alpha=2.0/(per+1);
      avrangeBuffer[i]=alpha*abschangeBuffer[i]+(1-alpha)*avrangeBuffer[i+1];
   }
   for(int i=BARS;i>=0;i--)
   {
      double alpha=2.0/(wper+1);
      smoothrngBuffer[i]=mult*alpha*avrangeBuffer[i]+(1-alpha)*smoothrngBuffer[i+1];
   }
   for(int i=BARS;i>=0;i--)
   {
      rngfiltBuffer[i]=price(i, src);
   }
   for(int i=BARS;i>=0;i--)
   {
      rngfiltBuffer[i] = price(i, src) > rngfiltBuffer[i+1] ? price(i, src) - smoothrngBuffer[i] < rngfiltBuffer[i+1] ? rngfiltBuffer[i+1] : price(i, src) - smoothrngBuffer[i] : 
       price(i, src) + smoothrngBuffer[i] > rngfiltBuffer[i+1] ? rngfiltBuffer[i+1] : price(i, src) + smoothrngBuffer[i];
   }

   for(int i=BARS;i>=0;i--)
   {
      upwardBuffer[i] = 0.0;
      upwardBuffer[i] = rngfiltBuffer[i] > rngfiltBuffer[i+1] ? upwardBuffer[i+1] + 1 : rngfiltBuffer[i] < rngfiltBuffer[i+1] ? 0 : upwardBuffer[i+1];
      downwardBuffer[i] = 0.0;
      downwardBuffer[i] = rngfiltBuffer[i] < rngfiltBuffer[i+1] ? downwardBuffer[i+1] + 1 : rngfiltBuffer[i] > rngfiltBuffer[i+1] ? 0 : downwardBuffer[i+1];
   }

   for(int i=BARS;i>=0;i--)
   {
      lbandBuffer[i] = rngfiltBuffer[i]-smoothrngBuffer[i];
      hbandBuffer[i] = rngfiltBuffer[i]+smoothrngBuffer[i];
   }

   for(int i=BARS;i>=0;i--)
   {
      rngfiltColors[i]= upwardBuffer[i] > 0 ? 0 : downwardBuffer[i] > 0 ? 1 : 2;
      Label1Colors[i] = price(i, src) > rngfiltBuffer[i] && price(i, src) > price(i+1, src) && upwardBuffer[i] > 0 ? 0 : 
      price(i, src) > rngfiltBuffer[i] && price(i, src) < price(i+1, src) && upwardBuffer[i] > 0 ? 1 : 
      price(i, src) < rngfiltBuffer[i] && price(i, src) < price(i+1, src) && downwardBuffer[i] > 0 ? 2 : 
      price(i, src) < rngfiltBuffer[i] && price(i, src) > price(i+1, src) && downwardBuffer[i] > 0 ? 3 : 4;
      Label1Buffer1[i]=price(i, PRICE_OPEN);
      Label1Buffer2[i]=price(i, PRICE_HIGH);
      Label1Buffer3[i]=price(i, PRICE_LOW);
      Label1Buffer4[i]=price(i, PRICE_CLOSE);
   }
   
   //////////////////////////////////////////////
   if(BARS==Bars(_Symbol,PERIOD_CURRENT)-100)
   {
      ObjectsDeleteAll(0,prefix);
      for(int i=BARS;i>=0;i--)
      {
         if(rngfiltColors[i+1]==0 && rngfiltColors[i+2]==1)
         {
            DrawUpArrow(i, "Long");
            BuyBuffer[i]=1;
            SellBuffer[i]=0;
         }
         else if(rngfiltColors[i+1]==1 && rngfiltColors[i+2]==0)
         {
            DrawDownArrow(i, "Short");
            BuyBuffer[i]=0;
            SellBuffer[i]=1;
         }
      }
      return rates_total;
   }

   //////////////////////////////////////////////   
   manageAlerts(time[rates_total-1],time[rates_total-2]);
   return(rates_total);
}

void manageAlerts(datetime currTime, datetime prevTime)
{

   if (AlertsOn)
   {
      datetime time = currTime;
      int whichBar = 0; if (!AlertsOnCurrent) { whichBar = 1; time = prevTime; }
      
      /*if(useAlerts && rngfiltColors[1]==0 && rngfiltColors[2]==1)
         Alert(prefix+" Long: "+_Symbol+" Period:M-"+(string)(PeriodSeconds(PERIOD_CURRENT)/60));
      else if(useAlerts && rngfiltColors[1]==1 && rngfiltColors[2]==0)
         Alert(prefix+" Short: "+_Symbol+" Period:M-"+(string)(PeriodSeconds(PERIOD_CURRENT)/60));*/
      
      if ( price(whichBar+1, PRICE_CLOSE) < rngfiltBuffer[whichBar+1] && 
               price(whichBar, PRICE_OPEN) < rngfiltBuffer[whichBar] && price(whichBar, PRICE_CLOSE) >= rngfiltBuffer[whichBar]) {
         doAlert(time," LONG");
      }
      if ( price(whichBar+1, PRICE_CLOSE) > rngfiltBuffer[whichBar+1] && 
               price(whichBar, PRICE_OPEN) > rngfiltBuffer[whichBar] && price(whichBar, PRICE_CLOSE) <= rngfiltBuffer[whichBar]) {
         doAlert(time,"SHORT");
      }      
     
   }
}   

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      message = doWhat + " @ " + _Symbol + " : M-"+(string)(PeriodSeconds(PERIOD_CURRENT)/60) + " [tilly]";
      if (AlertsMessage) Alert(message);
      if (AlertsEmail)   SendMail("Alert @tilly " + _Symbol,message);
      if (AlertsNotify)  SendNotification(message);
      if (AlertsSound)   PlaySound("alert2.wav");
   }
}

double price(int i, ENUM_APPLIED_PRICE applied)
{
   if(useHA)
   {
      if(applied==PRICE_CLOSE)
      {
         double array[];
         ArraySetAsSeries(array, true);
         CopyBuffer(ashi_handle, 3, i, 1, array);
         return array[0];
      }
      else if(applied==PRICE_OPEN)
      {
         double array[];
         ArraySetAsSeries(array, true);
         CopyBuffer(ashi_handle, 0, i, 1, array);
         return array[0];
      }
      if(applied==PRICE_HIGH)
      {
         double array[];
         ArraySetAsSeries(array, true);
         CopyBuffer(ashi_handle, 1, i, 1, array);
         return array[0];
      }
      if(applied==PRICE_LOW)
      {
         double array[];
         ArraySetAsSeries(array, true);
         CopyBuffer(ashi_handle, 2, i, 1, array);
         return array[0];
      }
   }
   if(applied==PRICE_CLOSE) return iClose(_Symbol,PERIOD_CURRENT,i);
   if(applied==PRICE_OPEN) return iOpen(_Symbol,PERIOD_CURRENT,i);
   if(applied==PRICE_HIGH) return iHigh(_Symbol,PERIOD_CURRENT,i);
   if(applied==PRICE_LOW) return iLow(_Symbol,PERIOD_CURRENT,i);
   return -1;
}

int kk=0;

void DrawDownArrow(int i,string txt)
{
   if (!DrawArrows) return;
   double xx = ATR(i);
   ObjectCreate(ChartID(), prefix+"OBJ_TEXT"+string(kk++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,i+3), hbandBuffer[i]+1*xx);
   ObjectCreate(ChartID(), prefix+"OBJ_ARROW"+string(kk-1), OBJ_ARROW_DOWN, 0, iTime(_Symbol, PERIOD_CURRENT,i+1),hbandBuffer[i]+0.5*xx);
   ObjectSetString(ChartID(), prefix+"OBJ_TEXT"+string(kk-1), OBJPROP_TEXT, txt);
   ObjectSetInteger(ChartID(), prefix+"OBJ_TEXT"+string(kk-1), OBJPROP_COLOR, clrRed);
   ObjectSetInteger(ChartID(), prefix+"OBJ_ARROW"+string(kk-1), OBJPROP_COLOR, clrRed);
}


void DrawUpArrow(int i, string txt)
{
   if (!DrawArrows) return;
   double xx = ATR(i);
   ObjectCreate(ChartID(), prefix+"OBJ_TEXT"+string(kk++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,i+3),lbandBuffer[i]-0.5*xx);
   ObjectCreate(ChartID(), prefix+"OBJ_ARROW"+string(kk-1), OBJ_ARROW_UP, 0, iTime(_Symbol, PERIOD_CURRENT,i+1),lbandBuffer[i]);
   ObjectSetString(ChartID(), prefix+"OBJ_TEXT"+string(kk-1), OBJPROP_TEXT, txt);
   ObjectSetInteger(ChartID(), prefix+"OBJ_TEXT"+string(kk-1), OBJPROP_COLOR, clrLimeGreen);
   ObjectSetInteger(ChartID(), prefix+"OBJ_ARROW"+string(kk-1), OBJPROP_COLOR, clrLimeGreen);
}

double ATR(int i)
{
   double array[];
   ArraySetAsSeries(array, true);
   CopyBuffer(atr_handle, 0, i, 1, array);
   return array[0];
}

