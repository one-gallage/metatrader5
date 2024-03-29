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
#property description "Bot_GLX1_OneTrader"
#property description "© ErangaGallage"
#property strict


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <Tilly\tilly_framework.mqh>

class CAlgoSuper : public CMyAlgo {

private:
   
   string   mSymbol;
   long     mChartId, mBoxLongCount, mBoxShortCount;
   string   mCommonPrefix, mBoxPrefix, mIdButtonLong, mIdButtonShort, mIdButtonDelete;
   
   void SetSymbolName() {
      this.mSymbol = CMyUtil::CurrentSymbol();
   }
      
   void SetMaximumSpread() { 
      int spread_points = (int)SymbolInfoInteger(this.mSymbol, SYMBOL_SPREAD);    
      this.MaximumSpreadPointCount = spread_points*3;
   }
   
   void CreateAlgoButtons() {    
      CMyUtil::CreateWidgetButton(mChartId, mIdButtonLong, 260, 55, true, 50, 20, clrLightSeaGreen, "Long");
      CMyUtil::CreateWidgetButton(mChartId, mIdButtonDelete, 330, 55, true, 60, 20, clrDarkGray, "Delete *");
      CMyUtil::CreateWidgetButton(mChartId, mIdButtonShort, 410, 55, true, 50, 20, clrLightSalmon, "Short");      
   }
   
   void DrawBox(string pTradeDirection) {
      CMyUtil::Debug(__FUNCTION__, " for trading ", pTradeDirection); 
      datetime time1 = iTime(mSymbol, PERIOD_CURRENT, 30); datetime time2 = iTime(mSymbol, PERIOD_CURRENT, 15);      
      SetMaximumSpread();
      int spread_points = (int)SymbolInfoInteger(this.mSymbol, SYMBOL_SPREAD);    
      double distance_sl = CMyUtil::ToPointDecimal(mSymbol, spread_points*15);
      
      double price1, price2;      
      long box_count;
      color border_color;  
      if (pTradeDirection == DEFINE_TRADE_DIR_LONG) {
         box_count = ++mBoxLongCount;
         border_color = clrLightSeaGreen;   
         price1 = SymbolInfoDouble(mSymbol, SYMBOL_ASK);     
         price2 = price1 - distance_sl;  
      } else {
         box_count = ++mBoxShortCount;
         border_color = clrLightSalmon; 
         price1 = SymbolInfoDouble(mSymbol, SYMBOL_BID); 
         price2 = price1 + distance_sl;       
      }       
      string str1 = (string)box_count + "_" + pTradeDirection;
      string text = "box_" + str1;
      string obj_name = mBoxPrefix + str1;
      obj_name = obj_name + "+"; //-- to stop opening a trade until this flag '+' gets removed by the trader
      if (ObjectFind(mChartId, obj_name) < 0) { 
         price1 = CMyUtil::NormalizePrice(mSymbol, price1);
         price2 = CMyUtil::NormalizePrice(mSymbol, price2);
         ObjectCreate(mChartId, obj_name, OBJ_RECTANGLE, 0, time1, price1, time2, price2); 
         ObjectSetString(mChartId, obj_name, OBJPROP_TEXT, text); ObjectSetString(mChartId, obj_name, OBJPROP_TOOLTIP, text);  
         ObjectSetInteger(mChartId, obj_name, OBJPROP_HIDDEN, false); ObjectSetInteger(mChartId, obj_name, OBJPROP_BACK, false);  
         ObjectSetInteger(mChartId, obj_name, OBJPROP_SELECTABLE, true); ObjectSetInteger(mChartId, obj_name, OBJPROP_SELECTED, true); 
         ObjectSetInteger(mChartId, obj_name, OBJPROP_COLOR, border_color); ObjectSetInteger(mChartId, obj_name, OBJPROP_ZORDER, 10); 
         ObjectSetInteger(mChartId, obj_name, OBJPROP_WIDTH, 2);       
      }
   }
   
   void ShowQuantity(string pObjName, int pStoplossPoints) {
      double capital = AccountInfoDouble(ACCOUNT_BALANCE);      
      double lots_array[];
      CMyUtil::CalculateUnitSize(mSymbol, capital, Algo1_RiskPercentage, pStoplossPoints, "", lots_array);
      if (ObjectFind(mChartId, pObjName) >= 0) {
         string text = ObjectGetString(mChartId, pObjName, OBJPROP_TEXT);
         int find_index = StringFind(text, "@[");
         string desc = find_index >= 0 ? StringSubstr(text, 0, find_index) : text;
         text = ArraySize(lots_array) > 0 ? desc + "@[" + (string)lots_array[0] + "]" : desc;
         ObjectSetString(mChartId, pObjName, OBJPROP_TEXT, text); ObjectSetString(mChartId, pObjName, OBJPROP_TOOLTIP, text);  
      }
   }
   
   string GetTradeComment(string pText) {
      string comment = "";
      string input_text = CMyUtil::NormalizeComment(pText);
      string input_comment = CMyUtil::NormalizeComment(Algo1_TradeComment);
      if (StringLen(input_comment) == 0 && StringLen(input_text) > 0) {
         comment = input_text;         
      } else if (StringLen(input_comment) > 0) {
         comment = input_comment;         
      }
      return comment;
   }
   
   bool CheckBoxCrossed(double pCrossValue) {   
      int digits = (int)SymbolInfoInteger(mSymbol, SYMBOL_DIGITS);
      double obj_price = StringToDouble(DoubleToString(pCrossValue, digits));            
      double open_price = StringToDouble(DoubleToString(iOpen(NULL,0,0), digits));
      double now_price = StringToDouble(DoubleToString(iClose(NULL,0,0), digits));
      return (open_price<=obj_price && now_price>obj_price) || (open_price>obj_price && now_price<=obj_price);  
   }   
   
   void AnalyseTrading() {      
      for (int x = 0; x < ObjectsTotal(mChartId, 0, OBJ_RECTANGLE); x++) {
         string obj_name = ObjectName(mChartId, x, 0, OBJ_RECTANGLE);
         int find_index = StringFind(obj_name, mBoxPrefix);
         if (find_index < 0) {
            continue;
         }
         //-- found a setup
         bool is_valid = false;
         double p0, p1, price_open, price_sl;
         p0 = ObjectGetDouble(mChartId, obj_name, OBJPROP_PRICE, 0);
         p1 = ObjectGetDouble(mChartId, obj_name, OBJPROP_PRICE, 1);    
         int sl_points = CMyUtil::ToPointsCount(mSymbol, MathAbs(p0 - p1));     
         ShowQuantity(obj_name, sl_points);
         find_index = StringFind(obj_name, "_" + DEFINE_TRADE_DIR_LONG);
         string name_suffix = find_index >= 0 ? StringSubstr(obj_name, find_index) : "";
         if (name_suffix == "_" + DEFINE_TRADE_DIR_LONG) {         
            is_valid = true;
            price_open = p0 > p1 ? p0 : p1;
            price_sl = p0 > p1 ? p1 : p0; 
            if (CheckBoxCrossed(price_open)) {  
               int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
               string comment = GetTradeComment(ObjectGetString(mChartId, obj_name, OBJPROP_TEXT));
               string signal = "open plus=mt m=" + mSymbol + " d=" + DEFINE_TRADE_DIR_LONG + " q=" + (string)Algo1_RiskPercentage + 
                  "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + comment;
               this.AddSignal(signal);
               ObjectDelete(mChartId, obj_name); ChartRedraw();  
            }  
         }
         find_index = StringFind(obj_name, "_" + DEFINE_TRADE_DIR_SHORT);
         name_suffix = find_index >= 0 ? StringSubstr(obj_name, find_index) : "";
         if (name_suffix == "_" + DEFINE_TRADE_DIR_SHORT) {      
            is_valid = true;
            price_open = p0 < p1 ? p0 : p1;
            price_sl = p0 < p1 ? p1 : p0;  
            if (CheckBoxCrossed(price_open)) {
               int tp_points = (int)MathCeil(MathAbs(sl_points * Algo1_RewardMultiplier));
               string comment = GetTradeComment(ObjectGetString(mChartId, obj_name, OBJPROP_TEXT));
               string signal = "open plus=mt m=" + mSymbol + " d=" + DEFINE_TRADE_DIR_SHORT + " q=" + (string)Algo1_RiskPercentage + 
                  "% sl=" + (string)sl_points + " tp=" + (string)tp_points + " ref=" + comment;               
               this.AddSignal(signal);
               ObjectDelete(mChartId, obj_name); ChartRedraw();  
            } 
         }      
         if (is_valid == false) {
            CMyUtil::Info(obj_name, " is ignored as the name ends with '+'");
         }  
      } 
      this.DisplayInfo = "*********";              
   }

public:   
  
   int OnStartAlgo() {  
      //--- initialize common configuration
      this.AlgoId = Algo1_Magic;
      //--- initialize algo specific variables  
      this.SetSymbolName();
      int leverage = CMyUtil::LeverageAllowedForSymbol(mSymbol);
      CMyUtil::Info(mSymbol, " leverage=", (string)leverage);       
      this.SetMaximumSpread();        
      mChartId = ChartID();
      mBoxLongCount = 0; mBoxShortCount = 0;
      mCommonPrefix = "@" + Robot_Name + "_"; 
      mBoxPrefix = mCommonPrefix + "box_";
      mIdButtonLong = mCommonPrefix + "APP_BTN_LONG";
      mIdButtonShort = mCommonPrefix + "APP_BTN_SHORT";
      mIdButtonDelete = mCommonPrefix + "APP_BTN_DELETE";
      CreateAlgoButtons();  
      return (INIT_SUCCEEDED);
   }

   void OnUpdateAlgo() {         
      AnalyseTrading();    
   }
      
   void OnStopAlgo() {      
   }
   
   void OnChartEventAlgo(const int id, const long& lparam, const double& dparam, const string& sparam) {  
      //CMyUtil::Debug("CHARTEVENT_ID: ", id, " ", lparam, " ", dparam, " ", sparam);
      if (id == CHARTEVENT_OBJECT_CLICK) {
         if (sparam == mIdButtonLong) {
            DrawBox(DEFINE_TRADE_DIR_LONG); ChartRedraw();              
         }  
         else if (sparam == mIdButtonShort) {
            DrawBox(DEFINE_TRADE_DIR_SHORT); ChartRedraw();             
         } 
         else if (sparam == mIdButtonDelete) {
            mBoxLongCount = 0; mBoxShortCount = 0;
            ObjectsDeleteAll(mChartId, mBoxPrefix); ChartRedraw();           
         }                          
      } else if (id == CHARTEVENT_OBJECT_DRAG) {
         //CMyUtil::Debug("CHARTEVENT_OBJECT_DRAG ", lparam, " ", dparam, " ", sparam);
      }       
   }
   
   void OnTradeTransactionAlgo(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
       //CMyUtil::Info("OnTradeTransaction event ", (string)transac.deal);   
   }   

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    "*** Settings of Bot_GLX1_OneTrader © ErangaGallage ***"
input group    "---------------------------------------------------"
input uint     Algo1_Magic                            = 777;   // Magic Number
input double   Algo1_RiskPercentage                   = 0.1;   // Risk Percentage; ex: 0.5 = 0.5%
input string   Algo1_TradeComment                     = "";    // Trade Comment; The box description is used if this is empty
input double   Algo1_RewardMultiplier                 = 2.0;   // Take profit multiplier; 0.0 -> No take profit level

input group    "---------------------------------------------------"
string         Robot_Name                             = "Bot_GLX1_OneTrader"; // Robot Name
int            Robot_TimerSeconds                     = 5; // Robot Timer Seconds
string         Robot_LicenseKey                       = "XXXX"; // License Key

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

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {  
   mAlgo.OnChartEventAlgo(id, lparam, dparam, sparam);     
}

void OnTradeTransaction(const MqlTradeTransaction& transac, const MqlTradeRequest& request, const MqlTradeResult& result) {                        
   mAlgo.OnTradeTransactionAlgo(transac, request, result);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
