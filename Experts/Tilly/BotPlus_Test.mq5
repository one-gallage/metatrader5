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
#property description "BotPlus_Test"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_Test"; // Robot Name
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

input double   Algo1_RiskPercentage                   = 0.5;      // Risk Percentage; ex: 0.5 = 0.5%
input string   Algo1_Comment                          = "Test";   // Comment

input group    "..........................................................................."

enum EAlgo
{
   ALGO_A   =  801,
   ALGO_B   =  802
};
  
input EAlgo    Algo1_Algo                             =  ALGO_A;  // Trading Algorithm
input int      MA_Period                              =  9;       // Lookback

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

class CMyRobotImpl : public CMyRobot {

private:
   
   string   m_symbol;
   int      m_handle_cci;  
   bool     m_ok_new_bar;   
  
   void SetSymbolProperties() { 
      //m_symbol_custom = Symbol();
      m_symbol = CMyUtil::CurrentSymbol();      
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      MaximumSpreadPointCount = spread_points > 2 ? spread_points*5 : 10;
      int leverage = CMyUtil::LeverageAllowedForSymbol(m_symbol);
      CMyUtil::Info(m_symbol, " leverage=", (string)leverage,  " max_spread=", (string)MaximumSpreadPointCount);      
   }    

public:   
     
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_Algo;  
      this.TimerSeconds = 0;     
      SetSymbolProperties();
      //--- initialize algo specific variables 
      if((m_handle_cci = iCCI(NULL, 0, 14, PRICE_TYPICAL)) == INVALID_HANDLE ) return(INIT_FAILED); 
      
      string common_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
      CMyUtil::Info("common_data_path=", (string)common_data_path);     
      datetime date_from = D'2024.07.01 00:00';
      datetime date_to = D'2024.08.01 00:00';          
      CMyUtil::CheckNewsEvents(m_symbol, 30, 30, 3);   
      
      this.DisplayInfo = Algo1_Comment + (string)this.RobotId + ":" + EnumToString(Algo1_Algo);         
      return (INIT_SUCCEEDED);
   }
   
   void Update() {    
      datetime newbar_time = iTime(m_symbol, 0, 0); 
      static datetime var_last_newbar_time = newbar_time;
      if ( newbar_time > var_last_newbar_time ) {
         var_last_newbar_time = newbar_time;
         m_ok_new_bar = true;                  
      } else { 
         m_ok_new_bar = false; 
      } 
       
      if ( m_ok_new_bar ) {  
         double cci_arr[];
         if(CMyUtil::XCopyBuffer(m_handle_cci, 0, 3, true, cci_arr) == false) return; 
         Comment("CCI=", cci_arr[1]);   
         this.DisplayInfo = TimeToString(TimeCurrent()); 
      }
   }   
      
   void Stop() {
      IndicatorRelease(m_handle_cci); 
   }
  
   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {  
                    
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
