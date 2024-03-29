//+------------------------------------------------------------------+ 
//|                                                 Ichimoku_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window
//---- êîëè÷åñòâî èíäèêàòîðíûõ áóôåðîâ 8
#property indicator_buffers 8
//---- èñïîëüçîâàíî âñåãî ïÿòü ãðàôè÷åñêèõ ïîñòðîåíèé
#property indicator_plots   5
//+----------------------------------------------+
//| îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET 0                                 // Êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
#define INDICATOR_NAME "Ichimoku"               // Êîíñòàíòà äëÿ èìåíè èíäèêàòîðà
#define SIZE 8                                  // Êîíñòàíòà äëÿ êîëè÷åñòâà âûçîâîâ ôóíêöèè CountLine
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà Tenkan-sen    |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 1 â âèäå ëèíèè
#property indicator_type1   DRAW_LINE
//---- â êà÷åñòâå öâåòà îñíîâíîé ëèíèè èíäèêàòîðà èñïîëüçîâàí öâåò Red
#property indicator_color1  clrRed
//---- ëèíèÿ èíäèêàòîðà 1 - íåïðåðûâíàÿ êðèâàÿ
#property indicator_style1  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 1
#property indicator_width1  1
//---- îòîáðàæåíèå ìåòêè ëèíèè èíäèêàòîðà
#property indicator_label1  "Tenkan-sen"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà Kijun-sen     |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 2 â âèäå ëèíèè
#property indicator_type2   DRAW_LINE
//---- â êà÷åñòâå öâåòà ñèãíàëüíîé ëèíèè èíäèêàòîðà èñïîëüçîâàí öâåò Blue
#property indicator_color2  clrBlue
//---- ëèíèÿ èíäèêàòîðà 2 - íåïðåðûâíàÿ êðèâàÿ
#property indicator_style2  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 1
#property indicator_width2  1
//---- îòîáðàæåíèå ìåòêè ëèíèè èíäèêàòîðà
#property indicator_label2  "Kijun-sen"
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè îáëàêà Senkou           |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå öâåòíîãî îáëàêà
#property indicator_type3   DRAW_FILLING
//---- â êà÷åñòâå öâåòà îáëàêà èñïîëüçîâàí
#property indicator_color3  clrPaleTurquoise,clrLavenderBlush
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label3  "Senkou Span A;Senkou Span B"
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè ìóâèíãà  Chinkou Span   |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå ëèíèè
#property indicator_type4   DRAW_LINE
//---- â êà÷åñòâå öâåòà ëèíèè èíäèêàòîðà èñïîëüçîâàí ñàëàòîâûé öâåò
#property indicator_color4 clrLime
//---- ëèíèÿ èíäèêàòîðà - ñïëîøíàÿ
#property indicator_style4  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 2
#property indicator_width4  2
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label4  "Chinkou Span"
//+----------------------------------------------+
//|  Ïàðàìåòðû îòðèñîâêè ìóâèíãà  Chinkou Span   |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå öâåòíîé ãèñòîãðàììû
#property indicator_type5   DRAW_COLOR_HISTOGRAM2
//---- â êà÷åñòâå öâåòà ëèíèè èíäèêàòîðà èñïîëüçîâàíû
#property indicator_color5 clrRed,clrBlue
//---- ëèíèÿ èíäèêàòîðà - øòðèõ-ïóíêòèð
#property indicator_style5  STYLE_DASHDOTDOT
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 1
#property indicator_width5  1
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label5  "Tenkan-sen; Kijun-sen"
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;
input int InpTenkan=9;     // Tenkan-sen
input int InpKijun=26;     // Kijun-sen
input int InpSenkou=52;    // Senkou Span B
//+----------------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
// äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
//--- îáúÿâëåíèå ñòðîêîâûõ ïåðåìåííûõ
string Symbol_,Word;
//--- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total,Shift;
//--- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int Ind_Handle;
//+------------------------------------------------------------------+
//| Ïîëó÷åíèå òàéìôðåéìà â âèäå ñòðîêè                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES Timeframe)
  {return(StringSubstr(EnumToString(Timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- ïðîâåðêà ïåðèîäîâ ãðàôèêîâ íà êîððåêòíîñòü
   if(InpTenkan>0)
      if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
        {
         Print("Ïåðèîä ãðàôèêà äëÿ èíäèêàòîðà Ichimoku íå ìîæåò áûòü ìåíüøå ïåðèîäà òåêóùåãî ãðàôèêà");
         return(INIT_FAILED);
        }
//--- èíèöèàëèçàöèÿ ïåðåìåííûõ 
   min_rates_total=2;
   if(InpTenkan>0) Shift=(InpKijun-2)*PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" èíäèêàòîð: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà Ichimoku
   if(InpTenkan>0)
     {
      Ind_Handle=iCustom(Symbol_,TimeFrame,MQLInfoString(MQL_PROGRAM_NAME),PERIOD_CURRENT,-InpTenkan,InpKijun,InpSenkou);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà "+MQLInfoString(MQL_PROGRAM_NAME));
         return(INIT_FAILED);
        }
     }
//---- ïðåâðàùåíèå äèíàìè÷åñêèõ ìàññèâîâ â èíäèêàòîðíûå áóôåðû
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer8,INDICATOR_COLOR_INDEX);
//---- óñòàíîâêà ïîçèöèè, ñ êîòîðîé íà÷èíàåòñÿ îòðèñîâêà óðîâíåé
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- çàâåðøåíèå èíèöèàëèçàöèè
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(rates_total<min_rates_total) return(RESET);
   if(InpTenkan>0)
     {
      //--- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
      ArraySetAsSeries(Time,true);
      //---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà ïî ãîðèçîíòàëè
      datetime time1[1],timex[];
      if(CopyTime(Symbol(),TimeFrame,1,1,time1)<=0) return(RESET);
      if(CopyTime(Symbol(),NULL,Time[0],time1[0],timex)<=0) return(RESET);
      int shiftx=Shift+ArraySize(timex);
      PlotIndexSetInteger(2,PLOT_SHIFT,shiftx);
      PlotIndexSetInteger(3,PLOT_SHIFT,-shiftx);
      //--- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
      if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,ExtLineBuffer1,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,ExtLineBuffer2,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,ExtLineBuffer3,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,ExtLineBuffer4,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(4,NULL,TimeFrame,Ind_Handle,4,ExtLineBuffer5,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(5,NULL,TimeFrame,Ind_Handle,5,ExtLineBuffer6,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(6,NULL,TimeFrame,Ind_Handle,6,ExtLineBuffer7,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(7,NULL,TimeFrame,Ind_Handle,7,ExtLineBuffer8,Time,rates_total,prev_calculated,min_rates_total)) return(RESET);
     }
   else
     {
      int limit;
      //---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
      ArraySetAsSeries(High,true);
      ArraySetAsSeries(Low,true);
      ArraySetAsSeries(Close,true);
      //---
      if(prev_calculated==0) limit=0;
      else                   limit=prev_calculated-1;
      //---
      for(int i=limit;i<rates_total && !IsStopped();i++)
        {
         ExtLineBuffer5[i]=Close[i];
         //--- tenkan sen
         double high=High[ArrayMaximum(High,i,MathAbs(InpTenkan))];
         double low=Low[ArrayMinimum(Low,i,MathAbs(InpTenkan))];
         ExtLineBuffer1[i]=ExtLineBuffer6[i]=(high+low)/2.0;
         //--- kijun sen
         high=High[ArrayMaximum(High,i,InpKijun)];
         low=Low[ArrayMinimum(Low,i,InpKijun)];
         ExtLineBuffer2[i]=ExtLineBuffer7[i]=(high+low)/2.0;
         //--- senkou span a
         ExtLineBuffer3[i]=(ExtLineBuffer1[i]+ExtLineBuffer2[i])/2.0;
         //--- senkou span b
         high=High[ArrayMaximum(High,i,InpSenkou)];
         low=Low[ArrayMinimum(Low,i,InpSenkou)];
         ExtLineBuffer4[i]=(high+low)/2.0;
         if(ExtLineBuffer2[i]<ExtLineBuffer1[i]) ExtLineBuffer8[i]=1;
         else ExtLineBuffer8[i]=0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Íîìåð ôóíêöèè CountLine ïî ñïèñêó â êîäå èíäèêàòîðà (ñòàðòîâûé íîìåð - 0)
                    string   Symb,            // Ñèìâîë ãðàôèêà
                    ENUM_TIMEFRAMES TFrame,   // Ïåðèîä ãðàôèêà
                    int      IndHandle,       // Õåíäë îáðàáàòûâàåìîãî èíäèêàòîðà
                    uint     BuffNumb,        // Íîìåð áóôåðà îáðàáàòûâàåìîãî èíäèêàòîðà
                    double&  IndBuf[],        // Ïðèåìíûé áóôåð èíäèêàòîðà
                    const datetime& iTime[],  // Òàéìñåðèÿ âðåìåíè
                    const int Rates_Total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                    const int Prev_Calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
                    const int Min_Rates_Total)// ìèíèìàëüíîå êîëè÷åñòâî èñòîðèè â áàðàõ äëÿ ðàñ÷åòà
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ
//--- è ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=Rates_Total-Min_Rates_Total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ 
//--- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- îáíóëèì ñîäåðæèìîå èíäèêàòîðíûõ áóôåðîâ äî ðàñ÷åòà
      IndBuf[bar]=0.0;
      //--- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâ IndTime
      if(CopyTime(Symbol_,TimeFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâ Arr
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
