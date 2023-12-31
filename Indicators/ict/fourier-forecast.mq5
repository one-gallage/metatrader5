//+------------------------------------------------------------------+
//|                                                     !Fourier.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// добавлена возможность сдвигать начало отсчета ( нажать CTRL)
//#import "Fourier64.dll"
// void   MathFourier(double &xm[], double &x[], int n, int n2, double reqTol, int Nh);
//#import

#property copyright "gpwr"
#property version "1.00"
#property description "Extrapolation of open prices by trigonometric (multitone) model"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
//--- future model outputs
#property indicator_label1 "Modeled future"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
//--- past model outputs
#property indicator_label2 "Modeled past"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
//--- global constants
//#define pi 3.141592653589793238462643383279502884197169399375105820974944592
//--- indicator inputs
input int Npast=1000;// Кол-во бар в прошлом
input int Nfut =300; // Кол-во бар в будущее
input int Nharm =140; // Кол-во гармоник
input double FreqTOL=0.000001; // Tolerance of frequency calculations
input int Start=100; // Начальный бар
//--- global variables
int N,u;
int key=0;
int start=0;
int Nh=Nharm;
//long to1,to2=0,to3=0,NN=0;
//--- indicator buffers
double ym[],xm[];
double xx[];
double p[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialize global variables
   N=Npast;

//--- indicator buffers mapping
//ArraySetAsSeries(xx,true);
   ArraySetAsSeries(xm,true);
   ArraySetAsSeries(ym,true);
   SetIndexBuffer(0,ym,INDICATOR_DATA);
   SetIndexBuffer(1,xm,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"Fourier("+string(N)+")");
   PlotIndexSetInteger(0,PLOT_SHIFT,Nfut-1);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   start=Start;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // размер массива price[]
                 const int prev_calculated,  // обработано баров на предыдущем вызове
                 const int begin,            // откуда начинаются значимые данные
                 const double &price[]) // массив для расчета

  {
   if(rates_total<N+begin) { Print("Error: not enough bars in history!"); return(0);}
   u=rates_total-1;
   ArrayResize(p,rates_total);
   if(prev_calculated<=0) // если индикатор еще не вычислялся
      ArrayCopy(p,price);
   else if(rates_total==prev_calculated) // дорисовываем изменени последнего тика если новый бар не создан
   p[u]=price[u];
   else                    // создан как минимум один новый бар
   ArrayCopy(p,price,prev_calculated,prev_calculated,rates_total-prev_calculated);
   BildFourier(start);
   ChartRedraw();
   return(rates_total);
  }
//--- обработчик события нажатия Ctrl и движения мыши

void OnChartEvent(
                  const int id,         // идентификатор события 
                  const long& lparam,   // параметр события типа long
                  const double& dparam, // параметр события типа double
                  const string& sparam  // параметр события типа string
                  )

  {
   double y;
   int window=0;
   datetime ttt;
   if(id==CHARTEVENT_KEYDOWN) key=(int)lparam;
//Comment(key);
   if(id==CHARTEVENT_MOUSE_MOVE && key==17)
     {
      ChartXYToTimePrice(0,(int)lparam,(int)dparam,window,ttt,y);
      if(ttt!=0) start=Bars(NULL,0,ttt,3200000000);
      //Comment("x = ",lparam,", y = ",dparam,", Price = ",y,", start = ",start);
      BildFourier(start);

      ChartRedraw();
     }

   if(id==CHARTEVENT_MOUSE_MOVE && key==16)
     {
      ChartXYToTimePrice(0,(int)lparam,(int)dparam,window,ttt,y);
      if(ttt!=0)
        {
         N=Bars(NULL,0,ttt,3200000000)-start;
         if(N<2) N=2;
         Nh=(int)MathRound(N/(Npast/Nharm));
         if(Nh==0) Nh=1;
         if(N<(Nh+5)) N=Nh+5;
        }
      //Comment("x = ",lparam,", y = ",dparam,", Price = ",y,", start = ",start);
      BildFourier(start);

      ChartRedraw();
     }

  }
//---  Построение кривых

void BildFourier(int st)
  {
   double x[];
   ArrayResize(x,N);

   if(ArrayCopy(x,p,0,u+1-st-N,N)!=N) return;

   ArrayResize(xx,N+Nfut);
//NN++;
//to1=(long)GetMicrosecondCount();
   MathFourier2(xx,x,N,Nfut,FreqTOL,Nh);
//to2=to2+(long)GetMicrosecondCount()-to1;
//to1=(long)GetMicrosecondCount();
//MathFourier(xx,x, N, Nfut, FreqTOL, Nh);
//to3=to3+(long)GetMicrosecondCount()-to1;
//Comment(to2/NN,"       ",to3/NN);
   ArrayInitialize(xm,EMPTY_VALUE);
   ArrayInitialize(ym,EMPTY_VALUE);
   ArrayCopy(xm,xx,st,0,N);
   ArrayCopy(ym,xx,st,N-1,Nfut);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  MathFourier2(double &xxx[],double &x9[],const int n,const int n1,double FreqTOL2,int Nharm2)
  {
   double av=0;
   double w,m,a,b;
   for(int i=0; i<n; i++) av+=x9[i];
   av/=n;  // av - среднне значение массива Close из Npast элементов
   for(int i=0; i<(n+n1); i++) xxx[i]=av;

   for(int harm=1; harm<=Nharm2; harm++)
     {
      //double z[3000];
      double z[];
      ArrayResize(z,n);

      double alpha= 0.0;
      double beta = 2.0;
      z[0]=x9[0]-xxx[0];

      while(fabs(alpha-beta)>FreqTOL2)
        {
         alpha= beta;
         z[1] = x9[1]-xxx[1]+alpha*z[0];
         double num = z[0] * z[1];
         double den = z[0] * z[0];
         for(int i=2; i<n; i++)
           {
            z[i] = x9[i] - xxx[i] + alpha*z[i - 1] - z[i - 2];
            num += z[i - 1] * (z[i] + z[i - 2]);
            den += z[i - 1] * z[i - 1];
           }
         if(den == 0) return;
         beta=num/den;
        }
      w=acos(beta/2.0);
      double Sc = 0.0;
      double Ss = 0.0;
      double Scc = 0.0;
      double Sss = 0.0;
      double Scs = 0.0;
      double Sx=0.0;
      double Sxc = 0.0;
      double Sxs = 0.0;
      for(int i=0; i<n; i++)
        {
         double c = cos(w*i);
         double s = sin(w*i);
         double dx= x9[i]-xxx[i];
         Sc += c;
         Ss += s;
         Scc += c*c;
         Sss += s*s;
         Scs += c*s;
         Sx+=dx;
         Sxc += dx*c;
         Sxs += dx*s;
        }
      Sc /= n;
      Ss /= n;
      Scc /= n;
      Sss /= n;
      Scs /= n;
      Sx/=n;
      Sxc /= n;
      Sxs /= n;
      if(w == 0.0)
        {
         m = Sx;
         a = 0.0;
         b = 0.0;
        }
      else
        {
         // calculating a, b, and m
         double den=pow(Scs-Sc*Ss,2) -(Scc-Sc*Sc)*(Sss-Ss*Ss);
         if(den == 0) return;
         a = ((Sxs - Sx*Ss)*(Scs - Sc*Ss) - (Sxc - Sx*Sc)*(Sss - Ss*Ss)) / den;
         b = ((Sxc - Sx*Sc)*(Scs - Sc*Ss) - (Sxs - Sx*Ss)*(Scc - Sc*Sc)) / den;
         m = Sx - a*Sc - b*Ss;
        }

      for(int i=0; i<(n+n1); i++)
        {
         xxx[i]+=m+a*cos(w*i)+b*sin(w*i);
        }
     }

  }
//+------------------------------------------------------------------+
