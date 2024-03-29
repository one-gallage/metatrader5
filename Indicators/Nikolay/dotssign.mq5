//+------------------------------------------------------------------+
//|Based on NonLagDOT.mq4 by TrendLaboratory                         |
//|http://finance.groups.yahoo.com/group/TrendLaboratory             |
//|igorad2003@yahoo.co.uk                                            |
//|                                                     DotsSign.mq5 |
//|                                  Copyright © 2011, EarnForex.com |
//|                                         http://www.earnforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex"
#property link      "http://www.earnforex.com"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//--- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî äâà áóôåðà
#property indicator_buffers 2
//--- èñïîëüçîâàíî âñåãî äâà ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   2
//+----------------------------------------------+
//| Îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET 0                        // êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
#define PI 3.1415926535                // êîíñòàíòà äëÿ ÷èñëà Ïè
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 1 â âèäå ñèìâîëà
#property indicator_type1   DRAW_ARROW
//--- â êà÷åñòâå öâåòà ìåäâåæüåé ëèíèè èíäèêàòîðà èñïîëüçîâàí êðàñíûé öâåò
#property indicator_color1  clrRed
//--- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 2
#property indicator_width1  2
//--- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label1  "Dots Sell"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà       |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//--- â êà÷åñòâå öâåòà áû÷üåé ëèíèè èíäèêàòîðà èñïîëüçîâàí ñèíèé öâåò
#property indicator_color2  clrBlue
//--- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 2
#property indicator_width2  2
//--- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label2 "Dots Buy"
//+----------------------------------------------+
//| Îáúÿâëåíèå ïåðå÷èñëåíèé                      |
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
input uint Length = 10;                           
input uint Filter = 0;                            
input Applied_price_ IPC=PRICE_CLOSE_;           
input int Shift=0;                               
//+----------------------------------------------+
//---- îáúÿâëåíèå ãëîáàëüíûõ ïåðåìåííûõ
double dPriceShift,Coeff,Phase,Res1,Res2,dFilter;
int Len,Cycle;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
//--- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå â äàëüíåéøåì
//--- áóäóò èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double SellBuffer[],BuyBuffer[];
//--- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int ATR_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà ATR
   int ATR_Period=15;
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà ATR");
      return(INIT_FAILED);
     }
//---- èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   Coeff=3*PI;
   Phase=Length-1;
   Cycle=4;
   Len=int(Length*Cycle+Phase);
   Res1=1.0/(Phase-1);
   Res2=(2.0*Cycle-1.0)/(Cycle*Length-1.0);
   min_rates_total=int(Len)+1;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//---- èíèöèàëèçàöèÿ ñäâèãà ïî âåðòèêàëè
   dFilter=_Point*Filter;
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà ïî ãîðèçîíòàëè íà Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- ñèìâîë äëÿ èíäèêàòîðà
//PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà ïî ãîðèçîíòàëè íà Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- ñèìâîë äëÿ èíäèêàòîðà
//PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- èíèöèàëèçàöèÿ ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname;
   StringConcatenate(shortname,"DotsSign(",Length,")");
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
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
//--- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- îáúÿâëåíèå ïåðåìåííûõ ñ ïëàâàþùåé òî÷êîé  
   double alfa,beta,t,Sum,Weight,g,price,MA,ATR[1];
   static double MA_prev;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ è ïîëó÷åíèå óæå ïîñ÷èòàííûõ áàðîâ
   int first,bar,trend;
   static int trend_prev;
//---- ðàñ÷åò ñòàðòîâîãî íîìåðà first äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      first=min_rates_total; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
      bar=first-1;
      MA_prev=close[bar];
     }
   else first=prev_calculated-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Weight=0; Sum=0; t=0;
      //---
      for(int iii=0; iii<Len; iii++)
        {
         g=1.0/(Coeff*t+1);
         if(t<=0.5) g=1;
         beta=MathCos(PI*t);
         alfa=g*beta;
         price=PriceSeries(IPC,bar-iii,open,low,high,close);
         Sum+=alfa*price;
         Weight+=alfa;
         if(t<1) t+=Res1;
         else if(t<Len-1) t+=Res2;
        }
      //---
      if(Weight) MA=Sum/MathAbs(Weight);
      else MA=MA_prev;
      if(Filter && MathAbs(MA-MA_prev)<dFilter) MA=MA_prev;
      //---
      if(MA-MA_prev>dFilter) trend=+1;
      else if(MA_prev-MA>dFilter) trend=-1;
      //----       
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(trend_prev<=0 && trend>0)
        {
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(trend_prev>=0 && trend<0)
        {
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar!=rates_total-1)
        {
         MA_prev=MA;
         trend_prev=trend;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Ïîëó÷åíèå çíà÷åíèÿ öåíîâîé òàéìñåðèè                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,// öåíîâàÿ êîíñòàíòà
                   uint   bar,        // èíäåêñ ñäâèãà îòíîñèòåëüíî òåêóùåãî áàðà íà óêàçàííîå êîëè÷åñòâî ïåðèîäîâ íàçàä èëè âïåðåä
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- Öåíîâûå êîíñòàíòû èç ïåðå÷èñëåíèÿ ENUM_APPLIED_PRICE
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
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
