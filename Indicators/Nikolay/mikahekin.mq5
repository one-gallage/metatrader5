//+------------------------------------------------------------------+ 
//|                                                    Mikahekin.mq5 | 
//|                                                                  | 
//|                              Modified by: Ronald Verwer/ROVERCOM |
//+------------------------------------------------------------------+ 
#property copyright ""
#property link ""
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 5
#property indicator_buffers 5 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- Gray, Red and Lime colors are used for the indicator
#property indicator_color1 Gray,Red,Lime
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 5
#property indicator_width1  5
//---- displaying the indicator label
#property indicator_label1  "Signal"

//---- drawing the indicator as a label
#property indicator_type2   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color2 Magenta
//---- indicator width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Buy StopLoss"

//---- drawing the indicator as a label
#property indicator_type3   DRAW_ARROW
//---- blue color is used for the indicator
#property indicator_color3 Blue
//---- indicator width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Sell StopLoss"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int KPeriod=3;
input int JPeriod=7;
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double UpperBuffer[];
double LowerBuffer[];
double OpMiddleBuffer[];
double ClMiddleBuffer[];
double ColorMiddleBuffer[];
//---- declaration of global variables
int Count[];
double Highest[],Lowest[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[]) // Return the current value of the price series by the link
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=MathMax(KPeriod,JPeriod);
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of constants
   min_rates_total=KPeriod+JPeriod;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,JPeriod);
   ArrayResize(Highest,JPeriod);
   ArrayResize(Lowest,JPeriod);
   
   ArrayInitialize(Count,0);
   ArrayInitialize(Highest,0.0);
   ArrayInitialize(Lowest,0.0);

//---- set OpMiddleBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,OpMiddleBuffer,INDICATOR_CALCULATIONS);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(OpMiddleBuffer,true);

//---- set ClMiddleBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ClMiddleBuffer,INDICATOR_CALCULATIONS);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ClMiddleBuffer,true);

//---- set ColorMiddleBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(2,ColorMiddleBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ColorMiddleBuffer,true);

//---- set UpperBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,UpperBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(UpperBuffer,true);

//---- set LowerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(LowerBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Mikahekin( ",KPeriod,", ",JPeriod," )");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double sumlow,sumhigh,sumopen,sumclose,Max,Min,Op,Cl;
//---- declaration of integer variables
   int limit,bar;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-KPeriod-1;                       // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;               // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- main cycle of calculation of the channel center line
   for(bar=limit; bar>=0; bar--)
     {
      Highest[Count[0]]=high[ArrayMaximum(high,bar,KPeriod)];
      Lowest [Count[0]]=low [ArrayMinimum(low, bar,KPeriod)];

      if(bar>rates_total-min_rates_total-1)
        {
         Recount_ArrayZeroPos(Count);
         continue;
        }

      sumlow=0.0;
      sumhigh=0.0;
      sumopen=0.0;
      sumclose=0.0;

      for(int kkk=0; kkk<JPeriod; kkk++)
        {
         sumopen+=open[bar+kkk];
         sumclose+=close[bar+kkk];

         sumlow +=Lowest [Count[kkk]];
         sumhigh+=Highest[Count[kkk]];
        }

      Op=sumopen /JPeriod;
      Cl=sumclose/JPeriod;

      Max=MathMax(Op,Cl);
      Min=MathMin(Op,Cl);

      if(!(Max-Min)) Max+=_Point;

      ClMiddleBuffer[bar]=Max;
      OpMiddleBuffer[bar]=Min;

      ColorMiddleBuffer[bar]=0;
      if(Cl>Op) ColorMiddleBuffer[bar]=2;
      if(Cl<Op) ColorMiddleBuffer[bar]=1;


      UpperBuffer[bar]=sumhigh/JPeriod;
      LowerBuffer[bar]=sumlow /JPeriod;

      if(bar>0) Recount_ArrayZeroPos(Count);
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
