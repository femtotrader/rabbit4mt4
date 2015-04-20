//+------------------------------------------------------------------+
//|                                         display_price_volume.mqh |
//|                                    Copyright © 2014, FemtoTrader |
//|                       https://sites.google.com/site/femtotrader/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, FemtoTrader"
#property link      "https://sites.google.com/site/femtotrader/"
#property version   "1.00"

double PipPoint(string symbol) {
    int digits = (int) SymbolInfoInteger(symbol, SYMBOL_DIGITS);
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


int PipDigits(string symbol) {
    int digits = (int) SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    int pipdigit;

    if (digits == 2 || digits == 4) {
        pipdigit = 0;
    } else if (digits == 3 || digits == 5) {
        pipdigit = 1;
    } else {
        //Comment("Error PipPoint function");
        Print("Error PipPoint function");
        pipdigit = 0;
    }
    return(pipdigit);
}