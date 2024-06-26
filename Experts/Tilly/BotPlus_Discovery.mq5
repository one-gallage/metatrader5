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

#property version   "1.0"
#property description "BotPlus_Discovery"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_Discovery"; // Robot Name
int      Robot_TimerSeconds                     = 0; // Robot Timer Seconds
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

uint     Algo1_Magic                            = 918;      // Magic number
double   Algo1_CapitalMultiplier                = 1;        // Account balance multiplier
input double   Algo1_RiskPercentage                   = 0.2;         // Risk percentage for a trade (0.2 = 0.2%)
input string   Algo1_Comment                          = "True_Trend";// Comment
input double   Algo1_StoplossBrickRatio               = 3;           // Stoploss Brick ratio
input double   Algo1_TakeprofitBrickRatio             = 0;           // Takeprofit Brick ratio (0.95)

input group    "..........................................................................."

input int      Algo1_IndiLength                       = 14;          // Indicator Length
input int      Algo1_IndiSmooth                       = 1;           // Indicator Smooth

input group    "..........................................................................."

input bool     Algo1_EnableTimeFilter                 = false;       // Enable time filter
input double   Algo1_TimeFilterStart                  = 08.00;       // Time filter start
input double   Algo1_TimeFilterFinish                 = 16.30;       // Time filter finish

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

class CAlgoRenko : public CMyAlgo {

private:
   
   string   m_symbol, m_symbol_custom;
   string   m_strategy_name;
   int      m_handle_solar_winds;
  
   void SetSymbolName() {
      this.m_symbol_custom = Symbol();
      this.m_symbol = CMyUtil::CurrentSymbol();
   }
   
   void SetMaximumSpread() { 
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      this.MaximumSpreadPointCount = spread_points*3;
   }   
   
   void OpenNewPosition(string _direction, double _risk, double _sl_price, double _tp_price, string _reference) {
      string signal = "c=open plus=mt m=" + this.m_symbol + " d=" + _direction + " q=" + (string)_risk + 
                     "% sl=" + (string)_sl_price + " tp=" + (string)_tp_price + " ref=" + _reference;
      this.AddSignal(signal);   
   }
     
   void CloseCurrentPosition(string _direction) {
      string signal = "c=close plus=mt m=" + this.m_symbol + " d=" + _direction;
      this.AddSignal(signal);   
   } 
   
   void OpenNewOrder(double _open_price, string _direction, double _risk, double _sl_price, double _tp_price, string _reference) {
      string signal = "c=open plus=mt m=" + this.m_symbol + " d=" + _direction + " q=" + (string)_risk + 
                     "% po="+(string)_open_price + " sl=" + (string)_sl_price + " tp=" + (string)_tp_price + " ref=" + _reference;
      this.AddSignal(signal);   
   }  
   
   void DeleteCurrentOrders() {
      string signal = "c=delete plus=mt m=" + this.m_symbol;
      this.AddSignal(signal);   
   }     
   
   string CreateComment(string _strategy, string _extra) {      
      string extra_comment = StringLen(_extra) > 0 ? "@" + _extra : "";
      return _strategy + extra_comment;    
   } 
   
   void TradeStrategy1() {
      double arr_solar[];
      int to_copy = 3;
      if(CMyUtil::XCopyBuffer(m_handle_solar_winds, 2, to_copy, true, arr_solar) == false) return; 
      
      bool ok_crossed_long = (arr_solar[2] < 0 && arr_solar[1] > 0);
      bool ok_crossed_short = (arr_solar[2] > 0 && arr_solar[1] < 0);
           
      if ( (ok_crossed_long || ok_crossed_short) == false ) return;
      
      /*int xcount_long = 0, xcount_short = 0;
      ulong xtickets_position[];        
      CMyUtil::PositionTickets((string)this.AlgoId, "", this.m_symbol, "", "", xtickets_position); 
      CPositionInfo xpositionInfo;
      for ( int k= 0; k < ArraySize(xtickets_position); k++ ) {
         if ( xpositionInfo.SelectByTicket(xtickets_position[k]) == false ) continue;         
         if ( CMyUtil::GetPositionDirection(xpositionInfo.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
            xcount_long++;
         } else {
            xcount_short++;      
         }         
      }*/      
      
      double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1); 
      double brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(close1 - open1));  
      bool ok_time_filter = Algo1_EnableTimeFilter ? CMyUtil::CheckMarketSessionTime(Algo1_TimeFilterStart, Algo1_TimeFilterFinish) : true;  
      string comment = this.CreateComment(m_strategy_name, Algo1_Comment);
      double open_price, sl_price, tp_price, spread_ticks;
      MqlTick mql_tick;  
            
      if ( ok_crossed_long ) {
         if ( ok_time_filter ) {           
            SymbolInfoTick(m_symbol, mql_tick);      
            spread_ticks =  CMyUtil::NormalizePrice(m_symbol, MathAbs(mql_tick.ask-mql_tick.bid)); 
            open_price = mql_tick.ask;
            sl_price = CMyUtil::NormalizePrice(m_symbol, close1 - (brick_ticks * Algo1_StoplossBrickRatio)) - spread_ticks;
            tp_price = Algo1_TakeprofitBrickRatio > 0 ? CMyUtil::NormalizePrice(m_symbol, open_price + (brick_ticks * Algo1_TakeprofitBrickRatio)) : 0;  
            
            OpenNewPosition(DEFINE_TRADE_DIR_LONG, Algo1_RiskPercentage, sl_price, tp_price, comment);  
         }
         //if ( xcount_short > 0 ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_SHORT);  
         //}      
      } 
      else if ( ok_crossed_short ) {  
         if ( ok_time_filter ) {                
            SymbolInfoTick(m_symbol, mql_tick);      
            spread_ticks =  CMyUtil::NormalizePrice(m_symbol, MathAbs(mql_tick.ask-mql_tick.bid)); 
            open_price = mql_tick.ask;
            sl_price = CMyUtil::NormalizePrice(m_symbol, close1 + (brick_ticks * Algo1_StoplossBrickRatio)) + spread_ticks;
            tp_price = Algo1_TakeprofitBrickRatio > 0 ? CMyUtil::NormalizePrice(m_symbol, open_price - (brick_ticks * Algo1_TakeprofitBrickRatio)) : 0;  
            
            OpenNewPosition(DEFINE_TRADE_DIR_SHORT, Algo1_RiskPercentage, sl_price, tp_price, comment);  
         }
         //if ( xcount_long > 0 ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_LONG);   
         //}     
      }       
                      
   }
  
public:   

   void SetInputParameters(int _algo_id, string _strategy) {
      this.AlgoId = _algo_id;
      this.m_strategy_name = _strategy;      
   }
  
   int OnStartAlgo() {  
      //--- initialize common configuration       
      this.CapitalMultiplier = Algo1_CapitalMultiplier;   
      //--- initialize algo specific variables  
      this.SetSymbolName();
      this.SetMaximumSpread();     
      if((this.m_handle_solar_winds = iCustom(NULL,0,"Tilly/tilly_solar_winds", Algo1_IndiLength, Algo1_IndiSmooth)) == INVALID_HANDLE ) return(INIT_FAILED); 
      int leverage = CMyUtil::LeverageAllowedForSymbol(m_symbol);
      CMyUtil::Info(m_symbol, " leverage=", (string)leverage);
      this.DisplayInfo = m_strategy_name;
      return (INIT_SUCCEEDED);
   }
   
   void OnUpdateAlgo() {       
                 
      datetime bar_time = iTime(m_symbol_custom, 0, 0); 
      static datetime var_last_trade_time = bar_time;
      
      if ( var_last_trade_time < bar_time ) {
         var_last_trade_time = bar_time;
      } else { return; }
      
      CMyUtil::Info("... analysing the new renko bar ...");
      
      TradeStrategy1();
      
   }   
      
   void OnStopAlgo() {      
      IndicatorRelease(this.m_handle_solar_winds); 
   }

   void OnTradeTransactionAlgo(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) { 
   }                        
      

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyRobot mRobot;
CAlgoRenko mAlgo;

int OnInit()
{   
   mAlgo.SetInputParameters(Algo1_Magic, "Discovery");
   CMyAlgo* algoArray[];
   ArrayResize(algoArray, 1);
   algoArray[0] = GetPointer(mAlgo);
   
   int hasStarted = mRobot.Start(Robot_Name, Robot_TimerSeconds, Robot_LicenseKey, algoArray);
   return hasStarted;
}

void OnTimer() 
{  
   mRobot.UpdateTimer();
}

void OnTick()
{    
   mRobot.UpdateTick();
}

void OnDeinit(const int reason)
{
   mRobot.Stop(reason);   
}

void OnTradeTransaction(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
   mAlgo.OnTradeTransactionAlgo(transac, request, result);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
