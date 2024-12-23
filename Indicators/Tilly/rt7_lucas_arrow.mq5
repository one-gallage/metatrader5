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
#property description "rt7_lucas_arrow"
#property description "© ErangaGallage"
#property strict

#property description "Arrows & curves type indicator"

#property indicator_applied_price PRICE_CLOSE
#property indicator_chart_window
//----
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//----
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
//----
#property indicator_color1  Green
#property indicator_color2  Red
#property indicator_color3  Gray
#property indicator_color4  Gray
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  2
#property indicator_width4  2
//---
input int Lookback =  8;
input int Pro = 3;

int iMx=500; // number of bars to calculate

double dBuf_up[];     // "up" arrows buffer
double dBuf_dn[];     // "down" arrows buffer
double dBuf_chaup[];     // upper channel buffer
double dBuf_chadn[];     // lower channel buffer
double dBuf_trend[];     // trend direction buffer

double dBuf_Hi[];    // buffer for Hi
double dBuf_Lo[];    // buffer for Lo
//---
int ihHiA;
int ihLoA;
int ihHiL;
int ihLoL;

bool   bUp,bOld;

int OnInit() {
//---
   SetIndexBuffer(0,dBuf_up);
   SetIndexBuffer(1,dBuf_dn);
   SetIndexBuffer(2,dBuf_chaup);
   SetIndexBuffer(3,dBuf_chadn);
   SetIndexBuffer(4,dBuf_trend);
//---
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//----
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   PlotIndexSetString(0,PLOT_LABEL,"UP_Arrow");
   PlotIndexSetString(1,PLOT_LABEL,"DN_Arrow");
   PlotIndexSetString(2,PLOT_LABEL,"UP_Line");
   PlotIndexSetString(3,PLOT_LABEL,"DN_Line");
   PlotIndexSetString(4,PLOT_LABEL,"Trend_Arrow");
//---
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---
   if(Pro<=0) {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,Blue);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,Blue);
   } else {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,Gray);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,Gray);
   }
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
     
   return(0);
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

   double dHiA,dLoA;
   double dMax,dMin;

// we need the iMn bars available in the history
   int iMn = 10*Lookback;                   // The mininal number of bars needed
   if(iMn>rates_total)return(0);       // return if we haven't iMn bars
   if(iMn>iMx) iMx=iMn;               // if the minimal is greater than specified, lets calculate minimal.
   if(iMx>rates_total)iMx=rates_total; // if specified is greater than available, lets calculate all available.

   int limit;
   if(prev_calculated>rates_total || prev_calculated<=0) { 
      limit = rates_total - iMn - 1; // starting index for calculation of all bars
   }
   else {
      limit = rates_total - prev_calculated; // starting index for calculation of new bars
   } 

   for(int i=limit; i>0; i--) {
      if( dBuf_dn[i]>0 )  {bOld = false;break;}
      if( dBuf_up[i]>0 )  {bOld = true; break;}
   }

//=== MAIN CYCLE
   for(int iii=limit;iii<=rates_total;iii++) {
      ihHiA=CopyHigh(NULL,0,rates_total-iii-1,Lookback,dBuf_Hi);
      if(ihHiA<=0) break;
      else
         dHiA=dBuf_Hi[ArrayMaximum(dBuf_Hi,0,WHOLE_ARRAY)];
         
      //---
      ihLoA=CopyLow(NULL,0,rates_total-iii-1,Lookback,dBuf_Lo);
      if(ihLoA<=0) break;
      else
         dLoA=dBuf_Lo[ArrayMinimum(dBuf_Lo,0,WHOLE_ARRAY)];
         
      //---
      dMax = dHiA - (dHiA - dLoA)*Pro / 100; 
      dMin = dLoA + (dHiA - dLoA)*Pro / 100; 

      if(close[iii]<dMin) {
         bUp=false; 
      }
      if(close[iii]>dMax) {
         bUp=true; 
      }
      dBuf_trend[iii] = bUp;
      
      if(bUp!=bOld && bUp==false && iii!=rates_total-1) {
         dBuf_dn[iii]=dHiA; 
      } else {
         dBuf_dn[iii]=EMPTY_VALUE;
      }
      if(bUp!=bOld && bUp==true && iii!=rates_total-1) {
         dBuf_up[iii]=dLoA; 
      } else {
         dBuf_up[iii]=EMPTY_VALUE;
      }

      bOld=bUp;

      dBuf_chaup[iii]=dMax;
      dBuf_chadn[iii]=dMin;
   }
   
   return(rates_total);
   
}
//+------------------------------------------------------------------+