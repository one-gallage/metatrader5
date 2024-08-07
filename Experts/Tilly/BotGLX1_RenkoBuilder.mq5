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

#property version   "1.2"
#property description "BotGLX1_RenkoBuilder"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

enum MY_ENUM_RENKO_MODE {
   ATR_BASED_SIZE,
   FIXED_SIZE
};

string            Robot_Name              = "BotGLX1_RenkoBuilder"; // Robot Name
bool              RenkoAsymetric          = false;                // Asymetric
int               RenkoTimer              = 5;                    // Timer in Seconds (0 = Off)
bool              RenkoBook               = true;                 // Watch Market Book

input group "*** Renko Bar Generation Settings ***"
input MY_ENUM_RENKO_MODE   RenkoMode      = ATR_BASED_SIZE;       //Renko Mode
input int         HistoryDaysCount        = 10;                   //History days Count
input bool        RenkoWicks              = true;                 //Enable Renko Wicks

input group "*** ATR_BASED_SIZE calculation ***"
input ENUM_TIMEFRAMES      ATRTimeFrame   = PERIOD_D1;            //ATR Time frame
input int                  ATRPeriod      = 5;                    //ATR Period
input double               ATRPercentage  = 10;                   //ATR Percentage (10 = 10%)

input group "*** FIXED_SIZE calculation ***"
input double               ValueFixedSize = 0.0001;               //Fixed Size

input group    ""

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_renko.mqh>
#include <Tilly/tilly_framework.mqh>

//+------------------------------------------------------------------+
//| Internal variables and objects                                   |
//+------------------------------------------------------------------+
CMyRenkoChart *renko_chart;
CMyAppWidget*     mAppWidget;
string original_symbol, custom_symbol;
int handle_atr;
bool testing_mode = false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   string mqlProgramName = MQLInfoString(MQL_PROGRAM_NAME);
   if ( Robot_Name != mqlProgramName ) {
      MessageBox("Invalid file name= '" + mqlProgramName + "' owned by the expert, it must be '" + Robot_Name +"'.", Robot_Name, MB_OK);
      return (INIT_PARAMETERS_INCORRECT);
   }   
   //--- Check Symbol
   original_symbol = _Symbol;
   if ( (bool)MQLInfoInteger(MQL_DEBUG) || (bool)MQLInfoInteger(MQL_PROFILER) || (bool)MQLInfoInteger(MQL_TESTER) ||
           (bool)MQLInfoInteger(MQL_FORWARD) || (bool)MQLInfoInteger(MQL_OPTIMIZATION) || (bool)MQLInfoInteger(MQL_VISUAL_MODE) || 
           (bool)MQLInfoInteger(MQL_FRAME_MODE) ) {
      testing_mode = true;
   }    
   //--- Setup Renko
   if(renko_chart != NULL) {      
      renko_chart.Stop();
      delete renko_chart;
      renko_chart = NULL;
      Sleep(100);  
   }    
   /*if(ValidSymbolOrigin("EURUSD") || ValidSymbolOrigin("EURAUD")) {   
   } else {
      MessageBox("This EA can only be used with Symbol 'EURUSD' or 'EURAUD' on M1", __FILE__, MB_OK);
      return(INIT_FAILED);   
   }*/  
   //Check Period
   if(ChartPeriod(0) != PERIOD_M1) {
      MessageBox("Change the period to M1 and re-attach the EA !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }
   //--- ATR Config
   handle_atr = iATR(original_symbol, ATRTimeFrame, ATRPeriod);
   if(handle_atr == INVALID_HANDLE) {
      MessageBox("Renko ATR indicator error !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }  
   if ((renko_chart = new CMyRenkoChart()) == NULL) {
      MessageBox("Renko class creation error !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }
   //--- Create Custom Symbol 
   double renko_size = SetupNameAndSize();
   if(!renko_chart.Create(original_symbol, RENKO_TYPE_POINTS, renko_size, RenkoWicks, true, HistoryDaysCount, RenkoAsymetric, custom_symbol)) {
      MessageBox("Renko Custom Symbol creation error !", __FILE__, MB_OK);
      return(INIT_FAILED);
   }
   renko_chart.ClearRates();
   renko_chart.ClearCustomSymbol();
   //--- Load History
   renko_chart.UpdateRates();
   renko_chart.ReplaceCustomSymbol();
   //--- Start Renko
   ENUM_RENKO_WINDOW renko_window = testing_mode ? RENKO_CURRENT_WINDOW : RENKO_NEW_WINDOW;
   renko_chart.Start(renko_window, RenkoTimer, RenkoBook);
   //--- Start Widget UI
   if(mAppWidget != NULL) {
      delete mAppWidget;
      mAppWidget = NULL;
      Sleep(100);  
   }   
   mAppWidget = new CMyAppWidget(); 
   mAppWidget.Start(custom_symbol);   
   ChartRedraw();
   CMyUtil::Info(mqlProgramName, " started successfully !");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int pReason) {
   if(renko_chart != NULL) {
      renko_chart.Stop();
      delete renko_chart;
      renko_chart = NULL;
   } 
   if(mAppWidget != NULL) {
      delete mAppWidget;
      mAppWidget = NULL; 
   }     
   ChartRedraw();
   CMyUtil::CheckDeinitReason(pReason);      
}
//+------------------------------------------------------------------+
//| Tick Event (for testing purposes only)                           |
//+------------------------------------------------------------------+
void OnTick() {
   CustomRefresh();
}
//+------------------------------------------------------------------+
//| Book Event                                                       |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol) {
   if(RenkoBook) CustomRefresh();
}
//+------------------------------------------------------------------+
//| Timer Event                                                      |
//+------------------------------------------------------------------+
void OnTimer() {
   if(RenkoTimer > 1 && testing_mode == false) CustomRefresh();
}

void CustomRefresh() {
   if(IsStopped() || renko_chart == NULL) return;
    
   static bool in_update = false;
   if (in_update) return;
   in_update = true;    
   
   datetime current_time = TimeCurrent();
   //--- Update ATR Boxes
   static datetime last_update = current_time;
   if ((current_time - last_update) >= RenkoTimer) {
      last_update = current_time; 
      renko_chart.UpdateRates();
      renko_chart.ReplaceCustomSymbol();          
   }       
   renko_chart.UpdateCustomTick();
   in_update = false;
}

double SetupNameAndSize() {
   ResetLastError();
   double size = 0;
   if ( RenkoMode == ATR_BASED_SIZE ) {
      StringConcatenate(custom_symbol
                     , original_symbol
                     , "_RENKO_"
                     , StringPeriod(ATRTimeFrame) 
                     , StringFormat("P%g", ATRPercentage)                  
                    );     
      double return_array[]; 
      ArraySetAsSeries(return_array, true);
      int cbar_count = CopyBuffer(handle_atr, 0, 0, 3, return_array);
      
      if (testing_mode) {
         //--- CopyBuffer doesn't work during OnInit
         double range = MathAbs(iHigh(original_symbol, ATRTimeFrame, 1) - iLow(original_symbol, ATRTimeFrame, 1));
         size = range * ATRPercentage / 100;
      } else {
         if(cbar_count <= 0) {
            Print("Failed to copy buffer of ATR indicator handle, Error= ", IntegerToString(GetLastError())); 
         }  
         size = return_array[2] * ATRPercentage / 100;
      }
   } else {
      StringConcatenate(custom_symbol
                     , original_symbol
                     , "_RENKO_"
                     , (string)ValueFixedSize                 
                    );    
      size = ValueFixedSize;
   }
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

bool ValidSymbolOrigin(string pRestrictedSymbol) {
   int len = StringLen(original_symbol);
   int index = StringFind(original_symbol, pRestrictedSymbol);
   if (len > 0 && index >= 0) {
      return true;
   }
   return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
