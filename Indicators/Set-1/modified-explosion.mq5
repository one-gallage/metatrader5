//+------------------------------------------------------------------+
//|                                           modified-explosion.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version   "1.00"
#property description "modified-explosion"
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_plots   3
#property indicator_minimum 0
//--- plot Trend Histogram settings
#property indicator_label1  "Trend Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrLimeGreen,clrRed,clrTomato
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot Explosion Line settings
#property indicator_label2  "Explosion Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Dead Zone Line settings
#property indicator_label3  "Dead Zone Line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_DASHDOTDOT
#property indicator_width3  1
//--- enumerations
enum ENUM_PRICE_DERIVATIVE
  {
   Open,       // Open
   High,       // High
   Low,        // Low
   Close,      // Close
   Median,     // Median, (h+l)/2
   Mid,        // Mid, (o+c)/2
   Typical,    // Typical, (h+l+c)/3
   Weighted,   // Weighted, (h+l+c+c)/4
   Average     // Average, (o+h+l+c)/4
  };
enum ENUM_YES_NO
  {
   Yes,        // Yes
   No          // No
  };  
//--- input parameters
input ENUM_PRICE_DERIVATIVE      inp_price            = Close;       // Price Derivative
input int                        inp_sensitivity      = 150;         // Sensitivity
input int                        inp_fastlength       = 20;          // Fast EMA Length
input int                        inp_slowlength       = 40;          // Slow EMA Length
input int                        inp_bblength         = 20;          // BB Length
input double                     inp_bbstdev          = 2.0;         // BB Stdev Multiplier
input ENUM_YES_NO                inp_smoothyesno      = Yes;         // Smooth Trend Histogram?
//--- indicator plot buffers
double                           TrendHistogramPlot[];
double                           TrendHistogramColor[];
double                           ExplosionLinePlot[];
double                           DeadZoneLinePlot[];
//--- indicator calculation buffers
double                           Price[];
double                           TR[];
double                           ATR[];
double                           FastEMA[];
double                           SlowEMA[];
double                           Base[];
double                           Dev[];
double                           Trend[];
double                           TrendHistogram[];
double                           SmoothedTrendHistogram[];
double                           ExplosionLine[];
double                           DeadZoneLine[];
//--- variables
int                              sensitivity;
int                              fastlength;
int                              slowlength;
int                              bblength;
double                           bbstdev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check input parameters
   sensitivity = inp_sensitivity < 1 ? 1 : inp_sensitivity;
   fastlength = inp_fastlength < 1 ? 1 : inp_fastlength;
   slowlength = inp_slowlength < inp_fastlength ? inp_fastlength * 2 : inp_slowlength;
   bblength = inp_bblength < 1 ? 1 : inp_bblength;
   bbstdev = inp_bbstdev < 0.5 ? 0.5 : inp_bbstdev;
//--- indicator buffers mapping
   SetIndexBuffer(0, TrendHistogramPlot, INDICATOR_DATA);
   SetIndexBuffer(1, TrendHistogramColor, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExplosionLinePlot, INDICATOR_DATA);
   SetIndexBuffer(3, DeadZoneLinePlot, INDICATOR_DATA);
   SetIndexBuffer(4, Price, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, TR, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, ATR, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, FastEMA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, SlowEMA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, Base, INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, Dev, INDICATOR_CALCULATIONS);
   SetIndexBuffer(11, Trend, INDICATOR_CALCULATIONS);
   SetIndexBuffer(12, TrendHistogram, INDICATOR_CALCULATIONS);
   SetIndexBuffer(13, SmoothedTrendHistogram, INDICATOR_CALCULATIONS);
   SetIndexBuffer(14, ExplosionLine, INDICATOR_CALCULATIONS);
   SetIndexBuffer(15, DeadZoneLine, INDICATOR_CALCULATIONS);
//--- set indicator accuracy
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);
//--- set indicator name display
   string short_name = "Modified Explosion (" + EnumToString(inp_price) + ", " + string(sensitivity) + ", " + string(fastlength) + ", " + string(slowlength) + ", " + string(bblength) + ", " + DoubleToString(bbstdev, 1) + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//--- sets drawing lines to empty value
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//--- initialization succeeded
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
//--- check period
   if(rates_total < fmax(sensitivity, fmax(fastlength, fmax(slowlength, bblength))))
      return(0);
//--- calculate start position
   int start_position;
   if(prev_calculated == 0)
      start_position = 0;
   else
      start_position = prev_calculated - 1;
//--- main loop
   for(int i = start_position; i < rates_total && !_StopFlag; i++)
     {
      //--- populate price derivative buffer
      if(inp_price == Open)
         Price[i] = open[i];
      if(inp_price == High)
         Price[i] = high[i];
      if(inp_price == Low)
         Price[i] = low[i];
      if(inp_price == Close)
         Price[i] = close[i];
      if(inp_price == Median)
         Price[i] = (high[i] + low[i]) / 2;
      if(inp_price == Mid)
         Price[i] = (open[i] + close[i]) / 2;
      if(inp_price == Typical)
         Price[i] = (high[i] + low[i] + close[i]) / 3;
      if(inp_price == Weighted)
         Price[i] = (high[i] + low[i] + close[i] + close[i]) / 4;
      if(inp_price == Average)
         Price[i] = (open[i] + high[i] + low[i] + close[i]) / 4;
      //--- populate true range buffer
      TR[i] = i < 1 ? high[i] - low[i] : fmax(high[i] - low[i], fmax(fabs(high[i] - close[i - 1]), fabs(low[i] - close[i - 1])));
      //--- populate average true range buffer
      ATR[i] = i < 1 ? 0.0 : RMA(i, 100, ATR[i - 1], TR);
      //--- populate fast exponential moving average buffer
      FastEMA[i] = i < 1 ? 0.0 : EMA(i, fastlength, FastEMA[i - 1], Price);
      //--- populate slow exponential moving average buffer
      SlowEMA[i] = i < 1 ? 0.0 : EMA(i, slowlength, SlowEMA[i - 1], Price);
      //--- populate bollinger bands simple moving average base buffer
      Base[i] = i < bblength ? 0.0 : SMA(i, bblength, Price);
      //--- populate bollinger bands deviation buffer
      Dev[i] = i < bblength ? 0.0 : bbstdev * SD(i, bblength, Price);
      //--- populate trend and trend histogram buffer
      Trend[i] = i < 2 ? 0.0 : ((FastEMA[i] - SlowEMA[i]) - (FastEMA[i - 1] - SlowEMA[i - 1])) * sensitivity;
      TrendHistogram[i] = i < 2 ? 0.0 : Trend[i] >= 0.0 ? Trend[i] : Trend[i] < 0.0 ? -1 * Trend[i] : 0.0;
      //--- populate smoothed trend histogram buffer
      SmoothedTrendHistogram[i] = i < 3 ? 0.0 : LRMA(i, 8, TrendHistogram);
      //--- populate explosion line buffer
      ExplosionLine[i] = i < bblength ? 0.0 : (Base[i] + Dev[i]) - (Base[i] - Dev[i]);
      //--- populate dead zone line buffer
      DeadZoneLine[i] = i < 1 ? 0.0 : ATR[i] * 3.7;
      //--- plot trend histogram
      TrendHistogramPlot[i] = i < bblength ? EMPTY_VALUE : inp_smoothyesno == Yes ? SmoothedTrendHistogram[i] : inp_smoothyesno == No ? TrendHistogram[i] : 0.0;
      //--- populate trend histogram color
      TrendHistogramColor[i] = i < bblength ? EMPTY_VALUE : Trend[i] >= 0.0 && SmoothedTrendHistogram[i] > SmoothedTrendHistogram[i - 1] ? 0.0 : Trend[i] >= 0.0 && SmoothedTrendHistogram[i] < SmoothedTrendHistogram[i - 1] ? 1.0 : Trend[i] < 0.0 && SmoothedTrendHistogram[i] > SmoothedTrendHistogram[i - 1] ? 2.0 : Trend[i] < 0.0 && SmoothedTrendHistogram[i] < SmoothedTrendHistogram[i - 1] ? 3.0 : EMPTY_VALUE;
      //--- plot explosion line
      ExplosionLinePlot[i] = i < bblength ? EMPTY_VALUE : ExplosionLine[i];
      //--- plot dead zone line
      DeadZoneLinePlot[i] = i < bblength ? EMPTY_VALUE : DeadZoneLine[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//*****************************
//***** SUPPORT FUNCTIONS *****
//*****************************
//+------------------------------------------------------------------+
//| Function: Rolling (Smoothed) Moving Average (RMA)                |
//+------------------------------------------------------------------+
double RMA(const int position, const int period, const double prev_RMA_1_period_back, const double &price[])
  {
   double result = 0.0;
   if(period > 0 && period <= (position + 1))
      result = (prev_RMA_1_period_back * (period - 1) + price[position]) / period;
   return(result);
  }
//+------------------------------------------------------------------+
//| Function: Exponential Moving Average (EMA)                       |
//+------------------------------------------------------------------+
double EMA(const int position, const int period, const double prev_EMA_1_period_back, const double &price[])
  {
   double result = 0.0;
   if(period > 0)
     {
      double pr = 2.0 / (period + 1.0);
      result = price[position] * pr + prev_EMA_1_period_back * (1 - pr);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Function: Simple Moving Average (SMA)                            |
//+------------------------------------------------------------------+
double SMA(const int position, const int period, const double &price[])
  {
   double result = 0.0;
   if(period > 0 && period <= (position + 1))
     {
      for(int j = position - (period - 1); j <= position; j++)
         result += price[j];
      result /= period;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Function: Standard Deviation (SD)                                |
//+------------------------------------------------------------------+
double SD(const int position, const int period, const double &price[])
  {
   double result = 0.0;
   double mean = 0.0;
   for(int j = position - (period - 1); j <= position; j++)
      mean += price[j];
   mean = mean / period;
   double dev = 0.0;
   for(int j = position - (period - 1); j <= position; j++)
      dev += pow(price[j] - mean, 2);
   result = sqrt(dev / period);
   return (result);
  }
//+------------------------------------------------------------------+
//| Function: SuperSmoother Filter (SSF) by John F. Ehlers           |
//+------------------------------------------------------------------+
double SSF(const int position, const int period, const double prev_SSF_1_period_back, const double prev_SSF_2_period_back, const double &price[])
  {
   double result = 0.0;
   if(period > 0 && period <= (position + 1))
     {
      double a1 = exp(-sqrt(2.0) * M_PI / period);
      double c2 = 2 * a1 * cos((sqrt(2.0) * 180 / period) * (M_PI / 180));
      double c3 = -pow(a1, 2);
      double c1 = 1 - c2 - c3;
      result = c1 * (price[position] + price[position - 1]) / 2 + c2 * prev_SSF_1_period_back + c3 * prev_SSF_2_period_back;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Function: Linear Regression Moving Average (LRMA)                |
//+------------------------------------------------------------------+
double LRMA(const int position, const int period, const double &price[])
  {
   double result = 0.0;
   if(period > 0 && period <= (position + 1))
     {
      double sumX = 0.0;
      double sumY = 0.0;
      double sumXY = 0.0;
      double sumXpow2 = 0.0;
      for(int j = position - (period - 1); j <= position; j++)
        {
         sumX += j;
         sumY += price[j];
         sumXY += j * price[j];
         sumXpow2 += pow(j, 2);
        }
      double m = (period * sumXY - sumX * sumY) / (period * sumXpow2 - pow(sumX, 2));
      double b = (sumY - m * sumX) / period;
      result = m * position + b;
     }
   return(result);
  }
//+------------------------------------------------------------------+
