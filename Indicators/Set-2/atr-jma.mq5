//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "ATR adaptive JMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "JMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrCrimson,clrGreen
#property indicator_width1  2
//--- input parameters
input int                inpJmaPeriod = 14;          // JMA period
input double             inpJmaPhase  = 0;           // JMA phase
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input string             __alr__00         = "";    //.
input string             __alr__01         = "";    //.                     Alerts settings
      enum enAlertOnOff
         {  
            aloo_yes = (int)true,  // Turn alerts on
            aloo_no  = (int)false, // Turn alerts off
         };
input enAlertOnOff    inpAlertsOn       = aloo_no; // Alerting mode
      enum enAlertOnCurrent
         {  
            alcu_yes = (int)true,  // Alert on current (still opened) bar)
            alcu_no  = (int)false, // Alert on first closed bar
         };
input enAlertOnCurrent inpAlertsOnCurrent = alcu_no;  // Alert bars
      enum enAlertMessage
         {  
            alme_yes = (int)true,  // Display pop-up message
            alme_no  = (int)false, // No pop-up messages
         };
input enAlertMessage  inpAlertsMessage  = alme_yes; // Pop-up messages
      enum enAlertSound
         {  
            also_yes = (int)true,  // Play alert sound
            also_no  = (int)false, // No alerting sound
         };
input enAlertSound   inpAlertsSound  = also_no;  // Sound
      enum enAlertEmail
         {  
            alem_yes = (int)true,  // Send email
            alem_no  = (int)false, // No emails sent
         };
input enAlertEmail    inpAlertsEmail    = alem_no;  // Emails
      enum enAlertPush
         {  
            alpu_yes = (int)true,  // Send push notification
            alpu_no  = (int)false, // No push notifications
         };
input enAlertPush     inpAlertsPush    = alpu_no;  // Push notifications

//
//
//

double val[],valc[],atr[],tr[];

//------------------------------------------------------------------ 
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,atr,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,tr,INDICATOR_CALCULATIONS);

   //
   //
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive JMA ("+(string)inpJmaPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;
   
   //
   //
   //
   
   for(int i=limit; i<rates_total && !_StopFlag; i++)
   {
      tr[i] = (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      atr[i] = 0; 
         for (int k=0; k<inpJmaPeriod && (i-k)>=0; k++) 
            atr[i] += tr[i-k]; 
            atr[i] /= inpJmaPeriod;
         int _start = MathMax(i-inpJmaPeriod+1,0);
         double _max   = atr[ArrayMaximum(atr,_start,inpJmaPeriod)];            
         double _min   = atr[ArrayMinimum(atr,_start,inpJmaPeriod)];            
         double _coeff = (_min!=_max) ? 1-(atr[i]-_min)/(_max-_min) : 0.5;
         
      val[i]  = iSmooth(getPrice(inpPrice,open,close,high,low,i,rates_total),inpJmaPeriod*(_coeff+1.0)/2.0,inpJmaPhase,i);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   
   //
   //
   //
   
   if (inpAlertsOn)
   {
      int _alertBar = (inpAlertsOnCurrent) ? rates_total-1 : rates_total-2;
      
         if (valc[_alertBar]!=valc[_alertBar-1])
         {
            if (valc[_alertBar]==2) doAlert("slope changed to UP");
            if (valc[_alertBar]==1) doAlert("slope changed to DOWN");
         }
   }
   return(rates_total);
}

//----------------------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------------------
//
//
//

void doAlert(string doWhat, int instanceNo=0)
{
   struct sWorkStruct
   {
      public :
         datetime prevTime;
         string   prevMessage;
         
         void sWorkStruct() : prevTime(-1), prevMessage("") {};
   };
   static sWorkStruct m_array[];
   static int         m_arraySize = -1;
                  if (m_arraySize<instanceNo+1) m_arraySize = ArrayResize(m_array,instanceNo+1);
   
   //
   //
   //
   
   if (m_array[instanceNo].prevMessage != doWhat || m_array[instanceNo].prevTime != iTime(_Symbol,_Period,0)) 
   {
      m_array[instanceNo].prevMessage  = doWhat;
      m_array[instanceNo].prevTime     = iTime(_Symbol,_Period,0);

      //
      //
      //

      string message = StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7)+"  "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" ATR adaptive JMA - "+doWhat;
         if (inpAlertsMessage) Alert(message);
         if (inpAlertsEmail)   SendMail(_Symbol+" ATR adaptive JMA",message);
         if (inpAlertsPush)    SendNotification(message);
         if (inpAlertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _smoothInstances     1
#define _smoothInstancesSize 10
#define _smoothRingSize      11
double workSmooth[_smoothRingSize][_smoothInstances*_smoothInstancesSize];
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9
//
//
//
double iSmooth(double price, double length, double phase, int i, int instance=0)
{
   int _indP = (i-1)%_smoothRingSize;
   int _indC = (i  )%_smoothRingSize;
   int _inst = instance*_smoothInstancesSize;

   if(i==0 || length<=1) { int k=0; for(; k<volty; k++) workSmooth[_indC][_inst+k]=price; for(; k<_smoothInstancesSize; k++) workSmooth[_indC][_inst+k]=0; return(price); }

   //
   //
   //

      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1.0)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = price - workSmooth[_indP][_inst+bsmax], absDel1 = MathAbs(del1);
      double del2 = price - workSmooth[_indP][_inst+bsmin], absDel2 = MathAbs(del2);
      int   _indF = (i-MathMin(i,10))%_smoothRingSize;

         workSmooth[_indC][_inst+volty]  = (absDel1 > absDel2) ? absDel1 : (absDel1 < absDel2) ? absDel2 : 0;
         workSmooth[_indC][_inst+vsum]   = workSmooth[_indP][_inst+vsum]+(workSmooth[_indC][_inst+volty]-workSmooth[_indF][_inst+volty])*0.1;
         workSmooth[_indC][_inst+avolty] = workSmooth[_indP][_inst+avolty]+(2.0/(MathMax(4.0*length,30)+1.0))*(workSmooth[_indC][_inst+vsum]-workSmooth[_indP][_inst+avolty]);
      
      double dVolty    = (workSmooth[_indC][_inst+avolty]>0) ? workSmooth[_indC][_inst+volty]/workSmooth[_indC][_inst+avolty]: 0;
      double dVoltyTmp = MathPow(len1,1.0/pow1);
         if (dVolty > dVoltyTmp) dVolty = dVoltyTmp;
         if (dVolty < 1.0)       dVolty = 1.0;

      double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         workSmooth[_indC][_inst+bsmax] = (del1 > 0) ? price : price - Kv*del1;
         workSmooth[_indC][_inst+bsmin] = (del2 < 0) ? price : price - Kv*del2;

      //
      //
      //

      double corr  = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

          workSmooth[_indC][_inst+0] = price + alpha*(workSmooth[_indP][_inst+0]-price);
          workSmooth[_indC][_inst+1] = (price - workSmooth[_indC][_inst+0])*(1-beta) + beta*workSmooth[_indP][_inst+1];
          workSmooth[_indC][_inst+2] = (workSmooth[_indC][_inst+0] + corr*workSmooth[_indC][_inst+1]);
          workSmooth[_indC][_inst+3] = (workSmooth[_indC][_inst+2] - workSmooth[_indP][_inst+4])*((1-alpha)*(1-alpha)) + (alpha*alpha)*workSmooth[_indP][_inst+3];
          workSmooth[_indC][_inst+4] = (workSmooth[_indP][_inst+4] + workSmooth[_indC][_inst+3]);
   return(workSmooth[_indC][_inst+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
}    
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
