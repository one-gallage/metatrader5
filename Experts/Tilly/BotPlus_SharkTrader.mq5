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
   STOPLOSS_BRICK          =  1,
   STOPLOSS_ATR            =  2,
   STOPLOSS_SWING          =  3
   
};

input string            Algo7_Comment                    = "H1T";          // Comment
input ERunMode          Algo7_RunMode                    = RUNMODE_FULL;   // Run Mode
input double            Algo7_RiskPercentage             = 0.1;            // Use risk percentage (0.2 = 0.2%)
double                  Algo7_FixedLotSize               = 0;              // Use fixed lots
input EStoplossMode     Algo7_StoplossMode               = STOPLOSS_BRICK; // Stoploss Mode
input uint              Algo7_StoplossCalcPeriod         = 5;              // Stoploss calculation period
input double            Algo7_StoplossMultiplier         = 1;              // Stoploss multiplier
input double            Algo7_TakeprofitMultiplier       = 0;              // Takeprofit multiplier
bool              Algo7_EnableReverseEntry         = false;          // Enable reverse entry
bool              Algo7_EnableProfitableExit       = false;          // Enable profitable exit
bool              Algo7_EnableEarlyExit            = false;          // Enable early exit
input uint              Algo7_MaxTradesPerSide           = 1;              // Max trade count per side
bool              Algo7_EnableSmartRiM             = false;          // Enable Smart risk management
uint              Algo7_TrailingStoplossMultiplier = 0;              // Trailing Stoploss multiplier
uint              Algo7_TrailingBarFrequency       = 2;              // Trailing Bar frequency

input group    "..........................................................................."

enum EAlgo
{
   ALGO_MARVEL       =  1,
   ALGO_EMACROSS     =  2,
   ALGO_COPPER       =  3,
   ALGO_KOKODA       =  4
};
  
input EAlgo             Algo7_Algo                       = ALGO_KOKODA;    // Trading Algorithm
uint              Algo7_IndiParam1                 = 7;              // Indicator length
ENUM_TIMEFRAMES   Algo7_IndiHigherTimeFrame        = PERIOD_CURRENT;     // Higher time frame to analyse

input group    "..........................................................................."

enum ETrendFilter 
{
   TRENDY_DISABLED   = 1,
   TRENDY_TRIX       = 2,
   TRENDY_SMA        = 3,
   TRENDY_CHAIKIN    = 4
};

input ETrendFilter      Algo7_TrendFilter                = TRENDY_DISABLED;   // Enable Trend filter
input ENUM_TIMEFRAMES   Algo7_TrendFilterTimeFrame       = PERIOD_CURRENT;    // Trend filter time frame
input uint              Algo7_TrendFilterLength          = 10;                // Trend filter length

input group    "..........................................................................."

input bool              Algo7_EnableNewsEventFilter      = false;          // Enable news filter
input bool              Algo7_EnableTimeFilter           = false;          // Enable time filter
input double            Algo7_TimeFilterStart            = 4.00;           // Time filter start
input double            Algo7_TimeFilterFinish           = 19.00;          // Time filter finish
input bool              Algo7_EnableDateFilter           = true;           // Enable date filter
input bool              Algo7_EnableNFP_ThursdayBefore   = false;          // Enable NFP_ThursdayBefore filter
input bool              Algo7_EnableNFP_Friday           = false;          // Enable NFP_Friday filter
input bool              Algo7_EnableNFP_Session          = false;          // Enable NFP_Session filter
bool              Algo7_EnableXMAS_Holiday         = false;       // Enable XMAS_Holiday filter
uint              Algo7_XMAS_DayBeginBreak         = 20;          // XMAS_DayBeginBreak
bool              Algo7_EnableNewYearHoliday       = false;       // Enable NewYearHoliday filter
uint              Algo7_NewYear_DayEndBreak        = 10;          // NewYear_DayEndBreak

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
   int      m_handle_stopatr, m_handle_tftrix, m_handle_tfsma, m_handle_tfchaikin;
   int      m_handle_sma, m_handle_rt7dbt_cur, m_handle_rt7dbt_htf;
     
   void SetSymbolProperties() { 
      m_symbol_custom = Symbol();
      m_symbol = CMyUtil::CurrentSymbol();      
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      MaximumSpreadPointCount = spread_points > 5 ? spread_points*3 : 15;
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
   
   void ModifyPosition(long _ticket, string _direction, double _sl_price) {
      string signal = "c=modify m=" + CMyUtil::XStringReplaceCharSpace(this.m_symbol) + " d=" + _direction + 
            " ticket=" + (string)_ticket + " sl=" + (string)_sl_price + " magic=" + (string)m_botid + " plus=mt";
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
      if ( Algo7_StoplossMode == STOPLOSS_BRICK ) {
         double high1 = iHigh(m_symbol_custom, 0, 1);
         double low1 = iLow(m_symbol_custom, 0, 1);
         brick_ticks = CMyUtil::NormalizePrice(m_symbol, MathAbs(high1 - low1));       
      }      
      else if ( Algo7_StoplossMode == STOPLOSS_ATR ) {
         brick_ticks = CMyUtil::NormalizePrice(m_symbol, atr);       
      } 
      else {
         int index; double level;
         if ( _direction == DEFINE_TRADE_DIR_LONG ) {
            index = iLowest(m_symbol_custom, 0, MODE_LOW, Algo7_StoplossCalcPeriod, 1);
            level = iLow(m_symbol_custom, 0, index);  
         }else {
            index = iHighest(m_symbol_custom, 0, MODE_HIGH, Algo7_StoplossCalcPeriod, 1);
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
         m_ok_filter_day = Algo7_EnableDateFilter == true ? CMyUtil::CheckTradingDay(true, Algo7_EnableNFP_Friday, Algo7_EnableNFP_Session, 
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
         
         //--- evaluating current positions
         uint xcount_long = 0, xcount_short = 0; 
         double xprofit_long = 0, xprofit_short = 0, xrisk_long = 0, xrisk_short = 0; 
         ulong curr_tickets[];        
         CMyUtil::PositionTickets((string)m_botid, "", m_symbol, "", "", curr_tickets); 
         CPositionInfo curr_position;
         for ( int k= 0; k < ArraySize(curr_tickets); k++ ) {
            if ( curr_position.SelectByTicket(curr_tickets[k]) == false ) continue;   
            int trailing_bar = (int)MathMod(bar_number, Algo7_TrailingBarFrequency); 
            if ( CMyUtil::GetPositionDirection(curr_position.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
               xcount_long++;   
               if ( Algo7_EnableProfitableExit ) {   
                  xprofit_long = curr_position.Profit();
                  xrisk_long = ParseMoneyRisked(curr_position.Comment());
               }
               if ( Algo7_TrailingStoplossMultiplier > 0 && trailing_bar == 0 ) {  
                  double brick_ticks = GetStoplossTicks(array_stopatr[1], DEFINE_TRADE_DIR_LONG);               
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, price_openbar - (brick_ticks * Algo7_TrailingStoplossMultiplier));
                  if ( sl_price > curr_position.StopLoss() ) {                     
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_LONG, sl_price); 
                  }  
               }
               if ( Algo7_Algo == ALGO_KOKODA ) {
                  xprofit_long = curr_position.Profit();
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, curr_position.PriceOpen());
                  if ( xprofit_long > 0 && sl_price > curr_position.StopLoss() ) {
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_LONG, sl_price);                       
                  }
               }
                
            } else {
               xcount_short++;   
               if ( Algo7_EnableProfitableExit ) {
                  xprofit_short = curr_position.Profit();  
                  xrisk_short = ParseMoneyRisked(curr_position.Comment()); 
               }                               
               if ( Algo7_TrailingStoplossMultiplier > 0 && trailing_bar == 0 ) {
                  double brick_ticks = GetStoplossTicks(array_stopatr[1], DEFINE_TRADE_DIR_SHORT);
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, price_openbar + (brick_ticks * Algo7_TrailingStoplossMultiplier));
                  if ( sl_price < curr_position.StopLoss() ) {                     
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_SHORT, sl_price); 
                  }  
               }  
               if ( Algo7_Algo == ALGO_KOKODA ) {
                  xprofit_long = curr_position.Profit();
                  double sl_price = CMyUtil::NormalizePrice(m_symbol, curr_position.PriceOpen());
                  if ( xprofit_long > 0 && sl_price < curr_position.StopLoss() ) {
                     ModifyPosition(curr_tickets[k], DEFINE_TRADE_DIR_SHORT, sl_price);                       
                  }
               }               
                            
            }         
         } 
         
         //--- algorithmic rules
         bool open_long = false, open_short = false, close_long = false, close_short = false;  
         if ( Algo7_Algo == ALGO_MARVEL ) {
            double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1);
            double arr_sma[];
            if(CMyUtil::XCopyBuffer("iMa", m_handle_sma, 0, 3, true, arr_sma) == false) return;   
            open_long = price_openbar > arr_sma[0]; 
            open_short = price_openbar < arr_sma[0];
            close_short = price_openbar > arr_sma[0];
            close_long = price_openbar < arr_sma[0];                 
         }         
         else if ( Algo7_Algo == ALGO_EMACROSS ) {
            double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1);
            double arr_sma[];
            if(CMyUtil::XCopyBuffer("iMa", m_handle_sma, 0, 3, true, arr_sma) == false) return;   
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
         else if ( Algo7_Algo == ALGO_KOKODA ) {            
            double arr_rt7dbt_htf[], arr_rt7dbt_cur[];
            //if(CMyUtil::XCopyBuffer("iKokoda_HTF", m_handle_rt7dbt_htf, 4, 3, true, arr_rt7dbt_htf) == false) return;
            if(CMyUtil::XCopyBuffer("iKokoda_CUR", m_handle_rt7dbt_cur, 4, 3, true, arr_rt7dbt_cur) == false) return;  
            open_long = arr_rt7dbt_cur[0] > 0; 
            open_short = arr_rt7dbt_cur[0] < 0;
         }  
         //--- reverse                 
         if ( Algo7_EnableReverseEntry ) {
            if ( open_long ) { open_long = false; open_short = true; }
            if ( open_short ) { open_long = true; open_short = false; }
         }    
         //--- trend filter
         bool ok_trend_long = true, ok_trend_short = true;
         if ( Algo7_TrendFilter == TRENDY_TRIX ) {
            double arr_tftrix[];
            if(CMyUtil::XCopyBuffer("iTrendFilterTriX", m_handle_tftrix, 0, 3, true, arr_tftrix) == false) return;       
            ok_trend_long = arr_tftrix[1] > arr_tftrix[2];
            ok_trend_short = arr_tftrix[1] < arr_tftrix[2];
            //close_short = ok_trend_long;
            //close_long = ok_trend_short;
         } else if ( Algo7_TrendFilter == TRENDY_SMA ) {
            ENUM_TIMEFRAMES xttf = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)0 : Algo7_TrendFilterTimeFrame;
            string xtsymbol = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? m_symbol_custom : m_symbol;
            double open_curr = iOpen(xtsymbol, xttf, 0);
            double arr_tfsma[];
            if(CMyUtil::XCopyBuffer("iTrendFilterMA", m_handle_tfsma, 0, 3, true, arr_tfsma) == false) return;       
            ok_trend_long = open_curr > arr_tfsma[0] && arr_tfsma[0] > arr_tfsma[1]; 
            ok_trend_short = open_curr < arr_tfsma[0] && arr_tfsma[0] < arr_tfsma[1];  
         }  else if ( Algo7_TrendFilter == TRENDY_CHAIKIN ) {
            double arr_tfchaikin[];
            if(CMyUtil::XCopyBuffer("iTrendFilterChaikin", m_handle_tfchaikin, 0, 3, true, arr_tfchaikin) == false) return;       
            ok_trend_long = arr_tfchaikin[0] > 0;
            ok_trend_short = arr_tfchaikin[0] < 0;
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
      string strbotid = IntegerToString(Algo7_Algo) + IntegerToString(CMyUtil::PeriodToMinutes(Period()));
      strbotid = (Algo7_TakeprofitMultiplier > 0) ? "1" + strbotid : strbotid; 
      strbotid = (Algo7_TrailingStoplossMultiplier > 0) ? "2" + strbotid : strbotid; 
      m_botid = (int)strbotid;
      SetSymbolProperties(); 
      //--- initialize algo specific variables 
      m_quantity = Algo7_FixedLotSize > 0 ? Algo7_FixedLotSize : Algo7_RiskPercentage;      
      m_ok_new_bar = false; m_ok_new_m5 = false; 
      
      if((m_handle_stopatr = iATR(m_symbol_custom, 0, Algo7_StoplossCalcPeriod)) == INVALID_HANDLE ) return(INIT_FAILED);  

      ENUM_TIMEFRAMES xttf = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)0 : Algo7_TrendFilterTimeFrame;
      string xtsymbol = Algo7_TrendFilterTimeFrame == PERIOD_CURRENT ? m_symbol_custom : m_symbol;                 
      if ( Algo7_TrendFilter == TRENDY_TRIX ) {
         if((m_handle_tftrix = iTriX(xtsymbol, xttf, Algo7_TrendFilterLength, PRICE_OPEN)) == INVALID_HANDLE ) return(INIT_FAILED);  
         CMyUtil::Info("TRENDY_TRIX Trend filter=", EnumToString(Algo7_TrendFilter), " timeframe=", EnumToString(xttf), " symbol=", xtsymbol);          
      }
      else if( Algo7_TrendFilter == TRENDY_SMA ) {
         if((m_handle_tfsma = iMA(xtsymbol, xttf, Algo7_TrendFilterLength, 1, MODE_SMA, PRICE_OPEN)) == INVALID_HANDLE ) return(INIT_FAILED);
         CMyUtil::Info("TRENDY_SMA Trend filter=", EnumToString(Algo7_TrendFilter), " timeframe=", EnumToString(xttf), " symbol=", xtsymbol);       
      } 
      else if( Algo7_TrendFilter == TRENDY_CHAIKIN ) {
         if((m_handle_tfchaikin = iChaikin(xtsymbol, xttf, 3, 10, MODE_EMA, VOLUME_TICK)) == INVALID_HANDLE ) return(INIT_FAILED);
         CMyUtil::Info("TRENDY_CHAIKIN Trend filter=", EnumToString(Algo7_TrendFilter), " timeframe=", EnumToString(xttf), " symbol=", xtsymbol);       
      }            
      CMyUtil::Info("Trading Algorithm=", EnumToString(Algo7_Algo), " Magic=", (string)m_botid, " symbol=", m_symbol_custom);
      if ( Algo7_Algo == ALGO_MARVEL ) { 
         if((m_handle_sma = iMA(m_symbol_custom, 0, Algo7_IndiParam1, 1, MODE_SMA, PRICE_OPEN)) == INVALID_HANDLE ) return(INIT_FAILED);
      }      
      else if ( Algo7_Algo == ALGO_EMACROSS ) { 
         if((m_handle_sma = iMA(m_symbol_custom, 0, Algo7_IndiParam1, 1, MODE_SMA, PRICE_OPEN)) == INVALID_HANDLE ) return(INIT_FAILED);            
      } 
      else if ( Algo7_Algo == ALGO_KOKODA ) { 
         if((m_handle_rt7dbt_cur = iCustom(m_symbol_custom, 0, "Tilly/rt7_double_bt")) == INVALID_HANDLE ) return(INIT_FAILED);
         if((m_handle_rt7dbt_htf = iCustom(m_symbol_custom, Algo7_IndiHigherTimeFrame, "Tilly/rt7_double_bt")) == INVALID_HANDLE ) return(INIT_FAILED);                        
      }      
                      
      this.DisplayInfo = Algo7_Comment + (string)m_botid;
      return (INIT_SUCCEEDED);
   }
   
   void Update() {    
      int bar_number = iBars(m_symbol_custom, 0);
      static int var_last_bar_number = bar_number;
      if ( bar_number > var_last_bar_number ) {
         var_last_bar_number = bar_number;
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
      
      Strategy7(bar_number);
      
   }   
      
   void Stop() { 
      IndicatorRelease(m_handle_stopatr); IndicatorRelease(m_handle_tftrix); IndicatorRelease(m_handle_tfsma); IndicatorRelease(m_handle_tfchaikin);  
      IndicatorRelease(m_handle_sma);     
      IndicatorRelease(m_handle_rt7dbt_cur); IndicatorRelease(m_handle_rt7dbt_htf);
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
                     CMyUtil::Info("applied SmartRiM, now risk=", (string)m_quantity);
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
