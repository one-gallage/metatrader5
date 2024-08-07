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
#property description "BotPlus_CopyDiscordReader"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_CopyDiscordReader"; // Robot Name
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

string   Algo1_DiscordServerBaseUrl             = "https://discord.com/api/v10";   // Discord Web Address
string   Algo1_DiscordBotToken                  = "MTExMDk1ODM4MDQ2MzQyMzU3OA.G9fsXt.rF3H_k8LdI6zL_sBFM2hHjsuYbDmchAAe4ij4w";  // Discord Bot Token
input string   Algo1_DiscordChannelId                 = "1110963091623120976";  // Customer ID
input string   Algo1_SignalMagicsReject               = "";          // Rejecting magics of Copy Sender (205,0)
input string   Algo1_SignalSymbolsReject              = "";          // Rejecting symbols of Copy Sender (USDJPY,USDCAD)
input group    "..........................................................................."

uint     Algo1_Magic                            = 811;  // Magic number
input double   Algo1_RiskMultiplier                   = 1.0;         // Use calculated lots with the multiplier for the copy trade
input double   Algo1_FixedLotSize                     = 0;           // Use fixed lots for the copy trade
input double   Algo1_StoplossMultiplier               = 1.0;         // Adjust the Stoploss distance using Stoploss multiplier
input string   Algo1_SymbolMappings                   = "";          // Symbol conversions (EURUSD=EUR/USD,USTEC=NAS100)

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>
        
#define  MY_GLOBAL_VAR_GROUP_ROOT      "DISCORDREADER"
#define  MY_REQUEST_TIMEOUT            5000
#define  MY_SLEEP_TIME                 3000

class CMyRobotImpl : public CMyRobot {

private:
   
   string         m_global_var_running;
   string         m_session_token;
   int            m_session_timeout;
   double         m_dxtrade_account_balance;  
   string         m_dxtrade_last_message_id;
  
   void LogError(string _request, int _httpCode, string _response) {
      CMyUtil::Error("DXtrade ", _request, " request failed ! ", (string)_httpCode, " ", _response);
      if ( _httpCode == -1 ) {
         CMyUtil::Error("'https://discord.com' should be added to the list of allowed ones on the client terminal ! Error: ", (string)GetLastError());
      } else if ( _httpCode != 200 ) {
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(_response);
         string code = json_node["code"].ToString();
         string desc = json_node["message"].ToString();
         CMyUtil::Error("Error description: ", desc, ". code: ", code);
         delete json_node; json_node = NULL;
      } 
   }   
    
      
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
      string instrument = CMyUtil::ParseBrokerSymbol(_market, Algo1_SymbolMappings, "", "");
      return instrument;  
   }     
           
   void ReadCopySignal(string _signal) {
      JSONNode* json_node = new JSONNode();
      CMyUtil::ParseSignal(_signal, json_node); 
      
      string command = json_node[DEFINE_SIGNAL_OPTION_COMMAND].ToString();
      string sender_market = json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string sender_magic = json_node[DEFINE_SIGNAL_OPTION_MAGIC].ToString();
      string sender_ticket = json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString();      
      string sender_quantity = json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString();
          
      if ( StringLen(command) == 0 || StringLen(sender_market) == 0 || StringLen(sender_magic) == 0 || StringLen(sender_ticket) == 0 ) { return; } 
      
      if ( ValidateSignal(sender_market, sender_magic) == false ) { return; }
            
      string receiver_market = CalcOrderInstrument(sender_market);
      json_node[DEFINE_SIGNAL_OPTION_MARKET] = receiver_market; 
      
      if ( StringCompare(command, DEFINE_SIGNAL_COMMAND_OPEN, false) == 0 ) {    
         if ( StringLen(sender_quantity) == 0 ) { CMyUtil::Error("Open Signal is ignored as the option ", DEFINE_SIGNAL_OPTION_QUANTITY, " is missing"); return; }   
         
         //-- sender_quantity must be a percentage in tradingview signals; ex: 1%
         json_node[DEFINE_SIGNAL_OPTION_GLOBALVAR_GROUP] = MY_GLOBAL_VAR_GROUP_ROOT + ".REF"; 
              
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
   
   bool GetChannel() {      
      string url = Algo1_DiscordServerBaseUrl + "/channels/" + Algo1_DiscordChannelId;
      string req_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: Bot " + Algo1_DiscordBotToken + "\r\n";
      string json_body = "";
      string result_headers;
      char req_chars[], result_chars[];
      StringToCharArray(json_body, req_chars, 0, StringLen(json_body));
      ResetLastError();
      int http_code = WebRequest("GET", url, req_headers, MY_REQUEST_TIMEOUT, req_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0);
      if ( http_code == 200 ) {         
         CMyUtil::Info("Discord channel ",  Algo1_DiscordChannelId, " accessed successfully -> ", response); 
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(response); 
         this.m_dxtrade_last_message_id = json_node["last_message_id"].ToString();         
         delete json_node; json_node = NULL;
         return true;   
      } else {
         LogError("channel", http_code, response);
      }   
      return false;
   }
   
   bool GetMessages() {      
      string query = "limit=9";
      if( StringLen(this.m_dxtrade_last_message_id) > 0 ) {
         query = "after=" + this.m_dxtrade_last_message_id;
      }
      string url = Algo1_DiscordServerBaseUrl + "/channels/" + Algo1_DiscordChannelId + "/messages?" + query;
      //CMyUtil::Info("Discord Request -> ", url); 
      string req_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: Bot " + Algo1_DiscordBotToken + "\r\n";
      string json_body = "";    
      string result_headers;
      char req_chars[], result_chars[];
      StringToCharArray(json_body, req_chars, 0, StringLen(json_body));
      ResetLastError();
      int http_code = WebRequest("GET", url, req_headers, MY_REQUEST_TIMEOUT, req_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0);
      if ( http_code == 200 ) {               
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(response);         
         int size = json_node.Size();
         string msg_id, msg_timestamp, msg_content;
         if ( size > 0 ) {
            for ( int i=size-1 ; i>=0 ; i-- ) {
               msg_id = json_node[i]["id"].ToString();
               msg_timestamp = json_node[i]["timestamp"].ToString();
               msg_content = json_node[i]["content"].ToString();               
               this.m_dxtrade_last_message_id = msg_id;
               string signal_msgs[];
               CMyUtil::XStringSplit(msg_content, "\n", signal_msgs);
               if ( ArraySize(signal_msgs)  > 0 ) {
                  for( int x=0 ; x < ArraySize(signal_msgs) ; x++) {   
                     CMyUtil::Info("Received Discord message -> ", signal_msgs[x]);         
                     ReadCopySignal(signal_msgs[x]); 
                  }
               }
                             
            }  
            for ( int i=size-1 ; i>=0 ; i-- ) {
               delete json_node[i];
            }                    
         }      
         delete json_node; json_node = NULL;
         return true;   
      } else {
         LogError("messages", http_code, response);
      }   
      return false;
   }   
        
         
public:   
  
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_Magic; 
      this.TimerSeconds = 16; 
      this.RiskMultiplier = Algo1_RiskMultiplier; 
      this.StoplossMultiplier = Algo1_StoplossMultiplier;
      //--- initialize algo specific variables  
      m_global_var_running = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT, "RUN");
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) > 0 ){
         MessageBox("Already running on another chart !\r\nNo need to add this Expert again on the same account.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }   
      CMyUtil::GlobalVarSetValue(m_global_var_running, "1");     
      if ( GetChannel() == false ) {
         MessageBox("Unauthorized access !\r\nCheck the details provided in the Inputs.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }   
      this.DisplayInfo = "DiscordReader" + (string)this.RobotId;
      return (INIT_SUCCEEDED);
   }
   
   void Update() { 
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) == 0 ){
         CMyUtil::GlobalVarSetValue(m_global_var_running, "1");     
      }   
      GetMessages();  
   }   
      
   void Stop() {     
      CMyUtil::GlobalVarDelete(m_global_var_running);
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
