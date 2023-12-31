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

//+------------------------------------------------------------------+
//| Defines                                                          |
//+------------------------------------------------------------------+

#define DEFINE_DEBUG                               false
#define DEFINE_ROBOT_ENFORCE_LICENSE               false
#define DEFINE_ROBOT_PLUS_CODE                     "mt"
#define DEFINE_ROBOT_TESTER_HIDE_INDICATORS        false

#define DEFINE_TRADE_ASYNC_MODE                    false
#define DEFINE_TRADE_RETRY_COUNT                   5
#define DEFINE_TRADE_WAIT_TIME                     10000
#define DEFINE_TRADE_DIR_LONG                      "long"
#define DEFINE_TRADE_DIR_SHORT                     "short"

#define DEFINE_SIGNAL_COMMAND_OPEN                 "open"
#define DEFINE_SIGNAL_COMMAND_MODIFY               "modify"
#define DEFINE_SIGNAL_COMMAND_CLOSE                "close"
#define DEFINE_SIGNAL_COMMAND_DELETE               "delete"
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

//+------------------------------------------------------------------+
//| Classes                                                          |
//+------------------------------------------------------------------+


class CMyUtil {

protected:

   virtual void  _Name() = NULL;   // A pure virtual function to make this class abstract

public:

   static void Info(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "") {
      Print(" --INFO-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10);
   }
   
   static void Debug(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "") {
      if ( DEFINE_DEBUG ) {
         Print(" --DEBUG-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10);      
      }
   }   

   static void XSleep(int pMilliseconds = DEFINE_TRADE_WAIT_TIME) {
      Sleep(pMilliseconds);
      Info("Sleep(", (string)pMilliseconds, ") done, Market Session= ", CurrentMarketSession());
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
   
   static void RefreshRates(string pMarket){
      MqlTick mql_tick;
      SymbolInfoTick(pMarket, mql_tick); //-- refresh rates
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
      int utickscount = uticksize > 0 ? (int)((pPointsCount / uticksize) * uticksize) : 0; //-- fix prices by ticksize
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
         CMyUtil::Debug("Chart's custom_symbol=", m_symbol_custom, " origin_symbol=", m_symbol);
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
       long last_quote_time = SymbolInfoInteger(pSymbol, SYMBOL_TIME); //--- Time of the last quote
       long current_server_time = (long)TimeTradeServer();
      
       long diff = MathAbs(last_quote_time-current_server_time);
       //Debug(__FUNCTION__, " last_quote_time: ", (string)last_quote_time, " current_server_time: ", (string)current_server_time);
       if ( diff > 5000 ) {
         Debug(__FUNCTION__, " Market seems to be closed as quote time difference is: ", (string)diff);
         return false;
       }
       return true;
   }   

   static string CurrentMarketSession(string pSymbol) {
      string mSession = "";     
      if ( CheckMarketOpen(pSymbol) ) {
         CheckMarketSessionTime(22.00, 7.00) ? StringConcatenate(mSession, mSession, "Sydney ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(0.00, 9.00) ? StringConcatenate(mSession, mSession, "Tokyo ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(7.00, 16.00) ? StringConcatenate(mSession, mSession, "Frankfurt ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(8.00, 17.00) ? StringConcatenate(mSession, mSession, "London ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(13.00, 22.00) ? StringConcatenate(mSession, mSession, "Newyork ") : StringConcatenate(mSession, mSession, "");
         CheckMarketSessionTime(14.00, 23.00) ? StringConcatenate(mSession, mSession, "Chicago ") : StringConcatenate(mSession, mSession, "");
      } else {
         mSession = "Market is closed";
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
      Debug("SYMBOL_TRADE_TICK_VALUE=",(string)oneTickValue, " SL Ticks count=", (string)totalTickCount, " Risk=", (string)pRiskPercentage, " Total calculated Lots=", (string)lotsByRisk);
      
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
      int cbar_count = CopyBuffer(ind_handle, buffer_num, 0, copy_count, return_array)>0;
      if(cbar_count <= 0) {
         Info("Failed to copy buffer of indicator handle= ", (string)ind_handle, " Error= ", IntegerToString(GetLastError())); 
         return (false);
      }   
      return (true);
   }      

   static double MathGetAngle(double pValue1, double pValue2, int pPeriod, double pCoef) {
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
      Info(MQLInfoString(MQL_PROGRAM_NAME), " terminated! ", text);
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
               Info(msg);
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
            str = "unknown position type "+(string)pPostionType; break;
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
            str = "unknown order type "+(string)pOrderType; break;
      }
      return (str);
   }   

   static string _ParseComment(string pComment) {
      string str = pComment;
      int len = StringLen(pComment);
      int index = StringFind(pComment,"@");
      if (len > 0 && index >= 0) {
         str = StringSubstr(pComment, 0, index);
         Info("Trade selected by comment = ", str);
      }
      return str;
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
         if ( filterReference && _ParseComment(pReference) != _ParseComment(PositionGetString(POSITION_COMMENT)) ) continue;     
         if ( filterTicket && pTicket != (string)PositionGetInteger(POSITION_TICKET) ) continue;                    
         
         arrLength = ArraySize(returnTickets);
         ArrayResize(returnTickets, arrLength+1);
         returnTickets[arrLength] = (ulong)PositionGetInteger(POSITION_TICKET);          
      }
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
         if ( filterReference && _ParseComment(pReference) != _ParseComment(OrderGetString(ORDER_COMMENT)) ) continue;
         if ( filterTicket && pTicket != (string)OrderGetInteger(ORDER_TICKET) ) continue;                     
                  
         arrLength = ArraySize(returnTickets);
         ArrayResize(returnTickets, arrLength+1);
         returnTickets[arrLength] = (ulong)OrderGetInteger(ORDER_TICKET);          
      } 
   }    
};

class CMyAppWidget {
private:
   string   mObjectPrefix;
   long     mChartId;
   int      mAnimationX;
   string   mFontName;
   int      mFontSizeTitle, mFontSizeText;
   color    mFontColorTitle, mFontColorText;
   color    mBgColorMainPane, mBgColorTitle, mBgColorAnimBox, mActiveColorAnimBox;    

public:
   CMyAppWidget() {
      mObjectPrefix = "@" + MQLInfoString(MQL_PROGRAM_NAME);
      mChartId = ChartID();
      mAnimationX = 60;
      mFontName = "Tahoma";
      mFontSizeTitle = 12;
      mFontSizeText = 10;
      mFontColorTitle = clrDarkSlateGray;
      mBgColorMainPane = clrSlateGray;
      mBgColorTitle = C'132,191,4'; 
      mBgColorAnimBox = clrIvory;
      mActiveColorAnimBox = C'132,191,4'; 
      CMyUtil::Debug(__FUNCTION__, " is called");
   }

   ~CMyAppWidget() {
      ObjectsDeleteAll(mChartId, mObjectPrefix);
      Comment("");
      ChartRedraw();      
      CMyUtil::Debug(__FUNCTION__, " is called");
   }
        
   const void Start() {
      string obj_name = mObjectPrefix + "_APP_LABEL_FRAME";
      CMyUtil::CreateWidgetRectangleLabel(mChartId, obj_name, 40, 40, true, 440, 90, mBgColorMainPane);
      
      obj_name = mObjectPrefix + "_APP_LABEL_TITLE";
      CMyUtil::CreateWidgetRectangleLabel(mChartId, obj_name, 50, 50, true, 420, 30, mBgColorTitle);
      
      obj_name = mObjectPrefix + "_APP_TEXT_TITLE";
      CMyUtil::CreateWidgetText(mChartId, obj_name, 90, 55, false, 0, "Expert Name", mFontSizeTitle, mFontName, mFontColorTitle, MQLInfoString(MQL_PROGRAM_NAME));
      
      int animBoxYDistance = 90;
      for(int itrX = 60; itrX <= 440; itrX += 20) {
         obj_name = mObjectPrefix + "_APP_ANIMATION_" + IntegerToString(itrX);
         CMyUtil::CreateWidgetText(mChartId, obj_name, itrX, animBoxYDistance, true, 20, "Ticks update", 12, "Wingdings", mBgColorAnimBox, CharToString(110));   
      }      
      obj_name = mObjectPrefix + "_APP_TEXT_SESSION";
      CMyUtil::CreateWidgetText(mChartId, obj_name, 60, 110, false, 0, "Market Session", mFontSizeText, mFontName, mFontColorText, CMyUtil::CurrentMarketSession());                  
   }
   
   const void Update() { 
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
   }   
   
};

class CMyAlgo {

private:   

   CSymbolInfo symbolInfo;
   CTrade      ctrade; 
   string mSignalArray[];

   int _SignalSplit(string pSource, string pSeparator, string & arraySplits[]) {
      if (pSource == NULL || StringLen(pSource) == 0) {
         return -1;
      }
      StringTrimLeft(pSource); StringTrimRight(pSource); 
      ushort ushsep = StringGetCharacter(pSeparator, 0);
      int count = StringSplit(pSource, ushsep, arraySplits);
      return count;     
   }
   
   string _SignalCommand(string pString) {  
      string command = "";
      if ( pString == DEFINE_SIGNAL_COMMAND_OPEN || pString == DEFINE_SIGNAL_COMMAND_MODIFY || 
            pString == DEFINE_SIGNAL_COMMAND_CLOSE || pString == DEFINE_SIGNAL_COMMAND_DELETE ) {
         command = pString;           
      }      
      return command;      
   }   
      
   string _SignalOptionValue(string pString, string pOption) { 
      int sindex = StringFind(pString, pOption, 0); 
      if ( sindex != 0 ) {          
         return "";
      }
      ushort ushsep = StringGetCharacter("=", 0);
      string arraySplits[];
      int count = StringSplit(pString, ushsep, arraySplits);
      if ( count != 2 ) {
         return "";
      }
      return arraySplits[1];      
   }
   
   string _ReadTypeOfString(string pString) {
      //--- return p(percentage), t(tick value), d(double), i(int)
      int sindex;
      if( (sindex = StringFind(pString, "%", 1)) > 0 ) {
         return "p";
      }
      if( (sindex = StringFind(pString, "t", 1)) > 0 ) {
         return "t";
      }      
      if( (sindex = StringFind(pString, ".", 1)) > 0 ) {
         return "d";
      }
      if( (sindex = StringFind(pString, ".", 1)) < 0 ) {
         return "i";
      }
      return "";            
   } 
   
   double _ReadPriceFromString(string pPriceStr, string pMarket, string pDirection, double pPriceOpen, bool pAsStopPrice, bool pAsTargetPrice) {
      double returnPrice = 0, diffPrice = 0;
      string parsedType = this._ReadTypeOfString(pPriceStr);   
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
      diffPrice = (this.StoplossMultiplier > 0 && this.StoplossMultiplier != 1) ? 
                     CMyUtil::NormalizePrice(pMarket, (diffPrice * this.StoplossMultiplier)) : diffPrice;
      //---Set supplied price levels accrording to the broker's price levels
      if ( diffPrice > 0) {
         if ( DEFINE_TRADE_DIR_LONG == pDirection ) {
            if ( pAsStopPrice ) {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen - diffPrice));
            } else if ( pAsTargetPrice ) {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen + diffPrice));
            }            
         } else if ( DEFINE_TRADE_DIR_SHORT == pDirection ) {
            if ( pAsStopPrice ) {
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen + diffPrice));
            } else if ( pAsTargetPrice ){
               returnPrice = CMyUtil::NormalizePrice(pMarket, (pPriceOpen - diffPrice));
            }          
         }      
      }      
      return returnPrice;
   }
   
   void _ParseQuantityFromString(string pQuantityStr, string pMarket, string pDirection, double pPriceOpen, double pStoplossPrice, double& lots_array[]) {
      double lots = 0, capital = 0;
      if( UseAccountFreeMargin ) {
         capital = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      } else {
         capital = AccountInfoDouble(ACCOUNT_BALANCE);
      }       
      string parsedType = this._ReadTypeOfString(pQuantityStr);
      if ( "d" == parsedType || "i" == parsedType ) {
         double decimalValue = StringToDouble(pQuantityStr);  
         decimalValue = (this.RiskMultiplier > 0 && this.RiskMultiplier != 1) ? decimalValue * this.RiskMultiplier : decimalValue;
         lots = decimalValue > 0 ? CMyUtil::NormalizeLots(pMarket, decimalValue) : 0;
         ArrayResize(lots_array, 1);
         lots_array[0] = lots;
      } else if ( "p" == parsedType ) {
         double riskPercentage = StringToDouble(pQuantityStr);
         riskPercentage = (this.RiskMultiplier > 0 && this.RiskMultiplier != 1) ? riskPercentage * this.RiskMultiplier : riskPercentage;
         int stoplossPoints = 0;        
         if ( riskPercentage > 0 && pStoplossPrice > 0 ) {
            stoplossPoints = CMyUtil::ToPointsCount(pMarket, MathAbs(pPriceOpen - pStoplossPrice));
            CMyUtil::CalculateUnitSize(pMarket, capital, riskPercentage, stoplossPoints, "", lots_array);            
         }
      }  
      if ( ArraySize(lots_array) > 0 ) {
         CMyUtil::Info("Successfully calculated lots for the new ", pMarket, " trade(s)."); ArrayPrint(lots_array);         
      } else {
         CMyUtil::Info("Failed to calculate lots for the new ", pMarket, " trade(s). No Quantity or Stoploss defined.");
      }
   } 
   
   bool _CheckSignalTargetAccount(string pSourceAccount) { 
      if ( StringLen(pSourceAccount) == 0 ) {
         return true; 
      }
      string accounts[];      
      int count = this._SignalSplit(pSourceAccount, ",", accounts);
      if ( count < 1 ) {
         return true;  
      }      
      for (int i=0; i < count; i++) {
         if (accounts[i] == IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))) {
            return true;  
         }
      }         
      return false;
   } 
      
   string _MapMarketSymbolToBrokerSpecific(string pSourceSymbol) { 
      if ( this.BrokerSymbolMappings == "" ) {
         return pSourceSymbol;
      }
      string mappings[];      
      int count = this._SignalSplit(this.BrokerSymbolMappings, ",", mappings);
      if ( count < 1 ) {
         return pSourceSymbol;  
      }      
      string value, targetSymbol = "";
      for (int i=0; i < count; i++) {
         targetSymbol   = (value = this._SignalOptionValue(mappings[i], pSourceSymbol)) != "" ? value : targetSymbol;    
      }   
      if ( targetSymbol == "" ) {
         targetSymbol = pSourceSymbol;
      } else {
         CMyUtil::Info("Market= ", pSourceSymbol, " mapped to Broker Symbol= ", targetSymbol);    
      }
      return targetSymbol;
   } 
         
   void _PositionClose(string pTicket, string pMarket, string pDirection, string pReference) {
      ulong arrayTickets[];
      CMyUtil::PositionTickets((string)AlgoId, pTicket, pMarket, pDirection, pReference, arrayTickets);     
      CPositionInfo positionInfo; 
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( positionInfo.SelectByTicket(arrayTickets[k]) == false ) continue; //--- select the position         
         //--- close the position
         for( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) {
               CMyUtil::XSleep();
            }
            ctrade.SetDeviationInPoints(MaximumSpreadPointCount*100);
            bool succeded = ctrade.PositionClose(positionInfo.Ticket());
            if ( succeded ) {
               CMyUtil::Info("Closed the ", pMarket, " Position= ",(string)positionInfo.Ticket());
               break;
            } else {
               CMyUtil::Info("Failed to close the ", pMarket, " Position= ",(string)positionInfo.Ticket(), " Reason= ", ctrade.ResultRetcodeDescription());
            }
         }  
      }
   }

   void _OrderDelete(string pTicket, string pMarket, string pDirection, string pReference) {
      ulong arrayTickets[];
      CMyUtil::OrderTickets((string)AlgoId, pTicket, pMarket, pDirection, pReference, arrayTickets);  
      COrderInfo orderInfo;
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( orderInfo.Select(arrayTickets[k]) == false ) continue; //--- select the order
         //--- delete the order       
         for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) {
               CMyUtil::XSleep();
            }
            ctrade.SetDeviationInPoints(MaximumSpreadPointCount*100);
            bool succeded = ctrade.OrderDelete(orderInfo.Ticket());
            if ( succeded ) {
               CMyUtil::Info("Deleted the ", pMarket, " Order= ",(string)orderInfo.Ticket());
               break;
            } else {
               CMyUtil::Info("Failed to delete the ", pMarket, " Order= ",(string)orderInfo.Ticket(), " Reason= ", ctrade.ResultRetcodeDescription());        
            }
         }        
      } 
   }

   void _PositionModify(string pTicket, string pMarket, string pDirection, string pReference, string pStoploss, string pTakeprofit) {
      ulong arrayTickets[];
      CMyUtil::PositionTickets((string)AlgoId, pTicket, pMarket, pDirection, pReference, arrayTickets); 
      CPositionInfo positionInfo; 
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( positionInfo.SelectByTicket(arrayTickets[k]) == false ) continue; //--- select the position 
         //--- modify the position
         for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) {
               CMyUtil::XSleep();
            }      
            double sl = this._ReadPriceFromString(pStoploss, pMarket, pDirection, positionInfo.PriceOpen(), true, false);
            double tp = this._ReadPriceFromString(pTakeprofit, pMarket, pDirection, positionInfo.PriceOpen(), false, true); 
            sl = sl > 0 ? sl : positionInfo.StopLoss();
            tp = tp > 0 ? tp : positionInfo.TakeProfit();
            ctrade.SetDeviationInPoints(MaximumSpreadPointCount*10);                       
            bool succeded = ctrade.PositionModify(positionInfo.Ticket(), sl, tp);
            if ( succeded ) {
               CMyUtil::Info("Updated the ", pMarket, " Position= ",(string)positionInfo.Ticket());
               break;
            } else {
               CMyUtil::Info("Failed to update the ", pMarket, " Position= ",(string)positionInfo.Ticket(), " Reason= ", ctrade.ResultRetcodeDescription());
            }
         } 
      } 
   }

   void _OrderModify(string pTicket, string pMarket, string pDirection, string pReference, string pPriceOpen, string pStoploss, string pTakeprofit, string pExpiry) {
      ulong arrayTickets[];
      CMyUtil::OrderTickets((string)AlgoId, pTicket, pMarket, pDirection, pReference, arrayTickets); 
      COrderInfo orderInfo;  
      for ( int k = 0; k < ArraySize(arrayTickets); k++ ) {
         if ( orderInfo.Select(arrayTickets[k]) == false ) continue; //--- select the order 
         //--- modify the order       
         for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
            ResetLastError();
            if ( itr > 1 ) {
               CMyUtil::XSleep();
            }                    
            double newOpenPrice = StringToDouble(pPriceOpen);         
            newOpenPrice = newOpenPrice > 0 ? CMyUtil::NormalizePrice(pMarket, newOpenPrice) : orderInfo.PriceOpen();            
            double sl = this._ReadPriceFromString(pStoploss, pMarket, pDirection, newOpenPrice, true, false);
            double tp = this._ReadPriceFromString(pTakeprofit, pMarket, pDirection, newOpenPrice, false, true); 
            sl = sl > 0 ? sl : orderInfo.StopLoss();
            tp = tp > 0 ? tp : orderInfo.TakeProfit();      
            long minutesExp = StringLen(pExpiry) > 0 ? StringToInteger(pExpiry) : 0;    
            long expiryNew = minutesExp > 0 ? (datetime)(TimeTradeServer() + (minutesExp * 60)) : orderInfo.TimeExpiration();   
            ENUM_ORDER_TYPE_TIME timeType = expiryNew > 0 ? ORDER_TIME_SPECIFIED : ORDER_TIME_GTC;                     
            ctrade.SetDeviationInPoints(MaximumSpreadPointCount*10);    
            bool succeded = ctrade.OrderModify(orderInfo.Ticket(), newOpenPrice, sl, tp, timeType, expiryNew);
            if ( succeded ) {
               CMyUtil::Info("Updated the ", pMarket, " Order= ",(string)orderInfo.Ticket());
               break;
            } else {
               CMyUtil::Info("Failed to update the ", pMarket, " Order= ",(string)orderInfo.Ticket(), " Reason= ", ctrade.ResultRetcodeDescription());                    
            }
         }        
      }
   }

   void _PositionOpen(string pMarket, string pDirection, string pReference, string pQuantity, string pStoploss, string pTakeprofit) {
      ulong ticket = -1; double stopprice = 0, takeprice = 0;
      for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyUtil::XSleep();
         }
         symbolInfo.RefreshRates();
         if ( MaximumSpreadPointCount > 0 && symbolInfo.Spread() > MaximumSpreadPointCount ) {
            CMyUtil::Info("Market: ", pMarket, " attempt:", (string)itr, ", failed to open Position, current spread= ", (string)symbolInfo.Spread(), " > maximum spread allowed= ", (string)MaximumSpreadPointCount);
            continue;
         }
         double priceOpen = pDirection == DEFINE_TRADE_DIR_LONG ? symbolInfo.Ask() : symbolInfo.Bid();
         priceOpen = CMyUtil::NormalizePrice(pMarket, priceOpen);
         double sl = this._ReadPriceFromString(pStoploss, pMarket, pDirection, priceOpen, true, false);
         double tp = this._ReadPriceFromString(pTakeprofit, pMarket, pDirection, priceOpen, false, true); 
         ENUM_ORDER_TYPE orderType = pDirection == DEFINE_TRADE_DIR_LONG ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         
         double lots_array[]; 
         ArrayResize(lots_array, 0);        
         this._ParseQuantityFromString(pQuantity, pMarket, pDirection, priceOpen, sl, lots_array);               
         if ( ArraySize(lots_array) > 0 ) {
            for ( int x = 0; x < ArraySize(lots_array); x++ ) {   
               ctrade.SetDeviationInPoints(MaximumSpreadPointCount*10);
               bool succeded = ctrade.PositionOpen(pMarket, orderType, lots_array[x], priceOpen, sl, tp, pReference);
               if ( succeded ) {            
                  ticket = ctrade.ResultOrder();
                  CMyUtil::Info("Opened a new ", pMarket, " Position= ",(string)ticket);                  
               } else {
                  CMyUtil::Info("Failed to open the new ", pMarket, " Position. Reason= ", ctrade.ResultRetcodeDescription());
               } 
               CMyUtil::XSleep(1000);
            }
            break;
         }
      }
   }

   void _OrderOpen(string pMarket, string pDirection, string pReference, string pQuantity, string pPriceOpen, string pStoploss, string pTakeprofit, string pExpiry) {
      ulong ticket = -1; double stopprice = 0, takeprice = 0;         
      for ( uint itr = 1 ; itr <= DEFINE_TRADE_RETRY_COUNT ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyUtil::XSleep();
         }
         symbolInfo.RefreshRates();
         double priceOpen = CMyUtil::NormalizePrice(pMarket, StringToDouble(pPriceOpen));
         ENUM_ORDER_TYPE orderType; 
         if ( pDirection == DEFINE_TRADE_DIR_LONG ) {
            orderType = priceOpen > symbolInfo.Ask() ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT;            
         } else {
            orderType = priceOpen < symbolInfo.Bid() ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT;      
         }            
         double sl = this._ReadPriceFromString(pStoploss, pMarket, pDirection, priceOpen, true, false);
         double tp = this._ReadPriceFromString(pTakeprofit, pMarket, pDirection, priceOpen, false, true);           
         long minutesExp = StringLen(pExpiry) > 0 ? StringToInteger(pExpiry) : 0;    
         long expiryNew = minutesExp > 0 ? (datetime)(TimeTradeServer() + (minutesExp * 60)) : 0;   
         ENUM_ORDER_TYPE_TIME timeType = expiryNew > 0 ? ORDER_TIME_SPECIFIED : ORDER_TIME_GTC;    
         
         double lots_array[]; 
         ArrayResize(lots_array, 0);    
         this._ParseQuantityFromString(pQuantity, pMarket, pDirection, priceOpen, sl, lots_array);           
         if ( ArraySize(lots_array) > 0 ) {
            for ( int x = 0; x < ArraySize(lots_array); x++ ) {            
               ctrade.SetDeviationInPoints(MaximumSpreadPointCount*10);
               bool succeded = ctrade.OrderOpen(pMarket, orderType, lots_array[x], 0, priceOpen, sl, tp, timeType, expiryNew, pReference);
               if ( succeded ) {
                  ticket = ctrade.ResultOrder();
                  CMyUtil::Info("Opened a new ", pMarket, " Order= ",(string)ticket);
                  
               } else {
                  CMyUtil::Info("Failed to open the new ", pMarket, " Order. Reason= ", ctrade.ResultRetcodeDescription());
               } 
               CMyUtil::XSleep(1000);
            }
            break;            
         }
      }
   }
   
   const void _ProcessSignal(string pSignal) { 
      ResetLastError();
      CMyUtil::Info("Expert received the signal= ", pSignal); 
      string options[];
      int count = this._SignalSplit(pSignal, " ", options);
      if ( count < 3 ) {
         CMyUtil::Info("Received signal is incomplete!"); return;  
      }      
      string value, command="", plus="", market="", direction="", quantity="", priceopen="", stoploss="", takeprofit="", expiry="", 
               reference="", account="", ticket = "";
      for (int i=0; i < count; i++) {
         command     = (value = this._SignalCommand(options[i])) != "" ? value : command;
         plus        = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_PLUS)) != "" ? value : plus;
         market      = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_MARKET)) != "" ? value : market;
         direction   = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_DIRECTION)) != "" ? value : direction;
         reference   = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_REFERENCE)) != "" ? value : reference;
         quantity    = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_QUANTITY)) != "" ? value : quantity;
         priceopen   = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_PRICEOPEN)) != "" ? value : priceopen; 
         stoploss    = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_STOPLOSS)) != "" ? value : stoploss;
         takeprofit  = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_TAKEPROFIT)) != "" ? value : takeprofit;
         expiry      = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_EXPIRY)) != "" ? value : expiry;         
         account     = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_ACCOUNT)) != "" ? value : account;      
         ticket      = (value = this._SignalOptionValue(options[i], DEFINE_SIGNAL_OPTION_TICKET)) != "" ? value : ticket;      
      }
      if ( _CheckSignalTargetAccount(account) == false ) {
         CMyUtil::Info("Received signal's value for account=",account," doesn't have current account number!"); return; 
      }
      if ( StringLen(command) == 0 ) { CMyUtil::Info("Received signal have no command value!"); return; }
      if ( StringLen(plus) == 0 ) { CMyUtil::Info("Received signal have no '", DEFINE_SIGNAL_OPTION_PLUS, "' value!"); return; }
      if ( plus != DEFINE_ROBOT_PLUS_CODE ) { CMyUtil::Info("Received signal have no '", DEFINE_SIGNAL_OPTION_PLUS, "=", DEFINE_ROBOT_PLUS_CODE,"' value!"); return; }
      if ( StringLen(market) == 0 ) { CMyUtil::Info("Received signal have no '", DEFINE_SIGNAL_OPTION_MARKET, "' value!"); return; }      
      if ( StringLen(direction) > 0 && direction != DEFINE_TRADE_DIR_LONG && direction != DEFINE_TRADE_DIR_SHORT ) { 
         CMyUtil::Info("Received signal have invalid '", DEFINE_SIGNAL_OPTION_DIRECTION, "' value!"); return;
      }    
      
      market = this._MapMarketSymbolToBrokerSpecific(market);   
      //--- initialize the symbol
      symbolInfo.Name(market);
      if (  symbolInfo.CheckMarketWatch() == false || CMyUtil::CheckMarketOpen(market) == false ) { return; } 
      ctrade.SetTypeFillingBySymbol(market);
      //--- execute trades
      if ( command == DEFINE_SIGNAL_COMMAND_OPEN ) {
         if ( StringLen(direction) == 0 ) { CMyUtil::Info("Received signal must have '", DEFINE_SIGNAL_OPTION_DIRECTION, "' value!"); return; }
         
         if ( StringLen(priceopen) > 0 ) {
            this._OrderOpen(market, direction, reference, quantity, priceopen, stoploss, takeprofit, expiry);
         } else {
            this._PositionOpen(market, direction, reference, quantity, stoploss, takeprofit);
         }
      }
      else if ( command == DEFINE_SIGNAL_COMMAND_MODIFY ) {
         if ( StringLen(direction) == 0 ) { CMyUtil::Info("Received signal must have '", DEFINE_SIGNAL_OPTION_DIRECTION, "' value!"); return; }
         
         this._PositionModify(ticket, market, direction, reference, stoploss, takeprofit);            
         this._OrderModify(ticket, market, direction, reference, priceopen, stoploss, takeprofit, expiry);
      }
      else if ( command == DEFINE_SIGNAL_COMMAND_CLOSE ) {
         this._PositionClose(ticket, market, direction, reference);
      }
      else if ( command == DEFINE_SIGNAL_COMMAND_DELETE ) {
         this._OrderDelete(ticket, market, direction, reference);
      }
      
   }   

protected:      
   //--- parameterized configuration
   long     AlgoId; // Magic Number
   int      MaximumSpreadPointCount; // Maximum Spread points, 50 points -> 5 pips  
   bool     UseAccountFreeMargin; // Use Account Free Margin instead of Account Balance   
   string   BrokerSymbolMappings; // Maps a given market symbol to broker specific symbol
   double   RiskMultiplier; // Multiplier value of the given risk
   double   StoplossMultiplier; // Multiplier of the stoploss distance

   virtual int    OnStartAlgo()  = 0;
   virtual void   OnUpdateAlgo()   = 0;
   virtual void   OnStopAlgo()   = 0;   
   
   void AddSignal(string pSignal) {
      CMyUtil::Debug(__FUNCTION__, " ", pSignal);
      if (StringLen(pSignal) == 0) return;
      int arr_length = ArraySize(mSignalArray);
      ArrayResize(mSignalArray, arr_length+1);
      mSignalArray[arr_length] = pSignal;   
   }
  
public:

   CMyAlgo() : AlgoId(0),
               MaximumSpreadPointCount(9000), 
               UseAccountFreeMargin(true),
               BrokerSymbolMappings(""),
               RiskMultiplier(1),
               StoplossMultiplier(1)                 
               
   {  
      ArrayResize(mSignalArray, 0);
      CMyUtil::Debug(__FUNCTION__, " is called");
   }

   ~CMyAlgo() {
      CMyUtil::Debug(__FUNCTION__, " is called");
   }
   
   const int Start() {      
      ctrade.SetAsyncMode(DEFINE_TRADE_ASYNC_MODE);
      ctrade.SetMarginMode();          
      int ret = this.OnStartAlgo();
      if ( ret == INIT_SUCCEEDED ) {
         ctrade.SetExpertMagicNumber(AlgoId);
         CMyUtil::Info("Algo: ", (string)AlgoId, " started!");
      } else {
         CMyUtil::Info("Algo: ", (string)AlgoId, " startup failed!");
         ret = INIT_FAILED;
      }   
      return ret;
   }
  
   const void Update() {     
      this.OnUpdateAlgo();   
         /*static int lastBarsPeriodCurrent;
         int countBarsPeriodX = iBars(NULL, 0);
         if ( lastBarsPeriodCurrent != countBarsPeriodX ) {
            lastBarsPeriodCurrent = countBarsPeriodX;
            //Do something
         }*/      
      if ( ArraySize(mSignalArray) > 0 ) {
         for ( int sindex = 0; sindex < ArraySize(mSignalArray); sindex++ ) {
            this._ProcessSignal(mSignalArray[sindex]);
         }
      }      
      ArrayResize(mSignalArray, 0);          
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
  
   void _Update() {      
      static bool in_update = false;
      if (in_update) return;
      in_update = true; 
      
      //CMyUtil::Debug(__FUNCTION__, " is called");
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         mAlgoArray[i].Update();
      } 
      mAppWidget.Update();
      CMyUtil::FlagTerminalLostConnection(60*10);
      in_update = false;   
   }
   
public:

   CMyRobot() : mTimerSeconds(0){
      ArrayResize(mAlgoArray, 0);      
      CMyUtil::Debug(__FUNCTION__, " is called");
   }

   ~CMyRobot() {
      CMyUtil::Debug(__FUNCTION__, " is called");
   }

   const int Start(string pRobotName, int pTimerSeconds, string pLicenseKey, CMyAlgo* &pAlgo[]) {      
      CMyUtil::Debug(__FUNCTION__, " ", pRobotName);
      TesterHideIndicators(DEFINE_ROBOT_TESTER_HIDE_INDICATORS); 
      ResetLastError();
      
      string mqlProgramName = MQLInfoString(MQL_PROGRAM_NAME);
      if ( pRobotName != mqlProgramName ) {
         CMyUtil::Info("Invalid file name= '", mqlProgramName, "' owned by the expert, it must be '", pRobotName, "'.");
         return (INIT_PARAMETERS_INCORRECT);
      }
      bool hasValidLicense = CMyUtil::CheckValidLicense(pLicenseKey);
      if  ( DEFINE_ROBOT_ENFORCE_LICENSE && hasValidLicense == false ) {
         CMyUtil::Info("Invalid License Key= '", pLicenseKey, "' configured in the expert.");
         return (INIT_PARAMETERS_INCORRECT);
      }
      if ( AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ) {
         CMyUtil::Info("Running on a Demo Account!");
      }
      mTimerSeconds = pTimerSeconds;
      if (CMyUtil::IsTesting()) {
         mTimerSeconds = 0;
         CMyUtil::Info("Running on Strategy Tester!");
      }
      ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
      if ( margin_mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING ) {
         CMyUtil::Info("Account has no retail hedging!");         
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
      ChartRedraw();
      if (mTimerSeconds > 0) {
         EventSetTimer(mTimerSeconds); 
      }
      CMyUtil::Info(mqlProgramName, " started successfully!");
      return (INIT_SUCCEEDED);
   }

   const void Stop(const int pReason) { 
      CMyUtil::Debug(__FUNCTION__, " ", (string)pReason); 
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
      CMyUtil::CheckDeinitReason(pReason);
   }
   
   const void UpdateTimer() {  
      if (mTimerSeconds > 1) {
         //CMyUtil::RefreshRates(CurrentSymbol()); //-- force refresh ticks
         _Update();
      }
   }
   
   const void UpdateTick() {
      if (mTimerSeconds <= 1) {
         _Update();
      }
   }

};

//+------------------------------------------------------------------+
//| Framework implementation end                                     |
//+------------------------------------------------------------------+

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
