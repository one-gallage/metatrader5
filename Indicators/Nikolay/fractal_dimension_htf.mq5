//+------------------------------------------------------------------+ 
//|                                        fractal_dimension_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.60"
//---- îòðèñîâêà èíäèêàòîðà â îòäåëüíîì îêíå
#property indicator_separate_window
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ 2
#property indicator_buffers 2 
//---- èñïîëüçîâàíî âñåãî îäíî ãðàôè÷åñêèå ïîñòðîåíèå
#property indicator_plots   1
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà               |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå ìíîãîöâåòíîé ëèíèè
#property indicator_type1   DRAW_COLOR_LINE
//---- â êà÷åñòâå öâåòîâ òðåõöâåòíîé ëèíèè èñïîëüçîâàíû
#property indicator_color1  clrRed,clrBlue
//---- ëèíèÿ èíäèêàòîðà - íåïðåðûâíàÿ êðèâàÿ
#property indicator_style1  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 2
#property indicator_width1  2
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  "fractal_dimension"
//+----------------------------------------------+
//| Îáúÿâëåíèå ïåðå÷èñëåíèé                      |
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
//| Îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET 0 // êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;      
input uint                e_period=30;          
input Applied_price_   e_type_data=PRICE_CLOSE; 
input double         e_random_line=1.5;        
input int                    Shift=0;          
//+----------------------------------------------+
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int Ind_Handle;
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
//---- äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//| Ïîëó÷åíèå òàéìôðåéìà â âèäå ñòðîêè                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+    
//| fractal_dimension indicator initialization function              | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   min_rates_total=3;
//---- ïðîâåðêà ïåðèîäîâ ãðàôèêîâ íà êîððåêòíîñòü
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Ïåðèîä ãðàôèêà äëÿ èíäèêàòîðà fractal_dimension íå ìîæåò áûòü ìåíüøå ïåðèîäà òåêóùåãî ãðàôèêà");
      return(INIT_FAILED);
     }
//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà fractal_dimension
   Ind_Handle=iCustom(Symbol(),TimeFrame,"fractal_dimension",e_period,e_type_data,e_random_line,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà fractal_dimension");
      return(INIT_FAILED);
     }
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà IndBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(IndBuffer,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ColorIndBuffer,true);
//---- èíèöèàëèçàöèÿ ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname;
   StringConcatenate(shortname,"fractal_dimension HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- êîëè÷åñòâî  ãîðèçîíòàëüíûõ óðîâíåé èíäèêàòîðà 1  
   IndicatorSetInteger(INDICATOR_LEVELS,1);
//---- çíà÷åíèÿ ãîðèçîíòàëüíûõ óðîâíåé èíäèêàòîðà   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,e_random_line);
//---- â êà÷åñòâå öâåòà ëèíèè ãîðèçîíòàëüíîãî óðîâíÿ èñïîëüçîâàí Purple öâåò  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrPurple);
//---- â ëèíèè ãîðèçîíòàëüíîãî óðîâíÿ èñïîëüçîâàí êîðîòêèé øòðèõ-ïóíêòèð  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
//---- çàâåðøåíèå èíèöèàëèçàöèè
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| fractal_dimension iteration function                             | 
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
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ
   int limit,bar;
//---- îáúÿâëåíèå ïåðåìåííûõ ñ ïëàâàþùåé òî÷êîé  
   double Ind[1],Clr[1];
   datetime IndTime[1];
   static uint LastCountBar;
//---- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è
//---- ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=rates_total-min_rates_total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ 
//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(time,true);
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- îáíóëèì ñîäåðæèìîå èíäèêàòîðíûõ áóôåðîâ äî ðàñ÷åòà
      IndBuffer[bar]=EMPTY_VALUE;
      ColorIndBuffer[bar]=0;
      //---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâ
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,IndTime)<=0) return(RESET);
      //----
      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         //---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
         if(CopyBuffer(Ind_Handle,0,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Clr)<=0) return(RESET);
         //---- çàãðóçêà ïîëó÷åííûõ çíà÷åíèé â èíäèêàòîðíûå áóôåðû
         IndBuffer[bar]=Ind[0];
         ColorIndBuffer[bar]=Clr[0];
        }
      else
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
