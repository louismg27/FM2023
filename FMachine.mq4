//+------------------------------------------------------------------+
//|                                                   textmoving.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int foundL;
int foundH;
double StoreHL[8000];
int index=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
 
//---
   //---
   ChartSetInteger(0,CHART_SHOW_GRID,false);
ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,Red);
ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,Lime);
ChartSetInteger(0,CHART_COLOR_CHART_DOWN,Red);
ChartSetInteger(0,CHART_COLOR_CHART_UP,Lime);
ChartSetInteger(0,CHART_MODE, CHART_CANDLES);
ChartSetInteger(0,CHART_COLOR_BACKGROUND, Black);
              
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  LecturaPrecio(index,5,10,"p1",  StringConcatenate("index: "));  
  LecturaPrecio(StoreHL[0],5,30,"p2",  StringConcatenate("Storehl: "));  
  LecturaPrecio(StoreHL[1],5,50,"p3",  StringConcatenate("Storehl: "));  
  if(index>0){
    LecturaPrecio(StoreHL[index-1],5,70,"p4",  StringConcatenate("Storehl: "));  
  }
//---
/*
ObjectCreate ("MovingText", OBJ_TEXT,0,0,0);
ObjectSetText("MovingText", "D1-Main"+DoubleToStr(Low[0],Digits),8,"Arial",Red);
ObjectMove("MovingText",0,Time[0],1.038);
*/

   //********************************************************************
   //Dibujar rectangulo****************************************************
   //*********************************************************************
   double posVelaStart= 5;
   double posVelaEnd= 10;
   index=0;
   //Find the highest ofthe last 30 candles
   int HighestCandle=  iHighest(_Symbol,_Period,MODE_HIGH,4,posVelaStart);
   // Find the lowest of the last 30 candles
   int LowestCandle = iLowest(_Symbol,_Period,MODE_LOW,4,posVelaEnd);
   
   drawrectangle(posVelaStart,High[HighestCandle],posVelaEnd,Low[LowestCandle]  ,"b");

   for (int i=Bars-2;  i>1; i--){
      //DETECCION LIQUIDEZ ALTA
      if (liquidezHigh(i)==true){
      StoreHL[index]=iHigh(_Symbol,_Period,i);
       drawHorizontalLine(StoreHL[index],i);
       drawH(i);
      // foundH=1;
     //  foundL=0;
      index=index+1;
      }
      //DETECCION LIQUIDEZ BAJA
      if (liquidezLow(i)==true){
      StoreHL[index]=iLow(_Symbol,_Period,i);
      drawHorizontalLine(StoreHL[index],i);
        drawL(i);
       //  foundL=1;
       //  foundH=0;  
      index=index+1;                 
      }          
   }
  }
//+------------------------------------------------------------------+

void drawrectangle(int posVelaStart,double pricestart, int postVelaEnd, double pricend,string name){
  string lineName = "Rectangle"+name;
   ObjectDelete(lineName); 
  ObjectCreate(lineName,OBJ_RECTANGLE,0,Time[posVelaStart],pricestart,Time[postVelaEnd],pricend);
  ObjectSet(lineName,OBJPROP_COLOR,"128,128,128");

}

void drawarrow(int postvela,int code,color col,double highpostvela){
   datetime time1=iTime(0,0,postvela);   
 
   ObjectCreate(_Symbol,"MyObject"+postvela,OBJ_ARROW,0,time1,highpostvela);
   ObjectSetInteger(0,"MyObject"+postvela,OBJPROP_ARROWCODE,code);
   ObjectSetInteger(0,"MyObject"+postvela,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,"MyObject"+postvela,OBJPROP_COLOR,col);
   ObjectMove(_Symbol,"MyObject"+postvela,0,time1,highpostvela);
}

void drawtext(string texto, color clx,int posvela,double precio){
ObjectCreate ("MovingText"+posvela, OBJ_TEXT,0,0,0);
ObjectSetText("MovingText"+posvela, texto,8,"Arial", clx);
 ObjectMove("MovingText"+posvela,0,Time[posvela],precio);

}
void drawHorizontalLine(double price,int posvela){

    string name="level";
     ObjectMove(name,0,iTime(Symbol(),_Period,0),price);
     ObjectCreate(name,OBJ_HLINE,0,0,price);
     ObjectSet(name,OBJPROP_COLOR,clrAqua);
     ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet(name,OBJPROP_WIDTH,2);
     ObjectSet(name,OBJPROP_BACK,TRUE);
     
     string nameprice ="Mprice";
   
     ObjectCreate (nameprice, OBJ_TEXT,0,0,0);
     ObjectSetText(nameprice, DoubleToStr(price,5),8,"Arial", clrAliceBlue);
     ObjectMove(nameprice,0,iTime(Symbol(),_Period,0),price);
 
 
}

bool liquidezHigh(int i){
   bool result=false;
   if((High[i]>High[i+1])&&(High[i]>High[i-1])){
      result=true;
   }   
   return result;
}
bool liquidezLow(int i){
   bool result=false;
   if((Low[i]<Low[i+1])&&(Low[i]<Low[i-1])){
      result=true;
   }   
   return result;
}

void drawL(int i){
   drawarrow(i,174,clrGold,Low[i]);
   drawtext("L", clrGreen,i,Low[i]);
}
void drawH(int i){
   drawarrow(i,108,clrAliceBlue,High[i]);
   drawtext("H", clrRed,i,High[i]);
}
void LecturaPrecio(double precio_sto,int cx, int cy, string name,string name2){

   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet(name,OBJPROP_XDISTANCE,cx);
   ObjectSet(name,OBJPROP_YDISTANCE,cy);
   ObjectSetText(name,name2 +DoubleToStr(precio_sto,5),10,"Arial",Yellow);

}

