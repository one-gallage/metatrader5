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
#property description "BotPlus_CopyMT5Sender"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_CopyMT5Sender"; // Robot Name
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

input ushort   Algo1_SenderServicePort                = 12600;       // Sender service port


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>
#include <Tilly/tilly_socket_library.mqh>

#define  MY_GLOBAL_VAR_GROUP_ROOT   "MT5SENDER"

class CMyRobotImpl : public CMyRobot {

private:
   
   ServerSocket * m_server_socket;
   ClientSocket * m_receivers[];
   string         m_global_var_running;
   
   string CalcPriceDistance(string _market, double _price_open, double _price_other) {
      double distance = 0;      
      if ( _price_other > 0 ) {
         distance = MathAbs(_price_open - _price_other);
         distance = CMyUtil::NormalizePrice(_market, distance);
         return (string)distance + "t";
      } 
      return "0";
   }
   
    string CalcOrderQuantity(string _direction, string _market, double _lots, double _price_enter, double _price_exit) { 
      string str_qty;      
      if ( _price_exit > 0 ) {
         ENUM_ORDER_TYPE order_type = _direction == DEFINE_TRADE_DIR_LONG ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         double profit;
         bool ok = OrderCalcProfit(order_type, _market, _lots, _price_enter, _price_exit, profit);
         if ( ok ) {
            double risk =  (MathAbs(profit)/AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
            risk = NormalizeDouble(risk, 2);
            str_qty = ((string)risk) + "%";
         } else {
            str_qty = (string)_lots;
         }
      } 
      else {
         str_qty = (string)_lots;
      } 
      return str_qty;    
   }  
   
   void AcceptNewConnections() {     
      //--- Keep accepting any pending connections until Accept() returns NULL  
      ClientSocket * client;    
      do {      
         client = m_server_socket.Accept();
         if (client != NULL) {
            int arr_length = ArraySize(m_receivers);
            ArrayResize(m_receivers, arr_length + 1);
            m_receivers[arr_length] = client;
            //CMyUtil::Debug("TradeCopy_Sender connects to new Receiver ", (string)(arr_length + 1));    
            client.Send("Hello\r\n");
         }         
      } while (client != NULL);
   } 

   void SendToReceivers(string _signal) {    
      //--- Publish signal on each client socket, bearing in mind that SendToReceiver()
      //--- can delete sockets and reduce the size of the array, if a socket has been closed   
      for (int i = ArraySize(m_receivers) - 1; i >= 0; i--) {
         SendToReceiver(i, _signal);
      }  
   }  
   
   void SendToReceiver(int index_receiver, string _signal) {
      ClientSocket * client = m_receivers[index_receiver];
      if(client) {
         bool success = client.Send(_signal+"\r\n");         
         if (success == false) {            
            //--- Client is dead. Destroy the object
            delete client;      
            //--- And remove from the array
            int arr_length = ArraySize(m_receivers);
            for (int i = index_receiver + 1; i < arr_length; i++) {
               m_receivers[i - 1] = m_receivers[i];
            }
            arr_length--;
            ArrayResize(m_receivers, arr_length);
         } else {
            //CMyUtil::Debug("Successfully send the signal to Receiver ",(string)index_receiver);
         }
      }   
   }  
      
public:   
  
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_SenderServicePort; 
      this.TimerSeconds = 27;
      //--- initialize algo specific variables  
      if (m_server_socket) {
         Stop();
      } 
      m_global_var_running = CMyUtil::GlobalVarName(MY_GLOBAL_VAR_GROUP_ROOT, "RUN");
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) > 0 ){
         MessageBox("Already running on another chart !\r\nNo need to add this Expert again on the same account.", __FILE__, MB_OK);    
         return (INIT_FAILED);
      }   
      CMyUtil::GlobalVarSetValue(m_global_var_running, "1");         
      //--- Create the server socket
      m_server_socket = new ServerSocket(Algo1_SenderServicePort, true);
      if (m_server_socket.Created()) {
         CMyUtil::Info("Service started on port ", (string)Algo1_SenderServicePort);                  
      } else {
         MessageBox("Service failed to start on port " + (string)Algo1_SenderServicePort + ".\r\nChange the service port as it may already in use !", __FILE__, MB_OK);
         return (INIT_FAILED);
      }
      this.DisplayInfo = "Sender service on port: " + (string)Algo1_SenderServicePort;   
      return (INIT_SUCCEEDED);
   }
   
   void Update() { 
      if ( StringLen(CMyUtil::GlobalVarGetValue(m_global_var_running)) == 0 ){
         CMyUtil::GlobalVarSetValue(m_global_var_running, "1");     
      }    
      AcceptNewConnections();      
   }   
      
   void Stop() {      
      CMyUtil::GlobalVarDelete(m_global_var_running);
      //--- Delete all clients currently connected
      for (int i = 0; i < ArraySize(m_receivers); i++) {
         delete m_receivers[i];
      }
      ArrayResize(m_receivers, 0);      
      //--- Free the server socket. *VERY* important, or else the port number remains in use and un-reusable until MT4/5 is shut down
      delete m_server_socket; m_server_socket = NULL;       
   }

   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) {  
         
      if ( _request.action == TRADE_ACTION_SLTP && _result.retcode == TRADE_RETCODE_DONE) { 
         ResetLastError(); 
         CPositionInfo positionInfo; 
         if (_request.position > 0 && positionInfo.SelectByTicket(_request.position)) {
            string direction = CMyUtil::GetPositionDirection(positionInfo.PositionType());
            MqlTick mql_tick;
            SymbolInfoTick(positionInfo.Symbol(), mql_tick); 
            double curr_price = direction == DEFINE_TRADE_DIR_LONG ? mql_tick.ask : mql_tick.bid;     
            string signal =   DEFINE_SIGNAL_OPTION_COMMAND + "=" + DEFINE_SIGNAL_COMMAND_MODIFY + " " +        
                              DEFINE_SIGNAL_OPTION_PLUS + "=" + DEFINE_ROBOT_PLUS_CODE + " " +                              
                              DEFINE_SIGNAL_OPTION_MAGIC + "=" + (string)positionInfo.Magic() + " " +
                              DEFINE_SIGNAL_OPTION_TICKET + "=" + (string)_request.position + " " +
                              DEFINE_SIGNAL_OPTION_MARKET + "=" + positionInfo.Symbol() + " " +
                              DEFINE_SIGNAL_OPTION_DIRECTION + "=" + direction + " " +
                              DEFINE_SIGNAL_OPTION_STOPLOSS + "=" + CalcPriceDistance(positionInfo.Symbol(), curr_price, positionInfo.StopLoss()) + " " +
                              DEFINE_SIGNAL_OPTION_TAKEPROFIT + "=" + CalcPriceDistance(positionInfo.Symbol(), curr_price, positionInfo.TakeProfit()) + " ";
            CMyUtil::Info("Sends modify signal -> ", signal);
            SendToReceivers(signal);
         }
      } 
      
      if ( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ulong xdeal_ticket = _transaction.deal;  
         ENUM_DEAL_ENTRY xdeal_entry = NULL; 
         long position_id = -1, xdeal_magic = -1;  
         string xdeal_symbol = NULL, xdeal_direction = NULL, xdeal_comment = NULL;
         double xdeal_price = -1, xdeal_volume = -1, xdeal_sl = -1, xdeal_tp = -1;
         if ( HistoryDealSelect(xdeal_ticket) ) {
            xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
            position_id = HistoryDealGetInteger(xdeal_ticket, DEAL_POSITION_ID);            
            xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);            
            xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);
            xdeal_price = HistoryDealGetDouble(xdeal_ticket, DEAL_PRICE);
            xdeal_direction = CMyUtil::GetDealDirection((ENUM_DEAL_TYPE)HistoryDealGetInteger(xdeal_ticket,DEAL_TYPE));
            xdeal_volume = HistoryDealGetDouble(xdeal_ticket, DEAL_VOLUME);
            xdeal_sl = HistoryDealGetDouble(xdeal_ticket, DEAL_SL);
            xdeal_tp = HistoryDealGetDouble(xdeal_ticket, DEAL_TP);
            xdeal_comment = HistoryDealGetString(xdeal_ticket, DEAL_COMMENT); 
         } 
         if ( position_id > 0 ) {
            if ( xdeal_entry == DEAL_ENTRY_IN ) {
               string str_qty = CalcOrderQuantity(xdeal_direction, xdeal_symbol, xdeal_volume, xdeal_price, xdeal_sl);
               string signal =   DEFINE_SIGNAL_OPTION_COMMAND + "=" + DEFINE_SIGNAL_COMMAND_OPEN + " " +      
                                 DEFINE_SIGNAL_OPTION_PLUS + "=" + DEFINE_ROBOT_PLUS_CODE + " " +                                 
                                 DEFINE_SIGNAL_OPTION_MAGIC + "=" + (string)xdeal_magic + " " +
                                 DEFINE_SIGNAL_OPTION_BALANCE + "=" + (string)AccountInfoDouble(ACCOUNT_BALANCE) + " " +
                                 DEFINE_SIGNAL_OPTION_QUANTITY + "=" + str_qty + " " +
                                 DEFINE_SIGNAL_OPTION_TICKET + "=" + (string)position_id + " " +
                                 DEFINE_SIGNAL_OPTION_MARKET + "=" + xdeal_symbol + " " +                                 
                                 DEFINE_SIGNAL_OPTION_DIRECTION + "=" + xdeal_direction + " " +                                 
                                 DEFINE_SIGNAL_OPTION_STOPLOSS + "=" + CalcPriceDistance(xdeal_symbol, xdeal_price, xdeal_sl) + " " +
                                 DEFINE_SIGNAL_OPTION_TAKEPROFIT + "=" + CalcPriceDistance(xdeal_symbol, xdeal_price, xdeal_tp) + " " +
                                 DEFINE_SIGNAL_OPTION_REFERENCE + "=" + CMyUtil::NormalizeComment(xdeal_comment) + " ";
               CMyUtil::Info("Sends open signal -> ", signal);
               SendToReceivers(signal);                              
            }
            if ( xdeal_entry == DEAL_ENTRY_OUT ) {
               xdeal_direction = xdeal_direction == DEFINE_TRADE_DIR_LONG ? DEFINE_TRADE_DIR_SHORT : xdeal_direction == DEFINE_TRADE_DIR_SHORT ? 
                                                            DEFINE_TRADE_DIR_LONG : xdeal_direction;
               string signal =   DEFINE_SIGNAL_OPTION_COMMAND + "=" + DEFINE_SIGNAL_COMMAND_CLOSE + " " + 
                                 DEFINE_SIGNAL_OPTION_PLUS + "=" + DEFINE_ROBOT_PLUS_CODE + " " +                                 
                                 DEFINE_SIGNAL_OPTION_MAGIC + "=" + (string)xdeal_magic + " " +
                                 DEFINE_SIGNAL_OPTION_TICKET + "=" + (string)position_id + " " +
                                 DEFINE_SIGNAL_OPTION_MARKET + "=" + xdeal_symbol + " " +                                 
                                 DEFINE_SIGNAL_OPTION_DIRECTION + "=" + xdeal_direction + " ";
               CMyUtil::Info("Sends close signal -> ", signal);
               SendToReceivers(signal);     
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
