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
#property description "tilly_one_trading_bot"
#property description "© ErangaGallage"
#property strict


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_framework.mqh>

class CAlgoSuper : public CMyAlgo {

private:
   
   string   mSymbol;
   int      mHandleADR;
   int      handle_hans_x62, handle_cci;  
   
   int GetADRPointCount() {
      double array_adr[];
      CMyUtil::XCopyBuffer(mHandleADR, 0, 2, true, array_adr);
      return CMyUtil::GetATRPointCount(mSymbol,array_adr[0], 0, 1); 
   }   
   
   void SetMaximumSpread(int pADRPointCount) {
      int max_spread = (int) ((Robot_ADRPercentageSpread/100) * pADRPointCount);
      this.MaximumSpreadPointCount = max_spread;
   }

public:   
     
   int OnStartAlgo() {  
      //--- initialize common configuration
      this.AlgoId = Algo1_Magic;
      //--- initialize algo specific variables  
      mSymbol = Symbol();
      if((mHandleADR = iATR(mSymbol, PERIOD_D1, 1)) == INVALID_HANDLE ) return(INIT_FAILED);   
      SetMaximumSpread(GetADRPointCount());
      int leverage = CMyUtil::LeverageAllowedForSymbol(mSymbol);
      CMyUtil::Info("leverage=", (string)leverage); 
      
      if((handle_hans_x62 = iCustom(NULL,0,"Tilly/tilly_hans_x62_cloud")) == INVALID_HANDLE ) return(INIT_FAILED);
      if((handle_cci = iCCI(NULL, 0, 14, PRICE_TYPICAL)) == INVALID_HANDLE ) return(INIT_FAILED); 
      string common_data_path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
      CMyUtil::Info("common_data_path=", (string)common_data_path);           
      return (INIT_SUCCEEDED);
   }
   
   void OnUpdateAlgo() {         
      double AR_T_HANSX62[],AR_CCI[];
      int to_copy = 3;
      if(CMyUtil::XCopyBuffer(handle_cci, 0, to_copy, true, AR_CCI) == false) return; 
      Comment("CCI=",AR_CCI[1]);     
   }   
      
   void OnStopAlgo() {
      IndicatorRelease(mHandleADR); 
      IndicatorRelease(handle_hans_x62); 
      IndicatorRelease(handle_cci); 
   }
   
   void OnChartEventAlgo(const int id, const long& lparam, const double& dparam, const string& sparam) { 
   }
   
   void OnTradeTransactionAlgo(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
       //CMyUtil::Info("OnTradeTransaction event ", (string)transac.deal);   
   }   

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    " "  
input int      MA_Period            = 9;     // Bash Lookback
input int      BB_Period            = 20;    // Band Period
input double   Std                  = 0.4;   // Band Deviation
input int      OsMA_FastEMA_Period  = 1;     // Fast EMA
input int      OsMA_SlowEMA_Period  = 3;     // Slow EMA
input int      OsMA_Signal_Period   = 3;     // Signal EMA

input group    " "
input uint     Algo1_Magic                            = 777;   // Magic Number
input double   Algo1_RiskPercentage                   = 0.5;   // Risk Percentage; ex: 0.5 = 0.5%
input string   Algo1_TradeComment                     = "";    // Trade comment; The box description is used if this is empty
input double   Algo1_RewardMultiplier                 = 2.0;   // Take profit multiplier; 0.0 -> No take profit level

input group    " "
string         Robot_Name                             = "test_bot"; // Robot Name
int            Robot_TimerSeconds                     = 0; // Robot Timer Seconds
string         Robot_LicenseKey                       = "XXXX"; // License Key
input double   Robot_ADRPercentageSpread              = 10; // ADR Percentage as the Maximum Spread; ex: 10.0 = 10.0%
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
