//+------------------------------------------------------------------+
//|                                       InventoryRetracemenBar.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//---reference zigzag indicator
#resource "\\Indicators\\zigzagcolor.ex5"
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrCoral
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Lower
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrCornflowerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
bool     CalculateOnBarClose=true;
double retracementBuy = 45;//retracement amount buys (in %)
double retracementSell = 45;//retracement amount sells (in %)
int      nShift=0;//ArrowShift_points

//--- indicator buffers
double UpperBuffer[];
double LowerBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,238);
   PlotIndexSetInteger(1,PLOT_ARROW,236);
//---   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE, EMPTY_VALUE);
//---
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int limit,i,first=0;
//---
   if(prev_calculated<=0)limit=rates_total-1;
   else limit=1;

//---   
   if(CalculateOnBarClose) first=1;
//---main loop
   for(i=limit;i>=first;i--) {
      UpperBuffer[i] = EMPTY_VALUE;
      LowerBuffer[i] = EMPTY_VALUE;
      
      double c0 = iClose(NULL,0,i);
      double o0 = iOpen(NULL,0,i);
      double high0 = iHigh(NULL,0,i);
      double low0 = iLow(NULL,0,i);
            
      if (high0 - MathMax(o0, c0) > (high0-low0) * retracementBuy / 100.0) {
         UpperBuffer[i] = low0 - (2*nShift)*_Point;              
      }
      if (MathMin(o0, c0) - low0 > (high0-low0) * retracementSell / 100.0) {
         LowerBuffer[i] = high0 + (2*nShift)*_Point;            
      }  

   }
//--- return value of prev_calculated for next call
   return(rates_total);
}

