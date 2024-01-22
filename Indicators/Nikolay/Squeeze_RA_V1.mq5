//+---------------------------------------------------------------------+
//|                                                   Squeeze_RA_V1.mq5 | 
//|                                  Copyright © 2015, Ravish Anandaram | 
//|                                     mailto: aravishstocks@gmail.com | 
//+---------------------------------------------------------------------+ 
// ===========================================================================================================
// This indicator is based on a strategy mentioned in John Carter's book, Mastering the Trade. 
// It is also a fully improvised version of Squeeze_Break indicator by DesO'Regan.
// You can find that implementation here: 
// https://www.mql5.com/en/code/8840?utm_campaign=MetaTrader+4+Terminal&utm_medium=special&utm_source=mt4terminal+codebase
// The main improvements include plotting squeeze values (some BB/KC calculation changes) on the zero-line and then to smoothen the momentum values as rising/falling positive/negative histograms
// to match the ones sold on commercial websites. This is easy on the eye.
// Uses some of the Linear Regression code from Victor Nicolaev aka Vinin's V_LRMA.mq4 for smoothening the histograms
// This version DOES NOT have any alerts functionality and also does not have inputs to change.
// The reason is - this is V1 and generally no body changes the BB and KC values. Feel free to enhance on your own.
// And if you like this indicator pa$$ :-) on to -->  Ravish Anandaram (aravishstocks@gmail.com)
// ===========================================================================================================
#property copyright "Copyright © 2015, Ravish Anandaram"
#property link      "aravishstocks@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован MediumBlue цвет
#property indicator_color1 clrMediumBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "SqzFiredLong"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type2   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован Tomato цвет
#property indicator_color2 clrTomato
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2 3
//---- отображение метки индикатора
#property indicator_label2 "SqzFiredShort"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
#property indicator_type3   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color3  clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3 3
//---- отображение метки индикатора
#property indicator_label3 "SqzFiredLong_Weak"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 4             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type4   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован Orange цвет
#property indicator_color4  clrOrange
//---- линия индикатора - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width4 3
//---- отображение метки индикатора
#property indicator_label4 "SqzFiredShort_Weak"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 5             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значков
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color5  clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width5 3
//---- отображение метки индикатора
#property indicator_label5 "Squeeze_Off"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 6             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значков
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета линии индикатора использован Magenta цвет
#property indicator_color6  clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width6 3
//---- отображение метки индикатора
#property indicator_label6 "Squeeze_On"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                        // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Internal Global Variables                    |
//+----------------------------------------------+
int       Bollinger_Period=20;
double    Bollinger_Deviation=2.0;
int       Keltner_Period=20;
double    Keltner_ATR=1.5;
ENUM_MA_METHOD Bollinger_MaMode=MODE_SMA;
ENUM_MA_METHOD Keltner_MaMode=MODE_SMA;
int       BarsToGoBack=1000;
double      LSmoothX=1.0;
double      LSmoothY=1.0;
double      LSmoothFactor_1=3.0;
double      LSmoothFactor_2=3.0;
int Shift=0; // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double Squeeze_Off[];           // Green Dots on the zero line
double Squeeze_On[];            // Red Dots on the zero line
double SqzFiredLong_Strong[];   // Rising Positive Histograms 
double SqzFiredShort_Strong[];  // Falling Negative Histograms 
double SqzFiredLong_Weak[];     // Falling Positive Histograms 
double SqzFiredShort_Weak[];    // Rising Negative Histograms
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,Smooth_Factor;
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle,Std_Handle,Ma1_Handle,Ma2_Handle,Ma3_Handle,Ma4_Handle;
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+    
void IndInit(int number,double &Array[],int shift,int draw_begin,double empty_value)
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(number,Array,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(number,PLOT_SHIFT,shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(number,PLOT_DRAW_BEGIN,draw_begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(number,PLOT_EMPTY_VALUE,empty_value);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(Array,true);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+    
int GetSmoothFactor(ENUM_TIMEFRAMES period)
  {
//----
   switch(period)
     {
      case PERIOD_M1:  return(300);
      case PERIOD_M2:  return(230);
      case PERIOD_M4:  return(150);
      case PERIOD_M5:  return(100);
      case PERIOD_M6:  return(80);
      case PERIOD_M10: return(65);
      case PERIOD_M15: return(50);
      case PERIOD_M20: return(50);
      case PERIOD_M30: return(50);
      case PERIOD_H1:  return(30);
      case PERIOD_H2:  return(20);
      case PERIOD_H3:  return(12);
      case PERIOD_H4:  return(8);
      case PERIOD_H6:  return(7);
      case PERIOD_H8:  return(6);
      case PERIOD_H12: return(5);
      case PERIOD_D1:  return(6);
      case PERIOD_W1:  return(4);
      case PERIOD_MN1: return(4);
     }
//----
   return(300);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,Keltner_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iStdDev
   Std_Handle=iStdDev(NULL,0,Bollinger_Period,0,Bollinger_MaMode,PRICE_CLOSE);
   if(Std_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStdDev");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA1
   Ma1_Handle=iMA(NULL,0,Keltner_Period,0,MODE_SMA,PRICE_CLOSE);
   if(Ma1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA1");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA2
   Ma2_Handle=iMA(NULL,0,Keltner_Period,0,MODE_LWMA,PRICE_CLOSE);
   if(Ma2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA2");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA3
   Ma3_Handle=iMA(NULL,0,Keltner_Period,0,Keltner_MaMode,PRICE_CLOSE);
   if(Ma3_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA3");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA4
   Ma4_Handle=iMA(NULL,0,Bollinger_Period,0,Bollinger_MaMode,PRICE_CLOSE);
   if(Ma4_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA4");
      return(INIT_FAILED);
     }
//---- 
   min_rates_total=Keltner_Period+Bollinger_Period;
   Smooth_Factor=GetSmoothFactor(Period());
//---- превращение динамических массивов в индикаторные буферы
   IndInit(0,SqzFiredLong_Strong,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(1,SqzFiredShort_Strong,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(2,SqzFiredLong_Weak,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(3,SqzFiredShort_Weak,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(4,Squeeze_Off,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(5,Squeeze_On,Shift,min_rates_total,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Squeeze_RA_V1");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(Std_Handle)<rates_total
      || BarsCalculated(Ma1_Handle)<rates_total
      || BarsCalculated(Ma2_Handle)<rates_total
      || BarsCalculated(Ma3_Handle)<rates_total
      || BarsCalculated(Ma4_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double Std[],ATR[],MA1[],MA2[],MA3[],MA4[];

//--- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Std_Handle,0,0,to_copy,Std)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(Ma1_Handle,0,0,to_copy,MA1)<=0) return(RESET);
   if(CopyBuffer(Ma2_Handle,0,0,to_copy,MA2)<=0) return(RESET);
   if(CopyBuffer(Ma3_Handle,0,0,to_copy,MA3)<=0) return(RESET);
   if(CopyBuffer(Ma4_Handle,0,0,to_copy,MA4)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Std,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(MA1,true);
   ArraySetAsSeries(MA2,true);
   ArraySetAsSeries(MA3,true);
   ArraySetAsSeries(MA4,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Kelt_Mid_Band=MA3[bar];
      double Kelt_Upper_Band=Kelt_Mid_Band+ATR[bar]*Keltner_ATR;
      double Kelt_Lower_Band=Kelt_Mid_Band-ATR[bar]*Keltner_ATR;
      //---
      double StdDev=Std[bar];
      double Ma=MA4[bar];
      double Boll_Upper_Band=Ma+StdDev*Bollinger_Deviation;
      double Boll_Lower_Band=Ma-StdDev*Bollinger_Deviation;
      //---
      double LSmooth1,LSmooth2,LSmoothVal,dLSmoothVal;
      LSmooth1=LSmoothX*MA1[bar];
      LSmooth2=MA2[bar]/LSmoothY;
      LSmoothVal=LSmoothFactor_1*LSmooth2-LSmoothFactor_2*LSmooth1;
      dLSmoothVal=LSmoothVal*Smooth_Factor;
      if(dLSmoothVal>0)
        {
         if((SqzFiredLong_Strong[bar+1] && dLSmoothVal>SqzFiredLong_Strong[bar+1]) || (SqzFiredLong_Weak[bar+1] && dLSmoothVal>SqzFiredLong_Weak[bar+1]))
           {
            SqzFiredLong_Strong[bar]=dLSmoothVal; 
            SqzFiredLong_Weak[bar]=0;
           }
         else
           {
            SqzFiredLong_Weak[bar]=dLSmoothVal;
            SqzFiredLong_Strong[bar]=0;
           }
         SqzFiredShort_Strong[bar]=0;
         SqzFiredShort_Weak[bar]=0;
        }
      else
        {
         if((SqzFiredShort_Strong[bar+1] && dLSmoothVal<SqzFiredShort_Strong[bar+1]) || (SqzFiredShort_Weak[bar+1] && dLSmoothVal<SqzFiredShort_Weak[bar+1]))
           {
            SqzFiredShort_Strong[bar]=dLSmoothVal;
            SqzFiredShort_Weak[bar]=0;
           }
         else
           {
            SqzFiredShort_Weak[bar]=dLSmoothVal;
            SqzFiredShort_Strong[bar]=0;
           }
         SqzFiredLong_Strong[bar]=0;
         SqzFiredLong_Weak[bar]=0;
        }
      //---
      if(Boll_Upper_Band<Kelt_Upper_Band && Boll_Lower_Band>Kelt_Lower_Band)
        {
         Squeeze_On[bar]=0.00;
         Squeeze_Off[bar]=EMPTY_VALUE;
        }
      else
        {
         Squeeze_Off[bar]=0.00;
         Squeeze_On[bar]=EMPTY_VALUE;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
