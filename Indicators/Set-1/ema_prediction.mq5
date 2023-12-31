//+------------------------------------------------------------------+
//|                                               EMA_Prediction.mq5 |
//|                                     Copyright © 2008, Codersguru |
//|                                         http://www.forex-tsd.com |
//+------------------------------------------------------------------+
//---- àâòîðñòâî èíäèêàòîðà
#property copyright "Copyright © 2008, Codersguru"
//---- ññûëêà íà ñàéò àâòîðà
#property link      "http://www.forex-tsd.com"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.01"
//---- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//---- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî äâà áóôåðà
#property indicator_buffers 2
//---- èñïîëüçîâàíî âñåãî äâà ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   2
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 1 â âèäå ñèìâîëà
#property indicator_type1   DRAW_ARROW
//---- â êà÷åñòâå öâåòà ìåäâåæüåé ëèíèè èíäèêàòîðà èñïîëüçîâàí ðîçîâûé öâåò
#property indicator_color1  clrMagenta
//---- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 4
#property indicator_width1  1
//---- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label1  "EMA_Prediction Sell"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà       |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//---- â êà÷åñòâå öâåòà áû÷üåé ëèíèè èíäèêàòîðà èñïîëüçîâàí çåëåíûé öâåò
#property indicator_color2  clrLime
//---- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 4
#property indicator_width2  1
//---- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label2 "EMA_Prediction Buy"
//+----------------------------------------------+
//| Îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET  0 // êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+
input uint               FastMAPeriod=1;
input  ENUM_MA_METHOD    FastMAType=MODE_EMA;
input ENUM_APPLIED_PRICE FastMAPrice=PRICE_CLOSE;
input uint               SlowMAPeriod=2;
input  ENUM_MA_METHOD    SlowMAType=MODE_EMA;
input ENUM_APPLIED_PRICE SlowMAPrice=PRICE_CLOSE;
//+----------------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
//---- äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double SellBuffer[];
double BuyBuffer[];
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int ATR_Handle,FsMA_Handle,SlMA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ
   int ATR_Period=12;
   min_rates_total=int(MathMax(MathMax(FastMAPeriod,SlowMAPeriod),ATR_Period))+1;
//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iATR!");
      return(INIT_FAILED);
     }
//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà Fast iMA
   FsMA_Handle=iMA(NULL,0,FastMAPeriod,0,FastMAType,FastMAPrice);
   if(FsMA_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà Fast iMA");
      return(INIT_FAILED);
     }
//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà Slow iMA
   SlMA_Handle=iMA(NULL,0,SlowMAPeriod,0,SlowMAType,SlowMAPrice);
   if(SlMA_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà Slow iMA");
      return(INIT_FAILED);
     }
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñîçäàíèå ìåòêè äëÿ îòîáðàæåíèÿ â DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"EMA_Prediction Sell");
//---- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(SellBuffer,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñîçäàíèå ìåòêè äëÿ îòîáðàæåíèÿ â DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"EMA_Prediction Buy");
//---- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BuyBuffer,true);
//---- óñòàíîâêà ôîðìàòà òî÷íîñòè îòîáðàæåíèÿ èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- èìÿ äëÿ îêîí äàííûõ è ëýéáà äëÿ ñóáúîêîí 
   string short_name="EMA_Prediction";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- çàâåðøåíèå èíèöèàëèçàöèè
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(BarsCalculated(FsMA_Handle)<rates_total
      || BarsCalculated(SlMA_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- îáúÿâëåíèÿ ëîêàëüíûõ ïåðåìåííûõ 
   int to_copy,limit,bar;
   double ATR[],FsMA[],SlMA[];
//---- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è
//---- ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=rates_total-min_rates_total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
     }
   else
     {
      limit=rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
     }
//----
   to_copy=limit+1;
//---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy++;
   if(CopyBuffer(FsMA_Handle,0,0,to_copy,FsMA)<=0) return(RESET);
   if(CopyBuffer(SlMA_Handle,0,0,to_copy,SlMA)<=0) return(RESET);
//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(FsMA,true);
   ArraySetAsSeries(SlMA,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //----
      if(FsMA[bar+1]<SlMA[bar+1] && FsMA[bar]>SlMA[bar] && open[bar]<close[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(FsMA[bar+1]>SlMA[bar+1] && FsMA[bar]<SlMA[bar] && open[bar]>close[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
