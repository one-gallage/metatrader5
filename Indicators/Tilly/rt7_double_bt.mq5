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
#property description "rt7_double_bt"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot TopDbl
#property indicator_label1  "Double Top"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGold 
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed 
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BottomDbl
#property indicator_label3  "Double Bottom"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrGreen 
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- Signal
#property indicator_label5  "Signal"
#property indicator_type5   DRAW_NONE
#property indicator_color5  clrNONE
//--- Trend
#property indicator_label6  "Trend"
#property indicator_type6   DRAW_NONE
#property indicator_color6  clrNONE  


//--- input parameters
input uint     InpMinHeight   =  10;   // Minumum Height/Depth
input uint     InpMaxDist     =  20;   // Maximum distance between the twin tops/bottoms
input uint     InpMinBars     =  0;    // Maximum number of bars after the top/bottom
//input uint     InpMinBars     =  3;    // Maximum number of bars after the top/bottom

input bool     AlertsOn        = false;         // Turn alerts on?
bool           AlertsOnCurrent = false;         // Alert on current bar?
input bool     AlertsMessage   = false;         // Display messageas on alerts?
bool           AlertsSound     = false;         // Play sound on alerts?
bool           AlertsEmail     = false;         // Send email on alerts?
input bool     AlertsNotify    = false;         // Send push notification on alerts?

//--- indicator buffers
double         BufferTop[];
double         BufferTopDBL[];
double         BufferBottom[];
double         BufferBottomDBL[];
double         BufferSignal[];
double         BufferTrend[];
//--- global variables
double         min_height;
int            min_hgt;
int            min_bars;
int            max_dist;


int OnInit()
{
   min_hgt=int(InpMinHeight<1 ? 1 : InpMinHeight);
   min_height=min_hgt*Point();
   min_bars=int(InpMinBars<1 ? 1 : InpMinBars);
   max_dist=int(InpMaxDist<1 ? 1 : InpMaxDist);
   
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferTopDBL,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferBottomDBL,true);   
   ArraySetAsSeries(BufferSignal,true);   
   ArraySetAsSeries(BufferTrend,true);   

   SetIndexBuffer(0,BufferTopDBL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottomDBL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(4,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(5,BufferTrend,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,82);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,82);
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   //IndicatorSetString(INDICATOR_SHORTNAME,"rt7_double_bt(Min height: "+(string)min_hgt+", max distance: "+(string)max_dist+", min bars: "+(string)min_bars+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());

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

   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

   /*if(rates_total<fmax(min_bars,4)) return 0;
   int limit=rates_total-prev_calculated;
   if(limit>1) {
      limit=rates_total-min_bars-1;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferTopDBL,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferBottomDBL,EMPTY_VALUE);
   }*/
   
   int limit;
   if(prev_calculated>rates_total || prev_calculated<=0) { 
      limit = rates_total - min_bars - 1; // starting index for calculation of all bars
   }
   else {
      limit = rates_total - prev_calculated; // starting index for calculation of new bars
   }   

   for(int i=limit; i>=0 && !IsStopped(); i--) {
      BufferBottom[i]=BufferBottomDBL[i]=BufferTop[i]=BufferTopDBL[i]=EMPTY_VALUE;
      BufferTop[i+min_bars]=(IsTop(rates_total,i+min_bars,high,low) ? high[i+min_bars] : EMPTY_VALUE);
      BufferBottom[i+min_bars]=(IsBottom(rates_total,i+min_bars,high,low) ? low[i+min_bars] : EMPTY_VALUE);
     
      if(BufferTop[i+min_bars]==high[i+min_bars]) {
         if(FindPrevTop(rates_total,i+min_bars,high)) {
            BufferTopDBL[i+min_bars]=high[i+min_bars];
         } else {
            BufferTopDBL[i+min_bars]=EMPTY_VALUE;
         }
      }

      if(BufferBottom[i+min_bars]==low[i+min_bars]) {
         if(FindPrevBottom(rates_total,i+min_bars,low)) {
            BufferBottomDBL[i+min_bars]=low[i+min_bars];
         } else {
            BufferBottomDBL[i+min_bars]=EMPTY_VALUE;
         }
      }
      
      ///////////////////// signal and trend buffers

      BufferSignal[i] = 0;
      BufferTrend[i] = BufferTrend[i+1]; 
      
      if ( BufferTop[i+min_bars] != EMPTY_VALUE && BufferTopDBL[i+min_bars] != EMPTY_VALUE ) {
         BufferSignal[i] = -1;
         BufferTrend[i] = -1;      
      }
      else if ( BufferBottom[i+min_bars] != EMPTY_VALUE && BufferBottomDBL[i+min_bars] != EMPTY_VALUE ) {
         BufferSignal[i] = 1;
         BufferTrend[i] = 1;      
      }      
            
      if( BufferTop[i+min_bars] != EMPTY_VALUE && BufferBottom[i+min_bars] != EMPTY_VALUE) {
            BufferSignal[i] = 0;
            BufferTrend[i] = 0;      
      }
      
   }
   
   manageAlerts();
   return(rates_total);
}

bool IsTop(const int rates_total,const int index,const double &high[],const double &low[])
{
   bool fl=true;
   for(int i=1; i<=min_bars; i++)
      if(high[index-i]>=high[index]) fl=false;
   if(fl)
     {
      int i=index+1;
      while(i<rates_total)
        {
         if(high[i]>=high[index]) return false;
         if(high[index]-low[i]>=min_height) return true;
         i++;
        }
     }
   return false;
}

bool IsBottom(const int rates_total,const int index,const double &high[],const double &low[])
{
   bool fl=true;
   for(int i=1; i<=min_bars; i++)
      if(low[index-i]<=low[index]) fl=false;
   if(fl)
     {
      int i=index+1;
      while(i<rates_total)
        {
         if(low[i]<=low[index]) return false;
         if(high[i]-low[index]>=min_height) return true;
         i++;
        }
     }
   return false;
}

bool FindPrevTop(const int rates_total,const int index,const double &high[])
{
   int i=index+1;
   while(i<rates_total && i<=index+max_dist)
     {
      if(BufferTop[i]==high[i]) return true;
      i++;
     }
   return false;
}

bool FindPrevBottom(const int rates_total,const int index,const double &low[])
{
   int i=index+1;
   while(i<rates_total && i<=index+max_dist)
     {
      if(BufferBottom[i]==low[i]) return true;
      i++;
     }
   return false;
}


void manageAlerts()
{
   if (AlertsOn)
   {
      int whichBar = 0; if (AlertsOnCurrent == false) { whichBar = 1; }

      int bar_number = iBars(_Symbol, 0);
      static int var_last_bar_number = bar_number;
      if ( bar_number > var_last_bar_number ) {
         var_last_bar_number = bar_number;
         //m_ok_new_bar = true;                  
      } else { 
         //m_ok_new_bar = false;
         return; 
      }       

      if ( BufferBottomDBL[whichBar] != EMPTY_VALUE && BufferBottomDBL[whichBar] > 0 ) {
         doAlert(" LONG");
      }
      if ( BufferTopDBL[whichBar] != EMPTY_VALUE && BufferTopDBL[whichBar] > 0 ) {
         doAlert("SHORT");
      }  
   }
}   

void doAlert(string doWhat)
{
   string message = "[" + MQLInfoString(MQL_PROGRAM_NAME) + "] " + doWhat + " @ " + _Symbol + " : M-"+(string)(PeriodSeconds(PERIOD_CURRENT)/60);
   if (AlertsMessage) Alert(message);
   if (AlertsEmail)   SendMail("Alert @tilly " + _Symbol,message);
   if (AlertsNotify)  SendNotification(message);
   if (AlertsSound)   PlaySound("alert2.wav");
}

//+------------------------------------------------------------------+

