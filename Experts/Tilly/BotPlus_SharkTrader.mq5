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
#property description "BotPlus_SharkTrader"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Bot_Name                               = "BotPlus_SharkTrader";// Bot Name
string   Bot_LicenseKey                         = "XXXX";               // License Key

input group    "..........................................................................."

enum ERunMode
{
   RUNMODE_FULL            =  1,
   RUNMODE_MODIFY_CLOSE    =  2,
   RUNMODE_ONLY_LONG       =  3,
   RUNMODE_ONLY_SHORT      =  4 
};

enum EStoplossMode
{
   STOPLOSS_BRICK_HL       =  1,
   STOPLOSS_BRICK_OC       =  2,
   STOPLOSS_ATR            =  3,
   STOPLOSS_SWING          =  4
   
};

input string            Algo7_Comment                    = "K";            // Comment
input string            Algo7_MagicPrefix                = "";             // Integer prefix of Magic
input ERunMode          Algo7_RunMode                    = RUNMODE_FULL;   // Run Mode
input double            Algo7_RiskPercentage             = 0.3;            // Use risk percentage (0.2 = 0.2%)
input double            Algo7_FixedLotSize               = 0;              // Use fixed lots
input EStoplossMode     Algo7_StoplossMode               = STOPLOSS_BRICK_OC; // Stoploss Mode
input uint              Algo7_StoplossSwingPeriod        = 5;              // Stoploss swing/atr period
bool              Algo7_EnableEmptyStoploss        = false;          // Set empty stoploss price   
input double            Algo7_StoplossMultiplier         = 8;              // Stoploss multiplier
input double            Algo7_TakeprofitMultiplier       = 0;              // Takeprofit multiplier
bool              Algo7_EnableReverseEntry         = false;          // Enable reverse entry
bool              Algo7_EnableProfitableExit       = false;          // Enable profitable exit
bool              Algo7_EnableEarlyExit            = false;          // Enable early exit before TP
uint              Algo7_MaxTradesPerSide           = 1;              // Max trade count per side
bool              Algo7_EnableBreakEven            = false;          // Enable break even trading
bool              Algo7_EnableSmartRiM             = false;          // Enable Smart risk management
uint              Algo7_TrailingStoplossMultiplier = 0;              // Trailing Stoploss multiplier
uint              Algo7_TrailingBarFrequency       = 2;              // Trailing Bar frequency

input group    "..........................................................................."

enum EAlgo
{
   ALGO_EMACROSS     =  1,
   ALGO_COPPER       =  2,
   ALGO_DOUBLEBT     =  3,
   ALGO_SOLARWIND    =  4,
   ALGO_QQE          =  5,
   ALGO_TRENDSIGNAL  =  6,
   ALGO_LUCASARROW   =  7
};
  
input EAlgo             Algo7_Algo                 = ALGO_LUCASARROW;   // Trading Algorithm
input uint              Algo7_IndiLength           = 8;                 // Algorithm length
input uint              Algo7_IndiSmooth           = 1;                 // Algorithm smooth

//input group    "..........................................................................."

enum ETrendFilter 
{
   TRENDY_DISABLED   = 1,
   TRENDY_SMA        = 2,
   TRENDY_CHAIKIN    = 3,
   TRENDY_SOLARWIND  = 4
};

ETrendFilter      Algo7_TrendFilter                = TRENDY_DISABLED;   // Enable Trend filter
ENUM_TIMEFRAMES   Algo7_TrendFilterTimeFrame       = PERIOD_CURRENT;    // Trend filter time frame
uint              Algo7_TrendFilterLength          = 35;                // Trend filter length
uint              Algo7_TrendFilterSmooth          = 10;                // Trend filter smooth

input group    "..........................................................................."

bool              Algo7_EnableNewsEventFilter      = false;          // Enable news filter
bool              Algo7_EnableTimeFilter           = false;          // Enable time filter
double            Algo7_TimeFilterStart            = 4.00;           // Time filter start
double            Algo7_TimeFilterFinish           = 19.00;          // Time filter finish
input bool              Algo7_EnableDateCheckFilters     = false;          // Enable date checking filters
input bool              Algo7_EnableNFP_ThursdayBefore   = false;          // Enable NFP_ThursdayBefore filter
input bool              Algo7_EnableNFP_Friday           = false;          // Enable NFP_Friday filter
input bool              Algo7_EnableNFP_Session          = false;          // Enable NFP_Session filter
input bool              Algo7_EnableXMAS_Holiday         = false;          // Enable XMAS_Holiday filter
input uint              Algo7_XMAS_DayBeginBreak         = 20;             // XMAS_DayBeginBreak
input bool              Algo7_EnableNewYearHoliday       = false;          // Enable NewYearHoliday filter
input uint              Algo7_NewYear_DayEndBreak        = 10;             // NewYear_DayEndBreak

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

class CMyBotImpl : public CMyBot {

private:
   long     m_botid;
   string   m_symbol, m_symbol_custom;
   double   m_quantity;
   bool     m_ok_new_bar, m_ok_new_m5; 
   bool     m_ok_filter_day, m_ok_filter_time, m_ok_filter_news; 
   int      m_handle_stopatr, m_handle_tfsma, m_handle_tfchaikin, m_handle_tfsolarwind;
   int      m_handle_rt7sma, m_handle_rt7dobt, m_handle_rt7solarwind, m_handle_rt7qqe, m_handle_rt7trendsig, m_handle_rt7lucasaw;
     
   void SetSymbolProperties() { 
      m_symbol_custom = Symbol();
      m_symbol = CMyUtil::CurrentSymbol();      
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      this.MaximumSpreadPointCount = spread_points > 5 ? spread_points*3 : 15;
      int leverage = CMyUtil::LeverageAllowedForSymbol(m_symbol);
      CMyUtil::Info(m_symbol, " leverage=", (string)leverage,  " max_spread=", (string)MaximumSpreadPointCount);      
   }  
   
   void OpenNewPosition(string _direction, double _sl_price, double _tp_price, string _reference) {   
      string quantity = Algo7_FixedLotSize > 0 ? (string)m_quantity : (string)m_quantity + "%";
         
      string signal = "c=open m=" + CMyUtil::XStringReplaceCharSpace(this.m_symbol) + " d=" + _direction + 
            " q=" + quantity + " sl=" + (string)_sl_price + " tp=" + (string)_tp_price + " ref=" + _reference + 
            " magic=" + (string)m_botid + " plus=mt";
      if ( Algo7_RunMode == RUNMODE_MODIFY_CLOSE ) {         
      } else if ( Algo7_RunMode == RUNMODE_ONLY_LONG && _direction == DEFINE_TRADE_DIR_SHORT ) {
      } else if ( Algo7_RunMode == RUNMODE_ONLY_SHORT && _direction == DEFINE_TRADE_DIR_LONG ) {
      } else {
         this.AddSignal(signal);  
      }
   }
   
   void ModifyPosition(long _ticket, string _direction, double _sl_price, double _tp_price) {
      string signal = "c=modify m=" + CMyUtil::XStringReplaceCharSpace(this.m_symbol) + " d=" + _direction + 
            " ticket=" + (string)_ticket + " sl=" + (string)_sl_price + " tp=" + (string)_tp_price + 
            " magic=" + (string)m_botid + " plus=mt";
      this.AddSignal(signal);
   }   
     
   void CloseCurrentPosition(string _direction) {
      string signal = "c=close m=" + CMyUtil::XStringReplaceCharSpace(this.m_symbol) + " d=" + _direction + 
            " magic=" + (string)m_botid + " plus=mt";
      this.AddSignal(signal);  
   } 
   
   void OpenNewOrder(double _open_price, string _direction, double _risk, double _sl_price, double _tp_price, string _reference) {
      string signal = "c=open m=" + CMyUtil::XStringReplaceCharSpace(this.m_symbol) + " d=" + _direction + " q=" + (string)_risk + 
            "% po="+(string)_open_price + " sl=" + (string)_sl_price + " tp=" + (string)_tp_price + " ref=" + _reference + 
            " magic=" + (string)m_botid + " plus=mt";
      if ( Algo7_RunMode == RUNMODE_MODIFY_CLOSE ) {         
      } else if ( Algo7_RunMode == RUNMODE_ONLY_LONG && _direction == DEFINE_TRADE_DIR_SHORT ) {
      } else if ( Algo7_RunMode == RUNMODE_ONLY_SHORT && _direction == DEFINE_TRADE_DIR_LONG ) {
      } else {
         this.AddSignal(signal);  
      }  
   }  
   
   void DeleteCurrentOrders() {
      string signal = "c=delete m=" + CMyUtil::XStringReplaceCharSpace(this.m_symbol) + " magic=" + (string)m_botid + " plus=mt";
      this.AddSignal(signal);   
   }   
   
   double GetStoplossTicks(double atr, string _direction) {
      double brick_ticks;
      if ( Algo7_StoplossMode == STOPLOSS_BRICK_HL ) {
         double high1 = iHigh(m_symbol_custom, 0, 1);
         double low1 = iLow(m_symbol_custom, 0, 1);
         brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(high1 - low1));       
      } 
      else if ( Algo7_StoplossMode == STOPLOSS_BRICK_OC ) {
         double open1 = iOpen(m_symbol_custom, 0, 1);
         double close1 = iClose(m_symbol_custom, 0, 1);
         brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(open1 - close1));       
      }           
      else if ( Algo7_StoplossMode == STOPLOSS_ATR ) {
         brick_ticks = CMyUtil::NormalizePrice(m_symbol, atr);       
      } 
      else {
         int index; double level;
         if ( _direction == DEFINE_TRADE_DIR_LONG ) {
            index = iLowest(m_symbol_custom, 0, MODE_LOW, Algo7_StoplossSwingPeriod, 1);
            level = iLow(m_symbol_custom, 0, index);  
         }else {
            index = iHighest(m_symbol_custom, 0, MODE_HIGH, Algo7_StoplossSwingPeriod, 1);
            level = iHigh(m_symbol_custom, 0, index);            
         }
         double open1 = iOpen(m_symbol_custom, 0, 0);
         brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(open1 - level)); 
      } 
      return brick_ticks;   
   }
   
   double ParseMoneyRisked(string pComment) {
      double value = 0;
      int len = StringLen(pComment);
      int index = StringFind(pComment,"@");
      if (len > 0 && index >= 0) {
         string str = StringSubstr(pComment, index);
         len = StringLen(str);
         index = StringFind(str, "R");
         if (len > 0 && index >= 0) {
            string smoney_risk = StringSubstr(str, index + 1);
            value = StringToDouble(smoney_risk);
         }         
      }
      return value;
   }     
   
   void Strategy7(int bar_number) { 
   
      if ( m_ok_new_m5 ) {
         //--- news, time, date filter
         m_ok_filter_day = Algo7_EnableDateCheckFilters == true ? CMyUtil::CheckTradingDay(true, Algo7_EnableNFP_Friday, Algo7_EnableNFP_Session, 
                                                         Algo7_EnableNFP_ThursdayBefore, Algo7_EnableXMAS_Holiday, Algo7_XMAS_DayBeginBreak, 
                                                         Algo7_EnableNewYearHoliday, Algo7_NewYear_DayEndBreak) : true; 
         m_ok_filter_time = Algo7_EnableTimeFilter == true ? CMyUtil::CheckMarketSession(Algo7_TimeFilterStart, Algo7_TimeFilterFinish) : true; 
         m_ok_filter_news = Algo7_EnableNewsEventFilter == true ? CMyUtil::CheckNewsEvents(m_symbol, 5, 5, CALENDAR_IMPORTANCE_HIGH) : true; 
         
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
         double price_openbar = iOpen(m_symbol_custom, 0, 0);       
         double array_stopatr[];
         if(CMyUtil::XCopyBuffer("iStoplossATR", m_handle_stopatr, 0, 3, true, array_stopatr) == false) return;         
         int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
         
         uint xcount_long = 0, xcount_short = 0; 
         double xprofit_long = 0, xprofit_short = 0, xrisk_long = 0, xrisk_short = 0; 
         bool open_long = false, open_short = false, close_long = false, close_short = false;  
         
         
         ulong curr_tickets[];        
         CMyUtil::PositionTickets((string)m_botid, "", m_symbol, "", "", curr_tickets); 
         CPositionInfo curr_position;
         for ( int k= 0; k < ArraySize(curr_tickets); k++ ) {
            if ( curr_position.SelectByTicket(curr_tickets[k]) == false ) continue;   
            int trailing_bar = (int)MathMod(bar_number, Algo7_TrailingBarFrequency); 
            if ( CMyUtil::GetPositionDirection(curr_position.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
               xcount_long++;   
               xprofit_long = curr_position.Profit();
               if ( Algo7_EnableProfitableExit ) {                     
                  xrisk_long = ParseMoneyRisked(curr_position.Comment());
               }
               if ( Algo7_TrailingStoplossMultiplier > 0 && trailing_bar == 0 ) {  
                  double brick_ticks = GetStoplossTicks(array_stopatr[1], DEFINE_TRADE_DIR_LONG);               
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, price_openbar - (brick_ticks * Algo7_TrailingStoplossMultiplier));
                  if ( sl_price > curr_position.StopLoss() ) {                     
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_LONG, sl_price, curr_position.TakeProfit()); 
                  }  
               }
               if ( Algo7_EnableBreakEven ) {
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, curr_position.PriceOpen()) + CMyUtil::ToPointDecimal(m_symbol, 3 * spread_points);
                  if ( xprofit_long > 1 && sl_price > curr_position.StopLoss() ) {
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_LONG, sl_price, curr_position.TakeProfit());                       
                  }              
               }
                
            } else {
               xcount_short++;   
               xprofit_short = curr_position.Profit(); 
               if ( Algo7_EnableProfitableExit ) {                   
                  xrisk_short = ParseMoneyRisked(curr_position.Comment()); 
               }                               
               if ( Algo7_TrailingStoplossMultiplier > 0 && trailing_bar == 0 ) {
                  double brick_ticks = GetStoplossTicks(array_stopatr[1], DEFINE_TRADE_DIR_SHORT);
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, price_openbar + (brick_ticks * Algo7_TrailingStoplossMultiplier));
                  if ( sl_price < curr_position.StopLoss() ) {                     
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_SHORT, sl_price, curr_position.TakeProfit()); 
                  }  
               }  
               if ( Algo7_EnableBreakEven ) {
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, curr_position.PriceOpen()) - CMyUtil::ToPointDecimal(m_symbol, 3 * spread_points);
                  if ( xprofit_short > 1 && sl_price < curr_position.StopLoss() ) {
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_SHORT, sl_price, curr_position.TakeProfit());                       
                  }              
               }            
                            
            }         
         } 
         
         //--- algorithmic rules         
         if ( Algo7_Algo == ALGO_EMACROSS ) {
            double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1);
            double arr_sma[];
            if(CMyUtil::XCopyBuffer("iMa", m_handle_rt7sma, 0, 3, true, arr_sma) == false) return;   
            open_long = close1 > open1 && price_openbar > arr_sma[0] && arr_sma[0] > arr_sma[1]; 
            open_short = close1 < open1 && price_openbar < arr_sma[0] && arr_sma[0] < arr_sma[1];
            close_short = price_openbar > arr_sma[0] || arr_sma[0] > arr_sma[1]; 
            close_long = price_openbar < arr_sma[0] || arr_sma[0] < arr_sma[1];  
         } 
         else if ( Algo7_Algo == ALGO_COPPER ) {
            double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1);
            double close2 = iClose(m_symbol_custom, 0, 2); double open2 = iOpen(m_symbol_custom, 0, 2);
            open_long = close1 > open1; 
            open_short = close1 < open1;
            close_short = close1 > open1; 
            close_long = close1 < open1;
         } 
         else if ( Algo7_Algo == ALGO_DOUBLEBT ) {            
            double arr_rt7dobt[];            
            if(CMyUtil::XCopyBuffer("iDoubleBT", m_handle_rt7dobt, 4, 3, true, arr_rt7dobt) == false) return; 
            open_long = arr_rt7dobt[0] > 0; 
            open_short = arr_rt7dobt[0] < 0; 
            close_long = xcount_long > 0 && xprofit_long > 0;
            close_short = xcount_short > 0 && xprofit_short > 0;
         }  
         else if ( Algo7_Algo == ALGO_SOLARWIND ) {
            double arr_rt7solarwind[];
            //if(CMyUtil::XCopyBuffer("iSolarWindJoy", m_handle_rt7solarwind, 5, 3, true, arr_rt7solarwind) == false) return;  
            if(CMyUtil::XCopyBuffer("iSolarWindJoy", m_handle_rt7solarwind, 0, 3, true, arr_rt7solarwind) == false) return;      
            open_long = arr_rt7solarwind[1] > 0 && arr_rt7solarwind[2] < 0;
            open_short = arr_rt7solarwind[1] < 0 && arr_rt7solarwind[2] > 0;
            close_long = open_short;
            close_short = open_long;
            CMyUtil::Info("ALGO_SOLARWIND buffer[1]", (string)arr_rt7solarwind[1], " buffer[2]", (string)arr_rt7solarwind[2]);
         }  
         else if ( Algo7_Algo == ALGO_QQE ) {
            double arr_rt7qqe_buy[], arr_rt7qqe_sell[];
            if(CMyUtil::XCopyBuffer("iQQE", m_handle_rt7qqe, 2, 3, true, arr_rt7qqe_buy) == false) return;   
            if(CMyUtil::XCopyBuffer("iQQE", m_handle_rt7qqe, 3, 3, true, arr_rt7qqe_sell) == false) return;       
            open_long = arr_rt7qqe_buy[1] != EMPTY_VALUE && arr_rt7qqe_sell[1] == EMPTY_VALUE;
            open_short = arr_rt7qqe_buy[1] == EMPTY_VALUE && arr_rt7qqe_sell[1] != EMPTY_VALUE;
            close_long = open_short;
            close_short = open_long;
         }      
         else if ( Algo7_Algo == ALGO_TRENDSIGNAL ) {
            double arr_rt7trendsig[];
            if(CMyUtil::XCopyBuffer("iTrendSignal", m_handle_rt7trendsig, 2, 3, true, arr_rt7trendsig) == false) return;       
            open_long = arr_rt7trendsig[1] > 0 && arr_rt7trendsig[2] < 0;
            open_short = arr_rt7trendsig[1] < 0 && arr_rt7trendsig[2] > 0;
            close_long = open_short;
            close_short = open_long;         
         }
         else if ( Algo7_Algo == ALGO_LUCASARROW ) {
            double arr_rt7lucasaw[];
            if(CMyUtil::XCopyBuffer("iLucasArrow", m_handle_rt7lucasaw, 4, 3, true, arr_rt7lucasaw) == false) return;       
            open_long = arr_rt7lucasaw[1] > 0.5 && arr_rt7lucasaw[2] < 0.5;
            open_short = arr_rt7lucasaw[1] < 0.5 && arr_rt7lucasaw[2] > 0.5;
            close_long = open_short;
            close_short = open_long;         
         }            
           
         //--- trend filter
         bool ok_trend_long = true, ok_trend_short = true;
         if ( Algo7_TrendFilter == TRENDY_SMA ) {
            ENUM_TIMEFRAMES xttf = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)0 : Algo7_TrendFilterTimeFrame;
            string xtsymbol = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? m_symbol_custom : m_symbol;
            double open_curr = iOpen(xtsymbol, xttf, 0);
            double arr_tfsma[];
            if(CMyUtil::XCopyBuffer("iTrendFilterMA", m_handle_tfsma, 0, 3, true, arr_tfsma) == false) return;       
            ok_trend_long = open_curr > arr_tfsma[0] && arr_tfsma[0] > arr_tfsma[1]; 
            ok_trend_short = open_curr < arr_tfsma[0] && arr_tfsma[0] < arr_tfsma[1];  
         }  
         else if ( Algo7_TrendFilter == TRENDY_CHAIKIN ) {
            double arr_tfchaikin[];
            if(CMyUtil::XCopyBuffer("iTrendFilterChaikin", m_handle_tfchaikin, 0, 3, true, arr_tfchaikin) == false) return;       
            ok_trend_long = arr_tfchaikin[1] > 0;
            ok_trend_short = arr_tfchaikin[1] < 0;
         }  
         else if ( Algo7_TrendFilter == TRENDY_SOLARWIND ) {
            double arr_tfsolarwind[];
            
            if(CMyUtil::XCopyBuffer("iTrendFilterSolarWindJoy", m_handle_tfsolarwind, 0, 3, true, arr_tfsolarwind) == false) return;       
            ok_trend_long = arr_tfsolarwind[0] > 0;
            ok_trend_short = arr_tfsolarwind[0] < 0;           
         }
         
         //--- reverse                 
         if ( Algo7_EnableReverseEntry ) {
            if ( open_long ) { 
               open_long = false; open_short = true; close_long = true; close_short = false;
            }
            else if ( open_short ) { 
               open_long = true; open_short = false; close_long = false; close_short = true;
            }
         }                                                                   
              
         //--- close rules
         close_long = (Algo7_TakeprofitMultiplier > 0) ? (Algo7_EnableEarlyExit ? close_long : false) : 
                        (Algo7_EnableProfitableExit ? xprofit_long > xrisk_long && close_long : close_long); 
         close_short = (Algo7_TakeprofitMultiplier > 0) ? (Algo7_EnableEarlyExit ? close_short : false) : 
                        (Algo7_EnableProfitableExit ? xprofit_short > xrisk_short && close_short : close_short);  
         if ( close_long ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_LONG);
         }            
         if ( close_short ) {
            CloseCurrentPosition(DEFINE_TRADE_DIR_SHORT);
         }  
         
         //--- open rules    
         open_long = open_long && m_ok_filter_day && m_ok_filter_time && m_ok_filter_news && (xcount_long < Algo7_MaxTradesPerSide) && ok_trend_long;
         open_short = open_short && m_ok_filter_day && m_ok_filter_time && m_ok_filter_news && (xcount_short < Algo7_MaxTradesPerSide) && ok_trend_short; 
         if ( open_long ) {          
            string xcomment = CMyUtil::XStringReplaceCharSpace(this.DisplayInfo);
            double brick_ticks = GetStoplossTicks(array_stopatr[1], DEFINE_TRADE_DIR_LONG);
            double sl_price = CMyUtil::NormalizePrice(m_symbol, price_openbar - (brick_ticks * Algo7_StoplossMultiplier));
            double tp_price = Algo7_TakeprofitMultiplier > 0 ? CMyUtil::NormalizePrice(m_symbol, price_openbar + (brick_ticks * Algo7_TakeprofitMultiplier)) : 0;  
               
            OpenNewPosition(DEFINE_TRADE_DIR_LONG, sl_price, tp_price, xcomment);             
         } 
         if ( open_short ) {                 
            string xcomment = CMyUtil::XStringReplaceCharSpace(this.DisplayInfo);   
            double brick_ticks = GetStoplossTicks(array_stopatr[1], DEFINE_TRADE_DIR_SHORT);
            double sl_price = CMyUtil::NormalizePrice(m_symbol, price_openbar + (brick_ticks * Algo7_StoplossMultiplier));
            double tp_price = Algo7_TakeprofitMultiplier > 0 ? CMyUtil::NormalizePrice(m_symbol, price_openbar - (brick_ticks * Algo7_TakeprofitMultiplier)) : 0;  
               
            OpenNewPosition(DEFINE_TRADE_DIR_SHORT, sl_price, tp_price, xcomment);           
         }   
            
      }      
                       
   } 
  
public:
  
   int Start() {  
      //--- initialize common configuration
      this.TimerMilliSeconds = 320;
      this.EnableEmptyStoploss = Algo7_EnableEmptyStoploss;
      string strbotid = Algo7_MagicPrefix + IntegerToString(Algo7_Algo) + IntegerToString(CMyUtil::PeriodToMinutes(Period()));
      m_botid = (int)strbotid;
      this.DisplayInfo = Algo7_Comment + (string)m_botid;
      SetSymbolProperties(); 
      //--- initialize algo specific variables 
      m_quantity = Algo7_FixedLotSize > 0 ? Algo7_FixedLotSize : Algo7_RiskPercentage;      
      m_ok_new_bar = false; m_ok_new_m5 = false; 
      
      if((m_handle_stopatr = iATR(m_symbol_custom, 0, Algo7_StoplossSwingPeriod)) == INVALID_HANDLE ) return(INIT_FAILED);  

      ENUM_TIMEFRAMES tiftrendf = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)0 : Algo7_TrendFilterTimeFrame;
      string symbtrendf = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? m_symbol_custom : m_symbol;  
            
      CMyUtil::Info("Trend filter=", EnumToString(Algo7_TrendFilter), " timeframe=", EnumToString(tiftrendf), " symbol=", symbtrendf);  
      if( Algo7_TrendFilter == TRENDY_SMA ) {
         if((m_handle_tfsma = iMA(symbtrendf, tiftrendf, Algo7_TrendFilterLength, 1, MODE_SMA, PRICE_OPEN)) == INVALID_HANDLE ) return(INIT_FAILED);
      } 
      else if( Algo7_TrendFilter == TRENDY_CHAIKIN ) {
         if((m_handle_tfchaikin = iChaikin(symbtrendf, tiftrendf, 3, 10, MODE_EMA, VOLUME_TICK)) == INVALID_HANDLE ) return(INIT_FAILED);    
      }
      else if( Algo7_TrendFilter == TRENDY_SOLARWIND ) {
         if((m_handle_tfsolarwind = iCustom(symbtrendf, tiftrendf, "Tilly/rt7_solar_wind", Algo7_TrendFilterLength, Algo7_TrendFilterSmooth)) == INVALID_HANDLE ) return(INIT_FAILED);
      }             
                        
      CMyUtil::Info("Trading algorithm=", EnumToString(Algo7_Algo), " magic=", (string)m_botid, " symbol=", m_symbol_custom);
      if ( Algo7_Algo == ALGO_EMACROSS ) { 
         if((m_handle_rt7sma = iMA(m_symbol_custom, 0, Algo7_IndiLength, 1, MODE_EMA, PRICE_OPEN)) == INVALID_HANDLE ) return(INIT_FAILED);            
      } 
      else if ( Algo7_Algo == ALGO_DOUBLEBT ) { 
         if((m_handle_rt7dobt = iCustom(m_symbol_custom, 0, "Tilly/rt7_double_bt")) == INVALID_HANDLE ) return(INIT_FAILED);                       
      }  
      else if( Algo7_Algo == ALGO_SOLARWIND ) {
         if((m_handle_rt7solarwind = iCustom(m_symbol_custom, 0, "Tilly/rt7_solar_wind", Algo7_IndiLength, Algo7_IndiSmooth)) == INVALID_HANDLE ) return(INIT_FAILED);
      } 
      else if( Algo7_Algo == ALGO_QQE ) {
         if((m_handle_rt7qqe = iCustom(m_symbol_custom, 0, "Tilly/rt7_qqe_arrow", Algo7_IndiLength, Algo7_IndiSmooth)) == INVALID_HANDLE ) return(INIT_FAILED);
      }     
      else if( Algo7_Algo == ALGO_TRENDSIGNAL ) {
         if((m_handle_rt7trendsig = iCustom(m_symbol_custom, 0, "Tilly/rt7_trend_signal", Algo7_IndiLength, Algo7_IndiSmooth)) == INVALID_HANDLE ) return(INIT_FAILED);
      }
      else if( Algo7_Algo == ALGO_LUCASARROW ) {
         if((m_handle_rt7lucasaw = iCustom(m_symbol_custom, 0, "Tilly/rt7_lucas_arrow", Algo7_IndiLength, Algo7_IndiSmooth)) == INVALID_HANDLE ) return(INIT_FAILED);
      }                             
      
      return (INIT_SUCCEEDED);
   }
   
   void Update() {    
      int bar_number = iBars(m_symbol_custom, 0);
      static int var_last_bar_number = bar_number;
      if ( bar_number > var_last_bar_number ) {
         var_last_bar_number = bar_number;
         m_ok_new_bar = true;   
         //Print(m_symbol_custom, " new bar generated, bar_number=", bar_number);                
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
      
      Strategy7(bar_number);
      
   }   
      
   void Stop() { 
      IndicatorRelease(m_handle_stopatr); IndicatorRelease(m_handle_tfsma); 
      IndicatorRelease(m_handle_tfchaikin); IndicatorRelease(m_handle_tfsolarwind);      
      IndicatorRelease(m_handle_rt7sma); IndicatorRelease(m_handle_rt7dobt); IndicatorRelease(m_handle_rt7solarwind); 
      IndicatorRelease(m_handle_rt7qqe); IndicatorRelease(m_handle_rt7trendsig); IndicatorRelease(m_handle_rt7lucasaw);  
   }

   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) { 
      if( Algo7_EnableSmartRiM == false ) { return; }
      
      if( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ulong xdeal_ticket = _transaction.deal;        
         if(HistoryDealSelect(xdeal_ticket)) {
            string xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);
            long xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);            
            ENUM_DEAL_ENTRY xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
            if ( xdeal_symbol == this.m_symbol && xdeal_magic == m_botid ) {               
               if ( xdeal_entry == DEAL_ENTRY_IN ) {             
               } else if ( xdeal_entry == DEAL_ENTRY_OUT ) {               
                  double deal_profit = HistoryDealGetDouble(xdeal_ticket, DEAL_PROFIT);   
                  if ( Algo7_EnableSmartRiM ) {
                     if ( deal_profit < 0 ) { 
                        m_quantity = Algo7_FixedLotSize > 0 ? Algo7_FixedLotSize * 2: Algo7_RiskPercentage * 2;  
                     } else {    
                        m_quantity = Algo7_FixedLotSize > 0 ? Algo7_FixedLotSize : Algo7_RiskPercentage;       
                     }
                     CMyUtil::Info("SmartRiM is applied, now risk=", (string)m_quantity);
                  }                   
               }          
            }       
         }
      } 
         
   }                        
      

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyBotImpl robot;

int OnInit()
{ 
   return robot.OnInitHandler(Bot_Name, Bot_LicenseKey);
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
