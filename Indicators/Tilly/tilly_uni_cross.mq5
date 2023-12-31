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
#property description "tillY_uni_cross"
#property description "© ErangaGallage"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

#property indicator_label1  "uni_cross_up"
#property indicator_color1  clrBlue
#property indicator_width1  1

#property indicator_label2  "uni_cross_dn"
#property indicator_color2  clrRed
#property indicator_width2  1

#property indicator_label3  "uni_cross_trend"
#property indicator_type3   DRAW_NONE

#property indicator_label4  "uni_cross_tmac"
#property indicator_type4   DRAW_NONE

#property indicator_label5  "uni_cross_t3c"
#property indicator_type5   DRAW_NONE

input bool                 Repaint           = false;   
input int                  T3Period          = 14;
input ENUM_APPLIED_PRICE   T3Price           = PRICE_CLOSE;
input double               T3Hot             = 0.382;
input bool                 T3Original        = false;
input int                  TMAHalfCycle      = 1;
//input int    TMAHalfCycle    = 5;
input ENUM_APPLIED_PRICE   TMAPrice          = PRICE_CLOSE;
input bool                 AlertsOn          = false;

bool   AlertsOnCurrent = true;
bool   AlertsMessage   = true;
bool   AlertsSound     = false;
bool   AlertsEmail     = false;
string soundfile       = "alert2.wav";

double   BUF_UP[];
double   BUF_DN[];
double   BUF_TREND[];
double   BUF_TMAC[];
double   BUF_T3C[];

int Dist2 = 20;
int   min_rates_total;
int   handle_TMA = 0;

int OnInit()
{
   min_rates_total = T3Period;
   
   SetIndexBuffer(0,BUF_UP,INDICATOR_DATA); PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);  
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_ARROW); PlotIndexSetInteger(0,PLOT_ARROW,233);    
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total); 
   ArraySetAsSeries(BUF_UP,true);
   
   SetIndexBuffer(1,BUF_DN,INDICATOR_DATA); PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_ARROW); PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total); 
   ArraySetAsSeries(BUF_DN,true);   
   
   SetIndexBuffer(2,BUF_TREND,INDICATOR_DATA); PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);   
   ArraySetAsSeries(BUF_TREND,true); 
   
   SetIndexBuffer(3,BUF_TMAC,INDICATOR_DATA); PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);   
   ArraySetAsSeries(BUF_TMAC,true); 
   
   SetIndexBuffer(4,BUF_T3C,INDICATOR_DATA); PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);   
   ArraySetAsSeries(BUF_T3C,true);          
   
   if((handle_TMA = iMA(NULL,0,1,0,MODE_SMA,TMAPrice)) == INVALID_HANDLE ) return(INIT_FAILED);
   
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason){ }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   
   int to_copy,limit,i,j,k;
   
   if(prev_calculated>rates_total || prev_calculated<=0) {      
      limit=rates_total-min_rates_total;       // starting index for calculation of all bars
   }
   else {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
   }
   
   to_copy = limit+TMAHalfCycle+min_rates_total;   

   ArraySetAsSeries(open,true);   
   ArraySetAsSeries(high,true);     
   ArraySetAsSeries(low,true);     
   ArraySetAsSeries(close,true);     
   
   double ARR_TMA[];
   
   if(copyHandleValue(handle_TMA, 0, to_copy, ARR_TMA) == false) return(0); 
   
   for (i=limit; i>=0 && !IsStopped(); i--)  {
   
      double sum  = (TMAHalfCycle+1)*ARR_TMA[i];
      double sumw = (TMAHalfCycle+1);
         for(j=1, k=TMAHalfCycle; j<=TMAHalfCycle; j++, k--) {
            sum  += k*ARR_TMA[i+j];
            sumw += k;
            if (Repaint && j<=i)
            {
               sum  += k*ARR_TMA[i-j];
               sumw += k;
            }
         }
         BUF_TMAC[i] = sum/sumw;
         BUF_T3C[i]  = iT3(ARR_TMA[i],T3Period,T3Hot,T3Original,i);         

         BUF_TREND[i] = BUF_TREND[i+1];         
         if (BUF_T3C[i]<BUF_TMAC[i]) BUF_TREND[i] =  1;            
         if (BUF_T3C[i]>BUF_TMAC[i]) BUF_TREND[i] = -1;
             
         BUF_UP[i] = EMPTY_VALUE; BUF_DN[i] = EMPTY_VALUE;     
         if (BUF_TREND[i] != BUF_TREND[i+1]) {
               if (BUF_TREND[i] > 0) { 
                  BUF_UP[i] = low[i] - Dist2*_Point;
                  //Print("i=", i, " BUF_UP:",BUF_UP[i]);  
               }
               else {
                  BUF_DN[i] = high[i] + Dist2*_Point;      
                  //Print("i=", i, " BUF_DN:", BUF_DN[i]);  
               }          
         }
         
      }       

      manageAlerts(time[rates_total-1],time[rates_total-2]);
      return(rates_total);
}      

bool copyHandleValue(int ind_handle, int buffer_num,int copy_count, double& return_array[] )
{
   ArraySetAsSeries(return_array, true);
   return CopyBuffer(ind_handle, buffer_num, 0, copy_count, return_array)>0;
}


void manageAlerts(datetime currTime, datetime prevTime)
{
   if (AlertsOn)
   {
      datetime time = currTime;
      int whichBar = 0; if (!AlertsOnCurrent) { whichBar = 1; time = prevTime; }
                   
      if (BUF_TREND[whichBar] != BUF_TREND[whichBar+1]){
         if (BUF_TREND[whichBar] == 1) doAlert(time,"up");
         else  doAlert(time,"down"); 
      }
   }
}   

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      message = "[" + MQLInfoString(MQL_PROGRAM_NAME) + "] " + doWhat + " @ " + _Symbol + " : M-"+(string)(PeriodSeconds(PERIOD_CURRENT)/60);
      if (AlertsMessage) Alert(message);
      if (AlertsEmail)   SendMail("Alert " + _Symbol,message);
      //if (AlertsNotify)  SendNotification(message);
      if (AlertsSound)   PlaySound(soundfile);
   }
}

double workT3[][6];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   int xbars = Bars(NULL, 0);
   if (ArrayRange(workT3,0) != xbars) {               ArrayResize(workT3,xbars);}
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) { ArrayResize(workT3Coeffs,instanceNo+1);}

   if (workT3Coeffs[instanceNo][_period] != period) {
     workT3Coeffs[instanceNo][_period] = period;
            double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   int buffer = instanceNo*6;
   int r = xbars-i-1;
   if (r == 0) {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
   }
   else {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
    }
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}





