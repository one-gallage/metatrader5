//+------------------------------------------------------------------+
//|                                                    Renko2ATR.mq5 |
//|                                Copyright 2018, Guilherme Santos. |
//|                                               fishguil@gmail.com |
//|                                                    Renko 2.0 ATR |
//|                                                                  |
//|2018-04-10:                                                       |
//| Add tick event and remove timer event for tester                 |
//|2018-04-30:                                                       |
//| Correct volume on renko bars, wicks, performance, and parameters |
//|2018-05-10:                                                       |
//| Now with timer event                                             |
//|2018-05-16:                                                       |
//| New methods and MiniChart display by Marcelo Hoepfner            |
//|2018-06-21:                                                       |
//| New library with custom tick, performance and other improvements |
//|2018-09-27:                                                       |
//| Asymetric reversals, corrections on wick size and initialization |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Guilherme Santos."
#property link      "fishguil@gmail.com"
#property version   "2.0"
#property description "Renko 2.0 ATR"
#include <Tilly/Utils/RenkoCharts.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
// Inputs

input double               RenkoBoxSize = 50;                     //Renko Box Size Pips
input bool              RenkoWicks     = true;                 // Show Wicks
input bool              RenkoTime      = true;                 // Brick Open Time
input bool              RenkoAsymetricReversal = false;        // Asymetric Reversals
ENUM_RENKO_WINDOW RenkoWindow    = RENKO_NEW_WINDOW; // Chart Mode
ENUM_RENKO_TYPE RenkoType    = RENKO_TYPE_POINTS; // Chart Type
input int               RenkoTimer     = 30000;                 // Timer in milliseconds (0 = Off)
bool              RenkoBook      = true;                 // Watch Market Book


//+------------------------------------------------------------------+
//| Internal variables and objects                                   |
//+------------------------------------------------------------------+
RenkoCharts *RenkoOffline;
string original_symbol, custom_symbol;
int hATR, hMA;
bool _DebugMode = (MQL5InfoInteger(MQL5_TESTER) || MQL5InfoInteger(MQL5_DEBUG) || MQL5InfoInteger(MQL5_DEBUGGING) || MQL5InfoInteger(MQL5_OPTIMIZATION) || MQL5InfoInteger(MQL5_VISUAL_MODE) || MQL5InfoInteger(MQL5_PROFILER));
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   // Check Symbol
   original_symbol = _Symbol; // StringAt(_Symbol, ",");
   //Check Period
   if(ChartPeriod(0) != PERIOD_M1) {
      MessageBox("Chart must be M1 period!", __FILE__, MB_OK);
      ChartSetSymbolPeriod(0, _Symbol, PERIOD_M1);
   }
   // Setup Renko
   double renko_size = ATRBoxSize();
   if (RenkoOffline == NULL)
      if ((RenkoOffline = new RenkoCharts()) == NULL) {
         MessageBox("Renko create class error!", __FILE__, MB_OK);
         return(INIT_FAILED);
      }
   if(!RenkoOffline.Setup(original_symbol, RenkoType, renko_size, RenkoWicks)) {
      MessageBox("Renko setup error!", __FILE__, MB_OK);
      return(INIT_FAILED);
   }
   // Create Custom Symbol
   StringConcatenate(custom_symbol
                     , original_symbol
                     , "#Box#", (string) renko_size                    
                    );
   if(!RenkoOffline.CreateCustomSymbol(custom_symbol)) {
      MessageBox("Renko Custom Symbol creation error!", __FILE__, MB_OK);
      return(INIT_FAILED);
   }

   RenkoOffline.ClearCustomSymbol();
   // Load History
   RenkoOffline.UpdateRates();
   RenkoOffline.ReplaceCustomSymbol();
   //Start
   RenkoOffline.Start(RenkoWindow, RenkoTimer, RenkoBook);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if(RenkoOffline != NULL) {
      RenkoOffline.Stop();
      delete RenkoOffline;
      RenkoOffline = NULL;
   }
}
//+------------------------------------------------------------------+
//| Tick Event (for testing purposes only)                           |
//+------------------------------------------------------------------+
void OnTick() {
   if(!IsStopped())
      if(RenkoOffline != NULL)
         CustomRefresh();
}
//+------------------------------------------------------------------+
//| Book Event                                                       |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol) {
   if(RenkoBook)
      OnTick();
}
//+------------------------------------------------------------------+
//| Timer Event                                                      |
//+------------------------------------------------------------------+
void OnTimer() {
   if(RenkoTimer > 0)
      if(!MQL5InfoInteger(MQL5_TESTER) && !MQL5InfoInteger(MQL5_OPTIMIZATION))
         OnTick();
}
//+------------------------------------------------------------------+
void CustomRefresh() {
   static datetime next_update;
   //Update ATR Boxes
   datetime current = TimeCurrent();
   if(next_update <= current) {
      next_update = current - current % PeriodSeconds(PERIOD_M1) + PeriodSeconds(PERIOD_M1);
      double renko_size = ATRBoxSize();
      if(!RenkoOffline.Setup(original_symbol, RENKO_TYPE_POINTS, renko_size, RenkoWicks)) {
         MessageBox("Renko reload error. Check error log!", "Renko 2.0 ATR", MB_OK);
         return;
      }
      //Update history
      RenkoOffline.ClearRates();
      RenkoOffline.UpdateRates();
      //Update custom symbol
      RenkoOffline.ClearCustomSymbol();
      RenkoOffline.ReplaceCustomSymbol();
   }
   RenkoOffline.Refresh();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ATRBoxSize() {   
   return RenkoBoxSize;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringPeriod(ENUM_TIMEFRAMES value) {
   if(value == PERIOD_CURRENT) value = (ENUM_TIMEFRAMES) _Period;
   string period = EnumToString(value);
   return StringSubstr(period, 7);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringMethod(ENUM_MA_METHOD value) {
   string method = EnumToString(value);
   return StringSubstr(method, 5);
}
//+------------------------------------------------------------------+