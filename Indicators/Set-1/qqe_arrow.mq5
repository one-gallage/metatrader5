//+------------------------------------------------------------------+
//|                                                    QQE Arrow.mq5 |
//|                              Copyright © 2021, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43516 |
//|                                                                  |
//|                                                          QQE.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//|                                                                  |
//|                                                        Based on: |
//|                                                          QQE.mq5 |
//|                                      Copyright © 2010, EarnForex |
//|                                         http://www.earnforex.com |
//|                             Based on version by Tim Hyder (2008) |
//|                         Based on version by Roman Ignatov (2006) |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43516"
#property version   "1.005"
//#property version     "V02"

/*--------------------------------------------------------------------
2010 09 26: v02   Code rewritten to make the indicator work better with MetaTrader5
                  Fixed wrong values returned at the start of the chart
----------------------------------------------------------------------*/
#property description "QQE - Qualitative Quantitative Estimation."
#property description "Calculated as two indicators:"
#property description "1) MA on RSI"
#property description "2) Difference of MA on RSI and MA of MA of ATR of MA of RSI"
#property description "The signal for buy is when blue line crosses level 50 from below"
#property description "after crossing the yellow line from below."
#property description "The signal for sell is when blue line crosses level 50 from above"
#property description "after crossing the yellow line from above."
#include <MovingAverages.mqh>
#property indicator_separate_window
#property indicator_buffers    8
#property indicator_plots      4
//--- plot Fast RSI MA
#property indicator_label1     "Fast RSI MA"
#property indicator_width1     2
#property indicator_color1     clrDodgerBlue
#property indicator_type1      DRAW_LINE
#property indicator_style1     STYLE_SOLID
//--- plot Slow RSI MA
#property indicator_label2     "Slow RSI MA"
#property indicator_width2     1
#property indicator_color2     clrOrange
#property indicator_type2      DRAW_LINE
#property indicator_style2     STYLE_DOT
//--- plot BUY
#property indicator_label3     "BUY"
#property indicator_type3      DRAW_ARROW
#property indicator_color3     clrBlue
#property indicator_style3     STYLE_SOLID
#property indicator_width3     1
//--- plot SELL
#property indicator_label4     "SELL"
#property indicator_type4      DRAW_ARROW
#property indicator_color4     clrRed
#property indicator_style4     STYLE_SOLID
#property indicator_width4     1
//--- indicator levels
#property indicator_level1     50
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int                  InpSF             = 5;           // Smoothing Factor
input int                  InpRSI            = 14;          // RSI Period
input int                  InpAlertLevel     = 50;          // Alert level
input bool                 InpMsgAlerts      = false;       // Use alert message
input bool                 InpEmailAlerts    = false;       // Send email alert
input bool                 InpSoundAlerts    = false;       // Play sound alert
string               InpSoundAlertFile = "alert.wav"; // Sound alert
input ENUM_APPLIED_PRICE   InpAppliedPrice   = PRICE_CLOSE; // Applied price
input group             "Arrow"
input uchar                InpCodeBuy        = 233;         // Arrow code for 'BUY' (font Wingdings)
input uchar                InpCodeSell       = 234;         // Arrow code for 'SELL' (font Wingdings)
input int                  InpShift          = 10;          // Vertical shift of arrows in pixel
//--- indicator buffers
double   ExtRsiMaBuffer[];          // moving average of RSI
double   ExtTrLevelSlowBuffer[];    // true range level
double   BUYBuffer[];               // arrow 'BUY'
double   SELLBuffer[];              // arrow 'SELL'
double   ExtRsiBuffer[];            // RSI
double   ExtAtrRsiBuffer[];         // average true range of RSI
double   ExtMaAtrRsiBuffer[];       // moving average of true range of RSI
double   ExtMaMaAtrRsiBuffer[];     // moving average of moving average of true range of RSI
//--- indicator handle
int      handle_iRSI;               // variable for storing the handle of the iRSI indicator
//--- global variables
int      Wilders_Period;
int      SmoothingFactor, RSI_Period;
int      AlertLevel;
int      LastAlertBar;
//--- turn on/off error messages
bool     ShowErrorMessages = true;  // turn on/off error messages for debugging
//---
bool     m_init_error      = false; // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  RSI_Period = InpRSI;
//--- set Wilders Period
   Wilders_Period=RSI_Period*2-1;
//--- check smoothing factor
   SmoothingFactor=InpSF;
   if(SmoothingFactor<=0)
      SmoothingFactor=5;
//--- check alert level
   AlertLevel=InpAlertLevel;
   if(AlertLevel<0 || AlertLevel>100)
      AlertLevel=50;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRsiMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTrLevelSlowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,BUYBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,SELLBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtRsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtAtrRsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtMaAtrRsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,ExtMaMaAtrRsiBuffer,INDICATOR_CALCULATIONS);
//--- define the symbol code for drawing in PLOT_ARROW
   PlotIndexSetInteger(2,PLOT_ARROW,InpCodeBuy);
   PlotIndexSetInteger(3,PLOT_ARROW,InpCodeSell);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,+InpShift);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-InpShift);
//--- Set as an empty value 0
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(ExtRsiMaBuffer,true);
   ArraySetAsSeries(ExtTrLevelSlowBuffer,true);
   ArraySetAsSeries(BUYBuffer,true);
   ArraySetAsSeries(SELLBuffer,true);
   ArraySetAsSeries(ExtRsiBuffer,true);
   ArraySetAsSeries(ExtAtrRsiBuffer,true);
   ArraySetAsSeries(ExtMaAtrRsiBuffer,true);
   ArraySetAsSeries(ExtMaMaAtrRsiBuffer,true);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RSI_Period+SmoothingFactor);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,RSI_Period+SmoothingFactor+1+Wilders_Period+Wilders_Period);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- set maximum and minimum for subwindow
   IndicatorSetDouble(INDICATOR_MINIMUM,-5);
   IndicatorSetDouble(INDICATOR_MAXIMUM,105);
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"QQE("+IntegerToString(SmoothingFactor)+")");
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(Symbol(),Period(),RSI_Period,InpAppliedPrice);
//--- if the handle is not created
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Converts timeframe period to string                              |
//+------------------------------------------------------------------+
string TF2Str(ENUM_TIMEFRAMES period)
  {
   return(StringSubstr(EnumToString(period),7,-1));
  }
//+------------------------------------------------------------------+
//| QQE                                                              |
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
   if(m_init_error)
      return(0);
//--- check for data
   if(rates_total<=MathMax(Wilders_Period,SmoothingFactor))
      return(0);
//--- not all data may be calculated
   int calculated;
   calculated=BarsCalculated(handle_iRSI);
   if(calculated<rates_total)
     {
      if(ShowErrorMessages)
         Print("Not all data of handle_iRSI has been calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      //--- older bars ([1]) are needed to calculate the current bar
      limit=rates_total-1-1;
   else
      limit=rates_total-prev_calculated;
//--- calculate how many bars need to be recalculated
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }
//--- get RSI buffer values
   if(CopyBuffer(handle_iRSI,0,0,to_copy,ExtRsiBuffer)<=0)
     {
      if(ShowErrorMessages)
         Print("Getting RSI failed! Error",GetLastError());
      return(0);
     }
//--- get EMA of RSI buffer values
   ExponentialMAOnBuffer(rates_total,prev_calculated,RSI_Period,SmoothingFactor,ExtRsiBuffer,ExtRsiMaBuffer);
//--- get ATR of EMA of RSI buffer values
   for(int i=limit; i>=0; i--)
      ExtAtrRsiBuffer[i]=MathAbs(ExtRsiMaBuffer[i+1]-ExtRsiMaBuffer[i]);
//--- get EMA of ATR of EMA of RSI buffer values
   ExponentialMAOnBuffer(rates_total,prev_calculated,RSI_Period+SmoothingFactor+1,Wilders_Period,ExtAtrRsiBuffer,ExtMaAtrRsiBuffer);
//--- get EMA of EMA of ATR of EMA of RSI buffer values
   ExponentialMAOnBuffer(rates_total,prev_calculated,RSI_Period+SmoothingFactor+1+Wilders_Period,Wilders_Period,ExtMaAtrRsiBuffer,ExtMaMaAtrRsiBuffer);
//--- get ExtTrLevelSlowBuffer values
   double rsi0,rsi1,dar,tr,dv;
   tr=ExtTrLevelSlowBuffer[limit+1];
   rsi1=ExtRsiMaBuffer[limit+1];
   for(int i=limit+1; i>=0; i--)
     {
      BUYBuffer[i]=0.0;
      SELLBuffer[i]=0.0;
      //---
      rsi0=ExtRsiMaBuffer[i];
      dar=ExtMaMaAtrRsiBuffer[i]*4.236;
      dv=tr;
      if(rsi0<tr)
        {
         tr=rsi0+dar;
         if((rsi1<dv) && (tr>dv))
            tr=dv;
        }
      else
         if(rsi0>tr)
           {
            tr=rsi0-dar;
            if((rsi1>dv) && (tr<dv))
               tr=dv;
           }
      ExtTrLevelSlowBuffer[i]=tr;
      rsi1=rsi0;
      //---
      if(i<rates_total-RSI_Period)
        {
         if(ExtRsiMaBuffer[i+1]<ExtTrLevelSlowBuffer[i+1] && ExtRsiMaBuffer[i]>ExtTrLevelSlowBuffer[i])
            BUYBuffer[i]=ExtTrLevelSlowBuffer[i];
         if(ExtRsiMaBuffer[i+1]>ExtTrLevelSlowBuffer[i+1] && ExtRsiMaBuffer[i]<ExtTrLevelSlowBuffer[i])
            SELLBuffer[i]=ExtTrLevelSlowBuffer[i];
        }
     }
//--- check if alerts are set
   if((InpMsgAlerts || InpSoundAlerts || InpEmailAlerts) && rates_total>LastAlertBar)
     {
      //--- check if alert level is hit and set direction of alert
      int AlertDirection=0;
      if((ExtRsiMaBuffer[1]<AlertLevel && ExtRsiMaBuffer[0]>=AlertLevel) || (BUYBuffer[0]!=0.0))
         AlertDirection=1;
      if((ExtRsiMaBuffer[1]>AlertLevel && ExtRsiMaBuffer[0]<=AlertLevel) || (SELLBuffer[0]!=0.0))
         AlertDirection=-1;
      if(AlertDirection==1 || AlertDirection==-1)
        {
         //--- create alert subject
         string AlertSubj=Symbol()+","+TF2Str(Period())+", "+IntegerToString(AlertLevel)+" level Cross ";
         if(AlertDirection==1)
            AlertSubj=AlertSubj+"UP";
         if(AlertDirection==-1)
            AlertSubj=AlertSubj+"DOWN";
         //--- create alert message
         string AlertMsg=AlertSubj+" @ "+TimeToString(TimeLocal(),TIME_SECONDS);
         //--- pop up alert message
         if(InpMsgAlerts)
            Alert(AlertMsg);
         //--- send email alert message
         if(InpEmailAlerts)
           {
            bool mailsent=false;
            mailsent=SendMail(AlertSubj,AlertMsg);
            if(mailsent==false && ShowErrorMessages)
               Print("Email alert was not sent! ",AlertMsg," --- Error",GetLastError());
           }
         //--- play sound alert
         if(InpSoundAlerts)
           {
            bool playsoundfile=false;
            playsoundfile=PlaySound(InpSoundAlertFile);
            if(playsoundfile==false && ShowErrorMessages)
               Print("Soundfile not found:\"",InpSoundAlertFile,"\" --- Error",GetLastError());
           }
         //--- send only one alert per bar
         LastAlertBar=rates_total;
        }
     }
//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iRSI!=INVALID_HANDLE)
      IndicatorRelease(handle_iRSI);
  }
//+------------------------------------------------------------------+