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
string StoreHL_Type[8000];
int iStoreHL=0;
double LastHTemp;
double LastLTemp; 

double Temp[8000];
int iTemp=0;

int iHLs=0;
double HLs[8000];
string HLs_Type[8000];

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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
 
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
   iStoreHL=0;
   //Find the highest ofthe last 30 candles
   int HighestCandle=  iHighest(_Symbol,_Period,MODE_HIGH,4,posVelaStart);
   // Find the lowest of the last 30 candles
   int LowestCandle = iLowest(_Symbol,_Period,MODE_LOW,4,posVelaEnd);
   
   drawrectangle(posVelaStart,High[HighestCandle],posVelaEnd,Low[LowestCandle]  ,"b");
   
   iTemp=0;
   //------------------------------------------------------------------
   //INICIAR BUSQUEDA
   for (int i=Bars-2;  i>1; i--){
   
      //DETECCION LIQUIDEZ ALTA---------------------------------------------------------
      if (ExisteLiquidezHigh(i)==true){
         foundH++;foundL=0;
         
         //Almacenar Todo HL detected
         StoreHL[iStoreHL]=iHigh(_Symbol,_Period,i);//Almacenar el alto
         StoreHL_Type[iStoreHL]="H";//Registrar el tipo
         
         if (iTemp<2){//Esta Vacio TEMP?
            LecturaString("",120,70,"x1",  StringConcatenate("Temp-Vacio"));  
           
           if (iStoreHL>2){//para filtrar solo al inicio del scaneo
         
              if (StoreHL_Type[iStoreHL-1]==StoreHL_Type[iStoreHL-2]){ //ACTUAL==OLD?
                 mostrarlectura();
                 LecturaString("",120,90,"x11",  StringConcatenate("H-H igual"));  
                  Temp[0]=StoreHL[iStoreHL-1];
                  Temp[1]=StoreHL[iStoreHL-2];
                  iTemp=2;
                  
              }   
           }         
         }
         
         else{
           LecturaString("",120,70,"x1",  StringConcatenate("Temp-Lleno"));
           LecturaString("",120,90,"x11",  StringConcatenate("H-H difer.")); 
           
           if (StoreHL_Type[iStoreHL-1]==StoreHL_Type[iStoreHL-2]){ //ACTUAL==OLD?
                  Temp[iTemp]=StoreHL[iStoreHL-1]; 
                  iTemp++;
           } 
           //Cuando ya no es igual al anterior
           else{
                  iTemp=0;
                  resetTemp();
           }  
           
         }
         
         //Dibujar Arrows
         drawH(i); //Dibujar High
         drawHorizontalLine(StoreHL[iStoreHL],i,"dh1","nameprice1");//mostrar ultimo precio 
          
         iStoreHL=iStoreHL+1;
         //Mostrar Lectura
         mostrarlectura();
      }
      //**********************************************************************************
      //*********************************************************************************
      //DETECCION LIQUIDEZ BAJA
      if (ExisteLiquidezLow(i)==true){
         foundL++;foundH=0;
         
         //Almacenar Todo HL detected
         StoreHL[iStoreHL]=iLow(_Symbol,_Period,i);
         StoreHL_Type[iStoreHL]="L";
         
         //Dibujar Arrows
         drawL(i);
         drawHorizontalLine(StoreHL[iStoreHL],i,"dh2","nameprice2");
      
         iStoreHL=iStoreHL+1;   
         //Mostrar Lectura 
         mostrarlectura();          
      }          
   }
   //-----------------------------------------------FIN BUSQUEDAD
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
void drawHorizontalLine(double price,int posvela,string name,string nameprice){

     
     ObjectMove(name,0,iTime(Symbol(),_Period,0),price);
     ObjectCreate(name,OBJ_HLINE,0,0,price);
     ObjectSet(name,OBJPROP_COLOR,clrAqua);
     ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet(name,OBJPROP_WIDTH,2);
     ObjectSet(name,OBJPROP_BACK,TRUE);
       
     ObjectCreate (nameprice, OBJ_TEXT,0,0,0);
     ObjectSetText(nameprice, DoubleToStr(price,5),8,"Arial", clrAliceBlue);
     ObjectMove(nameprice,0,iTime(Symbol(),_Period,0),price);
 
 
}

bool ExisteLiquidezHigh(int i){
   bool result=false;
   if((High[i]>High[i+1])&&(High[i]>High[i-1])){
      result=true;
   }   
   return result;
}
bool ExisteLiquidezLow(int i){
   bool result=false;
   if(  ((Low[i]<Low[i+1])&&(Low[i]<Low[i-1])) || ( ((Low[i+1]<Low[i+2])&&(Low[i]==Low[i+1])&&(Low[i]<Low[i-1]))   )){
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
void LecturaPrecio(double precio_sto,int cx, int cy, string name,string name2,int digitos){

   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet(name,OBJPROP_XDISTANCE,cx);
   ObjectSet(name,OBJPROP_YDISTANCE,cy); 
   ObjectSetText(name,name2 +DoubleToStr(precio_sto,digitos),10,"Arial",clrAzure);

}
void LecturaString(string precio_sto,int cx, int cy, string name,string name2){

   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet(name,OBJPROP_XDISTANCE,cx);
   ObjectSet(name,OBJPROP_YDISTANCE,cy);
   ObjectSetText(name,name2 +precio_sto,10,"Arial",clrAzure);

}

void mostrarlectura(){
   LecturaString(0,120,10,"H7",  StringConcatenate("HL_ALL")); 
   if(iStoreHL>0){
               LecturaPrecio(iStoreHL,5,10,"px1",  StringConcatenate("iStoreHL: "),0);  
               LecturaPrecio(StoreHL[iStoreHL-1],5,30,"p1",  StringConcatenate("Stored-1: "),5);  
       
               LecturaString(StoreHL_Type[iStoreHL-1],120,30,"p2",  StringConcatenate("Type-1: "));   
               LecturaPrecio(foundH,5,70,"p3",  StringConcatenate("Found-H: "),0);  
               LecturaPrecio(foundL,5,90,"p4",  StringConcatenate("Found-L: "),0);  
               if (iStoreHL>1){
                 LecturaString(StoreHL_Type[iStoreHL-2],120,50,"p5",  StringConcatenate("OldType-2: ")); 
                 LecturaPrecio(StoreHL[iStoreHL-2],5,50,"p6",  StringConcatenate("Stored-2: "),5); 
                } 
            }
   if(iHLs>0){
          LecturaPrecio(HLs[iHLs-1],250,30,"h2",  StringConcatenate("HLs-1: "),5); 
          LecturaString(HLs_Type[iHLs-1],370,30,"H4",  StringConcatenate("Type-1: ")); 
          
          LecturaPrecio(iHLs,250,10,"hl",  StringConcatenate("iHLs: "),0);   
          LecturaString(0,370,10,"H6",  StringConcatenate("FILTRED")); //text  
        
   
             if (iHLs>1){
              LecturaPrecio(HLs[iHLs-2],250,50,"h3",  StringConcatenate("HLs-2: "),5);
              LecturaString(HLs_Type[iHLs-2],370,50,"H5",  StringConcatenate("OldType-2: "));  
             } 
             
             
   }   
                LecturaPrecio(Temp[0],5,120,"T0",  StringConcatenate("Temp[0]:"),5);        
                LecturaPrecio(Temp[1],5,140,"T1",  StringConcatenate("Temp[1]:"),5);  
                LecturaPrecio(Temp[2],5,160,"T2",  StringConcatenate("Temp[2]:"),5);  
                LecturaPrecio(Temp[3],5,180,"T3",  StringConcatenate("Temp[3]:"),5);  
                LecturaPrecio(Temp[4],5,200,"T4",  StringConcatenate("Temp[4]:"),5);   
                 LecturaPrecio(iTemp,5,220,"T5",  StringConcatenate("iTemp:"),0); 
             
      
}

void resetTemp(){
   for (int i=0;i<7900;i++){
         Temp[i]=0.0;
   }
}