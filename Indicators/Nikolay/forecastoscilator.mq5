//+------------------------------------------------------------------+
//|                                            ForecastOscilator.mq5 |
//|                Copyright © 2005, Nick Bilak, beluck[AT]gmail.com |
//|                                    http://metatrader.50webs.com/ |
//+------------------------------------------------------------------+
//---- àâòîðñòâî èíäèêàòîðà
#property copyright "Copyright © 2005, Nick Bilak"
//---- ññûëêà íà ñàéò àâòîðà
#property link      "http://metatrader.50webs.com/"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.01"
//---- îòðèñîâêà èíäèêàòîðà â îòäåëüíîì îêíå
#property indicator_separate_window 
//---- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî ÷åòûðå áóôåðà
#property indicator_buffers 4
//---- èñïîëüçîâàíî âñåãî ÷åòûðå ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   4
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà 1             |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 1 â âèäå ëèíèè
#property indicator_type1   DRAW_LINE
//---- â êà÷åñòâå öâåòà ëèíèè èíäèêàòîðà èñïîëüçîâàí áëåäíî-ãîëóáîé öâåò
#property indicator_color1  clrCornflowerBlue
//---- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 1
#property indicator_width1  1
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  "Forecast Oscilator"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà 2             |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_LINE
//---- â êà÷åñòâå öâåòà ëèíèè èíäèêàòîðà èñïîëüçîâàí îðàíæåâûé öâåò
#property indicator_color2  clrOrange
//---- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 1
#property indicator_width2  1
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label2 "Signal line"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 3 â âèäå ñèìâîëà
#property indicator_type3   DRAW_ARROW
//---- â êà÷åñòâå öâåòà ìåäâåæüåé ëèíèè èíäèêàòîðà èñïîëüçîâàí ðîçîâûé öâåò
#property indicator_color3  clrMagenta
//---- òîëùèíà ëèíèè èíäèêàòîðà 3 ðàâíà 4
#property indicator_width3  4
//---- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label3  "Sell"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà       |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 4 â âèäå ñèìâîëà
#property indicator_type4   DRAW_ARROW
//---- â êà÷åñòâå öâåòà áû÷üåé ëèíèè èíäèêàòîðà èñïîëüçîâàí çåëåíûé öâåò
#property indicator_color4  clrLime
//---- òîëùèíà ëèíèè èíäèêàòîðà 4 ðàâíà 4
#property indicator_width4  4
//---- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label4 "Buy"
//+----------------------------------------------+
//| Îáúÿâëåíèå ïåðå÷èñëåíèÿ                      |
//+----------------------------------------------+
enum Applied_price_ //òèï êîíñòàíòû
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
input uint   length=15;
input uint   t3=3;
input double b=0.7;
input Applied_price_ IPC=PRICE_CLOSE_;
//+----------------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
//---- äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double BuyBuffer[];
double SellBuffer[];
double IndBuffer[],SigBuffer[];
//---
int min_rates_total;
double b2,b3,c1,c2,c3,c4,w1,w2,n,Kx,Br;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ
   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
//----
   n=MathMax(n,t3);
   n=1+0.5*(n-1);
   w1=2/(n+1);
   w2=1-w1;
   Kx=6.0/(length*(length+1.0));
   Br=(length+1.0)/3.0;
   min_rates_total=int(length+1);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(1,SigBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(2,PLOT_ARROW,158);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(3,PLOT_ARROW,158);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- óñòàíîâêà ôîðìàòà òî÷íîñòè îòîáðàæåíèÿ èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- èìÿ äëÿ îêîí äàííûõ è ìåòêà äëÿ ïîäîêîí 
   string short_name="Forecast Oscilator";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(rates_total<min_rates_total) return(0);
//---- îáúÿâëåíèÿ ëîêàëüíûõ ïåðåìåííûõ 
   int first,bar;
   double WT,forecastosc,t3_fosc,sum,e1,e2,e3,e4,e5,e6,tmp,tmp2;
   static double e1_,e2_,e3_,e4_,e5_,e6_;
//---- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è
//---- ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      first=min_rates_total+1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
      e1_=0.0;
      e2_=0.0;
      e3_=0.0;
      e4_=0.0;
      e5_=0.0;
      e6_=0.0;
     }
   else
     {
      first=prev_calculated-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
     }
//---- âîññòàíàâëèâàåì çíà÷åíèÿ ïåðåìåííûõ
   e1=e1_;
   e2=e2_;
   e3=e3_;
   e4=e4_;
   e5=e5_;
   e6=e6_;
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- çàïîìèíàåì çíà÷åíèÿ ïåðåìåííûõ ïåðåä ïðîãîíàìè íà òåêóùåì áàðå
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         e1_=e1;
         e2_=e2;
         e3_=e3;
         e4_=e4;
         e5_=e5;
         e6_=e6;
        }
      //----
      sum=0.0;
      for(int i=int(length); i>0; i--)
        {
         tmp=Br;
         tmp2=i;
         tmp=tmp2-tmp;
         sum+=tmp*PriceSeries(IPC,bar-length+i,open,low,high,close);
        }
      //----
      WT=sum*Kx;
      //----
      forecastosc=(PriceSeries(IPC,bar,open,low,high,close)-WT)/WT*100;
      e1=w1*forecastosc + w2*e1;
      e2=w1*e1 + w2*e2;
      e3=w1*e2 + w2*e3;
      e4=w1*e3 + w2*e4;
      e5=w1*e4 + w2*e5;
      e6=w1*e5 + w2*e6;
      //----
      t3_fosc=c1*e6+c2*e5+c3*e4+c4*e3;
      IndBuffer[bar]=forecastosc;
      SigBuffer[bar]=t3_fosc;
      BuyBuffer [bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;
      //----
      if(IndBuffer[bar-1] > SigBuffer[bar-2] && IndBuffer[bar-2]<=SigBuffer[bar-3] && SigBuffer[bar-1]<0) BuyBuffer [bar-1]=t3_fosc-0.05;
      if(IndBuffer[bar-1] < SigBuffer[bar-2] && IndBuffer[bar-2]>=SigBuffer[bar-3] && SigBuffer[bar-1]>0) SellBuffer[bar-1]=t3_fosc+0.05;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Ïîëó÷åíèå çíà÷åíèÿ öåíîâîé òàéìñåðèè                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price, // öåíîâàÿ êîíñòàíòà
                   uint   bar,         // èíäåêñ ñäâèãà îòíîñèòåëüíî òåêóùåãî áàðà íà óêàçàííîå êîëè÷åñòâî ïåðèîäîâ íàçàä èëè âïåðåä
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- öåíîâûå êîíñòàíòû èç ïåðå÷èñëåíèÿ ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);
      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
