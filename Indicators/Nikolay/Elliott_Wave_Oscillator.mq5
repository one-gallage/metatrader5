//+------------------------------------------------------------------+
//|                                      Elliott_Wave_Oscillator.mq5 | 
//|                              Copyright © 2008, tonyc2a@yahoo.com |
//|                                                tonyc2a@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, tonyc2a@yahoo.com"
#property link      "tonyc2a@yahoo.com"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â îòäåëüíîì îêíå
#property indicator_separate_window
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ
#property indicator_buffers 2 
//---- èñïîëüçîâàíî âñåãî îäíî ãðàôè÷åñêîå ïîñòðîåíèå
#property indicator_plots   1
//+-----------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà   |
//+-----------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå ïÿòèöâåòíîé ãèñòîãðàììû
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- â êà÷åñòâå öâåòîâ ÷åòûð¸õöâåòíîé ãèñòîãðàììû èñïîëüçîâàíû
#property indicator_color1 clrBlue,clrTurquoise,clrGray,clrYellow,clrDarkOrange
//---- ëèíèÿ èíäèêàòîðà - ñïëîøíàÿ
#property indicator_style1 STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 2
#property indicator_width1 2
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1 "Elliott_Wave_Oscillator"
//+-----------------------------------+
//|  Îïèñàíèå êëàññà CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- îáúÿâëåíèå ïåðåìåííûõ êëàññà CXMA èç ôàéëà SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  îáúÿâëåíèå ïåðå÷èñëåíèé          |
//+-----------------------------------+
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
//+-----------------------------------+
//|  îáúÿâëåíèå ïåðå÷èñëåíèé          |
//+-----------------------------------+
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
//+-----------------------------------+
//|  ÂÕÎÄÍÛÅ ÏÀÐÀÌÅÒÐÛ ÈÍÄÈÊÀÒÎÐÀ     |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA_; 
input int Length1=5;  
input int Phase1=15; 
//---- äëÿ JJMA èçìåíÿþùèéñÿ â ïðåäåëàõ -100 ... +100, âëèÿåò íà êà÷åñòâî ïåðåõîäíîãî ïðîöåññà;
//---- Äëÿ VIDIA ýòî ïåðèîä CMO, äëÿ AMA ýòî ïåðèîä ìåäëåííîé ñêîëüçÿùåé
input Applied_price_ IPC1=PRICE_MEDIAN_;
input Smooth_Method MA_Method2=MODE_JJMA; 
input int Length2=35; 
input int Phase2=15;  
//---- äëÿ JJMA èçìåíÿþùèéñÿ â ïðåäåëàõ -100 ... +100, âëèÿåò íà êà÷åñòâî ïåðåõîäíîãî ïðîöåññà;
//---- Äëÿ VIDIA ýòî ïåðèîä CMO, äëÿ AMA ýòî ïåðèîä ìåäëåííîé ñêîëüçÿùåé
input Applied_price_ IPC2=PRICE_MEDIAN_;
input int Shift=0; // Ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ
//+-----------------------------------+
//---- èíäèêàòîðíûå áóôåðû
double IndBuffer[],ColorIndBuffer[];
//---- Îáúÿâëåíèå öåëûõ ïåðåìåííûõ íà÷àëà îòñ÷¸òà äàííûõ
int min_rates_total;
//+------------------------------------------------------------------+   
//| Elliott_Wave_Oscillator initialization function                  | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷¸òà äàííûõ
   min_rates_total=MathMax(GetStartBars(MA_Method1,Length1,Phase1),GetStartBars(MA_Method2,Length2,Phase2));

//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷¸òà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- èíèöèàëèçàöèè ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname;
   StringConcatenate(shortname,"Elliott_Wave_Oscillator(",Length1,",",Length2,")");
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- çàâåðøåíèå èíèöèàëèçàöèè
  }
//+------------------------------------------------------------------+ 
//| Elliott_Wave_Oscillator iteration function                       | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                const int prev_calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷¸òà
   if(rates_total<min_rates_total) return(0);

//---- Îáúÿâëåíèå ïåðåìåííûõ ñ ïëàâàþùåé òî÷êîé  
   double price,x1xma,x2xma;
//---- Îáúÿâëåíèå öåëûõ ïåðåìåííûõ è ïîëó÷åíèå óæå ïîñ÷èòàííûõ áàðîâ
   int first,bar;

//---- ðàñ÷åò ñòàðòîâîãî íîìåðà first äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
      first=0; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
   else first=prev_calculated-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ

//---- Îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC1,bar,open,low,high,close); 
      x1xma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);
      price=PriceSeries(IPC2,bar,open,low,high,close);
      x2xma=XMA2.XMASeries(0,prev_calculated,rates_total,MA_Method2,Phase2,Length2,price,bar,false);
      IndBuffer[bar]=x1xma-x2xma;
     }
if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- Îñíîâíîé öèêë ðàñêðàñêè èíäèêàòîðà Ind
   for(bar=first; bar<rates_total; bar++)
     {
      int clr=2;

      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=1;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=3;
        }
       ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
