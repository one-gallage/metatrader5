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
#property description "tilly_fvg"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_plots  0
//-------------------------

//-------------------------

enum EMY_FVG_TYPE {
   FVG_UP,
   FVG_DN
};

class CMyFairValueGap {
   public:
      EMY_FVG_TYPE type;
      datetime time;
      double high;
      double low;
      
      void draw(datetime _time2) {
         string objName = prefix + "box_" + TimeToString(time);
         if(ObjectFind(0, objName) < 0) {
            ObjectCreate(0, objName, OBJ_RECTANGLE,0, time, high, _time2, low);
            ObjectSetInteger(0, objName, OBJPROP_FILL, true);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, type == FVG_UP ? clrLightGreen : clrLightGoldenrod);
         }
      }
};

//-------------------------
string prefix;
int  min_rates_total;

#define RESET  0

int OnInit()
{

   string shortname = "tilly_fvg";
   prefix = shortname+"_";

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   min_rates_total = int(20);   
  
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, prefix);
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

   to_copy = limit+3;
   
   ArraySetAsSeries(time,true); 
   ArraySetAsSeries(open,true);   
   ArraySetAsSeries(high,true);     
   ArraySetAsSeries(low,true);     
   ArraySetAsSeries(close,true); 
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);        
   
   double MA_UP[],MA_DN[],BB_UP[],BB_DN[],MA_HIGH[],MA_LOW[],OsMA[];
   
   for(bar=limit; bar>=1 && !IsStopped(); bar--) {
      bool is_fvg_up = high[bar+2] < low[bar];
      bool is_fvg_dn = low[bar+2] > high[bar];
      
      if ( is_fvg_up || is_fvg_dn ) {
         CMyFairValueGap fvg;
         fvg.type = is_fvg_up ? FVG_UP : FVG_DN;
         fvg.time = time[bar];
         fvg.high = is_fvg_up ? low[bar] : low[bar+2];
         fvg.low = is_fvg_up ? high[bar+2] : high[bar];
         fvg.draw(time[bar]+ PeriodSeconds(PERIOD_CURRENT)*10);
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
