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

#property version   "1.00"
#property description "tilly_framework"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//| Framework implementation start                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Tilly\tilly_json.mqh>

//+------------------------------------------------------------------+
//| Defines                                                          |
//+------------------------------------------------------------------+

#define DEFINE_DEBUG                               false
#define DEFINE_ROBOT_ENFORCE_LICENSE               false
#define DEFINE_ROBOT_PLUS_CODE                     "mt"
#define DEFINE_ROBOT_TESTER_HIDE_INDICATORS        false

#define DEFINE_TRADE_RETRY_COUNT                   3
#define DEFINE_TRADE_WAIT_TIME                     15000
#define DEFINE_TRADE_DIR_LONG                      "long"
#define DEFINE_TRADE_DIR_SHORT                     "short"

#define DEFINE_SIGNAL_COMMAND_OPEN                 "open"
#define DEFINE_SIGNAL_COMMAND_MODIFY               "modify"
#define DEFINE_SIGNAL_COMMAND_CLOSE                "close"
#define DEFINE_SIGNAL_COMMAND_DELETE               "delete"
#define DEFINE_SIGNAL_OPTION_COMMAND               "c"
#define DEFINE_SIGNAL_OPTION_PLUS                  "plus"
#define DEFINE_SIGNAL_OPTION_MARKET                "m"
#define DEFINE_SIGNAL_OPTION_QUANTITY              "q"
#define DEFINE_SIGNAL_OPTION_DIRECTION             "d"
#define DEFINE_SIGNAL_OPTION_REFERENCE             "ref"
#define DEFINE_SIGNAL_OPTION_PRICEOPEN             "po"
#define DEFINE_SIGNAL_OPTION_STOPLOSS              "sl"
#define DEFINE_SIGNAL_OPTION_TAKEPROFIT            "tp"
#define DEFINE_SIGNAL_OPTION_EXPIRY                "exp"
#define DEFINE_SIGNAL_OPTION_ACCOUNT               "account"
#define DEFINE_SIGNAL_OPTION_TICKET                "ticket"
#define DEFINE_SIGNAL_OPTION_MAGIC                 "magic"
#define DEFINE_SIGNAL_OPTION_BALANCE               "balance"
#define DEFINE_SIGNAL_OPTION_GLOBALVAR_GROUP       "gvargroup"

//+------------------------------------------------------------------+
//| Classes                                                          |
//+------------------------------------------------------------------+


class CMyUtil {

protected:

   virtual void  _Name() = NULL;   // A pure virtual function to make this class abstract

public:

   static void Info(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "",
                   string p11 = "", string p12 = "", string p13 = "", string p14 = "", string p15 = "", string p16 = "", string p17 = "", string p18 = "", string p19 = "", string p20 = "",
                   string p21 = "", string p22 = "", string p23 = "", string p24 = "", string p25 = "", string p26 = "", string p27 = "", string p28 = "", string p29 = "", string p30 = ""
                   ) {
      Print(" --INFO-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20,
                          p21, p22, p23, p24, p25, p26, p27, p28, p29, p30);
   }
   
   static void Error(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "",
                   string p11 = "", string p12 = "", string p13 = "", string p14 = "", string p15 = "", string p16 = "", string p17 = "", string p18 = "", string p19 = "", string p20 = "",
                   string p21 = "", string p22 = "", string p23 = "", string p24 = "", string p25 = "", string p26 = "", string p27 = "", string p28 = "", string p29 = "", string p30 = ""
                   ) {
      Print(" --ERROR-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20,
                          p21, p22, p23, p24, p25, p26, p27, p28, p29, p30);
   }   
   
   static void Debug(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "",
                   string p11 = "", string p12 = "", string p13 = "", string p14 = "", string p15 = "", string p16 = "", string p17 = "", string p18 = "", string p19 = "", string p20 = "",
                   string p21 = "", string p22 = "", string p23 = "", string p24 = "", string p25 = "", string p26 = "", string p27 = "", string p28 = "", string p29 = "", string p30 = ""
                   ) {
      if ( DEFINE_DEBUG ) {
         Print(" --DEBUG-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20,
                          p21, p22, p23, p24, p25, p26, p27, p28, p29, p30);               
      }
   } 

   static void XSleep(int pMilliseconds, string pNextAction="") {
      Sleep(pMilliseconds);
      Info("Sleep(", (string)pMilliseconds, ") done. ", pNextAction);
   }
   
   static bool IsTesting() {
      if ( (bool)MQLInfoInteger(MQL_DEBUG) || (bool)MQLInfoInteger(MQL_PROFILER) || (bool)MQLInfoInteger(MQL_TESTER) ||
           (bool)MQLInfoInteger(MQL_FORWARD) || (bool)MQLInfoInteger(MQL_OPTIMIZATION) || (bool)MQLInfoInteger(MQL_VISUAL_MODE) || 
           (bool)MQLInfoInteger(MQL_FRAME_MODE) ) {
         return true;
      }   
      return false;
   }

   static double _NormalizeDouble(double pValue, int pDigits) {
      double d = NormalizeDouble(pValue, pDigits);
      return StringToDouble(DoubleToString(d, pDigits));
   }

   static double NormalizePrice(string pMarket, double pPrice) {
      int udigits = (int)SymbolInfoInteger(pMarket, SYMBOL_DIGITS);     
      return _NormalizeDouble(pPrice, udigits); 
   }

   static double NormalizeLots(string pMarket, double pLots) {       
      double lotstep   = SymbolInfoDouble(pMarket, SYMBOL_VOLUME_STEP);
      int lotdigits    = (int) - MathLog10(lotstep);
      return _NormalizeDouble(pLots, lotdigits);   
   } 
   
   static string NormalizeComment(string pText) {
      string comment = "";
      string input_comment = pText;
      StringTrimRight(input_comment); StringTrimLeft(input_comment);      
      if (StringLen(input_comment) > 0) {
         StringReplace(input_comment, " ", "_");
         StringReplace(input_comment, "\t", "_");
         StringReplace(input_comment, "\r\n", "_");
         StringReplace(input_comment, "\n", "_");      
         comment = input_comment;         
      }
      return comment;
   }
   
   static bool RefreshRates(string pMarket){
      MqlTick mql_tick;
      return SymbolInfoTick(pMarket, mql_tick); //-- refresh rates
   }     

   static double ToPointDecimal(string pMarket, uint pPointsCount) {
      int udigits = (int)SymbolInfoInteger(pMarket, SYMBOL_DIGITS);
      double upointDecimal = SymbolInfoDouble(pMarket, SYMBOL_POINT);
      return _NormalizeDouble(upointDecimal * pPointsCount, udigits);
   }

   static int ToPointsCount(string pMarket, double pDecimalValue) {
      double upointDecimal = SymbolInfoDouble(pMarket, SYMBOL_POINT);
      return (int)((1 / upointDecimal) * pDecimalValue);
   }

   static int ToTicksCount(string pMarket, uint pPointsCount) {
      /* https://forum.mql4.com/43064#515262 for non-currency DE30:
      SymbolInfoDouble(chart.symbol, SYMBOL_TRADE_TICK_SIZE) returns 0.5
      SymbolInfoInteger(chart.symbol,SYMBOL_DIGITS) returns 1
      SymbolInfoInteger(chart.symbol,SYMBOL_POINT) returns 0.1
      Prices to open must be a multiple of ticksize */
      double uticksize = SymbolInfoDouble(pMarket, SYMBOL_TRADE_TICK_SIZE);
      //--- make tick count increments of uticksize
      int utickscount = uticksize > 0 ? (int)((pPointsCount / uticksize) * uticksize) : 0; 
      //Info("SYMBOL_TRADE_TICK_SIZE=", (string)SYMBOL_TRADE_TICK_SIZE, " ticks count=", (string)utickscount);
      return utickscount;
   }

   static bool CheckValidLicense(string pLicensekey) {
      string xLicensekey = pLicensekey;
      StringTrimLeft(xLicensekey);
      StringTrimRight(xLicensekey);

      int licensekeyLength = StringLen(xLicensekey);

      string masterKey = "CNAT";
      int masterKeyLength = StringLen(masterKey);
      string inMasterKey = StringSubstr(xLicensekey, 0, masterKeyLength);

      bool okMasterKey = inMasterKey == "CNAT" ? true : (inMasterKey == "GARA" ? true : false);

      if(okMasterKey == false) {
         return (false);
      }

      string accountNo = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
      int accountNoLength = StringLen(accountNo);
      string inAccountNo = StringSubstr(xLicensekey, (masterKeyLength + 1), accountNoLength);

      if(accountNo != inAccountNo) {
         return (false);
      }
      return (true);
   }
   
   static string CurrentSymbol() {
      string m_symbol_custom = Symbol();
      string m_symbol = m_symbol_custom;
      int len = StringLen(m_symbol_custom);
      int index = StringFind(m_symbol_custom,"_RENKO_");
      if (len > 0 && index >= 0) {
         m_symbol = StringSubstr(m_symbol_custom, 0, index);
         //Debug("Chart's custom_symbol=", m_symbol_custom, " origin_symbol=", m_symbol);
      }     
      return m_symbol;
   }    

   static datetime _GetBarTime( const datetime pTime, const bool pNextBar = false, string pMarket = NULL, const ENUM_TIMEFRAMES pTimeFrame = PERIOD_M1 ) {
      return (iTime(pMarket, pTimeFrame, iBarShift(pMarket, pTimeFrame, pTime) - (pNextBar ? 1 : 0)));
   }

   static datetime _GetTimeDayOfWeek( const int pShift = 0, const ENUM_DAY_OF_WEEK pDay = SUNDAY ) {
      int week = 7;
      int daySeconds = PeriodSeconds(PERIOD_D1);
      const datetime res = (TimeCurrent() / daySeconds) * daySeconds;
      MqlDateTime mqlDT;
      TimeToStruct(res, mqlDT);
      return (res - (((week + (mqlDT.day_of_week - pDay)) % week) + pShift * week) * daySeconds);
   }

   static int _GetTimeDifferenceGMTFromServer() {
      if(IsTesting()) {
         return 0;
      }
      int daySeconds = PeriodSeconds(PERIOD_D1);
      int hourSeconds = PeriodSeconds(PERIOD_H1);
      const datetime sunday = _GetTimeDayOfWeek();
      return (((int)MathRound((double)MathMin(sunday - daySeconds - _GetBarTime(sunday), sunday + daySeconds - _GetBarTime(sunday, true)) / hourSeconds) - 3) * hourSeconds);
   }

   static datetime TimeServerGMT() {
      datetime dt = (TimeCurrent() + _GetTimeDifferenceGMTFromServer());
      return dt;
   }

   static bool CheckMarketSessionTime(double pStartTimeGMT, double pEndTimeGMT) {
      //    London         8.00  to 17.00          Frankfurt      7.00  to 16.00
      //    Newyork        13.00 to 22.00          Chicago        14.00 to 23.00
      //    Sydney         22.00 to 7.00           Tokyo          0.00  to 9.00
      bool ok = false;
      MqlDateTime mqlDT;
      TimeToStruct(TimeServerGMT(), mqlDT);
      double _decimalTime = StringToDouble((string)mqlDT.hour + "." + (string)mqlDT.min); // GMT server time as a decimal value   
      if(pStartTimeGMT < pEndTimeGMT) {
         if(_decimalTime >= pStartTimeGMT && _decimalTime <= pEndTimeGMT) { ok = true; }
      }
      if(pStartTimeGMT >= pEndTimeGMT) {
         if(_decimalTime >= pStartTimeGMT || _decimalTime <= pEndTimeGMT) { ok = true; }
      }
      return (ok);
   }
  
   static bool CheckMarketOpen(string pSymbol) {
      long lastM1_time = SeriesInfoInteger(pSymbol,PERIOD_M1,SERIES_LASTBAR_DATE);
      long server_time = (long)TimeTradeServer();        
      if ( MathAbs(server_time-lastM1_time) > 1000 ) {         
         Debug(__FUNCTION__, "() last_M1_open_time=", (string)lastM1_time, " server_time=", (string)server_time);
         return false;
      }
      return true;
   }   

   static string CurrentMarketSession(string pSymbol) {
      string mSession = "";     
      if ( CheckMarketOpen(pSymbol) ) {
         CheckMarketSessionTime(22.00, 7.00) ? StringConcatenate(mSession, mSession, "Sydney ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(0.00, 9.00) ? StringConcatenate(mSession, mSession, "Tokyo ") : StringConcatenate(mSession, mSession, "");         
         CheckMarketSessionTime(8.00, 17.00) ? StringConcatenate(mSession, mSession, "London ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(13.00, 22.00) ? StringConcatenate(mSession, mSession, "Newyork ") : StringConcatenate(mSession, mSession, "");         
      } else {
         mSession = "Market seems to be closed";
         ChartRedraw();
      }  
      return mSession;
   }
   
   static string CurrentMarketSession() {
      return CurrentMarketSession(CurrentSymbol());
   } 

   static bool CheckTradingDay(bool pWeekEnds, bool pNFP_Friday, bool pNFP_ThursdayBefore, bool pChristmasHolidays, int pXMAS_DayBeginBreak, bool pNewYearsHolidays, int pNewYears_DayEndBreak) {
      bool _ok = true;
      MqlDateTime mqlDT;
      TimeToStruct(TimeCurrent(), mqlDT);
      int _dayOfWeek = mqlDT.day_of_week;
      int _date = mqlDT.day;
      int _month = mqlDT.mon;

      if((_dayOfWeek == 6 || _dayOfWeek == 0) && pWeekEnds == false) {
         _ok = false;   // no trading on Saturdays and Sundays
      }
      if(_dayOfWeek == 5 && _date < 8 && pNFP_Friday == false) {
         _ok = false;
      }
      if(_dayOfWeek == 4 && _date < 8 && pNFP_ThursdayBefore == false) {
         _ok = false;
      }
      if(_month == 12 && _date > pXMAS_DayBeginBreak && pChristmasHolidays == false) {
         _ok = false;
      }
      if(_month == 1 && _date < pNewYears_DayEndBreak && pNewYearsHolidays == false) {
         _ok = false;
      }

      return (_ok);
   }
   
   static string GlobalVarName(string _group, string _key) {
      return  "G." + _group + "@" + _key;
   }

   static void GlobalVarSetValue(string _name, string _value) {
      GlobalVarDelete(_name);
      string global_name = _name + "#" + _value;
      GlobalVariableSet(global_name, AccountInfoInteger(ACCOUNT_LOGIN));
      Info("Saving the Global var " , global_name);
   } 
      
   static string GlobalVarGetValue(string _name) {      
      int total_golbal = GlobalVariablesTotal();
      string  value = "", real_name; long real_value;
      int index_name;
      for (int i=0 ; i < total_golbal ; i++) {
         real_name = GlobalVariableName(i);
         real_value = (long)GlobalVariableGet(real_name);         
         if ( AccountInfoInteger(ACCOUNT_LOGIN) != real_value ) {
            continue;
         }
         index_name = StringFind(real_name, _name, 0);         
         if ( index_name >= 0 ) {
            value = StringSubstr(real_name, StringLen(_name) + 1);
            break;
         }
      }  
      return value;
   }  
   
   static void GlobalVarDelete(string _name) { 
      int total_golbal = GlobalVariablesTotal();
      string real_name; long real_value;
      int index_name; bool deleted = false;
      for (int i=0 ; i < total_golbal ; i++) {
         real_name = GlobalVariableName(i);
         real_value = (long)GlobalVariableGet(real_name);
         if ( AccountInfoInteger(ACCOUNT_LOGIN) != real_value ) {
            continue;
         }         
         index_name = StringFind(real_name, _name, 0);
         if ( index_name >= 0 ) {
            deleted = GlobalVariableDel(real_name);
            break;
         }
      }  
      if ( deleted ) {
         Info("Deleting the Global var " , _name);
         GlobalVariablesFlush();
      }     
   }  
   
   static void GlobalVarSearchKeys(string _group, string &_keys[]) {
      int total_golbal = GlobalVariablesTotal();
      string real_name, key_part; long real_value;
      int index_group, index_key, key_length, arr_length;
      ArrayResize(_keys, 0);
      _group = "G." + _group;
      for (int i=0 ; i < total_golbal ; i++) {
         real_name = GlobalVariableName(i);
         real_value = (long)GlobalVariableGet(real_name);
         if ( AccountInfoInteger(ACCOUNT_LOGIN) != real_value ) {
            continue;
         }
         index_group = StringFind(real_name, _group, 0);         
         if ( index_group >= 0 ) {
            index_key = StringFind(real_name, "#", StringLen(_group));
            key_length = index_key - (StringLen(_group) + 1);
            key_part = StringSubstr(real_name, StringLen(_group) + 1, key_length);
                        
            arr_length = ArraySize(_keys);
            ArrayResize(_keys, arr_length+1);
            _keys[arr_length] = key_part;             
         }
      } 
   }    

   static double GetPriceHighest(string pMarket, ENUM_TIMEFRAMES pTimeframe, int pBarCount, int pStartBarIndex = 0, int pExtraPoints = 0) {
      int val_index = iHighest(pMarket, pTimeframe, MODE_HIGH, pBarCount, pStartBarIndex);
      double value = iHigh(pMarket, pTimeframe, val_index);
      value = value + ToPointDecimal(pMarket, pExtraPoints);
      return (value);
   }

   static double GetPriceLowest(string pMarket, ENUM_TIMEFRAMES pTimeframe, int pBarCount, int pStartBarIndex = 0, int pExtraPoints = 0) {
      int val_index = iLowest(pMarket, pTimeframe, MODE_LOW, pBarCount, pStartBarIndex);
      double value = iLow(pMarket, pTimeframe, val_index);
      value = value - ToPointDecimal(pMarket, pExtraPoints);
      return (value);
   }
   
   static int GetATRPointCount(string pMarket, double pValueATR, int pExtraPointCount, double pMultiplier) {
      int atrPoints, totalPoints;            
      atrPoints = (int)(pValueATR * MathPow(10, (int)SymbolInfoInteger(pMarket, SYMBOL_DIGITS)));
      totalPoints = (int)MathCeil(pMultiplier*atrPoints) + pExtraPointCount;   
      return totalPoints;
   } 
   
   static string ArrayToString(double &pArray[], string pDelimitter=",", int pDigits=2) {
      string res="[";
      int itr;
      for(itr=0; itr < ArraySize(pArray); itr++) {
         if ( itr > 0 ) { res += pDelimitter; }
         res += StringFormat("%g",NormalizeDouble(pArray[itr], pDigits));
      } 
      res+= "]";
      return res;
   }      
   
   static double _CurrencyMultiplicator(string pCurrencyPairAppendix = "") {
      double multiplicator = 1.0;
      string xCurrency = AccountInfoString(ACCOUNT_CURRENCY);
      StringToUpper(xCurrency);

      if(xCurrency == "USD")
         return (multiplicator);
      if(xCurrency == "EUR")
         multiplicator = 1.0 / SymbolInfoDouble("EURUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "GBP")
         multiplicator = 1.0 / SymbolInfoDouble("GBPUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "AUD")
         multiplicator = 1.0 / SymbolInfoDouble("AUDUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "NZD")
         multiplicator = 1.0 / SymbolInfoDouble("NZDUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "CHF")
         multiplicator = SymbolInfoDouble("USDCHF" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "JPY")
         multiplicator = SymbolInfoDouble("USDJPY" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "CAD")
         multiplicator = SymbolInfoDouble("USDCAD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(multiplicator == 0)
         multiplicator = 1.0; // If account currency is neither of EUR, GBP, AUD, NZD, CHF, JPY or CAD we assumes that it is USD
      return (multiplicator);
   }

   static double MaxUnitSizeAllowedForMargin(string pMarket, double pMoneyCapital, double pAllowedMaxUnitSize) {
      // Calculate Lot size according to Equity.
      double marginForOneLot, lotsPossible;
      if(OrderCalcMargin(ORDER_TYPE_BUY, pMarket, 1, SymbolInfoDouble(pMarket, SYMBOL_ASK), marginForOneLot)) { // Calculate margin required for 1 lot
         lotsPossible = pMoneyCapital * 0.98 / marginForOneLot;
         lotsPossible = MathMin(lotsPossible, MathMin(pAllowedMaxUnitSize, SymbolInfoDouble(pMarket, SYMBOL_VOLUME_MAX)));
         lotsPossible = NormalizeLots(pMarket, lotsPossible);
      } else {
         lotsPossible = SymbolInfoDouble(pMarket, SYMBOL_VOLUME_MAX);
      }   
      return (lotsPossible);
   }
   
   static int LeverageAllowedForSymbol(const string pSymbol) {  
      int leverage=-1;
      double margin=0.0;
      double lots=1.0;
      
      if(OrderCalcMargin(ORDER_TYPE_BUY,pSymbol,lots,SymbolInfoDouble(pSymbol,SYMBOL_ASK),margin) && margin > 0) {
         double tickValue = SymbolInfoDouble(pSymbol,SYMBOL_TRADE_TICK_VALUE);
         double tickSize = SymbolInfoDouble(pSymbol,SYMBOL_TRADE_TICK_SIZE);
         double lotValue = tickValue * SymbolInfoDouble(pSymbol,SYMBOL_ASK) / tickSize;
         leverage=(int)MathRound(lotValue/margin);
      }      
      return leverage;
   }   

   static void CalculateUnitSize(string pMarket, double pMoneyCapital, double pRiskPercentage, int pStoplossPoints, string pCurrencyPairAppendix, double& lots_array[]) {
      //---Calculate LotSize based on Equity, Risk in decimal and StopLoss in points
      double maxLots, minLots, oneTickValue, moneyRisk, lotsByRisk, lotSize;
      int totalTickCount;
      double allowedMaxUnitSize = SymbolInfoDouble(pMarket, SYMBOL_VOLUME_MAX) + 10;

      maxLots = MaxUnitSizeAllowedForMargin(pMarket, pMoneyCapital, allowedMaxUnitSize);
      minLots = SymbolInfoDouble(pMarket, SYMBOL_VOLUME_MIN);
      oneTickValue = SymbolInfoDouble(pMarket, SYMBOL_TRADE_TICK_VALUE); // Tick value of the asset

      moneyRisk = (pRiskPercentage/100) * pMoneyCapital;
      totalTickCount = ToTicksCount(pMarket, pStoplossPoints);

      //---Calculate the Lot size according to Risk.
      lotsByRisk = moneyRisk / (totalTickCount * oneTickValue);
      lotsByRisk = lotsByRisk * _CurrencyMultiplicator(pCurrencyPairAppendix);
      //Debug("SYMBOL_TRADE_TICK_VALUE=",(string)oneTickValue, " SL Ticks count=", (string)totalTickCount, " Risk=", (string)pRiskPercentage, " Total calculated Lots=", (string)lotsByRisk);
      
      if (lotsByRisk > maxLots) {
         int pos_count = (int)MathRound(lotsByRisk/maxLots);         
         ArrayResize(lots_array, pos_count);
         for (int itr=0; itr<pos_count;itr++) {
            lots_array[itr] = NormalizeLots(pMarket, maxLots);
         }    
         lotSize = NormalizeLots(pMarket, MathMod(lotsByRisk, maxLots));       
         if ( lotSize >= minLots) {
            pos_count++;
            ArrayResize(lots_array, pos_count);
            lots_array[pos_count-1] = NormalizeLots(pMarket, lotSize);
         }     
      }
      else {
         ArrayResize(lots_array, 1);
         lotSize = MathMax(lotsByRisk, minLots);      
         lotSize = NormalizeLots(pMarket, lotSize);
         lots_array[0] = lotSize;
      }
   }
   
   static bool XCopyBuffer(int ind_handle, int buffer_num,int copy_count, bool array_as_series, double& return_array[] )
   {
      ResetLastError();
      ArraySetAsSeries(return_array, array_as_series);
      int cbar_count = CopyBuffer(ind_handle, buffer_num, 0, copy_count, return_array);
      if(cbar_count <= 0) {
         Error("Failed to copy buffer of indicator handle= ", (string)ind_handle, " Error=", IntegerToString(GetLastError())); 
         return (false);
      }   
      return (true);
   }      

   static double MathGetAngle(double pValue1, double pValue2, int pPeriod, double pCoef=1) {
      double zDiff = pValue1 - pValue2;
      double zAngleRad = MathArctan(zDiff / (pCoef * pPeriod));
      double zPI =  3.141592654;
      double zAngleDegrees = (zAngleRad * 180) / zPI;
      return (zAngleDegrees);
   }

   static bool MathCheckEqual(double pValue1, double pValue2, int pDigits) {
      string s1 = DoubleToString(pValue1, pDigits);
      string s2 = DoubleToString(pValue2, pDigits);
      return (s1 == s2);
   }

   static double MathRoundDown(const double pValue, const double pDigits) {
      int norm = (int) MathPow(10, pDigits);
      return(MathFloor(pValue * norm) / norm);
   }

   static double MathRoundBasic(const double pValue, const double pDigits) {
      int norm = (int) MathPow(10, pDigits);
      return(MathRound(pValue * norm) / norm);
   }
   
   static int XStringSplit(string pSource, string pSeparator, string &pArraySplits[]) {
      if (pSource == NULL || StringLen(pSource) == 0) {
         return 0;
      }
      StringTrimLeft(pSource); StringTrimRight(pSource); 
      ushort ushsep = StringGetCharacter(pSeparator, 0);
      ArrayResize(pArraySplits, 0);
      int count = StringSplit(pSource, ushsep, pArraySplits);
      return count;     
   }   
  
   static bool XStringCheckContains(string& _valid_options[], string _option) {
      for (int i = 0; i < ArraySize(_valid_options); i++) {
         if ( StringCompare(_valid_options[i], _option, false) == 0 ) {
            return true;
         }
      }  
      return false;
   }
  
   static void CheckDeinitReason(const int pReason) {
      string text = "";
      switch(pReason) {
      case REASON_PROGRAM:
         text = "the ExpertRemove() function called in the program (REASON_PROGRAM).";
         break;
      case REASON_REMOVE:
         text = "it has been removed from the chart (REASON_REMOVE).";
         break;
      case REASON_RECOMPILE:
         text = "it has been recompiled (REASON_RECOMPILE)."; 
         break;
      case REASON_CHARTCHANGE:
         text = "the symbol or chart period has been changed (REASON_CHARTCHANGE).";
         break;
      case REASON_CHARTCLOSE:
         text = "the chart has been closed (REASON_CHARTCLOSE).";
         break;
      case REASON_PARAMETERS:
         text = "the input parameters has been changed (REASON_PARAMETERS).";
         break;
      case REASON_ACCOUNT:
         text = "the account settings<another account has been activated or reconnection to the trade server> has been changed (REASON_ACCOUNT).";
         break;
      case REASON_TEMPLATE:
         text = "a new template has been applied (REASON_TEMPLATE).";
         break;
      case REASON_INITFAILED:
         text = "it failed the initialization (REASON_INITFAILED).";
         break;
      case REASON_CLOSE:
         text = "the terminal has been closed (REASON_CLOSE).";
         break;
      default:
         text = "an unexpected error occured (" + (string)pReason + ").";
         break;
      }
      Info(MQLInfoString(MQL_PROGRAM_NAME), " terminated ! ", text);
   }
   
   static void _SetWidgetCommonProps(long mChartId, string pObjName, int pX, int pY, bool pBack, int pWidth) {
         ObjectSetInteger(mChartId, pObjName, OBJPROP_HIDDEN, true); 
         ObjectSetInteger(mChartId, pObjName, OBJPROP_BACK, pBack);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_XDISTANCE, pX);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_YDISTANCE, pY);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_WIDTH, 2); // border width    
         ObjectSetInteger(mChartId, pObjName, OBJPROP_XSIZE, pWidth);          
   } 

   static void CreateWidgetRectangleLabel(long mChartId, string pObjName, int pX, int pY, bool pBack, int pWidth, int pHeight, color pBgColor) {
      if(ObjectFind(mChartId, pObjName) < 0) {
         ObjectCreate(mChartId, pObjName, OBJ_RECTANGLE_LABEL, 0, 0, 0) ;
         _SetWidgetCommonProps(mChartId, pObjName, pX, pY, pBack, pWidth);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_YSIZE, pHeight);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_BGCOLOR, pBgColor);
      }               
   }
   
   static void CreateWidgetText(long mChartId,string pObjName, int pX, int pY, bool pBack, int pWidth, string pTooltip, 
               int pFontSize, string pFontName, color pFontColor, string pText) {
      if(ObjectFind(mChartId, pObjName) < 0) {
         ObjectCreate(mChartId, pObjName, OBJ_LABEL, 0, 0, 0) ;
         _SetWidgetCommonProps(mChartId, pObjName, pX, pY, pBack, pWidth);
         ObjectSetString(mChartId, pObjName, OBJPROP_TOOLTIP, pTooltip);         
         ObjectSetInteger(mChartId, pObjName, OBJPROP_FONTSIZE, pFontSize);  
         ObjectSetString(mChartId, pObjName, OBJPROP_FONT, pFontName);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_COLOR, pFontColor);         
         ObjectSetString(mChartId, pObjName, OBJPROP_TEXT, pText);      
      }   
      string current_text = ObjectGetString(mChartId, pObjName, OBJPROP_TEXT);
      if (current_text != pText) {
         ObjectSetString(mChartId, pObjName, OBJPROP_TEXT, pText);   
      }            
   }    
   
   static void CreateWidgetButton(long mChartId,string pObjName, int pX, int pY, bool pBack, int pWidth, int pHeight, color pBgColor, string pText) {
      if(ObjectFind(mChartId, pObjName) < 0) {
         ObjectCreate(mChartId, pObjName, OBJ_BUTTON, 0, 0, 0) ;
         _SetWidgetCommonProps(mChartId, pObjName, pX, pY, pBack, pWidth);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_YSIZE, pHeight);
         ObjectSetInteger(mChartId, pObjName, OBJPROP_BGCOLOR, pBgColor);         
         ObjectSetString(mChartId, pObjName, OBJPROP_TOOLTIP, pText);         
         ObjectSetInteger(mChartId, pObjName, OBJPROP_FONTSIZE, 11);  
         ObjectSetString(mChartId, pObjName, OBJPROP_FONT, "Tahoma");
         ObjectSetInteger(mChartId, pObjName, OBJPROP_COLOR, clrDarkSlateGray); 
         ObjectSetInteger(mChartId, pObjName, OBJPROP_ZORDER, 0); 
      }  
      string current_text = ObjectGetString(mChartId, pObjName, OBJPROP_TEXT);
      if (current_text != pText) {
         ObjectSetString(mChartId, pObjName, OBJPROP_TEXT, pText);   
      }            
   }   
   
   static void FlagTerminalLostConnection(int pIntervalSeconds) {
      if (! (bool)TerminalInfoInteger(TERMINAL_CONNECTED)) {
         static uint lastMsTerminalNotConnected = 0;
         uint currentMs = GetTickCount();
         if ( lastMsTerminalNotConnected == 0) {
            lastMsTerminalNotConnected = currentMs;
         }
         else {
            long diffSeconds= MathAbs(currentMs-lastMsTerminalNotConnected);  
            if ( diffSeconds > (pIntervalSeconds*1000) ) {
               string msg = AccountInfoString(ACCOUNT_COMPANY) + " Terminal lost the server connection at " + 
                              TimeToString(TimeLocal(),TIME_DATE|TIME_MINUTES);
               Error(msg);
               lastMsTerminalNotConnected = 0;
               int f = FileOpen("TERMINAL_NOT_CONNECTED.txt", FILE_WRITE|FILE_COMMON);
               FileWrite(f, msg);
               FileClose(f);
            }
         } 
      } else {
         /*if ( FileIsExist("TERMINAL_NOT_CONNECTED.txt", FILE_COMMON) ) {
            FileDelete("TERMINAL_NOT_CONNECTED.txt", FILE_COMMON);
         }*/
      }
   }
   
   static string GetPositionDirection(ENUM_POSITION_TYPE pPostionType) {
      string str;
      switch ( pPostionType ) {
         case POSITION_TYPE_BUY:
            str = DEFINE_TRADE_DIR_LONG; break;
         case POSITION_TYPE_SELL:
            str = DEFINE_TRADE_DIR_SHORT; break;
         default:
            str = EnumToString(pPostionType); break;
      }
      return (str);
   }
   
   static string GetOrderDirection(ENUM_ORDER_TYPE pOrderType) {
      string str;
      switch ( pOrderType ) {
         case ORDER_TYPE_BUY: case ORDER_TYPE_BUY_LIMIT: case ORDER_TYPE_BUY_STOP: case ORDER_TYPE_BUY_STOP_LIMIT:
            str = DEFINE_TRADE_DIR_LONG; break;
         case ORDER_TYPE_SELL: case ORDER_TYPE_SELL_LIMIT: case ORDER_TYPE_SELL_STOP: case ORDER_TYPE_SELL_STOP_LIMIT:
            str = DEFINE_TRADE_DIR_SHORT; break;
         default :
            str = EnumToString(pOrderType); break;
      }
      return (str);
   } 
   
   static string GetDealDirection(ENUM_DEAL_TYPE pDealType) {
      string str;
      switch ( pDealType ) {
         case DEAL_TYPE_BUY:
            str = DEFINE_TRADE_DIR_LONG; break;
         case DEAL_TYPE_SELL:
            str = DEFINE_TRADE_DIR_SHORT; break;
         default :
            str = EnumToString(pDealType); break;
      }
      return (str);
   }  
   
   static string XStringGetType(string pString) {
      //--- return p(percentage), t(tick value), d(double), i(int)
      int sindex;
      if( (sindex = StringFind(pString, "%", 1)) > 0 ) {
         return "p"; // percentage
      }
      if( (sindex = StringFind(pString, "t", 1)) > 0 ) {
         return "t"; // offset ticks
      }      
      if( (sindex = StringFind(pString, ".", 1)) > 0 ) {
         return "d"; // price
      }
      if( (sindex = StringFind(pString, ".", 1)) < 0 ) {
         return "i"; // price
      }
      return "";            
   }    

   static string ParseBrokerSymbol(string pSourceSymbol, string pSymbolMapping, string pSymbolSuffuxDeletion, string pSymbolSuffuxAddition) {      
      string targetSymbol = pSourceSymbol;      
      if ( StringLen(pSymbolMapping) > 0 ) {
         string mapping_array[];    
         int count = CMyUtil::XStringSplit(pSymbolMapping,",", mapping_array);
         string token[];
         for (int i=0; i < count; i++) {
            CMyUtil::XStringSplit(mapping_array[i],"=", token);            
            if ( ArraySize(token) == 2 && StringCompare(pSourceSymbol,token[0],false) == 0 ) {
               targetSymbol = token[1]; 
               CMyUtil::Info("Symbol conversion changed '", pSourceSymbol, "' to '", targetSymbol, "'"); 
               break;
            }           
         }         
      }       
      if ( StringCompare(pSourceSymbol, targetSymbol, false) == 0 ) {
         int symbol_sindex;
         if ( StringLen(pSymbolSuffuxDeletion) > 0 && (symbol_sindex = StringFind(pSourceSymbol, pSymbolSuffuxDeletion, 0)) > 0 ) {
            targetSymbol = StringSubstr(pSourceSymbol, 0, symbol_sindex);
            CMyUtil::Info("Symbol suffix deletion settings changed '", pSourceSymbol, "' to '", targetSymbol, "'"); 
         }
         if ( StringLen(pSymbolSuffuxAddition) > 0 ) {
            targetSymbol = pSourceSymbol + pSymbolSuffuxAddition;
            CMyUtil::Info("Symbol suffix addition settings changed '", pSourceSymbol, "' to '", targetSymbol, "'"); 
         }
      }      
      return targetSymbol;
   }      

   static string ParseComment(string pComment) {
      string str = pComment;
      int len = StringLen(pComment);
      int index = StringFind(pComment,"@");
      if (len > 0 && index >= 0) {
         str = StringSubstr(pComment, 0, index);
         Debug(__FUNCTION__, "() Trade selected by comment = ", str);
      }
      return str;
   }
   
   static void ParseSignal(string _signal, JSONNode& _json_node) { 
      string options[];
      int count = CMyUtil::XStringSplit(_signal, " ", options);      
      string tokens[];
      for (int i=0; i < count; i++) {         
         CMyUtil::XStringSplit(options[i], "=", tokens); 
         if ( ArraySize(tokens) == 2 ) {
            _json_node[tokens[0]] = tokens[1];
         }
      } 
   }   
      

   static void PositionTickets(string pMagic, string pTicket, string pMarket, string pDirection, string pReference, ulong & returnTickets[]) { 
      bool filterMagic = StringLen(pMagic) > 0;
      bool filterTicket = StringLen(pTicket) > 0;
      bool filterMarket = StringLen(pMarket) > 0;
      bool filterDirection = StringLen(pDirection) > 0;
      bool filterReference = StringLen(pReference) > 0;
        
      int arrLength; 
      ArrayResize(returnTickets, 0);
      for ( int k= 0; k < PositionsTotal(); k++ ) {
         if ( PositionSelectByTicket(PositionGetTicket(k)) == false ) continue; //--- select the position
         if ( filterMarket && pMarket != PositionGetString(POSITION_SYMBOL) ) continue;
         if ( filterDirection && pDirection != GetPositionDirection((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)) ) continue;          
         if ( filterMagic && pMagic != (string)PositionGetInteger(POSITION_MAGIC) ) continue;  
         if ( filterReference && ParseComment(pReference) != ParseComment(PositionGetString(POSITION_COMMENT)) ) continue;     
         if ( filterTicket && pTicket != (string)PositionGetInteger(POSITION_TICKET) ) continue;                    
         
         arrLength = ArraySize(returnTickets);
         ArrayResize(returnTickets, arrLength+1);
         returnTickets[arrLength] = (ulong)PositionGetInteger(POSITION_TICKET);          
      }
      CMyUtil::Debug((string)ArraySize(returnTickets), " positions selected from search");
   }
   
   static void OrderTickets(string pMagic, string pTicket, string pMarket, string pDirection, string pReference, ulong & returnTickets[]) { 
      bool filterMagic = StringLen(pMagic) > 0; 
      bool filterTicket = StringLen(pTicket) > 0;
      bool filterMarket = StringLen(pMarket) > 0;
      bool filterDirection = StringLen(pDirection) > 0;
      bool filterReference = StringLen(pReference) > 0;      
         
      int arrLength;
      ArrayResize(returnTickets, 0);
      for ( int k = 0; k < OrdersTotal(); k++ ) {
         if ( OrderSelect(OrderGetTicket(k)) == false ) continue; //--- select the order
         if ( filterMarket && pMarket != OrderGetString(ORDER_SYMBOL) ) continue;
         if ( filterDirection && pDirection != GetOrderDirection((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)) ) continue;          
         if ( filterMagic && pMagic != (string)OrderGetInteger(ORDER_MAGIC) ) continue;
         if ( filterReference && ParseComment(pReference) != ParseComment(OrderGetString(ORDER_COMMENT)) ) continue;
         if ( filterTicket && pTicket != (string)OrderGetInteger(ORDER_TICKET) ) continue;                     
                  
         arrLength = ArraySize(returnTickets);
         ArrayResize(returnTickets, arrLength+1);
         returnTickets[arrLength] = (ulong)OrderGetInteger(ORDER_TICKET);          
      } 
      CMyUtil::Debug((string)ArraySize(returnTickets), " orders selected from search");
   }    
};

class CMyAppWidget {
private:
   string   mObjectPrefix;
   long     mChartId;
   int      mAnimationX;
   string   mFontName;
   int      mFontSizeTitle, mFontSizeText;
   color    mFontColorText;
   color    mBgColorMainPane, mBgColorTitle, mBgColorAnimBox, mActiveColorAnimBox;    

public:
   CMyAppWidget() {
      mObjectPrefix = "@" + MQLInfoString(MQL_PROGRAM_NAME);
      mChartId = ChartID();
      mAnimationX = 60;
      mFontName = "Tahoma";
      mFontSizeTitle = 12;
      mFontSizeText = 10;
      mFontColorText = clrSnow; // clrDarkRed;
      mBgColorMainPane = clrSlateGray;
      mBgColorTitle = C'244,142,56'; // C'40,100,220'; 
      mBgColorAnimBox = clrIvory;
      mActiveColorAnimBox = C'244,142,56'; // C'40,100,220';
      CMyUtil::Debug(__FUNCTION__, "() called");
   }

   ~CMyAppWidget() {
      ObjectsDeleteAll(mChartId, mObjectPrefix);
      Comment("");
      ChartRedraw();      
      CMyUtil::Debug(__FUNCTION__, "() called");
   }
        
   const void Start() {
      string obj_name = mObjectPrefix + "_APP_LABEL_FRAME";
      CMyUtil::CreateWidgetRectangleLabel(mChartId, obj_name, 40, 40, true, 440, 90, mBgColorMainPane);
      
      obj_name = mObjectPrefix + "_APP_LABEL_TITLE";
      CMyUtil::CreateWidgetRectangleLabel(mChartId, obj_name, 50, 50, true, 420, 30, mBgColorTitle);
      
      obj_name = mObjectPrefix + "_APP_TEXT_TITLE";
      CMyUtil::CreateWidgetText(mChartId, obj_name, 90, 55, false, 0, "Expert Name", mFontSizeTitle, mFontName, mFontColorText, MQLInfoString(MQL_PROGRAM_NAME));
      
      int animBoxYDistance = 90;
      for(int itrX = 60; itrX <= 440; itrX += 20) {
         obj_name = mObjectPrefix + "_APP_ANIMATION_" + IntegerToString(itrX);
         CMyUtil::CreateWidgetText(mChartId, obj_name, itrX, animBoxYDistance, true, 20, "Progress", 12, "Wingdings", mBgColorAnimBox, CharToString(110));   
      }      
      obj_name = mObjectPrefix + "_APP_TEXT_SESSION";
      CMyUtil::CreateWidgetText(mChartId, obj_name, 60, 110, false, 0, "Market Session", mFontSizeText, mFontName, mFontColorText, CMyUtil::CurrentMarketSession());                  
      
      obj_name = mObjectPrefix + "_APP_TEXT_INFO";
      CMyUtil::CreateWidgetText(mChartId, obj_name, 250, 110, false, 0, "Info", mFontSizeText, mFontName, mFontColorText, " ");                  
      ChartRedraw();    
   }
   
   const void Update(string pInfoText) { 
      string obj_name;
      for(int itrX = 60; itrX <= 440; itrX += 20) {
         obj_name = mObjectPrefix + "_APP_ANIMATION_" + IntegerToString(itrX);
         ObjectSetInteger(mChartId, obj_name, OBJPROP_COLOR, mBgColorAnimBox);   
      } 
      obj_name = mObjectPrefix + "_APP_ANIMATION_" + IntegerToString(mAnimationX);
      ObjectSetInteger(mChartId, obj_name, OBJPROP_COLOR, mActiveColorAnimBox);
      mAnimationX += 20;
      if (mAnimationX > 440) {
         mAnimationX = 60;
      }
      
      obj_name = mObjectPrefix + "_APP_TEXT_SESSION";
      ObjectSetString(mChartId, obj_name, OBJPROP_TEXT, CMyUtil::CurrentMarketSession());  
      obj_name = mObjectPrefix + "_APP_TEXT_INFO";
      string dinfo = StringLen(pInfoText) > 0 ? pInfoText : "";
      ObjectSetString(mChartId, obj_name, OBJPROP_TEXT, dinfo);  
      //CMyUtil::Debug(__FUNCTION__, " updated the ui");                      
   }   
   
};

class CMyAlgo {

private:   

   CSymbolInfo m_symbol_info;
   CTrade      m_trade; 
   JSONNode*   m_json_signals[];
   
   double _ReadPriceFromString(string pPriceStr, string pMarket, string pDirection, double pPriceOpen, bool pAsStoplossPrice) {
      double returnPrice = 0, diffPrice = 0;
      string parsedType = CMyUtil::XStringGetType(pPriceStr);   
      if ( "d" == parsedType ) {
         double doublePrice = StringToDouble(pPriceStr); 
         if ( doublePrice > 0 ) { 
            diffPrice = MathAbs(pPriceOpen - doublePrice);
         } 
      } else if ( "t" == parsedType ) {
         double doublePrice = StringToDouble(pPriceStr); 
         if ( doublePrice > 0 ) { 
            diffPrice = doublePrice;
         } 
      } else if ( "i" == parsedType ) {
         int diffPointCount = (int)StringToInteger(pPriceStr);
         if ( diffPointCount > 0 ) {         
            diffPrice = CMyUtil::ToPointDecimal(pMarket, diffPointCount);
         }
      }
      diffPrice = (this.StoplossMultiplier > 1) ? 
                     CMyUtil::NormalizePrice(pMarket, (diffPrice * this.StoplossMultiplier)) : diffPrice;
      //---Set supplied price levels accrording to the broker's price levels
      if ( diffPrice > 0) {
         //CMyUtil::Debug(__FUNCTION__, "() calculated price diff=", (string)diffPrice);
         if ( DEFINE_TRADE_DIR_LONG == pDirection ) {
            if ( pAsStoplossPrice ) {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen - diffPrice));
            } else {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen + diffPrice));
            }            
         } else if ( DEFINE_TRADE_DIR_SHORT == pDirection ) {
            if ( pAsStoplossPrice ) {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen + diffPrice));
            } else {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen - diffPrice));
            }          
         }      
      }      
      return returnPrice;
   }
   
   void _ReadQuantityFromString(string pQuantityStr, string pMarket, string pDirection, double pPriceOpen, double pStoplossPrice, double& lots_array[]) {
      double lots = 0;
      double capital = AccountInfoDouble(ACCOUNT_BALANCE);   
      capital = (this.CapitalMultiplier > 1) ? capital * this.CapitalMultiplier : capital;  
      string parsedType = CMyUtil::XStringGetType(pQuantityStr);
      if ( "d" == parsedType || "i" == parsedType ) {
         double decimalValue = StringToDouble(pQuantityStr);  
         decimalValue = (this.RiskMultiplier > 1) ? decimalValue * this.RiskMultiplier : decimalValue;
         lots = decimalValue > 0 ? CMyUtil::NormalizeLots(pMarket, decimalValue) : 0;
         ArrayResize(lots_array, 1);
         lots_array[0] = lots;
      } else if ( "p" == parsedType ) {
         double riskPercentage = StringToDouble(pQuantityStr);
         riskPercentage = (this.RiskMultiplier > 1) ? riskPercentage * this.RiskMultiplier : riskPercentage;
         int stoplossPoints = 0;        
         if ( riskPercentage > 0 && pStoplossPrice > 0 ) {
            stoplossPoints = CMyUtil::ToPointsCount(pMarket, MathAbs(pPriceOpen - pStoplossPrice));
            CMyUtil::CalculateUnitSize(pMarket, capital, riskPercentage, stoplossPoints, "", lots_array);            
         }
      }  
      if ( ArraySize(lots_array) > 0 ) {
         CMyUtil::Info("Calculated lots ", CMyUtil::ArrayToString(lots_array), " for the new ", pMarket, " trade(s).");         
      } else {
         CMyUtil::Error("Failed to calculate lots for the new ", pMarket, " trade(s). No Quantity or Stoploss defined.");
      }
   }      
       
   void _PositionClose(JSONNode& _json_node) {
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();
      ulong arrayTickets[];
      CMyUtil::PositionTickets((string)AlgoId, ticket, market, direction, reference, arrayTickets);     
      CPositionInfo positionInfo; 
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( positionInfo.SelectByTicket(arrayTickets[k]) == false ) continue; //--- select the position         
         //--- close the position
         for( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, ""); }
            
            m_trade.SetDeviationInPoints(MaximumSpreadPointCount*100);
            bool succeded = m_trade.PositionClose(positionInfo.Ticket());
            if ( succeded ) {
               CMyUtil::Info("Closed the ", market, " Position=",(string)positionInfo.Ticket());
               break;
            } else {
               CMyUtil::Error("Failed to close the ", market, " Position=",(string)positionInfo.Ticket(), " Reason=", m_trade.ResultRetcodeDescription());
            }
         }  
      }
   }

   void _OrderDelete(JSONNode& _json_node) {
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();   
      ulong arrayTickets[];
      CMyUtil::OrderTickets((string)AlgoId, ticket, market, direction, reference, arrayTickets);  
      COrderInfo orderInfo;
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( orderInfo.Select(arrayTickets[k]) == false ) continue; //--- select the order
         //--- delete the order       
         for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, ""); }
            
            m_trade.SetDeviationInPoints(MaximumSpreadPointCount*100);
            bool succeded = m_trade.OrderDelete(orderInfo.Ticket());
            if ( succeded ) {
               CMyUtil::Info("Deleted the ", market, " Order=",(string)orderInfo.Ticket());
               break;
            } else {
               CMyUtil::Error("Failed to delete the ", market, " Order=",(string)orderInfo.Ticket(), " Reason=", m_trade.ResultRetcodeDescription());        
            }
         }        
      } 
   }

   void _PositionModify(JSONNode& _json_node) {
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();
      string quantity = _json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString();       
      string stoploss = _json_node[DEFINE_SIGNAL_OPTION_STOPLOSS].ToString(); 
      string takeprofit = _json_node[DEFINE_SIGNAL_OPTION_TAKEPROFIT].ToString();                     
      ulong arrayTickets[];
      CMyUtil::PositionTickets((string)AlgoId, ticket, market, direction, reference, arrayTickets);     
      CPositionInfo positionInfo; 
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( positionInfo.SelectByTicket(arrayTickets[k]) == false ) continue; //--- select the position 
         //--- modify the position
         for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, ""); }
                  
            double sl = this._ReadPriceFromString(stoploss, market, direction, positionInfo.PriceOpen(), true);
            double tp = this._ReadPriceFromString(takeprofit, market, direction, positionInfo.PriceOpen(), false); 
            m_trade.SetDeviationInPoints(MaximumSpreadPointCount*10);                       
            bool succeded = m_trade.PositionModify(positionInfo.Ticket(), sl, tp);
            if ( succeded ) {
               CMyUtil::Info("Modified the ", market, " Position=",(string)positionInfo.Ticket());
               break;
            } else {
               CMyUtil::Error("Failed to modify the ", market, " Position=",(string)positionInfo.Ticket(), " Reason=", m_trade.ResultRetcodeDescription());
            }
         } 
      } 
   }

   void _OrderModify(JSONNode& _json_node) {
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();
      string quantity = _json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString();       
      string stoploss = _json_node[DEFINE_SIGNAL_OPTION_STOPLOSS].ToString(); 
      string takeprofit = _json_node[DEFINE_SIGNAL_OPTION_TAKEPROFIT].ToString();
      string priceopen = _json_node[DEFINE_SIGNAL_OPTION_PRICEOPEN].ToString();  
      string expiry = _json_node[DEFINE_SIGNAL_OPTION_EXPIRY].ToString();    
      ulong arrayTickets[];
      CMyUtil::OrderTickets((string)AlgoId, ticket, market, direction, reference, arrayTickets); 
      COrderInfo orderInfo;  
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( orderInfo.Select(arrayTickets[k]) == false ) continue; //--- select the order 
         //--- modify the order       
         for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, ""); } 
                               
            double newOpenPrice = StringToDouble(priceopen);         
            newOpenPrice = newOpenPrice > 0 ? CMyUtil::NormalizePrice(market, newOpenPrice) : orderInfo.PriceOpen();            
            double sl = this._ReadPriceFromString(stoploss, market, direction, newOpenPrice, true);
            double tp = this._ReadPriceFromString(takeprofit, market, direction, newOpenPrice, false);    
            long minutesExp = StringLen(expiry) > 0 ? StringToInteger(expiry) : 0;    
            long expiryNew = minutesExp > 0 ? (datetime)(TimeTradeServer() + (minutesExp * 60)) : orderInfo.TimeExpiration();   
            ENUM_ORDER_TYPE_TIME timeType = expiryNew > 0 ? ORDER_TIME_SPECIFIED : ORDER_TIME_GTC;                     
            m_trade.SetDeviationInPoints(MaximumSpreadPointCount*10);    
            bool succeded = m_trade.OrderModify(orderInfo.Ticket(), newOpenPrice, sl, tp, timeType, expiryNew);
            if ( succeded ) {
               CMyUtil::Info("Modified the ", market, " Order=",(string)orderInfo.Ticket());
               break;
            } else {
               CMyUtil::Error("Failed to modify the ", market, " Order=",(string)orderInfo.Ticket(), " Reason=", m_trade.ResultRetcodeDescription());                    
            }
         }        
      }
   }

   void _PositionOpen(JSONNode& _json_node) {
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();
      string quantity = _json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString();       
      string stoploss = _json_node[DEFINE_SIGNAL_OPTION_STOPLOSS].ToString(); 
      string takeprofit = _json_node[DEFINE_SIGNAL_OPTION_TAKEPROFIT].ToString();
      string gvargroup = _json_node[DEFINE_SIGNAL_OPTION_GLOBALVAR_GROUP].ToString();            
      for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) { CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, ""); }
         
         m_symbol_info.RefreshRates();
         if ( MaximumSpreadPointCount > 0 && m_symbol_info.Spread() > MaximumSpreadPointCount ) {
            CMyUtil::Info("Attempt:", (string)itr, ", failed to open Position, current spread=", (string)m_symbol_info.Spread(), " > maximum spread allowed=", (string)MaximumSpreadPointCount);
            continue;
         }
         double newOpenPrice = direction == DEFINE_TRADE_DIR_LONG ? m_symbol_info.Ask() : m_symbol_info.Bid();
         newOpenPrice = CMyUtil::NormalizePrice(market, newOpenPrice);
         double sl = this._ReadPriceFromString(stoploss, market, direction, newOpenPrice, true);
         double tp = this._ReadPriceFromString(takeprofit, market, direction, newOpenPrice, false); 
         ENUM_ORDER_TYPE orderType = direction == DEFINE_TRADE_DIR_LONG ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         
         double lots_array[]; 
         ArrayResize(lots_array, 0);        
         this._ReadQuantityFromString(quantity, market, direction, newOpenPrice, sl, lots_array);               
         if ( ArraySize(lots_array) > 0 ) {
            for ( int x = 0; x < ArraySize(lots_array); x++ ) {   
               if ( x > 0 ) {  CMyUtil::XSleep(5000, ""); }  
               
               m_trade.SetDeviationInPoints(MaximumSpreadPointCount*10);
               bool succeded = m_trade.PositionOpen(market, orderType, lots_array[x], newOpenPrice, sl, tp, reference);
               if ( succeded ) {            
                  ulong trade_id = m_trade.ResultOrder();
                  if ( StringLen(gvargroup) > 0 && StringLen(ticket) > 0 ) {
                     string global_var_ticket = CMyUtil::GlobalVarName(gvargroup, ticket);
                     CMyUtil::GlobalVarSetValue(global_var_ticket, (string)trade_id);
                  }
                  CMyUtil::Info("Opened a new ", market, " Position=",(string)trade_id);            
               } else {
                  CMyUtil::Error("Failed to open the new ", market, " Position. Reason=", m_trade.ResultRetcodeDescription());
               }
            }
            break;
         }
      }
   }

   void _OrderOpen(JSONNode& _json_node) {
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString();
      string quantity = _json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString();       
      string stoploss = _json_node[DEFINE_SIGNAL_OPTION_STOPLOSS].ToString(); 
      string takeprofit = _json_node[DEFINE_SIGNAL_OPTION_TAKEPROFIT].ToString();
      string priceopen = _json_node[DEFINE_SIGNAL_OPTION_PRICEOPEN].ToString();  
      string expiry = _json_node[DEFINE_SIGNAL_OPTION_EXPIRY].ToString();    
      string gvargroup = _json_node[DEFINE_SIGNAL_OPTION_GLOBALVAR_GROUP].ToString();  
      for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {  CMyUtil::XSleep(DEFINE_TRADE_WAIT_TIME, ""); }
         
         m_symbol_info.RefreshRates();
         double newOpenPrice = CMyUtil::NormalizePrice(market, StringToDouble(priceopen));
         ENUM_ORDER_TYPE orderType; 
         if ( direction == DEFINE_TRADE_DIR_LONG ) {
            orderType = newOpenPrice > m_symbol_info.Ask() ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT;            
         } else {
            orderType = newOpenPrice < m_symbol_info.Bid() ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT;      
         }            
         double sl = this._ReadPriceFromString(stoploss, market, direction, newOpenPrice, true);
         double tp = this._ReadPriceFromString(takeprofit, market, direction, newOpenPrice, false);           
         long minutesExp = StringLen(expiry) > 0 ? StringToInteger(expiry) : 0;    
         long expiryNew = minutesExp > 0 ? (datetime)(TimeTradeServer() + (minutesExp * 60)) : 0;   
         ENUM_ORDER_TYPE_TIME timeType = expiryNew > 0 ? ORDER_TIME_SPECIFIED : ORDER_TIME_GTC;    
         
         double lots_array[]; 
         ArrayResize(lots_array, 0);    
         this._ReadQuantityFromString(quantity, market, direction, newOpenPrice, sl, lots_array);           
         if ( ArraySize(lots_array) > 0 ) {
            for ( int x = 0; x < ArraySize(lots_array); x++ ) {     
               if ( x > 0 ) {  CMyUtil::XSleep(5000, ""); }  
                    
               m_trade.SetDeviationInPoints(MaximumSpreadPointCount*10);
               bool succeded = m_trade.OrderOpen(market, orderType, lots_array[x], 0, newOpenPrice, sl, tp, timeType, expiryNew, reference);
               if ( succeded ) {
                  ulong trade_id = m_trade.ResultOrder();
                  if ( StringLen(gvargroup) > 0 && StringLen(ticket) > 0 ) {
                     string global_var_ticket = CMyUtil::GlobalVarName(gvargroup, ticket);
                     CMyUtil::GlobalVarSetValue(global_var_ticket, (string)trade_id);
                  }                  
                  CMyUtil::Info("Opened a new ", market, " Order=",(string)trade_id);                                
               } else {
                  CMyUtil::Error("Failed to open the new ", market, " Order. Reason=", m_trade.ResultRetcodeDescription());
               }                
            }
            break;            
         }
      }
   }
   
   const void _ProcessSignal(JSONNode& _json_node) { 
      ResetLastError();
      //CMyUtil::Info("Signal -> ", json_node.Serialize());       
     
      string command = _json_node[DEFINE_SIGNAL_OPTION_COMMAND].ToString();
      string plus = _json_node[DEFINE_SIGNAL_OPTION_PLUS].ToString();
      string ticket = _json_node[DEFINE_SIGNAL_OPTION_TICKET].ToString(); 
      string market = _json_node[DEFINE_SIGNAL_OPTION_MARKET].ToString();
      string direction = _json_node[DEFINE_SIGNAL_OPTION_DIRECTION].ToString(); 
      string reference = _json_node[DEFINE_SIGNAL_OPTION_REFERENCE].ToString(); 
      string quantity = _json_node[DEFINE_SIGNAL_OPTION_QUANTITY].ToString(); 
      string priceopen = _json_node[DEFINE_SIGNAL_OPTION_PRICEOPEN].ToString(); 
      string stoploss = _json_node[DEFINE_SIGNAL_OPTION_STOPLOSS].ToString(); 
      string takeprofit = _json_node[DEFINE_SIGNAL_OPTION_TAKEPROFIT].ToString(); 
      string expiry = _json_node[DEFINE_SIGNAL_OPTION_EXPIRY].ToString(); 
      string account = _json_node[DEFINE_SIGNAL_OPTION_ACCOUNT].ToString(); 

      if ( StringLen(command) == 0 ) { CMyUtil::Error("Received signal have no '", DEFINE_SIGNAL_OPTION_COMMAND, "' value !"); return; }
      if ( StringLen(plus) == 0 ) { CMyUtil::Error("Received signal have no '", DEFINE_SIGNAL_OPTION_PLUS, "' value !"); return; }
      if ( plus != DEFINE_ROBOT_PLUS_CODE ) { CMyUtil::Error("Received signal have no '", DEFINE_SIGNAL_OPTION_PLUS, "=", DEFINE_ROBOT_PLUS_CODE,"' value !"); return; }
      if ( StringLen(market) == 0 ) { CMyUtil::Error("Received signal have no '", DEFINE_SIGNAL_OPTION_MARKET, "' value !"); return; }      
      if ( StringLen(direction) > 0 && direction != DEFINE_TRADE_DIR_LONG && direction != DEFINE_TRADE_DIR_SHORT ) { 
         CMyUtil::Error("Received signal have invalid '", DEFINE_SIGNAL_OPTION_DIRECTION, "' value !"); return;
      }       
      
      string current_act = (string)AccountInfoInteger(ACCOUNT_LOGIN);
      if ( StringLen(account) > 0 && StringCompare(account, current_act, false) != 0 ) {
         CMyUtil::Error("Received signal's value for account=", account," doesn't equal to current account=", current_act," !"); return; 
      }      
      //--- initialize the symbol
      bool symbol_valid = m_symbol_info.Name(market);
      if (  symbol_valid == false ) {            
         CMyUtil::Error("'", market, "' is not found. Check the avalibales Symbols !"); return;
      }           
      //if (  CMyUtil::CheckMarketOpen(market) == false ) { CMyUtil::Error("Market seems to be closed for '", market, "' !"); return; } 
  
      m_trade.SetTypeFillingBySymbol(market);      
      //--- execute trades
      if ( StringCompare(command, DEFINE_SIGNAL_COMMAND_OPEN, false) == 0 ) {
         if ( StringLen(direction) == 0 ) { CMyUtil::Error("Received signal have no '", DEFINE_SIGNAL_OPTION_DIRECTION, "' value !"); return; }
         
         if ( StringLen(priceopen) > 0 ) {
            this._OrderOpen(_json_node);
         } else {
            this._PositionOpen(_json_node);
         }
      }
      else if ( StringCompare(command, DEFINE_SIGNAL_COMMAND_MODIFY, false) == 0 ) {
         if ( StringLen(direction) == 0 ) { CMyUtil::Error("Received signal have no '", DEFINE_SIGNAL_OPTION_DIRECTION, "' value !"); return; }
         
         this._PositionModify(_json_node);            
         this._OrderModify(_json_node);
      }
      else if ( StringCompare(command, DEFINE_SIGNAL_COMMAND_CLOSE, false) == 0 ) {
         this._PositionClose(_json_node);
      }
      else if ( StringCompare(command, DEFINE_SIGNAL_COMMAND_DELETE, false) == 0 ) {
         this._OrderDelete(_json_node);
      }   
    
   }   

protected:      
   //--- parameterized configuration
   long     AlgoId; // Magic Number
   int      MaximumSpreadPointCount; // Maximum Spread points, 50 points -> 5 pips  
   double   CapitalMultiplier; // Multiplier of the account balance
   double   RiskMultiplier; // Multiplier value of the given risk
   double   StoplossMultiplier; // Multiplier of the stoploss distance

   virtual int    OnStartAlgo()  = 0;
   virtual void   OnUpdateAlgo()   = 0;
   virtual void   OnStopAlgo()   = 0;              

   void AddSignal(JSONNode &_json_node) {      
      int arr_length = ArraySize(m_json_signals);
      ArrayResize(m_json_signals, arr_length+1);
      m_json_signals[arr_length] = GetPointer(_json_node);        
   }
     
   void AddSignal(string _signal) {      
      if (StringLen(_signal) == 0) return;
      CMyUtil::Info("Received the signal -> ", _signal);   
      JSONNode* json_node = new JSONNode();
      CMyUtil::ParseSignal(_signal, json_node);
      AddSignal(json_node);    
   }
  
public:

   string   DisplayInfo; // Info displayed in the widget box

   CMyAlgo() : AlgoId(0),
               DisplayInfo(" "),
               MaximumSpreadPointCount(9000), 
               CapitalMultiplier(1),
               RiskMultiplier(1),
               StoplossMultiplier(1)  
   {  
      ArrayResize(m_json_signals, 0);
      CMyUtil::Debug(__FUNCTION__, "() called");
   }

   ~CMyAlgo() {
      CMyUtil::Debug(__FUNCTION__, "() called");
   }
   
   const int Start() {  
      int ret = this.OnStartAlgo();
      if ( ret == INIT_SUCCEEDED ) {
         m_trade.SetAsyncMode(false);
         m_trade.SetMarginMode();      
         m_trade.SetExpertMagicNumber(AlgoId);
         CMyUtil::Info("Algo=", (string)AlgoId, " initialized !");
      } else {
         CMyUtil::Error("Algo=", (string)AlgoId, " initialization failed !");
         ret = INIT_FAILED;
      }   
      return ret;
   }
  
   const void Update() {     
      this.OnUpdateAlgo();   
      /*datetime bar_time = iTime(m_symbol_custom, 0, 0); 
      static datetime var_last_bar_time = bar_time;  
      if ( var_last_bar_time < bar_time ) {
         var_last_bar_time = bar_time;
      }*/     
      if ( ArraySize(m_json_signals) > 0 ) {
         for ( int k = 0; k < ArraySize(m_json_signals); k++ ) {
            this._ProcessSignal(m_json_signals[k]);
         } 
         for ( int k = 0; k < ArraySize(m_json_signals); k++ ) {
            delete m_json_signals[k]; m_json_signals[k] = NULL;
         }                  
      }      
      ArrayResize(m_json_signals, 0);          
   }     
  
   const void Stop() {
      this.OnStopAlgo();   
   }
     
};

class CMyRobot {

private:

   CMyAppWidget*     mAppWidget;
   CMyAlgo*          mAlgoArray[];
   int               mTimerSeconds;
   bool              mCreatedTimer;
  
   void _Update() {      
      static bool in_update = false;
      if (in_update) return;
      in_update = true; 
      
      string dinfo;
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         mAlgoArray[i].Update();
         dinfo = mAlgoArray[i].DisplayInfo;
      } 
      mAppWidget.Update(dinfo);
      //CMyUtil::FlagTerminalLostConnection(60*10);
      in_update = false;   
   }
   
public:

   CMyRobot()  :  mTimerSeconds(0),
                  mCreatedTimer(false)
   {
      ArrayResize(mAlgoArray, 0);      
      CMyUtil::Debug(__FUNCTION__, "() called");
   }

   ~CMyRobot() {
      CMyUtil::Debug(__FUNCTION__, "() called");
   }

   const int Start(string pRobotName, int pTimerSeconds, string pLicenseKey, CMyAlgo* &pAlgo[]) {      
      CMyUtil::Debug(__FUNCTION__, "() ", pRobotName);
      TesterHideIndicators(DEFINE_ROBOT_TESTER_HIDE_INDICATORS); 
      ResetLastError();
      
      string mqlProgramName = MQLInfoString(MQL_PROGRAM_NAME);
      if ( pRobotName != mqlProgramName ) {
         MessageBox("Invalid file name= '" + mqlProgramName + "' owned by the expert, it must be '" + pRobotName +"'.", pRobotName, MB_OK);
         return (INIT_PARAMETERS_INCORRECT);
      }
      bool hasValidLicense = CMyUtil::CheckValidLicense(pLicenseKey);
      if  ( DEFINE_ROBOT_ENFORCE_LICENSE && hasValidLicense == false ) {
         MessageBox("Invalid License Key= '" + pLicenseKey + "' configured in the expert.", pRobotName, MB_OK);
         return (INIT_PARAMETERS_INCORRECT);
      }
      if ( AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ) {
         CMyUtil::Info("Running on a Demo Account !");
      }
      mTimerSeconds = pTimerSeconds;
      if (CMyUtil::IsTesting()) {
         mTimerSeconds = 0;
         CMyUtil::Info("Running on Strategy Tester !");
      }
      ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
      if ( margin_mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING ) {
         CMyUtil::Info("Account has no retail hedging !");         
      }
      mAppWidget = new CMyAppWidget(); 
      mAppWidget.Start();       
      ArrayCopy(mAlgoArray, pAlgo, 0, 0, ArraySize(pAlgo));
      int initResult;
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         initResult = mAlgoArray[i].Start();
         if ( initResult != INIT_SUCCEEDED ) {
            return (initResult);
         }            
      }     
      if (mTimerSeconds > 0) {
         mCreatedTimer = EventSetTimer(mTimerSeconds); 
      }
      ChartRedraw();
      CMyUtil::Info(mqlProgramName, " started successfully !");
      return (INIT_SUCCEEDED);
   }

   const void Stop(const int pReason) { 
      CMyUtil::Debug(__FUNCTION__, "() ", (string)pReason); 
      EventKillTimer();
      delete mAppWidget;
      for (int i = 0; i < ArraySize(mAlgoArray); i++) {
         mAlgoArray[i].Stop();
      }
      //---now delete dynamic algo objects
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         if ( CheckPointer(mAlgoArray[i]) == POINTER_DYNAMIC ) {
            delete mAlgoArray[i];
         }
      }      
      ChartRedraw();
      CMyUtil::CheckDeinitReason(pReason);
   }
   
   const void UpdateTimer() {  
      if (mTimerSeconds > 0) {
         //CMyUtil::RefreshRates(CurrentSymbol()); //-- force refresh ticks
         _Update();
      }
   }
   
   const void UpdateTick() {
      if (mTimerSeconds > 0) {
         if(mCreatedTimer == false) {
            mCreatedTimer = EventSetTimer(mTimerSeconds);
         }          
      } else {
         _Update();
      }
   }

};

//+------------------------------------------------------------------+
//| Framework implementation end                                     |
//+------------------------------------------------------------------+

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
