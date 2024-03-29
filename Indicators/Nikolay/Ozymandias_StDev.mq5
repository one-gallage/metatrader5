//+------------------------------------------------------------------+
//|                                             Ozymandias_StDev.mq5 |
//|                                     Copyright © 2014, GoldnMoney |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, GoldnMoney"
#property link "http://www.mql5.com"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ 4
#property indicator_buffers 5 
//---- èñïîëüçîâàíî âñåãî òðè ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   4
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà              |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå ìíîãîöâåòíîé ëèíèè
#property indicator_type1   DRAW_COLOR_LINE
//---- â êà÷åñòâå öâåòîâ äâóõöâåòíîé ëèíèè èñïîëüçîâàíû
#property indicator_color1  clrGray,clrDodgerBlue,clrOrange
//---- ëèíèÿ èíäèêàòîðà - íåïðåðûâíàÿ êðèâàÿ
#property indicator_style1  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 3
#property indicator_width1  3
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  "#Ozymandias"
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà   |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//---- â êà÷åñòâå öâåòà ìåäâåæüåãî èíäèêàòîðà èñïîëüçîâàí êðàñíûé öâåò
#property indicator_color2  clrRed
//---- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 3
#property indicator_width2  3
//---- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label2  "#Dn_Signal"
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè áû÷üãî èíäèêàòîðà       |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 3 â âèäå ñèìâîëà
#property indicator_type3   DRAW_ARROW
//---- â êà÷åñòâå öâåòà áû÷üåãî èíäèêàòîðà èñïîëüçîâàí çåë¸íûé öâåò
#property indicator_color3  clrMediumSpringGreen
//---- òîëùèíà ëèíèè èíäèêàòîðà 3 ðàâíà 3
#property indicator_width3  3
//---- îòîáðàæåíèå áû÷åé ìåòêè èíäèêàòîðà
#property indicator_label3  "#Up_Signal"

#property indicator_type4   DRAW_NONE
#property indicator_label4  "#Trend"
//+----------------------------------------------+
//|  îáúÿâëåíèå êîíñòàíò                         |
//+----------------------------------------------+
#define RESET  0 // Êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷¸ò èíäèêàòîðà
//+----------------------------------------------+
//|  ÂÕÎÄÍÛÅ ÏÀÐÀÌÅÒÐÛ ÈÍÄÈÊÀÒÎÐÀ                |
//+----------------------------------------------+
input uint Length=2;
input  ENUM_MA_METHOD MAType=MODE_SMA;
input double dK=2.0; 
input uint std_period=9; 
input int Shift=0;   
//+----------------------------------------------+

//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
// äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double OzimBuffer[];
double ColorOzimBuffer[];
double BearsBuffer[];
double BullsBuffer[];
double TrendBuffer[];
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
// äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå êîëüöåâûõ áóôåðîâ
int Count[];
double Smooth[];
double dOzim[];
//---- Îáúÿâëåíèå öåëûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_1,min_rates_total;
int HMA_Handle,LMA_Handle;
//+------------------------------------------------------------------+
//|  Ïåðåñ÷åò ïîçèöèè ñàìîãî íîâîãî ýëåìåíòà â ìàññèâå               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Âîçâðàò ïî ññûëêå íîìåðà òåêóùåãî çíà÷åíèÿ öåíîâîãî ðÿäà
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   min_rates_1=int(Length);
   min_rates_total=min_rates_1+1+int(std_period);

//---- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ 
   int ATR_Period=100;
//---- Ðàñïðåäåëåíèå ïàìÿòè ïîä ìàññèâû ïåðåìåííûõ  
   ArrayResize(dOzim,std_period);   

//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà iMA
   HMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iMA");
      return(INIT_FAILED);
     }

//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà iMA
   LMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iMA");
      return(INIT_FAILED);
     }
   
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,OzimBuffer,INDICATOR_DATA);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(OzimBuffer,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorOzimBuffer,INDICATOR_COLOR_INDEX);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ColorOzimBuffer,true);

//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà BearsBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(2,BearsBuffer,INDICATOR_DATA);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BearsBuffer,true);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 2 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷¸òà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- âûáîð ñèìâîëà äëÿ îòðèñîâêè
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà BullsBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(3,BullsBuffer,INDICATOR_DATA);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BullsBuffer,true);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 3 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷¸òà îòðèñîâêè èíäèêàòîðà 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- âûáîð ñèìâîëà äëÿ îòðèñîâêè
   PlotIndexSetInteger(2,PLOT_ARROW,119);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

   SetIndexBuffer(4,TrendBuffer,INDICATOR_DATA);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(TrendBuffer,true);

//---- èíèöèàëèçàöèè ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname="Ozymandias";
//---- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
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
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷¸òà
   if(BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);


//---- Îáúÿâëåíèå ïåðåìåííûõ
   int to_copy,limit,trend0,nexttrend0;
   double SMAdif,Sum,StDev,dstd,BEARS,BULLS,Filter;
   double hh,ll,maxl0,minh0,lma,hma,HMA[],LMA[];
   static int trend1,nexttrend1;
   static double maxl1,minh1;

//---- ðàñ÷¸ò ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷¸òà áàðîâ
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

//---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);

//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);

   nexttrend0=nexttrend1;
   maxl0=maxl1;
   minh0=minh1;

//---- îñíîâíîé öèêë ðàñ÷¸òà èíäèêàòîðà
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      hh=high[ArrayMaximum(high,bar,Length)];
      ll=low[ArrayMinimum(low,bar,Length)];
      lma=LMA[bar];
      hma=HMA[bar];
      trend0=trend1;

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

      if(trend0==0)
        {
         if(trend1!=0.0)
           {
            OzimBuffer[bar]=OzimBuffer[bar+1];
            ColorOzimBuffer[bar]=1;
           }
         else
           {
            OzimBuffer[bar]=MathMax(maxl0,OzimBuffer[bar+1]);
            ColorOzimBuffer[bar]=1;
           }
        }
      else
        {
         if(trend1!=1)
           {
            OzimBuffer[bar]=OzimBuffer[bar+1];
            ColorOzimBuffer[bar]=0;
           }
         else
           {
            OzimBuffer[bar]=MathMin(minh0,OzimBuffer[bar+1]);
            ColorOzimBuffer[bar]=0;
           }
        }

      if(bar)
        {
         nexttrend1=nexttrend0;
         trend1=trend0;
         maxl1=maxl0;
         minh1=minh0;
        }
     }
     
//---- êîððåêòèðîâêà çíà÷åíèÿ ïåðåìåííîé limit
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
      limit=rates_total-min_rates_total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ

//---- Îñíîâíîé öèêë ðàñêðàñêè ñèãíàëüíîé ëèíèè
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorOzimBuffer[bar]=0; TrendBuffer[bar] = 0;
      if(OzimBuffer[bar+1]<OzimBuffer[bar]) {
         ColorOzimBuffer[bar]=1; TrendBuffer[bar] = 1;
      }
      if(OzimBuffer[bar+1]>OzimBuffer[bar]) {
         ColorOzimBuffer[bar]=2; TrendBuffer[bar] = -1;
      }
      if(OzimBuffer[bar+1]==OzimBuffer[bar]) {
         ColorOzimBuffer[bar]=ColorOzimBuffer[bar+1]; TrendBuffer[bar] = TrendBuffer[bar+1];
      }
     }

//---- îñíîâíîé öèêë ðàñ÷¸òà èíäèêàòîðà ñòàíäàðòíîãî îòêëîíåíèÿ
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- çàãðóæàåì ïðèðàùåíèÿ èíäèêàòîðà â ìàññèâ äëÿ ïðîìåæóòî÷íûõ âû÷èñëåíèé
      for(int iii=0; iii<int(std_period); iii++) dOzim[iii]=OzimBuffer[bar+iii]-OzimBuffer[bar+iii+1];

      //---- íàõîäèì ïðîñòîå ñðåäíåå ïðèðàùåíèé èíäèêàòîðà
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dOzim[iii];
      SMAdif=Sum/std_period;

      //---- íàõîäèì ñóììó êâàäðàòîâ ðàçíîñòåé ïðèðàùåíèé è ñðåäíåãî
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dOzim[iii]-SMAdif,2);

      //---- îïðåäåëÿåì èòîãîâîå çíà÷åíèå ñðåäíåêâàäðàòè÷íîãî îòêëîíåíèÿ StDev îò ïðèðàùåíèÿ èíäèêàòîðà
      StDev=MathSqrt(Sum/std_period);

      //---- èíèöèàëèçàöèÿ ïåðåìåííûõ
      dstd=NormalizeDouble(dOzim[0],_Digits+2);
      Filter=NormalizeDouble(dK*StDev,_Digits+2);
      BEARS=0;
      BULLS=0;

      //---- âû÷èñëåíèå èíäèêàòîðíûõ çíà÷åíèé
      if(dstd<-Filter) BEARS=OzimBuffer[bar]; //åñòü íèñõîäÿùèé òðåíä
      if(dstd>+Filter) BULLS=OzimBuffer[bar]; //åñòü âîñõîäÿùèé òðåíä

      //---- èíèöèàëèçàöèÿ ÿ÷ååê èíäèêàòîðíûõ áóôåðîâ ïîëó÷åííûìè çíà÷åíèÿìè 
      BullsBuffer[bar]=BULLS;
      BearsBuffer[bar]=BEARS;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
