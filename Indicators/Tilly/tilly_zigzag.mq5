//+------------------------------------------------------------------+

//|                                   UniZigZagChannel_v1.9 600+.mq4 |

//|                                Copyright © 2016, TrendLaboratory |

//|            http://finance.groups.yahoo.com/group/TrendLaboratory |

//|                                   E-mail: igorad2003@yahoo.co.uk |

//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 clrLightPink
#property indicator_color2 clrLightBlue
#property indicator_color3 clrCoral
#property indicator_color4 clrCornflowerBlue
#property indicator_color5 clrAliceBlue
#property indicator_color6 clrOrangeRed
#property indicator_color7 clrOrange
#property indicator_color8 clrOliveDrab
#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 4
#property indicator_width6 4
#property indicator_style7 2
#property indicator_style8 2
enum ENUM_PRICE
{
close = 0,               // Close
open = 1,                // Open
high = 2,                // High
low = 3,                 // Low
median = 4,              // Median
typical = 5,             // Typical
weightedClose = 6,       // Weighted Close
heikenAshiCloses = 7,     // Heiken Ashi Close
heikenAshiOpens = 8,      // Heiken Ashi Open
heikenAshiHighs = 9,      // Heiken Ashi High
heikenAshiLows = 10,       // Heiken Ashi Low
heikenAshiMedian = 11,    // Heiken Ashi Median
heikenAshiTypical = 12,   // Heiken Ashi Typical
heikenAshiWeighted = 13   // Heiken Ashi Weighted Close
};

enum ENUM_BREAK
{
byclose = 0,            // by Close
byuplo =1              // by Up/Lo Band Price
};

enum ENUM_RETRACE
{
channel = 0,             // Price Channel
pctprice = 1,            // % of Price
pips = 2,                // Price Change in pips
ratr = 3                 // ATR Multiplier
};

enum ENUM_ZZCHANNEL
{
off = 0,                 // Off
hilo = 1,                // High/Low Channel
chaos = 2                // Chaos Bands
};

//---- input parameters

input double            ReversalValue        =       9;       // Reversal Value according to Retrace Method
input ENUM_RETRACE      RetraceMethod        =     ratr;       // Retrace Method
input int               ATR_Period            =       50;       // ATR Period (RetraceMethod=3)
ENUM_ZZCHANNEL    ZigZagChannelMode    =      off;       // ZigZag Channel Mode
bool              AlertOn              =    false;
ENUM_PRICE        UpBandPrice          =     high;       // Upper Band Price
ENUM_PRICE        LoBandPrice          =      low;       // Lower Band Price
ENUM_BREAK        BreakOutMode         =   byuplo;       // Breakout Mode
bool              ShowZigZag           =    false;       // Show ZigZag
bool              ShowSignals          =     true;       // Show Signals
bool              ShowPriceChannel     =    false;       // ShowPriceChannel
int               AlertShift           =        1;       // Alert Shift:0-current bar,1-previous bar
int               SoundsNumber         =        5;       // Number of sounds after Signal
int               SoundsPause          =        5;       // Pause in sec between sounds
bool              EmailOn              =    false;
int               EmailsNumber         =        1;
bool              PushNotificationOn   =    false;
double upZZ1[];
double dnZZ1[];
double hiBuffer[];
double loBuffer[];
double upSignal[];
double dnSignal[];
double hiband[];
double loband[];
double upPrice[];
double loPrice[];
int timeframe = 0;
int      trend[][3];
datetime hiTimes()[2), loTime()[2), prevtime[);
double   upBand[][2], loBand[][2], hiValue[][2], loValue[][2], _point;
int init()
{
Indicator_Digits(Digits);
IndicatorName = MQLInfoString(MQL5_PROGRAM_NAME);
IndicatorBuffers(10);
SetIndexBuffer(0,   upZZ1);
SetIndexStyle(0,DRAW_ZIGZAG);
SetIndexBuffer(1,   dnZZ1);
SetIndexStyle(1,DRAW_ZIGZAG);
SetIndexBuffer(2,hiBuffer);
SetIndexStyle(2,  DRAW_LINE);
SetIndexBuffer(3,loBuffer);
SetIndexStyle(3,  DRAW_LINE);
SetIndexBuffer(4,upSignal);
SetIndexEmptyValue(4,EMPTY_VALUE);
SetIndexStyle(4, DRAW_ARROW);
SetIndexArrow(4,159);
SetIndexBuffer(5,dnSignal);
SetIndexEmptyValue(5,EMPTY_VALUE);
SetIndexStyle(5, DRAW_ARROW);
SetIndexArrow(5,159);
SetIndexBuffer(6,  hiband);
if(ShowPriceChannel)
SetIndexStyle(6,DRAW_LINE);
else
SetIndexStyle(6,DRAW_NONE);
SetIndexBuffer(7,  loband);
if(ShowPriceChannel)
SetIndexStyle(7,DRAW_LINE);
else
SetIndexStyle(7,DRAW_NONE);
SetIndexBuffer(8, upPrice);
SetIndexBuffer(9, loPrice);
short_name = IndicatorName+"("+UpBandPrice+","+LoBandPrice+","+DoubleToString(ReversalValue,1)+","+RetraceMethod+")";
IndicatorShortName(short_name);
SetIndexLabel(0,"Upper ZigZag");
SetIndexEmptyValue(0,0.0);
SetIndexLabel(1,"Lower ZigZag");
SetIndexEmptyValue(1,0.0);
SetIndexLabel(2,"UniZigZag Upper Band");
SetIndexLabel(3,"UniZigZag Lower Band");
SetIndexLabel(4,"UpSignal");
SetIndexLabel(5,"DnSignal");
SetIndexLabel(6,"Channel\'s Upper Band");
SetIndexLabel(7,"Channel\'s Lower Band");
ArrayResize(prevtime,1);
ArrayResize(trend,1);
ArrayResize(hiTimes,1);
ArrayResize(loTime,1);
ArrayResize(upBand,1);
ArrayResize(loBand,1);
ArrayResize(hiValue,1);
ArrayResize(loValue,1);
_point = _Point*MathPow(10,_Digits%2);
return(0);
}

int deinit() {return(0);}
int start()
{
int i,counted_bars=IndicatorCounted(),limit;
if(counted_bars > 0)
limit = Bars(_Symbol,_Period) - counted_bars - 1;
if(counted_bars < 1)
{
limit = Bars(_Symbol,_Period) - 1;
for(i=0; i<limit; i++)
{
upZZ1[i]    = 0;
dnZZ1[i]    = 0;
hiBuffer[i] = 0;
loBuffer[i] = 0;
upSignal[i] = 0;
dnSignal[i] = 0;
hiband[i]   = 0;
loband[i]   = 0;
}

SetIndexDrawBegin(0, ReversalValue);
}

if(ReversalValue > 0)
_uniZigZag(upZZ1,dnZZ1,0, ReversalValue,limit,counted_bars);
return(0);
}

void _uniZigZag(double& upZZ[],double& dnZZ[],int index,double retrace,int limit,int counted_bars)
{
int i, nlow, nhigh;
for(int shift=limit; shift>=0; shift--)
{
if(prevtime[index) != Time(shift))
{
hiTimes[index)[1)  = hiTime(index)[0);
loTime(index)[1)  = loTime(index)[0);
upBand[index][1]  = upBand[index][0];
loBand[index][1]  = loBand[index][0];
hiValue[index][1] = hiValue[index][0];
loValue[index][1] = loValue[index][0];
trend[index][2]   = trend[index][1];
trend[index][1]   = trend[index][0];
prevtime[index)   = Time(shift);
}

if(shift < Bars(_Symbol,_Period) - retrace)
{
hiTimes[index)[0)  = hiTime(index)[1);
loTime(index)[0)  = loTime(index)[1);
upBand[index][0]  = upBand[index][1];
loBand[index][0]  = loBand[index][1];
hiValue[index][0] = 0;
loValue[index][0] = 0;
trend[index][0]   = trend[index][1];
if(UpBandPrice <= 6)
upPrice[shift] = iMa(NULL,0,1,0,0,(int)UpBandPrice,shift);
else
if(UpBandPrice > 6 && UpBandPrice <= 13)
upPrice[shift] = HeikenAshi(0,UpBandPrice-7,shift);
if(LoBandPrice <= 6)
loPrice[shift] = iMa(NULL,0,1,0,0,(int)LoBandPrice,shift);
else
if(LoBandPrice > 6 && LoBandPrice <= 13)
loPrice[shift] = HeikenAshi(1,LoBandPrice-7,shift);
switch(RetraceMethod)
{
case 0:
upBand[index][0] = upPrice[HighestBar(retrace,shift,0)];
loBand[index][0] = loPrice[ LowestBar(retrace,shift,0)];
break;
case 1:
if(upPrice[shift] > upBand[index][0])
{
upBand[index][0] = upPrice[shift];
loBand[index][0] = upBand[index][0]*(1 - 0.01*retrace);
}

if(loPrice[shift] < loBand[index][0])
{
loBand[index][0] = loPrice[shift];
upBand[index][0] = loBand[index][0]*(1 + 0.01*retrace);
}

break;
case 2:
if(upPrice[shift] >= upBand[index][0])
{
upBand[index][0] = upPrice[shift];
loBand[index][0] = upBand[index][0] - retrace*_point;
}

if(loPrice[shift] <= loBand[index][0])
{
loBand[index][0] = loPrice[shift];
upBand[index][0] = loBand[index][0] + retrace*_point;
}

break;
case 3:
double atr = iATr(NULL,0,ATR_Period,shift);
if(upPrice[shift] >= upBand[index][0])
{
upBand[index][0] = upPrice[shift];
loBand[index][0] = upBand[index][0] - retrace*atr;
}

if(loPrice[shift] <= loBand[index][0])
{
loBand[index][0] = loPrice[shift];
upBand[index][0] = loBand[index][0] + retrace*atr;
}

break;
}

upSignal[shift] = 0;
dnSignal[shift] = 0;
if(ShowPriceChannel)
{
hiband[shift] = upBand[index][0];
loband[shift] = loBand[index][0];
}

bool upbreak = false, dnbreak = false;
switch(BreakOutMode)
{
case 1:
if(upPrice[shift] > upBand[index][1] && trend[index][0] <= 0)
upbreak = true;
if(loPrice[shift] < loBand[index][1] && trend[index][0] >= 0)
dnbreak = true;
break;
default:
if(Close(shift) > upBand[index)[1) && trend[index)[0) <= 0)
upbreak = true;
if(Close(shift) < loBand[index)[1) && trend[index)[0) >= 0)
dnbreak = true;
break;
}

if(upbreak && (loPrice[shift) >= loBand[index)[1) ||(loPrice[shift) < loBand[index)[1) && Close(shift) > Close(shift+1))) && upBand[index)[1) > 0)
{
trend[index][0] = 1;
int lobar = LowestBar(iBarShifts(NULL,0,hiTimes[index][0],FALSE) - shift,shift,1);
loValue[index][0] = loPrice[lobar];
loTime(index)[0)  = Time(lobar);
if(ShowSignals)
upSignal[shift] = loValue[index][0];
if(ShowZigZag)
dnZZ[lobar]     = loValue[index][0];
}

if(dnbreak && (upPrice[shift) <= upBand[index)[1) ||(upPrice[shift) > upBand[index)[1) && Close(shift) < Close(shift+1))) && loBand[index)[1) > 0)
{
trend[index][0] =-1;
int hibar = HighestBar(iBarShifts(NULL,0,loTime(index)[0),FALSE)-shift,shift,1);
hiValue[index][0] = upPrice[hibar];
hiTimes[index)[0)  = Time(hibar);
if(ShowSignals)
dnSignal[shift] = hiValue[index][0];
if(ShowZigZag)
upZZ[hibar]     = hiValue[index][0];
}

if(shift == 0)
{
upZZ[shift] = 0;
dnZZ[shift] = 0;
if(trend[index][0] > 0)
{
int hilen = iBarShifts(NULL,0,loTime(index)[0),FALSE);
nhigh = HighestBar(hilen,0,1);
for(i=hilen; i>=0; i--)
upZZ[i] = 0;
if(ShowZigZag)
upZZ[nhigh]   = upPrice[nhigh];
if(!ShowPriceChannel)
hiband[shift] = hilen;
}

if(trend[index][0] < 0)
{
int lolen = iBarShifts(NULL,0,hiTimes[index][0],FALSE);
nlow = LowestBar(lolen,0,1);
for(i=lolen; i>=0; i--)
dnZZ[i] = 0;
if(ShowZigZag)
dnZZ[nlow]    = loPrice[nlow];
if(!ShowPriceChannel)
hiband[shift] = lolen;
}

}

if(ZigZagChannelMode > 0)
{
hiBuffer[shift] = hiBuffer[shift+1];
loBuffer[shift] = loBuffer[shift+1];
if(hiValue[index][0] > 0)
hiBuffer[shift] = hiValue[index][0];
if(ZigZagChannelMode == 1)
if(upPrice[shift] > hiBuffer[shift])
hiBuffer[shift] = upPrice[shift];
if(loValue[index][0] > 0)
loBuffer[shift] = loValue[index][0];
if(ZigZagChannelMode == 1)
if(loPrice[shift] < loBuffer[shift])
loBuffer[shift] = loPrice[shift];
}

}

}

if(AlertOn || EmailOn || PushNotificationOn)
{
bool uptrend = trend[index][AlertShift] > 0 && trend[index][AlertShift+1] <= 0;
bool dntrend = trend[index][AlertShift] < 0 && trend[index][AlertShift+1] >= 0;
if(uptrend || dntrend)
{
if(isNewBar(timeframe))
{
if(AlertOn)
{
BoxAlert(uptrend," : BUY Signal @ " +DoubleToString(Close(AlertShift),Digits));
BoxAlert(dntrend," : SELL Signal @ "+DoubleToString(Close(AlertShift),Digits));
}

if(EmailOn)
{
EmailAlert(uptrend,"BUY"," : BUY Signal @ " +DoubleToString(Close(AlertShift),Digits),EmailsNumber);
EmailAlert(dntrend,"SELL"," : SELL Signal @ "+DoubleToString(Close(AlertShift),Digits),EmailsNumber);
}

if(PushNotificationOn)
{
PushAlert(uptrend," : BUY Signal @ " +DoubleToString(Close(AlertShift),Digits));
PushAlert(dntrend," : SELL Signal @ "+DoubleToString(Close(AlertShift),Digits));
}

}

else
{
if(AlertOn)
{
WarningSound(uptrend,SoundsNumber,SoundsPause,UpTrendSound,Time(AlertShift));
WarningSound(dntrend,SoundsNumber,SoundsPause,DnTrendSound,Time(AlertShift));
}

}

}

}

}

int LowestBar(int len,int k,int opt)
{
double min = 10000000;
if(len <= 0)
int lobar = k;
else
for(int i=k+len-1; i>=k; i--)
{
double lo0 = loPrice[i];
if(opt == 1)
double lo1 = loPrice[i-1];
if((opt == 1 && (i==0 || (i > 0/*&& lo0 < lo1*/)) && lo0 <= min) || (opt==0 && lo0 <= min))
{
min = lo0;
lobar = i;
}

}

return(lobar);
}

int HighestBar(int len,int k,int opt)
{
double max = -10000000;
if(len <= 0)
int hibar = k;
else
for(int i=k+len-1; i>=k; i--)
{
double hi0 = upPrice[i];
if(opt==1)
double hi1 = upPrice[i-1];
if((opt==1 && (i==0 || (i > 0 /*&& hi0 > hi1*/)) && hi0 >= max) || (opt==0 && hi0 >= max))
{
max = hi0;
hibar = i;
}

}

return(hibar);
}

// HeikenAshi Price

double   haClose(2)[2), haOpen(2)[2), haHigh(2)[2), haLow(2)[2);
datetime prevhatime[2];
double HeikenAshi(int index,int price,int bar)
{
if(prevhatime[index) != Time(bar))
{
haClose(index)[1) = haClose(index)[0);
haOpen [index][1] = haOpen [index][0];
haHigh [index][1] = haHigh [index][0];
haLow  [index][1] = haLow  [index][0];
prevhatime[index) = Time(bar);
}

if(bar == Bars(_Symbol,_Period) - 1)
{
haClose(index)[0) = Close(bar);
haOpen [index][0] = Open [bar];
haHigh [index][0] = High [bar];
haLow  [index][0] = Low  [bar];
}

else
{
haClose(index)[0) = (Open(bar) + High(bar) + Low(bar) + Close(bar))/4;
haOpen [index)[0) = (haOpen(index)[1) + haClose(index)[1))/2;
haHigh [index)[0) = MathMax(High(bar),MathMax(haOpen(index)[0),haClose(index)[0)));
haLow  [index)[0) = MathMin(Low [bar),MathMin(haOpen(index)[0),haClose(index)[0)));
}

switch(price)
{
case  0:
return(haClose(index)[0));
break;
case  1:
return(haOpen [index][0]);
break;
case  2:
return(haHigh [index][0]);
break;
case  3:
return(haLow  [index][0]);
break;
case  4:
return((haHigh(index)[0) + haLow(index)[0))/2);
break;
case  5:
return((haHigh(index)[0) + haLow(index)[0) +   haClose(index)[0))/3);
break;
case  6:
return((haHigh(index)[0) + haLow(index)[0) + 2*haClose(index)[0))/4);
break;
default:
return(haClose(index)[0));
break;
}

}

datetime prevnbtime;
bool isNewBar(int tf)
{
bool res = false;
if(tf >= 0)
{
if(iTimes(NULL,tf,0) != prevnbtime)
{
res   = true;
prevnbtime = iTimes(NULL,tf,0);
}

}

else
res = true;
return(res);
}

bool BoxAlert(bool cond,string text)
{
if(cond && mess != prevmess)
{
Alert(mess);
prevmess = mess;
return(true);
}

return(false);
}

datetime pausetime;
bool Pause(int sec)
{
if(TimeCurrent() >= pausetime + sec)
{
pausetime = TimeCurrent();
return(true);
}

return(false);
}

datetime warningtime;
void WarningSound(bool cond,int num,int sec,string sound,datetime curtime)
{
static int i;
if(cond)
{
if(curtime != warningtime)
i = 0;
if(i < num && Pause(sec))
{
PlaySound(sound);
warningtime = curtime;
i++;
}

}

}

bool EmailAlert(bool cond,string text1,string text2,int num)
{
if(cond && mess != prevemail)
{
if(subj != "" && mess != "")
for(int i=0; i<num; i++)
SendMail(subj, mess);
prevemail = mess;
return(true);
}

return(false);
}

bool PushAlert(bool cond,string text)
{
if(cond && push != prevpush)
{
SendNotification(push);
prevpush = push;
return(true);
}

return(false);
}

//+------------------------------------------------------------------+



//+----This is an external returning function----+//


double iMa(string symbol, ENUM_TIMEFRAMES tf,int period = 0,int ma_shift = 0,ENUM_MA_METHOD method = MODE_EMA,int price = PRICE_CLOSE,int shift = 1){
int handle=iMA(symbol,tf,period,ma_shift,method,price);
if(handle<0){Print("The iMA object is not created: Error",GetLastError());
return(-1);
}
else{
return(CopyBufferMQL4(handle,0,shift));
}
}
double CopyBufferMQL4(int handle,int start,int shift)
	{
		double Array[];ArraySetAsSeries(Array,true);
		CopyBuffer(handle,0,start,100,Array);
		return Array[shift];
	}
datetime Time(int index){datetime time[];ArraySetAsSeries(time,true);CopyTime(_Symbol,_Period,0,3,time);return time[index];}
double Low(int index){double low[];ArraySetAsSeries(low,true);CopyTime(_Symbol,_Period,0,3,low);return low[index];}
double Open(int index){double open[];ArraySetAsSeries(open,true);CopyTime(_Symbol,_Period,0,3,open);return open[index];}
double High(int index){double high[];ArraySetAsSeries(high,true);CopyTime(_Symbol,_Period,0,3,high);return high[index];}
double Close(int index){double close[];ArraySetAsSeries(close,true);CopyTime(_Symbol,_Period,0,3,close);return close[index];}
double iATr(string symbol,ENUM_TIMEFRAMES tf,int period,int shift){int handle=iATR(symbol,tf,period);if(handle<0){Print("The iATR object is not created: Error",GetLastError());return(-1);}else{return(CopyBufferMQL4(handle,0,shift));}}
double iBarShifts(string symbol,ENUM_TIMEFRAMES tf,datetime time,bool exact=false){if(time<0)return(-1);datetime Arr[],time1;CopyTime(symbol,tf,0,1,Arr);time1=Arr[0];if(CopyTime(symbol,tf,time,time1,Arr)>0){if(ArraySize(Arr)>2)return(ArraySize(Arr)-1);if(time<time1)return(1);else{return(0);}}else{return(-1);}}
double iCloses(string symbol,ENUM_TIMEFRAMES tf,int index){if(index < 0)return(-1);double Arr[];if(CopyClose(symbol,tf, index, 1, Arr)>0){return(Arr[0]);}else{return(-1);}}
double iHighs(string symbol,ENUM_TIMEFRAMES tf,int index){if(index < 0)return(-1);double Arr[];if(CopyHigh(symbol,tf, index, 1, Arr)>0){return(Arr[0]);}else{return(-1);}}
double iLows(string symbol,ENUM_TIMEFRAMES tf,int index){if(index < 0)return(-1);double Arr[];if(CopyLow(symbol,tf, index, 1, Arr)>0){return(Arr[0]);}else{return(-1);}}
double iOpens(string symbol,ENUM_TIMEFRAMES tf,int index){   if(index < 0) return(-1);double Arr[];if(CopyOpen(symbol,tf, index, 1, Arr)>0)     return(Arr[0]);else return(-1);}
datetime iTimes(string symbol,ENUM_TIMEFRAMES tf,int index){if(index < 0) return(-1);datetime Arr[];if(CopyTime(symbol, tf, index, 1, Arr)>0)    return(Arr[0]);else return(-1);}


//+----End of generated script----+//

