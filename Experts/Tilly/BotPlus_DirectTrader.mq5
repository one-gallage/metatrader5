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

string   Bot_Name                               = "BotPlus_DirectTrader"; // Bot Name
string   Bot_LicenseKey                         = "XXXX"; // License Key

input group    "..........................................................................."

enum EAlgo
{
   ALGO_MONITORING   =  1,
   ALGO_TRADING      =  2  
};

input EAlgo    Algo1_Algo                             = ALGO_MONITORING;  // Algorithm
input uint     Algo1_Magic                            = 0;     // ALGO_TRADING Magic
input double   Algo1_RiskPercentage                   = 0.1;   // Risk Percentage; ex: 0.5 = 0.5%
input string   Algo1_Comment                          = "";    // Comment; Box description is used if this is empty
input double   Algo1_RewardMultiplier                 = 2.0;   // Takeprofit multiplier; 0.0 -> No take profit level

input group    "..........................................................................."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly/tilly_framework.mqh>

class CMyBotImpl : public CMyBot {

private:
   long     m_botid;
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
   
   void ShowQuantity(string _obj_name, string _direction, double _price_open, double _price_stop) {
      double capital = AccountInfoDouble(ACCOUNT_BALANCE);      
      double lots = CMyUtil::CalculateUnitSize(m_symbol, _direction, capital, Algo1_RiskPercentage, _price_open, _price_stop);
      if (ObjectFind(m_chartId, _obj_name) >= 0) {
         string text = ObjectGetString(m_chartId, _obj_name, OBJPROP_TEXT);
         int find_index = StringFind(text, "@lots=");
         string desc = find_index >= 0 ? StringSubstr(text, 0, find_index) : text;
         text = desc + "@lots=" + (string)lots;
         ObjectSetString(m_chartId, _obj_name, OBJPROP_TEXT, text); ObjectSetString(m_chartId, _obj_name, OBJPROP_TOOLTIP, text);  
      }
   }
   
   string MakeComment(string _text) {
      string xcomment = "";
      if (StringLen(Algo1_Comment) > 0) {
         xcomment = Algo1_Comment;        
      } else if (StringLen(_text) > 0) {
         xcomment = _text;         
      }
      xcomment = CMyUtil::ParseComment(xcomment);
      return CMyUtil::XStringReplaceCharSpace(xcomment);
   }
   
   bool CheckBoxCrossed(double _crossvalue) {   
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      double obj_price = StringToDouble(DoubleToString(_crossvalue, digits));            
      double open_price = StringToDouble(DoubleToString(iOpen(NULL,0,0), digits));
      double now_price = StringToDouble(DoubleToString(iClose(NULL,0,0), digits));
      return (open_price<=obj_price && now_price>obj_price) || (open_price>obj_price && now_price<=obj_price);  
   }   
   
   void Trading() {   
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
            ShowQuantity(obj_name, DEFINE_TRADE_DIR_LONG, price_open, price_sl);
            if (CheckBoxCrossed(price_open)) {  
               int sl_points = CMyUtil::ToPointsCount(m_symbol, MathAbs(price_open - price_sl));  
               int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
               string xcomment = MakeComment(ObjectGetString(m_chartId, obj_name, OBJPROP_TEXT));
               string signal = "c=open m=" + CMyUtil::XStringReplaceCharSpace(m_symbol) + " d=" + DEFINE_TRADE_DIR_LONG +
                  " q=" + (string)Algo1_RiskPercentage + "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + xcomment + 
                  " magic=" + (string)m_botid + " plus=mt";
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
            ShowQuantity(obj_name, DEFINE_TRADE_DIR_SHORT,price_open, price_sl);
            if (CheckBoxCrossed(price_open)) {
               int sl_points = CMyUtil::ToPointsCount(m_symbol, MathAbs(price_open - price_sl));  
               int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
               string xcomment = MakeComment(ObjectGetString(m_chartId, obj_name, OBJPROP_TEXT));
               string signal = "c=open m=" + CMyUtil::XStringReplaceCharSpace(m_symbol) + " d=" + DEFINE_TRADE_DIR_SHORT + 
                  " q=" + (string)Algo1_RiskPercentage + "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + xcomment + 
                  " magic=" + (string)m_botid + " plus=mt";             
               this.AddSignal(signal);
               ObjectDelete(m_chartId, obj_name); ChartRedraw();  
            } 
         }      
         if (is_valid == false) {
            CMyUtil::Info(obj_name, " is ignored as the name ends with '+'");
         }  
      }               
   }
   
   void Monitoring() {
      if ( Algo1_Algo == ALGO_TRADING ) { return; }  
      
      ulong curr_tickets[];        
      CMyUtil::PositionTickets("", "", "", "", "", curr_tickets); 
      CPositionInfo curr_position;
      for ( int k= 0; k < ArraySize(curr_tickets); k++ ) {
         if ( curr_position.SelectByTicket(curr_tickets[k]) == false ) continue;  
         MqlTick mql_tick; 
         SymbolInfoTick(curr_position.Symbol(), mql_tick);   
         bool ok_close = false;
         if ( CMyUtil::GetPositionDirection(curr_position.PositionType()) == DEFINE_TRADE_DIR_LONG ) {
            if ( curr_position.StopLoss() > 0 && mql_tick.bid <  curr_position.StopLoss() ) {
               ok_close = true;
            }
            if ( curr_position.TakeProfit() > 0 && mql_tick.bid >  curr_position.TakeProfit() ) {
               ok_close = true;
            }               
         } else {
            if ( curr_position.StopLoss() > 0 && mql_tick.ask >  curr_position.StopLoss() ) {
               ok_close = true;
            }
            if ( curr_position.TakeProfit() > 0 && mql_tick.ask <  curr_position.TakeProfit() ) {
               ok_close = true;
            }                 
         } 
                  
         if ( ok_close ) {
            string message = "monitor on '" + AccountInfoString(ACCOUNT_COMPANY) + "' account=" + (string)AccountInfoInteger(ACCOUNT_LOGIN) +
               " attempts to close the " + curr_position.Symbol() + " position=" + (string)curr_tickets[k] +
               " comment=" + curr_position.Comment() + " which missed to hit SL/TP level";
            CMyUtil::Warn(message);
            SendNotification(message);
            string signal = "c=close m=" + CMyUtil::XStringReplaceCharSpace(curr_position.Symbol()) + 
               " ticket=" + (string)curr_tickets[k] + " magic=" + (string)curr_position.Magic() + " plus=mt";
            this.AddSignal(signal);
         }
                      
      }  
      
      CMyUtil::FlagTerminalLostConnection(60*10);       
      
   }

public:   
  
   int Start() {  
      //--- initialize common configuration  
      if ( Algo1_Algo == ALGO_TRADING ) {
         this.TimerMilliSeconds = 4*1000;
      }
      else if ( Algo1_Algo == ALGO_MONITORING ) {
         this.TimerMilliSeconds = 36*1000;
      } 
      m_botid = Algo1_Magic;
      SetSymbolProperties();     
      //--- initialize algo specific variables  
      m_chartId = ChartID();
      m_box_long_count = 0; m_box_short_count = 0;
      mCommonPrefix = "@" + Bot_Name + "_"; 
      mBoxPrefix = mCommonPrefix + "box_";
      mIdButtonLong = mCommonPrefix + "APP_BTN_LONG";
      mIdButtonShort = mCommonPrefix + "APP_BTN_SHORT";
      mIdButtonDelete = mCommonPrefix + "APP_BTN_DELETE";
      CreateAlgoButtons();  
      this.DisplayInfo = "DirectTrader" + ":" + EnumToString(Algo1_Algo); 
      return (INIT_SUCCEEDED);
   }

   void Update() {         
      Trading();  
      Monitoring();  
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

CMyBotImpl robot;

int OnInit()
{ 
   return robot.OnInitHandler(Bot_Name, Bot_LicenseKey);
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