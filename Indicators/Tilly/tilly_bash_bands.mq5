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
#property description "tilly_bash_bands"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

#property   indicator_label1  "band-high"
#property   indicator_color1  clrBlueViolet
#property   indicator_style1  STYLE_SOLID
#property   indicator_width1  1

#property   indicator_label2  "band-low"
#property   indicator_color2  clrBlueViolet
#property   indicator_style2  STYLE_SOLID
#property   indicator_width2  1

#property   indicator_label3  "band-center"
#property   indicator_color3  clrGoldenrod
#property   indicator_style3  STYLE_SOLID
#property   indicator_width3  2

#property   indicator_label4  "arrow-up"
#property   indicator_color4  clrDeepSkyBlue
#property   indicator_style4  STYLE_SOLID
#property   indicator_width4  2

#property   indicator_label5  "arrow-dn"
#property   indicator_color5  clrTomato
#property   indicator_style5  STYLE_SOLID
#property   indicator_width5  2


//-------------------------
input group  " "  
input int      MA_Period            = 9;     // Bash Lookback
input int      BB_Period            = 20;    // Band Period
input double   Std                  = 1.0;   // Band Deviation
//input double   Std                  = 0.4;   // Band Deviation
input group  " "  
input bool     UseArrows            = true;  // Show Signals
input bool     UseLines             = false;  // Show Lines
input int      OsMA_FastEMA_Period  = 3;     // Fast EMA
input int      OsMA_SlowEMA_Period  = 5;     // Slow EMA
input int      OsMA_Signal_Period   = 2;     // Signal EMA

//input int      OsMA_FastEMA_Period  = 1;     // Fast EMA
//input int      OsMA_SlowEMA_Period  = 3;     // Slow EMA
//input int      OsMA_Signal_Period   = 2;     // Signal EMA
int      Shift=0;

//-------------------------
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double UpMapBuffer[];
double DnMapBuffer[];

//-------------------------
string prefix;
int  min_rates_total;
int handle_MA_UP = 0;
int handle_MA_DN = 0;
int handle_BB_UP = 0;
int handle_BB_DN = 0;
int handle_MA_HIGH = 0;
int handle_MA_LOW = 0;
int handle_OsMA = 0;

ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; 
int Dist2 = 20;
#define RESET  0

int OnInit()
{

   string shortname = "YAY-Bash-Bands";
   prefix = shortname+"-";

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   min_rates_total = int(BB_Period);
  
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
   ArraySetAsSeries(ExtMapBuffer1,true);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   if(UseLines)PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE); else PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   
   //PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
   ArraySetAsSeries(ExtMapBuffer2,true);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   if(UseLines)PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE); else PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   
   SetIndexBuffer(2,ExtMapBuffer3,INDICATOR_DATA);
   ArraySetAsSeries(ExtMapBuffer3,true);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   if(UseLines)PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE); else PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   
   SetIndexBuffer(3,UpMapBuffer,INDICATOR_DATA);
   ArraySetAsSeries(UpMapBuffer,true);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   if(UseArrows)PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_ARROW); else PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);    
   PlotIndexSetInteger(3,PLOT_ARROW,233);  

   SetIndexBuffer(4,DnMapBuffer,INDICATOR_DATA);   
   ArraySetAsSeries(DnMapBuffer,true);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
   if(UseArrows)PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_ARROW); else PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);    
   PlotIndexSetInteger(4,PLOT_ARROW,234);  
   
   if((handle_MA_UP = iMA(NULL,0,MA_Period,0,MODE_SMA,PRICE_HIGH)) == INVALID_HANDLE ) return(INIT_FAILED);
   if((handle_MA_DN = iMA(NULL,0,MA_Period,0,MODE_SMA,PRICE_LOW)) == INVALID_HANDLE ) return(INIT_FAILED);
   if((handle_BB_UP = iBands(NULL,0,BB_Period,0,Std,PRICE_HIGH)) == INVALID_HANDLE ) return(INIT_FAILED);
   if((handle_BB_DN = iBands(NULL,0,BB_Period,0,Std,PRICE_LOW)) == INVALID_HANDLE ) return(INIT_FAILED);
   if((handle_MA_HIGH = iMA(NULL,0,4,0,MODE_LWMA,PRICE_HIGH)) == INVALID_HANDLE ) return(INIT_FAILED);
   if((handle_MA_LOW = iMA(NULL,0,4,0,MODE_LWMA,PRICE_LOW)) == INVALID_HANDLE ) return(INIT_FAILED);
   if((handle_OsMA = iOsMA(NULL,0,OsMA_FastEMA_Period,OsMA_SlowEMA_Period,OsMA_Signal_Period,PRICE_CLOSE)) == INVALID_HANDLE ) return(INIT_FAILED);
     
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

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
      limit=rates_total-min_rates_total;       // starting index for calculation of all bars
   }
   else {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
   }

   to_copy = limit+3;
   
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else ArraySetAsSeries(volume,true); 
   ArraySetAsSeries(open,true);   
   ArraySetAsSeries(high,true);     
   ArraySetAsSeries(low,true);     
   ArraySetAsSeries(close,true);     
   
   double MA_UP[],MA_DN[],BB_UP[],BB_DN[],MA_HIGH[],MA_LOW[],OsMA[];
   
   if(copyHandleValue(handle_MA_UP, 0, to_copy, MA_UP) == false) return(RESET); 
   if(copyHandleValue(handle_MA_DN, 0, to_copy, MA_DN) == false) return(RESET); 
   if(copyHandleValue(handle_BB_UP, 1, to_copy, BB_UP) == false) return(RESET); 
   if(copyHandleValue(handle_BB_DN, 2, to_copy, BB_DN) == false) return(RESET); 
   if(copyHandleValue(handle_MA_HIGH, 0, to_copy, MA_HIGH) == false) return(RESET); 
   if(copyHandleValue(handle_MA_LOW, 0, to_copy, MA_LOW) == false) return(RESET); 
   if(copyHandleValue(handle_OsMA, 0, to_copy, OsMA) == false) return(RESET); 
  
   for(bar=limit; bar>=0 && !IsStopped(); bar--) {                  
          
      if(MA_UP[bar] > BB_UP[bar]) {
            ExtMapBuffer1[bar] = MA_UP[bar] + Dist2*_Point; 
      }
      else {
            ExtMapBuffer1[bar] = BB_UP[bar] + Dist2*_Point; 
      }
   
    
      if(MA_DN[bar] < BB_DN[bar]) {
            ExtMapBuffer2[bar] = MA_DN[bar] - Dist2*_Point;
      }
      else {
            ExtMapBuffer2[bar] = BB_DN[bar] - Dist2*_Point;
      }
      
      ExtMapBuffer3[bar]= ( ExtMapBuffer1[bar]+ExtMapBuffer2[bar])/2.0 ;        
   
        
      double OsMA_Now = OsMA[bar];  
      double OsMA_Pre = OsMA[bar+1]; 
      
          
      if( (OsMA_Now<0 && OsMA_Pre>0) && MA_HIGH[bar] > ExtMapBuffer1[bar] && high[bar] > ExtMapBuffer1[bar] ) {
         DnMapBuffer[bar] = high[bar] + Dist2*_Point;         
      }
      else {
         DnMapBuffer[bar] = EMPTY_VALUE;
      }      
      if( (OsMA_Now>0 && OsMA_Pre<0)&& MA_LOW[bar] < ExtMapBuffer2[bar] && low[bar] < ExtMapBuffer2[bar] ) {
         UpMapBuffer[bar] = low[bar] - Dist2*_Point;      
      }
      else{
         UpMapBuffer[bar] = EMPTY_VALUE;
      } 
       
   }
 
   return(rates_total);
}

bool copyHandleValue(int ind_handle, int buffer_num,int copy_count, double& return_array[] )
{
   ArraySetAsSeries(return_array, true);
   return CopyBuffer(ind_handle, buffer_num, 0, copy_count, return_array)>0;
}

//+------------------------------------------------------------------+
