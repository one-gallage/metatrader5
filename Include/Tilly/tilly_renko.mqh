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
#property description "tilly_renko"
#property description "© ErangaGallage"
#property strict

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//+------------------------------------------------------------------+
//| enum types                                                       |
//+------------------------------------------------------------------+

enum ENUM_RENKO_TYPE {
   RENKO_TYPE_TICKS, //Ticks
   RENKO_TYPE_PIPS,  //Pips
   RENKO_TYPE_POINTS,//Points
   RENKO_TYPE_R      //R Type (-1 Tick)
};

enum ENUM_RENKO_WINDOW {
   RENKO_CURRENT_WINDOW,   //Current Window
   RENKO_NEW_WINDOW,       //New Window
   RENKO_MINI_CHART        //Mini Chart
};

//+------------------------------------------------------------------+
//| classes                                                          |
//+------------------------------------------------------------------+

class CMySymbol {

private:
   string Name;
   
public:

   CMySymbol( const string Symb = NULL, const string Path = NULL ) {
      this.Name = Symb;
      if (!CMySymbol::SymbolIsExist(this.Name))
         ::CustomSymbolCreate(this.Name, Path, _Symbol); //::CustomSymbolCreate(this.Name, Path);
   }

   static bool SymbolIsExist( const string Symb = NULL ) {
      ::ResetLastError();
      ::SymbolInfoInteger((Symb == NULL) ? _Symbol : Symb, SYMBOL_CUSTOM);
      return(::GetLastError() != ERR_MARKET_UNKNOWN_SYMBOL);
   }

   bool SetProperty( const ENUM_SYMBOL_INFO_DOUBLE Property, double Value ) const {
      return(::CustomSymbolSetDouble(this.Name, Property, Value));
   }

   bool SetProperty( const ENUM_SYMBOL_INFO_INTEGER Property, long Value ) const {
      return(::CustomSymbolSetInteger(this.Name, Property, Value));
   }

   bool SetProperty( const ENUM_SYMBOL_INFO_STRING Property, string Value ) const {
      return(::CustomSymbolSetString(this.Name, Property, Value));
   }

   long GetProperty( const ENUM_SYMBOL_INFO_INTEGER Property ) const {
      return(::SymbolInfoInteger(this.Name, Property));
   }

   double GetProperty( const ENUM_SYMBOL_INFO_DOUBLE Property ) const {
      return(::SymbolInfoDouble(this.Name, Property));
   }

   string GetProperty( const ENUM_SYMBOL_INFO_STRING Property ) const {
      return(::SymbolInfoString(this.Name, Property));
   }

   bool Delete( void ) const {
      return(this.IsCustom() && this.Off() && ::CustomSymbolDelete(this.Name));
   }

#define CLONE(A) this.SetProperty(A, Source.GetProperty(A))

   bool CloneProperties( const string Symb = NULL ) const {
      const CMySymbol Source(Symb);

      return(CMySymbol::SymbolIsExist(Symb) && this.IsCustom() &&
             CLONE(SYMBOL_BASIS) &&
             CLONE(SYMBOL_CURRENCY_BASE) &&
             CLONE(SYMBOL_CURRENCY_MARGIN) &&
             CLONE(SYMBOL_CURRENCY_PROFIT) &&
             CLONE(SYMBOL_DESCRIPTION) &&
             CLONE(SYMBOL_FORMULA) &&
             CLONE(SYMBOL_ISIN) &&
             CLONE(SYMBOL_PAGE) &&

             CLONE(SYMBOL_MARGIN_HEDGED) &&
             CLONE(SYMBOL_MARGIN_INITIAL) &&
             CLONE(SYMBOL_MARGIN_MAINTENANCE) &&
             CLONE(SYMBOL_OPTION_STRIKE) &&
             CLONE(SYMBOL_POINT) &&
             CLONE(SYMBOL_SESSION_PRICE_LIMIT_MAX) &&
             CLONE(SYMBOL_SESSION_PRICE_LIMIT_MIN) &&
             CLONE(SYMBOL_SESSION_PRICE_SETTLEMENT) &&
             CLONE(SYMBOL_SWAP_LONG) &&
             CLONE(SYMBOL_SWAP_SHORT) &&
             CLONE(SYMBOL_TRADE_ACCRUED_INTEREST) &&
             CLONE(SYMBOL_TRADE_CONTRACT_SIZE) &&
             CLONE(SYMBOL_TRADE_FACE_VALUE) &&
             CLONE(SYMBOL_TRADE_LIQUIDITY_RATE) &&
             CLONE(SYMBOL_TRADE_TICK_SIZE) &&
             CLONE(SYMBOL_TRADE_TICK_VALUE) &&
             CLONE(SYMBOL_VOLUME_LIMIT) &&
             CLONE(SYMBOL_VOLUME_MAX) &&
             CLONE(SYMBOL_VOLUME_MIN) &&
             CLONE(SYMBOL_VOLUME_STEP) &&

             CLONE(SYMBOL_BACKGROUND_COLOR) &&
             CLONE(SYMBOL_CHART_MODE) &&
             CLONE(SYMBOL_DIGITS) &&
             CLONE(SYMBOL_EXPIRATION_MODE) &&
             CLONE(SYMBOL_EXPIRATION_TIME) &&
             CLONE(SYMBOL_FILLING_MODE) &&
             CLONE(SYMBOL_MARGIN_HEDGED_USE_LEG) &&
             CLONE(SYMBOL_OPTION_MODE) &&
             CLONE(SYMBOL_OPTION_RIGHT) &&
             CLONE(SYMBOL_ORDER_GTC_MODE) &&
             CLONE(SYMBOL_ORDER_MODE) &&
             CLONE(SYMBOL_SPREAD) &&
             CLONE(SYMBOL_SPREAD_FLOAT) &&
             CLONE(SYMBOL_START_TIME) &&
             CLONE(SYMBOL_SWAP_MODE) &&
             CLONE(SYMBOL_SWAP_ROLLOVER3DAYS) &&
             CLONE(SYMBOL_TICKS_BOOKDEPTH) &&
             CLONE(SYMBOL_TRADE_CALC_MODE) &&
             CLONE(SYMBOL_TRADE_EXEMODE) &&
             CLONE(SYMBOL_TRADE_FREEZE_LEVEL) &&
             CLONE(SYMBOL_TRADE_MODE) &&
             CLONE(SYMBOL_TRADE_STOPS_LEVEL));
   }

#undef CLONE

   int CloneHistory( string Symb = NULL ) const {
      return(::MathMax(this.CloneRates(Symb), this.CloneTicks(Symb)));
   }

   int CloneRates( const MqlRates &Rates[] ) const {
      return(this.IsCustom() ? ::CustomRatesReplace(this.Name, 0, LONG_MAX, Rates) : -1);
   }

   int CloneRates( string Symb = NULL ) const {
      int Res = this.IsCustom() && CMySymbol::SymbolIsExist(Symb) ? 0 : -1;
      if (Res != -1) {
         Symb = (Symb == NULL) ? _Symbol : Symb;
         MqlRates Rates[];
         ::CopyRates(Symb, PERIOD_M1, 0, ::Bars(Symb, PERIOD_M1), Rates);
         Res = this.CloneRates(Rates);
      }
      return(Res);
   }

   int CloneTicks( const MqlTick &Ticks[] ) const {
      return(this.IsCustom() ? ::CustomTicksReplace(this.Name, 0, LONG_MAX, Ticks) : -1);
   }

   int CloneTicks( string Symb = NULL ) const {
      Symb = (Symb == NULL) ? _Symbol : Symb;
      int Res = this.IsCustom() && ::SymbolInfoInteger(Symb, SYMBOL_CUSTOM) ? 0 : -1;
      if (Res != -1) {
         MqlTick Ticks[];
         ::CopyTicksRange(Symb, Ticks, COPY_TICKS_ALL, 0, LONG_MAX);
         Res = this.CloneTicks(Ticks);
      }
      return(Res);
   }

   bool Clone( const string Symb = NULL ) const {
      return(this.CloneProperties(Symb) && (this.CloneHistory(Symb) != -1));
   }

   virtual bool operator =( const string Symb ) const {
      return(this.Clone(Symb));
   }

   bool On( void ) const {
      return(::SymbolSelect(this.Name, true));
   }

   bool Off( void ) const {
      return(::SymbolSelect(this.Name, false));
   }

   bool IsCustom( void ) const {
      return((bool)this.GetProperty(SYMBOL_CUSTOM));
   }

   bool IsExist( void ) const {
      return(CMySymbol::SymbolIsExist(this.Name));
   }
};

class CMyRenkoChart {

private:
   MqlRates rates[],             //Rates buffer
            renko_buffer[];      //Renko buffer
   string   renko_symbol,        //Original symbol
            custom_symbol;       //Custom symbol
   double   renko_size,          //Renko size
            brick_size,          //Brick size
            up_wick,             //Upper wick size
            down_wick;           //Down wick size
   long     tick_volumes,        //Tick Volumes
            volumes;             //Volumes
   bool     show_wicks,          //Show renko wicks
            open_time,           //Save brick open time
            asymetric_reversal;  //Asymetric Reversal
   ENUM_RENKO_TYPE renko_type;

   //Add one to buffer array
   int CMyRenkoChart::AddOne(datetime time = 0) {
      //Resize buffers
      int index = ArrayResize(renko_buffer, ArraySize(renko_buffer) + 1, 100000) - 1;
      if(index <= 0) return 0;
      //Time
      if(time == 0) time = TimeCurrent();
      if(!open_time) time = time - time % 86400;
      if(time <= renko_buffer[index - 1].time)
         renko_buffer[index].time = renko_buffer[index - 1].time + 60;
      else
         renko_buffer[index].time = time;
      //Defaults
      renko_buffer[index].open = renko_buffer[index].high = renko_buffer[index].low = renko_buffer[index].close = renko_buffer[index - 1].close;
      renko_buffer[index].tick_volume = renko_buffer[index].real_volume = 0;
      renko_buffer[index].spread = 0;
      return index;
   }
   
   //Add positive renko bar
   int CMyRenkoChart::CloseUp(double points, datetime time = 0, int spread = 0) {
      int index = ArraySize(renko_buffer) - 1;
      //OHLC
      if(asymetric_reversal) renko_buffer[index].open = renko_buffer[index - 1].close;
      else renko_buffer[index].open = renko_buffer[index - 1].close + points - brick_size;
      renko_buffer[index].high = renko_buffer[index - 1].close + points;
      renko_buffer[index].close = renko_buffer[index - 1].close + points;
      //Wicks
      if(show_wicks) renko_buffer[index].low = down_wick;
      else renko_buffer[index].low = renko_buffer[index].open;
      up_wick = down_wick = renko_buffer[index].close;
      //Volumes
      renko_buffer[index].tick_volume = tick_volumes;
      renko_buffer[index].real_volume = volumes;
      renko_buffer[index].spread = spread;
      tick_volumes = volumes = 0;
      //Add one
      return AddOne(time);
   }
   
   //Add negative renko bar
   int CMyRenkoChart::CloseDown(double points, datetime time = 0, int spread = 0) {
      int index = ArraySize(renko_buffer) - 1;
      //OHLC
      if(asymetric_reversal) renko_buffer[index].open = renko_buffer[index - 1].close;
      else renko_buffer[index].open = renko_buffer[index - 1].close - points + brick_size;
      renko_buffer[index].low = renko_buffer[index - 1].close - points;
      renko_buffer[index].close = renko_buffer[index - 1].close - points;
      //Wicks
      if(show_wicks) renko_buffer[index].high = up_wick;
      else renko_buffer[index].high = renko_buffer[index].open;
      up_wick = down_wick = renko_buffer[index].close;
      //Volumes
      renko_buffer[index].tick_volume = tick_volumes;
      renko_buffer[index].real_volume = volumes;
      renko_buffer[index].spread = spread;
      tick_volumes = volumes = 0;
      //Add one
      return AddOne(time);
   }
   
   //Load price information
   int CMyRenkoChart::LoadPrice(double price, datetime time = 0, long tick_volume = 0, long volume = 0, int spread = 0) {
      static datetime last_time;
      static long last_tick_volume, last_volume;
      //Time
      if(time == 0) time = TimeCurrent();
      //Buffer size
      int size = ArraySize(renko_buffer);
      int index = size - 1;
      //First bricks
      if(size == 0) {
         //1st Buffers
         ArrayResize(renko_buffer, 2, 1000);
         renko_buffer[1].time = time - 60;
         renko_buffer[1].close = renko_buffer[1].high = NormalizeDouble(MathFloor(price / brick_size) * brick_size, _Digits);
         renko_buffer[1].open = renko_buffer[1].low = renko_buffer[1].close - brick_size;
         renko_buffer[1].tick_volume = renko_buffer[1].real_volume = 0;
         renko_buffer[1].spread = 0;
         renko_buffer[0].time = time - 120;
         renko_buffer[0].open = renko_buffer[0].low = renko_buffer[1].open - brick_size;
         renko_buffer[0].high = renko_buffer[0].close = renko_buffer[1].open;
         renko_buffer[0].tick_volume = renko_buffer[0].real_volume = 0;
         renko_buffer[0].spread = 0;
         //Current Buffer
         index = AddOne(time);
      }
      //Time change
      if(time != last_time) {
         last_time = time;
         tick_volumes += last_tick_volume;
         volumes += last_volume;
      }
      //Volume change
      last_tick_volume = tick_volume;
      last_volume = volume;
      //Wicks
      up_wick = MathMax(up_wick, price);
      down_wick = MathMin(down_wick, price);
      if(down_wick <= 0) down_wick = price;
      //Price change
      if(renko_type == RENKO_TYPE_R) {
         //Up
         if(renko_buffer[index - 1].close > renko_buffer[index - 2].close) {
            if(price > renko_buffer[index - 1].close + brick_size) {
               for(; price > renko_buffer[index - 1].close + brick_size;)
                  index = CloseUp(brick_size, time, spread);
            }
            //Reversal
            else if(price < renko_buffer[index - 1].close - brick_size * 2.0) {
               index = CloseDown(brick_size * 2.0, time, spread);
               for(; price < renko_buffer[index - 1].close - brick_size;)
                  index = CloseDown(brick_size, time, spread);
            }
         }
         //Down
         if(renko_buffer[index - 1].close < renko_buffer[index - 2].close) {
            if(price < renko_buffer[index - 1].close - brick_size) {
               for(; price < renko_buffer[index - 1].close - brick_size;)
                  index = CloseDown(brick_size, time, spread);
            }
            //Reversal
            else if(price > renko_buffer[index - 1].close + brick_size * 2.0) {
               index = CloseUp(brick_size * 2.0, time, spread);
               for(; price > renko_buffer[index - 1].close + brick_size;)
                  index = CloseUp(brick_size, time, spread);
            }
         }
      } else {
         //Up
         if(renko_buffer[index - 1].close >= renko_buffer[index - 2].close) {
            if(price >= renko_buffer[index - 1].close + brick_size) {
               for(; price >= renko_buffer[index - 1].close + brick_size;)
                  index = CloseUp(brick_size, time, spread);
            }
            //Reversal
            else if(price <= renko_buffer[index - 1].close - brick_size * 2.0) {
               index = CloseDown(brick_size * 2.0, time, spread);
               for(; price <= renko_buffer[index - 1].close - brick_size;)
                  index = CloseDown(brick_size, time, spread);
            }
         }
         //Down
         if(renko_buffer[index - 1].close <= renko_buffer[index - 2].close) {
            if(price <= renko_buffer[index - 1].close - brick_size) {
               for(; price <= renko_buffer[index - 1].close - brick_size;)
                  index = CloseDown(brick_size, time, spread);
            }
            //Reversal
            else if(price >= renko_buffer[index - 1].close + brick_size * 2.0) {
               index = CloseUp(brick_size * 2.0, time, spread);
               for(; price >= renko_buffer[index - 1].close + brick_size;)
                  index = CloseUp(brick_size, time, spread);
            }
         }
      }
      //Current buffer
      renko_buffer[index].open = renko_buffer[index - 1].close;
      renko_buffer[index].high = up_wick;
      renko_buffer[index].low = down_wick;
      renko_buffer[index].close = price;
      renko_buffer[index].tick_volume = tick_volumes + tick_volume;
      renko_buffer[index].real_volume = volumes + volume;
      renko_buffer[index].spread = spread;
   
      return index + 1;
   }
   
   //Load price rates information
   int CMyRenkoChart::LoadPrice(const MqlRates &price) {
      //Price
      return LoadPrice(price.close, price.time, price.tick_volume, price.real_volume, price.spread);
   }
   
   //Load OHLC price rates information
   int CMyRenkoChart::LoadPriceOHLC(const MqlRates &price) {
      LoadPrice(price.open, price.time, 0, 0, price.spread);
      if(price.close > price.open) {
         LoadPrice(price.low, price.time, 0, 0, price.spread);
         LoadPrice(price.high, price.time, 0, 0, price.spread);
      } else {
         LoadPrice(price.high, price.time, 0, 0, price.spread);
         LoadPrice(price.low, price.time, 0, 0, price.spread);
      }
      return LoadPrice(price.close, price.time, price.tick_volume, price.real_volume, price.spread);
   }   
   
   //Open selectable mini-chart
   void CMyRenkoChart::MiniChartCustomSymbol() {
      ObjectCreate(0, custom_symbol, OBJ_CHART, 0, 0, 0);
      ObjectSetString(0, custom_symbol, OBJPROP_SYMBOL, custom_symbol);
      ObjectSetInteger(0, custom_symbol, OBJPROP_XDISTANCE, 0);
      ObjectSetInteger(0, custom_symbol, OBJPROP_YDISTANCE, 200);
      ObjectSetInteger(0, custom_symbol, OBJPROP_XSIZE, 300);
      ObjectSetInteger(0, custom_symbol, OBJPROP_YSIZE, 200);
      ObjectSetInteger(0, custom_symbol, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, custom_symbol, OBJPROP_PERIOD, PERIOD_M1);
      ObjectSetInteger(0, custom_symbol, OBJPROP_CHART_SCALE, 3);
      ObjectSetInteger(0, custom_symbol, OBJPROP_DATE_SCALE, false);
      ObjectSetInteger(0, custom_symbol, OBJPROP_BACK, false);
      ObjectSetInteger(0, custom_symbol, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, custom_symbol, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, custom_symbol, OBJPROP_HIDDEN, true);
   }   

public:

   CMyRenkoChart::CMyRenkoChart() {
      return;
   }
   
   CMyRenkoChart::~CMyRenkoChart() {
      ArrayFree(rates);
      ArrayFree(renko_buffer);
      SymbolSelect(custom_symbol, false);
      CustomSymbolDelete(custom_symbol);
   }
   
   //Setup
   bool CMyRenkoChart::Setup(string symbol, ENUM_RENKO_TYPE type = RENKO_TYPE_TICKS, double size = 20, bool wicks = true, bool times = true, bool asymetric = false) {
   //Check Symbol
      if(symbol == "" || symbol == NULL) {
         Print("Line:", __LINE__, " - Invalid symbol selected.");
         return(false);
      }
      if(SymbolInfoInteger(symbol, SYMBOL_CUSTOM)) {
         if (MQL5InfoInteger(MQL5_TESTER) || MQL5InfoInteger(MQL5_DEBUG) || MQL5InfoInteger(MQL5_DEBUGGING) || MQL5InfoInteger(MQL5_OPTIMIZATION) || MQL5InfoInteger(MQL5_VISUAL_MODE)) {
            //Print("Line:",__LINE__," - symbol selected is custom.");
         } else {
            Print("Line:", __LINE__, " - Custom Symbol selected. Please Change for the original symbol.");
            return(false);
         }
      }
   //Select Symbol
      if(SymbolSelect(symbol, true) == false) {
         Print("Line:", __LINE__, " - Symbol selection error.");
         return(false);
      }
   //Renko setup
      renko_symbol = symbol;
      renko_type = type;
      renko_size = size;
      show_wicks = wicks;
      open_time = times;
      asymetric_reversal = asymetric;
   //Renko brick size
      int digits = (int) SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double points = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double pip_size = (digits == 5 || digits == 3) ? points * 10 : points;
      if(renko_type == RENKO_TYPE_TICKS) brick_size = renko_size * tick_size;
      else if(renko_type == RENKO_TYPE_PIPS) brick_size = renko_size * pip_size;
      else if(renko_type == RENKO_TYPE_R) brick_size = renko_size * tick_size - tick_size;
      else brick_size = renko_size;
   //Invalid brick size
      if(brick_size <= 0) {
         Print("Line:", __LINE__, " - Invalid brick size. Value of ", brick_size, " selected.");
         return(false);
      }
   //Minimum brick size
      if(brick_size < tick_size) {
         brick_size = tick_size;
         Print("Line:", __LINE__, " - Invalid brick size. Minimum value of ", brick_size, " will be used.");
      }
      brick_size = NormalizeDouble(brick_size, digits);
   //Success
      return(true);
   }
   
   //Load history
   int CMyRenkoChart::LoadFrom(datetime start = 0) {
      ResetLastError();
      int total, size = ArraySize(renko_buffer);
      //Copy rates
      if(size == 0)
         total = CopyRates(renko_symbol, PERIOD_M1, 0, 1000000, rates);
      else
         total = CopyRates(renko_symbol, PERIOD_M1, start - 59, TimeCurrent(), rates);
      //Return
      if(total <= 0)
         return 0;
      else if(total == 1)
         size = LoadPrice(rates[0]);
      else for(int i = 0; i < total; i++)
            size = LoadPriceOHLC(rates[i]);
      return size;
   }
   
   //Update Rates
   int CMyRenkoChart::UpdateRates() {
      static datetime last_update = 0;
      int size = LoadFrom(last_update);
      last_update = TimeCurrent();
      return size;
   }
   
   //Clear Rates
   int CMyRenkoChart::ClearRates() {
      return ArrayResize(renko_buffer, 0);
   }
   
   //Get values
   double CMyRenkoChart::GetValue(int buffer = 0, int index = -1) {
      index = (index < 0) ? ArraySize(renko_buffer) - 1 : index;
      if(index < 0) return EMPTY_VALUE;
      switch(buffer) {
      case  0:
         return (double) renko_buffer[index].time;
         break; //Time
      case  1:
         return          renko_buffer[index].open;
         break; //Open
      case  2:
         return          renko_buffer[index].high;
         break; //High
      case  3:
         return          renko_buffer[index].low;
         break; //Low
      case  4:
         return          renko_buffer[index].close;
         break; //Close
      case  5:
         return (double) renko_buffer[index].tick_volume;
         break; //Tick volume
      case  6:
         return (double) renko_buffer[index].real_volume;
         break; //Volume
      case  7:
         return (double) renko_buffer[index].spread;
         break; //Spread
      case  8:
         return (double) renko_buffer[index].open < renko_buffer[index].close ? 1 : renko_buffer[index].open == renko_buffer[index].close ? 0 : -1;
         break; //Direction
      default:
         return EMPTY_VALUE;
         break;
      }
   }
   
   //Get values as Series
   double CMyRenkoChart::GetValueAsSeries(int buffer = 0, int index = -1) {
      index = ArraySize(renko_buffer) - index;
      index = (index <= 0) ? ArraySize(renko_buffer) - 1 : index - 1;
      if(index < 0) return EMPTY_VALUE;
      switch(buffer) {
      case  0:
         return (double) renko_buffer[index].time;
         break; //Time
      case  1:
         return          renko_buffer[index].open;
         break; //Open
      case  2:
         return          renko_buffer[index].high;
         break; //High
      case  3:
         return          renko_buffer[index].low;
         break; //Low
      case  4:
         return          renko_buffer[index].close;
         break; //Close
      case  5:
         return (double) renko_buffer[index].tick_volume;
         break; //Tick volume
      case  6:
         return (double) renko_buffer[index].real_volume;
         break; //Volume
      case  7:
         return (double) renko_buffer[index].spread;
         break; //Spread
      case  8:
         return (double) renko_buffer[index].open < renko_buffer[index].close ? 1 : renko_buffer[index].open == renko_buffer[index].close ? 0 : -1;
         break; //Direction
      default:
         return EMPTY_VALUE;
         break;
      }
   }
   
   //+------------------------------------------------------------------+
   //| custom symbol methods                                            |
   //+------------------------------------------------------------------+
   //Return custom symbol name
   string CMyRenkoChart::GetSymbolName() {
      return custom_symbol;
   }
   
   //Create renko custom symbol
   bool CMyRenkoChart::CreateCustomSymbol(string name = "") {
      ::ResetLastError();
      custom_symbol = name;
      //Create symbol
      const CMySymbol Symb(custom_symbol, "Renko_Charts");
      if(!Symb.CloneProperties(renko_symbol)) {
         Print("Custom Symbol Clone Properties error. Error: ", ::GetLastError());
         return false;
      }
      if(!Symb.On()) {
         Print("Custom Symbol On error. Error: ", ::GetLastError());
         return false;
      }
      //Select Custom Symbol
      if(SymbolSelect(custom_symbol, true) == false) {
         //Select Custom Symbol
         Print("Custom Symbol select error. Error: ", ::GetLastError());
         return false;
      }
      return true;
   }
   
   //Check custom symbol
   bool CMyRenkoChart::CheckCustomSymbol() {
      if(custom_symbol == "" || custom_symbol == NULL)
         return(false);
      return((bool)SymbolInfoInteger(custom_symbol, SYMBOL_CUSTOM));
   }
   
   //Clear custom symbol rates
   int CMyRenkoChart::ClearCustomSymbol() {
      if(!CheckCustomSymbol()) return 0;
      return CustomRatesDelete(custom_symbol, D'1970.01.01 00:00', D'3000.12.31 00:00');
   }
   
   //Update custom symbol rates
   int CMyRenkoChart::ReplaceCustomSymbol() {
      if(!CheckCustomSymbol()) return 0;
      return CustomRatesUpdate(custom_symbol, renko_buffer);
   }
   
   //Open custom symbol window
   void CMyRenkoChart::OpenCustomSymbol() {
      if(!CheckCustomSymbol()) return;
      static long chart_id = -1;
      ChartClose(chart_id);
      chart_id = ChartOpen(custom_symbol, PERIOD_M1);
      //Print("ChartId=", chart_id);
      ChartSetInteger(chart_id, CHART_MODE, CHART_CANDLES);
      ChartSetInteger(chart_id, CHART_SHOW_PERIOD_SEP, 0, true);
      ChartSetInteger(chart_id, CHART_SHOW_GRID, 0, false);   
   }
   
   //Set chart current symbol
   void CMyRenkoChart::SetCustomSymbol(long chart_id = 0) {
      if(!CheckCustomSymbol()) return;
      ChartSetSymbolPeriod(chart_id, custom_symbol, PERIOD_M1);
      ChartSetInteger(chart_id, CHART_MODE, CHART_CANDLES);
      ChartSetInteger(chart_id, CHART_SHOW_PERIOD_SEP, 0, true);
      ChartSetInteger(chart_id, CHART_SHOW_GRID, 0, false);
   }
   
   //update custom rates
   int CMyRenkoChart::UpdateCustomRates(int count = 0) {
      if(!CheckCustomSymbol()) return 0;
      //Update buffer
      MqlRates update_buffer[];
      ArraySetAsSeries(update_buffer, true);
      //Copy last buffer
      if(count <= 0) count = WHOLE_ARRAY;
      int copied = ArrayCopy(update_buffer, renko_buffer, 0, 0, count);
      if(copied <= 0) return 0;
      //Update Custom Rates
      copied = CustomRatesUpdate(custom_symbol, update_buffer);
      return copied;
   }
   
   //Update custom tick
   int CMyRenkoChart::UpdateCustomTick() {
      if(!CheckCustomSymbol()) return 0;
      //Update buffer
      static long last_tick = 0;
      MqlTick update_buffer[];
      ArraySetAsSeries(update_buffer, true);
      //Copy last buffer
      int copied = CopyTicks(renko_symbol, update_buffer, COPY_TICKS_ALL, 0, 1);
      if(copied <= 0) return 0;
      if(last_tick != update_buffer[0].time_msc)
         last_tick = update_buffer[0].time_msc;
      else
         return 0;
      //Update current tick
      update_buffer[0].time_msc = 1000 * (long) GetValue(0);
      if(update_buffer[0].bid == 0)update_buffer[0].bid = GetValue(4);
      if(update_buffer[0].ask == 0)update_buffer[0].ask = GetValue(4);
      if(update_buffer[0].last == 0)update_buffer[0].last = GetValue(4);
      //Update Custom Tick
      copied = CustomTicksAdd(custom_symbol, update_buffer);
      return copied;
   }
   
   //+------------------------------------------------------------------+
   //| event methods                                                    |
   //+------------------------------------------------------------------+
   //Create Renko Chart/Events
   void CMyRenkoChart::Start(ENUM_RENKO_WINDOW window = RENKO_NEW_WINDOW, int event_timer = 0, bool event_book = false) {
      //Open/Set Custom Symbol
      Print("Starting Custom Symbol: ", custom_symbol);
      if(window == RENKO_CURRENT_WINDOW) {
         SetCustomSymbol();
      } else if(window == RENKO_NEW_WINDOW) {
         Comment("Updating Custom Symbol: ", custom_symbol);
         OpenCustomSymbol();
      } else if(window == RENKO_MINI_CHART) {
         MiniChartCustomSymbol();
      }
      //Events
      if(event_timer > 0)
         EventSetMillisecondTimer(event_timer);
      if(event_book)
         MarketBookAdd(renko_symbol);
   }
   
   //Release OnBookEvent
   void CMyRenkoChart::Stop() {
      Print("Stopping Custom Symbol: ", custom_symbol);
      Comment("");
      EventKillTimer();
      SymbolSelect(custom_symbol, false);
      MarketBookRelease(renko_symbol);
      MarketBookRelease(custom_symbol);
      CustomSymbolDelete(custom_symbol);
      ClearCustomSymbol();
   }
   
   //Refresh rates on OnTick and OnBookEvent events
   void CMyRenkoChart::Refresh() {
      static datetime last_update;
      static int last_size;
      //Update custom symbol
      int size = UpdateRates();
      if(last_size == 0)
         ReplaceCustomSymbol();
      if(last_size != size)
         if(TimeCurrent() - last_update > 60)
            ReplaceCustomSymbol();
         else
            UpdateCustomRates(last_size - size);
      //Update custom tick
      UpdateCustomTick();
      last_update = TimeCurrent();
      last_size = size;
   }

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
