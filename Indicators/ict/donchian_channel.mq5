#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3



input int indPeriod=10; //Period
input color indColor=clrChartreuse; //Color

double upperBuff[];
double lowerBuff[];
double middleBuff[];
double upperLine,lowerLine,middleLine;
int start, bar;

void indInit(int index, double &buffer[],string label)
{
   SetIndexBuffer(index,buffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(index,PLOT_LINE_WIDTH,2);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,indPeriod-1);
   PlotIndexSetInteger(index,PLOT_SHIFT,1);
   PlotIndexSetInteger(index,PLOT_LINE_COLOR,indColor);
   PlotIndexSetString(index,PLOT_LABEL,label);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,EMPTY_VALUE);
}

int OnInit()
{
   indInit(0,upperBuff,"Donchian Channel Low");
   indInit(1,lowerBuff,"Donchian Channel High");
   indInit(2,middleBuff,"Donchian Channel Middle");
   IndicatorSetString(INDICATOR_SHORTNAME,"Donchian ("+IntegerToString(indPeriod)+")");

   return(INIT_SUCCEEDED);
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
   if(rates_total<indPeriod+1)
     {
      return 0;
     }
   start=prev_calculated==0? indPeriod: prev_calculated-1;
   for(bar=start;bar<rates_total;bar++)
   {
      upperLine=high[ArrayMaximum(high,bar-indPeriod+1,indPeriod)];
      lowerLine=low[ArrayMinimum(low,bar-indPeriod+1,indPeriod)];
      middleLine=(upperLine+lowerLine)/2;
      
      upperBuff[bar]=upperLine-(upperLine-lowerLine);
      lowerBuff[bar]=lowerLine+(upperLine-lowerLine);
      middleBuff[bar]=middleLine;
   }
   return(rates_total);
}