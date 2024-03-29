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
#property description "Bot_GLX1_TradeCopyReceiver_From_MT5"
#property description "© ErangaGallage"
#property strict


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_framework.mqh>
#include <Tilly/Utils/socket-library-mt4-mt5.mqh>

class CAlgoCopyReceiver : public CMyAlgo {

#define  MY_GLOBAL_VAR_PREFIX_ROOT     "TCRECEFROMMT5"

private:
   
   ClientSocket * m_client_socket;
   string         m_global_var_running;
     
   void ReadCopySignal(string _signal) {
      string str_signal = _signal;
      string options[];
      int count = CMyUtil::XStringSplit(str_signal, " ", options);    
        
      string valid_commands[] = {DEFINE_SIGNAL_COMMAND_OPEN, DEFINE_SIGNAL_COMMAND_MODIFY, DEFINE_SIGNAL_COMMAND_CLOSE, DEFINE_SIGNAL_COMMAND_DELETE};
      string value, command="", market="", xmagic="", xcapital="", xvolume="", xticket="";
      for (int i=0; i < count; i++) {
         command  = command == "" && (value = CMyUtil::XStringCheckContains(valid_commands, options[i])) != "" ? value : command;
         market   = market == "" && (value = CMyUtil::XStringGetValueForKey(options[i], DEFINE_SIGNAL_OPTION_MARKET, "=")) != "" ? value : market;      
         xmagic   = xmagic == "" && (value = CMyUtil::XStringGetValueForKey(options[i], "xmagic", "=")) != "" ? value : xmagic;      
         xcapital = xcapital == "" && (value = CMyUtil::XStringGetValueForKey(options[i], "xcapital", "=")) != "" ? value : xcapital;
         xvolume  = xvolume == "" && (value = CMyUtil::XStringGetValueForKey(options[i], "xvolume", "=")) != "" ? value : xvolume;
         xticket  = xticket == "" && (value = CMyUtil::XStringGetValueForKey(options[i], DEFINE_SIGNAL_OPTION_XTICKET, "=")) != "" ? value : xticket;
      }     
      if ( StringLen(command) == 0 || StringLen(market) == 0 || StringLen(xmagic) == 0 || StringLen(xticket) == 0 ) { return; } 
      
      string reject_symbols[];
      CMyUtil::XStringSplit(Algo1_SignalSymbolsReject, ",", reject_symbols);
      string sincluded = CMyUtil::XStringCheckContains(reject_symbols, market);
      if ( StringLen(sincluded) > 0 ) { CMyUtil::Error("Signal is ignored as " ,market, " is included in the Rejecting Symbols"); return;}

      string reject_magics[];
      CMyUtil::XStringSplit(Algo1_SignalMagicsReject, ",", reject_magics);
      sincluded = CMyUtil::XStringCheckContains(reject_magics, xmagic); 
      if ( StringLen(sincluded) > 0 ) { CMyUtil::Error("Signal is ignored as " ,xmagic, " is included in the Rejecting Magic numbers"); return;}
      
      if ( command == DEFINE_SIGNAL_COMMAND_OPEN ) {    
         if ( StringLen(xcapital) == 0 || StringLen(xvolume) == 0 ) { CMyUtil::Error("Open Signal is ignored as the 'xcapital','xvolume' options are missing"); return; }   

         double receiver_capital = AccountInfoDouble(ACCOUNT_BALANCE);
         double sender_capital = StringToDouble(xcapital) > 0 ? StringToDouble(xcapital) : receiver_capital;
         double sender_volume = StringToDouble(xvolume);
         double receiver_volume = (sender_volume/sender_capital) * receiver_capital;
         str_signal = str_signal + " " + DEFINE_SIGNAL_OPTION_QUANTITY + "=" + DoubleToString(receiver_volume,3) + " ";
      } 
      else {
         string global_var_xticket = CMyUtil::GetGlobalVarName("TRCOPY_" + DEFINE_SIGNAL_OPTION_XTICKET, xticket);  
         if ( GlobalVariableCheck(global_var_xticket) ) {
            int mapped_ticket = (int)GlobalVariableGet(global_var_xticket);
            //CMyUtil::Debug(__FUNCTION__, "() Reads the Global var ", global_var_xticket, "=", (string)mapped_ticket);
            if ( mapped_ticket > 0 ) {
               str_signal = str_signal + " " + DEFINE_SIGNAL_OPTION_TICKET + "=" + (string)mapped_ticket + " ";
            }
         }
      }
      
      this.AddSignal(str_signal);
   }
   
   void ReceiveSignals() {
      string str_response;
      do {
         str_response = m_client_socket.Receive("\r\n");
         if (str_response == "Hello") {
            CMyUtil::Info("TradeCopyReceiver is connected to ", (string)Algo1_SenderServicePort);
            this.DisplayInfo = "Connected to Sender: " + (string)Algo1_SenderServicePort;
         } else {
            ReadCopySignal(str_response);
         }
      } while (str_response != "");
   }
      
public:   
  
   int OnStartAlgo() {  
      //--- initialize common configuration
      this.AlgoId = Algo1_Magic; 
      this.BrokerSymbolMappings = Algo1_SymbolMappings;
      this.BrokerSymbolSuffuxDeletion = Algo1_SymbolSuffuxDeletion;
      this.BrokerSymbolSuffuxAddition = Algo1_SymbolSuffuxAddition;
      this.RiskMultiplier = Algo1_RiskMultiplier;
      //--- initialize algo specific variables  
      m_global_var_running = CMyUtil::GetGlobalVarName(MY_GLOBAL_VAR_PREFIX_ROOT, (string)Algo1_SenderServicePort);          
      if ( GlobalVariableCheck(m_global_var_running) ){
         MessageBox(Robot_Name + " is already connected to Sender port " + (string)Algo1_SenderServicePort + " from another chart on this account !", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }      
      GlobalVariableSet(m_global_var_running, 1);  
      this.DisplayInfo = "Attempting to connect";
      return (INIT_SUCCEEDED);
   }
   
   void OnUpdateAlgo() { 
      if(   GlobalVariableCheck(m_global_var_running) == false ) {
         GlobalVariableSet(m_global_var_running, 1);
      } 
      if ( !m_client_socket ) {
         m_client_socket = new ClientSocket("localhost", Algo1_SenderServicePort);         
      }
      if ( m_client_socket.IsSocketConnected() ) {         
         ReceiveSignals();
      } else {
         datetime current_time = TimeCurrent();
         static datetime var_last_try = 0;
         if ((current_time - var_last_try) >= 30) {
            var_last_try = current_time;
            //--- If the socket is closed, destroy it, and attempt a new connection on the next call
            CMyUtil::Info("TradeCopyReceiver is not connected to ", (string)Algo1_SenderServicePort, ". Will retry again !");
            delete m_client_socket;
            m_client_socket = NULL;
            this.DisplayInfo = "Attempting to connect";
         }
      }       
   }   
      
   void OnStopAlgo() {      
      GlobalVariableDel(m_global_var_running);
      if ( m_client_socket ) {
         delete m_client_socket;
         m_client_socket = NULL;
      }      
   }  
   
   void OnTradeTransactionAlgo(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {  

      if ( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError();          
         CMyUtil::ClearGlobalVariables("TRCOPY_" + DEFINE_SIGNAL_OPTION_XTICKET);
      }
         
   }   

};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    "*** Settings of Bot_GLX1_TradeCopyReceiver_From_MT5 © ErangaGallage ***"
input group    "---------------------------------------------------"
input ushort   Algo1_SenderServicePort                = 12100;       // Sender service port to connect
input string   Algo1_SignalMagicsReject               = "";          // Rejecting magic numbers (205,0)
input string   Algo1_SignalSymbolsReject              = "";          // Rejecting symbols (USDJPY,USDCAD)

input group    "---------------------------------------------------"
uint     Algo1_Magic                            = 636;         // Magic number
input double   Algo1_RiskMultiplier                   = 1.0;         // Quantity multiplier of copy trade
input string   Algo1_SymbolMappings                   = "";          // Symbol mappings (USTEC=NAS100,EURUSD.i=EURUSD)
input string   Algo1_SymbolSuffuxDeletion             = "";          // Symbol suffix to remove (.a -> to remove .a)
input string   Algo1_SymbolSuffuxAddition             = "";          // Symbol suffix to add (.b -> to add .b)

input group    "---------------------------------------------------"
string         Robot_Name                             = "Bot_GLX1_TradeCopyReceiver_From_MT5"; // Robot Name
int            Robot_TimerSeconds                     = 2; // Robot Timer Seconds
string         Robot_LicenseKey                       = "XXXX"; // License Key

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyRobot mRobot;
CAlgoCopyReceiver mAlgo;

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
