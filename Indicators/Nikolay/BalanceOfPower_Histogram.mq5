//+------------------------------------------------------------------+
//|                                     BalanceOfPower_Histogram.mq5 |
//|                                         Copyright © 2012, RoboFx |
//|                                            http://www.robofx.org |
//+------------------------------------------------------------------+
//---- àâòîðñòâî èíäèêàòîðà
#property copyright "Copyright © 2012, RoboFx"
//---- ññûëêà íà ñàéò àâòîðà
#property link      "http://www.robofx.org"
#property description "Èíäèêàòîð Balance of Power (BOP), îïèñàííûé Èãîðåì Ëèâøèíîì, èçìåðÿåò ñèëó áûêîâ è ìåäâåäåé îöåíèâàÿ ñïîñîáíîñòü òåõ è äðóãèõ òîëêàòü öåíû äî ïðåäåëüíîãî óðîâíÿ"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â îòäåëüíîì îêíå
#property indicator_separate_window
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ 2
#property indicator_buffers 2 
//---- èñïîëüçîâàíî îäíî ãðàôè÷åñêîå ïîñòðîåíèå
#property indicator_plots   1
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà 1            |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå ÷åòûð¸õöâåòíîé ãèñòîãðàììû
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- â êà÷åñòâå öâåòîâ ãèñòîãðàììû èñïîëüçîâàíû
#property indicator_color1 clrLime,clrDeepSkyBlue,clrTeal,clrBlue,clrPurple,clrMediumVioletRed,clrMagenta,clrRed
//---- ëèíèÿ èíäèêàòîðà - ñïëîøíàÿ
#property indicator_style1 STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 2
#property indicator_width1 2
//---- îòîáðàæåíèå ìåòêè ëèíèè èíäèêàòîðà
#property indicator_label1  "BalanceOfPower_Histogram"
//+----------------------------------------------+
//|  Îïèñàíèå êëàññà CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- îáúÿâëåíèå ïåðåìåííûõ êëàññà CXMA èç ôàéëà SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//|  îáúÿâëåíèå ïåðå÷èñëåíèé                     |
//+----------------------------------------------+
/*enum Smooth_Method - ïåðå÷èñëåíèå îáúÿâëåíî â ôàéëå SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  îáúÿâëåíèå ïåðå÷èñëåíèé                     |
//+----------------------------------------------+
enum Applied_price_ //Òèï êîíñòàíòû
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+
input Smooth_Method XMethod=MODE_T3;              
input uint XLength=13;                                   
input int XPhase=13;                              
input int HighLevel=+20;                         
input int LowLevel=-20;                         
input int Shift=0;                                
//+----------------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double IndBuffer[],ColorIndBuffer[];
//---- Îáúÿâëåíèå öåëûõ ïåðåìåííûõ íà÷àëà îòñ÷¸òà äàííûõ
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷¸òà äàííûõ
   min_rates_total=GetStartBars(XMethod,XLength,XPhase)+1;

//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà SignBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè íà Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷¸òà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,"BalanceOfPower_Histogram");
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- êîëè÷åñòâî  ãîðèçîíòàëüíûõ óðîâíåé èíäèêàòîðà 3  
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- çíà÷åíèÿ ãîðèçîíòàëüíûõ óðîâíåé èíäèêàòîðà   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- â êà÷åñòâå öâåòîâ ëèíèé ãîðèçîíòàëüíûõ óðîâíåé èñïîëüçîâàíû 
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- â ëèíèè ãîðèçîíòàëüíîãî óðîâíÿ èñïîëüçîâàí êîðîòêèé øòðèõ-ïóíêòèð  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                const int prev_calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
                const datetime &time[],
                const double &open[],
                const double& high[],     // öåíîâîé ìàññèâ ìàêñèìóìîâ öåíû äëÿ ðàñ÷¸òà èíäèêàòîðà
                const double& low[],      // öåíîâîé ìàññèâ ìèíèìóìîâ öåíû  äëÿ ðàñ÷¸òà èíäèêàòîðà
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷¸òà
   if(rates_total<min_rates_total) return(0);

//---- îáúÿâëåíèÿ ëîêàëüíûõ ïåðåìåííûõ 
   int first;
   double diff,bop;

//---- ðàñ÷¸ò ñòàðòîâîãî íîìåðà first äëÿ öèêëà ïåðåñ÷¸òà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷¸òà èíäèêàòîðà
     {
      first=0; // ñòàðòîâûé íîìåð äëÿ ðàñ÷¸òà âñåõ áàðîâ
     }
   else first=prev_calculated-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷¸òà íîâûõ áàðîâ

//---- îñíîâíîé öèêë ðàñ÷¸òà èíäèêàòîðà
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      diff=high[bar]-low[bar];
      if(!diff) diff=_Point;
      bop=(close[bar]-open[bar])/diff;
      IndBuffer[bar]=100*XMA1.XMASeries(0,prev_calculated,rates_total,XMethod,XPhase,XLength,bop,bar,false);
     }
//---- 
   if(prev_calculated>rates_total || prev_calculated<=0) first=min_rates_total;
//---- Îñíîâíîé öèêë ðàñêðàñêè èíäèêàòîðà
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=10;
      bop=IndBuffer[bar];
      diff=IndBuffer[bar]-IndBuffer[bar-1];

      if(bop>0)
        {
         if(diff>0.0)
           {
            if(bop>HighLevel) clr=0;
            else clr=2;
           }
         if(diff<0.0)
           {
            if(bop>HighLevel) clr=1;
            else clr=3;
           }
        }

      if(bop<0)
        {
         if(diff<0.0)
           {
            if(bop<LowLevel) clr=7;
            else clr=5;
           }
         if(diff>0.0)
           {
            if(bop<LowLevel) clr=6;
            else clr=4;
           }
        }
      ColorIndBuffer[bar]=clr;
     }
//----              
   return(rates_total);
  }
//+------------------------------------------------------------------+
