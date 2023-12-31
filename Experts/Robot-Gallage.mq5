//+------------------------------------------------------------------+
//|                                                Robot-Gallage.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "22.06"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

#include <Arrays/ArrayLong.mqh>
#include <Generic/HashSet.mqh>
#include <Trade/DealInfo.mqh>
#include <Trade/HistoryOrderInfo.mqh>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//| Framework implementation start                                   |
//+------------------------------------------------------------------+

#define DEF_MY_ENFORCE_LICENSE   false
#define DEF_MY_ROBOT_NAME  "Robot-Gallage"
#define DEF_MY_ASYNC_MODE  false
#define DEF_MY_TESTER_HIDE_INDICATORS  false
#define DEF_MY_DEBUG  false

class CMyCandlePatternHelper {

protected:

   virtual void  _Name() = NULL;   // A pure virtual function to make this class abstract

public:

   static bool PatternHammer(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {

      double H = iHigh(pSymbol, pTimeframe, pShift);
      double L = iLow(pSymbol, pTimeframe, pShift);
      double L1 = iLow(pSymbol, pTimeframe, pShift + 1);
      double L2 = iLow(pSymbol, pTimeframe, pShift + 2);
      double L3 = iLow(pSymbol, pTimeframe, pShift + 3);

      double O = iOpen(pSymbol, pTimeframe, pShift);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double CL = H - L;

      double BodyLow, BodyHigh;
      double Candle_WickBody_Percent = 0.9;
      int CandleLength = 120;

      if (O > C) {
         BodyHigh = O;
         BodyLow = C;
      } else {
         BodyHigh = C;
         BodyLow = O;
      }

      double LW = BodyLow - L;
      double UW = H - BodyHigh;
      double BLa = MathAbs(O - C);
      double BL90 = BLa * Candle_WickBody_Percent;

      double diffDecimal = CMyToolkit::ToPointDecimal(pSymbol, CandleLength);

      if ((L <= L1) && (L < L2) && (L < L3))  {
         if (((LW / 2) > UW) && (LW > BL90) && (CL >= (diffDecimal)) && (O != C) && ((LW / 3) <= UW) && ((LW / 4) <= UW)/*&&(H<H1)&&(H<H2)*/)  {
            return(true);
         }
         if (((LW / 3) > UW) && (LW > BL90) && (CL >= (diffDecimal)) && (O != C) && ((LW / 4) <= UW)/*&&(H<H1)&&(H<H2)*/)  {
            return(true);
         }
         if (((LW / 4) > UW) && (LW > BL90) && (CL >= (diffDecimal)) && (O != C)/*&&(H<H1)&&(H<H2)*/)  {
            return(true);
         }
      }
      return (false);
   }

   static bool PatternPiercingLine(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double L = iLow(pSymbol, pTimeframe, pShift);
      double H = iHigh(pSymbol, pTimeframe, pShift);

      double O = iOpen(pSymbol, pTimeframe, pShift);
      double O1 = iOpen(pSymbol, pTimeframe, pShift + 1);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double C1 = iClose(pSymbol, pTimeframe, pShift + 1);
      double CL = H - L;

      double CO_HL;
      if((H - L) != 0) {
         CO_HL = (C - O) / (H - L);
      } else {
         CO_HL = 0;
      }

      double Piercing_Line_Ratio = 0.5;
      int Piercing_Candle_Length = 100;
      double Candle_size = CMyToolkit::ToPointDecimal(pSymbol, Piercing_Candle_Length);

      if ((C1 < O1) && (((O1 + C1) / 2) < C) && (O < C) && (CO_HL > Piercing_Line_Ratio) && (CL >= Candle_size)) {
         return(true);
      }
      return (false);
   }

   static bool PatternShootingStar(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double L = iLow(pSymbol, pTimeframe, pShift);
      double H = iHigh(pSymbol, pTimeframe, pShift);
      double H1 = iHigh(pSymbol, pTimeframe, pShift + 1);
      double H2 = iHigh(pSymbol, pTimeframe, pShift + 2);
      double H3 = iHigh(pSymbol, pTimeframe, pShift + 3);

      double O = iOpen(pSymbol, pTimeframe, pShift);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double CL = H - L;

      double BodyLow, BodyHigh;
      double Candle_WickBody_Percent = 0.9;
      int CandleLength = 120;

      if (O > C) {
         BodyHigh = O;
         BodyLow = C;
      } else {
         BodyHigh = C;
         BodyLow = O;
      }

      double LW = BodyLow - L;
      double UW = H - BodyHigh;
      double BLa = MathAbs(O - C);
      double BL90 = BLa * Candle_WickBody_Percent;

      double CandelSize = CMyToolkit::ToPointDecimal(pSymbol, CandleLength);

      if ((H >= H1) && (H > H2) && (H > H3))  {
         if (((UW / 2) > LW) && (UW > (2 * BL90)) && (CL >= (CandelSize)) && (O != C) && ((UW / 3) <= LW) && ((UW / 4) <= LW)/*&&(L>L1)&&(L>L2)*/)  {
            return(true);
         }
         if (((UW / 3) > LW) && (UW > (2 * BL90)) && (CL >= (CandelSize)) && (O != C) && ((UW / 4) <= LW)/*&&(L>L1)&&(L>L2)*/)  {
            return(true);
         }
         if (((UW / 4) > LW) && (UW > (2 * BL90)) && (CL >= (CandelSize)) && (O != C)/*&&(L>L1)&&(L>L2)*/)  {
            return(true);
         }
      }
      return(false);
   }

   static bool PatternBearishEngulfing(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double O = iOpen(pSymbol, pTimeframe, pShift);
      double O1 = iOpen(pSymbol, pTimeframe, pShift + 1);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double C1 = iClose(pSymbol, pTimeframe, pShift + 1);

      if ((C1 > O1) && (O > C) && (O >= C1) && (O1 >= C) && ((O - C) > (C1 - O1))) {
         return(true);
      }
      return(false);
   }

   static bool PatternBullishEngulfing(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double O = iOpen(pSymbol, pTimeframe, pShift);
      double O1 = iOpen(pSymbol, pTimeframe, pShift + 1);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double C1 = iClose(pSymbol, pTimeframe, pShift + 1);

      if ((O1 > C1) && (C > O) && (C >= O1) && (C1 >= O) && ((C - O) > (O1 - C1))) {
         return(true);
      }
      return(false);
   }

   static bool PatternDarkCloudCover(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double L = iLow(pSymbol, pTimeframe, pShift);
      double H = iHigh(pSymbol, pTimeframe, pShift);

      double O = iOpen(pSymbol, pTimeframe, pShift);
      double O1 = iOpen(pSymbol, pTimeframe, pShift + 1);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double C1 = iClose(pSymbol, pTimeframe, pShift + 1);
      double CL = H - L;

      double OC_HL;
      if((H - L) != 0) {
         OC_HL = (O - C) / (H - L);
      } else {
         OC_HL = 0;
      }

      double Piercing_Line_Ratio = 0.5;
      int Piercing_Candle_Length = 100;
      double CandleSize = CMyToolkit::ToPointDecimal(pSymbol, Piercing_Candle_Length);

      if ((C1 > O1) && (((C1 + O1) / 2) > C) && (O > C) && (C > O1) && (OC_HL > Piercing_Line_Ratio) && (CL >= CandleSize)) {
         return(true);
      }
      return(false);
   }

   static bool PatternBearishHarami(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double O = iOpen(pSymbol, pTimeframe, pShift);
      double O1 = iOpen(pSymbol, pTimeframe, pShift + 1);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double C1 = iClose(pSymbol, pTimeframe, pShift + 1);

      if ((C1 > O1) && (O > C) && (O <= C1) && (O1 <= C) && ((O - C) < (C1 - O1))) {
         return(true);
      }
      return(false);
   }

   static bool PatternBullishHarami(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pShift) {
      double O = iOpen(pSymbol, pTimeframe, pShift);
      double O1 = iOpen(pSymbol, pTimeframe, pShift + 1);
      double C = iClose(pSymbol, pTimeframe, pShift);
      double C1 = iClose(pSymbol, pTimeframe, pShift + 1);

      if ((O1 > C1) && (C > O) && (C <= O1) && (C1 <= O) && ((C - O) < (O1 - C1))) {
         return(true);
      }
      return(false);
   }

   static double FibonacciRetracement(ENUM_ORDER_TYPE pOrderType, double pFiboLevel, double pSwingHighPrice, double pSwingLowPrice) {
      double zFibPrice;
      if(pOrderType == ORDER_TYPE_BUY || pOrderType == ORDER_TYPE_BUY_LIMIT || pOrderType == ORDER_TYPE_BUY_STOP || pOrderType == ORDER_TYPE_BUY_STOP_LIMIT) {
         // C = B — (B — A) x N%
         zFibPrice = MathFloor(pSwingHighPrice - ((pSwingHighPrice - pSwingLowPrice) * pFiboLevel));
      } else {
         // C = B + (A — B) x N%
         zFibPrice = MathFloor(pSwingLowPrice + ((pSwingHighPrice - pSwingLowPrice) * pFiboLevel));
      }
      return zFibPrice;
   }

   static double FibonacciExtension(ENUM_ORDER_TYPE pOrderType, double pFiboLevel, double pSwingHighPrice, double pSwingLowPrice) {
      double zFibPrice;
      if(pOrderType == ORDER_TYPE_BUY || pOrderType == ORDER_TYPE_BUY_LIMIT || pOrderType == ORDER_TYPE_BUY_STOP || pOrderType == ORDER_TYPE_BUY_STOP_LIMIT) {
         // D = B + (B — A) x N%
         zFibPrice = MathFloor(pSwingHighPrice + ((pSwingHighPrice - pSwingLowPrice) * pFiboLevel));
      } else {
         // D = B — (A — B) x N%
         zFibPrice = MathFloor(pSwingLowPrice - ((pSwingHighPrice - pSwingLowPrice) * pFiboLevel));
      }
      return zFibPrice;
   }

};

class CMyHistoryPositionInfo {
protected:
   ulong             m_curr_ticket;        // ticket of closed position
   CArrayLong        m_tickets;
   CDealInfo         m_curr_deal;
   
   bool HistoryPositionSelect(long position_id) {
      if(!HistorySelectByPosition(position_id)) {
         CMyToolkit::XPrint(__FUNCTION__+" > Error: HistorySelectByPosition -> false. Error Code: ", IntegerToString(GetLastError()));
         return(false);
      }
      return(true);
   }
   bool HistoryPositionCheck(int log_level) {
      //--- the first check - surely has to be one IN and one or more OUT
      int deals=HistoryDealsTotal();
      if(deals<2) {
         if(log_level>0) CMyToolkit::XPrint(__FUNCTION__+" > Error: the selected position is still open.");
         return(false);
      }
      double pos_open_volume=0;
      double pos_close_volume=0;
      for(int j = 0; j < deals; j++) {
         if(m_curr_deal.SelectByIndex(j)) {
            if(m_curr_deal.Entry()==DEAL_ENTRY_IN)
               pos_open_volume=m_curr_deal.Volume();
            else
               if(m_curr_deal.Entry()==DEAL_ENTRY_OUT || m_curr_deal.Entry()==DEAL_ENTRY_OUT_BY)
                  pos_close_volume+=m_curr_deal.Volume();
         } else {
            CMyToolkit::XPrint(__FUNCTION__+" > Error: failed to select deal at index #", IntegerToString(j));
            return(false);
         }
      }
      //--- the second check - the total volume of IN minus OUT has to be equal to zero
      //--- If a position is still open, it will not be displayed in the history.
      if(MathAbs(pos_open_volume-pos_close_volume)>0.00001) {
         if(log_level>0) CMyToolkit::XPrint(__FUNCTION__+" > Error: the selected position is not yet fully closed.");
         return(false);
      }
      return(true);
   }   

public:
   CMyHistoryPositionInfo(){
      //CMyToolkit::XPrint("__FUNCTION__ = ", __FUNCTION__, " is called");
   }   
   ~CMyHistoryPositionInfo() {    
      //CMyToolkit::XPrint("__FUNCTION__ = ", __FUNCTION__, " is called");                
   }
   ulong Ticket() { return(m_curr_ticket); }   
   ENUM_POSITION_TYPE PositionType() {
      ENUM_POSITION_TYPE pos_type = WRONG_VALUE;
      if(m_curr_ticket)
         if(m_curr_deal.SelectByIndex(0))
            pos_type = (ENUM_POSITION_TYPE)m_curr_deal.DealType();
      return(pos_type);   
   }
   long Magic() {
      long pos_magic = WRONG_VALUE;
      if(m_curr_ticket)
         if(m_curr_deal.SelectByIndex(0))
            pos_magic = m_curr_deal.Magic();
      return(pos_magic);   
   }
   double Volume() {
      double pos_volume = WRONG_VALUE;
      if(m_curr_ticket)
         if(m_curr_deal.SelectByIndex(0))
            pos_volume = m_curr_deal.Volume();
      return(pos_volume);   
   }
   double Profit() {
      double pos_profit = 0;
      if(m_curr_ticket)
         for(int i = 0; i < HistoryDealsTotal(); i++)
            if(m_curr_deal.SelectByIndex(i))
               if(m_curr_deal.Entry()==DEAL_ENTRY_OUT || m_curr_deal.Entry()==DEAL_ENTRY_OUT_BY)
                  pos_profit += m_curr_deal.Profit();
      return(pos_profit);   
   }
   string Symbol() {
      string pos_symbol = NULL;
      if(m_curr_ticket)
         if(m_curr_deal.SelectByIndex(0))
            pos_symbol = m_curr_deal.Symbol();
      return(pos_symbol);   
   }
   bool HistorySelect(datetime from_date,datetime to_date){
   //--- request the history of deals and orders for the specified period
      if(!::HistorySelect(from_date,to_date))
        {
         CMyToolkit::XPrint(__FUNCTION__+" > Error: HistorySelect -> false. Error Code: ", IntegerToString(GetLastError()));
         return(false);
        }
   
   //--- clear all cached position ids on new requests to the history
      m_tickets.Shutdown();
   
   //--- define a hashset to collect position IDs (with no duplicates)
      CHashSet<long>set_positions;
      long curr_pos_id;
   
   //--- collect position ids of history deals into the hashset,
   //--- handle the case when a position has multiple deals out.
      int deals = HistoryDealsTotal();
      //for(int i = 0; i < deals && !IsStopped(); i++)
      for(int i = deals-1; i >= 0 && !IsStopped(); i--)
         if(m_curr_deal.SelectByIndex(i))
            //if(m_curr_deal.Entry()==DEAL_ENTRY_IN)
            if(m_curr_deal.Entry()==DEAL_ENTRY_OUT || m_curr_deal.Entry()==DEAL_ENTRY_OUT_BY)
               if(m_curr_deal.DealType()==DEAL_TYPE_BUY || m_curr_deal.DealType()==DEAL_TYPE_SELL)
                  if((curr_pos_id=m_curr_deal.PositionId())>0)
                     set_positions.Add(curr_pos_id);
   
      long arr_positions[];
   //--- copy the elements from the set to a compatible one-dimensional array
      set_positions.CopyTo(arr_positions,0);
      ArraySetAsSeries(arr_positions,true);
   
   //--- filter out all the open or partially closed positions.
   //--- copy the remaining fully closed positions to the member array
      int positions = ArraySize(arr_positions);
      for(int i = 0; i < positions && !IsStopped(); i++)
         if((curr_pos_id=arr_positions[i])>0)
            if(HistoryPositionSelect(curr_pos_id))
               if(HistoryPositionCheck(0))
                  if(!m_tickets.Add(curr_pos_id))
                    {
                     CMyToolkit::XPrint(__FUNCTION__+" > Error: failed to add position ticket #", IntegerToString(curr_pos_id));
                     return(false);
                    }
      return(true);   
   }
   int PositionsTotal() {
      return(m_tickets.Total());   
   }
   bool SelectByTicket(ulong ticket) {
      if(HistoryPositionSelect(ticket)) {
         if(HistoryPositionCheck(1)) {
            m_curr_ticket = ticket;
            return(true);
         }
      }
      m_curr_ticket = 0;
      return(false);   
   }
   bool SelectByIndex(int index) {
      ulong curr_pos_ticket = m_tickets.At(index);
      if(curr_pos_ticket<LONG_MAX) {
         if(HistoryPositionSelect(curr_pos_ticket)) {
            m_curr_ticket = curr_pos_ticket;
            return(true);
         }
      }
      else {
         CMyToolkit::XPrint(__FUNCTION__+" > Error: the index of selection is out of range.");
      }
      m_curr_ticket = 0;
      return(false);   
   }
};

class CMyToolkit {

protected:

   virtual void  _Name() = NULL;   // A pure virtual function to make this class abstract

public:

   static void XPrint(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "") {
      string xTxt;
      StringConcatenate(xTxt, " --LOG-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10);
      Print(xTxt);
   }
   
   static void XDebug(string p1 = "", string p2 = "", string p3 = "", string p4 = "", string p5 = "", string p6 = "", string p7 = "", string p8 = "", string p9 = "", string p10 = "") {
      if ( DEF_MY_DEBUG ) {
         string xTxt;
         StringConcatenate(xTxt, " --LOG-- ", p1, p2, p3, p4, p5, p6, p7, p8, p9, p10);
         Print(xTxt);      
      }
   }   

   static void XSleep(int pMilliseconds = 5000) {
      Sleep(pMilliseconds);
      XPrint("Sleep(", (string)pMilliseconds, ") done, MarketSession: ", CurrentMarketSession());
   }
   
   static bool IsTesting() {
      if ( (bool)MQLInfoInteger(MQL_DEBUG) || (bool)MQLInfoInteger(MQL_PROFILER) || (bool)MQLInfoInteger(MQL_TESTER) ||
           (bool)MQLInfoInteger(MQL_FORWARD) || (bool)MQLInfoInteger(MQL_OPTIMIZATION) || (bool)MQLInfoInteger(MQL_VISUAL_MODE) || 
           (bool)MQLInfoInteger(MQL_FRAME_MODE) ) {
         return true;
      }   
      return false;
   }

   static double NormalizePrice(string pSymbol, double pPrice) {
      int udigits = (int)SymbolInfoInteger(pSymbol, SYMBOL_DIGITS);
      double uticksize = SymbolInfoDouble(pSymbol, SYMBOL_TRADE_TICK_SIZE);
      double uprice  = NormalizeDouble(pPrice, udigits);
      uprice = MathRound(uprice / uticksize) * uticksize; //-- fix prices by ticksize
      return uprice;
   }

   static double NormalizeLots(string pSymbol, double pLots) {
      double uvolumeStep = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_STEP);
      double ulots = MathRound(pLots / uvolumeStep) * uvolumeStep; //-- normallize to a multiple of lotstep accepted by the broker
      return ulots;
   }

   static double ToPointDecimal(string pSymbol, uint pPointsCount) {
      int udigits = (int)SymbolInfoInteger(pSymbol, SYMBOL_DIGITS);
      double upointDecimal = SymbolInfoDouble(pSymbol, SYMBOL_POINT);
      return NormalizeDouble(upointDecimal * pPointsCount, udigits);

   }

   static int ToPointsCount(string pSymbol, double pDecimalValue) {
      double upointDecimal = SymbolInfoDouble(pSymbol, SYMBOL_POINT);
      return (int)((1 / upointDecimal) * pDecimalValue);
   }

   static int ToTicksCount(string pSymbol, uint pPointsCount) {
      // https://forum.mql4.com/43064#515262 for non-currency DE30:
      // SymbolInfoDouble(chart.symbol, SYMBOL_TRADE_TICK_SIZE) returns 0.5
      // SymbolInfoInteger(chart.symbol,SYMBOL_DIGITS) returns 1
      // SymbolInfoInteger(chart.symbol,SYMBOL_POINT) returns 0.1
      // Prices to open must be a multiple of ticksize
      double uticksize = SymbolInfoDouble(pSymbol, SYMBOL_TRADE_TICK_SIZE);
      int utickscount = (int)((pPointsCount / uticksize) * uticksize); //-- fix prices by ticksize
      return utickscount;
   }

   static void ShowComment(string pText) {
      string xTxt = "";
      StringConcatenate(xTxt, xTxt, "\n", "\n", "********* ", DEF_MY_ROBOT_NAME, " *********");
      StringConcatenate(xTxt, xTxt, "\n", "********* ", "Account:     ", AccountInfoInteger(ACCOUNT_LOGIN), "  , Leverage: ", AccountInfoInteger(ACCOUNT_LEVERAGE), " *********");
      StringConcatenate(xTxt, xTxt, "\n", "********* ", "Broker:        ", AccountInfoString(ACCOUNT_COMPANY), "  , Server: ", AccountInfoString(ACCOUNT_SERVER), " *********");
      StringConcatenate(xTxt, xTxt, "\n", "********* ", "Session:      ", CurrentMarketSession(), " *********");
      StringConcatenate(xTxt, xTxt, "\n", "********* ", pText, " *********");

      Comment(xTxt);
   }

   static uint GetAlgoMagicNumber(string pAlgoName) {
      int charCode = 0, magic = 1000;

      string zStr = DEF_MY_ROBOT_NAME;
      for(int itr = 0; itr < StringLen(zStr); itr++) {
         charCode = StringGetCharacter(zStr, itr);
         magic += charCode;
      }

      zStr = pAlgoName;
      for(int itr = 0; itr < StringLen(zStr); itr++) {
         charCode = StringGetCharacter(zStr, itr);
         magic += charCode;
      }

      return magic;
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

   static datetime _GetBarTime( const datetime pTime, const bool pNextBar = false, string pSymbol = NULL, const ENUM_TIMEFRAMES pTimeFrame = PERIOD_M1 ) {
      return (iTime(pSymbol, pTimeFrame, iBarShift(pSymbol, pTimeFrame, pTime) - (pNextBar ? 1 : 0)));
   }

   static datetime _GetTimeDayOfWeek( const int pShift = 0, const ENUM_DAY_OF_WEEK pDay = SUNDAY ) {
      int week = 7;
      int daySeconds = PeriodSeconds(PERIOD_D1);
      const datetime res = (TimeServerCurrent() / daySeconds) * daySeconds;
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

   static datetime TimeServerCurrent() {
      return TimeCurrent();
   }

   static datetime TimeServerGMT(datetime pServerLocalTime = 0) {
      if(pServerLocalTime == NULL || pServerLocalTime == 0) {
         pServerLocalTime = TimeServerCurrent();
      }
      return (pServerLocalTime + _GetTimeDifferenceGMTFromServer());
   }

   static bool CheckTradingSessionTime(double pStartTimeGMT, double pEndTimeGMT) {
      //    London         8.00  to 17.00          Frankfurt      7.00  to 16.00
      //    Newyork        13.00 to 22.00          Chicago        14.00 to 23.00
      //    Sydney         22.00 to 7.00           Tokyo          0.00  to 9.00
      bool _ok = false;
      MqlDateTime mqlDT;
      TimeToStruct(TimeServerGMT(0), mqlDT);
      double _decimalTime = mqlDT.hour + (mqlDT.min / 100); // GMT server time as a decimal value

      if(pStartTimeGMT < pEndTimeGMT) {
         if(_decimalTime >= pStartTimeGMT && _decimalTime <= pEndTimeGMT) {
            _ok = true;
         }
      }
      if(pStartTimeGMT >= pEndTimeGMT) {
         if(_decimalTime >= pStartTimeGMT || _decimalTime <= pEndTimeGMT) {
            _ok = true;
         }
      }
      return (_ok);
   }

   static string CurrentMarketSession() {
      string _session = "";
      CheckTradingSessionTime(22.00, 7.00) ? StringConcatenate(_session, _session, "Sydney ") : StringConcatenate(_session, _session, "");
      CheckTradingSessionTime(0.00, 9.00) ? StringConcatenate(_session, _session, "Tokyo ") : StringConcatenate(_session, _session, "");
      CheckTradingSessionTime(7.00, 16.00) ? StringConcatenate(_session, _session, "Frankfurt ") : StringConcatenate(_session, _session, "");
      CheckTradingSessionTime(8.00, 17.00) ? StringConcatenate(_session, _session, "London ") : StringConcatenate(_session, _session, "");
      CheckTradingSessionTime(13.00, 22.00) ? StringConcatenate(_session, _session, "Newyork ") : StringConcatenate(_session, _session, "");
      CheckTradingSessionTime(14.00, 23.00) ? StringConcatenate(_session, _session, "Chicago ") : StringConcatenate(_session, _session, "");
      return _session;
   }

   static bool CheckTradingDay(bool pWeekEnds, bool pNFP_Friday, bool pNFP_ThursdayBefore, bool pChristmasHolidays, int pXMAS_DayBeginBreak, bool pNewYearsHolidays, int pNewYears_DayEndBreak) {
      bool _ok = true;
      MqlDateTime mqlDT;
      TimeToStruct(TimeServerCurrent(), mqlDT);
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

   static double GetPriceHighest(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pBarCount, int pStartBarIndex = 0, int pExtraPoints = 0) {
      int val_index = iHighest(pSymbol, pTimeframe, MODE_HIGH, pBarCount, pStartBarIndex);
      double value = iHigh(pSymbol, pTimeframe, val_index);
      value = value + ToPointDecimal(pSymbol, pExtraPoints);
      return (value);
   }

   static double GetPriceLowest(string pSymbol, ENUM_TIMEFRAMES pTimeframe, int pBarCount, int pStartBarIndex = 0, int pExtraPoints = 0) {
      int val_index = iLowest(pSymbol, pTimeframe, MODE_LOW, pBarCount, pStartBarIndex);
      double value = iLow(pSymbol, pTimeframe, val_index);
      value = value - ToPointDecimal(pSymbol, pExtraPoints);
      return (value);
   }
   
   static double GetATRPointDecimal(string pSymbol, double pValueATR, int pExtraPointCount, double pMultiplier) {
         int atrPoints, totalPoints;
            
         atrPoints = (int)(pValueATR * MathPow(10, (int)SymbolInfoInteger(pSymbol, SYMBOL_DIGITS)));
         totalPoints = (int)MathCeil(pMultiplier*atrPoints) + pExtraPointCount;   
         return ToPointDecimal(pSymbol, totalPoints);
   }   

   static double _CurrencyMultiplicator(string pCurrencyPairAppendix = "") {
      double _multiplicator = 1.0;
      string xCurrency = AccountInfoString(ACCOUNT_CURRENCY);
      StringToUpper(xCurrency);

      if(xCurrency == "USD")
         return (_multiplicator);
      if(xCurrency == "EUR")
         _multiplicator = 1.0 / SymbolInfoDouble("EURUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "GBP")
         _multiplicator = 1.0 / SymbolInfoDouble("GBPUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "AUD")
         _multiplicator = 1.0 / SymbolInfoDouble("AUDUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "NZD")
         _multiplicator = 1.0 / SymbolInfoDouble("NZDUSD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "CHF")
         _multiplicator = SymbolInfoDouble("USDCHF" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "JPY")
         _multiplicator = SymbolInfoDouble("USDJPY" + pCurrencyPairAppendix, SYMBOL_BID);
      if(xCurrency == "CAD")
         _multiplicator = SymbolInfoDouble("USDCAD" + pCurrencyPairAppendix, SYMBOL_BID);
      if(_multiplicator == 0)
         _multiplicator = 1.0; // If account currency is neither of EUR, GBP, AUD, NZD, CHF, JPY or CAD we assumes that it is USD
      return (_multiplicator);
   }

   static double MaxUnitSizeAllowedForMargin(string pSymbol, double pMoneyCapital, double pAllowedMaxUnitSize) {
      // Calculate Lot size according to Equity.
      double _marginForOneLot, _maxLotsPossible;
      if(OrderCalcMargin(ORDER_TYPE_BUY, pSymbol, 1, SymbolInfoDouble(pSymbol, SYMBOL_ASK), _marginForOneLot)) { // Calculate margin required for 1 lot
         _maxLotsPossible = pMoneyCapital * 0.98 / _marginForOneLot;
         _maxLotsPossible = MathMin(_maxLotsPossible, MathMin(pAllowedMaxUnitSize, SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX)));
         _maxLotsPossible = NormalizeLots(pSymbol, _maxLotsPossible);
      } else {
         _maxLotsPossible = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX);
      }   
      return (_maxLotsPossible);
   }

   static double CalculateUnitSize(string pSymbol, double pMoneyCapital, double pRiskPercentage, int pStoplossPoints, double pAllowedMaxUnitSize, string pCurrencyPairAppendix = "") {
      //---Calculate LotSize based on Equity, Risk in decimal and StopLoss in points
      double _moneyRisk, _maxLotsPossible, _lotsByRisk, _lotSize;
      int _lotdigit = 2, _totalTickCount;

      _maxLotsPossible = MaxUnitSizeAllowedForMargin(pSymbol, pMoneyCapital, pAllowedMaxUnitSize);
      double _lotStep = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_STEP); // Step in lot size changing
      double _oneTickValue = SymbolInfoDouble(pSymbol, SYMBOL_TRADE_TICK_VALUE); // Tick value of the asset

      if(_lotStep ==  1) _lotdigit = 0;
      if(_lotStep == 0.1) _lotdigit = 1;
      if(_lotStep == 0.01) _lotdigit = 2;

      _moneyRisk = (pRiskPercentage * 0.01) * pMoneyCapital;
      _totalTickCount = ToTicksCount(pSymbol, pStoplossPoints);

      //---Calculate the Lot size according to Risk.
      _lotsByRisk = _moneyRisk / (_totalTickCount * _oneTickValue);
      _lotsByRisk = _lotsByRisk * _CurrencyMultiplicator(pCurrencyPairAppendix);
      _lotsByRisk = NormalizeLots(pSymbol, _lotsByRisk);

      _lotSize = MathMax(MathMin(_lotsByRisk, _maxLotsPossible), SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MIN));
      _lotSize = NormalizeDouble(_lotSize, _lotdigit);
      return (_lotSize);
   }
   
   static bool CopyBufferAsSeries(int handleP, string handleNameP, int bufferIndexP, int postionStartP, int copyCountP, bool asSeriesP, double& targetArrayP[]) {
      ResetLastError();
      int returnedBarCount = CopyBuffer(handleP, bufferIndexP, postionStartP, copyCountP, targetArrayP);
      if(returnedBarCount <= 0) {
         XPrint("Failed to copy buffer of indicator handle: ", handleNameP, " Error: ", IntegerToString(GetLastError())); 
         return (false);
      }
      ArraySetAsSeries(targetArrayP, asSeriesP);
      return (true);
   }   

   static double MathGetAngle(double pValue1, double pValue2, int pPeriod, double pCoef) {
      double zDiff = pValue1 - pValue2;
      double zAngleRad = MathArctan(zDiff / (pCoef * pPeriod));
      double zPI =  3.141592654;
      double zAngleDegrees = (zAngleRad * 180) / zPI;
      return (zAngleDegrees);
   }

   static bool MathCheckDoubleEqual(double pValue1, double pValue2, int pDigits) {
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

   static int MathCountDecimalPlaces(double pValue) {
      //---100 as maximum length of number.
      for (int i = 0; i < 100; i++) {
         if (MathAbs(MathRound(pValue) - pValue) / MathPow(10, i) <= FLT_EPSILON) return(i);
         pValue *= 10;
      }
      return(-1);
   }

   static string GetRandomMessage() {
      string messages[];
      int total = 8;
      ArrayResize(messages, total);
      messages[0] = "Anyone can be Anything";
      messages[1] = "Follow your Instincts";
      messages[2] = "Failure allows to Grow";
      messages[3] = "No pressure, No diamonds";
      messages[4] = "Pain is temporary";
      messages[5] = "Begin anywhere";
      messages[6] = "Try again, Fail better";
      messages[7] = "Happiness comes by choice";                        
      int index = MathRand() % total;
      return messages[index];
   }

   static void checkDeinitReason(const int pReason) {
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
         ExpertRemove();
         break;
      case REASON_CHARTCHANGE:
         text = "the symbol or chart period has been changed (REASON_CHARTCHANGE).";
         ExpertRemove();
         break;
      case REASON_CHARTCLOSE:
         text = "the chart has been closed (REASON_CHARTCLOSE).";
         break;
      case REASON_PARAMETERS:
         text = "the input parameters has been changed (REASON_PARAMETERS).";
         break;
      case REASON_ACCOUNT:
         text = "the account settings<another account has been activated or reconnection to the trade server> has been changed (REASON_ACCOUNT).";
         ExpertRemove();
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
         ExpertRemove();
         break;
      }
      XPrint("Trading Robot terminated! ", text);
   }

};

class CMyBoxWidget {
private:
   string   mObjectPrefix;
   int      mAnimationX;
   string   mFontName;
   int      mFontSizeTitle, mFontSizeNote, mFontSizeText;
   color    mFontColorTitle, mFontColorNote, mFontColorText;
   color    mBgColorLabel1, mBgColorLabel2, mBgColorAnimBox, mActiveColorAnimBox;

   void _WriteText(int corner, string tooltip, string text, int Ydistance) {
      _WriteText(corner, tooltip, text, Ydistance, 60, mFontName, mFontSizeText, mFontColorText);
   }

   void _WriteText(int corner, string tooltip, string text, int Ydistance, int Xdistance, string fontNameInput, int fontSizeInput, color fontColorInput) {
      string OBJNAME = mObjectPrefix + "-TXT-" + IntegerToString(Ydistance);
      if(ObjectFind(ChartID(), OBJNAME) != 0) {
         ObjectCreate(ChartID(), OBJNAME, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_HIDDEN, true);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_CORNER, corner);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XDISTANCE, Xdistance);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_YDISTANCE, Ydistance);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_FONT, fontNameInput);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_COLOR, fontColorInput);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_FONTSIZE, fontSizeInput);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_TOOLTIP, tooltip);
      }
      ObjectSetString(ChartID(), OBJNAME, OBJPROP_TEXT, text);
   }

   void _SetAnimationBox(int corner, color colorInput, int Ydistance, int XDist) {
      string OBJNAME = mObjectPrefix + "-BOX-" + IntegerToString(Ydistance) + "-" + IntegerToString(XDist);
      if(ObjectFind(ChartID(), OBJNAME) != 0) {
         ObjectCreate(ChartID(), OBJNAME, OBJ_LABEL, 0, 0, 0, 0, 0);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_HIDDEN, true);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_CORNER, corner);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XSIZE, 20);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_TOOLTIP, "Ticks update");
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_YDISTANCE, Ydistance);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_TEXT, CharToString(110));
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_FONTSIZE, 12);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_FONT, "Wingdings");
      }
      ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XDISTANCE, XDist);
      ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_COLOR, colorInput);
   }

public:
   CMyBoxWidget() {
      mAnimationX = 0;
      mFontName = "Tahoma";
      mFontSizeTitle = 15;
      mFontSizeNote = 13;
      mFontSizeText = 11;
      mFontColorTitle = clrDarkSlateGray;
      mFontColorNote = clrDarkOrange;
      mFontColorText = C'255,255,255';
      mBgColorLabel1 = clrSlateGray;
      mBgColorLabel2 = clrCrimson;
      mBgColorAnimBox = clrIvory;
      mActiveColorAnimBox = clrSpringGreen;
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }

   ~CMyBoxWidget() {
      DeleteWidget();
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }

   const void DeleteWidget() {
      for(int iObj = ObjectsTotal(ChartID()) - 1; iObj >= 0; iObj--) {
         string on = ObjectName(ChartID(), iObj);
         if (StringFind(on, mObjectPrefix) == 0)  ObjectDelete(ChartID(), on);
      }
      ObjectDelete(ChartID(), mObjectPrefix);
      Comment("");
   }

   const void ShowWidget(string pText) {
      string robotName = DEF_MY_ROBOT_NAME;
      int corner = 0;

      mObjectPrefix = "@" + robotName;
      string OBJNAME = mObjectPrefix + "-LABEL-1";
      if(ObjectFind(ChartID(), OBJNAME) != 0) {
         ObjectCreate(ChartID(), OBJNAME, OBJ_RECTANGLE_LABEL, 0, 0, 0) ;
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_HIDDEN, true); // hide the object in list
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_CORNER, corner);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XDISTANCE, 40);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_YDISTANCE, 40);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_BGCOLOR, mBgColorLabel1);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_WIDTH, 5); // border width
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XSIZE, 440);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_YSIZE, 360);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_TOOLTIP, robotName);
      }

      OBJNAME = mObjectPrefix + "-LABEL-2";
      if(ObjectFind(ChartID(), OBJNAME) != 0) {
         ObjectCreate(ChartID(), OBJNAME, OBJ_RECTANGLE_LABEL, 0, 0, 0) ;
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_HIDDEN, true);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_CORNER, corner);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XDISTANCE, 80);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_YDISTANCE, 60);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_WIDTH, 2);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_BGCOLOR, mBgColorLabel2);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_XSIZE, 360);
         ObjectSetInteger(ChartID(), OBJNAME, OBJPROP_YSIZE, 110);
         ObjectSetString(ChartID(), OBJNAME, OBJPROP_TOOLTIP, robotName);

         _WriteText(corner, "Robot Name", robotName, 80, 100, "Arial", mFontSizeTitle, mFontColorTitle);

         _WriteText(corner, "Account Broker", AccountInfoString(ACCOUNT_COMPANY), 180);
         _WriteText(corner, "Account Server", AccountInfoString(ACCOUNT_SERVER), 200);
         _WriteText(corner, "Account Number", IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)), 220);
         _WriteText(corner, "Account Leverage", IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + ":1", 240);
      }
      _WriteText(corner, "Comment", "* " + pText + " *", 120, 100, "Arial", mFontSizeNote, mFontColorNote);

      int animBoxYDistance = 270;
      for(int itrX = 60; itrX <= 440; itrX += 20) {
         _SetAnimationBox(corner, mBgColorAnimBox, animBoxYDistance, itrX);
      }

      if(mAnimationX == 0) {
         mAnimationX = 60;
      }
      _SetAnimationBox(corner, mActiveColorAnimBox, animBoxYDistance, mAnimationX);
      mAnimationX += 20;
      if (mAnimationX > 440) {
         mAnimationX = 60;
      }
      _WriteText(corner, "Server Time", TimeToString(CMyToolkit::TimeServerCurrent(), TIME_DATE | TIME_SECONDS), 300);
      _WriteText(corner, "Server Time(GMT)", TimeToString(CMyToolkit::TimeServerGMT(0), TIME_DATE | TIME_SECONDS), 320);
      _WriteText(corner, "Market Session", CMyToolkit::CurrentMarketSession(), 340);

   }
};


enum EMyAlgoRunMode {
   MY_ALGO_RUNMODE_NEW_MODIFY = 5,
   MY_ALGO_RUNMODE_MODIFY_ONLY = 10,
   MY_ALGO_RUNMODE_OFF = 20,
};

enum EMySignalType {
   MY_SIGNAL_TYPE_NONE = 0,
   MY_SIGNAL_TYPE_OPEN = 3,
   MY_SIGNAL_TYPE_MODIFY = 6,
   MY_SIGNAL_TYPE_CLOSE = 9,   
};

class CMySignal {
public:
   EMySignalType signal;
   ENUM_ORDER_TYPE orderType;
   double pendingOrderOpenPrice;
   ENUM_ORDER_TYPE_TIME pendingOrderTypeTime;
   datetime pendingOrderExpiration;
   double stoploss;
   double takeprofit;
   string remark;
   ulong ticket;
   
   CMySignal() {
      this.signal = MY_SIGNAL_TYPE_NONE;
      this.orderType = -1;
      this.pendingOrderOpenPrice = 0;
      this.pendingOrderTypeTime = ORDER_TIME_GTC;
      this.pendingOrderExpiration = 0;
      this.stoploss = 0;
      this.takeprofit = 0;
      this.remark = NULL;
      this.ticket = -1;
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }
   ~CMySignal() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }
};

class CMyTechRiskCalculation {
public:
   bool useFixedUnits;
   bool useAccountBalance;
   double riskPerTrade;
   
   CMyTechRiskCalculation() {
      this.useFixedUnits = false;
      this.useAccountBalance = false;
      this.riskPerTrade = 0;
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }
   ~CMyTechRiskCalculation() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }     
};

class CMyTechTimeFilter {   
public:      
   bool useTimeFilter;
   double startTimeGMT;
   double finishTimeGMT;   
         
   CMyTechTimeFilter() {
      this.useTimeFilter = false;
      this.startTimeGMT = 0;
      this.finishTimeGMT = 0;
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }
   ~CMyTechTimeFilter() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }       
};

class CMyTechBreakEven {
public:
   bool useBreakEven; //---Enable moving Stop-Loss to Break Even
   double requiredRewardRatio; //---Reward ratio used for Break Even, 1.0 -> Break Even done at 1.0 Reward to Risk
   uint pointCountAddition; //---Extra Profit in points used for Break Even, 10 points -> 1 pip
   
   CMyTechBreakEven() {
      this.useBreakEven = false;
      this.requiredRewardRatio = 0;
      this.pointCountAddition = 0;
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }
   ~CMyTechBreakEven() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }  
};

class CMyTechProfitMaximisation {
public:
   bool useProfitMaximisation;
   double currencyProfitMargin;
   uint cycleTarget;
   double riskAdditionAfterWin;
   double riskSubtractionAfterLoss;
   double stayAtMaxRisk;   

   CMyTechProfitMaximisation() {
      this.useProfitMaximisation = false;
      this.currencyProfitMargin = 1;
      this.cycleTarget = 0;
      this.riskAdditionAfterWin = 0;
      this.riskSubtractionAfterLoss = 0;
      this.stayAtMaxRisk = 1;
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }
   ~CMyTechProfitMaximisation() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }  
};

class CMyAlgo {
private:
   CTrade      mTrade;
   CMySignal   mSignalArray[];

   ENUM_ORDER_TYPE _ToOrderType(ENUM_POSITION_TYPE pType) {
      if(pType == POSITION_TYPE_BUY) return ORDER_TYPE_BUY;
      if(pType == POSITION_TYPE_SELL) return ORDER_TYPE_SELL;
      return ORDER_TYPE_BUY;
   }
   
   void _AddSignal(CMySignal &pSignal) {
      int arrLength = ArraySize(mSignalArray);
      ArrayResize(mSignalArray, arrLength+1);
      mSignalArray[arrLength] = pSignal;   
   }

   double _GetUnitSize(const double pOpenPrice, const double pStoplossPrice) {
      uint stoplossDistancePoints = 0;
      double availableMoney = 0, originalLotSize = 0, stayMaxLotSize = 0, lotSizeAdditionAfterWin = 0,  lotSizeSubtractionAfterLoss = 0, finalLotSize = 0;

      if ( pOpenPrice > 0 && pStoplossPrice > 0 ) {
         stoplossDistancePoints = CMyToolkit::ToPointsCount(mSymbol, MathAbs(pOpenPrice - pStoplossPrice));
      }
      if (stoplossDistancePoints < 1) {
         stoplossDistancePoints = Robot_DefaultStopLossPointCount;
      }
      //---Get available money
      if ( mTechRiskCalculation.useAccountBalance ) {
         availableMoney = AccountInfoDouble(ACCOUNT_BALANCE);
      } else {
         availableMoney = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      }
      
      //---calculate raw lotsize
      if ( mTechRiskCalculation.useFixedUnits ) {
         originalLotSize = mTechRiskCalculation.riskPerTrade;
         stayMaxLotSize = mTechProfitMaximisation.stayAtMaxRisk;
         lotSizeAdditionAfterWin = mTechProfitMaximisation.riskAdditionAfterWin;
         lotSizeSubtractionAfterLoss = mTechProfitMaximisation.riskSubtractionAfterLoss;
      } else {
         originalLotSize = CMyToolkit::CalculateUnitSize(mSymbol, availableMoney, mTechRiskCalculation.riskPerTrade, stoplossDistancePoints, Robot_MaximumLotSizeRisk, Robot_CurrencyPairAppendix);
         if ( mTechProfitMaximisation.stayAtMaxRisk > 0 ) {
            stayMaxLotSize = CMyToolkit::CalculateUnitSize(mSymbol, availableMoney, mTechProfitMaximisation.stayAtMaxRisk, stoplossDistancePoints, Robot_MaximumLotSizeRisk, Robot_CurrencyPairAppendix);
         }
         if ( mTechProfitMaximisation.riskAdditionAfterWin > 0 ) {
            lotSizeAdditionAfterWin = CMyToolkit::CalculateUnitSize(mSymbol, availableMoney, mTechProfitMaximisation.riskAdditionAfterWin, stoplossDistancePoints, Robot_MaximumLotSizeRisk, Robot_CurrencyPairAppendix);
         }
         if ( mTechProfitMaximisation.riskSubtractionAfterLoss > 0 ) {
            lotSizeSubtractionAfterLoss = CMyToolkit::CalculateUnitSize(mSymbol, availableMoney, mTechProfitMaximisation.riskSubtractionAfterLoss, stoplossDistancePoints, Robot_MaximumLotSizeRisk, Robot_CurrencyPairAppendix);
         } 
      }      
      
      finalLotSize = originalLotSize;
      
      if ( mTechProfitMaximisation.useProfitMaximisation ) {   // profit maximisation enabled       
         uint lastTradeIndex = 0, winningCycle = 0;
         double lastTradeLotSize = 0;
         bool wasLastTradeProfitable = false;         
         CMyHistoryPositionInfo histPositionInfo; 
         datetime today = CMyToolkit::TimeServerCurrent();  
         datetime twoMonthsAgo = today - (2*PeriodSeconds(PERIOD_MN1));   
               
         if ( histPositionInfo.HistorySelect(twoMonthsAgo, today) ) {
            int histTotal = histPositionInfo.PositionsTotal();               
            for ( int i = histTotal-1; i >= 0; i-- ) {
               if ( histPositionInfo.SelectByIndex(i) == false ) continue; // select the history position
               if ( mSymbol != histPositionInfo.Symbol() ) continue;
               if ( mMagicNumber != histPositionInfo.Magic() ) continue;    
               
               lastTradeIndex++;               
               //---check win or loss
               if ( histPositionInfo.Profit() > mTechProfitMaximisation.currencyProfitMargin ) {
                  winningCycle++;
               }               
               if ( lastTradeIndex == 1 ) {
                  lastTradeLotSize = histPositionInfo.Volume();
                  if ( histPositionInfo.Profit() > mTechProfitMaximisation.currencyProfitMargin ) {
                     wasLastTradeProfitable = true;
                  }                    
               }
               if ( lastTradeIndex >= mTechProfitMaximisation.cycleTarget ) break;
            }
         }
         
         if ( wasLastTradeProfitable ) {
            CMyToolkit::XPrint("Wow ! Last trade was profitable !");
            finalLotSize = lastTradeLotSize + lotSizeAdditionAfterWin;
            if ( mTechProfitMaximisation.stayAtMaxRisk > 0 && finalLotSize >= stayMaxLotSize ) {
               finalLotSize = stayMaxLotSize;
               CMyToolkit::XPrint("Staying at max unit size of ", (string)finalLotSize);
            }
            if ( mTechProfitMaximisation.cycleTarget > 0 && winningCycle >= mTechProfitMaximisation.cycleTarget ) {
               CMyToolkit::XPrint("Cycle Target of ", (string)mTechProfitMaximisation.cycleTarget, " achieved");
               if ( mTechProfitMaximisation.riskSubtractionAfterLoss > 0 && lastTradeLotSize > lotSizeSubtractionAfterLoss ) {
                  finalLotSize = lastTradeLotSize - lotSizeSubtractionAfterLoss;
                  CMyToolkit::XPrint("Next trade will have the decreased unit size of ", (string)finalLotSize);
               }  else {
                  finalLotSize = originalLotSize;
                  CMyToolkit::XPrint("Next trade will have the original unit size of ", (string)finalLotSize);
               }
            } else {
               CMyToolkit::XPrint("Next trade will have the increased/same unit size of ", (string)finalLotSize);
            } 
            
         } else {
            CMyToolkit::XPrint("Ohh ! Last trade was not profitable !");
            if ( mTechProfitMaximisation.riskSubtractionAfterLoss > 0 && lastTradeLotSize > lotSizeSubtractionAfterLoss ) {               
               finalLotSize = lastTradeLotSize - lotSizeSubtractionAfterLoss;
               CMyToolkit::XPrint("Next trade will have the decreased unit size of ", (string)finalLotSize);
            } else {  
               finalLotSize = originalLotSize;
               CMyToolkit::XPrint("Next trade will have the original unit size of ", (string)finalLotSize);
            }            
         }
         
      }
      double maxLotsPossible = CMyToolkit::MaxUnitSizeAllowedForMargin(mSymbol, availableMoney, Robot_MaximumLotSizeRisk);
      finalLotSize = MathMax(MathMin(finalLotSize, maxLotsPossible), SymbolInfoDouble(mSymbol, SYMBOL_VOLUME_MIN));
      return NormalizeDouble(finalLotSize, 2);
   }

   void _PositionClose(const ulong pTicket) {
      bool succeded = false;
      for( uint itr = 1 ; itr <= Robot_TradeRetryLoopCount ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyToolkit::XSleep(Robot_TradeRetryWaitTime);
         }
         mTrade.SetDeviationInPoints(Robot_MaximumSlippagePointCountOnClose);
         succeded = mTrade.PositionClose(pTicket);
         if ( succeded ) {
            break;
         } else {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to close position, Result: ", mTrade.ResultRetcodeDescription());
         }
      }
   }

   void _OrderDelete(const ulong pTicket) {
      bool succeded = false;
      for ( uint itr = 1 ; itr <= Robot_TradeRetryLoopCount ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyToolkit::XSleep(Robot_TradeRetryWaitTime);
         }
         mTrade.SetDeviationInPoints(Robot_MaximumSlippagePointCountOnClose);
         succeded = mTrade.OrderDelete(pTicket);
         if ( succeded ) {
            break;
         } else {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to delete pending order, Result: ", mTrade.ResultRetcodeDescription());
         }
      }
   }

   void _PositionModify(const ulong pTicket, const double pStoploss, const double pTakeprofit) {
      bool succeded = false;
      for ( uint itr = 1 ; itr <= Robot_TradeRetryLoopCount ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyToolkit::XSleep(Robot_TradeRetryWaitTime);
         }
         mTrade.SetDeviationInPoints(Robot_MaximumSlippagePointCountOnOpen);
         succeded = mTrade.PositionModify(pTicket, mSymbolInfo.NormalizePrice(pStoploss), mSymbolInfo.NormalizePrice(pTakeprofit));
         if ( succeded ) {
            break;
         } else {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to modify position, Result: ", mTrade.ResultRetcodeDescription());
         }
      }
   }

   void _OrderModify(const ulong pTicket, const double pPendingOrderOpenPrice, const double pStoploss, const double pTakeprofit,
                     const ENUM_ORDER_TYPE_TIME pPendingOrderTypeTime = ORDER_TIME_GTC, const datetime pPendingOrderExpiration = 0) {
      bool succeded = false;
      for ( uint itr = 1 ; itr <= Robot_TradeRetryLoopCount ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyToolkit::XSleep(Robot_TradeRetryWaitTime);
         }
         mTrade.SetDeviationInPoints(Robot_MaximumSlippagePointCountOnOpen);
         succeded = mTrade.OrderModify(pTicket, mSymbolInfo.NormalizePrice(pPendingOrderOpenPrice),
                                       mSymbolInfo.NormalizePrice(pStoploss), mSymbolInfo.NormalizePrice(pTakeprofit),
                                       pPendingOrderTypeTime, pPendingOrderExpiration);
         if ( succeded ) {
            break;
         } else {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to modify pending order, Result: ", mTrade.ResultRetcodeDescription());
         }
      }
   }

   void _PositionOpen(const ENUM_ORDER_TYPE pOrderType, const double pStoploss, const double pTakeprofit, const string pComment) {
      double sl, tp, price, volume;
      if ( Robot_UseECN ) {
         sl = 0;
         tp = 0;
      } else {
         sl = mSymbolInfo.NormalizePrice(pStoploss);
         tp = mSymbolInfo.NormalizePrice(pTakeprofit);
      }

      bool succeded = false;
      ulong ticket = -1;
      for ( uint itr = 1 ; itr <= Robot_TradeRetryLoopCount ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyToolkit::XSleep(Robot_TradeRetryWaitTime);
         }
         mSymbolInfo.RefreshRates();
         if ( mSymbolInfo.Spread() > (int)Robot_MaximumSpreadPointCount ) {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to open position, current spread: ", (string)mSymbolInfo.Spread(), " > maximum spread: ", (string)Robot_MaximumSpreadPointCount);
            continue;
         }
         price = pOrderType == ORDER_TYPE_BUY ? mSymbolInfo.Ask() : mSymbolInfo.Bid();
         volume = _GetUnitSize(price, pStoploss);
         mTrade.SetDeviationInPoints(Robot_MaximumSlippagePointCountOnOpen);
         succeded = mTrade.PositionOpen(mSymbol, pOrderType, volume, price, sl, tp, pComment);
         if ( succeded ) {
            ticket = mTrade.ResultDeal();
            break;
         } else {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to open position, Result: ", mTrade.ResultRetcodeDescription());
         }
      }

      if ( Robot_UseECN && ticket > 0 && (pStoploss > 0 || pTakeprofit > 0) ) {
         //---ecn execution
         _PositionModify(ticket, pStoploss, pTakeprofit);
      }
   }

   void _OrderOpen(const ENUM_ORDER_TYPE pOrderType, const double pPendingOrderOpenPrice, const double pStoploss, const double pTakeprofit,
                   const string pComment, const ENUM_ORDER_TYPE_TIME pPendingOrderTypeTime = ORDER_TIME_GTC, const datetime pPendingOrderExpiration = 0) {
      double sl, tp, volume;
      if ( Robot_UseECN ) {
         sl = 0;
         tp = 0;
      } else {
         sl = mSymbolInfo.NormalizePrice(pStoploss);
         tp = mSymbolInfo.NormalizePrice(pTakeprofit);
      }

      bool succeded = false;
      ulong ticket = -1;
      for ( uint itr = 1 ; itr <= Robot_TradeRetryLoopCount ; itr++ ) {
         ResetLastError();
         if ( itr > 1 ) {
            CMyToolkit::XSleep(Robot_TradeRetryWaitTime);
         }
         volume = _GetUnitSize(pPendingOrderOpenPrice, pStoploss);
         mTrade.SetDeviationInPoints(Robot_MaximumSlippagePointCountOnOpen);
         succeded = mTrade.OrderOpen(mSymbol, pOrderType, volume, 0, mSymbolInfo.NormalizePrice(pPendingOrderOpenPrice), sl, tp,
                                     pPendingOrderTypeTime, pPendingOrderExpiration, pComment);
         if ( succeded ) {
            ticket = mTrade.ResultOrder();
            break;
         } else {
            CMyToolkit::XPrint("Symbol: ", mSymbol, " attempt: ", (string)itr, ", failed to open pending order, Result: ", mTrade.ResultRetcodeDescription());
         }
      }

      if ( Robot_UseECN && ticket > 0 && (pStoploss > 0 || pTakeprofit > 0) ) {
         //---ecn execution
         _OrderModify(ticket, pPendingOrderOpenPrice, pStoploss, pTakeprofit, pPendingOrderTypeTime, pPendingOrderExpiration);
      }
   }

protected:   
   ulong       mMagicNumber;
   string      mSymbol;
   CSymbolInfo mSymbolInfo;
   CMyTechRiskCalculation mTechRiskCalculation;
   CMyTechTimeFilter mTechTimeFilter;
   CMyTechBreakEven mTechBreakEven;
   CMyTechProfitMaximisation mTechProfitMaximisation;
   
   const void CloseTrade(const ENUM_ORDER_TYPE pOrderType) {
      CMySignal signalClose;
      signalClose.signal = MY_SIGNAL_TYPE_CLOSE;
      signalClose.orderType = pOrderType;      
      _AddSignal(signalClose);
   }
   
   const void CloseTrade(const ulong pTicket) {
      CMySignal signalClose;
      signalClose.signal = MY_SIGNAL_TYPE_CLOSE;
      signalClose.ticket = pTicket;      
      _AddSignal(signalClose);
   }   

   const void ModifyTrade(const ENUM_ORDER_TYPE pOrderType, const double pStoploss, const double pTakeprofit,
                                 const double pPendingOrderOpenPrice = 0, const ENUM_ORDER_TYPE_TIME pPendingOrderTypeTime = ORDER_TIME_GTC,
                                 const datetime pPendingOrderExpiration = 0) {
      CMySignal signalModify;
      signalModify.signal = MY_SIGNAL_TYPE_MODIFY;
      signalModify.orderType = pOrderType;
      signalModify.stoploss = mSymbolInfo.NormalizePrice(pStoploss);
      signalModify.takeprofit = mSymbolInfo.NormalizePrice(pTakeprofit);
      signalModify.pendingOrderOpenPrice = mSymbolInfo.NormalizePrice(pPendingOrderOpenPrice);
      signalModify.pendingOrderTypeTime = pPendingOrderTypeTime;
      signalModify.pendingOrderExpiration = pPendingOrderExpiration;
      _AddSignal(signalModify);
   }
   
   const void ModifyTrade(const ulong pTicket, const double pStoploss, const double pTakeprofit,
                                 const double pPendingOrderOpenPrice = 0, const ENUM_ORDER_TYPE_TIME pPendingOrderTypeTime = ORDER_TIME_GTC,
                                 const datetime pPendingOrderExpiration = 0) {
      CMySignal signalModify;
      signalModify.signal = MY_SIGNAL_TYPE_MODIFY;
      signalModify.ticket = pTicket;
      signalModify.stoploss = mSymbolInfo.NormalizePrice(pStoploss);
      signalModify.takeprofit = mSymbolInfo.NormalizePrice(pTakeprofit);
      signalModify.pendingOrderOpenPrice = mSymbolInfo.NormalizePrice(pPendingOrderOpenPrice);
      signalModify.pendingOrderTypeTime = pPendingOrderTypeTime;
      signalModify.pendingOrderExpiration = pPendingOrderExpiration;
      _AddSignal(signalModify);
   }   

   const void OpenTrade(const ENUM_ORDER_TYPE pOrderType, const double pStoploss, const double pTakeprofit, const string pComment,
                               const double pPendingOrderOpenPrice = 0, const ENUM_ORDER_TYPE_TIME pPendingOrderTypeTime = ORDER_TIME_GTC,
                               const datetime pPendingOrderExpiration = 0) {
      if ( GetAlgoRunMode() == MY_ALGO_RUNMODE_MODIFY_ONLY ) {
         return;
      }
      if ( mTechTimeFilter.useTimeFilter ) {
         bool timeOk = CMyToolkit::CheckTradingSessionTime(mTechTimeFilter.startTimeGMT, mTechTimeFilter.finishTimeGMT);
         if ( timeOk == false ) {
            return;
         }
      }
      CMySignal signalOpen;
      signalOpen.signal = MY_SIGNAL_TYPE_OPEN;
      signalOpen.orderType = pOrderType;
      signalOpen.stoploss = mSymbolInfo.NormalizePrice(pStoploss);
      signalOpen.takeprofit = mSymbolInfo.NormalizePrice(pTakeprofit);
      signalOpen.remark = pComment;
      signalOpen.pendingOrderOpenPrice = mSymbolInfo.NormalizePrice(pPendingOrderOpenPrice);
      signalOpen.pendingOrderTypeTime = pPendingOrderTypeTime;
      signalOpen.pendingOrderExpiration = pPendingOrderExpiration;
      _AddSignal(signalOpen);
   }
   
   const void GetCurrentPositionTickets(ulong &returnTickets[]) {
      int arrLength;      
      CPositionInfo positionInfo;      
      ArrayResize(returnTickets, 0);
      uint total = PositionsTotal();
      for ( uint i = 0; i < total; i++ ) {
         if ( positionInfo.SelectByIndex(i) == false ) continue; // select the position
         if ( mSymbol != positionInfo.Symbol() ) continue;
         if ( mMagicNumber != positionInfo.Magic() ) continue;         
         
         arrLength = ArraySize(returnTickets);
         ArrayResize(returnTickets, arrLength+1);
         returnTickets[arrLength] = positionInfo.Ticket();          
      }
   }
   
    const void GetCurrentOrderTickets(ulong &returnTickets[]) {
      int arrLength;      
      COrderInfo orderInfo;     
      ArrayResize(returnTickets, 0);
      uint total = OrdersTotal();
      for ( uint i = 0; i < total; i++ ) {
         if ( orderInfo.SelectByIndex(i) == false ) continue; // select the position
         if ( mSymbol != orderInfo.Symbol() ) continue;
         if ( mMagicNumber != orderInfo.Magic() ) continue;         
         
         arrLength = ArraySize(returnTickets);
         ArrayResize(returnTickets, arrLength+1);
         returnTickets[arrLength] = orderInfo.Ticket();          
      } 
   }     

   virtual int RunOnInit() = 0;
   virtual void RunOnBar() = 0;
   virtual void RunOnDeinit() = 0;

   virtual string GetAlgoName() = 0;
   virtual string GetTradeSymbol() = 0; 
   virtual EMyAlgoRunMode GetAlgoRunMode() = 0; 
  
public:

   CMyAlgo() {
      ArrayResize(mSignalArray, 0);
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }

   ~CMyAlgo() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }

   const int Start() {
      if ( GetAlgoRunMode() == MY_ALGO_RUNMODE_OFF ) {
         return (INIT_SUCCEEDED);
      }
      mSymbol = GetTradeSymbol();
      mSymbolInfo.Name(mSymbol);
      mMagicNumber = CMyToolkit::GetAlgoMagicNumber(GetAlgoName());
      mTrade.SetExpertMagicNumber(mMagicNumber);
      mTrade.SetAsyncMode(DEF_MY_ASYNC_MODE);
      mTrade.SetMarginMode();
      mTrade.SetTypeFillingBySymbol(mSymbol);
      int ret = this.RunOnInit();
      if ( ret == INIT_SUCCEEDED ) {
         CMyToolkit::XPrint("Algo: ", GetAlgoName(), " started with Magic: ", (string)mMagicNumber);
      } else {
         CMyToolkit::XPrint("Algo: ", GetAlgoName(), " initialization failed.");
         ret = INIT_FAILED;
      }
      return ret;
   }

   const void Stop() {
      if(GetAlgoRunMode() == MY_ALGO_RUNMODE_OFF) {
         return;
      }
      this.RunOnDeinit();
   }

   const void Run() {
      if ( GetAlgoRunMode() == MY_ALGO_RUNMODE_OFF ) {
         return;
      }      
      
      mSymbolInfo.RefreshRates();
      ArrayResize(mSignalArray, 0);
      this.RunOnBar();
      
      if ( ArraySize(mSignalArray) > 0 || mTechBreakEven.useBreakEven ) {
         //---require processing
      } else {
         return;
      }      

      //---manage market positions
      CPositionInfo positionInfo;
      double breakEvenDistance, stoploss, takeprofit;
      uint total = PositionsTotal();
      for ( uint i = 0; i < total; i++ ) {
         if ( positionInfo.SelectByIndex(i) == false ) continue; // select the position
         if ( mSymbol != positionInfo.Symbol() ) continue;
         if ( mMagicNumber != positionInfo.Magic() ) continue;  
         
         //---TODO set the original stop loss and take profit if those hasn't been applied
         //---improve using the Global variables to maintain signals      
         
         //---close signals         
         for ( int sindex = 0; sindex < ArraySize(mSignalArray); sindex++ ) {
            if ( mSignalArray[sindex].signal == MY_SIGNAL_TYPE_CLOSE ) {
               CMySignal signalClose = mSignalArray[sindex];
               if ( signalClose.ticket == positionInfo.Ticket() 
                     || signalClose.orderType == _ToOrderType(positionInfo.PositionType()) ) {
                  _PositionClose(positionInfo.Ticket());
               }            
            }     
         }

         //---break even
         if ( mTechBreakEven.useBreakEven && mTechBreakEven.requiredRewardRatio > 0 ) {
            breakEvenDistance = mTechBreakEven.requiredRewardRatio * MathAbs(positionInfo.PriceOpen() - positionInfo.StopLoss());
            if ( positionInfo.PositionType() == POSITION_TYPE_BUY &&
                  MathAbs(positionInfo.PriceCurrent() - positionInfo.PriceOpen()) > breakEvenDistance ) {
               stoploss = positionInfo.PriceOpen() + CMyToolkit::ToPointDecimal(mSymbol, mTechBreakEven.pointCountAddition);
               _PositionModify(positionInfo.Ticket(), stoploss, positionInfo.TakeProfit());
            } else if( positionInfo.PositionType() == POSITION_TYPE_SELL &&
                       MathAbs(positionInfo.PriceOpen() - positionInfo.PriceCurrent()) > breakEvenDistance ) {
               stoploss = positionInfo.PriceOpen() - CMyToolkit::ToPointDecimal(mSymbol, mTechBreakEven.pointCountAddition);
               _PositionModify(positionInfo.Ticket(), stoploss, positionInfo.TakeProfit());
            }
         }
         //---modify signals
         for ( int sindex = 0; sindex < ArraySize(mSignalArray); sindex++ ) {
            if ( mSignalArray[sindex].signal == MY_SIGNAL_TYPE_MODIFY ) {
               CMySignal signalModify = mSignalArray[sindex];
               if( signalModify.ticket == positionInfo.Ticket()  
                     || signalModify.orderType == _ToOrderType(positionInfo.PositionType()) ) {
                  stoploss = signalModify.stoploss > 0 ? signalModify.stoploss : positionInfo.StopLoss();
                  takeprofit = signalModify.takeprofit > 0 ? signalModify.takeprofit : positionInfo.TakeProfit();
                  _PositionModify(positionInfo.Ticket(), stoploss, takeprofit);
               }               
            }     
         }   

      }

      //---manage pending orders
      COrderInfo orderInfo;
      double openPrice;
      datetime expiration;
      ENUM_ORDER_TYPE_TIME typeTime;
      total = OrdersTotal();
      for ( uint i = 0; i < total; i++ ) {
         if ( orderInfo.SelectByIndex(i) == false ) continue; // select the order
         if ( mSymbol != orderInfo.Symbol() ) continue;
         if ( mMagicNumber != orderInfo.Magic() ) continue;
         
         //---close signals
         for ( int sindex = 0; sindex < ArraySize(mSignalArray); sindex++ ) {
            if ( mSignalArray[sindex].signal == MY_SIGNAL_TYPE_CLOSE ) {
               CMySignal signalClose = mSignalArray[sindex];
               if ( signalClose.ticket == orderInfo.Ticket() 
                     || signalClose.orderType == orderInfo.OrderType() ) {
                  _OrderDelete(orderInfo.Ticket());
               }     
            }     
         }         

         //---modify signals
         for ( int sindex = 0; sindex < ArraySize(mSignalArray); sindex++ ) {
            if ( mSignalArray[sindex].signal == MY_SIGNAL_TYPE_MODIFY ) {
               CMySignal signalModify = mSignalArray[sindex];
               if( signalModify.ticket == orderInfo.Ticket() 
                     || signalModify.orderType == orderInfo.OrderType() ) {
                  openPrice = signalModify.pendingOrderOpenPrice > 0 ? signalModify.pendingOrderOpenPrice : orderInfo.PriceOpen();
                  stoploss = signalModify.stoploss > 0 ? signalModify.stoploss : orderInfo.StopLoss();
                  takeprofit = signalModify.takeprofit > 0 ? signalModify.takeprofit : orderInfo.TakeProfit();
                  typeTime = orderInfo.TypeTime() != signalModify.pendingOrderTypeTime ? signalModify.pendingOrderTypeTime : orderInfo.TypeTime() ;
                  expiration = orderInfo.TimeExpiration() != signalModify.pendingOrderExpiration ? signalModify.pendingOrderExpiration : orderInfo.TimeExpiration();
                  _OrderModify(orderInfo.Ticket(), openPrice, stoploss, takeprofit, typeTime, expiration);
               }              
            }     
         }  
      }

      //---open signals
      for ( int sindex = 0; sindex < ArraySize(mSignalArray); sindex++ ) {
         if ( mSignalArray[sindex].signal == MY_SIGNAL_TYPE_OPEN ) {
            CMySignal signalOpen = mSignalArray[sindex];
            if ( signalOpen.orderType == ORDER_TYPE_BUY || signalOpen.orderType == ORDER_TYPE_SELL ) {
               _PositionOpen(signalOpen.orderType, signalOpen.stoploss, signalOpen.takeprofit, signalOpen.remark);
            }
            else if ( signalOpen.orderType == ORDER_TYPE_BUY_LIMIT ||  signalOpen.orderType == ORDER_TYPE_BUY_STOP 
                        || signalOpen.orderType != ORDER_TYPE_BUY_STOP_LIMIT 
                        || signalOpen.orderType == ORDER_TYPE_SELL_LIMIT ||  signalOpen.orderType == ORDER_TYPE_SELL_STOP 
                        || signalOpen.orderType != ORDER_TYPE_SELL_STOP_LIMIT ) {
               _OrderOpen(signalOpen.orderType, signalOpen.pendingOrderOpenPrice, signalOpen.stoploss, signalOpen.takeprofit,
                          signalOpen.remark, signalOpen.pendingOrderTypeTime, signalOpen.pendingOrderExpiration);
            }          
         }     
      }       

   }

};

class CMyRobot {
private:

   CMyBoxWidget mBoxWidget;
   CMyAlgo* mAlgoArray[];

   void _ShowInfo(string pText) {
      if ( CMyToolkit::IsTesting() ) {
         return;
      }
      if ( Robot_UseBoxWidget ) {
         mBoxWidget.ShowWidget(pText);
      } else {
         CMyToolkit::ShowComment(pText);
      }
   }

public:

   CMyRobot() {
      ResetLastError();
      ArrayResize(mAlgoArray, 0);
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }

   ~CMyRobot() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
   }

   const int Start(CMyAlgo* &pAlgo[]) {
      TesterHideIndicators(DEF_MY_TESTER_HIDE_INDICATORS);

      ResetLastError();
      string mqlProgramName = MQLInfoString(MQL_PROGRAM_NAME);
      if ( DEF_MY_ROBOT_NAME != mqlProgramName ) {
         CMyToolkit::XPrint("Invalid file name: '", mqlProgramName, "' owned by the Robot, it must be '", DEF_MY_ROBOT_NAME, "'.");
         return (INIT_PARAMETERS_INCORRECT);
      }
      bool hasValidLicense = CMyToolkit::CheckValidLicense(Robot_LicenseKey);
      if  (DEF_MY_ENFORCE_LICENSE && hasValidLicense == false ) {
         CMyToolkit::XPrint("Invalid License Key: '", Robot_LicenseKey, "' configured in the Robot.");
         return (INIT_PARAMETERS_INCORRECT);
      }
      if ( AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ) {
         CMyToolkit::XPrint("Running on a Demo Account!");
      }
      if ( CMyToolkit::IsTesting() ) {
         CMyToolkit::XPrint("Running on Strategy Tester!");
      }
      ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
      if ( margin_mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING ) {
         CMyToolkit::XPrint("Account has no retail hedging!");
         return (INIT_PARAMETERS_INCORRECT);
      }

      ArrayCopy(mAlgoArray, pAlgo, 0, 0, ArraySize(pAlgo));
      int initResult;
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         initResult = mAlgoArray[i].Start();
         if ( initResult != INIT_SUCCEEDED ) return (initResult);
      }
      int errorCode = GetLastError();
      if ( errorCode != 0 ) {
         CMyToolkit::XPrint("Trading Robot initialization failed! Error Code: ", IntegerToString(errorCode));
         return (INIT_FAILED);
      }
      _ShowInfo("");
      CMyToolkit::XPrint("Trading Robot started successfully!");
      return (INIT_SUCCEEDED);
   }

   const void Stop(const int pReason) {
      for (int i = 0; i < ArraySize(mAlgoArray); i++) {
         mAlgoArray[i].Stop();
      }
      mBoxWidget.DeleteWidget();
      //---now delete dynamic algo objects
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         if ( CheckPointer(mAlgoArray[i]) == POINTER_DYNAMIC ) {
            delete mAlgoArray[i];
         }
      }      
      CMyToolkit::checkDeinitReason(pReason);
   }

   const void Run() {
      CMyToolkit::XDebug("__FUNCTION__ = ", __FUNCTION__, " is called");
      for ( int i = 0; i < ArraySize(mAlgoArray); i++ ) {
         mAlgoArray[i].Run();
      }
      _ShowInfo(CMyToolkit::GetRandomMessage());
   }
};

//+------------------------------------------------------------------+
//| Framework implementation end                                     |
//+------------------------------------------------------------------+

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

input group    ">>>>>>>>>> Algo 1 Settings <<<<<<<<<<"
input group    " "
string                  Algo1_AlgoName                               = "MyScalper"; // Algo Name
input string    Algo1_AlgoSymbol                                     = ""; // Symbol Name
input EMyAlgoRunMode    Algo1_AlgoRunMode                            = MY_ALGO_RUNMODE_NEW_MODIFY; // Run mode
input group    " "
input bool              Algo1_UnitCalculation_UseFixedUnits          = false; // Enable trading fixed size
input bool              Algo1_UnitCalculation_UseAccountBalance      = true; // Enable Account Balance as capital basis
input double            Algo1_UnitCalculation_PercentageOfCapital    = 0.2; // Risk percentage of the capital ,ex: 1 = 1%
input group    " "
input bool              Algo1_TimeFilter_UseTimeFilter               = false; // Enable the Time Filter on new trades
input double            Algo1_TimeFilter_StartTimeGMT                = 8.0; // Start time in GMT+0 for the Time Filter
input double            Algo1_TimeFilter_FinishTimeGMT               = 17.0; // Finish time in GMT+0 for the Time Filter
input group    " "
input bool              Algo1_BreakEven_UseBreakEven                 = false; // Enable moving Stop-Loss to Break Even
input double            Algo1_BreakEven_RequiredRewardRatio          = 2.0; // Reward ratio used for Break Even
input uint              Algo1_BreakEven_PointCountAddition           = 50; // Additional Profit in points used for Break Even
input group    " "
input bool              Algo1_ProfitMaximisation_UseProfitMaximisation     = false; // Enable the Profit Maximisation
input double            Algo1_ProfitMaximisation_CurrencyProfitMargin      = 1; // Value in account currency used to find a profitable trade
input uint              Algo1_ProfitMaximisation_CycleTarget               = 4; // Target profit cycle number
input double            Algo1_ProfitMaximisation_RiskAdditionAfterWin      = 0; // Additional Risk per trade after a win
input double            Algo1_ProfitMaximisation_RiskSubtractionAfterLoss  = 0; // Reduced Risk per trade after a loss
input double            Algo1_ProfitMaximisation_StayAtMaxRisk             = 1; // Stay at Maximum Risk per trade,ex: 1 = 1%
input group    " "

input group    ">>>>>>>>>> Robot Settings <<<<<<<<<<"
input group    " "
string                  Robot_LicenseKey                       = "XXXX"; // License Key
input bool                    Robot_UseBoxWidget                     = true; // Enable the Graphical Display
input uint                    Robot_MaximumSpreadPointCount          = 60; // Maximum Spread points on open, 10 points -> 1 pip
input uint                    Robot_MaximumSlippagePointCountOnOpen  = 20; // Maximum Slippage points on open, 10 points -> 1 pip
input uint                    Robot_MaximumSlippagePointCountOnClose = 1000; // Maximum Slippage points on close, 10 points -> 1 pip
input uint                    Robot_MaximumLotSizeRisk               = 50; // Maximum Lot size allowed used in Risk Management
input string                  Robot_CurrencyPairAppendix             = ""; // Appendix if the Symbol defined with afterword, .a -> EURUSD.a
input uint                    Robot_DefaultStopLossPointCount        = 500; // Default Stop-Loss points if no Stop-Loss, 10 points -> 1 pip
input bool                    Robot_UseECN                           = true; // Enable ECN execution
input uint                    Robot_TradeRetryLoopCount              = 10; // Retry count on error
input uint                    Robot_TradeRetryWaitTime               = 5000; // Retry wait time in milliseconds on error
input group    " "

CMyRobot mRobot;
   
int OnInit() {
   CMyAlgo* algoArray[];
   ArrayResize(algoArray, 1);
   algoArray[0] = new CAlgoMyScalper();
   
   int hasStarted = mRobot.Start(algoArray);
   //EventSetTimer(60);  
   return hasStarted;
}
void OnDeinit(const int pReason) {
   //EventKillTimer();
   mRobot.Stop(pReason);
}
void OnTick() {
   //if ( CMyToolkit::IsTesting() == false) {      
   //   return;
   //}      
   static int lastBarsPeriodCurrent;
   int countBarsPeriodX = iBars(NULL, 0);
   if ( lastBarsPeriodCurrent != countBarsPeriodX ) { //---Trade only if new bar has arrived
      lastBarsPeriodCurrent = countBarsPeriodX;
      OnTimer();
   }
}
void OnTimer() {   
   mRobot.Run();
}
void OnTrade() {
}
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {

}
double OnTester() {
   return (0);
}
void OnTesterInit() {
}
void OnTesterPass() {
}
void OnTesterDeinit() {
}
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
}
void OnBookEvent(const string &symbol) {
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CAlgoMyScalper : public CMyAlgo {

private:
   int mHandleMACD;   
   double mBufMACDLine[], mBufMACDSignal[];
   int mHandleATR;
   double mBufATR[];
   ENUM_TIMEFRAMES timeframeEntry, timeframeTrend;

protected:

   string GetAlgoName() {
      return Algo1_AlgoName;
   }
   string GetTradeSymbol() {
      return Algo1_AlgoSymbol;
   }
   EMyAlgoRunMode GetAlgoRunMode() {
      return Algo1_AlgoRunMode;
   }

public:

   int RunOnInit() {
      mTechRiskCalculation.useFixedUnits = Algo1_UnitCalculation_UseFixedUnits;
      mTechRiskCalculation.useAccountBalance = Algo1_UnitCalculation_UseAccountBalance;
      mTechRiskCalculation.riskPerTrade = Algo1_UnitCalculation_PercentageOfCapital;
      
      mTechTimeFilter.useTimeFilter = Algo1_TimeFilter_UseTimeFilter;
      mTechTimeFilter.startTimeGMT = Algo1_TimeFilter_StartTimeGMT;
      mTechTimeFilter.finishTimeGMT = Algo1_TimeFilter_FinishTimeGMT;
      
      mTechBreakEven.useBreakEven = Algo1_BreakEven_UseBreakEven;
      mTechBreakEven.requiredRewardRatio = Algo1_BreakEven_RequiredRewardRatio;
      mTechBreakEven.pointCountAddition = Algo1_BreakEven_PointCountAddition;
      
      mTechProfitMaximisation.useProfitMaximisation = Algo1_ProfitMaximisation_UseProfitMaximisation;
      mTechProfitMaximisation.currencyProfitMargin = Algo1_ProfitMaximisation_CurrencyProfitMargin;
      mTechProfitMaximisation.cycleTarget = Algo1_ProfitMaximisation_CycleTarget;
      mTechProfitMaximisation.riskAdditionAfterWin = Algo1_ProfitMaximisation_RiskAdditionAfterWin;
      mTechProfitMaximisation.riskSubtractionAfterLoss = Algo1_ProfitMaximisation_RiskSubtractionAfterLoss;
      mTechProfitMaximisation.stayAtMaxRisk = Algo1_ProfitMaximisation_StayAtMaxRisk;
         
      timeframeEntry = PERIOD_CURRENT;
      timeframeTrend = PERIOD_H4;
      if((mHandleMACD = iMACD(mSymbol, timeframeEntry, 12, 26, 9, PRICE_CLOSE)) == INVALID_HANDLE) {
         CMyToolkit::XPrint("Error creating MACD indicator");
         return (INIT_FAILED);
      }
      if((mHandleATR = iATR(mSymbol, timeframeEntry, 14)) == INVALID_HANDLE) {
         CMyToolkit::XPrint("Error creating ATR indicator");
         return (INIT_FAILED);
      }      
      return (INIT_SUCCEEDED);
   }

   void RunOnBar() {
      if( BarsCalculated(mHandleMACD)<=5 || BarsCalculated(mHandleATR)<=2 ) {
         return; 
      }               
      CMyToolkit::CopyBufferAsSeries(mHandleMACD, "iMACD", 0, 0, 5, true, mBufMACDLine);
      CMyToolkit::CopyBufferAsSeries(mHandleMACD, "iMACD", 1, 0, 5, true, mBufMACDSignal);
      CMyToolkit::CopyBufferAsSeries(mHandleATR, "iATR", 0, 0, 2, true, mBufATR);
       
      ulong positionTickets[];
              
      if ( iClose(mSymbol, timeframeTrend, 1) > iClose(mSymbol, timeframeTrend, 2) 
               && iClose(mSymbol, timeframeTrend, 1) > iClose(mSymbol, timeframeTrend, 3)  ) {
         //CMyToolkit::XPrint(">>>> H4 last bar Bull");
         if( mBufMACDLine[2] < 0 && mBufMACDLine[1] > 0 ) {
            double slDistance = CMyToolkit::GetATRPointDecimal(mSymbol,mBufATR[1], mSymbolInfo.Spread(), 2.0);
            double buySL = mSymbolInfo.Ask() - slDistance;
            double buyTP = mSymbolInfo.Ask() + 1.5 * slDistance;
            GetCurrentPositionTickets(positionTickets);
            if ( ArraySize(positionTickets) == 0 ) {
               OpenTrade(ORDER_TYPE_BUY, buySL, buyTP, GetAlgoName()); 
            }
            /*NotifySignalClose(ORDER_TYPE_SELL_STOP);
            
            double sellOpenPrice = buySL - CMyToolkit::ToPointDecimal(mSymbol, mSymbolInfo.Spread());
            double sellSL = mSymbolInfo.Bid();
            double sellTP = sellOpenPrice - 2 * MathAbs(sellSL -sellOpenPrice);  
            datetime expiry = CMyToolkit::TimeServerCurrent() + PeriodSeconds(PERIOD_H2);
            NotifySignalOpen(ORDER_TYPE_SELL_STOP, sellSL, sellTP, "MACD Reverse", sellOpenPrice, ORDER_TIME_SPECIFIED, expiry);*/
         }      
      } 
      if ( iClose(mSymbol, timeframeTrend, 1) < iClose(mSymbol, timeframeTrend, 2) 
               && iClose(mSymbol, timeframeTrend, 1) < iClose(mSymbol, timeframeTrend, 3) ) {
         //CMyToolkit::XPrint(">>>> H4 last bar Bear");
         if( mBufMACDLine[2] > 0 && mBufMACDLine[1] < 0 ) {
            double slDistance = CMyToolkit::GetATRPointDecimal(mSymbol,mBufATR[1], mSymbolInfo.Spread(), 2.0);
            double sellSL = mSymbolInfo.Bid() + slDistance;
            double sellTP = mSymbolInfo.Bid() - 1.5 * slDistance;
            GetCurrentPositionTickets(positionTickets);
            if ( ArraySize(positionTickets) == 0 ) {                    
               OpenTrade(ORDER_TYPE_SELL, sellSL, sellTP, GetAlgoName()); 
            }           
         }      
      }        

      /*static int lastBarsPeriodEntryTF;
      int countBarsPeriod = iBars(mSymbol, timeframeEntry);
      if ( lastBarsPeriodEntryTF != countBarsPeriod ) {
         lastBarsPeriodEntryTF = countBarsPeriod;
         
      }*/      
      
               

   }

   void RunOnDeinit() {
      IndicatorRelease(mHandleMACD); IndicatorRelease(mHandleATR);
   }

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
