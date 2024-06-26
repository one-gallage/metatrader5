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

#property version   "1.0"
#property description "tilly_envelope"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_framework.mqh>

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4

#property indicator_label1  "x_angle"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "x_upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreenYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "x_lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "x_ma"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDodgerBlue, clrRosyBrown
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1


input group  "---------------------------------"  
ENUM_APPLIED_PRICE SOURCE     = PRICE_CLOSE;           //Source
input int      InpEMALength         = 50;     // MA Length
input int      InpAngleCalPeriod    = 3;     // Angle Calc Period
input double   InpDeviation         = 0.1;            // Deviation


//-------------------------

#define RESET  0

//-------------------------

double angle_buffer[], ema_buffer[], ema_color_buffer[], upper_buffer[], lower_buffer[];

int handle_ema = 0;

string prefix;
int  min_rates_total;
int   ind_shift=0;

int OnInit()
{
   string shortname = MQLInfoString(MQL_PROGRAM_NAME);
   prefix = shortname+"_";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

   min_rates_total = int(InpEMALength);   
   
   int index = 0;   
   SetIndexBuffer(index,angle_buffer,INDICATOR_DATA);
   ArraySetAsSeries(angle_buffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(index,PLOT_SHIFT,ind_shift);   
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   index = 1;
   SetIndexBuffer(index,upper_buffer,INDICATOR_DATA);
   ArraySetAsSeries(upper_buffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(index,PLOT_SHIFT,ind_shift);   
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);   
   index = 2;
   SetIndexBuffer(index,lower_buffer,INDICATOR_DATA);
   ArraySetAsSeries(lower_buffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(index,PLOT_SHIFT,ind_shift);   
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);   
   index = 3;
   SetIndexBuffer(index,ema_buffer,INDICATOR_DATA);
   ArraySetAsSeries(ema_buffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(index,PLOT_SHIFT,ind_shift);   
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);  
   index = 4;
   SetIndexBuffer(index,ema_color_buffer,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(ema_color_buffer,true);   
         
   if((handle_ema = iDEMA(NULL,0,InpEMALength,0,PRICE_CLOSE)) == INVALID_HANDLE ) return(INIT_FAILED);
     
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(handle_ema);
   ObjectsDeleteAll(0, prefix);
   ChartRedraw();
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

   int to_copy,limit,bar;
   
   if(prev_calculated>rates_total || prev_calculated<=0) { 
      limit = rates_total - min_rates_total; // starting index for calculation of all bars
   }
   else {
      limit = rates_total - prev_calculated; // starting index for calculation of new bars
   }
   to_copy = limit+3+InpAngleCalPeriod;
   
   ArraySetAsSeries(time,true); 
   ArraySetAsSeries(open,true);   
   ArraySetAsSeries(high,true);     
   ArraySetAsSeries(low,true);     
   ArraySetAsSeries(close,true); 
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);        
   
   double ARR_EMA[];   
   if(copyHandleValue(handle_ema, 0, to_copy, ARR_EMA) == false) return(RESET);    
   
   angle_buffer[0] = EMPTY_VALUE;   
   ema_buffer[0] = EMPTY_VALUE; 
   upper_buffer[0] = EMPTY_VALUE; lower_buffer[0] = EMPTY_VALUE;
   for(bar=limit; bar>=1 && !IsStopped(); bar--) {
      angle_buffer[bar] = CMyUtil::MathGetAngle(ARR_EMA[bar], ARR_EMA[bar+InpAngleCalPeriod], InpAngleCalPeriod); 
      ema_buffer[bar] = ARR_EMA[bar];     
      if ( angle_buffer[bar] < 0 ) {
         ema_color_buffer[bar] = 1;
      } else {
         ema_color_buffer[bar] = 0;
      }      
      upper_buffer[bar] = (1+InpDeviation/100.0)*ARR_EMA[bar];
      lower_buffer[bar] = (1-InpDeviation/100.0)*ARR_EMA[bar];      
   }
 
   return(rates_total);
}

bool copyHandleValue(int ind_handle, int buffer_num,int copy_count, double& return_array[] )
{
   ArraySetAsSeries(return_array, true);
   return CopyBuffer(ind_handle, buffer_num, 0, copy_count, return_array)>0;
}

//+------------------------------------------------------------------+
