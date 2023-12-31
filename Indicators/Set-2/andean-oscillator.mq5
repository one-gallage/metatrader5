//+------------------------------------------------------------------+
//|                                            Andean Oscillator.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot Bull
#property indicator_label1  "Bull"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bear
#property indicator_label2  "Bear"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Signal
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input    int      inp_length           = 50;
input    int      inp_signal_length    = 9;

int length, signal_length;
double alpha;

double up1[];
double up2[];
double dn1[];
double dn2[];
double bull[];
double bear[];
double ma[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//--- check input parameters
   length = inp_length < 1 ? 1 : inp_length;
   signal_length = inp_signal_length < 1 ? 1 : inp_signal_length;
//--- indicator buffers mapping
   SetIndexBuffer(0, bull, INDICATOR_DATA);
   SetIndexBuffer(1, bear, INDICATOR_DATA);
   SetIndexBuffer(2, ma, INDICATOR_DATA);
   SetIndexBuffer(3, up1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, up2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, dn1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, dn2, INDICATOR_CALCULATIONS);
//---

   ArrayInitialize(bull, EMPTY_VALUE);
   ArrayInitialize(bear, EMPTY_VALUE);
   ArrayInitialize(ma, EMPTY_VALUE);
   ArrayInitialize(up1, EMPTY_VALUE);
   ArrayInitialize(up2, EMPTY_VALUE);
   ArrayInitialize(dn1, EMPTY_VALUE);
   ArrayInitialize(dn2, EMPTY_VALUE);
   
   alpha = 2.0 / (double(length +1));
   
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
//---
//--- calculate start position
   int bar;
   if(prev_calculated == 0)
      bar = 0;
   else
      bar = prev_calculated - 1;
      
   for(int i = bar; i < rates_total && !_StopFlag; i++)
     {
       if(i > fmax(length, signal_length))
        {
         up1[i] = MathMax(MathMax(close[i], open[i]), up1[i-1] - (up1[i-1] - close[i]) * alpha);
         up2[i] = MathMax(MathMax(close[i] * close[i], open[i] * open[i]), up2[i-1] - (up2[i-1] - close[i]* close[i]) * alpha);
         if (up1[i] == 0) up1[i] = close[i];
         if (up2[i] == 0) up2[i] = close[i] * close[i];
         
         dn1[i] = MathMin(MathMin(close[i], open[i]), dn1[i-1] + (close[i]- dn1[i-1]) * alpha);
         dn2[i] = MathMin(MathMin(close[i] * close[i], open[i] * open[i]), dn2[i-1] + (close[i]* close[i]- dn2[i-1]) * alpha);
         if (dn1[i] == 0) dn1[i] = close[i];
         if (dn2[i] == 0) dn2[i] = close[i]* close[i];
         
         bull[i] = MathSqrt(dn2[i] - dn1[i] * dn1[i]);
         bear[i] = MathSqrt(up2[i] - up1[i] * up1[i]);
         
         double ma_ = 0;
         for (int j = 0; j < signal_length; j++)
         {
            ma_ += MathMax(bull[i-j],bear[i-j]);
         }
         ma[i] = ma_ / double (signal_length);
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
