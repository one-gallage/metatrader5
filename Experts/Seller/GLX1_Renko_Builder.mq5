// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ErangaGallage

//  ________  _______    ______   __    __   ______    ______          ______    ______   __        __         ______    ______   ________ 
// /        |/       \  /      \ /  \  /  | /      \  /      \        /      \  /      \ /  |      /  |       /      \  /      \ /        |
// $$$$$$$$/ $$$$$$$  |/$$$$$$  |$$  \ $$ |/$$$$$$  |/$$$$$$  |      /$$$$$$  |/$$$$$$  |$$ |      $$ |      /$$$$$$  |/$$$$$$  |$$$$$$$$/ 
// $$ |__    $$ |__$$ |$$ |__$$ |$$$  \$$ |$$ | _$$/ $$ |__$$ |      $$ | _$$/ $$ |__$$ |$$ |      $$ |      $$ |__$$ |$$ | _$$/ $$ |__    
// $$    |   $$    $$< $$    $$ |$$$$  $$ |$$ |/    |$$    $$ |      $$ |/    |$$    $$ |$$ |      $$ |      $$    $$ |$$ |/    |$$    |   
// $$$$$/    $$$$$$$  |$$$$$$$$ |$$ $$ $$ |$$ |$$$$ |$$$$$$$$ |      $$ |$$$$ |$$$$$$$$ |$$ |      $$ |      $$$$$$$$ |$$ |$$$$ |$$$$$/    
// $$ |_____ $$ |  $$ |$$ |  $$ |$$ |$$$$ |$$ \__$$ |$$ |  $$ |      $$ \__$$ |$$ |  $$ |$$ |_____ $$ |_____ $$ |  $$ |$$ \__$$ |$$ |_____ 
// $$       |$$ |  $$ |$$ |  $$ |$$ | $$$ |$$    $$/ $$ |  $$ |      $$    $$/ $$ |  $$ |$$       |$$       |$$ |  $$ |$$    $$/ $$       |
// $$$$$$$$/ $$/   $$/ $$/   $$/ $$/   $$/  $$$$$$/  $$/   $$/        $$$$$$/  $$/   $$/ $$$$$$$$/ $$$$$$$$/ $$/   $$/  $$$$$$/  $$$$$$$$/ 

#property version   "1.00"
#property description "GLX1_Renko_Builder"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_renko.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

input group    "Renko Bar Calculation"
input ENUM_TIMEFRAMES   ATRTimeFrame = PERIOD_D1;              //ATR Time frame
input int               ATRPeriod = 14;                        //ATR Period
input double            ATRPercentage = 10;                     //ATR Percentage (10 = 10%)

input group    "Renko Bar Generation"
input bool              RenkoWicks     = true;                 //Enable Renko Wicks
int               RenkoTimer     = 30;                   // Timer in Seconds (0 = Off)
bool              RenkoTime      = true;                 // Brick Open Time
bool              RenkoAsymetricReversal = false;        // Asymetric Reversals
ENUM_RENKO_WINDOW RenkoWindow    = RENKO_NEW_WINDOW; // Chart Mode
ENUM_RENKO_TYPE RenkoType    = RENKO_TYPE_POINTS; // Chart Type
bool              RenkoBook      = false;                 // Watch Market Book


//+------------------------------------------------------------------+
//| Internal variables and objects                                   |
//+------------------------------------------------------------------+
CMyRenkoChart *renko_chart;
string original_symbol, custom_symbol;
int handle_atr;
bool _DebugMode = (MQL5InfoInteger(MQL5_TESTER) || MQL5InfoInteger(MQL5_DEBUG) || MQL5InfoInteger(MQL5_DEBUGGING) || MQL5InfoInteger(MQL5_OPTIMIZATION) || MQL5InfoInteger(MQL5_VISUAL_MODE) || MQL5InfoInteger(MQL5_PROFILER));
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   // Check Symbol
   original_symbol = _Symbol;
   /*if(ValidSymbolOrigin(original_symbol) == false) {
      MessageBox("This EA can only be used with currency pair 'EURAUD' on M1", __FILE__, MB_OK);
      return(INIT_FAILED);
   }*/    
   //Check Period
   if(ChartPeriod(0) != PERIOD_M1) {
      MessageBox("Change the period to M1 and attach the EA !", __FILE__, MB_OK);
      //ChartSetSymbolPeriod(0, _Symbol, PERIOD_M1);
      return(INIT_FAILED);
   }
   // ATR Config
   handle_atr = iATR(original_symbol, ATRTimeFrame, ATRPeriod);
   if(handle_atr == INVALID_HANDLE) {
      MessageBox("Renko ATR indicator error !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }
   // Setup Renko
   double renko_size = ATRBoxSize();
   if (renko_chart == NULL)
      if ((renko_chart = new CMyRenkoChart()) == NULL) {
         MessageBox("Renko create class error !", __FILE__, MB_OK);
         return(INIT_FAILED);
      }
   if(!renko_chart.Setup(original_symbol, RenkoType, renko_size, RenkoWicks)) {
      MessageBox("Renko setup error !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }
   // Create Custom Symbol
   StringConcatenate(custom_symbol
                     , original_symbol
                     , "_RENKO_"
                     , StringPeriod(ATRTimeFrame) 
                     , StringFormat("P%g", ATRPercentage)                  
                    );
   if(!renko_chart.CreateCustomSymbol(custom_symbol)) {
      MessageBox("Renko Custom Symbol creation error !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }

   renko_chart.ClearCustomSymbol();
   // Load History
   renko_chart.UpdateRates();
   renko_chart.ReplaceCustomSymbol();
   //Start
   renko_chart.Start(RenkoWindow, RenkoTimer*1000, RenkoBook);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if(renko_chart != NULL) {
      renko_chart.Stop();
      delete renko_chart;
      renko_chart = NULL;
   }
}
//+------------------------------------------------------------------+
//| Tick Event (for testing purposes only)                           |
//+------------------------------------------------------------------+
void OnTick() {
   if(!IsStopped())
      if(renko_chart != NULL)
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
      next_update = current - current % PeriodSeconds(ATRTimeFrame) + PeriodSeconds(ATRTimeFrame);
      double renko_size = ATRBoxSize();
      if(!renko_chart.Setup(original_symbol, RENKO_TYPE_POINTS, renko_size, RenkoWicks)) {
         MessageBox("Renko reload error. Check error log!", __FILE__, MB_OK);
         return;
      }
      //Update history
      renko_chart.ClearRates();
      renko_chart.UpdateRates();
      //Update custom symbol
      renko_chart.ClearCustomSymbol();
      renko_chart.ReplaceCustomSymbol();
   }
   renko_chart.Refresh();
}

double ATRBoxSize() {
   ResetLastError();
   double return_array[];
   ArraySetAsSeries(return_array, true);
   int cbar_count = CopyBuffer(handle_atr, 0, 0, 3, return_array)>0;
   double size = 0;
   if(cbar_count <= 0) {
      Print("Failed to copy buffer of ATR indicator handle, Error= ", IntegerToString(GetLastError())); 
   }  
   size = return_array[1] * ATRPercentage / 100;
   return NormalizeDouble(size, _Digits);
}

string StringPeriod(ENUM_TIMEFRAMES value) {
   if(value == PERIOD_CURRENT) value = (ENUM_TIMEFRAMES) _Period;
   string period = EnumToString(value);
   return StringSubstr(period, 7);
}

string StringMethod(ENUM_MA_METHOD value) {
   string method = EnumToString(value);
   return StringSubstr(method, 5);
}

bool ValidSymbolOrigin(string pSymbol) {
   int len = StringLen(pSymbol);
   int index = StringFind(pSymbol,"EURAUD");
   if (len > 0 && index >= 0) {
      return true;
   }
   return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
