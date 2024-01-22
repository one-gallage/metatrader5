//+------------------------------------------------------------------+ 
//|                                                      yEffekt.mq5 | 
//|                                         Copyright © 2008, MNS777 | 
//|                                                mns777.ru@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, MNS777"
#property link "mns777.ru@mail.ru" 
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color1 Gray,Teal,DarkViolet,IndianRed,Magenta
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator histogram label
#property indicator_label1 "yEffekt"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 +0.5
#property indicator_level2  0.0
#property indicator_level3 -0.5
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| yEffekt indicator initialization function                        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=5;

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- set ColorIndBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ColorIndBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname="yEffekt";
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| yEffekt iteration function                                       | 
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
//---- declaration of integer variables
   int limit1,limit2,bar;
//---- declaration of variables with a floating point  
   double Index;
//---- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit1=rates_total-1-min_rates_total; // starting index for calculation of all first loop bars
      limit2=limit1-1;                      // starting index for calculation of all second loop bars
     }
   else // starting index for calculation of new bars
     {
      limit1=rates_total-prev_calculated;
      limit2=limit1;
     }
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- main indicator calculation loop
   for(bar=limit1; bar>=0; bar--)
     {
      Index=(high[bar]-low[bar])+(high[bar+1]-low[bar+1])+(high[bar+2]-low[bar+2])+(high[bar+3]-low[bar+3])+(high[bar+4]-low[bar+4]);

      if(Index!=0.0)
        {
         if(high[bar] > low[bar+4] ) IndBuffer[bar]=(high[bar]-low[bar+4])/Index;
         if(low[bar]  < high[bar+4]) IndBuffer[bar]=(low[bar] - high[bar+4] )/Index;
        }
      else IndBuffer[bar]=0.0;

     }
//---- main loop of the Ind indicator coloring
   for(bar=limit2; bar>=0; bar--)
     {
      ColorIndBuffer[bar]=0;

      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar+1]) ColorIndBuffer[bar]=1;
         if(IndBuffer[bar]<IndBuffer[bar+1]) ColorIndBuffer[bar]=2;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar+1]) ColorIndBuffer[bar]=3;
         if(IndBuffer[bar]>IndBuffer[bar+1]) ColorIndBuffer[bar]=4;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+