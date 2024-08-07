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
#property description "tilly_solar_winds"
#property description "© ErangaGallage"
#property strict

#property indicator_separate_window 
#property indicator_buffers 3 
#property indicator_plots   3

#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrGray,clrRed,clrFireBrick,clrTeal,clrChartreuse
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

input int period=7; //period of averaging

int min_rates_total;
double IndBuffer[], ColorIndBuffer[], MomBuffer[];

void OnInit() {
   min_rates_total=period;

   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   ArraySetAsSeries(IndBuffer,true);
   
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer,true);
   
   SetIndexBuffer(2,MomBuffer,INDICATOR_DATA);
   ArraySetAsSeries(MomBuffer,true); 

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
}
 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
                
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,bar;
   double Value,SolarWinds,price,MinL,MaxH,Res;
   static double Prev_Value;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0) { // checking for the first start of the indicator calculation
     
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
      Prev_Value=0.0;
      IndBuffer[limit+1]=0.0;
   }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--) {
      MaxH=high[ArrayMaximum(high,bar,period)];
      MinL=low[ArrayMinimum(low,bar,period)];
      price=(high[bar]+low[bar])/2;
      Res=MaxH-MinL;
      Value=0.0;
      if(Res) Value=0.33*2*((price-MinL)/Res-0.5)+0.67*Prev_Value;
      Value=MathMin(MathMax(Value,-0.999),0.999);

      Res=1-Value;
      if(Res) SolarWinds=0.5*MathLog((1+Value)/(1-Value))+0.5*IndBuffer[bar+1];
      else SolarWinds=0.0;
      
      //---- saving values of variables
      if(bar) Prev_Value=Value;

      IndBuffer[bar]=SolarWinds;
      ColorIndBuffer[bar]=0;

      if(SolarWinds>0) {
         if(SolarWinds>IndBuffer[bar+1]) ColorIndBuffer[bar]=4;
         if(SolarWinds<IndBuffer[bar+1]) ColorIndBuffer[bar]=3;
      }

      if(SolarWinds<0) {
         if(SolarWinds<IndBuffer[bar+1]) ColorIndBuffer[bar]=1;
         if(SolarWinds>IndBuffer[bar+1]) ColorIndBuffer[bar]=2;
      }
        
      MomBuffer[bar] = ColorIndBuffer[bar];
   }
    
   return(rates_total);
}

//+------------------------------------------------------------------+
