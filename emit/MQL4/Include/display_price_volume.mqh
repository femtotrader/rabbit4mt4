//+------------------------------------------------------------------+
//|                                         display_price_volume.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property strict

double PipPoint(string symbol) {
    int digits = (int) MarketInfo(symbol, MODE_DIGITS);
    double pippoint = 0.0;

    if (digits == 2 || digits == 3) {
        pippoint = 0.01;
    } else if (digits == 4 || digits == 5) {
        pippoint = 0.0001;
    } else if (digits == 0 || digits == 1) {
        pippoint = 1.0;
    } else {
        //Comment("Error PipPoint function");
        Print("Error PipPoint function");
    }
    return(pippoint);
}

int VolumeDigits(string symbol) {
   int digits_volume = (int) -log10(MathMin(MarketInfo(symbol, MODE_LOTSTEP), MarketInfo(symbol, MODE_MINLOT)));
   if (digits_volume>=0) {
      return(digits_volume);
   } else {
      return(0);
   }
}

double spread(double bid, double ask) {
   return(ask-bid);
}

double spread_percent(double bid, double ask) {
   return(100.0*(ask-bid)/ask);
}


string PriceToString(double price, string symbol) {
   int digits_price = (int) MarketInfo(symbol, MODE_DIGITS);
   return(DoubleToString(price, digits_price));
}

string VolumeToString(double volume, string symbol) {
   return(DoubleToString(volume, VolumeDigits(symbol)));
}


string PriceDiffToPipsString(double price_diff, string symbol, string unit=" pips") {
   double pippoint = PipPoint(symbol);
   return(DoubleToString(price_diff/pippoint, 1) + unit);
}

string TickerToString(double bid, double ask, string symbol, string sep = "/") {
   return(PriceToString(bid, symbol) + sep + PriceToString(ask, symbol));
}

string TickerWithSpreadToString(double bid, double ask, string symbol, string sep = "/") {
   return(PriceToString(bid, symbol) + sep + PriceToString(ask, symbol) + " (" + PriceDiffToPipsString(ask-bid, symbol) + ")");
}