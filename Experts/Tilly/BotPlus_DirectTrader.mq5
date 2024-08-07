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
#property description "BotPlus_DirectTrader"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

string   Robot_Name                             = "BotPlus_DirectTrader"; // Robot Name
string   Robot_LicenseKey                       = "XXXX"; // License Key

input group    "..........................................................................."

enum EAlgo
{
   ALGO_MONITORING   =  844,
   ALGO_TRADING      =  855  
};

input EAlgo    Algo1_Algo                             = ALGO_MONITORING;  // Algorithm
input double   Algo1_RiskPercentage                   = 0.1;   // Risk Percentage; ex: 0.5 = 0.5%
input string   Algo1_Comment                          = "";    // Comment; Box description is used if this is empty
input double   Algo1_RewardMultiplier                 = 2.0;   // Takeprofit multiplier; 0.0 -> No take profit level

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

class CMyRobotImpl : public CMyRobot {

private:
   
   string   m_symbol;
   long     m_chartId, m_box_long_count, m_box_short_count;
   string   mCommonPrefix, mBoxPrefix, mIdButtonLong, mIdButtonShort, mIdButtonDelete;
   
   void SetSymbolProperties() { 
      //this.m_symbol_custom = Symbol();
      this.m_symbol = CMyUtil::CurrentSymbol();      
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      this.MaximumSpreadPointCount = spread_points > 2 ? spread_points*5 : 10;
      int leverage = CMyUtil::LeverageAllowedForSymbol(m_symbol);
      CMyUtil::Info(m_symbol, " leverage=", (string)leverage,  " max_spread=", (string)MaximumSpreadPointCount);      
   } 
   
   void CreateAlgoButtons() {    
      if ( Algo1_Algo == ALGO_MONITORING ) { return; }     
          
      CMyUtil::CreateWidgetButton(m_chartId, mIdButtonLong, 260, 55, false, 50, 20, clrLightSeaGreen, "Long");
      CMyUtil::CreateWidgetButton(m_chartId, mIdButtonDelete, 330, 55, false, 60, 20, clrDarkGray, "Delete *");
      CMyUtil::CreateWidgetButton(m_chartId, mIdButtonShort, 410, 55, false, 50, 20, clrLightSalmon, "Short");  
   }
   
   void DrawBox(string _direction) {
      //CMyUtil::Debug(__FUNCTION__, " for trading ", pTradeDirection); 
      datetime time1 = iTime(m_symbol, PERIOD_CURRENT, 30); datetime time2 = iTime(m_symbol, PERIOD_CURRENT, 15);      
      int spread_points = (int)SymbolInfoInteger(this.m_symbol, SYMBOL_SPREAD);    
      double distance_sl = CMyUtil::ToPointDecimal(m_symbol, spread_points*15);
      
      double price1, price2;      
      long box_count;
      color border_color;  
      if (_direction == DEFINE_TRADE_DIR_LONG) {
         box_count = ++m_box_long_count;
         border_color = clrLightSeaGreen;   
         price1 = SymbolInfoDouble(m_symbol, SYMBOL_ASK);     
         price2 = price1 - distance_sl;  
      } else {
         box_count = ++m_box_short_count;
         border_color = clrLightSalmon; 
         price1 = SymbolInfoDouble(m_symbol, SYMBOL_BID); 
         price2 = price1 + distance_sl;       
      }       
      string str1 = (string)box_count + "_" + _direction;
      string text = "box_" + str1;
      string obj_name = mBoxPrefix + str1;
      obj_name = obj_name + "+"; //-- to stop opening a trade until this flag '+' gets removed by the trader
      if (ObjectFind(m_chartId, obj_name) < 0) { 
         price1 = CMyUtil::NormalizePrice(m_symbol, price1);
         price2 = CMyUtil::NormalizePrice(m_symbol, price2);
         ObjectCreate(m_chartId, obj_name, OBJ_RECTANGLE, 0, time1, price1, time2, price2); 
         ObjectSetString(m_chartId, obj_name, OBJPROP_TEXT, text); ObjectSetString(m_chartId, obj_name, OBJPROP_TOOLTIP, text);  
         ObjectSetInteger(m_chartId, obj_name, OBJPROP_HIDDEN, false); ObjectSetInteger(m_chartId, obj_name, OBJPROP_BACK, false);  
         ObjectSetInteger(m_chartId, obj_name, OBJPROP_SELECTABLE, true); ObjectSetInteger(m_chartId, obj_name, OBJPROP_SELECTED, true); 
         ObjectSetInteger(m_chartId, obj_name, OBJPROP_COLOR, border_color); ObjectSetInteger(m_chartId, obj_name, OBJPROP_ZORDER, 10); 
         ObjectSetInteger(m_chartId, obj_name, OBJPROP_WIDTH, 2);       
      }
   }
   
   void ShowQuantity(string _obj_name, double _price_open, double _price_stop) {
      double capital = AccountInfoDouble(ACCOUNT_BALANCE);      
      double lots_array[];
      CMyUtil::CalculateUnitSize(m_symbol, capital, Algo1_RiskPercentage, _price_open, _price_stop, lots_array);
      if (ObjectFind(m_chartId, _obj_name) >= 0) {
         string text = ObjectGetString(m_chartId, _obj_name, OBJPROP_TEXT);
         int find_index = StringFind(text, "@lots=");
         string desc = find_index >= 0 ? StringSubstr(text, 0, find_index) : text;
         text = ArraySize(lots_array) > 0 ? desc + "@lots=" + (string)lots_array[0] : desc;
         ObjectSetString(m_chartId, _obj_name, OBJPROP_TEXT, text); ObjectSetString(m_chartId, _obj_name, OBJPROP_TOOLTIP, text);  
      }
   }
   
   string GetTradeComment(string _text) {
      string comment = "";
      string input_text = CMyUtil::NormalizeComment(_text);
      string input_comment = CMyUtil::NormalizeComment(Algo1_Comment);
      if (StringLen(input_comment) == 0 && StringLen(input_text) > 0) {
         comment = CMyUtil::ParseComment(input_text);         
      } else if (StringLen(input_comment) > 0) {
         comment = input_comment;         
      }
      return comment;
   }
   
   bool CheckBoxCrossed(double _crossvalue) {   
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      double obj_price = StringToDouble(DoubleToString(_crossvalue, digits));            
      double open_price = StringToDouble(DoubleToString(iOpen(NULL,0,0), digits));
      double now_price = StringToDouble(DoubleToString(iClose(NULL,0,0), digits));
      return (open_price<=obj_price && now_price>obj_price) || (open_price>obj_price && now_price<=obj_price);  
   }   
   
   void DirectTrading() {   
      if ( Algo1_Algo == ALGO_MONITORING ) { return; }   
      for (int x = 0; x < ObjectsTotal(m_chartId, 0, OBJ_RECTANGLE); x++) {
         string obj_name = ObjectName(m_chartId, x, 0, OBJ_RECTANGLE);
         int find_index = StringFind(obj_name, mBoxPrefix);
         if (find_index < 0) {
            continue;
         }
         //-- found a setup
         bool is_valid = false;
         double p0, p1, price_open, price_sl;
         p0 = ObjectGetDouble(m_chartId, obj_name, OBJPROP_PRICE, 0);
         p1 = ObjectGetDouble(m_chartId, obj_name, OBJPROP_PRICE, 1);          
         find_index = StringFind(obj_name, "_" + DEFINE_TRADE_DIR_LONG);
         string name_suffix = find_index >= 0 ? StringSubstr(obj_name, find_index) : "";
         if (name_suffix == "_" + DEFINE_TRADE_DIR_LONG) {         
            is_valid = true;
            price_open = p0 > p1 ? p0 : p1;
            price_sl = p0 > p1 ? p1 : p0; 
            ShowQuantity(obj_name, price_open, price_sl);
            if (CheckBoxCrossed(price_open)) {  
               int sl_points = CMyUtil::ToPointsCount(m_symbol, MathAbs(price_open - price_sl));  
               int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
               string comment = GetTradeComment(ObjectGetString(m_chartId, obj_name, OBJPROP_TEXT));
               string signal = "c=open plus=mt m=" + m_symbol + " d=" + DEFINE_TRADE_DIR_LONG + " q=" + (string)Algo1_RiskPercentage + 
                  "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + comment;
               this.AddSignal(signal);
               ObjectDelete(m_chartId, obj_name); ChartRedraw();  
            }  
         }
         find_index = StringFind(obj_name, "_" + DEFINE_TRADE_DIR_SHORT);
         name_suffix = find_index >= 0 ? StringSubstr(obj_name, find_index) : "";
         if (name_suffix == "_" + DEFINE_TRADE_DIR_SHORT) {      
            is_valid = true;
            price_open = p0 < p1 ? p0 : p1;
            price_sl = p0 < p1 ? p1 : p0;  
            ShowQuantity(obj_name, price_open, price_sl);
            if (CheckBoxCrossed(price_open)) {
               int sl_points = CMyUtil::ToPointsCount(m_symbol, MathAbs(price_open - price_sl));  
               int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
               string comment = GetTradeComment(ObjectGetString(m_chartId, obj_name, OBJPROP_TEXT));
               string signal = "c=open plus=mt m=" + m_symbol + " d=" + DEFINE_TRADE_DIR_SHORT + " q=" + (string)Algo1_RiskPercentage + 
                  "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + comment;               
               this.AddSignal(signal);
               ObjectDelete(m_chartId, obj_name); ChartRedraw();  
            } 
         }      
         if (is_valid == false) {
            CMyUtil::Info(obj_name, " is ignored as the name ends with '+'");
         }  
      }               
   }
   
   void MonitorTrades() {
      if ( Algo1_Algo == ALGO_TRADING ) { return; }  
      
      ulong xtickets_position[];        
      CMyUtil::PositionTickets("", "", "", "", "", xtickets_position); 
      CPositionInfo xposition_info;
      for ( int k= 0; k < ArraySize(xtickets_position); k++ ) {
         if ( xposition_info.SelectByTicket(xtickets_position[k]) == false ) continue;  
         MqlTick mql_tick; 
         SymbolInfoTick(xposition_info.Symbol(), mql_tick);   
         bool ok_close = false;
         if ( CMyUtil::GetPositionDirection(xposition_info.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
            if ( xposition_info.StopLoss() > 0 && mql_tick.bid <  xposition_info.StopLoss() ) {
               ok_close = true;
            }
            if ( xposition_info.TakeProfit() > 0 && mql_tick.bid >  xposition_info.TakeProfit() ) {
               ok_close = true;
            }               
         } else {
            if ( xposition_info.StopLoss() > 0 && mql_tick.ask >  xposition_info.StopLoss() ) {
               ok_close = true;
            }
            if ( xposition_info.TakeProfit() > 0 && mql_tick.ask <  xposition_info.TakeProfit() ) {
               ok_close = true;
            }                 
         } 
         
         if ( ok_close ) {
            string message = "monitor on '" + AccountInfoString(ACCOUNT_COMPANY) + "' account=" + (string)AccountInfoInteger(ACCOUNT_LOGIN) +
               " attempts to close the " + xposition_info.Symbol() + " position=" + (string)xtickets_position[k] +
               " comment=" + xposition_info.Comment() + " which missed to hit SL/TP level";
            CMyUtil::Warn(message);
            SendNotification(message);
            string signal = "c=close m=" + xposition_info.Symbol() + " ticket=" + (string)xtickets_position[k] + " plus=mt";
            this.AddSignal(signal);
         }
                      
      }  
      
      CMyUtil::FlagTerminalLostConnection(60*10);       
      
   }

public:   
  
   int Start() {  
      //--- initialize common configuration
      this.RobotId = Algo1_Algo;       
      if ( Algo1_Algo == ALGO_TRADING ) {
         this.TimerSeconds = 3;
      }
      else if ( Algo1_Algo == ALGO_MONITORING ) {
         this.TimerSeconds = 300;
      } 
      SetSymbolProperties();     
      //--- initialize algo specific variables  
      m_chartId = ChartID();
      m_box_long_count = 0; m_box_short_count = 0;
      mCommonPrefix = "@" + Robot_Name + "_"; 
      mBoxPrefix = mCommonPrefix + "box_";
      mIdButtonLong = mCommonPrefix + "APP_BTN_LONG";
      mIdButtonShort = mCommonPrefix + "APP_BTN_SHORT";
      mIdButtonDelete = mCommonPrefix + "APP_BTN_DELETE";
      CreateAlgoButtons();  
      this.DisplayInfo = "DirectTrader" + (string)this.RobotId + ":" + EnumToString(Algo1_Algo); 
      return (INIT_SUCCEEDED);
   }

   void Update() {         
      DirectTrading();  
      MonitorTrades();  
   }
      
   void Stop() {      
   }
   
   void OnChartEventHandler(const int _id, const long& _lparam, const double& _dparam, const string& _sparam) {
      //CMyUtil::Info("CHARTEVENT_ID: ", _id, " ", _lparam, " ", _dparam, " ", _sparam);
      if( Algo1_Algo == ALGO_MONITORING ) { return; } 
      if ( _id == CHARTEVENT_OBJECT_CLICK ) {
         if (_sparam == mIdButtonLong) {
            DrawBox(DEFINE_TRADE_DIR_LONG); ChartRedraw();              
         }  
         else if (_sparam == mIdButtonShort) {
            DrawBox(DEFINE_TRADE_DIR_SHORT); ChartRedraw();             
         } 
         else if (_sparam == mIdButtonDelete) {
            m_box_long_count = 0; m_box_short_count = 0;
            ObjectsDeleteAll(m_chartId, mBoxPrefix); ChartRedraw();           
         }                          
      }       
   }
   
   void OnTradeTransactionHandler(const MqlTradeTransaction& _transaction, const MqlTradeRequest& _request, const MqlTradeResult& _result) { 
      if( Algo1_Algo == ALGO_TRADING ) { return; }
      
      if( _transaction.type == TRADE_TRANSACTION_DEAL_ADD ) {
         ResetLastError(); 
         ulong xdeal_ticket = _transaction.deal;        
         if(HistoryDealSelect(xdeal_ticket)) {
            string xdeal_symbol = HistoryDealGetString(xdeal_ticket, DEAL_SYMBOL);
            long xdeal_magic = HistoryDealGetInteger(xdeal_ticket, DEAL_MAGIC);            
            ENUM_DEAL_ENTRY xdeal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(xdeal_ticket, DEAL_ENTRY);
              
            if ( xdeal_entry == DEAL_ENTRY_IN ) {             
            } else if ( xdeal_entry == DEAL_ENTRY_OUT ) {
               if ( xdeal_magic < 1 ) {
                  string message = "monitor on '" + AccountInfoString(ACCOUNT_COMPANY) + "' account=" + (string)AccountInfoInteger(ACCOUNT_LOGIN) +
                     " found unverified closing of " + xdeal_symbol + " position=" + (string)xdeal_ticket +
                     " by manual/broker intervention";
                  CMyUtil::Warn(message);
                  SendNotification(message);                  
               }               
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

void OnChartEvent(const int _id, const long& _lparam, const double& _dparam, const string& _sparam) { 
   robot.OnChartEventHandler(_id, _lparam, _dparam, _sparam);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////