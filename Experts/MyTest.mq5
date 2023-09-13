//+------------------------------------------------------------------+
//|                                                       MyTest.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/AccountInfo.mqh>

int handleBB;

bool myIndicatorCreate() {
   bool isOk = true;   
   handleBB = iBands(NULL, 0, 20, 0, 2.0, PRICE_CLOSE);      
   if(handleBB == INVALID_HANDLE) {
      isOk = false;
   }   
   return isOk;   
}

void myIndicatorRelease() {
   IndicatorRelease(handleBB);   
}

bool CopyBufferAsSeries(int handleP, string handleNameP, int bufferIndexP, int postionStartP, int copyCountP, bool asSeriesP, double& targetArrayP[]) {
   ResetLastError();
   int returnedBarCount = CopyBuffer(handleP, bufferIndexP, postionStartP, copyCountP, targetArrayP);
   if(returnedBarCount <= 0) {
      Print("Failed to copy buffer of indicator handle: ", handleNameP, " Error: ", GetLastError()); 
      return (false);
   }
   ArraySetAsSeries(targetArrayP, asSeriesP);
   return (true);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   ResetLastError();
   string str = "";
   if(myIndicatorCreate() == false) {
      StringConcatenate(str, "Failed to create indicator handle(s) , Error: ", GetLastError());
      MessageBox(str, "Error");
      return (INIT_FAILED);
   }      
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   myIndicatorRelease();   
   Comment("");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   double arrayUpper[], arrayLower[];  
   
   CopyBufferAsSeries(handleBB, "handleBB", UPPER_BAND, 0, 5, true,  arrayUpper);
   CopyBufferAsSeries(handleBB, "handleBB", LOWER_BAND, 0, 5, true, arrayLower);
   
   //Print(">>> " , ((ENUM_ORDER_TYPE)ORDER_TYPE_SELL_STOP_LIMIT));
   Comment("\n Bar " , 1, " BB Upper is ", arrayUpper[1], " BB Lower is " , arrayLower[1] , 
           "\n Bar " , 2, " BB Upper is ", arrayUpper[2], " BB Lower is " , arrayLower[2]
        );
        
        
//--- request trade history
   HistorySelect(0,TimeCurrent());
//--- create objects
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   double   price;
   double   profit;
   datetime time;
   string   symbol;
   long     type;
   long     entry;
//--- for all deals
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties
         price =HistoryDealGetDouble(ticket,DEAL_PRICE);
         time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         type  =HistoryDealGetInteger(ticket,DEAL_TYPE);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         //--- only for current symbol
         if(price && time && symbol==Symbol())
           {
           Print("TradeHistory_Deal_",string(ticket), "Profit: ", string(profit) );
           }
        }
     }
     
}

void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
  ) {  

      Print("OnChart Event " , sparam);
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade() {
   
   Print("OnTrade event ");   
}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
                        
    Print("OnTradeTransaction event ",request.action);                        

}
//+------------------------------------------------------------------+
