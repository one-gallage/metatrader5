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
#property description "tillY_ptl"
#property description "© ErangaGallage"
#property strict

//--- PTL (2) - Perfect trend line indicator by mladen

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   4
#property indicator_label1  "PTL trend candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrNONE,clrNONE   //clrDodgerBlue,clrCrimson
#property indicator_label2  "PTL slow line"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrDodgerBlue
#property indicator_label3  "PTL fast line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
#property indicator_style3  STYLE_DOT
#property indicator_label4  "PTL trend start"
#property indicator_type4   DRAW_COLOR_ARROW
#property indicator_color4  clrDodgerBlue,clrCrimson
#property indicator_width4  2

input int inpFastLength = 3; // Fast length
input int inpSlowLength = 7; // Slow length


double slowlu[],slowln[],fastln[],arrowar[],arrowcl[],candleo[],candleh[],candlel[],candlec[],candleC[];
int _fastPeriod,_slowPeriod;


int OnInit()
{
   SetIndexBuffer( 0,candleo,INDICATOR_DATA);
   SetIndexBuffer( 1,candleh,INDICATOR_DATA);
   SetIndexBuffer( 2,candlel,INDICATOR_DATA);
   SetIndexBuffer( 3,candlec,INDICATOR_DATA);
   SetIndexBuffer( 4,candleC,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 5,slowln ,INDICATOR_DATA);
   SetIndexBuffer( 6,fastln ,INDICATOR_DATA);
   SetIndexBuffer( 7,arrowar,INDICATOR_DATA);
   SetIndexBuffer( 8,arrowcl,INDICATOR_COLOR_INDEX);

   _fastPeriod = MathMax(MathMin(inpFastLength,inpSlowLength),1);
   _slowPeriod = MathMax(MathMax(inpFastLength,inpSlowLength),1);
      
   PlotIndexSetInteger(3,PLOT_ARROW,110);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { return; }

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
   struct sPtlStruct
   {
      datetime time;
      double   fastHigh;
      double   fastLow;
      double   slowHigh;
      double   slowLow;
      int      trend;
      int      trena;
   };
   static sPtlStruct m_array[];
   static int        m_arraySize=-1;
                 if (m_arraySize<rates_total) m_arraySize = ArrayResize(m_array,rates_total+500,2000);
  
   //
   //
   //
  
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (m_array[i].time != time[i])
      {
         m_array[i].time = time[i];
            int _startf = i-_fastPeriod+1; if (_startf<0) _startf = 0;
            int _starts = i-_slowPeriod+1; if (_starts<0) _starts = 0;
                                           if (i<rates_total-1) m_array[i+1].time = 0;
               m_array[i].fastHigh = high[ArrayMaximum(high,_startf,_fastPeriod-1)];
               m_array[i].fastLow  = low [ArrayMinimum(low ,_startf,_fastPeriod-1)];
               m_array[i].slowHigh = high[ArrayMaximum(high,_starts,_slowPeriod-1)];
               m_array[i].slowLow  = low [ArrayMinimum(low ,_starts,_slowPeriod-1)];
      }

      //
      //
      //
      
      double thighs = (high[i]<m_array[i].slowHigh) ? m_array[i].slowHigh : high[i];
      double tlows  = (low[i] >m_array[i].slowLow)  ? m_array[i].slowLow  : low[i];
      double thighf = (high[i]<m_array[i].fastHigh) ? m_array[i].fastHigh : high[i];
      double tlowf  = (low[i] >m_array[i].fastLow)  ? m_array[i].fastLow  : low[i];

      //
      //
      //
            
         m_array[i].trend = -1;
         if (i>0)
         {
            m_array[i].trena  = m_array[i-1].trena;
               slowln[i] = (close[i]>slowln[i-1]) ? tlows : thighs;
               fastln[i] = (close[i]>fastln[i-1]) ? tlowf : thighf;
                  if (close[i]<slowln[i] && close[i]<fastln[i])     m_array[i].trend = 1;
                  if (close[i]>slowln[i] && close[i]>fastln[i])     m_array[i].trend = 0;
                  if (slowln[i]>fastln[i] || m_array[i].trend == 1) m_array[i].trena = 1;
                  if (slowln[i]<fastln[i] || m_array[i].trend == 0) m_array[i].trena = 0;
              
                  //
                  //
                  //
              
                  arrowar[i] = (m_array[i].trena !=m_array[i-1].trena) ? (m_array[i].trena==1) ? MathMax(fastln[i],slowln[i]) : MathMin(fastln[i],slowln[i]) : EMPTY_VALUE;
         }
         else
         {
            arrowcl[i] = 0;
            arrowar[i] = EMPTY_VALUE;
            fastln[i]  = slowln[i] = close[i];
            m_array[i].trend = m_array[i].trena = 0;
         }
         if (m_array[i].trend!=-1)
            {
               candleo[i] = open[i];
               candleh[i] = high[i];
               candlel[i] = low[i];
               candlec[i] = close[i];
            }
         else candleo[i] = candleh[i] = candlel[i] = candlec[i] = EMPTY_VALUE;
        

        
         candleC[i] = m_array[i].trend;
         arrowcl[i] = m_array[i].trena;
   }          
   return(rates_total);
}