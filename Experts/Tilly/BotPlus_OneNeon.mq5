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
#property description "BotPlus_OneNeon"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_OneNeon"; // Robot Name
int      Robot_TimerSeconds                     = 0; // Robot Timer Seconds
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

uint     Algo1_Magic                            = 906;         // Magic number
input double   Algo1_CapitalMultiplier                = 0.04;        // Account balance multiplier
input double   Algo1_RiskPercentage                   = 1.0;         // Risk percentage for a trade (0.2 = 0.2%)

input group    "..........................................................................."

input bool     Algo1_EnableScalpTrade                 = true;        // Enable scalp trading
input double   Algo1_StoplossBrickRatio               = 2.0;         // Stoploss Brick ratio
input double   Algo1_TakeprofitBrickRatio             = 0.95;        // Takeprofit Brick ratio (0.95)
bool     Algo1_EnableScalpClose                 = false;       // Enable scalp position closing after a Brick
bool     Algo1_EnableSwingTrade                 = false;       // Enable swing trading

input group    "..........................................................................."

input bool     Algo1_EnableTimeFilter                 = true;        // Enable time filter
input double   Algo1_TimeFilterStart                  = 16.30;       // Time filter start
input double   Algo1_TimeFilterFinish                 = 23.55;       // Time filter finish
bool     Algo1_EnableSmartMM                    = false;       // Enable SmartMM

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

#define MY_COMMENT_SCALP "NEPTUNE"
#define MY_COMMENT_SWING "URANUS"

class CAlgoRenko : public CMyAlgo {

private:
   
   string   m_symbol, m_symbol_custom;
   double   m_risk_percentage, m_stoploss_ratio, m_takeprofit_ratio;
  
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
     
   void CloseCurrentPosition(string _direction, string _reference) {
      string signal = "c=close plus=mt m=" + this.m_symbol + " d=" + _direction;
      if ( StringLen(_reference) > 0 ) {
         signal = signal + " ref=" + _reference;
      }
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
   
   void InitSmartMM() { 
      datetime start_time = TimeCurrent() - (PeriodSeconds(PERIOD_D1) * 7);
      if ( Algo1_EnableSmartMM == false ) return; 
      HistorySelect(start_time, TimeCurrent());
      for( int itr = HistoryDealsTotal()-1; itr >= 0; itr-- ) {
         ulong xdeal_ticket = HistoryDealGetTicket(itr); 
         string xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);        
         long xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);
         ENUM_DEAL_ENTRY xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
         if ( xdeal_symbol == this.m_symbol && xdeal_magic == Algo1_Magic && xdeal_entry == DEAL_ENTRY_OUT ) {
            double deal_profit = HistoryDealGetDouble(xdeal_ticket, DEAL_PROFIT);  
            this.ApplySmartMM(deal_profit);
         }          
      }
      CMyUtil::Info("SmartMM risk_percentage=", (string)m_risk_percentage);
   }
   
   void ApplySmartMM(double _deal_profit) {
      //double new_risk_percentage = this.m_risk_percentage;
      double new_sl_ratio = this.m_stoploss_ratio;
      //double new_tp_ratio = this.m_takeprofit_ratio;
      if ( Algo1_EnableSmartMM ) {
         if ( _deal_profit < 0 ) {
            //new_risk_percentage = new_risk_percentage - Algo1_SmartMMRiskChange;
            new_sl_ratio = Algo1_StoplossBrickRatio + 1;
         } else {
            //new_risk_percentage = new_risk_percentage + Algo1_SmartMMRiskChange;
            new_sl_ratio = Algo1_StoplossBrickRatio;
         }
         
         /*if ( new_risk_percentage <= 0.05 ) {
            new_risk_percentage = 0.05;
         } else if ( new_risk_percentage >= 2*Algo1_RiskPercentage ) {
            new_risk_percentage = Algo1_RiskPercentage;
         }
         this.m_risk_percentage = new_risk_percentage;*/
         this.m_stoploss_ratio = new_sl_ratio;
      }      
   }
   
public:   
  
   int OnStartAlgo() {  
      //--- initialize common configuration
      this.AlgoId = Algo1_Magic; 
      this.CapitalMultiplier = Algo1_CapitalMultiplier;   
      //--- initialize algo specific variables  
      this.SetSymbolName();
      this.SetMaximumSpread();
      int leverage = CMyUtil::LeverageAllowedForSymbol(m_symbol);
      CMyUtil::Info(m_symbol, " leverage=", (string)leverage);  
      this.m_risk_percentage = Algo1_RiskPercentage;
      this.m_stoploss_ratio = Algo1_StoplossBrickRatio;
      this.m_takeprofit_ratio = Algo1_TakeprofitBrickRatio;      
      InitSmartMM();
      this.DisplayInfo = "Algo : " + (string)Algo1_Magic;
      return (INIT_SUCCEEDED);
   }
   
   void OnUpdateAlgo() {       
                 
      datetime bar_time = iTime(m_symbol_custom, 0, 0); 
      static datetime var_last_trade_time = bar_time;
      
      if ( var_last_trade_time < bar_time ) {
         var_last_trade_time = bar_time;
      } else { return; }  
      
      int xcount_long_scalp = 0, xcount_short_scalp = 0, xcount_long_swing = 0, xcount_short_swing = 0;
      double xopen_long_swing = -1 , xopen_short_swing = -1; 
      ulong xtickets_position[];        
      CMyUtil::PositionTickets((string)this.AlgoId, "", this.m_symbol, "", "", xtickets_position);    
      CPositionInfo xpositionInfo;
      for ( int k= 0; k < ArraySize(xtickets_position); k++ ) {
         if ( xpositionInfo.SelectByTicket(xtickets_position[k]) == false ) continue;         
         if ( CMyUtil::GetPositionDirection(xpositionInfo.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
            if ( CMyUtil::ParseComment(xpositionInfo.Comment()) == MY_COMMENT_SWING ) {
               xcount_long_swing++;
               xopen_long_swing = xpositionInfo.PriceOpen();
            } else {
               xcount_long_scalp++;
            }
         } else {
            if ( CMyUtil::ParseComment(xpositionInfo.Comment()) == MY_COMMENT_SWING ) {
               xcount_short_swing++;
               xopen_short_swing = xpositionInfo.PriceOpen();
            } else {
               xcount_short_scalp++;
            }         
         }         
      }
      
      double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1); 
      double brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(close1 - open1));  
      bool time_filter_ok = Algo1_EnableTimeFilter ? CMyUtil::CheckMarketSessionTime(Algo1_TimeFilterStart, Algo1_TimeFilterFinish) : true;    
      double open_price, sl_price, tp_price, spread_ticks;
      string comment;
      MqlTick mql_tick;       
     
      if ( close1 > open1 ) {  
         
         SymbolInfoTick(m_symbol, mql_tick);      
         spread_ticks =  CMyUtil::NormalizePrice(m_symbol, MathAbs(mql_tick.ask-mql_tick.bid)); 
         open_price = mql_tick.ask;
  
         if ( Algo1_EnableScalpTrade ) {
            comment = CreateComment(MY_COMMENT_SCALP, (string)spread_ticks);
            if ( Algo1_EnableScalpClose && xcount_long_scalp >= 1 ) {
               CloseCurrentPosition(DEFINE_TRADE_DIR_LONG, comment);
            }
            sl_price = CMyUtil::NormalizePrice(m_symbol, close1 - (brick_ticks * this.m_stoploss_ratio)) - spread_ticks;  
            tp_price = this.m_takeprofit_ratio > 0 ? CMyUtil::NormalizePrice(m_symbol, open_price + (brick_ticks * this.m_takeprofit_ratio)) : 0;  
            if ( xcount_long_scalp < 1 && time_filter_ok ) {               
               OpenNewPosition(DEFINE_TRADE_DIR_LONG, this.m_risk_percentage, sl_price, tp_price, comment);
            }
         }  

         if ( Algo1_EnableSwingTrade ) { 
            comment = CreateComment(MY_COMMENT_SWING, (string)spread_ticks);
            if ( xcount_short_swing >= 1 && xopen_short_swing > 0 && (xopen_short_swing - mql_tick.ask) > brick_ticks ) {
               CloseCurrentPosition(DEFINE_TRADE_DIR_SHORT, comment);
            }
            if ( xcount_long_swing < 1 && time_filter_ok ) {
               sl_price = CMyUtil::NormalizePrice(m_symbol, close1 - (brick_ticks * 3)) - spread_ticks;  
               OpenNewPosition(DEFINE_TRADE_DIR_LONG, this.m_risk_percentage, sl_price, 0, comment); 
            }
         }           
          
      } 
      else if ( close1 < open1 ) {         
         
         SymbolInfoTick(m_symbol, mql_tick);      
         spread_ticks =  CMyUtil::NormalizePrice(m_symbol, MathAbs(mql_tick.ask-mql_tick.bid)); 
         open_price = mql_tick.bid;

         if ( Algo1_EnableScalpTrade ) { 
            comment = CreateComment(MY_COMMENT_SCALP, (string)spread_ticks);
            if ( Algo1_EnableScalpClose && xcount_short_scalp >= 1 ) {
               CloseCurrentPosition(DEFINE_TRADE_DIR_SHORT, comment);
            }            
            sl_price = CMyUtil::NormalizePrice(m_symbol, close1 + (brick_ticks * this.m_stoploss_ratio)) + spread_ticks;  
            tp_price = this.m_takeprofit_ratio > 0 ? CMyUtil::NormalizePrice(m_symbol, open_price - (brick_ticks * this.m_takeprofit_ratio)) : 0;  
            if ( xcount_short_scalp < 1 && time_filter_ok ) {               
               OpenNewPosition(DEFINE_TRADE_DIR_SHORT, this.m_risk_percentage, sl_price, tp_price, comment);
            }
         } 
         
         if ( Algo1_EnableSwingTrade ) {         
            comment = CreateComment(MY_COMMENT_SWING, (string)spread_ticks);
            if ( xcount_long_swing >= 1 && xopen_long_swing > 0 && (mql_tick.bid - xopen_long_swing) > brick_ticks ) {
               CloseCurrentPosition(DEFINE_TRADE_DIR_LONG, comment);
            }  
            if ( xcount_short_swing < 1 && time_filter_ok ) {     
               sl_price = CMyUtil::NormalizePrice(m_symbol, close1 + (brick_ticks * 3)) + spread_ticks;
               OpenNewPosition(DEFINE_TRADE_DIR_SHORT, this.m_risk_percentage, sl_price, 0, comment);
            }
         } 
                  
      }
      
   }   
      
   void OnStopAlgo() {      
   }

   void OnTradeTransactionAlgo(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {  
                               
      if ( Algo1_EnableSmartMM == false ) return; 
      
      if( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ulong xdeal_ticket = _transaction.deal;        
         if(HistoryDealSelect(xdeal_ticket)) {
            string xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);
            long xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);
            ENUM_DEAL_ENTRY xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
            if ( xdeal_symbol == this.m_symbol && xdeal_magic == Algo1_Magic ) {
               if ( xdeal_entry == DEAL_ENTRY_IN ) {
               } else if ( xdeal_entry == DEAL_ENTRY_OUT ) {
                  double deal_profit = HistoryDealGetDouble(xdeal_ticket, DEAL_PROFIT);   
                  this.ApplySmartMM(deal_profit);
                  CMyUtil::Debug("SmartMM risk_percentage=", (string)m_risk_percentage);
               }          
            }       
         }
      }     

   }                        
      

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyRobot mRobot;
CAlgoRenko mAlgo;

int OnInit()
{   
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
