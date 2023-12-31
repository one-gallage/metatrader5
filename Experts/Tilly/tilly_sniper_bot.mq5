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
#property description "tilly_sniper_bot"
#property description "© ErangaGallage"
#property strict


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_framework.mqh>


enum EAlgoMethod {
   ON_LAST_BAR_CLOSE,
   ON_LAST_BAR_OPEN
};

class CAlgoSuper : public CMyAlgo {

private:
   
   string   m_symbol, m_symbol_custom;
   int      m_handle_adr, m_handle_cci;
   
   int GetADRPointCount() {
      double array_adr[];
      CMyUtil::XCopyBuffer(m_handle_adr, 0, 3, true, array_adr);
      return CMyUtil::GetATRPointCount(m_symbol, array_adr[1], 0, 1); 
   }   
   
   void SetMaximumSpread(int pADRPointCount) {
      int max_spread = (int) ((Robot_ADRPercentageSpread/100) * pADRPointCount);
      this.MaximumSpreadPointCount = max_spread;
   }
   
   void SetSymbolName() {
      this.m_symbol_custom = Symbol();
      this.m_symbol = CMyUtil::CurrentSymbol();
   }

public:   
  
   int OnStartAlgo() {  
      //--- initialize common configuration
      this.AlgoId = Algo1_Magic;
      //--- initialize algo specific variables  
      this.SetSymbolName();
      if((m_handle_adr = iATR(m_symbol, PERIOD_D1, 1)) == INVALID_HANDLE ) return(INIT_FAILED); 
      //if((m_handle_cci = iCCI(m_symbol, 0, 14, PRICE_TYPICAL)) == INVALID_HANDLE ) return(INIT_FAILED);   
      this.SetMaximumSpread(GetADRPointCount());    
      return (INIT_SUCCEEDED);
   }
   
   void OnUpdateAlgo() {   
      /*static int last_bars = 0;
      int bars = iBars(m_symbol, PERIOD_M1); 
      if ( last_bars < bars ) {
         last_bars = bars;
      } else {
         return;
      }*/
      
      CMyUtil::RefreshRates(m_symbol);      
      double ask_price = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double bid_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double close1 = iClose(m_symbol_custom, 0, 1); double open1 = iOpen(m_symbol_custom, 0, 1); 
      
      bool is_buy = false, is_sell = false;
      if (close1 > open1) {
         if ( Algo1_Method == ON_LAST_BAR_CLOSE && ask_price < close1 ) { is_buy = true; }         
         else if ( Algo1_Method == ON_LAST_BAR_OPEN && ask_price <= open1 ) { is_buy = true; }
      } else {
         if ( Algo1_Method == ON_LAST_BAR_CLOSE && bid_price > close1 ) { is_sell = true; }         
         else if ( Algo1_Method == ON_LAST_BAR_OPEN && bid_price >= open1 ) { is_sell = true; }      
      }
      
      if (is_buy == false && is_sell == false) { return; }
               
      ulong current_buys[];
      CMyUtil::PositionTickets((string)Algo1_Magic,"",m_symbol,DEFINE_TRADE_DIR_LONG,"",current_buys);
      
      ulong current_sells[];
      CMyUtil::PositionTickets((string)Algo1_Magic,"",m_symbol,DEFINE_TRADE_DIR_SHORT,"",current_sells);
            
      /*CPositionInfo positionInfo; 
      for ( int k = 0; k < ArraySize(current_buys); k++ ) {
         if ( positionInfo.SelectByTicket(current_buys[k]) == false ) continue; //--- select the position 
         //--- modify the position         
         double stop_distance = positionInfo.PriceOpen() - positionInfo.StopLoss();
         double profit_distance = ask_price - positionInfo.PriceOpen();    
         if ( stop_distance > 0 && profit_distance > stop_distance * 1.2) {
               string signal = "modify plus=mt m=" + m_symbol + " d=" + DEFINE_TRADE_DIR_LONG + 
                  " sl=" + (string)positionInfo.PriceOpen();
               //this.AddSignal(signal);
         } 
      } 
      
      for ( int k = 0; k < ArraySize(current_sells); k++ ) {
         if ( positionInfo.SelectByTicket(current_sells[k]) == false ) continue; //--- select the position 
         //--- modify the position         
         double stop_distance = positionInfo.StopLoss() - positionInfo.PriceOpen();
         double profit_distance = positionInfo.PriceOpen() - bid_price;    
         if ( stop_distance > 0 && profit_distance > stop_distance * 1.2 ) {
               string signal = "modify plus=mt m=" + m_symbol + " d=" + DEFINE_TRADE_DIR_SHORT + 
                  " sl=" + (string)positionInfo.PriceOpen();
               //this.AddSignal(signal);
         } 
      }*/                    
      
      //double ind_cci[];
      //if(CMyUtil::XCopyBuffer(m_handle_cci, 0, 3, true, ind_cci) == false) return;       
     
      double gap_sl = MathAbs(close1 - open1) * 2.2;
      if ( ArraySize(current_buys) < 1 && is_buy == true ) {
         double sl_price = CMyUtil::NormalizePrice(m_symbol, close1 - gap_sl);      
         int sl_points = (int)(CMyUtil::ToPointsCount(m_symbol, MathAbs(ask_price-sl_price)));
         int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
         string comment = "U1_SIG_P938_" + DoubleToString(Algo1_RewardMultiplier,1);
         string signal = "open plus=mt m=" + m_symbol + " d=" + DEFINE_TRADE_DIR_LONG + " q=" + (string)Algo1_RiskPercentage + 
                  "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + comment;
         this.AddSignal(signal);
      }
      else if ( ArraySize(current_sells) < 1 && is_sell == true ) {
         double sl_price = CMyUtil::NormalizePrice(m_symbol, close1 + gap_sl);      
         int sl_points = (int)(CMyUtil::ToPointsCount(m_symbol, MathAbs(sl_price-bid_price)));
         int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
         string comment = "D1_SIG_P938_" + DoubleToString(Algo1_RewardMultiplier,1);
         string signal = "open plus=mt m=" + m_symbol + " d=" + DEFINE_TRADE_DIR_SHORT + " q=" + (string)Algo1_RiskPercentage + 
                  "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + comment;
         this.AddSignal(signal);
      }   
      
   }   
      
   void OnStopAlgo() {
      IndicatorRelease(m_handle_adr); 
      //IndicatorRelease(m_handle_cci); 
   }
   
   void OnChartEventAlgo(const int id, const long& lparam, const double& dparam, const string& sparam) { 
   }
   
   void OnTradeTransactionAlgo(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
   }   

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    " "
input uint     Algo1_Magic                            = 777;   // Magic Number
input double   Algo1_RiskPercentage                   = 0.5;   // Risk Percentage; ex: 0.5 = 0.5%
input EAlgoMethod Algo1_Method                        = ON_LAST_BAR_CLOSE; // Entry Method
input double   Algo1_RewardMultiplier                 = 0.3;   // Take profit multiplier; 0.0 -> No take profit level

input group    " "
string         Robot_Name                             = "tilly_sniper_bot"; // Robot Name
int            Robot_TimerSeconds                     = 0; // Robot Timer Seconds
string         Robot_LicenseKey                       = "XXXX"; // License Key
input double   Robot_ADRPercentageSpread              = 20; // ADR Percentage as the Maximum Spread; ex: 10.0 = 10.0%
input group    " "

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyRobot mRobot;
CAlgoSuper mAlgo;

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

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {  
   mAlgo.OnChartEventAlgo(id, lparam, dparam, sparam);     
}

void OnTradeTransaction(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
   mAlgo.OnTradeTransactionAlgo(transac, request, result);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
