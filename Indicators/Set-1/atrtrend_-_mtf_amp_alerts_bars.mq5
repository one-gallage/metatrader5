//------------------------------------------------------------------

   #property copyright "mladen"
   #property link      "www.forex-tsd.com"

//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1

#property indicator_label1  "AtrTrend"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  DeepSkyBlue,PaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//
//
//

input ENUM_TIMEFRAMES    TimeFrame     = PERIOD_CURRENT; // Time frame
input int                AtrLength     = 10;             // ATR calculaion period
input double             AtrMultiplier = 1.7;            // ATR multiplier
input ENUM_APPLIED_PRICE Price         = PRICE_CLOSE;    // Price to use
input bool               ViewAsCandles = true;          // View as candles ?
input bool               alertsOn         = false;       // Alert on trend change
input bool               alertsOnCurrent  = false;        // Alert on current bar
input bool               alertsMessage    = false;        // Display messageas on alerts
input bool               alertsSound      = false;       // Play sound on alerts
input bool               alertsEmail      = false;       // Send email on alerts

//
//
//
//
//

double sth[];
double stl[];
double sto[];
double stc[];
double colorBuffer[];
double countBuffer[];
ENUM_TIMEFRAMES timeFrame;
int             mtfHandle;
int             atrHandle;
bool            calculating;

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   int style = DRAW_COLOR_BARS; if (ViewAsCandles) style = DRAW_COLOR_CANDLES;
   SetIndexBuffer(0,sto,INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_DRAW_TYPE,style);
   SetIndexBuffer(1,sth,INDICATOR_DATA); PlotIndexSetInteger(1,PLOT_DRAW_TYPE,style);
   SetIndexBuffer(2,stl,INDICATOR_DATA); PlotIndexSetInteger(2,PLOT_DRAW_TYPE,style);
   SetIndexBuffer(3,stc,INDICATOR_DATA); PlotIndexSetInteger(3,PLOT_DRAW_TYPE,style);
   SetIndexBuffer(4,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(5,countBuffer,INDICATOR_CALCULATIONS); 

   //
   //
   //
   //
   //
         
   timeFrame   = MathMax(_Period,TimeFrame);
   calculating = (timeFrame==_Period);
   if (!calculating)
         mtfHandle = iCustom(NULL,timeFrame,getIndicatorName(),PERIOD_CURRENT,AtrLength,AtrMultiplier,Price);
         atrHandle = iATR(NULL,0,AtrLength);

   IndicatorSetString(INDICATOR_SHORTNAME,getPeriodToString(timeFrame)+" ATR trend ("+string(AtrLength)+")");
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double Up[];
double Dn[];
double Di[];
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{


   if (calculating)
   {
      if (ArraySize(Up)!=rates_total) ArrayResize(Up,rates_total);
      if (ArraySize(Dn)!=rates_total) ArrayResize(Dn,rates_total);
      if (ArraySize(Di)!=rates_total) ArrayResize(Di,rates_total);
      
         //
         //
         //
         //
         //
         
         double tatr[]; CopyBuffer(atrHandle,0,0,rates_total,tatr);
         
         for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
         {
            double atr    = tatr[i];
            double cprice = getPrice(Price,open,close,high,low,i);
            double mprice = (high[i]+low[i])/2;
                   Up[i]  = mprice+AtrMultiplier*atr;
                   Dn[i]  = mprice-AtrMultiplier*atr;
                   if (i==0) continue;
         
            //
            //
            //
            //
            //

            sto[i] = open[i];         
            stc[i] = close[i];
            sth[i] = high[i];         
            stl[i] = low[i];         
            Di[i] = Di[i-1];
               if (cprice > Up[i-1]) Di[i] =  1;
               if (cprice < Dn[i-1]) Di[i] = -1;
               if (Di[i] > 0) { Dn[i] = MathMax(Dn[i],Dn[i-1]); colorBuffer[i]=0; }
               else           { Up[i] = MathMin(Up[i],Up[i-1]); colorBuffer[i]=1; }
         }      
      
         countBuffer[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
         manageAlerts(time[rates_total-1],time[rates_total-2],colorBuffer,rates_total);
      return(rates_total);
   }
   
   //
   //
   //
   //
   //
   
      datetime times[]; 
      datetime startTime = time[0]-PeriodSeconds(timeFrame);
      datetime endTime   = time[rates_total-1];
         int bars = CopyTime(NULL,timeFrame,startTime,endTime,times);
        
         if (times[0]>time[0] || bars<1) return(prev_calculated);
               double tcolo[]; CopyBuffer(mtfHandle,4,0,bars,tcolo);
               double count[]; CopyBuffer(mtfHandle,5,0,bars,count);
         int maxb = (int)MathMax(MathMin(count[bars-1]*PeriodSeconds(timeFrame)/PeriodSeconds(_Period),rates_total-1),1);

         //
         //
         //
         //
         //
         
         for(int i=(int)MathMax(prev_calculated-maxb,0); i<rates_total; i++)
         {
            int d = dateArrayBsearch(times,time[i],bars);
            if (d > -1 && d < bars)
            {
               sto[i]         = open[i];
               stc[i]         = close[i];
               sth[i]         = high[i];
               stl[i]         = low[i];
               colorBuffer[i] = tcolo[d];
            }
         }

   //
   //
   //
   //
   //
   
   manageAlerts(times[bars-1],times[bars-2],tcolo,bars);
   return(rates_total);
}




//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts(datetime currTime, datetime prevTime, double& trend[], int bars)
{
   if (alertsOn)
   {
      datetime time     = currTime;
      int      whichBar = bars-1; if (!alertsOnCurrent) { whichBar = bars-2; time = prevTime; }
         
      //
      //
      //
      //
      //
         
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar] == 0) doAlert(time,"up");
         if (trend[whichBar] == 1) doAlert(time,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = _Symbol+" "+getPeriodToString(timeFrame)+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" ATR trend changed to "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+" ATR trend",message);
         if (alertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double getPrice(ENUM_APPLIED_PRICE price,const double& open[], const double& close[], const double& high[], const double& low[], int i)
{
   switch (price)
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
  
//
//
//
//
//

string getIndicatorName()
{
   string progPath     = MQL5InfoString(MQL5_PROGRAM_PATH);
   string terminalPath = TerminalInfoString(TERMINAL_PATH);
   
   int startLength = StringLen(terminalPath)+17;
   int progLength  = StringLen(progPath);
         string indicatorName = StringSubstr(progPath,startLength);
                indicatorName = StringSubstr(indicatorName,0,StringLen(indicatorName)-4);
   return(indicatorName);
}

//
//
//
//
//
 
string getPeriodToString(int period)
{
   int i;
   static int    _per[]={1,2,3,4,5,6,10,12,15,20,30,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static string _tfs[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes",
                         "15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours",
                         "12 hours","daily","weekly","monthly"};
   
   if (period==PERIOD_CURRENT) 
       period = Period();   
            for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_tfs[i]);   
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int dateArrayBsearch(datetime& times[], datetime toFind, int total)
{
   int mid   = 0;
   int first = 0;
   int last  = total-1;
   
   while (last >= first)
   {
      mid = (first + last) >> 1;
      if (toFind == times[mid] || (mid < (total-1) && (toFind > times[mid]) && (toFind < times[mid+1]))) break;
      if (toFind <  times[mid])
            last  = mid - 1;
      else  first = mid + 1;
   }
   return (mid);
}