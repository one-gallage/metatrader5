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
#property description "BotPlus_CopyMT5Reader"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_CopyMT5Reader"; // Robot Name
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

input ushort   Algo1_SenderServicePort                = 12600;       // Copy Sender port to connect
input string   Algo1_SignalMagicsReject               = "";          // Rejecting magics of Copy Sender (205,0)
input string   Algo1_SignalSymbolsReject              = "";          // Rejecting symbols of Copy Sender (USDJPY,USDCAD)

input group    "..........................................................................."

uint     Algo1_Magic                            = 888;         // Magic number
input double   Algo1_RiskMultiplier                   = 1.0;         // Quantity multiplier of copy trade
input double   Algo1_FixedLotSize                     = 0;           // Use fixed lots for the copy trade
input double   Algo1_StoplossMultiplier               = 1.0;         // Adjust the Stoploss distance using Stoploss multiplier
input string   Algo1_SymbolMappings                   = "";          // Symbol mappings (USTEC=NAS100,EURUSD.i=EURUSD)
input string   Algo1_SymbolSuffuxDeletion             = "";          // Symbol suffix to remove (.a -> to remove .a)
input string   Algo1_SymbolSuffuxAddition             = "";          // Symbol suffix to add (.pro -> to add .pro)

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>
#include <Tilly/tilly_socket_library.mqh>

#define  MY_GLOBAL_VAR_GROUP_ROOT   "MT5READER"

class CMyRobotImpl : public CMyRobot {

private:
   
   ClientSocket * m_client_socket;
   string         m_global_var_running;
     
   bool ValidateSignal(string _xmarket, string _xmagic) {
      bool valid = true;
      string reject_symbols[];
      CMyUtil::XStringSplit(Algo1_SignalSymbolsReject, ",", reject_symbols); 
      if ( CMyUtil::XStringCheckContains(reject_symbols, _xmarket) ) { valid = false; CMyUtil::Error("Order is ignored as " ,_xmarket, " is included in the rejecting Symbols"); }

      string reject_magics[];
      CMyUtil::XStringSplit(Algo1_SignalMagicsReject, ",", reject_magics);
      if ( CMyUtil::XStringCheckContains(reject_magics, _xmagic) ) { valid = false; CMyUtil::Error("Order is ignored as " ,_xmagic, " is included in the rejecting Magics"); }
      
      return valid;
   }  
   
   void ClearGlobalVariables() {
      string xtickets[];
      CMyUtil::GlobalVarSearchKeys(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", xtickets);
      string global_var_ticket, receiver_ticket;
      ulong postions[];
      for ( int i = 0 ; i < ArraySize(xtickets) ; i++) { 
         global_var_ticket = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", xtickets[i]);   
         receiver_ticket = CMyUtil::GlobalVarGetValue(global_var_ticket);
         if ( StringLen(receiver_ticket) == 0 ) { continue; }              
         CMyUtil::PositionTickets("", receiver_ticket, "", "", "", postions);
         if ( ArraySize(postions) < 1 ) { 
            //-- position doesn't exist            
            CMyUtil::GlobalVarDelete(global_var_ticket);  
         }  
      }
   }    
   
   string CalcOrderInstrument(string _market) {
      string instrument = CMyUtil::ParseBrokerSymbol(_market, Algo1_SymbolMappings, Algo1_SymbolSuffuxDeletion, Algo1_SymbolSuffuxAddition);
      return instrument;  
   }     
   
   double CalcOrderQuantity(double _input_volume, double _input_balance, double _output_balance) {      
      //CMyUtil::Info("DXtrade account balance= ", (string)this.m_dxtrade_account_balance);
      double xnew_volume;
      if ( Algo1_FixedLotSize > 0 )  {
         xnew_volume = Algo1_FixedLotSize;
      } else {
         xnew_volume = (_input_volume/_input_balance) * _output_balance * Algo1_RiskMultiplier;
      }    
      return xnew_volume;    
   }
   
   string CalcOrderComment(string _sender_comment, string _extra) {   
      string lead_comment = CMyUtil::ParseComment(_sender_comment);
      return StringLen(lead_comment) > 0 ? lead_comment + "@" + _extra : "";
   }   
          
   void ReadCopySignal(string _signal) {
      JSONNode* json_node = new JSONNode();
      CMyUtil::ParseSignal(_signal, json_node); 
      
      string command = json_node[DEFINE_SIGNAL_OPTION_COMMAND].ToString();
      string sender_market = json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string sender_magic = json_node[DEFINE_SIGNAL_OPTION_MAGIC].ToString();
      string sender_ticket = json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString();      
      string sender_quantity = json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString();
      string sender_balance = json_node[DEFINE_SIGNAL_OPTION_BALANCE].ToString(); 
      string sender_comment = json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();      
          
      if ( StringLen(command) == 0 || StringLen(sender_market) == 0 || StringLen(sender_magic) == 0 || StringLen(sender_ticket) == 0 ) { return; } 
      
      if ( ValidateSignal(sender_market, sender_magic) == false ) { return; }
            
      string receiver_market = CalcOrderInstrument(sender_market);
      json_node[DEFINE_SIGNAL_OPTION_MARKET] = receiver_market; 
      
      if ( StringCompare(command, DEFINE_SIGNAL_COMMAND_OPEN, false) == 0 ) {    
         if ( StringLen(sender_quantity) == 0 ) { CMyUtil::Error("Open Signal is ignored as the option ", DEFINE_SIGNAL_OPTION_QUANTITY, " is missing"); return; }   
         if ( StringLen(sender_balance) == 0 ) { CMyUtil::Error("Open Signal is ignored as the option ", DEFINE_SIGNAL_OPTION_BALANCE, " is missing"); return; }   
            
         double dreceiver_balance = AccountInfoDouble(ACCOUNT_BALANCE);
         double dsender_balance = StringToDouble(sender_balance) > 0 ? StringToDouble(sender_balance) : dreceiver_balance;
         double dsender_quantity = StringToDouble(sender_quantity);
         double dreceiver_quantity = CalcOrderQuantity(dsender_quantity, dsender_balance, dreceiver_balance);
         MqlTick mql_tick;
         SymbolInfoTick(receiver_market, mql_tick);      
         double spread_ticks =  CMyUtil::NormalizePrice(receiver_market, MathAbs(mql_tick.ask-mql_tick.bid)); 
         string extra_comment = (string)CMyUtil::ToPointsCount(receiver_market, spread_ticks);            
         string dreceiver_comment = CalcOrderComment(sender_comment, extra_comment);
         json_node[DEFINE_SIGNAL_OPTION_QUANTITY] = DoubleToString(dreceiver_quantity,3);
         json_node[DEFINE_SIGNAL_OPTION_GLOBALVAR_GROUP] = MY_GLOBAL_VAR_GROUP_ROOT + ".REF";     
         json_node[DEFINE_SIGNAL_OPTION_REFERENCE] = dreceiver_comment;    
      } 
      else {
         string global_var_ticket = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", sender_ticket);  
         string receiver_ticket = CMyUtil::GlobalVarGetValue(global_var_ticket);
         //CMyUtil::Debug(__FUNCTION__, "() Reads the Global var ", global_var_xticket, "=", mapped_ticket);
         if ( StringLen(receiver_ticket) == 0 ) { return; }            
         json_node[DEFINE_SIGNAL_OPTION_TICKET] = receiver_ticket;         
      }
      
      this.AddSignalJSON(json_node);
   }   

protected:
  
   void ReceiveSignals() {
      string str_response;
      do {
         str_response = m_client_socket.Receive("\r\n");
         if (str_response == "Hello") {
            CMyUtil::Info("Connected to ", (string)Algo1_SenderServicePort);
            this.DisplayInfo = "Connected to Sender: " + (string)Algo1_SenderServicePort;
         } else if ( str_response != "" ) {
            ReadCopySignal(str_response);
         }
      } while ( StringLen(str_response) > 0 );
   }  
      
public:   
  
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_Magic; 
      this.TimerSeconds = 4;
      this.RiskMultiplier = Algo1_RiskMultiplier;
      this.StoplossMultiplier = Algo1_StoplossMultiplier;
      //--- initialize algo specific variables  
      m_global_var_running = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT, "RUN");
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) > 0 ){
         MessageBox("Already running on another chart !\r\nNo need to add this Expert again on the same account.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }   
      CMyUtil::GlobalVarSetValue(m_global_var_running, "1"); 
      this.DisplayInfo = "Trying to connect";
      return (INIT_SUCCEEDED);
   }
   
   void Update() { 
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) == 0 ){
         CMyUtil::GlobalVarSetValue(m_global_var_running, "1");     
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
            CMyUtil::Info("Not connected to ", (string)Algo1_SenderServicePort, ". Will retry again !");
            delete m_client_socket;
            m_client_socket = NULL;
            this.DisplayInfo = "Trying to connect";
         }
      }       
   }   
      
   void Stop() {      
      CMyUtil::GlobalVarDelete(m_global_var_running);
      if ( m_client_socket ) {
         delete m_client_socket;
         m_client_socket = NULL;
      }
   }  
   
   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {       
      if ( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ClearGlobalVariables();
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
