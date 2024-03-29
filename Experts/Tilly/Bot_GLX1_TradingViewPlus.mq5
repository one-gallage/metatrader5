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
#property description "Bot_GLX1_TradingViewPlus"
#property description "© ErangaGallage"
#property strict


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_framework.mqh>

#define  MY_GLOBAL_VAR_PREFIX_ROOT     "TRVIEWPLUS"

class CAlgoTVPlus : public CMyAlgo {

private:
   string         mSymbol;
   int            mClientSocket;
   string         mAuthRequest, mResponse, m_global_var_running;
   
   bool IsSocketConnected() {
      bool isConnected = false;
      if(SocketIsConnected(mClientSocket)) {
         isConnected = true;
      }else {
         if(SocketConnect(mClientSocket,"127.0.0.1", Algo1_ClientSocketPort, 3*1000)) {           
            this.SendToSocket(true, mAuthRequest);
            string message = this.ReadFromSocket(true);         
            if(StringLen(message) > 0 && message == "AUTHORIZED") {
               CMyUtil::Info("Connected to Port: ", (string)Algo1_ClientSocketPort, " on 127.0.0.1");
               this.DisplayInfo = "Connected Port: " + (string)Algo1_ClientSocketPort;
               isConnected = true;
            }
            else{
               isConnected = false;
               CMyUtil::Error("Unauthorized to establish the connection.");
            }
         }  
         else {
            isConnected = false;//--- not connected to the socket
            CMyUtil::Info("Not connected to Port: ", (string)Algo1_ClientSocketPort, " on 127.0.0.1");
            this.DisplayInfo = "Not Connected";
         }           
      } 
      ResetLastError();
      return isConnected;         
   }

   bool SendToSocket(bool isSocketConnected, string request) {
      bool done = false;
      if(isSocketConnected) {
         char req[];
         int  len = StringToCharArray(request,req)-1;
         if(len<0) return(false);
         done = (SocketSend(mClientSocket, req, len)==len); 
      }
      return done;
   }

   string ReadFromSocket(bool isSocketConnected) {
      if (isSocketConnected) {
         char   rsp[];
         uint timeout_check = GetTickCount() + 50;
         uint avl_len; int rsp_len; 
         //--- read data from sockets till they are still present but not longer than timeout
         do {
            avl_len = SocketIsReadable(mClientSocket);
            if(avl_len > 0) {
               rsp_len = SocketRead(mClientSocket, rsp, avl_len, 50);         
               if(rsp_len > 0) {
                  mResponse += CharArrayToString(rsp, 0, rsp_len);            
               }
            }  
            else {
               break;
            }   
            if(GetTickCount() > timeout_check) {
               break;
            }
         }
         while(SocketIsConnected(mClientSocket));
      }
      
      int msg_len; int pos; int ind_start; int ind_end;
      string message = "";   
      msg_len = StringLen(mResponse);
      if(msg_len > 4 ){ //--- messagemformat is ><ABC><
         pos = 0;
         ind_start = StringFind(mResponse, "><", pos);
         if(ind_start>=pos) {
            pos = ind_start+2;
            ind_end = StringFind(mResponse, "><", pos);
            if(ind_end>=pos) {
               message = StringSubstr(mResponse, (ind_start+2), (ind_end-2));
               if(msg_len == (ind_end + 2)) {
                  mResponse = "";
               }
               else{
                  mResponse = StringSubstr(mResponse, (ind_end + 2));
               }
            }         
         }      
      } 
      return message;   
   }      
   
public:   
  
   int OnStartAlgo() {  
      //--- initialize common configuration
      this.AlgoId = Algo1_ClientSocketPort;
      this.RiskMultiplier = Algo1_RiskMultiplier;
      this.StoplossMultiplier = Algo1_StoplossMultiplier;                      
      this.BrokerSymbolMappings = Robot_BrokerSymbolMappings;
      //--- initialize algo specific configuration            
      if ( Algo1_ClientSocketPort <= 9390 || Algo1_ClientSocketPort >= 9399 ) {
         MessageBox("The value of 'Connecting Port' must be between 9390 to 9399.", __FILE__, MB_OK);   
         return (INIT_FAILED);      
      } 
      m_global_var_running = CMyUtil::GetGlobalVarName(MY_GLOBAL_VAR_PREFIX_ROOT, "RUNNING");   
      if ( GlobalVariableCheck(m_global_var_running) ){
         MessageBox(Robot_Name + " is already running on another chart.\r\nNo need to add this Expert again on the same account.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }
      GlobalVariableSet(m_global_var_running, 1);       
      mSymbol = Symbol();
      mClientSocket = SocketCreate();        
      mResponse = "";      
      mAuthRequest = "14520415@" + (string)AccountInfoInteger(ACCOUNT_LOGIN);
      return (INIT_SUCCEEDED);
   }

   void OnUpdateAlgo() {         
      CMyUtil::RefreshRates(mSymbol); //-- force refresh ticks
      if( GlobalVariableCheck(m_global_var_running) == false ) {
         GlobalVariableSet(m_global_var_running, 1);
      }   
      string signal = this.ReadFromSocket(this.IsSocketConnected());
      if (StringLen(signal) == 0) return;
      this.AddSignal(signal);    
   }
      
   void OnStopAlgo() {
      GlobalVariableDel(m_global_var_running);
      SocketClose(mClientSocket); 
   }
   
   void OnChartEventAlgo(const int id, const long& lparam, const double& dparam, const string& sparam) {      
   }
   
   void OnTradeTransactionAlgo(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {   
   }   

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    "*** Settings of Bot_GLX1_TradingViewPlus © ErangaGallage ***"
input group    "---------------------------------------------------"
input uint     Algo1_ClientSocketPort                 = 9393;  // Connecting Port
input double   Algo1_RiskMultiplier                   = 1;  // Risk value multiplier
input double   Algo1_StoplossMultiplier               = 1;  // Stoploss distance multiplier

string         Robot_Name                             = "Bot_GLX1_TradingViewPlus"; // Robot Name
int            Robot_TimerSeconds                     = 5; // Robot Timer Seconds
string         Robot_LicenseKey                       = "XXXX"; // License Key
input string   Robot_BrokerSymbolMappings             = ""; // Market Symbol mappings
input group    "---------------------------------------------------"


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMyRobot mRobot;
CAlgoTVPlus mAlgo;

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
