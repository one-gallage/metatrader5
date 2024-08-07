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
#property description "BotPlus_CopyDXtradeSender"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_CopyDXtradeSender"; // Robot Name
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

input string   Algo1_DXtradeServerBaseUrl             = "https://trade.gooeytrade.com";   // DXtrade Web Address
input string   Algo1_DXtradeAccountNumber             = "508272";       // DXtrade Account Number
input string   Algo1_DXtradeLoginUser                 = "SPT_C109691";  // DXtrade Login Username
input string   Algo1_DXtradeLoginPassword             = "n8A}:CT*6";    // DXtrade Login Password

input group    "..........................................................................."

uint     Algo1_Magic                            = 822;  // Magic number
input bool     Algo1_UseCopyingStopTake               = true;        // Copy the stoploss and takeprofit prices ?
input string   Algo1_SymbolMappings                   = "EURUSD=EUR/USD,XAUUSD=XAU/USD,NDX100=NAS100"; // Symbol conversions (EURUSD=EUR/USD,USTEC=NAS100)
input double   Algo1_RiskMultiplier                   = 1.0;         // Use calculated lots with the multiplier for the copy trade
input double   Algo1_FixedLotSize                     = 0;           // Use fixed lots for the copy trade
input string   Algo1_SymbolLotNormalizations          = "EURUSD=1,XAUUSD=100,NDX100=100"; // Symbol lot size normalizations (EURUSD=1,XAUUSD=100)
input string   Algo1_SignalMagicsReject               = "";          // Ignore copying these Magic numbers (205,0)
input string   Algo1_SignalSymbolsReject              = "";          // ignore copying these Symbols (USDJPY,USDCAD)

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>
        
#define  MY_GLOBAL_VAR_GROUP_ROOT   "DXTRSENDER"
#define  MY_POST_TIMEOUT            35000
#define  MY_SLEEP_TIME              5000
#define  MY_DXTRADE_API             "/dxsca-web"
#define  MY_TAG_DEFAULT             "default"

class CMyRobotImpl : public CMyRobot {

private:
   
   string         m_global_var_running;
   string         m_session_token;
   int            m_session_timeout;
   double         m_dxtrade_balance;  
    
   void LogError(string _request, int _httpCode, string _response) {
      CMyUtil::Error("DXtrade ", _request, " request failed ! ", (string)_httpCode, " ", _response);
      if ( _httpCode == -1 ) {
         CMyUtil::Error("DXtrade Web site address should be added to the list of allowed ones on the client terminal. Error: ", (string)GetLastError());
      } else if ( _httpCode != 200 ) {
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(_response);
         string code = json_node["errorCode"].ToString();
         string desc = json_node["description"].ToString();
         CMyUtil::Error("Error description: ", desc, ". code: ", code);
         delete json_node; json_node = NULL;
      } 
   }   
 
   bool ValidateSignal(string _xmarket, string _xmagic) {
      bool valid = true;
      string reject_symbols[];
      CMyUtil::XStringSplit(Algo1_SignalSymbolsReject, ",", reject_symbols); 
      if ( CMyUtil::XStringCheckContains(reject_symbols, _xmarket) ) { valid = false; CMyUtil::Error("Order is ignored as " ,_xmarket, " is included in the Copy rejecting Symbols"); }

      string reject_magics[];
      CMyUtil::XStringSplit(Algo1_SignalMagicsReject, ",", reject_magics);
      if ( CMyUtil::XStringCheckContains(reject_magics, _xmagic) ) { valid = false; CMyUtil::Error("Order is ignored as " ,_xmagic, " is included in the Copy rejecting Magic numbers"); }
      
      return valid;
   }  
      
   void ClearGlobalVariables() {
      string global_keys[];
      CMyUtil::GlobalVarSearchKeys(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", global_keys);
      ulong postions[];
      for ( int i = 0 ; i < ArraySize(global_keys) ; i++) {       
         CMyUtil::PositionTickets("", global_keys[i], "", "", "", postions);
         if ( ArraySize(postions) < 1 ) { 
            //-- position doesn't exist
            string global_var_copy = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", global_keys[i]);
            CMyUtil::GlobalVarDelete(global_var_copy);   
            string global_var_modify = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".STOP", global_keys[i]);
            CMyUtil::GlobalVarDelete(global_var_modify);   
            global_var_modify = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".LIMIT", global_keys[i]);
            CMyUtil::GlobalVarDelete(global_var_modify);
         }  
      }
   }     
   
   string CalcOrderSide(string _direction) {
      string side = "";
      if ( StringCompare(DEFINE_TRADE_DIR_LONG, _direction, false) == 0 ) {
         side = "BUY";
      }
      else if ( StringCompare(DEFINE_TRADE_DIR_SHORT, _direction, false) == 0 ) {
         side = "SELL";
      }      
      return side;
   } 
   
   string CalcOrderOppositeSide(string _side) {
      string opp_side = _side == "BUY" ? "SELL" : "BUY";
      return opp_side;
   }   
   
   string CalcOrderInstrument(string _market) {
      string instrument = CMyUtil::ParseBrokerSymbol(_market, Algo1_SymbolMappings, "", "");
      return instrument;  
   }  
   
   double CalcOrderQuantity(string _market, double _input_volume, double _input_capital, double _output_capital) {      
      double xnew_volume = (_input_volume/_input_capital) * _output_capital * Algo1_RiskMultiplier; 
      CMyUtil::Info("DXtrade account balance= ", (string)_output_capital, ", suggested order quantity=", (string)xnew_volume);           
      if ( Algo1_FixedLotSize > 0 )  {
         return Algo1_FixedLotSize;
      }   
      if ( StringLen(Algo1_SymbolLotNormalizations) > 0 ) {
         string mapping_array[];    
         int count = CMyUtil::XStringSplit(Algo1_SymbolLotNormalizations,",", mapping_array);
         string token[];
         for (int i=0; i < count; i++) {
            CMyUtil::XStringSplit(mapping_array[i],"=", token);            
            if ( ArraySize(token) == 2 && StringCompare(_market,token[0],false) == 0 ) {
               CMyUtil::Info("Symbol has '", _market, "' lot size normaliztion ", token[1]); 
               long normalizer = StringToInteger(token[1]);
               long norm_volume = (long)(xnew_volume * normalizer);
               xnew_volume =  (double) norm_volume;
               break;
            }           
         }         
      }       
      return xnew_volume;    
   }
   
   bool _PostNewOrderX(long _mt_position_id, string _instrument, double _quantity, string _side) {   
      string account =  MY_TAG_DEFAULT + ":" + Algo1_DXtradeAccountNumber;
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API+ "/accounts/" + account + "/orders";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI " + this.m_session_token + "\r\n";
      string json_body =   "{" + 
                              "\"account\":\"" + account + "\"," +
                              "\"orderCode\":\"" + (string)_mt_position_id + "\"," +                              
                              "\"type\":\"" + "MARKET" + "\"," +                              
                              "\"instrument\":\"" + _instrument + "\"," +
                              "\"quantity\":" + (string)_quantity + "," +  
                              "\"positionEffect\":\"" + "OPEN" + "\"," +                                
                              "\"side\":\"" + _side + "\"," +
                              "\"tif\":\"" + "GTC" + "\"" +
                           "}";
      string result_headers;
      char post_chars[], result_chars[];
      StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
      CMyUtil::Info("DXtrade new order request -> ", json_body);
      ResetLastError();
      int http_code = WebRequest("POST", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
      if ( http_code == 200 ) {    
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(response);        
         string dx_position_id = json_node["orderId"].ToString();
         string global_var_copy = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", (string)_mt_position_id);
         CMyUtil::GlobalVarSetValue(global_var_copy, dx_position_id);
         delete json_node; json_node = NULL;
         CMyUtil::Info("DXtrade opened position ", dx_position_id, " successfully -> ", response); 
         return true;   
      } else {
         LogError("open_order", http_code, response);
         PostLogin();
      }   
      return false; 
   }  
   
   bool _PostCloseOrderX(long _mt_position_id, string _instrument, string _side) {  
      string global_var_copy = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", (string)_mt_position_id);
      string dx_position_id = CMyUtil::GlobalVarGetValue(global_var_copy);
      if( StringLen(dx_position_id) == 0 ) {
         return false;
      }        
      string account =  MY_TAG_DEFAULT + ":" + Algo1_DXtradeAccountNumber;
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/accounts/" + account + "/orders";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI " + this.m_session_token + "\r\n";
      string json_body = "{" + 
                              "\"account\":\"" + account + "\"," +
                              "\"orderCode\":\"" + (string)GetTickCount64() + "\"," +  
                              "\"type\":\"" + "MARKET" + "\"," +                 
                              "\"instrument\":\"" + _instrument + "\"," +  
                              "\"positionEffect\":\"" + "CLOSE" + "\"," + 
                              "\"positionCode\":\"" + dx_position_id + "\"," +                               
                              "\"side\":\"" + _side + "\"," +
                              "\"tif\":\"" + "GTC" + "\"" +
                        "}";                  
      string result_headers;
      char post_chars[], result_chars[];
      StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
      CMyUtil::Info("DXtrade close order request -> ", json_body);
      ResetLastError();
      int http_code = WebRequest("POST", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
      if ( http_code == 200 ) { 
         CMyUtil::GlobalVarDelete(global_var_copy);   
         string global_var_modify = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".STOP", (string)_mt_position_id);
         CMyUtil::GlobalVarDelete(global_var_modify);   
         global_var_modify = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".LIMIT", (string)_mt_position_id);
         CMyUtil::GlobalVarDelete(global_var_modify);          
         CMyUtil::Info("DXtrade closed position ", (string)dx_position_id, " successfully -> ", response);              
         return true;   
      } else {
         LogError("close_position_" + (string)dx_position_id, http_code, response);
         PostLogin();
      }   
      return false; 
   }  
   
   bool PostModifyOrder(long _mt_position_id, string _instrument, string _side, string _type, double _price) {
      string global_var_copy = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + ".REF", (string)_mt_position_id);
      string dx_position_id = CMyUtil::GlobalVarGetValue(global_var_copy);
      if( StringLen(dx_position_id) == 0 ) {
         return false;
      }
      string account =  MY_TAG_DEFAULT + ":" + Algo1_DXtradeAccountNumber;
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/accounts/" + account + "/orders";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI " + this.m_session_token + "\r\n";
      string json_body = "", info = "";      
      string global_var_modify = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT + "." + _type, (string)_mt_position_id);
      string dx_order_code = CMyUtil::GlobalVarGetValue(global_var_modify);  
      if ( StringLen(dx_order_code) == 0 ) {
         if ( _price > 0 == false ) {
            return false; //-- only attach valid sl/tp
         }
         string order_code = (string)GetTickCount64();
         string json_body = "{" + 
                                 "\"account\":\"" + account + "\"," +
                                 "\"orderCode\":\"" + order_code + "\"," +   
                                 "\"type\":\"" + _type + "\"," +    
                                 "\"instrument\":\"" + _instrument + "\"," +                               
                                 "\"positionEffect\":\"" + "CLOSE" + "\"," + 
                                 "\"positionCode\":\"" + dx_position_id + "\"," +                               
                                 "\"side\":\"" + _side + "\",";
                                 if ( _type == "STOP" ) {                                 
                                    json_body = json_body + "\"stopPrice\":" + (string)_price + ",";
                                    info = "DXtrade added stoploss " + (string)_price + " on position " + (string)dx_position_id;
                                 }
                                 else if ( _type == "LIMIT" ) {  
                                    json_body = json_body + "\"limitPrice\":" + (string)_price + ",";
                                    info = "DXtrade added takeprofit " + (string)_price + " on position " + (string)dx_position_id;
                                 }  
                                 json_body = json_body + "\"tif\":\"" + "GTC" + "\"" +
                           "}";                                         
         string result_headers;
         char post_chars[], result_chars[];
         StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
         //CMyUtil::Info("DXtrade modify(post) order request -> ", json_body);
         ResetLastError();
         int http_code = WebRequest("POST", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
         string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
         if ( http_code == 200 ) {         
            CMyUtil::GlobalVarSetValue(global_var_modify, order_code); 
            CMyUtil::Info(info, " successfully -> ", response); 
            return true;   
         } else {
            LogError("add_sl/tp_position_" + (string)dx_position_id, http_code, response);
         }   
         return false; 
      } else {
         string order_code = dx_order_code;
         if ( _price > 0 ) {
            string json_body = "{" + 
                                    "\"account\":\"" + account + "\"," +
                                    "\"orderCode\":\"" + order_code + "\"," +   
                                    "\"instrument\":\"" + _instrument + "\"," +                               
                                    "\"positionEffect\":\"" + "CLOSE" + "\"," + 
                                    "\"positionCode\":\"" + (string)dx_position_id + "\"," +                               
                                    "\"side\":\"" + _side + "\",";
                                    if ( _type == "STOP" ) {                                 
                                       json_body = json_body + "\"stopPrice\":" + (string)_price + ",";                                    
                                       info = "DXtrade modified position " + (string)dx_position_id + " with stoploss " + (string)_price;
                                    }
                                    else if ( _type == "LIMIT" ) {                                      
                                       json_body = json_body + "\"limitPrice\":" + (string)_price + ",";
                                       info = "DXtrade modified position " + (string)dx_position_id + " with takeprofit " + (string)_price;
                                    }  
                                    json_body = json_body + "\"tif\":\"" + "GTC" + "\"" +
                              "}";                                         
            string result_headers;
            char post_chars[], result_chars[];
            StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
            //CMyUtil::Info("DXtrade modify(put) order request -> ", json_body);
            ResetLastError();
            int http_code = WebRequest("PUT", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
            string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
            if ( http_code == 200 ) {         
               CMyUtil::GlobalVarSetValue(global_var_modify, order_code);
               CMyUtil::Info(info, " successfully -> ", response);
               return true;   
            } else {
               LogError("modify_sl/tp_position_" + (string)dx_position_id, http_code, response);
            }   
            return false;
         } else {
            url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/accounts/" + account + "/orders/" + (string)order_code;            
            if ( _type == "STOP" ) {                               
               info = "DXtrade removed stoploss on position " + (string)dx_position_id;
            }
            else if ( _type == "LIMIT" ) {  
               info = "DXtrade removed takeprofit on position " + (string)dx_position_id;
            }             
            string result_headers;
            char post_chars[], result_chars[];
            StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
            //CMyUtil::Info("DXtrade modify(put) order request -> ", json_body);
            ResetLastError();
            int http_code = WebRequest("DELETE", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
            string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
            if ( http_code == 200 ) {         
               CMyUtil::GlobalVarDelete(global_var_modify);
               CMyUtil::Info(info, " successfully -> ", response);                                                
               return true;   
            } else {
               LogError("remove_sl/tp_position_" + (string)dx_position_id, http_code, response);
            }   
            return false;            
         }      
      }
   }             
   
   bool PostLogin() {      
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/login";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\n";
      string json_body =   "{" + 
                              "\"username\":\"" + Algo1_DXtradeLoginUser + "\"," +
                              "\"domain\":\"" + MY_TAG_DEFAULT + "\"," +
                              "\"password\":\"" + Algo1_DXtradeLoginPassword + "\"" +
                           "}";
      string result_headers;
      char post_chars[], result_chars[];
      StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
      ResetLastError();
      int http_code = WebRequest("POST", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
      if ( http_code == 200 ) {                  
         CMyUtil::Info("DXtrade user ",  Algo1_DXtradeLoginUser, " logged in successfully -> ", response);  
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(response);
         this.m_session_token = json_node["sessionToken"].ToString();
         MqlDateTime mqlDT;
         TimeToStruct(StringToTime(json_node["timeout"].ToString()), mqlDT);
         this.m_session_timeout = PeriodSeconds(PERIOD_M1) * (mqlDT.min - 3);  
         delete json_node; json_node = NULL;        
         return true;   
      } else {
         LogError("login_user_" + Algo1_DXtradeLoginUser, http_code, response);
      }
      return false;
   }
   
   bool PostPing1() {      
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/ping";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI " + this.m_session_token + "\r\n";
      string json_body = "";
      string result_headers;
      char post_chars[], result_chars[];
      StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
      ResetLastError();
      int http_code = WebRequest("POST", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
      if ( http_code == 200 ) { 
         CMyUtil::Info("DXtrade session ",  this.m_session_token, " updated successfully -> ", response);  
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(response);
         this.m_session_token = json_node["sessionToken"].ToString();
         MqlDateTime mqlDT;
         TimeToStruct(StringToTime(json_node["timeout"].ToString()), mqlDT);
         this.m_session_timeout = PeriodSeconds(PERIOD_M1) * (mqlDT.min - 2);  
         delete json_node; json_node = NULL;        
         return true;   
      } else {
         LogError("ping", http_code, response);
         PostLogin();
      }   
      return false;
   }  
   
   bool GetMetrics() {      
      string account =  MY_TAG_DEFAULT + ":" + Algo1_DXtradeAccountNumber;
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/accounts/" + account + "/metrics?include-positions=false";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI " + this.m_session_token + "\r\n";
      string json_body = "";
      string result_headers;
      char post_chars[], result_chars[];
      StringToCharArray(json_body, post_chars, 0, StringLen(json_body));
      ResetLastError();
      int http_code = WebRequest("GET", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
      if ( http_code == 200 ) {         
         CMyUtil::Info("DXtrade account ",  Algo1_DXtradeAccountNumber, " metrics read successfully -> ", response); 
         JSONNode *json_node = new JSONNode();
         json_node.Deserialize(response);         
         this.m_dxtrade_balance = json_node["metrics"][0]["balance"].ToDouble();               
         delete json_node; json_node = NULL;
         return true;   
      } else {
         LogError("metrics", http_code, response);
         PostLogin();
      }   
      return false;
   }
   
   bool PostNewOrder(long _mt_position_id, string _instrument, double _quantity, string _side) {
      for( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, "Opening new position."); }            
         bool succeded = _PostNewOrderX(_mt_position_id, _instrument, _quantity, _side);
         if ( succeded ) {               
               return true;
         } else {               
         }
      }  
      return false;  
   }
   
   bool PostCloseOrder(long _mt_position_id, string _instrument, string _side) {
      for( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, "Closing existing position."); }            
         bool succeded = _PostCloseOrderX(_mt_position_id, _instrument, _side);
         if ( succeded ) {               
               return true;
         } else {               
         }
      }  
      return false;     
   } 
   
   bool PostLogout() {   
      string url = Algo1_DXtradeServerBaseUrl + MY_DXTRADE_API + "/logout";
      string post_headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI " + this.m_session_token + "\r\n";
      string json_body = "";
      string result_headers;
      char post_chars[], result_chars[];
      StringToCharArray(json_body, post_chars, 0, StringLen(json_body));      
      ResetLastError();
      int http_code = WebRequest("POST", url, post_headers, MY_POST_TIMEOUT, post_chars, result_chars, result_headers);
      string response = CharArrayToString(result_chars, 0, WHOLE_ARRAY);
      if ( http_code == 200 ) {         
         CMyUtil::Info("DXtrade user ",  Algo1_DXtradeLoginUser, " logged out successfully -> ", response);                  
         return true;   
      } else {
         //LogError("logout", http_code, response);
      }   
      return false; 
   }          
         
public:   
  
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_Magic; 
      this.TimerSeconds = 1620; 
      this.RiskMultiplier = Algo1_RiskMultiplier; 
      //--- initialize algo specific variables  
      m_global_var_running = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT, "RUN");
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) > 0 ){
         MessageBox("Already running on another chart !\r\nNo need to add this Expert again on the same account.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }   
      CMyUtil::GlobalVarSetValue(m_global_var_running, "1"); 
      if ( PostLogin() == false ) {
         MessageBox("Unauthorized access to DXtrade account !\r\nCheck the login details provided in the Inputs.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }
      if ( GetMetrics() == false ) {
         MessageBox("Unable find DXtrade account metrics !\r\nCheck the login details provided in the Inputs.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }      
      this.DisplayInfo = "DXtradeSender" + (string)this.RobotId;
      return (INIT_SUCCEEDED);
   }
   
   void Update() { 
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) == 0 ){
         CMyUtil::GlobalVarSetValue(m_global_var_running, "1");     
      }  
      datetime current_time = TimeCurrent();
      //Update session token
      static datetime var_last_ping = current_time;
      if ((current_time - var_last_ping) >= this.m_session_timeout ) {
         var_last_ping = current_time;
         //PostPing();  
         //CMyUtil::XSleep(MY_POST_TIMEOUT);        
         GetMetrics(); 
      }             
   }   
      
   void Stop() {    
      PostLogout();  
      CMyUtil::GlobalVarDelete(m_global_var_running);      
   }

   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {  
         
      if ( _request.action == TRADE_ACTION_SLTP && _result.retcode == TRADE_RETCODE_DONE) { 
         ResetLastError(); 
         CPositionInfo positionInfo; 
         if (_request.position > 0 && positionInfo.SelectByTicket(_request.position)) { 
            bool valid = this.ValidateSignal(positionInfo.Symbol(), (string)positionInfo.Magic());  
            if ( Algo1_UseCopyingStopTake && valid ) {     
               ulong position_id = _request.position;
               string instrument = this.CalcOrderInstrument(positionInfo.Symbol());
               string side = this.CalcOrderSide(CMyUtil::GetPositionDirection(positionInfo.PositionType()));            
               string op_side = this.CalcOrderOppositeSide(side);   
               this.PostModifyOrder(position_id, instrument, op_side, "LIMIT", positionInfo.TakeProfit());
               CMyUtil::XSleep(MY_SLEEP_TIME);      
               this.PostModifyOrder(position_id, instrument, op_side, "STOP", positionInfo.StopLoss());
            }
         }
      }       
      if ( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ulong xdeal_ticket = _transaction.deal;  
         ENUM_DEAL_ENTRY xdeal_entry = NULL; 
         long position_id = -1, xdeal_magic = -1;  
         string xdeal_symbol = NULL, xdeal_type = NULL, xdeal_comment = NULL;
         double xdeal_price = -1, xdeal_volume = -1, xdeal_sl = -1, xdeal_tp = -1;
         if ( HistoryDealSelect(xdeal_ticket) ) {
            xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
            position_id = HistoryDealGetInteger(xdeal_ticket, DEAL_POSITION_ID);            
            xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);            
            xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);
            xdeal_price = HistoryDealGetDouble(xdeal_ticket, DEAL_PRICE);
            xdeal_type = CMyUtil::GetDealDirection((ENUM_DEAL_TYPE)HistoryDealGetInteger(xdeal_ticket,DEAL_TYPE));
            xdeal_volume = HistoryDealGetDouble(xdeal_ticket, DEAL_VOLUME);
            xdeal_sl = HistoryDealGetDouble(xdeal_ticket, DEAL_SL);
            xdeal_tp = HistoryDealGetDouble(xdeal_ticket, DEAL_TP);
            xdeal_comment = HistoryDealGetString(xdeal_ticket, DEAL_COMMENT); 
         } 
         if ( position_id > 0 ) {
            bool valid = this.ValidateSignal(xdeal_symbol, (string)xdeal_magic);
            string instrument = this.CalcOrderInstrument(xdeal_symbol);
            double quantity = this.CalcOrderQuantity(xdeal_symbol, xdeal_volume, AccountInfoDouble(ACCOUNT_BALANCE), this.m_dxtrade_balance);
            string side = this.CalcOrderSide(xdeal_type);  
            if ( valid && xdeal_entry == DEAL_ENTRY_IN ) {
               bool done = this.PostNewOrder(position_id, instrument, quantity, side);  
               if ( done ) {  
                  string op_side = this.CalcOrderOppositeSide(side);  
                  if ( Algo1_UseCopyingStopTake && xdeal_tp > 0 ) { 
                     CMyUtil::XSleep(MY_SLEEP_TIME);                 
                     this.PostModifyOrder(position_id, instrument, op_side, "LIMIT", xdeal_tp);
                  }   
                  if ( Algo1_UseCopyingStopTake && xdeal_sl > 0 ) { 
                     CMyUtil::XSleep(MY_SLEEP_TIME);
                     this.PostModifyOrder(position_id, instrument, op_side, "STOP", xdeal_sl);
                  }                                  
               }
            }
            if ( valid && xdeal_entry == DEAL_ENTRY_OUT ) {
               this.PostCloseOrder(position_id, instrument, side);  
            }    
         }         
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
