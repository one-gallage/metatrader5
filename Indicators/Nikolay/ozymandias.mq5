//+------------------------------------------------------------------+
//|                                                   Ozymandias.mq5 |
//|                                     Copyright © 2014, GoldnMoney |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, GoldnMoney"
#property link "http://www.mql5.com"
//--- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//--- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//--- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ 4
#property indicator_buffers 4 
//--- èñïîëüçîâàíî âñåãî òðè ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   3
//+-----------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà         |
//+-----------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà â âèäå ìíîãîöâåòíîé ëèíèè
#property indicator_type1   DRAW_COLOR_LINE
//--- â êà÷åñòâå öâåòîâ äâóõöâåòíîé ëèíèè èñïîëüçîâàíû
#property indicator_color1  clrDeepPink,clrDodgerBlue
//--- ëèíèÿ èíäèêàòîðà - íåïðåðûâíàÿ êðèâàÿ
#property indicator_style1  STYLE_SOLID
//--- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 3
#property indicator_width1  3
//--- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  "Ozymandias"
//+-----------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà óðîâíåé |
//+-----------------------------------------+
//--- îòðèñîâêà óðîâíåé â âèäå ëèíèé
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//--- âûáîð öâåòîâ óðîâíåé
#property indicator_color2  clrRosyBrown
#property indicator_color3  clrRosyBrown
//--- óðîâíè - øòðèõïóíêòèðíûå êðèâûå
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//--- òîëùèíà óðîâíåé ðàâíà 2
#property indicator_width2  2
#property indicator_width3  2
//--- îòîáðàæåíèå ìåòêè óðîâíåé
#property indicator_label2  "Upper Ozymandias"
#property indicator_label3  "Lower Ozymandias"
//+-----------------------------------------+
//| îáúÿâëåíèå êîíñòàíò                     |
//+-----------------------------------------+
#define RESET  0 // Êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷¸ò èíäèêàòîðà
//+-----------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà            |
//+-----------------------------------------+
input uint Length=2;
input  ENUM_MA_METHOD MAType=MODE_SMA;
input int Shift=0;  
//+-----------------------------------------+
//--- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå â äàëüíåéøåì
//--- áóäóò èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double IndBuffer[],ColorIndBuffer[];
double UpBuffer[],DnBuffer[];
//--- îáúÿâëåíèå öåëî÷èñäåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
int ATR_Handle,HMA_Handle,LMA_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   min_rates_total=int(Length);
//--- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ 
   int ATR_Period=100;
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà ATR");
      return(INIT_FAILED);
     }
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà iMA
   HMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iMA");
      return(INIT_FAILED);
     }
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà iMA
   LMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iMA");
      return(INIT_FAILED);
     }
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(IndBuffer,true);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ColorIndBuffer,true);
//--- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(UpBuffer,true);
//--- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(3,DnBuffer,INDICATOR_COLOR_INDEX);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(DnBuffer,true);
//--- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- èíèöèàëèçàöèè ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname="Ozymandias";
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- çàâåðøåíèå èíèöèàëèçàöèè
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
//--- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷¸òà
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- îáúÿâëåíèå ïåðåìåííûõ
   int to_copy,limit,trend0,nexttrend0;
   double hh,ll,maxl0,minh0,lma,hma,atr,ATR[],HMA[],LMA[];
   static int trend1,nexttrend1;
   static double maxl1,minh1;
//--- ðàñ÷¸ò ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷¸òà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷¸òà èíäèêàòîðà
     {
      limit=rates_total-min_rates_total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷¸òà âñåõ áàðîâ
      trend1=0;
      nexttrend1=0;
      maxl1=0;
      minh1=9999999;
     }
   else limit=rates_total-prev_calculated;  // ñòàðòîâûé íîìåð äëÿ ðàñ÷¸òà òîëüêî íîâûõ áàðîâ
   to_copy=limit+1;
//--- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);
//--- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);
//---
   nexttrend0=nexttrend1;
   maxl0=maxl1;
   minh0=minh1;
//--- îñíîâíîé öèêë ðàñ÷¸òà èíäèêàòîðà
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      hh=high[ArrayMaximum(high,bar,Length)];
      ll=low[ArrayMinimum(low,bar,Length)];
      lma=LMA[bar];
      hma=HMA[bar];
      atr=ATR[bar]/2;
      trend0=trend1;
      //---
      if(nexttrend0==1)
        {
         maxl0=MathMax(ll,maxl0);

         if(hma<maxl0 && close[bar]<low[bar+1])
           {
            trend0=1;
            nexttrend0=0;
            minh0=hh;
           }
        }
      //---
      if(nexttrend0==0)
        {
         minh0=MathMin(hh,minh0);

         if(lma>minh0 && close[bar]>high[bar+1])
           {
            trend0=0;
            nexttrend0=1;
            maxl0=ll;
           }
        }
      //---
      if(trend0==0)
        {
         if(trend1!=0.0)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=1;
           }
         else
           {
            IndBuffer[bar]=MathMax(maxl0,IndBuffer[bar+1]);
            ColorIndBuffer[bar]=1;
           }
         UpBuffer[bar]=IndBuffer[bar]+atr;
         DnBuffer[bar]=IndBuffer[bar]-atr;
        }
      else
        {
         if(trend1!=1)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=0;
           }
         else
           {
            IndBuffer[bar]=MathMin(minh0,IndBuffer[bar+1]);
            ColorIndBuffer[bar]=0;
           }
         UpBuffer[bar]=IndBuffer[bar]+atr;
         DnBuffer[bar]=IndBuffer[bar]-atr;
        }
      //---
      if(bar)
        {
         nexttrend1=nexttrend0;
         trend1=trend0;
         maxl1=maxl0;
         minh1=minh0;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
