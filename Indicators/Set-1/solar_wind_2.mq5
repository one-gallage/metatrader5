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
#property description "solar_wind_2"
#property description "© ErangaGallage"
#property strict

#property indicator_separate_window 

#property indicator_buffers 8
#property indicator_plots   6

#property  indicator_color1  clrLimeGreen
#property  indicator_color2  clrRed
#property  indicator_color3  clrGold
#property  indicator_color4  clrLimeGreen
#property  indicator_color5  clrRed
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
#property  indicator_width4  2
#property  indicator_width5  2
 
input int length=35;
input int smooth=10; 

double         ExtBufferh1[];
double         ExtBufferh2[];
double         ExtBuffer3[];
double         ExtBuffer4[];
double         ExtBuffer5[];
double         ExtBufferTrend[];
double         ExtBuffer7[];
double         ExtBuffer8[];

int OnInit()
{
   SetIndexBuffer(0,ExtBufferh1); 
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   
   SetIndexBuffer(1,ExtBufferh2); 
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   
   SetIndexBuffer(2,ExtBuffer3);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
   
   SetIndexBuffer(3,ExtBuffer4);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
   
   SetIndexBuffer(4,ExtBuffer5);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_LINE);   
   
   SetIndexBuffer(5,ExtBufferTrend);
   PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_NONE);
      
   SetIndexBuffer(6,ExtBuffer7);
   PlotIndexSetInteger(6,PLOT_DRAW_TYPE,DRAW_NONE); 
 
   SetIndexBuffer(7,ExtBuffer8);
   PlotIndexSetInteger(7,PLOT_DRAW_TYPE,DRAW_NONE); 

   ArraySetAsSeries(ExtBufferh1,true);     
   ArraySetAsSeries(ExtBufferh2,true);    
   ArraySetAsSeries(ExtBuffer3,true);     
   ArraySetAsSeries(ExtBuffer4,true);     
   ArraySetAsSeries(ExtBuffer5,true);     
   ArraySetAsSeries(ExtBufferTrend,true);  
   ArraySetAsSeries(ExtBuffer7,true);
   ArraySetAsSeries(ExtBuffer8,true);     
    
   return INIT_SUCCEEDED;
}



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

   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;  
   
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(time,true);
      
   int limit;
   if(prev_calculated>rates_total || prev_calculated<=0) { 
      limit = rates_total - smooth - 1; // starting index for calculation of all bars
   }
   else {
      limit = rates_total - prev_calculated; // starting index for calculation of new bars
   }  


   for(int i=0; i<limit; i++) {  
      MaxH = high[ArrayMaximum(high,i,length)];
      MinL = low[ArrayMinimum(low,i,length)];
      price = (high[i]+low[i])/2.0;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
      Value=MathMin(MathMax(Value,-0.999),0.999); 
      ExtBuffer7[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      Value1=Value;
      Fish1=ExtBuffer7[i];
         if (ExtBuffer7[i]>0) ExtBufferTrend[i]=10; else ExtBufferTrend[i]=-10;      
    }

   for(int i=limit; i>=0; i--)
   {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i+k)<rates_total; k++)
      {
         double weight = smooth-k;
                sumw  += weight;
                sum   += weight*ExtBufferTrend[i+k];  
      }             
      if (sumw!=0)
            ExtBuffer8[i] = sum/sumw;
      else  ExtBuffer8[i] = 0;
   }      
   for(int i=0; i<=limit; i++)
   {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i-k)>=0; k++)
      {
         double weight = smooth-k;
                sumw  += weight;
                sum   += weight*ExtBuffer8[i-k];
      }             
      if (sumw!=0)
            ExtBuffer3[i] = sum/sumw;
      else  ExtBuffer3[i] = 0;
   }      
   for(int i=limit; i>=0; i--)
   {
      ExtBuffer4[i]=EMPTY_VALUE;
      ExtBuffer5[i]=EMPTY_VALUE;
      ExtBufferh1[i]=EMPTY_VALUE;
      ExtBufferh2[i]=EMPTY_VALUE;
      if (ExtBuffer3[i]>0) { ExtBuffer4[i]=ExtBuffer3[i]; ExtBufferh1[i]=ExtBuffer3[i]; }
      if (ExtBuffer3[i]<0) { ExtBuffer5[i]=ExtBuffer3[i]; ExtBufferh2[i]=ExtBuffer3[i]; }      

   }
   return rates_total;
}


