//+---------------------------------------------------------------------+
//|                                                   Squeeze_RA_V1.mq5 | 
//|                                  Copyright � 2015, Ravish Anandaram | 
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
#property copyright "Copyright � 2015, Ravish Anandaram"
#property link      "aravishstocks@gmail.com"
//---- ����� ������ ����������
#property version   "1.00"
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window 
//---- ���������� ������������ ������� 6
#property indicator_buffers 6 
//---- ������������ ����� ����� ����������� ����������
#property indicator_plots   6
//+----------------------------------------------+
//| ��������� ��������� ���������� 1             |
//+----------------------------------------------+
//---- ��������� ���������� � ���� �����������
#property indicator_type1   DRAW_HISTOGRAM
//---- � �������� ����� ����� ���������� ����������� MediumBlue ����
#property indicator_color1 clrMediumBlue
//---- ����� ���������� - ����������� ������
#property indicator_style1  STYLE_SOLID
//---- ������� ����� ���������� ����� 3
#property indicator_width1  3
//---- ����������� ����� ����������
#property indicator_label1  "SqzFiredLong"
//+----------------------------------------------+
//| ��������� ��������� ���������� 2             |
//+----------------------------------------------+
//---- ��������� ���������� � ���� �����������
#property indicator_type2   DRAW_HISTOGRAM
//---- � �������� ����� ����� ���������� ����������� Tomato ����
#property indicator_color2 clrTomato
//---- ����� ���������� - ����������� ������
#property indicator_style2  STYLE_SOLID
//---- ������� ����� ���������� ����� 3
#property indicator_width2 3
//---- ����������� ����� ����������
#property indicator_label2 "SqzFiredShort"
//+----------------------------------------------+
//| ��������� ��������� ���������� 3             |
//+----------------------------------------------+
#property indicator_type3   DRAW_HISTOGRAM
//---- � �������� ����� ����� ���������� ����������� DodgerBlue ����
#property indicator_color3  clrDodgerBlue
//---- ����� ���������� - ����������� ������
#property indicator_style3  STYLE_SOLID
//---- ������� ����� ���������� ����� 3
#property indicator_width3 3
//---- ����������� ����� ����������
#property indicator_label3 "SqzFiredLong_Weak"
//+----------------------------------------------+
//| ��������� ��������� ���������� 4             |
//+----------------------------------------------+
//---- ��������� ���������� � ���� �����������
#property indicator_type4   DRAW_HISTOGRAM
//---- � �������� ����� ����� ���������� ����������� Orange ����
#property indicator_color4  clrOrange
//---- ����� ���������� - ����������� ������
#property indicator_style4  STYLE_SOLID
//---- ������� ����� ���������� ����� 3
#property indicator_width4 3
//---- ����������� ����� ����������
#property indicator_label4 "SqzFiredShort_Weak"
//+----------------------------------------------+
//| ��������� ��������� ���������� 5             |
//+----------------------------------------------+
//---- ��������� ���������� � ���� �������
#property indicator_type5   DRAW_ARROW
//---- � �������� ����� ����� ���������� ����������� Lime ����
#property indicator_color5  clrLime
//---- ����� ���������� - ����������� ������
#property indicator_style5  STYLE_SOLID
//---- ������� ����� ���������� ����� 3
#property indicator_width5 3
//---- ����������� ����� ����������
#property indicator_label5 "Squeeze_Off"
//+----------------------------------------------+
//| ��������� ��������� ���������� 6             |
//+----------------------------------------------+
//---- ��������� ���������� � ���� �������
#property indicator_type6   DRAW_ARROW
//---- � �������� ����� ����� ���������� ����������� Magenta ����
#property indicator_color6  clrMagenta
//---- ����� ���������� - ����������� ������
#property indicator_style6  STYLE_SOLID
//---- ������� ����� ���������� ����� 3
#property indicator_width6 3
//---- ����������� ����� ����������
#property indicator_label6 "Squeeze_On"
//+----------------------------------------------+
//|  ���������� ��������                         |
//+----------------------------------------------+
#define RESET 0                        // ��������� ��� �������� ��������� ������� �� �������� ����������
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
int Shift=0; // ����� ���������� �� ����������� � �����
//+----------------------------------------------+
//---- ���������� ������������ ��������, ������� ����� � 
//---- ���������� ������������ � �������� ������������ �������
double Squeeze_Off[];           // Green Dots on the zero line
double Squeeze_On[];            // Red Dots on the zero line
double SqzFiredLong_Strong[];   // Rising Positive Histograms 
double SqzFiredShort_Strong[];  // Falling Negative Histograms 
double SqzFiredLong_Weak[];     // Falling Positive Histograms 
double SqzFiredShort_Weak[];    // Rising Negative Histograms
//---- ���������� ����� ���������� ������ ������� ������
int min_rates_total,Smooth_Factor;
//--- ���������� ������������� ���������� ��� ������� �����������
int ATR_Handle,Std_Handle,Ma1_Handle,Ma2_Handle,Ma3_Handle,Ma4_Handle;
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+    
void IndInit(int number,double &Array[],int shift,int draw_begin,double empty_value)
  {
//---- ����������� ������������� ������� � ������������ �����
   SetIndexBuffer(number,Array,INDICATOR_DATA);
//---- ������������� ������ ���������� �� �����������
   PlotIndexSetInteger(number,PLOT_SHIFT,shift);
//---- ������������� ������ ������ ������� ��������� ����������
   PlotIndexSetInteger(number,PLOT_DRAW_BEGIN,draw_begin);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   PlotIndexSetDouble(number,PLOT_EMPTY_VALUE,empty_value);
//---- ���������� ��������� � ������� ��� � ����������   
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
//--- ��������� ������ ���������� ATR
   ATR_Handle=iATR(NULL,0,Keltner_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� ATR");
      return(INIT_FAILED);
     }
//--- ��������� ������ ���������� iStdDev
   Std_Handle=iStdDev(NULL,0,Bollinger_Period,0,Bollinger_MaMode,PRICE_CLOSE);
   if(Std_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� iStdDev");
      return(INIT_FAILED);
     }
//--- ��������� ������ ���������� iMA1
   Ma1_Handle=iMA(NULL,0,Keltner_Period,0,MODE_SMA,PRICE_CLOSE);
   if(Ma1_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� iMA1");
      return(INIT_FAILED);
     }
//--- ��������� ������ ���������� iMA2
   Ma2_Handle=iMA(NULL,0,Keltner_Period,0,MODE_LWMA,PRICE_CLOSE);
   if(Ma2_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� iMA2");
      return(INIT_FAILED);
     }
//--- ��������� ������ ���������� iMA3
   Ma3_Handle=iMA(NULL,0,Keltner_Period,0,Keltner_MaMode,PRICE_CLOSE);
   if(Ma3_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� iMA3");
      return(INIT_FAILED);
     }
//--- ��������� ������ ���������� iMA4
   Ma4_Handle=iMA(NULL,0,Bollinger_Period,0,Bollinger_MaMode,PRICE_CLOSE);
   if(Ma4_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� iMA4");
      return(INIT_FAILED);
     }
//---- 
   min_rates_total=Keltner_Period+Bollinger_Period;
   Smooth_Factor=GetSmoothFactor(Period());
//---- ����������� ������������ �������� � ������������ ������
   IndInit(0,SqzFiredLong_Strong,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(1,SqzFiredShort_Strong,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(2,SqzFiredLong_Weak,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(3,SqzFiredShort_Weak,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(4,Squeeze_Off,Shift,min_rates_total,EMPTY_VALUE);
   IndInit(5,Squeeze_On,Shift,min_rates_total,EMPTY_VALUE);
//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   IndicatorSetString(INDICATOR_SHORTNAME,"Squeeze_RA_V1");
//--- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- ���������� �������������
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
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
//--- �������� ���������� ����� �� ������������� ��� �������
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(Std_Handle)<rates_total
      || BarsCalculated(Ma1_Handle)<rates_total
      || BarsCalculated(Ma2_Handle)<rates_total
      || BarsCalculated(Ma3_Handle)<rates_total
      || BarsCalculated(Ma4_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//--- ���������� ��������� ���������� 
   int to_copy,limit,bar;
   double Std[],ATR[],MA1[],MA2[],MA3[],MA4[];

//--- ������� ������������ ���������� ���������� ������ �
//���������� ������ limit ��� ����� ��������� �����
   if(prev_calculated>rates_total || prev_calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      limit=rates_total-min_rates_total; // ��������� ����� ��� ������� ���� �����
     }
   else
     {
      limit=rates_total-prev_calculated; // ��������� ����� ��� ������� ����� �����
     }
   to_copy=limit+1;
//--- �������� ����� ����������� ������ � �������
   if(CopyBuffer(Std_Handle,0,0,to_copy,Std)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(Ma1_Handle,0,0,to_copy,MA1)<=0) return(RESET);
   if(CopyBuffer(Ma2_Handle,0,0,to_copy,MA2)<=0) return(RESET);
   if(CopyBuffer(Ma3_Handle,0,0,to_copy,MA3)<=0) return(RESET);
   if(CopyBuffer(Ma4_Handle,0,0,to_copy,MA4)<=0) return(RESET);
//--- ���������� ��������� � �������� ��� � ����������  
   ArraySetAsSeries(Std,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(MA1,true);
   ArraySetAsSeries(MA2,true);
   ArraySetAsSeries(MA3,true);
   ArraySetAsSeries(MA4,true);

//--- �������� ���� ������� ����������
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
