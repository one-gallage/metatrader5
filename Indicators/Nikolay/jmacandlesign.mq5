//+------------------------------------------------------------------+
//|                                                JMACandleSign.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Ñåìàôîðíûé ñèãíàëüíûé èíäèêàòîð ñ èñïîëüçîâàíèåì äâóõ èíäèêàòîðîâ JMA, ïîñòðîåííûõ íà Open è Close çíà÷åíèÿõ öåíîâîãî ðÿäà"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//--- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//--- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî äâà áóôåðà
#property indicator_buffers 2
//--- èñïîëüçîâàíî âñåãî äâà ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   2
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 1 â âèäå ñèìâîëà
#property indicator_type1   DRAW_ARROW
//--- â êà÷åñòâå öâåòà ìåäâåæüåé ëèíèè èíäèêàòîðà èñïîëüçîâàí ðîçîâûé öâåò
#property indicator_color1  clrDeepPink
//--- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 2
#property indicator_width1  2
//--- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label1  "JMACandle Sell"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà       |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//--- â êà÷åñòâå öâåòà áû÷üåé ëèíèè èíäèêàòîðà èñïîëüçîâàí ãîëóáîé öâåò
#property indicator_color2  clrDodgerBlue
//--- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 2
#property indicator_width2  2
//--- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label2 "JMACandle Buy"
//+----------------------------------------------+
//| Îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET  0 // êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+
input int JLength=7; 
input int JPhase=100; 
//+----------------------------------------------+
//--- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå â äàëüíåéøåì
//--- áóäóò èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double SellBuffer[];
double BuyBuffer[];
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int O_Handle,C_Handle,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ 
   min_rates_total=30+1;
   int ATR_Period=15;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà ATR");
      return(INIT_FAILED);
     }
//---- îáúÿâëåíèå ïåðå÷èñëåíèé 
   enum Applied_price_ //Òèï êîíñòàíòû
     {
      PRICE_CLOSE_ = 1,     //PRICE_CLOSE
      PRICE_OPEN_ = 2       //PRICE_OPEN
     };
//---- ïîëó÷åíèå õåíäëîâ èíäèêàòîðà JMA
   O_Handle=iCustom(NULL,0,"JMA",JLength,JPhase,PRICE_OPEN_,0,0);
   if(O_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iJMA[OPEN]!");
      return(INIT_FAILED);
     }
//----
   C_Handle=iCustom(NULL,0,"JMA",JLength,JPhase,PRICE_CLOSE_,0,0);
   if(C_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iJMA[CLOSE]!");
      return(INIT_FAILED);
     }
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_ARROW,172);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(SellBuffer,true);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BuyBuffer,true);
//--- óñòàíîâêà ôîðìàòà òî÷íîñòè îòîáðàæåíèÿ èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- èìÿ äëÿ îêîí äàííûõ è ìåòêà äëÿ ñóáúîêîí 
   string short_name="JMACandleSign";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- çàâåðøåíèå èíèöèàëèçàöèè
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
   if(BarsCalculated(O_Handle)<rates_total
      || BarsCalculated(C_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- îáúÿâëåíèå ëîêàëüíûõ ïåðåìåííûõ 
   int to_copy,limit,bar;
   double ATR[],FOpen[],FClose[];
//---- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=rates_total-2; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
     }
   else
     {
      limit=rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
     }
//----
   to_copy=limit+2;
//---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyBuffer(O_Handle,0,0,to_copy,FOpen)<=0) return(RESET);
   if(CopyBuffer(C_Handle,0,0,to_copy,FClose)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(FOpen,true);
   ArraySetAsSeries(FClose,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- îñíîâíîé öèêë èñïðàâëåíèÿ è îêðàøèâàíèÿ ñâå÷åé
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      if(FOpen[bar+1]>=FClose[bar+1] && FOpen[bar]<FClose[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(FOpen[bar+1]<=FClose[bar+1] && FOpen[bar]>FClose[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
