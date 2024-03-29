//+------------------------------------------------------------------------------------------------------------------+
//|                                                                              fractal_dimension.mq5               |
//|                                                                              Copyright © 2011, iliko             |
//|                                                                              arcsin5@netscape.net                |
//|                                                                                                                  |
//|  The Fractal Dimension Index determines the amount of market volatility. The easiest way to use this indicator is|
//|  to understand that a value of 1.5 suggests the market is acting in a completely random fashion.                 |
//|  As the market deviates from 1.5, the opportunity for earning profits is increased in proportion                 |
//|  to the amount of deviation.                                                                                     |
//|  But be carreful, the indicator does not show the direction of trends !!                                         |
//|                                                                                                                  |
//|  The indicator is red when the market is in a trend. And it is blue when there is a high volatility.             |
//|  When the FDI changes its color from red to blue, it means that a trend is finishing, the market becomes         |
//|  erratic and a high volatility is present. Usually, these "blue times" do not go for a long time.They come before|
//|  a new trend.                                                                                                    |
//|                                                                                                                  |
//|  For more informations, see                                                                                      |
//|  http://www.forex-tsd.com/suggestions-trading-systems/6119-tasc-03-07-fractal-dimension-index.html               |
//|                                                                                                                  |
//|                                                                                                                  |   
//|  HOW TO USE INPUT PARAMETERS :                                                                                   |   
//|  -----------------------------                                                                                   |   
//|                                                                                                                  |   
//|      1) e_period [ integer >= 1 ]                                              =>  30                            |   
//|                                                                                                                  |   
//|         The indicator will compute the historical market volatility over this period.                            |   
//|         Choose its value according to the average of trend lengths.                                              |   
//|                                                                                                                  |   
//|      2) e_type_data [ int = {PRICE_CLOSE_ = 1,     //Close                                                       |
//|                              PRICE_OPEN_,          //Open                                                        |
//|                              PRICE_HIGH_,          //High                                                        |
//|                              PRICE_LOW_,           //Low                                                         |
//|                              PRICE_MEDIAN_,        //Median Price (HL/2)                                         |
//|                              PRICE_TYPICAL_,       //Typical Price (HLC/3)                                       |
//|                              PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)                                     |
//|                              PRICE_SIMPL_,         //Simpl Price (OC/2)                                          |
//|                              PRICE_QUARTER_,       //Quarted Price (HLOC/4)                                      |
//|                              PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price                                         |
//|                              PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price                                         |
//|                              PRICE_DEMARK_         //Demark Price}     => PRICE_CLOSE                            |   
//|                                                                                                                  |   
//|         Defines on which price type the Fractal Dimension is computed.                                           |   
//|                                                                                                                  |
//|      3) e_random_line [ 0.0 < double < 2.0 ]                                   => 1.5                            |
//|                                                                                                                  |
//|         Defines your separation betwen a trend market (red) and an erratic/high volatily one.                    |   
//|                                                                                                                  |   
//| v1.0 - February 2007                                                                                             |   
//+------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2011, iliko"
#property link "arcsin5@netscape.net"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â îòäåëüíîì îêíå
#property indicator_separate_window 
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ
#property indicator_buffers 2 
//---- èñïîëüçîâàíî âñåãî îäíî ãðàôè÷åñêîå ïîñòðîåíèå
#property indicator_plots   1
//+-----------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà    |
//+-----------------------------------+
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
//+-----------------------------------+
//| Îáúÿâëåíèå ïåðå÷èñëåíèé           |
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
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà      |
//+-----------------------------------+
input uint                e_period=30;          
input Applied_price_   e_type_data=PRICE_CLOSE;
input double         e_random_line=1.5;        
input int                    Shift=0;         
//+-----------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
//---- äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double IndBuffer[],ColorIndBuffer[];
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
//---- îáúÿâëåíèå ãëîáàëüíûõ ïåðåìåííûõ
int Count[];
double Price[];
double Log2,Log2e,Pow2e;
//+------------------------------------------------------------------+
//| Ïåðåñ÷åò ïîçèöèè ñàìîãî íîâîãî ýëåìåíòà â ìàññèâå                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// âîçâðàò ïî ññûëêå íîìåðà òåêóùåãî çíà÷åíèÿ öåíîâîãî ðÿäà
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+   
//| fractal_dimension indicator initialization function              | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   min_rates_total=int(e_period);
   Log2e=MathLog(2*e_period);
   Pow2e=1.0/MathPow(e_period,2.0);
   Log2=MathLog(2.0);
//---- ðàñïðåäåëåíèå ïàìÿòè ïîä ìàññèâû ïåðåìåííûõ  
   ArrayResize(Count,e_period);
   ArrayResize(Price,e_period);
//----
   ArrayInitialize(Count,0);
   ArrayInitialize(Price,0.0);
//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâå êàê â òàéìñåðèè
   ArraySetAsSeries(Price,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(IndBuffer,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ColorIndBuffer,true);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- èíèöèàëèçàöèÿ ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname;
   StringConcatenate(shortname,"fractal_dimension(",
                     e_period,", ",EnumToString(e_type_data),", ",
                     DoubleToString(e_random_line,4),", ",Shift,")");
//---- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
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
   if(rates_total<min_rates_total) return(0);
//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- îáúÿâëåíèå ïåðåìåííûõ ñ ïëàâàþùåé òî÷êîé  
   double HH,LL,diff,priorDiff,length,fdi,Range;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ è ïîëó÷åíèå óæå ïîñ÷èòàííûõ áàðîâ
   int limit,bar,iii,clr;
//---- ðàñ÷åò ñòàðòîâîãî íîìåðà first äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
      limit=rates_total-1;   // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
   else limit=rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Price[Count[0]]=PriceSeries(e_type_data,bar,open,low,high,close);
      HH=high[ArrayMaximum(high,bar,e_period)];
      LL=low[ArrayMinimum(low,bar,e_period)];
      Range=HH-LL;
      length=0.0;
      priorDiff=0.0;
      //----
      if(Range) for(iii=0; iii<int(e_period); iii++)
        {
         diff=(Price[Count[iii]]-LL)/Range;
         length+=MathSqrt(MathPow(diff-priorDiff,2.0)+Pow2e);
         priorDiff=diff;
        }
      //----
      if(length>0.0) fdi=1.0+(MathLog(length)+Log2)/Log2e;
      else
        {
         //---- The FDI algorithm suggests in this case a zero value. I prefer to use the previous FDI value.
         fdi=0.0;
        }
      //----
      IndBuffer[bar]=fdi;
      if(bar) Recount_ArrayZeroPos(Count,e_period);
     }
//---- êîððåêòèðîâêà çíà÷åíèÿ ïåðåìåííîé limit
   if(prev_calculated>rates_total || prev_calculated<=0) limit-=min_rates_total;
//---- îñíîâíîé öèêë ðàñêðàñêè ñèãíàëüíîé ëèíèè
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(IndBuffer[bar]>=e_random_line) clr=1;
      else clr=0;
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Ïîëó÷åíèå çíà÷åíèÿ öåíîâîé òàéìñåðèè                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,  // öåíîâàÿ êîíñòàíòà
                   uint bar,            // èíäåêñ ñäâèãà îòíîñèòåëüíî òåêóùåãî áàðà íà óêàçàííîå êîëè÷åñòâî ïåðèîäîâ íàçàä èëè âïåðåä
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[]
                   )
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
