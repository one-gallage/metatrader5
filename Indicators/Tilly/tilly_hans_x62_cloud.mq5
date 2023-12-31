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
#property description "tilly_hans_x62_cloud"
#property description "© ErangaGallage"
#property strict


/* Introduction:
   Hans_Indicator_x62_Cloud_System_Tail_Alert.mq5
   Draw ranges for "Simple Combined Breakout System for EUR/USD and GBP/USD" thread
   (see http://www.strategybuilderfx.com/forums/showthread.php?t=15439)

   LocalTimeZone: TimeZone for which MT5 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  
                  The MetaQuotes demo server uses GMT +2.   
   Enjoy  :-)
   
   Markus

*/

#property indicator_chart_window  
#property indicator_buffers 74
#property indicator_plots   68

#define LINES_TOTAL         32    
#define RESET               NULL  

#property indicator_type1   DRAW_FILLING
#property indicator_color1 clrNONE
#property indicator_label1  "Upper Hans_Indicator_x62 cloud"

#property indicator_type2   DRAW_FILLING
#property indicator_color2 clrNONE
#property indicator_label2  "Lower Hans_Indicator_x62 cloud"

#property indicator_type3   DRAW_LINE
#property indicator_color3 clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label3  "Upper Hans_Indicator 1"

#property indicator_type4   DRAW_LINE
#property indicator_color4 clrMagenta
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
#property indicator_label4  "Lower Hans_Indicator 1"

#property indicator_type5   DRAW_LINE
#property indicator_color5 clrLime
#property indicator_style5  STYLE_SOLID
#property indicator_width5 3
#property indicator_label5  "Upper Hans_Indicator 2"

#property indicator_type6   DRAW_LINE
#property indicator_color6 clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  3
#property indicator_label6  "Lower Hans_Indicator 2"

#property indicator_type7   DRAW_LINE
#property indicator_color7 clrGreen
#property indicator_style7  STYLE_SOLID
#property indicator_width7 3
#property indicator_label7  "Upper Hans_Indicator 3"

#property indicator_type8   DRAW_LINE
#property indicator_color8 clrIndigo
#property indicator_style8  STYLE_SOLID
#property indicator_width8  3
#property indicator_label8  "Lower Hans_Indicator 3"

#property indicator_type9   DRAW_LINE
#property indicator_color9 clrGreen
#property indicator_style9  STYLE_DASH
#property indicator_width9 1
#property indicator_label9  "Upper Hans_Indicator 4"

#property indicator_type10   DRAW_LINE
#property indicator_color10 clrIndigo
#property indicator_style10  STYLE_DASH
#property indicator_width10  1
#property indicator_label10  "Lower Hans_Indicator 4"

#property indicator_type11   DRAW_LINE
#property indicator_color11 clrGreen
#property indicator_style11  STYLE_DASHDOTDOT
#property indicator_width11 1
#property indicator_label11  "Upper Hans_Indicator 5"

#property indicator_type12   DRAW_LINE
#property indicator_color12 clrIndigo
#property indicator_style12  STYLE_DASHDOTDOT
#property indicator_width12  1
#property indicator_label12  "Lower Hans_Indicator 5"

#property indicator_type13   DRAW_LINE
#property indicator_color13 clrGreen
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1
#property indicator_label13  "Upper Hans_Indicator 6"

#property indicator_type14   DRAW_LINE
#property indicator_color14 clrIndigo
#property indicator_style14  STYLE_SOLID
#property indicator_width14  1
#property indicator_label14  "Lower Hans_Indicator 6"

#property indicator_type67   DRAW_LINE
#property indicator_color67 clrSlateGray
#property indicator_style67  STYLE_SOLID
#property indicator_width67 2
#property indicator_label67  "Middle Hans_Indicator"

input uint LocalTimeZone=0;        
input uint DestTimeZone=2;        
input uint PipsForEntryStep=50;  
input int  Shift=0;  
uint NumberofBar=1;   
uint NumberofAlerts=2;   
input bool AlertsON=false;  
uint Slip=0;             

double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[],MiddleBuffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
int  min_rates_total;

class CIndicatorsBuffers{
public: double    ZoneUpper[];
public: double    ZoneLower[];
};

CIndicatorsBuffers Ind[];

int OnInit()
  {

   min_rates_total=20;

   ENUM_LINE_STYLE line_style[];
   color line_color[];
   int line_width[];
   ENUM_DRAW_TYPE plot_type[];

   int size=10;
   ArrayResize(line_style,size);
   ArrayResize(line_color,size);
   ArrayResize(line_width,size);
   ArrayResize(plot_type,size);
   ArrayResize(Ind,LINES_TOTAL);

   for(int plot=4; plot<14; plot++)
     {
      plot_type[plot-4]=ENUM_DRAW_TYPE(PlotIndexGetInteger(plot,PLOT_DRAW_TYPE));
      line_style[plot-4]=ENUM_LINE_STYLE(PlotIndexGetInteger(plot,PLOT_LINE_STYLE));
      line_width[plot-4]=PlotIndexGetInteger(plot,PLOT_LINE_WIDTH);
      line_color[plot-4]=color(PlotIndexGetInteger(plot,PLOT_LINE_COLOR));
     }


   for(int step=0; step<5; step++) for(int count=0; count<10; count++)
     {
      int number=14+10*step+count;
      PlotIndexSetInteger(number,PLOT_DRAW_TYPE,plot_type[count]);
      PlotIndexSetInteger(number,PLOT_LINE_STYLE,line_style[count]);
      PlotIndexSetInteger(number,PLOT_LINE_WIDTH,line_width[count]);
      PlotIndexSetInteger(number,PLOT_LINE_COLOR,line_color[count]);
     }
   for(int count=0; count<2; count++)
     {
      int number=64+count;
      PlotIndexSetInteger(number,PLOT_DRAW_TYPE,plot_type[count]);
      PlotIndexSetInteger(number,PLOT_LINE_STYLE,line_style[count]);
      PlotIndexSetInteger(number,PLOT_LINE_WIDTH,line_width[count]);
      PlotIndexSetInteger(number,PLOT_LINE_COLOR,line_color[count]);
     }
   for(int count=0; count<LINES_TOTAL-6; count++)
     {
      PlotIndexSetString(14+2*count,PLOT_LABEL,"Upper Hans_Indicator "+string(7+count));
      PlotIndexSetString(15+2*count,PLOT_LABEL,"Lower Hans_Indicator "+string(7+count));
     }

   IndBufferInit(0,UpUpBuffer);
   IndBufferInit(1,UpDnBuffer);

   IndBufferInit(2,DnUpBuffer);
   IndBufferInit(3,DnDnBuffer);

   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      IndBufferInit(4+2*numb,Ind[numb].ZoneUpper);
      IndBufferInit(5+2*numb,Ind[numb].ZoneLower);
     }

   IndBufferInit(4+2*LINES_TOTAL,MiddleBuffer);

   IndBufferInit(5+2*(LINES_TOTAL),ExtOpenBuffer);
   IndBufferInit(6+2*(LINES_TOTAL),ExtHighBuffer);
   IndBufferInit(7+2*(LINES_TOTAL),ExtLowBuffer);
   IndBufferInit(8+2*(LINES_TOTAL),ExtCloseBuffer);
   IndBufferInit(9+2*(LINES_TOTAL),ExtColorBuffer);

//---- Инициализация индикаторов  
//for(int count=0; count<2; count++) IndCldInit(count,min_rates_total,Shift);
   for(int count=0; count<2; count++) IndInit(count,EMPTY_VALUE,min_rates_total,Shift);
   for(int count=2; count<2*LINES_TOTAL+6; count++) IndInit(count,NULL,min_rates_total,Shift);

   IndicatorSetString(INDICATOR_SHORTNAME, "tilly_hans_x62_cloud");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   return(INIT_SUCCEEDED);
 }
   
void IndBufferInit(int BuffNumber,double &Buffer[])
 {

   SetIndexBuffer(BuffNumber,Buffer,INDICATOR_DATA);
   ArraySetAsSeries(Buffer,true);
}

void IndCldInit(int PlotNumber,int Draw_Begin,int nShift)
{

   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,Draw_Begin);
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,nShift);
   PlotIndexSetInteger(PlotNumber,PLOT_SHOW_DATA,false);
}

void IndInit(int PlotNumber,double Empty_Value,int Draw_Begin,int nShift)
{

   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,Draw_Begin);
   PlotIndexSetDouble(PlotNumber,PLOT_EMPTY_VALUE,Empty_Value);
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,nShift);
   PlotIndexSetInteger(PlotNumber,PLOT_SHOW_DATA,false);

}

int OnCalculate(
                const int rates_total,    
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
{

   if(rates_total<min_rates_total) return(RESET);

   int limit,limit1;

   if(prev_calculated>rates_total || prev_calculated<=0)
   {
      limit=limit1=rates_total-min_rates_total-1; 
   }
   else limit=limit1=rates_total-prev_calculated;

   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

   BreakoutRanges(0,limit,LocalTimeZone,DestTimeZone,rates_total,Time,Open,High,Low,Close);

   //BuySignal("Hans_Indicator_x62_Cloud_System_Tail_Alert",ExtColorBuffer,rates_total,prev_calculated,Close,Spread);
   //SellSignal("Hans_Indicator_x62_Cloud_System_Tail_Alert",ExtColorBuffer,rates_total,prev_calculated,Close,Spread);
  
   return(rates_total);
}

void BuySignal(string SignalSirname,      
               double &ColorArrow[],      
               const int Rates_total,    
               const int Prev_calculated, 
               const double &Close[],     
               const int &Spread[])       
{

   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArrow);
   int index,index1;
   if(SeriesTest)
     {
      index=int(NumberofBar);
      index1=index+1;
     }
   else
     {
      index=Rates_total-int(NumberofBar)-1;
      index1=index-1;
     }
   if(ColorArrow[index]<2 && ColorArrow[index1]>1) BuySignal=true;
   if(BuySignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      SeriesTest=ArrayGetAsSeries(Close);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      double Ask=Close[index];
      double Bid=Close[index];
      SeriesTest=ArrayGetAsSeries(Spread);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      Alerts("LONG");
     }
}

void SellSignal(string SignalSirname,      
                double &ColorArrow[],      
                const int Rates_total,     
                const int Prev_calculated, 
                const double &Close[],     
                const int &Spread[])       
{

   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArrow);
   int index,index1;
   if(SeriesTest)
     {
      index=int(NumberofBar);
      index1=index+1;
     }
   else
     {
      index=Rates_total-int(NumberofBar)-1;
      index1=index-1;
     }
   if(ColorArrow[index]>2 && ColorArrow[index1]<3) SellSignal=true;
   if(SellSignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      SeriesTest=ArrayGetAsSeries(Close);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      double Ask=Close[index];
      double Bid=Close[index];
      SeriesTest=ArrayGetAsSeries(Spread);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      Alerts("SHORT");
     }

}
  
void Alerts(string txt)
{

   Print(MQLInfoString(MQL_PROGRAM_NAME), " ",EnumToString(Period())," ",Symbol()," ", txt);
   if(AlertsON){ 
      PlaySound("alert.wav");
      Alert(MQLInfoString(MQL_PROGRAM_NAME), " ", EnumToString(Period())," ",Symbol()," ", txt);
   }

}
    

string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
{
   return(StringSubstr(EnumToString(timeframe),7,-1));
}

int BreakoutRanges(int offset,int &lastbar,int tzlocal,int tzdest,const int rates_total_,const datetime &Time_[],
                   const double &Open_[],const double &High_[],const double &Low_[],const double &Close_[])
{

   int i,j,k,
   tzdiff=tzlocal-tzdest,
   tzdiffsec=tzdiff*3600,
   tidxstart[2]={ 0,0},
   tidxend[2]={ 0,0 };
   double thigh[2]={ 0.0,0.0 },
   tlow[2]={ DBL_MAX };
   string tfrom[3]={ "04:00","08:00",/*rest of day: */ "12:00"},
   tto[3]={ "08:00","12:00",/*rest of day: */ "24:00" },
   tday;
   bool inperiod=-1;
   datetime timet;

//
// search back for the beginning of the day
//
   tday=TimeToString(Time_[lastbar]-tzdiffsec,TIME_DATE);
   for(; lastbar<rates_total_-1; lastbar++)
     {
      if(TimeToString(Time_[lastbar]-tzdiffsec,TIME_DATE)!=tday)
        {
         lastbar--;
         break;
        }
     }

//
// find the high/low for the two periods and carry them forward through the day
//
   tday="XXX";
   for(i=lastbar; i>=offset; i--)
     {

      timet=Time_[i]-tzdiffsec;   // time of this bar

      string timestr=TimeToString(timet,TIME_MINUTES),// current time HH:MM
      thisday=TimeToString(timet,TIME_DATE);       // current date

                                                   //
      // for all three periods (first period, second period, rest of day)
      //
      for(j=0; j<2; j++)
        {
         if(tfrom[j]<=timestr && timestr<tto[j])
           {   // Bar[i] in this period
            if(inperiod!=j)
              { // entered new period, so last one is completed

               if(j>0)
                 {      // now draw high/low back over the recently completed period
                  for(k=tidxstart[j-1]; k>=tidxend[j-1]; k--)
                    {
                     ExtOpenBuffer[k]=ExtHighBuffer[k]=ExtLowBuffer[k]=ExtCloseBuffer[k]=NULL;
                     ExtColorBuffer[k]=2;
                     if(j-1==0)
                       {
                        Ind[0].ZoneUpper[k]= thigh[j-1];
                        Ind[0].ZoneLower[k]= tlow[j-1];
                        MiddleBuffer[k]=(Ind[0].ZoneUpper[k]+Ind[0].ZoneLower[k])/2;

                        if(Close_[k]>Ind[0].ZoneUpper[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]>=Open_[k]) ExtColorBuffer[k]=0;
                           else ExtColorBuffer[k]=1;
                          }
                        if(Close_[k]<Ind[0].ZoneLower[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]<=Open_[k]) ExtColorBuffer[k]=4;
                           else ExtColorBuffer[k]=3;
                          }
                       }

                     if(j-1==1)
                       {
                        Ind[1].ZoneUpper[k]= thigh[j-1];
                        Ind[1].ZoneLower[k]= tlow[j-1];
                        MiddleBuffer[k]=(Ind[1].ZoneUpper[k]+Ind[1].ZoneLower[k])/2;
                        if(Close_[k]>Ind[1].ZoneUpper[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]>=Open_[k]) ExtColorBuffer[k]=0;
                           else ExtColorBuffer[k]=1;
                          }
                        if(Close_[k]<Ind[1].ZoneLower[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]<=Open_[k]) ExtColorBuffer[k]=4;
                           else ExtColorBuffer[k]=3;
                          }
                       }
                    }
                 }

               inperiod=j;   // remember current period
              }

            if(inperiod==2) // inperiod==2 (end of day) is just to check completion of zone 2
               break;

            // for the current period find idxstart, idxend and compute high/low
            if(tidxstart[j]==0)
              {
               tidxstart[j]=i;
               tday=thisday;
              }

            tidxend[j]=i;

            thigh[j]=MathMax(thigh[j],High_[i]);
            tlow[j]=MathMin(tlow[j],Low_[i]);
           }
        }

      // 
      // carry forward the periods for which we have definite high/lows
      //
      if(inperiod>=1 && tday==thisday)
        { // first time period completed

         for(int numb=1; numb<LINES_TOTAL; numb++)
           {
            Ind[numb].ZoneUpper[i]=thigh[0]+numb*PipsForEntryStep*_Point;
            Ind[numb].ZoneLower[i]=tlow[0]-numb*PipsForEntryStep*_Point;
           }

         Ind[0].ZoneUpper[i]=Ind[1].ZoneUpper[i];
         Ind[0].ZoneLower[i]=Ind[1].ZoneLower[i];

         for(int numb=1; numb<LINES_TOTAL; numb++)
           {
            Ind[numb].ZoneUpper[i]+=Slip*PipsForEntryStep*_Point;
            Ind[numb].ZoneLower[i]-=Slip*PipsForEntryStep*_Point;
           }

         MiddleBuffer[i]=UpDnBuffer[i]=DnUpBuffer[i]=(Ind[0].ZoneUpper[i]+Ind[0].ZoneLower[i])/2;
         UpUpBuffer[i]=Ind[LINES_TOTAL-1].ZoneUpper[i];
         DnDnBuffer[i]=Ind[LINES_TOTAL-1].ZoneLower[i];
         ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
         ExtColorBuffer[i]=2;
         if(Close_[i]>Ind[0].ZoneUpper[i])
           {
            ExtOpenBuffer[i]=Open_[i];
            ExtHighBuffer[i]=High_[i];
            ExtLowBuffer[i]=Low_[i];
            ExtCloseBuffer[i]=Close_[i];
            if(Close_[i]>=Open_[i]) ExtColorBuffer[i]=0;
            else ExtColorBuffer[i]=1;
           }
         if(Close_[i]<Ind[0].ZoneLower[i])
           {
            ExtOpenBuffer[i]=Open_[i];
            ExtHighBuffer[i]=High_[i];
            ExtLowBuffer[i]=Low_[i];
            ExtCloseBuffer[i]=Close_[i];
            if(Close_[i]<=Open_[i]) ExtColorBuffer[i]=4;
            else ExtColorBuffer[i]=3;
           }
        }
      else
        {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)         
         Ind[0].ZoneUpper[i]=NULL;
         Ind[0].ZoneLower[i]=NULL;
         for(int numb=0; numb<LINES_TOTAL; numb++)
           {
            Ind[numb].ZoneUpper[i]=NULL;
            Ind[numb].ZoneLower[i]=NULL;
           }
         MiddleBuffer[i]=UpDnBuffer[i]=DnUpBuffer[i]=UpUpBuffer[i]=DnDnBuffer[i]=NULL;
         ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
         ExtColorBuffer[i]=2;
        }

      //
      // at the beginning of a new day reset everything
      //
      if(tday!="XXX" && tday!=thisday)
        {

         tday="XXX";
         inperiod=-1;
         for(j=0; j<2; j++)
           {
            tidxstart[j]=0;
            tidxend[j]=0;

            thigh[j]=0;
            tlow[j]=99999;
           }
        }
     }

   return (0);
}

//+------------------------------------------------------------------+
