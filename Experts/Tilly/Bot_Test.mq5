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
#property description "Bot_Test"
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
      string common_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
      CMyUtil::Info("common_data_path=", (string)common_data_path);           
      return (INIT_SUCCEEDED);
   }
   
   void OnUpdateAlgo() {         
      /*double AR_T_HANSX62[],AR_CCI[];
      int to_copy = 3;
      if(CMyUtil::XCopyBuffer(handle_cci, 0, to_copy, true, AR_CCI) == false) return; 
      Comment("CCI=",AR_CCI[1]);*/     
   }   
      
   void OnStopAlgo() {
      Comment("");
      IndicatorRelease(mHandleADR); 
      IndicatorRelease(handle_hans_x62); 
      IndicatorRelease(handle_cci); 
   }
   
  
   void OnTradeTransactionAlgo(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {  
                    
      if ( _request.action == TRADE_ACTION_SLTP && _result.retcode == TRADE_RETCODE_DONE) {
         Print("Modify position ", 
                  ", request type=", EnumToString(_request.type),
                  ", retcode=", _result.retcode,
                  ", deal=", _result.deal,
                  ", order=", _result.order,
                  ", position=", _request.position);   
         CPositionInfo positionInfo; 
         if (positionInfo.SelectByTicket(_request.position)) {
            Print(" PriceOpen=", positionInfo.PriceOpen(),
                  ", StopLoss=", positionInfo.StopLoss(),
                  ", TakeProfit=", positionInfo.TakeProfit(),
                  ", Comment=", positionInfo.Comment());  
         }
      }   
       
     if( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {

         if(HistoryDealSelect(_transaction.deal)) {
            ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(_transaction.deal, DEAL_ENTRY);
            long position_id = HistoryDealGetInteger(_transaction.deal, DEAL_POSITION_ID);
            ENUM_DEAL_REASON reason = (ENUM_DEAL_REASON)HistoryDealGetInteger(_transaction.deal, DEAL_REASON);
            Print("DEAL_ENTRY=", EnumToString(deal_entry),
                  ", deal=", _transaction.deal,
                  ", reason=", EnumToString(reason));                  
            
            if ( deal_entry == DEAL_ENTRY_IN ) {
               double stop_loss = HistoryDealGetDouble(_transaction.deal, DEAL_SL);
               double take_profit = HistoryDealGetDouble(_transaction.deal, DEAL_TP);
               string symb = HistoryDealGetString(_transaction.deal, DEAL_SYMBOL);
               string comment = HistoryDealGetString(_transaction.deal, DEAL_COMMENT);
               Print("Open position ", 
                  ", position_id=", position_id,
                  ", Symbol=", symb,
                  ", stop_loss=", stop_loss,
                  ", take_profit=", take_profit,
                  ", comment=", comment);                
            }

            if ( deal_entry == DEAL_ENTRY_OUT ) {
               double deal_profit = HistoryDealGetDouble(_transaction.deal, DEAL_PROFIT);
               double deal_commision = HistoryDealGetDouble(_transaction.deal, DEAL_COMMISSION);
               Print("Close position ", 
                  ", position_id=", position_id,
                  ", deal_profit=", deal_profit,
                  ", deal_commision=", deal_commision);                     
                            
            }         
                    
         }

      }    
     
   }   

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    "---------------------------------------------------"  
input int      MA_Period            = 9;     // Bash Lookback
input int      BB_Period            = 20;    // Band Period
input double   Std                  = 0.4;   // Band Deviation
input int      OsMA_FastEMA_Period  = 1;     // Fast EMA
input int      OsMA_SlowEMA_Period  = 3;     // Slow EMA
input int      OsMA_Signal_Period   = 3;     // Signal EMA

input group    "---------------------------------------------------"
input uint     Algo1_Magic                            = 777;   // Magic Number
input double   Algo1_RiskPercentage                   = 0.5;   // Risk Percentage; ex: 0.5 = 0.5%
input string   Algo1_TradeComment                     = "";    // Trade comment; The box description is used if this is empty
input double   Algo1_RewardMultiplier                 = 2.0;   // Take profit multiplier; 0.0 -> No take profit level

input group    "---------------------------------------------------"
string         Robot_Name                             = "Bot_Test"; // Robot Name
int            Robot_TimerSeconds                     = 5; // Robot Timer Seconds
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

void OnTradeTransaction(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
   mAlgo.OnTradeTransactionAlgo(transac, request, result);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
