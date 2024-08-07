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

string   Robot_Name                             = "BotPlus_Discovery";  // Robot Name
string   Robot_LicenseKey                       = "XXXX";               // License Key

input group    "..........................................................................."

enum ERunMode
{
   RUNMODE_FULL            =  0,
   RUNMODE_MODIFY_CLOSE    =  1,
   RUNMODE_ONLY_LONG       =  2,
   RUNMODE_ONLY_SHORT      =  3 
};

input ERunMode Algo1_RunMode                          = RUNMODE_FULL;   // Run Mode
input double   Algo1_RiskPercentage                   = 0.1;            // Risk percentage for a trade (0.2 = 0.2%)
input string   Algo1_Comment                          = "Discovery";    // Comment
input double   Algo1_StoplossBrickRatio               = 7;              // Stoploss Brick ratio
input double   Algo1_TakeprofitBrickRatio             = 0;              // Takeprofit Brick ratio
bool     Algo1_EnableSmartMoM                    = false;           // Enable Smart Money Management
input bool     Algo1_EnableSmartTrM                   = true;           // Enable Smart Trade Management
input bool     Algo1_EnableSimultaneousLongShort      = true;           // Enable Simultaneous Long/Short

input group    "..........................................................................."

enum EAlgo
{
   ALGO_DEMABAND     =  707,
   ALGO_EMACROSS     =  717     
};
  
input EAlgo    Algo1_Algo                             = ALGO_EMACROSS;  // Trading Algorithm
input int      Algo1_IndiParam1                       = 9;              // Indicator Length
int      Algo1_IndiParam2                       = 0;              // Indicator Shift
bool     Algo1_IndiEntryConfirmTwobars          = true;           // Indicator 2 bars confirmation on entry
bool     Algo1_IndiExitConfirmTwobars           = false;          // Indicator 2 bars confirmation on exit

input group    "..........................................................................."

input bool     Algo1_EnableTimeFilter                 = false;          // Enable time filter
input double   Algo1_TimeFilterStart                  = 2.00;           // Time filter start
input double   Algo1_TimeFilterFinish                 = 22.00;          // Time filter finish
input bool     Algo1_EnableNewsEventFilter            = false;          // Enable news event filter
bool     Algo1_EnableDateFilter                 = true;        // Enable date filter
bool     Algo1_EnableNFP_ThursdayBefore         = false;       // Enable NFP_ThursdayBefore filter
bool     Algo1_EnableNFP_Friday                 = false;       // Enable NFP_Friday filter
bool     Algo1_EnableNFP_Session                = true;        // Enable NFP_Session filter
bool     Algo1_EnableXMAS_Holiday               = false;       // Enable XMAS_Holiday filter
int      Algo1_XMAS_DayBeginBreak               = 20;          // XMAS_DayBeginBreak
bool     Algo1_EnableNewYearHoliday             = false;       // Enable NewYearHoliday filter
int      Algo1_NewYear_DayEndBreak              = 10;          // NewYear_DayEndBreak

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

class CMyRobotImpl : public CMyRobot {

private:
   
   string   m_symbol, m_symbol_custom;
   double   m_stoploss_brick_ratio;
   bool     m_ok_new_bar, m_ok_new_m5; 
   bool     m_ok_filter_day, m_ok_filter_time, m_ok_filter_news; 
   int      m_handle_dema, m_handle_bband, m_handle_sma;
     
   void SetSymbolProperties() { 
      m_symbol_custom = Symbol();
      m_symbol = CMyUtil::CurrentSymbol();      
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      MaximumSpreadPointCount = spread_points > 2 ? spread_points*5 : 10;
      int leverage = CMyUtil::LeverageAllowedForSymbol(m_symbol);
      CMyUtil::Info(m_symbol, " leverage=", (string)leverage,  " max_spread=", (string)MaximumSpreadPointCount);      
   }  
   
   void OpenNewPosition(string _direction, double _risk, double _sl_price, double _tp_price, string _reference) {
      string signal = "c=open m=" + this.m_symbol + " d=" + _direction + " q=" + (string)_risk + 
                     "% sl=" + (string)_sl_price + " tp=" + (string)_tp_price + " ref=" + _reference + " plus=mt";
      if ( Algo1_RunMode == RUNMODE_MODIFY_CLOSE ) {         
      } else if ( Algo1_RunMode == RUNMODE_ONLY_LONG && _direction == DEFINE_TRADE_DIR_SHORT ) {
      } else if ( Algo1_RunMode == RUNMODE_ONLY_SHORT && _direction == DEFINE_TRADE_DIR_LONG ) {
      } else {
         this.AddSignal(signal);  
      }
   }
   
   void ModifyPosition(long _ticket, string _direction, double _sl_price) {
      string signal = "c=modify m=" + this.m_symbol + " d=" + _direction + " ticket=" + (string)_ticket + 
                     " sl=" + (string)_sl_price + " plus=mt";
      this.AddSignal(signal);
   }   
     
   void CloseCurrentPosition(string _direction) {
      string signal = "c=close m=" + this.m_symbol + " d=" + _direction + " plus=mt";
      this.AddSignal(signal);   
   } 
   
   void OpenNewOrder(double _open_price, string _direction, double _risk, double _sl_price, double _tp_price, string _reference) {
      string signal = "c=open m=" + this.m_symbol + " d=" + _direction + " q=" + (string)_risk + 
                     "% po="+(string)_open_price + " sl=" + (string)_sl_price + " tp=" + (string)_tp_price + " ref=" + _reference + " plus=mt";
      if ( Algo1_RunMode == RUNMODE_MODIFY_CLOSE ) {         
      } else if ( Algo1_RunMode == RUNMODE_ONLY_LONG && _direction == DEFINE_TRADE_DIR_SHORT ) {
      } else if ( Algo1_RunMode == RUNMODE_ONLY_SHORT && _direction == DEFINE_TRADE_DIR_LONG ) {
      } else {
         this.AddSignal(signal);  
      }  
   }  
   
   void DeleteCurrentOrders() {
      string signal = "c=delete m=" + this.m_symbol + " plus=mt";
      this.AddSignal(signal);   
   }     
   
   string CreateComment(string _extra) {            
      string extra_comment = StringLen(_extra) > 0 ? "@" + _extra : "";
      return this.DisplayInfo + extra_comment;    
   } 
   
   void Strategy2() { 
   
      if ( m_ok_new_m5 ) {
         m_ok_filter_day = Algo1_EnableDateFilter == true ? CMyUtil::CheckTradingDay(true, Algo1_EnableNFP_Friday, Algo1_EnableNFP_Session, 
                                                         Algo1_EnableNFP_ThursdayBefore, Algo1_EnableXMAS_Holiday, Algo1_XMAS_DayBeginBreak, 
                                                         Algo1_EnableNewYearHoliday, Algo1_NewYear_DayEndBreak) : true; 
         m_ok_filter_time = Algo1_EnableTimeFilter == true ? CMyUtil::CheckMarketSession(Algo1_TimeFilterStart, Algo1_TimeFilterFinish) : true; 
         m_ok_filter_news = Algo1_EnableNewsEventFilter == true ? CMyUtil::CheckNewsEvents(m_symbol, 5, 5, CALENDAR_IMPORTANCE_HIGH) : true; 
         
         bool signal_close_long = m_ok_filter_news == false; 
         bool signal_close_short = m_ok_filter_news == false; 
         if ( signal_close_long ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_LONG);
         }            
         if ( signal_close_short ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_SHORT);
         }                        
      }    

      if ( m_ok_new_bar ) {
         double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1); 
         double brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(close1 - open1));  
         
         int xcount_long = 0, xcount_short = 0; 
         double xprofit_long = 1, xprofit_short = 1;     
         ulong xtickets_position[];        
         CMyUtil::PositionTickets((string)this.RobotId, "", this.m_symbol, "", "", xtickets_position); 
         CPositionInfo xposition_info;
         for ( int k= 0; k < ArraySize(xtickets_position); k++ ) {
            if ( xposition_info.SelectByTicket(xtickets_position[k]) == false ) continue;         
            if ( CMyUtil::GetPositionDirection(xposition_info.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
               xcount_long++;
               xprofit_long = xposition_info.Profit();  
            } else {
               xcount_short++;     
               xprofit_short = xposition_info.Profit();   
            }         
         } 
         
         bool open_long = false, open_short = false, close_long = false, close_short = false;  
         if ( Algo1_Algo == ALGO_DEMABAND ) {
            double arr_dema[], arr_bbhigh[], arr_bblow[];
            if(CMyUtil::XCopyBuffer(m_handle_dema, 0, 4, true, arr_dema) == false) return;    
            if(CMyUtil::XCopyBuffer(m_handle_bband, 1, 3, true, arr_bbhigh) == false) return;      
            if(CMyUtil::XCopyBuffer(m_handle_bband, 2, 3, true, arr_bblow) == false) return;   
            open_long = close1 > arr_bblow[1] && open1 < arr_bblow[1] && arr_dema[0] > arr_dema[1] && arr_dema[1] > arr_dema[2];
            open_short = close1 < arr_bbhigh[1] && open1 > arr_bbhigh[1] && arr_dema[0] < arr_dema[1] && arr_dema[1] < arr_dema[2]; 
            close_long = close1 < arr_bbhigh[1] && open1 > arr_bbhigh[1]; 
            close_short = close1 > arr_bblow[1] && open1 < arr_bblow[1];                      
         }         
         else if ( Algo1_Algo == ALGO_EMACROSS ) {
            double close2 = iClose(m_symbol_custom, 0, 2); double open2 = iOpen(m_symbol_custom, 0, 2); 
            double arr_sma[];
            if(CMyUtil::XCopyBuffer(m_handle_sma, 0, 4, true, arr_sma) == false) return;   
            if ( Algo1_IndiEntryConfirmTwobars ) {
               open_long = close1 > open1 && close2 > open2 && close1 > arr_sma[1] && close2 > arr_sma[2]; 
               open_short = close1 < open1 && close2 < open2 && close1 < arr_sma[1] && close2 < arr_sma[2];            
            } else {
               open_long = close1 > open1 && close1 > arr_sma[1]; 
               open_short = close1 < open1 && close1 < arr_sma[1];            
            }
            
            if ( Algo1_IndiExitConfirmTwobars ) {
               close_short = close1 > open1 && close2 > open2 && close1 > arr_sma[1] && close2 > arr_sma[2]; 
               close_long = close1 < open1 && close2 < open2 && close1 < arr_sma[1] && close2 < arr_sma[2];             
            } else {
               close_short = close1 > open1 && close1 > arr_sma[1]; 
               close_long = close1 < open1 && close1 < arr_sma[1];            
            }            
                     
         }                          
              
         //--- close rules
         close_long = (Algo1_TakeprofitBrickRatio > 0) ? false : (Algo1_EnableSmartTrM && xprofit_long < 1) ? false : close_long; 
         close_short = (Algo1_TakeprofitBrickRatio > 0) ? false : (Algo1_EnableSmartTrM && xprofit_short < 1) ? false : close_short;          
         if ( close_long ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_LONG);
         }            
         if ( close_short ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_SHORT);
         }
                       
         //--- open rules
         bool ok_countlong = Algo1_EnableSimultaneousLongShort ? xcount_long < 1 : (xcount_long + xcount_short) < 1;  
         bool ok_countshort = Algo1_EnableSimultaneousLongShort ? xcount_short < 1 : (xcount_long + xcount_short) < 1;                   
         open_long = open_long && m_ok_filter_day && m_ok_filter_time && m_ok_filter_news && ok_countlong;
         open_short = open_short && m_ok_filter_day && m_ok_filter_time && m_ok_filter_news && ok_countshort; 
         string comment;
         double open_price, sl_price, tp_price, spread_ticks;
         MqlTick mql_tick;          
         if ( open_long ) {          
            SymbolInfoTick(m_symbol, mql_tick);      
            spread_ticks =  CMyUtil::NormalizePrice(m_symbol, MathAbs(mql_tick.ask-mql_tick.bid)); 
            open_price = close1; // mql_tick.ask;
            comment = this.CreateComment((string)CMyUtil::ToPointsCount(m_symbol, spread_ticks));
            sl_price = CMyUtil::NormalizePrice(m_symbol, open_price - (brick_ticks * m_stoploss_brick_ratio));
            tp_price = Algo1_TakeprofitBrickRatio > 0 ? CMyUtil::NormalizePrice(m_symbol, open_price + (brick_ticks * Algo1_TakeprofitBrickRatio)) : 0;  
               
            OpenNewPosition(DEFINE_TRADE_DIR_LONG, Algo1_RiskPercentage, sl_price, tp_price, comment);             
         } 
         if ( open_short ) {                 
            SymbolInfoTick(m_symbol, mql_tick);      
            spread_ticks =  CMyUtil::NormalizePrice(m_symbol, MathAbs(mql_tick.ask-mql_tick.bid));
            open_price = close1; // mql_tick.bid;
            comment = this.CreateComment((string)CMyUtil::ToPointsCount(m_symbol, spread_ticks));   
            sl_price = CMyUtil::NormalizePrice(m_symbol, open_price + (brick_ticks * m_stoploss_brick_ratio));
            tp_price = Algo1_TakeprofitBrickRatio > 0 ? CMyUtil::NormalizePrice(m_symbol, open_price - (brick_ticks * Algo1_TakeprofitBrickRatio)) : 0;  
               
            OpenNewPosition(DEFINE_TRADE_DIR_SHORT, Algo1_RiskPercentage, sl_price, tp_price, comment);           
         }   
            
      }      
                       
   } 
  
public:
  
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_Algo; 
      this.TimerSeconds = 0;
      SetSymbolProperties(); 
      //--- initialize algo specific variables 
      m_stoploss_brick_ratio = Algo1_StoplossBrickRatio;      
      m_ok_new_bar = false; m_ok_new_m5 = false; 
      if ( Algo1_Algo == ALGO_DEMABAND ) { 
         if((m_handle_dema = iDEMA(m_symbol_custom, 0, Algo1_IndiParam1, Algo1_IndiParam2, PRICE_CLOSE)) == INVALID_HANDLE ) return(INIT_FAILED);    
         if((m_handle_bband = iBands(m_symbol_custom, 0, Algo1_IndiParam1, Algo1_IndiParam2, 0.1, PRICE_CLOSE)) == INVALID_HANDLE ) return(INIT_FAILED);
      }      
      else if ( Algo1_Algo == ALGO_EMACROSS ) { 
         if((m_handle_sma = iMA(m_symbol_custom, 0, Algo1_IndiParam1, Algo1_IndiParam2, MODE_SMA, PRICE_CLOSE)) == INVALID_HANDLE ) return(INIT_FAILED);            
      }        
                        
      this.DisplayInfo = Algo1_Comment + (string)this.RobotId + ":" + EnumToString(Algo1_Algo);
      return (INIT_SUCCEEDED);
   }
   
   void Update() {    
      datetime newbar_time = iTime(m_symbol_custom, 0, 0); 
      static datetime var_last_newbar_time = newbar_time;
      if ( newbar_time > var_last_newbar_time ) {
         var_last_newbar_time = newbar_time;
         m_ok_new_bar = true;                  
      } else { 
         m_ok_new_bar = false; 
      }   
      
      datetime m5_time = iTime(m_symbol, PERIOD_M5, 0); 
      static datetime var_last_m5_time = m5_time;   
      if ( m5_time > var_last_m5_time ) {
         var_last_m5_time = m5_time;
         m_ok_new_m5 = true;   
      } else {
         m_ok_new_m5 = false;
      }
      
      Strategy2();
      
   }   
      
   void Stop() { 
      IndicatorRelease(m_handle_dema); IndicatorRelease(m_handle_bband);
      IndicatorRelease(m_handle_sma);     
   }

   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) { 
      if( Algo1_EnableSmartMoM == false ) { return; }
      
      if( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ulong xdeal_ticket = _transaction.deal;        
         if(HistoryDealSelect(xdeal_ticket)) {
            string xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);
            long xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);            
            ENUM_DEAL_ENTRY xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
            if ( xdeal_symbol == this.m_symbol && xdeal_magic == this.RobotId ) {               
               if ( xdeal_entry == DEAL_ENTRY_IN ) {             
               } else if ( xdeal_entry == DEAL_ENTRY_OUT ) {               
                  double deal_profit = HistoryDealGetDouble(xdeal_ticket, DEAL_PROFIT);   
                  if ( Algo1_EnableSmartMoM ) {
                     if ( deal_profit < 0 ) { 
                        m_stoploss_brick_ratio = Algo1_StoplossBrickRatio + 2; 
                     } else {    
                        m_stoploss_brick_ratio = Algo1_StoplossBrickRatio; 
                     }
                     CMyUtil::Info("smart_mom changed the stoploss_brick_ratio=", (string)m_stoploss_brick_ratio);
                  }                   
               }          
            }       
         }
      } 
         
   }                        
      

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyRobotImpl robot;

int OnInit()
{ 
   return robot.OnInitHandler(Robot_Name, Robot_LicenseKey);
}

void OnTimer() 
{  
   robot.OnTimerHandler();
}

void OnTick()
{    
   robot.OnTickHandler();
}

void OnDeinit(const int _reason)
{
   robot.OnDeinitHandler(_reason);   
}

void OnTradeTransaction(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) { 
   robot.OnTradeTransactionHandler(_transaction, _request, _result);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
