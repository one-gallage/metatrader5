//+------------------------------------------------------------------+
//|                                                   BullsBears.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//|                                                   vasbsm@mail.ru |
//+------------------------------------------------------------------+
#property copyright   "2009, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Bulls Bears Power"
//--- indicator settings ---
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  CornflowerBlue
#property indicator_width1  2
//--- input parameters ---
input int InpPeriod=13; // Period
input ENUM_MA_METHOD TypeMA=MODE_EMA;           // Smoothing method
input ENUM_APPLIED_PRICE TypePrice=PRICE_CLOSE; // Applied price
//--- Buffers
double    ExtBBBuffer[];
double    ExtTempBuffer[];
//--- MA handle
int       ExtEmaHandle;
//--- initialization function
void OnInit()
  {
//--- define buffers
   SetIndexBuffer(0,ExtBBBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTempBuffer,INDICATOR_CALCULATIONS);
//--- set buffer accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- set draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriod-1);
//--- set indicator name
   IndicatorSetString(INDICATOR_SHORTNAME,"Bulls Bears Power("+(string)InpPeriod+")");
//--- average
   ExtEmaHandle=iMA(NULL,0,InpPeriod,0,TypeMA,TypePrice);
  }
//--- Custom indicator iteration function
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i,limit;

   if(rates_total<InpPeriod) return(0); // insufficient bars for calculation

   int calculated=BarsCalculated(ExtEmaHandle);

   if(calculated<rates_total)
     {
      Print("The last calculated bar is ",calculated,". Error.",GetLastError());
      return(0);
     }

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }

   if(CopyBuffer(ExtEmaHandle,0,0,to_copy,ExtTempBuffer)<=0)
     {
      Print("Error in call of CopyBuffer",GetLastError());
      return(0);
     }

   if(prev_calculated<InpPeriod)limit=InpPeriod;
   else limit=prev_calculated-1;

//--- Calculation of the indicator
   for(i=limit;i<rates_total;i++)
     {
      ExtBBBuffer[i]=High[i]+Low[i]-2*ExtTempBuffer[i];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+