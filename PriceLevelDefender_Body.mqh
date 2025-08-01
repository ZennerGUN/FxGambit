//+------------------------------------------------------------------+
//|                                      PriceLevelDefender_Body.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

bool     DirFlipped = true;
bool     SpreadBreached = false;
bool     ExitNOW = false;
double   static SLots=-1;
int      static DeInitReson=0;

bool CheckActivationFirstTime = false;
bool PenetrationON = false;


void IsTimeCurrent()
{

   // Changed 3/15/2022 - Use to be CheckActivation   
   if(DelayedTimeActivation && (StrToTime(_ActivateTimeStr) < TimeCurrent()))
   {
            //int dYear   =  TimeYear(StrToTime(_ActivateTimeStr));
            //int dMonth  =  TimeMonth(StrToTime(_ActivateTimeStr));
            //int dDay    =  TimeDay(StrToTime(_ActivateTimeStr));
            int dHour   =  TimeHour(StrToTime(_ActivateTimeStr));
            int dMinute =  TimeMinute(StrToTime(_ActivateTimeStr));
            //int dSeconds=  TimeSeconds(ActivateTime);
            
            
            int cYear   =  TimeYear(TimeCurrent());
            int cMonth  =  TimeMonth(TimeCurrent());
            int cDay    =  TimeDay(TimeCurrent());
            //int cHour   =  TimeHour(TimeCurrent());
            //int cMinute =  TimeMinute(TimeCurrent());
            
            string newActivateTimeStr = "";
            //datetime newActiveTime = 0;
   
            newActivateTimeStr = IntegerToString(cYear)  + "." +
                                 IntegerToString(cMonth) + "." +  
                                 IntegerToString(cDay)   + " " +
                                 IntegerToString(dHour)  + ":" + 
                                 IntegerToString(dMinute);

            _ActivateTimeStr = newActivateTimeStr;
            //newActiveTime = StrToTime(newActivateTimeStr);
            //ActivateTime = StrToTime(newActivateTimeStr);
            // 07222025 Print("_ActivateTimeStr: " + _ActivateTimeStr);
            
            // Make sure that if you are launching Bot AFTER ActivationTime the day of the launch - you DON'T CHECK for bool CheckActivation as it will cause problems... [28.01.2022]
            if(StrToTime(newActivateTimeStr) < TimeCurrent())
            {
               CheckActivationFirstTime = true;
               
               //// 07222025 Print(">>> Bot launched AFTER ActivationTime while CheckActivation is " + IntegerToString(CheckActivation)  +"!!!");
               // 07222025 Print(">>> Bot launched AFTER ActivationTime while CheckActivation is " + ((_CheckActivation == true) ? "ON" : "OFF") +"!!!");
               // 07222025 Print("Corrections?");
               
               if(_CheckActivation)
               {
                  _CheckActivation = false;
                  // 07222025 Print(">>> Corrected CheckActivation:" + ((_CheckActivation == true) ? "ON" : "OFF") +"!!!");
               }
            }
            else
            {
               //// 07222025 Print(">>> Bot launched BEFORE ActivationTime while CheckActivation is " + IntegerToString(CheckActivation)  +"!!!");
               // 07222025 Print(">>> Bot launched BEFORE ActivationTime while CheckActivation is " + ((_CheckActivation == true) ? "ON" : "OFF") +"!!!");
               
               if(!_CheckActivation)
               {
                  _CheckActivation = true;
                  // 07222025 Print(">>> Corrected CheckActivation:" + ((_CheckActivation == true) ? "ON" : "OFF") +"!!!");
               }
            }
            
   }
         
         
         // Changed 3/15/2022
         if(DelayedTimeDeActivation && (StrToTime(_DeActivateTimeStr) < TimeCurrent()))
         {
            //dYear   =  TimeYear(DeActivateTime);
            //dMonth  =  TimeMonth(DeActivateTime);
            //dDay    =  TimeDay(DeActivateTime);
            int dHour   =  TimeHour(StrToTime(_DeActivateTimeStr));
            int dMinute =  TimeMinute(StrToTime(_DeActivateTimeStr));
            
            
            int cYear   =  TimeYear(TimeCurrent());
            int cMonth  =  TimeMonth(TimeCurrent());
            int cDay    =  TimeDay(TimeCurrent());
            //int cHour   =  TimeHour(TimeCurrent());
            //int cMinute =  TimeMinute(TimeCurrent());
            //int cSeconds=  TimeSeconds(TimeCurrent());
            
            string newDeActivateTimeStr = IntegerToString(cYear)  + "." + 
                                          IntegerToString(cMonth) + "." + 
                                          IntegerToString(cDay)   + " " +
                                          IntegerToString(dHour)  + ":" +
                                          IntegerToString(dMinute);

            _DeActivateTimeStr   =  newDeActivateTimeStr;
            //datetime newDeActivateTime = StrToTime(newDeActivateTimeStr);
            //DeActivateTime = StrToTime(newDeActivateTimeStr);
            // 07222025 Print("_DeActivateTimeStr: " + _DeActivateTimeStr);
            
         }
        
}


//  =====================================================================================================================================


void SaveOriginalSetupVals()
{
   OriginalStopLossPips          =  StopLossPips;
   BeforeLastStopLossPips        =  StopLossPips;
   LastStopLossPips              =  StopLossPips;


   OriginalTakeProfitPips        =  TakeProfitPips;
   OriginaldRiskRewardTPRatio    =  dRiskRewardTPRatio;

   OriginalPriceTarget           =  PriceTargetLevel;
   OriginalExecCommand           =  ExecCommand;

   OriginalTrailingTriggerPips   =  TrailingTriggerPips;
   OriginaldRiskRewardTTRatio    =  dRiskRewardTTRatio;

   OriginalTrailingTailPips      =  TrailingTailPips;
   OriginaldRiskRewardTSRatio    =  dRiskRewardTSRatio;

   //// 07222025 Print("INSIDE SaveOriginalSetupVals:");
   //// 07222025 Print("OriginalStopLossPips: " + OriginalStopLossPips);
   //// 07222025 Print("BeforeLastStopLossPips: " + BeforeLastStopLossPips);
   //// 07222025 Print("LastStopLossPips " + LastStopLossPips);
   //// 07222025 Print("OriginalTakeProfitPips " + OriginalTakeProfitPips);
   //// 07222025 Print("OriginaldRiskRewardTPRatio " + OriginaldRiskRewardTPRatio);
   //// 07222025 Print("OriginalPriceTarget " + OriginalPriceTarget);
   //// 07222025 Print("OriginalExecCommand " + OriginalExecCommand);
   //// 07222025 Print("OriginalTrailingTriggerPips " + OriginalTrailingTriggerPips);
   //// 07222025 Print("OriginaldRiskRewardTTRatio " + OriginaldRiskRewardTTRatio);
   //// 07222025 Print("OriginalTrailingTailPips " + OriginalTrailingTailPips);
   //// 07222025 Print("OriginaldRiskRewardTSRatio " + OriginaldRiskRewardTSRatio);

//OriginalLots            = Lots;

}

uint uFirstTick= 0;
uint uLastTick = 0;
bool MyOnTick=false;
//bool bMyOnTick = false;


//  ===================================================================

#ifdef   _TIMER_ENABLED_
void OnTimer()
  {
//EventKillTimer();
   if(OnHold)
      return;

   uFirstTick=GetTickCount();
//Sleep(3000);
//   int uDiff = (uFirstTick - uLastTick);
//
//   if( uDiff > 1000)

   if((uFirstTick-uLastTick)>1000)
     {
      //Debug("REFRESH NEEDED!!! " + uLastTick + " | " + uFirstTick + " | " + (int)(uLastTick - uFirstTick));

      //bMyOnTick = true;
      //MyOnTick();
      //bMyOnTick = false;

      MyOnTick=true;
      OnTick();
      MyOnTick=false;
     }
   else
     {
      //Debug("OK... " + uDiff);
      //Debug("OK... " + (int)(uFirstTick - uLastTick));
     }

//EventSetTimer(1);
  }
#endif


// ==========================================================================================================


void ChangeColorForItem(string objItemName)
  {
   if(
      (
//(PriceDir==ABOVE) &&
         (ExecCommand==BUY_STOP)
      ) ||
      (
//((PriceDir==BELOW) || (PriceDir==INSIDE)) &&
         (ExecCommand==BUY_LIMIT))
   )
     {
      if(!ObjectSetInteger(ChartID(),objItemName,OBJPROP_COLOR,ExecPosLONG)) {}

     }
   else
      if(
         (
            //(PriceDir==BELOW) &&
            (ExecCommand==SELL_STOP)
         ) ||
         (
            //((PriceDir==ABOVE) || (PriceDir==INSIDE)) &&
            (ExecCommand==SELL_LIMIT))
      )
        {
         if(!ObjectSetInteger(ChartID(),objItemName,OBJPROP_COLOR,ExecPosSHORT)) {}
        }
  }


// ==========================================================================================================


datetime AddOneWorkingDay(datetime CurrantDay,uint AddTimeInSec)
  {
//uint OneDayInSec = 24 * 60 * 60;    //  24 hours * 60 minutes * 60 sec
   uint OneDayInSec = AddTimeInSec;
   datetime NewDate = CurrantDay + OneDayInSec;
   
   int WeekDay = TimeDayOfWeek(NewDate);
   
   if(WeekDay == 6)
      NewDate = NewDate + (2 * OneDayInSec);

////// 07222025 Print("New Date: " + TimeToString(NewDate));
   return(NewDate);
  }


// ==========================================================================================================


uint MyTickNum=0;
bool NewCandelPoped=false;


//  ===================================================================


bool CheckEntryToExitDistance(MarketRefPoints _PriceDir,
                              OrderTypes _ExecCommand,
                              double _StopLossLevel,
                              double _PriceTargetLevel,
                              double _Spread)
  {
   if(
//(PriceDir==ABOVE) &&
      (_ExecCommand==BUY_STOP)
   )
     {
      if(
         ((_PriceTargetLevel-_StopLossLevel)<=_Spread)
         ||
         ((_PriceTargetLevel-_StopLossLevel)<=0)
      )
         return(false);
      else
         return(true);
     }
   else
      if(
         //(PriceDir==BELOW) &&
         (_ExecCommand==SELL_STOP)
      )
        {
         if(
            ((_StopLossLevel-_PriceTargetLevel)<=_Spread)
            ||
            ((_StopLossLevel-_PriceTargetLevel)<=0)
         )
            return(false);
         else
            return(true);
        }
      else
         if(
            //((PriceDir==ABOVE)  || (PriceDir==INSIDE)) &&
            (_ExecCommand==SELL_LIMIT)
         )
           {
            if(
               ((_StopLossLevel-_PriceTargetLevel)<=_Spread)
               ||
               ((_StopLossLevel-_PriceTargetLevel)<=0)
            )
               return(false);
            else
               return(true);
           }
         else
            if(
               //((PriceDir==BELOW)  || (PriceDir==INSIDE)) &&
               (_ExecCommand==BUY_LIMIT))
              {
               if(
                  ((_PriceTargetLevel-_StopLossLevel)<=_Spread)
                  ||
                  ((_PriceTargetLevel-_StopLossLevel)<=0)
               )
                  return(false);
               else
                  return(true);
              }

   return(true);
  }


//  ===================================================================

//  Assume current price has to be more than one spread away from pending order
MarketRefPoints GetCurrentPriceDirection(double _PriceTargetLevel, bool Filter)
  {

   MarketRefPoints CurrPriceLocation;
   

   if(
      //(MarketInfo(Symbol(),MODE_BID) < _PriceTargetLevel) 
      //   &&
      (MarketInfo(Symbol(),MODE_ASK) + (PTBufferPips + 1) * Point < _PriceTargetLevel)
      )
     {
     
      CurrPriceLocation = ABOVE;
      
      if(LastPriceDir != CurrPriceLocation)
      {
         if(ExecCommand==BUY_LIMIT)
         {
            if(Filter && FlipTargetLevel)
            {
               PrevExecCommand = BUY_LIMIT;
               ExecCommand=SELL_LIMIT;
               DirFlipped = true;
               SpreadBreached = true;
               
                  
            }
            else
            {
               PrevExecCommand = BUY_LIMIT;
               ExecCommand=BUY_STOP;
               DirFlipped = false;
               SpreadBreached = true;
            }
         }
         else
            if(ExecCommand==SELL_STOP)
              {
               if(Filter && FlipTargetLevel)
               {
                  PrevExecCommand=SELL_STOP;
                  ExecCommand=BUY_STOP;
                  DirFlipped = true;
                  SpreadBreached = true;
                  
                     
               }
               else
               {
                  PrevExecCommand=SELL_STOP;
                  ExecCommand=SELL_LIMIT;
                  DirFlipped = false;
                  SpreadBreached = true;
               }
              }
      }
      
      return(CurrPriceLocation);
      
     }
   else
      if(
         (MarketInfo(Symbol(),MODE_BID) - (PTBufferPips + 1) * Point > _PriceTargetLevel) 
         //&&
         //(MarketInfo(Symbol(),MODE_ASK) > _PriceTargetLevel)
         )
        {
        
         CurrPriceLocation = BELOW;
         
         if(LastPriceDir != CurrPriceLocation)
         {
            if(ExecCommand==BUY_STOP)
            {
             if(Filter && FlipTargetLevel)
             {
               PrevExecCommand=BUY_STOP;
                ExecCommand=SELL_STOP;
                DirFlipped = true;
                SpreadBreached = true;
                   
             }
             else
             {
                PrevExecCommand=BUY_STOP;
                ExecCommand=BUY_LIMIT;
                DirFlipped = false;
                SpreadBreached = true;
             }
            }
            else
               if(ExecCommand==SELL_LIMIT)
                 {
                  if(Filter && FlipTargetLevel)
                  {
                     PrevExecCommand=SELL_LIMIT;
                     ExecCommand=BUY_LIMIT;
                     DirFlipped = true;
                     SpreadBreached = true;
                     
                        
                  }
                  else
                  {
                     PrevExecCommand=SELL_LIMIT;
                     ExecCommand=SELL_STOP;
                     DirFlipped = false;
                     SpreadBreached = true;
                  }
                 }
        }
        
//         if(DirFlipped && SpreadBreached)
//         {
//            //ReCalculate after DIRECTIONAL FLIP
//            CalcSLTP(ExecCommand);
//            DrawALLLines();
//            DrawAllArrows();
//            DrawInitialPanel();
//            
//            WindowRedraw();
//            
//            SpreadBreached = false;
//            DirFlipped = false;
//         }
         
         return(CurrPriceLocation);
         
        }       
      else
         //if((Bid <= _PriceTargetLevel) &&
         //   (Ask >= _PriceTargetLevel))
           {
            //SpreadBreached = true;
            return(INSIDE);
           }
           
//   else if((Bid < _PriceTargetLevel) &&
//           (Ask == _PriceTargetLevel))
//         {
//            return(ON_ASK);
//         }
//   else if((Bid ==_PriceTargetLevel) &&
//           (Ask < _PriceTargetLevel))
//         {
//            return(ON_BID);
//         }
//
   return(NA);
  }


//  ===================================================================


void AjustColorsAccordingToDir(MarketRefPoints Dir)
  {
////// 07222025 Print("Inside AjustColorsAccordingToDir");
   switch(Dir)
     {
      case ABOVE:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,ABOVEColor);
         ObjectSetInteger(ChartID(),objPriceTargetLevelLineName,OBJPROP_COLOR,TargetLineColor);
         break;

      case BELOW:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,BELOWColor);
         ObjectSetInteger(ChartID(),objPriceTargetLevelLineName,OBJPROP_COLOR,TargetLineColor2);
         break;

      case INSIDE:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,INSIDEColor);
         ObjectSetInteger(ChartID(),objPriceTargetLevelLineName,OBJPROP_COLOR,TargetLineColor3);
         break;
     }
     
#ifdef _COLOR_ACORDING_TO_DIR_
   if(
      (
//(PriceDir==ABOVE) &&
         (ExecCommand==BUY_STOP)
      ) ||
      (
//((PriceDir==BELOW) || (PriceDir==INSIDE)) &&
         (ExecCommand==BUY_LIMIT))
   )
     {
      if(!ObjectSetInteger(ChartID(),"ExecutePositionValue",OBJPROP_COLOR,ExecPosLONG)) {}
      if(!ObjectSetInteger(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_COLOR,ExecPosLONG)) {}
      if(!ObjectSetInteger(ChartID(),"PositionOutcomeValue",OBJPROP_COLOR,ExecPosLONG)) {}

      if(!ObjectSetInteger(ChartID(),"PriceLevelProtectionValue",OBJPROP_COLOR,ExecPosLONG)) {}
      if(!ObjectSetInteger(ChartID(),"StopLossValue",OBJPROP_COLOR,ExecPosLONG)) {}
      if(!ObjectSetInteger(ChartID(),"TakeProfitValue",OBJPROP_COLOR,ExecPosLONG)) {}

      if(!ObjectSetInteger(ChartID(),"TrailingTriggerValue",OBJPROP_COLOR,ExecPosLONG)) {}
      if(!ObjectSetInteger(ChartID(),"TrailingTailValue",OBJPROP_COLOR,ExecPosLONG)) {}

      if(!ObjectSetInteger(ChartID(),"ProtectionAttemptsValue",OBJPROP_COLOR,ExecPosLONG)) {}
     }
   else
      if(
         (
            //(PriceDir==BELOW) &&
            (ExecCommand==SELL_STOP)) ||
         (
            //((PriceDir==ABOVE) || (PriceDir==INSIDE)) &&
            (ExecCommand==SELL_LIMIT)
         ))
        {
         if(!ObjectSetInteger(ChartID(),"ExecutePositionValue",OBJPROP_COLOR,ExecPosSHORT)) {}
         if(!ObjectSetInteger(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_COLOR,ExecPosSHORT)) {}
         if(!ObjectSetInteger(ChartID(),"PositionOutcomeValue",OBJPROP_COLOR,ExecPosSHORT)) {}

         if(!ObjectSetInteger(ChartID(),"PriceLevelProtectionValue",OBJPROP_COLOR,ExecPosSHORT)) {}
         if(!ObjectSetInteger(ChartID(),"StopLossValue",OBJPROP_COLOR,ExecPosSHORT)) {}
         if(!ObjectSetInteger(ChartID(),"TakeProfitValue",OBJPROP_COLOR,ExecPosSHORT)) {}

         if(!ObjectSetInteger(ChartID(),"TrailingTriggerValue",OBJPROP_COLOR,ExecPosSHORT)) {}
         if(!ObjectSetInteger(ChartID(),"TrailingTailValue",OBJPROP_COLOR,ExecPosSHORT)) {}

         if(!ObjectSetInteger(ChartID(),"ProtectionAttemptsValue",OBJPROP_COLOR,ExecPosSHORT)) {}
        }
#endif


  }


//  ===================================================================


//string GetExecCommand(OrderTypes _ExecCommand)
//  {
//   switch(_ExecCommand)
//     {
//      case SELL_STOP:
//         return("SELL_STOP");
//      case BUY_STOP:
//         return("BUY_STOP");
//      case SELL_LIMIT:
//         return("SELL_LIMIT");
//      case BUY_LIMIT:
//         return("BUY_LIMIT");
//     }
//
//   return("");
//  }


//  ===================================================================


string GetOpositDirection(string __PriceDir)
  {
   if(__PriceDir=="ABOVE")
      return("BELOW");
   else
      if(__PriceDir=="BELOW")
         return("ABOVE");

   return("");
  }


//  ===================================================================


void DrawHorizontalLine(string ObjName,
                        double _PriceLine,
                        int linestyle,
                        color col1,
                        int _width,
                        bool back,
                        string descript)
  {
//                          ResetLastError();
//
//                          // 07222025 Print("ObjName: " + ObjName);
//                          // 07222025 Print("LineStyle: " + linestyle);

//if(!(ObjectFind(ObjName)<0))
//   ObjectDelete(ObjName);

   
   bool bRet = false;
//                           int d = 0;
//                           int iRes = ObjectFind(ObjName);
//
//                           while(iRes >= 0)
   uint i = 0;

   
     do
     {
     
      ResetLastError();
      i++;
      
      if(ObjectFind(ObjName) >= 0)
      {
         //// 07222025 Print("Object found: " + ObjName);
         bRet = ObjectDelete(ObjName);
      
         if(bRet)
         {
            //// 07222025 Print(IntegerToString(i) + "Deleted successfully OBJ_HLINE: " + ObjName + " Error#", IntegerToString(GetLastError())); 
            break;
         }
         else
         {
            //// 07222025 Print(IntegerToString(i) + "Can''t Delete OBJ_HLINE: " + ObjName + " Error#", IntegerToString(GetLastError())); 
         }
      }
      else
      {
         //// 07222025 Print("Object NOT found: " + ObjName);
         //// 07222025 Print("Good... Breaking out!");
         
         break;
     }
     
      Sleep(SuspendThread2_TimePeriod); 
      
      //                              if(bRet)
      //                                 break;
      //
      //                              Sleep(500);

      //iRes = ObjectFind(ObjName);
      //                              // 07222025 Print("In Loop Obj Found: " + ((iRes < 0) ? "No" : "Yes"));
      //
      //                              d++;
     } 
     while(!bRet && i < 10);
     
     //// 07222025 Print("bRet is: " + IntegerToString(bRet));
     
//while(!(ObjectFind(ObjName)<0))
//{
//   ObjectDelete(ObjName);
//   d++;
//}

//// 07222025 Print("Obj Found: " + ((iRes < 0) ? "No" : "Yes"));
//// 07222025 Print("Obj Deleted: " +  bRet);
//// 07222025 Print("Num of Objs: " + d);


//if(ObjectFind(ObjName)<0)
//{
   i = 0;
   bRet = false;
   
   do
   {
      bRet = ObjectCreate(ObjName,OBJ_HLINE,0,0,_PriceLine);
      i++;
      
      if(!bRet)
        {
         //// 07222025 Print(IntegerToString(i) + " Can't create OBJ_HLINE: " + ObjName + " Error#", IntegerToString(GetLastError()));
        }
        else
        {
         //// 07222025 Print(IntegerToString(i) + " Created OBJ_HLINE: " + ObjName + " Error#", IntegerToString(GetLastError()));
         
         break;
        }
        
     Sleep(SuspendThread2_TimePeriod); 
   }
   while(!bRet && i < 10);
   
   //// 07222025 Print("bRet is: " + IntegerToString(bRet));
   
//else
//{
//   // 07222025 Print("Creating NEW Obj: " + ObjName);
//}
//}

   ObjectSet(ObjName,OBJPROP_STYLE,linestyle);
   ObjectSet(ObjName,OBJPROP_COLOR,col1);
   ObjectSet(ObjName,OBJPROP_WIDTH,_width);
   ObjectSet(ObjName,OBJPROP_BACK,back);
   ObjectSetText(ObjName,descript);

  }


//  ===================================================================


void MoveHLine(string name,double newlevel)
  {
   bool ResObjSpreadLine=ObjectMove(name,
                                    0,
                                    TimeCurrent(),
                                    newlevel);

   if(!ResObjSpreadLine)
     {
      // 07222025 Print("GetLastError: " + IntegerToString(GetLastError()));
     }

  }


//  ===================================================================


void InitToggleOnHold()
  {
   // 07222025 Print("INSIDE InitToggleOnHold...");
   
   if(OnHold==true)
      CreateOnHoldButton(sButtonName,OnHoldIconColorTRUE,"Wingdings",CharToStr(OnHoldIconArrowTRUE));
   else
      CreateOnHoldButton(sButtonName,OnHoldIconColorFALSE,"Wingdings",CharToStr(OnHoldIconArrowFALSE));

   // 07222025 Print("OnHold: ", OnHold);
  }


//  ===================================================================


void ToggleOnHold()
{
   // 07222025 Print("INSIDE ToggleOnHold...");
   
   OnHold=!OnHold;
   // 07222025 Print("<<<ToggleOnHold: "+IntegerToString(OnHold));
   
   if(OnHold==true)
     {
      CreateOnHoldButton(sButtonName,OnHoldIconColorTRUE,"Wingdings",CharToStr(OnHoldIconArrowTRUE));

      CurrentPosition=PositionOnHolt;
      ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
     }
   else
     {
      CreateOnHoldButton(sButtonName,OnHoldIconColorFALSE,"Wingdings",CharToStr(OnHoldIconArrowFALSE));

      CurrentPosition=PositionPending;
      ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);

      //  Update VALUE when Toggle flipped to ACTIVE
#ifdef      _TrendLineControl_      
      if(TrendLineTrigger && TrendLineTriggerActive)
        {
         UpdatePriceTarget(ObjectGetValueByShift(TrendLineName,0));
         LastCandleStart=Time[0];
         //// 07222025 Print("UpdatePriceTarget: " + PriceTargetLevel);
        }
#endif        
     }

//// 07222025 Print("OnHold: ", OnHold);

}


string GetLastStatus="";
int GetLastStatusColor=0;
string LastObjectSelected="";
bool PriceTargetLevelLineSELECTED=false;
bool StopLossLevelLineSELECTED=false;
bool TakeProfittLevelLineSELECTED=false;


//  ===================================================================


void OnChartEvent(const int id,         // Event identifier
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
  {
//      //--- the key has been pressed 
//   if(id==CHARTEVENT_KEYDOWN) 
//     { 
//      switch(int(lparam)) 
//        { 
//         //case KEY_NUMLOCK_LEFT:  // 07222025 Print("The KEY_NUMLOCK_LEFT has been pressed");   break; 
//         //case KEY_LEFT:          // 07222025 Print("The KEY_LEFT has been pressed");           break; 
//         //case KEY_NUMLOCK_UP:    // 07222025 Print("The KEY_NUMLOCK_UP has been pressed");     break; 
//         //case KEY_UP:            // 07222025 Print("The KEY_UP has been pressed");             break; 
//         //case KEY_NUMLOCK_RIGHT: // 07222025 Print("The KEY_NUMLOCK_RIGHT has been pressed");  break; 
//         //case KEY_RIGHT:         // 07222025 Print("The KEY_RIGHT has been pressed");          break; 
//         //case KEY_NUMLOCK_DOWN:  // 07222025 Print("The KEY_NUMLOCK_DOWN has been pressed");   break; 
//         //case KEY_DOWN:          // 07222025 Print("The KEY_DOWN has been pressed");           break; 
//         //case KEY_NUMPAD_5:      // 07222025 Print("The KEY_NUMPAD_5 has been pressed");       break; 
//         //case KEY_NUMLOCK_5:     // 07222025 Print("The KEY_NUMLOCK_5 has been pressed");      break; 
//         //case KEY_SPACEBAR:      // 07222025 Print("The KEY_SPACEBAR has been pressed");       break; 
//         case KEY_ESC:           {
//                                    EscKeyPressed = true; 
//                                    // 07222025 Print("The KEY_ESC has been pressed");            break; 
//                                 }
//         
//         default:                // 07222025 Print("Some not listed key has been pressed"); 
//        } 
//        
//      ChartRedraw(); 
//     } 
     
//static string GetLastStatus = "";
//static int GetLastStatusColor = 0;
//static string LastObjectSelected = "";
//static bool PriceTargetLevelLineSELECTED = false;
//static bool StopLossLevelLineSELECTED = false;
//static bool TakeProfittLevelLineSELECTED = false;

   //// 07222025 Print("ChartEVENT: " + IntegerToString(id));
   
#ifdef _SNAG_IT_BUTTON_     
   if(id == CHARTEVENT_OBJECT_DRAG) 
     { 
   
     ActButton001WithEvents.ChartEvent(id,
                                  lparam,
                                  dparam,
                                  sparam);
     
     }
#endif


   if(id==CHARTEVENT_OBJECT_CLICK)
     {


//long longVal = 0;   
//      if( sparam == objPigOutBtn.GetPigOutButton_Name())
//            {
//               if(ChartGetInteger(0,CHART_EVENT_MOUSE_MOVE,0, longVal))
//               {
//                  if(longVal == 0)
//                     ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
     
#ifdef _SNAG_IT_BUTTON_

ActButton001WithEvents.ChartEvent(id,
                                  lparam,
                                  dparam,
                                  sparam);

#endif                                  
            
            
      //// 07222025 Print("<<< sParam: " + sparam);

      //  Aspect ratio ON/OFF button
      if(sparam==InpName)
        {
         
         if(!ButtonIsPressed)
           {
            //  If Button is NOT Pressed - PRESS IT...
            ObjectSetInteger(0,InpName,OBJPROP_STATE,true);
            ObjectSetString(0,InpName,OBJPROP_TEXT,TitleClicked);
            ObjectSetInteger(0,InpName,OBJPROP_COLOR,TextColorClicked);
            ObjectSetInteger(0,InpName,OBJPROP_FONTSIZE,TextFontSizeClicked);

            // ----------------------------------------------------
            // CALL some FUNCTION that DOES SOMETHING ON THIS EVENT
            // ----------------------------------------------------

            ButtonIsPressed=!ButtonIsPressed;
           }
         else
           {
            //  If Button is Pressed - RELEASE IT...
            ObjectSetInteger(0,InpName,OBJPROP_STATE,false);
            ObjectSetString(0,InpName,OBJPROP_TEXT,TitleReleased);
            ObjectSetInteger(0,InpName,OBJPROP_COLOR,TextColorReleased);
            ObjectSetInteger(0,InpName,OBJPROP_FONTSIZE,TextFontSizeReleased);

            // ----------------------------------------------------
            // CALL some FUNCTION that DOES SOMETHING ON THIS EVENT
            // ----------------------------------------------------

            ButtonIsPressed=!ButtonIsPressed;
           }
           
           return;
        }

       //  ON_HOLD Toggle Button Pressed
       if(sparam==sButtonName)
       {
         
         // 07222025 Print("ON_HOLD Toggle Button Pressed...");
         // 07222025 Print("OrderOpened: "+IntegerToString(OrderOpened));
         
         if(!OrderOpened)
         {
            ToggleOnHold();
            
            if(!OnHold)
            {
            
            if(DelayedPrintActive)
            {
               DelayedPrintActive =  false;
               // 07222025 Print(">>> DelayedPrintActive SET to FALSE...");
            }
            
            
            //  Re-Orient Entry according to current SPREAD location...
            if(ExecCommand==BUY_LIMIT)
            {
            LastExecCommand=ExecCommand;
            // 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

            //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
            RefreshRates();
            if((Bid<PriceTargetLevel) &&
               (Ask<=PriceTargetLevel))
              {
               // ABOVE
               // BUY_LIMIT Remains the SAME provided that SPREAD ABOVE EP
               //// 07222025 Print("Market BELOW Entry...");
               if(LastExecCommand==BUY_LIMIT)
                  ExecCommand=BUY_STOP;

              }
            else
               if((Bid>=PriceTargetLevel) &&
                  (Ask>PriceTargetLevel))
                 {
                  // BELOW
                  // BUY_LIMIT Migrated into a BUY_STOP provided that SPREAD < distance between EN & SL
                  //// 07222025 Print("Market ABOVE Entry...");
                  if(LastExecCommand==BUY_LIMIT)
                     ExecCommand=BUY_LIMIT;

                 }
               else
                  if((Bid<PriceTargetLevel) &&
                     (Ask>PriceTargetLevel))
                    {
                     // INSIDE
                     //// 07222025 Print("Market ABOVE Entry...");
                     if(LastExecCommand==BUY_LIMIT)
                        ExecCommand=BUY_LIMIT;

                    }

            // 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
           }
         else
            if(ExecCommand==SELL_LIMIT)
              {
               LastExecCommand=ExecCommand;
               // 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

               //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
               RefreshRates();
               if((Bid<PriceTargetLevel) &&
                  (Ask<=PriceTargetLevel))
                 {
                  // ABOVE
                  // SELL_LIMIT Migrated into a SELL_STOP provided that SPREAD < distance between EN & SL
                  //// 07222025 Print("Bid: " + Bid + " Ask: " + Ask + "PriceTargetLevel: " + PriceTargetLevel + " -> Market BELOW Entry...");
                  if(LastExecCommand==SELL_LIMIT)
                     ExecCommand=SELL_LIMIT;

                 }
               else
                  if((Bid>=PriceTargetLevel) &&
                     (Ask>PriceTargetLevel))
                    {
                     // BELOW
                     // SELL_LIMIT Remains the SAME provided that SPREAD BELOW EP
                     //// 07222025 Print("Bid: " + Bid + " Ask: " + Ask + "PriceTargetLevel: " + PriceTargetLevel + " -> Market ABOVE Entry......");
                     if(LastExecCommand==SELL_LIMIT)
                        ExecCommand=SELL_STOP;

                    }
                  else
                     if((Bid<PriceTargetLevel) &&
                        (Ask>PriceTargetLevel))
                       {
                        // INSIDE
                        //// 07222025 Print("Bid: " + Bid + " Ask: " + Ask + "PriceTargetLevel: " + PriceTargetLevel + " -> Market ABOVE Entry......");
                        if(LastExecCommand==SELL_LIMIT)
                           ExecCommand=SELL_LIMIT;

                       }

               // 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
              }
            else
               if(ExecCommand==SELL_STOP)
                 {
                  LastExecCommand=ExecCommand;
                  // 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

                  //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
                  RefreshRates();
                  if((Bid<PriceTargetLevel) &&
                     (Ask<=PriceTargetLevel))
                    {
                     // PriceTargetLevel is ABOVE SPREAD
                     // SELL_STOP Migrated into a SELL_LIMIT provided that SPREAD < distance between EN & SL
                     //// 07222025 Print("Market BELOW Entry...");
                     if(LastExecCommand==SELL_STOP)
                        ExecCommand=SELL_LIMIT;

                    }
                  else
                     if((Bid>=PriceTargetLevel) &&
                        (Ask>PriceTargetLevel))
                       {
                        // BELOW
                        // SELL_STOP Remains the SAME provided that SPREAD BELOW EP
                        //// 07222025 Print("Market ABOVE Entry...");
                        if(LastExecCommand==SELL_STOP)
                           ExecCommand=SELL_STOP;

                       }
                     else
                        if((Bid<PriceTargetLevel) &&
                           (Ask>PriceTargetLevel))
                          {
                           // INSIDE
                           //// 07222025 Print("Market ABOVE Entry...");
                           if(LastExecCommand==SELL_STOP)
                              ExecCommand=SELL_LIMIT;

                          }

                  // 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
                 }
               else
                  if(ExecCommand==BUY_STOP)
                    {
                     LastExecCommand=ExecCommand;
                     //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

                     //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
                     RefreshRates();
                     if((Bid<PriceTargetLevel) &&
                        (Ask<=PriceTargetLevel))
                       {
                        // ABOVE
                        // BUY_LIMIT Remains the SAME provided that SPREAD ABOVE EP
                        //// 07222025 Print("Market BELOW Entry...");
                        if(LastExecCommand==BUY_STOP)
                           ExecCommand=BUY_STOP;

                       }
                     else
                        if((Bid>=PriceTargetLevel) &&
                           (Ask>PriceTargetLevel))
                          {
                           // BELOW
                           // BUY_LIMIT Migrated into a BUY_STOP provided that SPREAD < distance between EN & SL
                           //// 07222025 Print("Market ABOVE Entry...");
                           if(LastExecCommand==BUY_STOP)
                              ExecCommand=BUY_LIMIT;

                          }
                        else
                           if((Bid<PriceTargetLevel) &&
                              (Ask>PriceTargetLevel))
                             {
                              // INSIDE
                              //// 07222025 Print("Market ABOVE Entry...");
                              if(LastExecCommand==BUY_STOP)
                                 ExecCommand=BUY_LIMIT;

                             }

                     // 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
                    }
                }
         }

         return;
      }


      // Entry Line Selected
      if(sparam == objPriceTargetLevelLineName)
      {
        
         if((OrderOpened) &&
            (ObjectGet(objPriceTargetLevelLineName,OBJPROP_SELECTED)==1))
           {
            ObjectSet(objPriceTargetLevelLineName,OBJPROP_SELECTED,0);
            //Debug("Can't SELECT while TRADE IS OPEN!!!");

            return;
           }


         if((!OrderOpened) &&
            (ObjectGet(objPriceTargetLevelLineName,OBJPROP_SELECTED)==1) &&
            (!PriceTargetLevelLineSELECTED))
           {
            //if(!PriceTargetLevelLineSELECTED)
            //   PriceTargetLevelLineSELECTED=!PriceTargetLevelLineSELECTED;
            PriceTargetLevelLineSELECTED = true;
            //// 07222025 Print("1.PriceTargetLevelLineSELECTED: " + IntegerToString(PriceTargetLevelLineSELECTED));
            
            CurrentPosition=PositionOnHolt;
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);

            if(!OnHold)
               ToggleOnHold();

            LastObjectSelected = objPriceTargetLevelLineName;
            //RefreshDirection();

            //GetLastStatus = ObjectGetString(ChartID(), "PositionLocationValue", OBJPROP_TEXT);
            //GetLastStatusColor = (int)ObjectGet("PositionLocationValue", OBJPROP_COLOR);

            //ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,clrRed);
            //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, "ENTRY LEVEL LINE SELECTED");

            //Debug("OnHold: " + OnHold +"  PriceTargetLevel SELECTED...");
#ifdef _MOUSE_MOVE_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1))
            Sleep(100);
#endif
            return;
           }


         if((!OrderOpened) &&
            (ObjectGet(objPriceTargetLevelLineName,OBJPROP_SELECTED)==0) &&
            (PriceTargetLevelLineSELECTED))
           {
            CurrentPosition=PositionPending;
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
            
            if(OnHold)
            //OnHold=!OnHold;
            ToggleOnHold();
            
            //if(PriceTargetLevelLineSELECTED)
            //   PriceTargetLevelLineSELECTED=!PriceTargetLevelLineSELECTED;
            PriceTargetLevelLineSELECTED = false;
            //// 07222025 Print("2.PriceTargetLevelLineSELECTED: " + IntegerToString(PriceTargetLevelLineSELECTED));
            
            ReAlignExecCommand();
            //if(!FirstTickTarget)
            //   FirstTickTarget=!FirstTickTarget;
            FirstTickTarget = true;

            //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, GetLastStatus);
            //ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,GetLastStatusColor);

            //Debug("OnHold: " + OnHold +"  PriceTargetLevel UN-SELECTED...");
#ifdef _MOUSE_MOVE2_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
            return;
           }
        }


      //  StopLoss Line Selected
      if(sparam==objStopLossLevelLineName)
        {
        
         if((ObjectGet(objStopLossLevelLineName,OBJPROP_SELECTED)==1) &&
            (!StopLossLevelLineSELECTED))
           {
            //if(!StopLossLevelLineSELECTED)
            //   StopLossLevelLineSELECTED=!StopLossLevelLineSELECTED;
            StopLossLevelLineSELECTED = true;
            
#ifdef _MOUSE_MOVE_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1))
            Sleep(100);
#endif
            //  Make a copy of the Last StopLossPips ONLY if it is NOT TRAILING already...
            if(!TTriggerActivated)
               BeforeLastStopLossPips = StopLossPips;

            //// 07222025 Print("1. BeforeLastStopLossPips: " + BeforeLastStopLossPips);
            //            BuffOriginalStopLossPips = OriginalStopLossPips;
            //            //// 07222025 Print("BuffOriginalStopLossPips: "+BuffOriginalStopLossPips);
            LastObjectSelected = objStopLossLevelLineName;
            return;
           }


         if((ObjectGet(sparam,OBJPROP_SELECTED)==0) &&
            (StopLossLevelLineSELECTED))
           {

            //if(StopLossLevelLineSELECTED)
            //   StopLossLevelLineSELECTED=!StopLossLevelLineSELECTED;
            StopLossLevelLineSELECTED = false;
               
#ifdef _MOUSE_MOVE2_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
            return;
           }
        }

      // Take Profit Line Selected
      if(sparam==objTakeProfitLevelLineName)
        {
         if((ObjectGet(objTakeProfitLevelLineName,OBJPROP_SELECTED)==1) &&
            (!TakeProfittLevelLineSELECTED))
           {
            //if(!TakeProfittLevelLineSELECTED)
            //   TakeProfittLevelLineSELECTED=!TakeProfittLevelLineSELECTED;
            TakeProfittLevelLineSELECTED = true;
               
            //BeforeLastTakeProfitPips = TakeProfitPips;
            //// 07222025 Print("1. BeforeLastTakeProfitPips: " + TakeProfitPips);
            
#ifdef _MOUSE_MOVE_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1))
            Sleep(100);
#endif
            LastObjectSelected=objTakeProfitLevelLineName;
            return;
           }


         if((ObjectGet(sparam,OBJPROP_SELECTED)==0) &&
            (TakeProfittLevelLineSELECTED))
           {
            //if(TakeProfittLevelLineSELECTED)
            //   TakeProfittLevelLineSELECTED=!TakeProfittLevelLineSELECTED;
               TakeProfittLevelLineSELECTED = false;
               
#ifdef _MOUSE_MOVE2_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
            return;
           }
        }

#ifdef      _TrendLineControl_
      //  TrendLine SELECTED
      if(sparam==TrendLineName)
        {
         if((ObjectGet(TrendLineName,OBJPROP_SELECTED)==1) &&
            (!TrendLineSELECTED))
           {
            //if(!TrendLineSELECTED)
            //   TrendLineSELECTED=!TrendLineSELECTED;
            TrendLineSELECTED = true;
            
            LastObjectSelected=TrendLineName;
#ifdef _MOUSE_MOVE_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1))
            Sleep(100);
#endif
            return;
           }

         if((ObjectGet(sparam,OBJPROP_SELECTED)==0) &&
            (TrendLineSELECTED))
           {
            //if(TrendLineSELECTED)
            //   TrendLineSELECTED=!TrendLineSELECTED;
            TrendLineSELECTED = false;
            
#ifdef _MOUSE_MOVE2_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
            return;
           }
        }
#endif

#ifdef   _TrailingStop_
      //  Trailing Trigger SELECTED
      if(sparam==objTrailingTriggerLevelLineName)
        {
         if((TTriggerActivated) &&
            (ObjectGet(objTrailingTriggerLevelLineName,OBJPROP_SELECTED)==1))
           {
            ObjectSet(objTrailingTriggerLevelLineName,OBJPROP_SELECTED,0);
            //Debug("Can't SELECT while TRADE IS OPEN!!!");

            return;
           }


         if((ObjectGet(objTrailingTriggerLevelLineName,OBJPROP_SELECTED)==1) &&
            (!TTriggerLineSELECTED))
           {
            //if(!TTriggerLineSELECTED)
            //   TTriggerLineSELECTED=!TTriggerLineSELECTED;
            TTriggerLineSELECTED = true;

            LastObjectSelected=objTrailingTriggerLevelLineName;
            
#ifdef _MOUSE_MOVE_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1))
            Sleep(100);
#endif
            //// 07222025 Print("TTriggerLineSELECTED: " + TTriggerLineSELECTED + "  LastObjectSelected: " + LastObjectSelected);
            return;
           }


         if((ObjectGet(objTrailingTriggerLevelLineName,OBJPROP_SELECTED)==0) &&
            (TTriggerLineSELECTED))
           {
            //if(TTriggerLineSELECTED)
            //   TTriggerLineSELECTED=!TTriggerLineSELECTED;
            TTriggerLineSELECTED = false;
            
#ifdef _MOUSE_MOVE2_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
            //// 07222025 Print("TTriggerLineSELECTED: " + TTriggerLineSELECTED + "  LastObjectSelected: " + LastObjectSelected);
            return;
           }
        }
#endif


#ifdef   _TrailingStop_
      //  Trailing TAIL SELECTED
      if(sparam==objTrailingTailLevelLineName)
        {
         if((TTriggerActivated) &&
            (ObjectGet(objTrailingTailLevelLineName,OBJPROP_SELECTED)==1))
           {
            ObjectSet(objTrailingTailLevelLineName,OBJPROP_SELECTED,0);
            //Debug("Can't SELECT while TRADE IS OPEN!!!");

            return;
           }


         if((ObjectGet(objTrailingTailLevelLineName,OBJPROP_SELECTED)==1) &&
            (!TTailLineSELECTED))
           {
            //if(!TTailLineSELECTED)
            //   TTailLineSELECTED=!TTailLineSELECTED;
            TTailLineSELECTED = true;

            LastObjectSelected=objTrailingTailLevelLineName;
            
#ifdef _MOUSE_MOVE_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1))
            Sleep(100);
#endif
            //// 07222025 Print("TTailLineSELECTED: " + TTailLineSELECTED + "  LastObjectSelected: " + LastObjectSelected);
            return;
           }

         if((ObjectGet(sparam,OBJPROP_SELECTED)==0) &&
            (TTailLineSELECTED))
           {
            //if(TTailLineSELECTED)
            //   TTailLineSELECTED=!TTailLineSELECTED;
            TTailLineSELECTED = false;
            
#ifdef _MOUSE_MOVE2_
            while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
            //// 07222025 Print("TTailLineSELECTED: " + TTailLineSELECTED + "  LastObjectSelected: " + LastObjectSelected);
            return;
           }
        }
#endif
      ////// 07222025 Print("The mouse has been clicked on the object with name '"+sparam+"'");
     }


//  ==============================================================================================================================================================================================


//  DRAG with LEFT MOUSE BUTTON DOWN
   else if(id==CHARTEVENT_MOUSE_MOVE)
     {


#ifdef _PIG_OUT_BUTTON_


#endif


      //  ========================================================================================================================================================================================
      //  When the Left Mouse Button is DOWN
      if((LastObjectSelected == objPriceTargetLevelLineName) && ((((uint)sparam  &1)==1) || ((((uint)sparam  &4)==4)) ))
        {
        
         //if(ExitNOW)
         //{
         //   // 07222025 Print("Returning...");
         //   //Sleep(100);
         //   return;
         //}
         //else
         //{
         //   // 07222025 Print("Going in...");
         //}
            
         if(!OrderOpened) //  No NEED as it wouldn't be selected in the first place...
           {
           //// 07222025 Print("MouseMove...");
         //  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            
            // SHIFT Key Pressed DOWN
//            if((((uint)sparam  &4)==4))
//            {
//               LastPriceTargetLevel = PriceTargetLevel;
//               LastPriceDir = PriceDir;
//               //  Get NEW PriceTargetLevel Location...
//               int j = 0;
//               while(!ObjectGetDouble(ChartID(), objPriceTargetLevelLineName, OBJPROP_PRICE, 0, PriceTargetLevel))
//               {
//                     j++;
//                     Sleep(100);
//                     // 07222025 Print(">>> " + IntegerToString(j) + "Can't GET PriceTargetLevel...");
//               }
//               
//               DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
//               // Get NEW PriceDir...
//               PriceDir = GetCurrentPriceDirection(PriceTargetLevel, true);
//               AjustColorsAccordingToDir(PriceDir);
//               // Filter OUT when line inside SPREAD...  So that CHANGES from BELOW -> ABOVE & ABOVE -> BELOW exist
//               if(PriceDir == INSIDE)
//                  PriceDir = LastPriceDir;
//               
//               if(PriceDir == ABOVE){
//                  AdjustNewPriceTargetLevelPosition2((uint)sparam);
//                  //// 07222025 Print(DoubleToStr(NormalizeDouble(PriceTargetLevel,Digits)) + "< ABOVE...");
//                  //// 07222025 Print("< ABOVE...");
//                  }
//               else 
//               if(PriceDir == BELOW){
//                  AdjustNewPriceTargetLevelPosition2((uint)sparam);
//                  //// 07222025 Print(DoubleToStr(NormalizeDouble(PriceTargetLevel,Digits)) + "> BELOW...");
//                  //// 07222025 Print("> BELOW...");
//                  }
//               else
//               if(PriceDir == INSIDE)
//               {
//                  AdjustNewPriceTargetLevelPosition2((uint)sparam);
//                  //// 07222025 Print(DoubleToStr(NormalizeDouble(PriceTargetLevel,Digits)) + "< INSIDE >...");
//                  // 07222025 Print("< INSIDE >...");
//               }
//               
//               //Sleep(10);
//               
//            }
//            else  // NO SHIFT Key...
            if(!(((uint)sparam  &4)==4))
            {
               LastPriceTargetLevel = PriceTargetLevel;
               LastPriceDir = PriceDir;
               
               //  Get NEW PriceTargetLevel Location...
               int j = 0;
               while(!ObjectGetDouble(ChartID(), objPriceTargetLevelLineName, OBJPROP_PRICE, 0, PriceTargetLevel))
               {
                     j++;
                     Sleep(100);
                     // 07222025 Print(">>> " + IntegerToString(j) + "Can't GET PriceTargetLevel...");
               }
               
               DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
               if(DiffLevels == 0)
                  return;
               
               // Get NEW PriceDir...
               //PriceDir = GetCurrentPriceDirection(PriceTargetLevel, true);
               PriceDir = GetCurrentPriceDirection(PriceTargetLevel, false);
               AjustColorsAccordingToDir(PriceDir);
                 
//               if(DirFlipped && SpreadBreached)
//               {
//                  //ReCalculate after DIRECTIONAL FLIP
//                  CalcSLTP(ExecCommand);
//                  MoveALLLines();
//                  //DrawAllArrows();
//                  //DrawInitialPanel();
//                  ChartRedraw();
//                  
//                  SpreadBreached = false;
//                  DirFlipped = false;
//               }  
                             
               AdjustNewPriceTargetLevelPosition((uint)sparam);    //    Call was here...
            }
            
            ChartRedraw();
            
            //// 07222025 Print("AdjustNewPriceTargetLevelPosition>>>");
        
           }
           
           return;
            
      }


      //  ========================================================================================================================================================================================


      //  When you RELEASE the Left Mouse Button
      if((LastObjectSelected == objPriceTargetLevelLineName) && (!(((uint)sparam  &1)==1)))
        {
        
        
         // UN-SELECT the LINE
         ObjectSet(objPriceTargetLevelLineName,OBJPROP_SELECTED,0);

         CurrentPosition=PositionPending;
         ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);

         if(OnHold)
            //OnHold=!OnHold;
            ToggleOnHold();

//         //if(PriceTargetLevelLineSELECTED)
//         //   PriceTargetLevelLineSELECTED=!PriceTargetLevelLineSELECTED;
         PriceTargetLevelLineSELECTED = false;
         //// 07222025 Print("After Mouse Release - PriceTargetLevelLineSELECTED: " + IntegerToString(PriceTargetLevelLineSELECTED));
         
         
         //ReAlignExecCommand();
         
//         if(!FirstTickTarget)
//            FirstTickTarget=!FirstTickTarget;
         FirstTickTarget = true;
                 
         
//         //  Get NEW PriceTargetLevel Location...
//         double ThisPriceTargetLevel;
//         int j = 0;
//         
//         while(!ObjectGetDouble(ChartID(), objPriceTargetLevelLineName, OBJPROP_PRICE, 0, ThisPriceTargetLevel))
//         {
//               j++;
//               Sleep(100);
//               // 07222025 Print(">>> " + IntegerToString(j) + "Can't GET PriceTargetLevel...");
//         }
//         
//         if(ThisPriceTargetLevel != PriceTargetLevel)
           
           //if(!FlipTargetLevel) 
           // MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
//            
//         
//         PriceDir = GetCurrentPriceDirection(PriceTargetLevel);
//         AjustColorsAccordingToDir(PriceDir);
//
//         //// 07222025 Print("2. PriceDir: " + EnumToString(PriceDir));
//
//         if((((uint)sparam   &4)==4) && (PriceDir==INSIDE))
//           {
//           
//            if(ExecCommand==BUY_LIMIT)
//              {
//               RefreshRates();
//               PriceTarget=Ask;
//
//               //SetALLLineLevels();
//
//#include <OpenPosLevel_BUY_LIMIT.mqh>
//
//               //DrawALLLines();
//               //DrawALLLinesMetrixs();
//
//              }
//            else
//               if(ExecCommand==BUY_STOP)
//                 {
//                  RefreshRates();
//                  PriceTarget=Ask;
//
//                  //SetALLLineLevels();
//
//#include <OpenPosLevel_BUY_STOP.mqh>
//
//                  //DrawALLLines();
//                  //DrawALLLinesMetrixs();
//                 }
//               else
//                  if(ExecCommand==SELL_LIMIT)
//                    {
//                     RefreshRates();
//                     PriceTarget=Bid;
//
//                     //SetALLLineLevels();
//
//#include <OpenPosLevel_SELL_LIMIT.mqh>
//
//                     //DrawALLLines();
//                     //DrawALLLinesMetrixs();
//                    }
//                  else
//                     if(ExecCommand==SELL_STOP)
//                       {
//                        RefreshRates();
//                        PriceTarget=Bid;
//
//                        //SetALLLineLevels();
//
//#include <OpenPosLevel_SELL_STOP.mqh>
//
//                        //DrawALLLines();
//                        //DrawALLLinesMetrixs();
//                       }
//
//           }
           
#ifdef _MOUSE_MOVE2_
         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif

         //if(ExitNOW)
         //   ExitNOW = false;
         
//         if(FlipTargetLevel)
//         {
//            //  ReCalculate after DIRECTIONAL FLIP
//            CalcSLTP(ExecCommand);
//            DrawALLLines();
//            DrawAllArrows();
//            DrawInitialPanel();
//            
//            //UpdatePriceTarget(PriceTargetLevel);
//
//         }
         
         WindowRedraw();

         return;
         
        }

      //  ========================================================================================================================================================================================

      if((LastObjectSelected==objStopLossLevelLineName) &&
         (StopLossLevelLineSELECTED) &&
         (((uint)sparam  &1)==1) &&
         (((uint)sparam  &4)==4))
        {
         AutoFireAfterSL=!AutoFireAfterSL;
         //LastObjectSelected = "";

         if(AutoFireAfterSL)
           {
            if(DrawStopLevel)
               DrawHorizontalLine(objStopLossLevelLineName,
                                  StopLossLevel,
                                  StopLineStyle,
                                  StopLineColor,
                                  StopLineWidth,
                                  StopBackground,
                                  "StopLossLevelLine");
           }
         else
           {
            if(DrawStopLevel)
               DrawHorizontalLine(objStopLossLevelLineName,
                                  StopLossLevel,
                                  DASH,
                                  StopLineColor,
                                  StopLineWidth,
                                  StopBackground,
                                  "StopLossLevelLine");
           }

         //  Un-Select LINE...
         //                                    ObjectSet(objStopLossLevelLineName, OBJPROP_SELECTED, 0);
         //
         //                                    //  Toggle Selected FLAG
         //                                    if(StopLossLevelLineSELECTED)
         //                                       StopLossLevelLineSELECTED=!StopLossLevelLineSELECTED;

         //// 07222025 Print("AutoFireAfterSL: " + AutoFireAfterSL);
         
         return;
         
        }

      //  ========================================================================================================================================================================================

      if((LastObjectSelected==objTakeProfitLevelLineName) &&
         (((uint)sparam  &1)==1) &&
         (((uint)sparam  &4)==4))
        {
         AutoFireAfterTP=!AutoFireAfterTP;

         if(AutoFireAfterTP)
           {
            if(DrawStopLevel)
               DrawHorizontalLine(objTakeProfitLevelLineName,
                                  TakeProfitLevel,
                                  ProfitLineStyle,
                                  ProfitLineColor,
                                  ProfitLineWidth,
                                  ProfitBackground,
                                  "TakeProfitLevelLine");
           }
         else
           {
            if(DrawStopLevel)
               DrawHorizontalLine(objTakeProfitLevelLineName,
                                  TakeProfitLevel,
                                  DASH,
                                  ProfitLineColor,
                                  ProfitLineWidth,
                                  ProfitBackground,
                                  "TakeProfitLevelLine");
           }


         //// 07222025 Print("AutoFireAfterTP: " + AutoFireAfterTP);
         return;
         
        }
        

      //  ========================================================================================================================================================================================

        
#ifdef   _TrailingStop_

      if((LastObjectSelected== objTrailingTriggerLevelLineName) &&
         (((uint)sparam  &1)==1) &&
         (((uint)sparam  &4)==4))
        {
         ////// 07222025 Print("INSIDE Proc!!!!!!!!!!!!!!!!!!");
         //// 07222025 Print("BEFORE TTriggerLineActive: " + TTriggerLineActive);

         TTriggerLineActive = !TTriggerLineActive;

         if(TTriggerLineActive)
           {
            if(DrawTTriggerLevel)
               ObjectSet(objTrailingTriggerLevelLineName,OBJPROP_STYLE,TTriggerLineStyle);

           }
         else
           {
            if(DrawTTriggerLevel)
               ObjectSet(objTrailingTriggerLevelLineName,OBJPROP_STYLE,STYLE_DASH);
           }

         //// 07222025 Print(">>>>>>>>>>>>>>>>>AFTER TTriggerLineActive: " + TTriggerLineActive);
        
         return;
        }
#endif

        

      //  ========================================================================================================================================================================================
      // StopLossLevel When Left Mouse Button Pressed
      if((LastObjectSelected == objStopLossLevelLineName) && (((uint)sparam  &1)==1))
        {
         AdjustNewStopLossLevelPosition(PriceDir);

         //  Make a copy of the NEW StopLossPips
         //LastStopLossPips = StopLossPips;
         //// 07222025 Print("2. StopLossPips: " + StopLossPips);
         
         return;
        }

      //  ========================================================================================================================================================================================

      //  StopLossLevel When you Release the Left Mouse Button
      if((LastObjectSelected == objStopLossLevelLineName) && (!(((uint)sparam  &1)==1)))
        {
         // UN-SELECT the LINE
         ObjectSet(objStopLossLevelLineName,OBJPROP_SELECTED,0);

         //if(StopLossLevelLineSELECTED)
         //   StopLossLevelLineSELECTED=!StopLossLevelLineSELECTED;
         StopLossLevelLineSELECTED = false;
            
         LastStopLossPips = StopLossPips;
         //// 07222025 Print("33. BeforeLastStopLossPips: " + BeforeLastStopLossPips + " | LastStopLossPips: " + LastStopLossPips);
#ifdef _MOUSE_MOVE2_
         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
         return;
         
        }

      //  ========================================================================================================================================================================================

#ifdef      _TrendLineControl_
      if((LastObjectSelected== TrendLineName) &&
         (((uint)sparam  &1)==1) &&
         (((uint)sparam  &4)==4))
        {
         TrendLineTriggerActive=!TrendLineTriggerActive;

         if(TrendLineTriggerActive)
           {
            if(TrendLineTrigger)
               ObjectSet(TrendLineName,OBJPROP_STYLE,TrendLineStyle);
           }
         else
           {
            if(TrendLineTrigger)
               ObjectSet(TrendLineName,OBJPROP_STYLE,STYLE_DASH);
           }

         //// 07222025 Print("TrendLineTriggerActive: " + TrendLineTriggerActive);
         return;
        }
#endif

      //  ========================================================================================================================================================================================

#ifdef      _TrendLineControl_
      //  When you release the Mouse Button
      if((LastObjectSelected==TrendLineName) && (!(((uint)sparam  &1)==1)))
        {
         // UN-SELECT the LINE
         ObjectSet(TrendLineName,OBJPROP_SELECTED,0);

         if(TrendLineSELECTED)
            TrendLineSELECTED=!TrendLineSELECTED;

         //  Update VALUE when MOUSE released
         if(TrendLineTrigger && TrendLineTriggerActive)
           {
            UpdatePriceTarget(ObjectGetValueByShift(TrendLineName,0));
            LastCandleStart=Time[0];
            //// 07222025 Print("UpdatePriceTarget: " + PriceTargetLevel);
           }
#ifdef _MOUSE_MOVE2_
         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
         return;
        }
#endif

      //  ========================================================================================================================================================================================

      if((LastObjectSelected==objTakeProfitLevelLineName) && (((uint)sparam  &1)==1))
        {
         AdjustNewTakeProfitLevelPosition(PriceDir);
         
         //// 07222025 Print("2. TakeProfitPips: " + TakeProfitPips);
         return;
        }

      //  ========================================================================================================================================================================================

      //  When you release the Mouse Button
      if((LastObjectSelected==objTakeProfitLevelLineName) && (!(((uint)sparam  &1)==1)))
        {
         // UN-SELECT the LINE
         ObjectSet(objTakeProfitLevelLineName,OBJPROP_SELECTED,0);

         //if(TakeProfittLevelLineSELECTED)
         //   TakeProfittLevelLineSELECTED=!TakeProfittLevelLineSELECTED;
         TakeProfittLevelLineSELECTED = false;
            
         //// 07222025 Print("2. TakeProfitPips: " + TakeProfitPips);
         
#ifdef _MOUSE_MOVE2_
         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
         return;
        }

      //  ========================================================================================================================================================================================

#ifdef   _TrailingStop_
      if((LastObjectSelected==objTrailingTriggerLevelLineName) && (((uint)sparam  &1)==1))
        {
         AdjustNewTrailingTriggerLevelPosition(PriceDir);
         
         return;
        }
#endif

      //  ========================================================================================================================================================================================

#ifdef   _TrailingStop_
      //  When you release the Mouse Button
      if((LastObjectSelected==objTrailingTriggerLevelLineName) && (!(((uint)sparam  &1)==1)))
        {
         // UN-SELECT the LINE
         ObjectSet(objTrailingTriggerLevelLineName,OBJPROP_SELECTED,0);

         
         //if(TTriggerLineSELECTED)
         //   TTriggerLineSELECTED=!TTriggerLineSELECTED;
         TTriggerLineSELECTED = false;
         
#ifdef _MOUSE_MOVE2_
         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
         return;
        }
#endif

      //  ========================================================================================================================================================================================

#ifdef   _TrailingStop_

      if((LastObjectSelected==objTrailingTailLevelLineName) && (((uint)sparam  &1)==1))
        {
         AdjustNewTrailingTailLevelPosition(PriceDir);
         
         return;
        }
#endif

      //  ========================================================================================================================================================================================

#ifdef   _TrailingStop_
      //  When you release the Mouse Button
      if((LastObjectSelected==objTrailingTailLevelLineName) && (!(((uint)sparam  &1)==1)))
        {
         // UN-SELECT the LINE
         ObjectSet(objTrailingTailLevelLineName,OBJPROP_SELECTED,0);

         //if(TTailLineSELECTED)
         //   TTailLineSELECTED=!TTailLineSELECTED;
         TTailLineSELECTED = false;
            
#ifdef _MOUSE_MOVE2_
         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
            Sleep(100);
#endif
         return;
        }
#endif

     }


//  ========================================================================================================================================================================================
//  
   else if((id==CHARTEVENT_OBJECT_DRAG) 
               //|| 
               //(id==CHARTEVENT_OBJECT_CHANGE)
               )
     {
      ////// 07222025 Print("CHARTEVENT_OBJECT_DRAG - The anchor point coordinates of the object with name ",sparam," has been changed");
      
      // 07222025 Print("CHARTEVENT_OBJECT_DRAG: " + objPriceTargetLevelLineName);
      
      if((!OrderOpened) && (sparam == objPriceTargetLevelLineName))
        {   

            // UN-SELECT the LINE
            ObjectSet(objPriceTargetLevelLineName,OBJPROP_SELECTED,0);

            CurrentPosition = PositionPending;
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);

            if(OnHold)
               ToggleOnHold();

            PriceTargetLevelLineSELECTED = false;
            FirstTickTarget = true;
            
            MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
            
            // ====================================================
//            if(DirFlipped && SpreadBreached)
//            {
//               //ReCalculate after DIRECTIONAL FLIP
//               CalcSLTP(ExecCommand);
//               DrawALLLines();
//               DrawAllArrows();
//               DrawInitialPanel();
//               
//               SpreadBreached = false;
//               DirFlipped = false;
//            }
            
            PlaySound("Ok.wav");
            
        }
     }

  }

//  ===================================================================




//  ===================================================================

//void RemoveOldArrows()
//{
//
//   if(!(ObjectFind(objStopArrow)<0))
//         ObjectDelete(objStopArrow);
//
//   if(!(ObjectFind(objProfitArrow)<0))
//      ObjectDelete(objProfitArrow);
//
//}


//  ===================================================================

//void CalcSLTP(OrderTypes _ExecCommand)
//{
//
//   switch (_ExecCommand)
//   {
//      case SELL_STOP:
//                           if(CalcSLTPbyPipsORDiff)
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel+(StopLossPips*Point)),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel -(TakeProfitPips*Point)),Digits);
//                             }
//                           else
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel+(MathAbs(LastPriceTargetLevel-StopLossLevel))),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel -(MathAbs(LastPriceTargetLevel-TakeProfitLevel))),Digits);
//                             }
//                           break;
//
//      case SELL_LIMIT:
//
//                           if(CalcSLTPbyPipsORDiff)
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel+(StopLossPips*Point)),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel -(TakeProfitPips*Point)),Digits);
//                             }
//                           else
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel+(MathAbs(LastPriceTargetLevel-StopLossLevel))),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel -(MathAbs(LastPriceTargetLevel-TakeProfitLevel))),Digits);
//                             }
//                           break;
//
//      case BUY_STOP:
//                           if(CalcSLTPbyPipsORDiff)
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel -(StopLossPips*Point)),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel+(TakeProfitPips*Point)),Digits);
//                             }
//                           else
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel -(MathAbs(LastPriceTargetLevel-StopLossLevel))),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel+(MathAbs(LastPriceTargetLevel-TakeProfitLevel))),Digits);
//                             }
//                           break;
//
//      case BUY_LIMIT:
//                           if(CalcSLTPbyPipsORDiff)
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel -(StopLossPips*Point)),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel+(TakeProfitPips*Point)),Digits);
//                             }
//                           else
//                             {
//                              StopLossLevel=RoundUp((PriceTargetLevel -(MathAbs(LastPriceTargetLevel-StopLossLevel))),Digits);
//                              TakeProfitLevel=RoundUp((PriceTargetLevel+(MathAbs(LastPriceTargetLevel-TakeProfitLevel))),Digits);
//                             }
//                           break;
//   }
//}


//  ===================================================================


void CalcSLTP(OrderTypes _ExecCommand)
  {
//  Changed all DOUBLEs to INTs

   int iPTL = 0;    // Price Target Level
   int iTTL = 0;    // Trailing Trigger Level

   int iBuff1 = 0;  // Stop Loss
   int iBuff2 = 0;  // Take Profit
   int iBuff3 = 0;  // Trailing Trigger
   int iBuff4 = 0;  // Trailing Tail

//   if(!(ObjectFind(objStopArrow)<0))
//      ObjectDelete(objStopArrow);
//
//   if(!(ObjectFind(objProfitArrow)<0))
//      ObjectDelete(objProfitArrow);
//
//   if(!(ObjectFind(objTTriggerArrow)<0))
//      ObjectDelete(objTTriggerArrow);
//
//   if(!(ObjectFind(objTTailArrow)<0))
//      ObjectDelete(objTTailArrow);

   iPTL=(int)(PriceTargetLevel/Point);


   switch(_ExecCommand)
     {
      case SELL_LIMIT:
      case SELL_STOP:

         //// 07222025 Print("SELL_LIMIT/SELL_STOP");
         //// 07222025 Print("StopLossLevel: " + StopLossLevel);
         
         iBuff1=(int)(iPTL+StopLossPips);
         StopLossLevel=iBuff1*Point;
         //// 07222025 Print("StopLossLevel: " + StopLossLevel);
         
         //// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);
         iBuff2=(int)(iPTL-TakeProfitPips);
         TakeProfitLevel=iBuff2*Point;
         //// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);
         
         //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
         iBuff3=(int)(iPTL-TrailingTriggerPips);
         TrailingTriggerLevel=iBuff3*Point;
         //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
         
         iTTL=(int)(TrailingTriggerLevel/Point);

         //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);
         iBuff4=(int)(iTTL+TrailingTailPips);
         TrailingTailLevel=iBuff4*Point;
         //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);
         
         break;

      case BUY_LIMIT:
      case BUY_STOP:

         //// 07222025 Print("BUY_LIMIT/BUY_STOP");
         //// 07222025 Print("StopLossLevel: " + StopLossLevel);
         
         iBuff1=(int)(iPTL-StopLossPips);
         StopLossLevel=iBuff1*Point;
         //// 07222025 Print("StopLossLevel: " + StopLossLevel);
         
         //// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);
         iBuff2=(int)(iPTL+TakeProfitPips);
         TakeProfitLevel=iBuff2*Point;
         //// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);

         //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
         iBuff3=(int)(iPTL+TrailingTriggerPips);
         TrailingTriggerLevel=iBuff3*Point;
         //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);

         iTTL=(int)(TrailingTriggerLevel/Point);

         //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);
         iBuff4=(int)(iTTL-TrailingTailPips);
         TrailingTailLevel=iBuff4*Point;
         //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);

         break;

     }

////// 07222025 Print("SL: " + StopLossLevel + "  TP: " + TakeProfitLevel);
  }


//  ===================================================================


void AdjustNewPriceTargetLevelPosition(uint flags)
  {

      if(ExecCommand==BUY_STOP)  // ======================================================================
      {
         //RefreshRates();
         //if(PriceTargetLevel<=(Ask+(PTBufferPips*Point)))  // Was Ask before
         
         // NO NEED TO CHECK LEVELS - Already checked above...
         if(PriceTargetLevel <= (MarketInfo(Symbol(),MODE_ASK)+(PTBufferPips*Point)))  // Was Ask before
         {
         

#ifdef _MOVE_TO_LAST_              
               PriceTargetLevel = LastPriceTargetLevel;
               DiffLevels = 0;
#endif 
 
#ifdef _MOVE_TO_SPREAD            
               //RefreshRates();
               //PriceTargetLevel = Ask + (PTBufferPips + 1) * Point;
               PriceTargetLevel = MarketInfo(Symbol(),MODE_ASK) + (PTBufferPips + 1) * Point;
               DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
#endif


#ifdef _DROP_SELECTION_               
            DropCurrentSelection();    
#endif       
         
         }
         
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
            ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
            // No need to MOVE as you are actually DRAGING it to its new location
            // Actually when you DROP the SELECTION you need to MOVE it!!!
            
            MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
            //DrawArrowEntry("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer);
            
            if(!MoveArrowEntry("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer))
            {
               DrawArrowEntry2("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer);
            }
            
            ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Ask,Digits)+Separator+ToEntry+DoubleToStr((PriceTargetLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips);         
            
//            if(DirFlipped && SpreadBreached)
//            {
//               //ReCalculate after DIRECTIONAL FLIP
//               CalcSLTP(ExecCommand);
//               
//            if(DrawStopLevel)
//               MoveHLine(objStopLossLevelLineName,
//                         StopLossLevel);
//         
//            if(DrawProfitLevel)
//               MoveHLine(objTakeProfitLevelLineName,
//                         TakeProfitLevel);
//         
//         #ifdef   _TrailingStop_
//            if(DrawTTriggerLevel)
//              {
//               MoveHLine(objTrailingTriggerLevelLineName,
//                         TrailingTriggerLevel);
//         
//               MoveHLine(objTrailingTailLevelLineName,
//                         TrailingTailLevel);
//              }
//         #endif
//            }
            
      }else
         if(ExecCommand==SELL_LIMIT)   // ======================================================================
         {
            //RefreshRates();
            //if(PriceTargetLevel<=(Ask+(PTBufferPips*Point)))  //  Was Bid before
            if(PriceTargetLevel<=(MarketInfo(Symbol(),MODE_ASK)+(PTBufferPips*Point)))  // Was Ask before
            {

#ifdef _MOVE_TO_LAST_              
               PriceTargetLevel = LastPriceTargetLevel;
               DiffLevels = 0; 
#endif  

#ifdef _MOVE_TO_SPREAD         
               //RefreshRates();     
               //PriceTargetLevel = Ask + (PTBufferPips + 1) * Point;
               PriceTargetLevel = MarketInfo(Symbol(),MODE_ASK) + (PTBufferPips + 1) * Point;
               DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
               
#endif

#ifdef _DROP_SELECTION_               
               DropCurrentSelection();
#endif             
           
           }
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
            ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
            // No need to MOVE as you are actually DRAGING it to its new location
            
            MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
            //DrawArrowEntry("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer);
            
            if(!MoveArrowEntry("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer))
                  {
                     DrawArrowEntry2("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer);
                  }   
            
            ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Bid,Digits)+Separator+ToEntry+DoubleToStr((PriceTargetLevel-Bid)/Point/_TicksPerPIP,1)+MeasurePips);
         }else
            if(ExecCommand==SELL_STOP) // ======================================================================
            {
               //RefreshRates();
               //if(PriceTargetLevel>=(Bid -(PTBufferPips*Point)))
               if(PriceTargetLevel >= (MarketInfo(Symbol(),MODE_BID) - (PTBufferPips*Point)))  // Was Ask before
               {
               

#ifdef _MOVE_TO_LAST_              
               PriceTargetLevel = LastPriceTargetLevel;
               DiffLevels = 0;
#endif  

#ifdef _MOVE_TO_SPREAD              
               //RefreshRates(); 
               //PriceTargetLevel = Bid - (PTBufferPips + 1) * Point;
               PriceTargetLevel = MarketInfo(Symbol(),MODE_BID) - (PTBufferPips + 1) * Point;
               DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
#endif

#ifdef _DROP_SELECTION_               
               DropCurrentSelection();
#endif             

             
              }
               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
               ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
               // No need to MOVE as you are actually DRAGING it to its new location
               
               MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
               //DrawArrowEntry("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer);
               
               if(!MoveArrowEntry("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer))
               {
                  DrawArrowEntry2("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer);
               }
               
               ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Bid,Digits)+Separator+ToEntry+DoubleToStr((Bid-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips);
            }else
               if(ExecCommand==BUY_LIMIT) // ======================================================================
               {
                  //RefreshRates();
                  //if(PriceTargetLevel>=(Bid -(PTBufferPips*Point))) //  Ask was before
                  if(PriceTargetLevel >= (MarketInfo(Symbol(),MODE_BID) - (PTBufferPips*Point)))  // Was Ask before
                  {
                  
#ifdef _MOVE_TO_LAST_              
               PriceTargetLevel = LastPriceTargetLevel;
               DiffLevels = 0; 
#endif  

#ifdef _MOVE_TO_SPREAD             
               //RefreshRates(); 
               //PriceTargetLevel = Bid - (PTBufferPips + 1) * Point;
               PriceTargetLevel = MarketInfo(Symbol(),MODE_BID) - (PTBufferPips + 1) * Point;
               DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
#endif

#ifdef _DROP_SELECTION_               
               DropCurrentSelection();
#endif     
                    
                 
                 }
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                  ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
                  // No need to MOVE as you are actually DRAGING it to its new location
                  
                  MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
                  //DrawArrowEntry("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer);
                  
                  if(!MoveArrowEntry("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer))
                  {
                        DrawArrowEntry2("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer);
                  }
                  
                  ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Ask,Digits)+Separator+ToEntry+DoubleToStr((Ask-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips);
                 }

   
   OriginalPriceTarget=PriceTargetLevel;

if(DiffLevels != 0)
{
   AdjustNewStopLossLevelPosition(PriceDir,DiffLevels);
   AdjustNewTakeProfitLevelPosition(PriceDir,DiffLevels);

#ifdef   _TrailingStop_

   if(DrawTTriggerLevel)
     {
      AdjustNewTrailingTriggerLevelPosition(PriceDir,DiffLevels);
     }
#endif
}
   
   ChartRedraw();
   
  }


// ==============================================================================================


void AdjustNewPriceTargetLevelPosition2(uint flags)
  {
            
   //LastPriceTargetLevel = PriceTargetLevel;
   //MarketRefPoints lPriceDir = PriceDir;
   
   //PriceTargetLevel = ObjectGetDouble(ChartID(),objPriceTargetLevelLineName,OBJPROP_PRICE, 0);
   //PriceTargetLevel = ObjectGet(objPriceTargetLevelLineName, OBJPROP_PRICE);
   
   //int j = 0;
   //while(!ObjectGetDouble(ChartID(), objPriceTargetLevelLineName, OBJPROP_PRICE, 0, PriceTargetLevel))
   //{
   //   j++;
   //   Sleep(100);
   //   // 07222025 Print(">>> " + IntegerToString(j) + "Can't GET PriceTargetLevel...");
   //}

   // No Change in location
   //if(PriceTargetLevel == LastPriceTargetLevel)
   //   return;
      
//PriceTargetLevel = RoundUp(ObjectGetDouble(ChartID(),objPriceTargetLevelLineName,OBJPROP_PRICE),Digits);

   //DiffLevels = (PriceTargetLevel - LastPriceTargetLevel);
   //// 07222025 Print("AdjustNewPriceTargetLevelPosition - DiffLevels: " + DoubleToString(DiffLevels));
   
   //if(DiffLevels==0)
   //   return;

   //  Release thread to update...
     //Sleep(10);

            
            
//         if(//(MarketInfo(Symbol(),MODE_BID) < PriceTargetLevel) 
//               //&&
//               (MarketInfo(Symbol(),MODE_ASK) <= PriceTargetLevel)
//               )
//               {
//                  PriceDir = ABOVE;
//                  AjustColorsAccordingToDir(PriceDir);
//                  
//                  if((PriceDir==ABOVE) && (ExecCommand==BUY_LIMIT))
//                  {
//                  if(FlipTargetLevel)
//                     ExecCommand=SELL_LIMIT;
//                  else
//                     ExecCommand=BUY_STOP;
//   
//                  DiffLevels=0;
//   
//                  }
//                  else
//                     if((PriceDir==ABOVE) && (ExecCommand==SELL_STOP))
//                       {
//                        if(FlipTargetLevel)
//                           ExecCommand=BUY_STOP;
//                        else
//                           ExecCommand=SELL_LIMIT;
//
//                        DiffLevels=0;
//                       }
//                }
//         else
//            if((MarketInfo(Symbol(),MODE_BID) >= PriceTargetLevel) 
//               //&&
//               //(MarketInfo(Symbol(),MODE_ASK) > PriceTargetLevel)
//               )
//               {
//                  PriceDir = BELOW;
//                  AjustColorsAccordingToDir(PriceDir);
//                  
//                  if((PriceDir==BELOW) && (ExecCommand==BUY_STOP))
//                  {
//                   if(FlipTargetLevel)
//                      ExecCommand=SELL_STOP;
//                   else
//                      ExecCommand=BUY_LIMIT;
//      
//                   DiffLevels=0;
//                  }
//                  else
//                     if((PriceDir==BELOW) && (ExecCommand==SELL_LIMIT))
//                       {
//                        if(FlipTargetLevel)
//                           ExecCommand=BUY_LIMIT;
//                        else
//                           ExecCommand=SELL_STOP;
//      
//                        DiffLevels=0;
//                        
//                       }
//                  
//               }
//            else
//               //if((MarketInfo(Symbol(),MODE_BID) < PriceTargetLevel) &&
//               //   (MarketInfo(Symbol(),MODE_ASK) > PriceTargetLevel))
//                 {
//                  //PriceDir = INSIDE;
//                  
//                  if(lPriceDir == BELOW)
//                     {
//                        PriceDir = BELOW;
//                        AjustColorsAccordingToDir(PriceDir);
//                        
//                        //PriceTargetLevel = MarketInfo(Symbol(),MODE_ASK);
//                        
//                        if(ExecCommand == BUY_LIMIT)
//                           if(FlipTargetLevel)
//                              ExecCommand=SELL_LIMIT;
//                           else
//                              ExecCommand=BUY_STOP;
//                              
//                        if(ExecCommand == SELL_STOP)
//                        if(FlipTargetLevel)
//                           ExecCommand=BUY_STOP;
//                        else
//                           ExecCommand=SELL_LIMIT;      
//                     }
//                  else if(lPriceDir == ABOVE)
//                     {
//                        PriceDir = ABOVE;
//                        AjustColorsAccordingToDir(PriceDir);
//                        
//                        //PriceTargetLevel = MarketInfo(Symbol(),MODE_BID);
//                        
//                        if(ExecCommand == SELL_LIMIT)
//                           if(FlipTargetLevel)
//                              ExecCommand=BUY_LIMIT;
//                           else
//                              ExecCommand=SELL_STOP;
//                              
//                        if(ExecCommand == BUY_STOP)
//                        if(FlipTargetLevel)
//                           ExecCommand=SELL_STOP;
//                        else
//                           ExecCommand=BUY_LIMIT;      
//                     }
//                 }



            if(DirFlipped)
            {
               //  ReCalculate after DIRECTIONAL FLIP
               CalcSLTP(ExecCommand);
               DrawALLLines();
               DrawAllArrows();
               DrawInitialPanel();
               ChartRedraw();
               
               DirFlipped = false;
               
            }
         
            
         if(
            //(PriceDir==ABOVE) && // With LEFT MOUSE DOWN & SHIFT DOWN...
            (ExecCommand==BUY_STOP))
           {
            // 07222025 Print("ExecCommand = " + EnumToString(ExecCommand));
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,EnumToString(PriceDir)+CurrentPosition);
            ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
            
            // You are MOVING it with the MOUSE...  No NEED to move it again!!!
            //MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
            //DrawArrowEntry
            if(!MoveArrowEntry("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer))
            {
               DrawArrowEntry2("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer);
               
            }
            
            //RefreshRates();
            //ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Ask,Digits)+Separator+ToEntry+DoubleToStr((PriceTargetLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips);
           }
         else
            if(
               //(PriceDir==BELOW) &&
               (ExecCommand==SELL_STOP))
              {
               // 07222025 Print("ExecCommand = " + EnumToString(ExecCommand));
               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,EnumToString(PriceDir)+CurrentPosition);
               ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
               
               // You are MOVING it with the MOUSE...  No NEED to move it again!!!
               // MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
               
               if(!MoveArrowEntry("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer))
               {
                  DrawArrowEntry2("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer);
               }
               
               //RefreshRates();
               //ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Bid,Digits)+Separator+ToEntry+DoubleToStr((Bid-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips);
              }
            else
               if(
                  //((PriceDir==ABOVE) || (PriceDir==INSIDE)) && // With LEFT MOUSE DOWN & SHIFT DOWN...
                  (ExecCommand==SELL_LIMIT))
                 {
                  // 07222025 Print("ExecCommand = " + EnumToString(ExecCommand));
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,EnumToString(PriceDir)+CurrentPosition);
                  ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
                  
                  // You are MOVING it with the MOUSE...  No NEED to move it again!!!
                  // MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
                  
                  if(!MoveArrowEntry("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer))
                  {
                     DrawArrowEntry2("DOWN_ARROW_TARGET","UP_ARROW_TARGET",PriceTargetLevel,ArrowDOWN,ArrowDOWNBackground,ANCHOR_TOP,ArrowDOWNColor,ArrowDOWNSize,ArrowDOWNOffsetHor,ArrowDOWNOffsetVer);
                  }                  
                  
                  //RefreshRates();
                  //ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Bid,Digits)+Separator+ToEntry+DoubleToStr((PriceTargetLevel-Bid)/Point/_TicksPerPIP,1)+MeasurePips);
                 }
               else
                  if(
                     //((PriceDir==BELOW) || (PriceDir==INSIDE)) &&
                     (ExecCommand==BUY_LIMIT))
                    {
                     // 07222025 Print("ExecCommand = " + EnumToString(ExecCommand));
                     ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,EnumToString(PriceDir)+CurrentPosition);
                     ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand));
                     
                     // You are MOVING it with the MOUSE...  No NEED to move it again!!!
                     // MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
                     
                     if(!MoveArrowEntry("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer))
                        DrawArrowEntry2("UP_ARROW_TARGET","DOWN_ARROW_TARGET",PriceTargetLevel,ArrowUP,ArrowUPBackground,ANCHOR_BOTTOM,ArrowUPColor,ArrowUPSize,ArrowUPOffsetHor,ArrowUPOffsetVer);
                     
                     
                     //RefreshRates();
                     //ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+DoubleToStr(Ask,Digits)+Separator+ToEntry+DoubleToStr((Ask-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips);
                    }
                    else
                    {
                     // 07222025 Print("ExecCommand = ERROR");
                     // 07222025 Print("ExecCommand = " + EnumToString(ExecCommand));
                    }
                    

   OriginalPriceTarget=PriceTargetLevel;

if(DiffLevels != 0)
{
   AdjustNewStopLossLevelPosition(PriceDir,DiffLevels);
   AdjustNewTakeProfitLevelPosition(PriceDir,DiffLevels);

#ifdef   _TrailingStop_

   if(DrawTTriggerLevel)
     {
      AdjustNewTrailingTriggerLevelPosition(PriceDir,DiffLevels);
     }
#endif
}
   
   //ChartRedraw();
   
  }


//  ===================================================================


void DropCurrentSelection()
{
   
   // UN-SELECT the LINE
   ObjectSet(objPriceTargetLevelLineName,OBJPROP_SELECTED,0);

   CurrentPosition=PositionPending;
   ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);

   if(OnHold)
      ToggleOnHold();

   PriceTargetLevelLineSELECTED = false;
   //// 07222025 Print("After Mouse Release - PriceTargetLevelLineSELECTED: " + IntegerToString(PriceTargetLevelLineSELECTED));
     
   FirstTickTarget = true;
   
//   if(DirFlipped && SpreadBreached)
//   {
//      //ReCalculate after DIRECTIONAL FLIP
//      CalcSLTP(ExecCommand);
//      DrawALLLines();
//      DrawAllArrows();
//      DrawInitialPanel();
//      
//      SpreadBreached = false;
//      DirFlipped = false;
//   }
   

//#ifdef _MOUSE_MOVE2_
//         while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
//            Sleep(100);
//#endif 

//   //  Get NEW PriceTargetLevel Location...
//   double ThisPriceTargetLevel;
//   int j = 0;
//   
//   while(!ObjectGetDouble(ChartID(), objPriceTargetLevelLineName, OBJPROP_PRICE, 0, ThisPriceTargetLevel))
//   {
//         j++;
//         Sleep(100);
//         // 07222025 Print(">>> " + IntegerToString(j) + "Can't GET PriceTargetLevel...");
//   }
//   
//   if(ThisPriceTargetLevel != PriceTargetLevel)
//      MoveHLine(objPriceTargetLevelLineName,PriceTargetLevel);
//
//   PriceDir = GetCurrentPriceDirection(PriceTargetLevel, false);
//   AjustColorsAccordingToDir(PriceDir);

//#ifdef _MOUSE_MOVE2_
//   while(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0))
//      Sleep(100);
//#endif

//   ExitNOW = true;
//   // 07222025 Print("ExitNOW SET to TRUE...");
//   
//   WindowRedraw();

}



//  ===================================================================

#ifdef   _TrailingStop_


void AdjustNewTrailingTailLevelPosition(MarketRefPoints _PriceDir)
  {

   double LastTrailingTailLevel = TrailingTailLevel;

//TrailingTailLevel = NormalizeDouble(ObjectGetDouble(ChartID(), objTrailingTailLevelLineName, OBJPROP_PRICE), Digits);
   TrailingTailLevel= AccuChop_ToFracNum(ObjectGetDouble(ChartID(),objTrailingTailLevelLineName,OBJPROP_PRICE));
   
   // No Change in location...
   if(TrailingTailLevel == LastTrailingTailLevel)
      return;
      
   TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);

   dRiskRewardTSRatio = TrailingTailPips/StopLossPips;
//// 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));

//OriginalTrailingTailPips = TrailingTailPips;
////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);

   RefreshRates();

   if((TrailingTailLevel<=(TrailingTriggerLevel -(TTailBufferPips*Point))) &&
      (TrailingTailLevel>=(StopLossLevel+(TTailBufferPips*Point))) &&
      ((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT)))
     {
      DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
      ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                 DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                 DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                 RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

      MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

     }
   else
      if(
         (TrailingTailLevel >= (TrailingTriggerLevel + (TTailBufferPips * Point))) &&
         (TrailingTailLevel <= (StopLossLevel - (TTailBufferPips * Point))) &&
         ((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
      )
        {
         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+                       
                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                    DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

        }
      else
        {
         TrailingTailLevel=LastTrailingTailLevel;

         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

         // BEFORE 03.10.2022 6:30pm
         //TrailingTailPips=MathAbs(TrailingTriggerLevel-TrailingTailLevel)/Point;  
         TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
         //OriginalTrailingTailPips = TrailingTailPips;
         ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);

         //return;
        }



#ifdef _MOVE_RR_RECTS_
   if(ShowTargetLayout && !(ObjectFind(objTargetLayoutMap)<0))
     {
      MoveTargetLayout();
      ////// 07222025 Print("<<< Layout MOVED... >>>");
     }
#endif

   //if(!OrderOpened)
   //  {
      //  Recalculate LOTS for Display purposes only...
      //if(AutoLotIncrease)
      //   Lots = CalcNewLotSize(AcumulatedFloatingLoss);
      //if(!RoundUpLots)
      //  {
      //   //Lots = NormalizeDouble((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
      //   Lots=NormalizeDouble(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
      //   ////// 07222025 Print("LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
      //  }
      //else
      //  {  //Lots = RoundUp((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
      //   Lots=RoundUp(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
      //   ////// 07222025 Print("RoundUp LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
      //  }

      //// 07222025 Print("New Calculated LOTS: " + Lots);

     
      UpdatePriceLevels();
      

      //ConvertSecondsToHHMMSS((uint)NormalizeDouble(MathAbs((GetTickCount()-LastStartTickTarget)/1000),0))+MeasureSec);
     //}

   return;
  }
#endif

//  ===================================================================

#ifdef   _TrailingStop_



void AdjustNewTrailingTriggerLevelPosition(MarketRefPoints _PriceDir)
  {

   double LastTrailingTriggerLevel = TrailingTriggerLevel;
   double LastTrailingTailLevel = TrailingTailLevel;

//TrailingTriggerLevel = NormalizeDouble(ObjectGetDouble(ChartID(), objTrailingTriggerLevelLineName, OBJPROP_PRICE), Digits);
   TrailingTriggerLevel = AccuChop_ToFracNum(ObjectGetDouble(ChartID(),objTrailingTriggerLevelLineName,OBJPROP_PRICE));

   // No change in location...
   if(LastTrailingTriggerLevel == TrailingTriggerLevel)
      return;
      
   
   if(MathAbs(TrailingTriggerLevel-PriceTargetLevel)<=0)
      TrailingTriggerLevel=LastTrailingTriggerLevel;
   else
     {
      double Diff = TrailingTriggerLevel - LastTrailingTriggerLevel;
      TrailingTailLevel=TrailingTailLevel+Diff;

      //TrailingTriggerPips  =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel), Digits)/Point);
      TrailingTriggerPips=MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point;
      TrailingTailPips = MathAbs(PriceTargetLevel-TrailingTailLevel)/Point;
      //  Should be UNCHANGED...
      //TrailingTailPips     =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - TrailingTailLevel), Digits)/Point);
     }

   dRiskRewardTTRatio = TrailingTriggerPips/StopLossPips;
//// 07222025 Print("dRiskRewardTTRatio: " + DoubleToString(dRiskRewardTTRatio));

   //dRiskRewardTSRatio = (TrailingTriggerPips-TrailingTailPips)/StopLossPips;
   //03.10.2022 6:37pm
   dRiskRewardTSRatio = TrailingTailPips / StopLossPips;
//// 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));

//   //// 07222025 Print("==============================================");

////// 07222025 Print("LastTrailingTailLevel: " + LastTrailingTailLevel);
////// 07222025 Print("LastDiff: " + NormalizeDouble(MathAbs(LastTrailingTriggerLevel - LastTrailingTailLevel),Digits));
////// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
////// 07222025 Print("NewDiff: " + MathAbs(LastTrailingTriggerLevel - TrailingTriggerLevel));
//
//   //// 07222025 Print("TrailingTailPips: " + TrailingTailPips);
//   //// 07222025 Print("Diff: " + DoubleToStr(NormalizeDouble(Diff, Digits),Digits));
//   //// 07222025 Print("LastTrailingTriggerLevel: " + LastTrailingTriggerLevel);
//   //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
//   //// 07222025 Print("LastTrailingTailLevel: " + LastTrailingTailLevel);
//   //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);
//   //// 07222025 Print("TrailingTriggerLevel - TrailingTailLevel = " + ((TrailingTriggerLevel - TrailingTailLevel)/Point) );
//
//   //// 07222025 Print("TrailingTriggerLevel - TrailingTailLevel = " + (int)(NormalizeDouble(TrailingTriggerLevel - TrailingTailLevel, Digits)/Point) );
//   //// 07222025 Print("TrailingTriggerLevel - TrailingTailLevel = " + TrailingTailPips );


   RefreshRates();
   if(OrderOpened)
     {
      if(DrawProfitLevel)
      {
      if((TrailingTriggerLevel <= (TakeProfitLevel - (TTriggerBufferPips * Point))) &&
         (TrailingTriggerLevel >= (Bid + (TTriggerBufferPips * Point))) &&
         ((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
        )
        {
         DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                         //DoubleToStr(((TrailingTriggerLevel - Bid)/Point/_TicksPerPIP),1) + MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
                         DoubleToStr(((TrailingTriggerLevel-PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                    DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

         MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
         //         OriginalTrailingTriggerPips = TrailingTriggerPips;
         //         //// 07222025 Print("1.  OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
         //
         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

         //         OriginalTrailingTailPips = TrailingTailPips;
         //         //// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
         //
        }
      else
         if(
            ((TrailingTriggerLevel >= (TakeProfitLevel + (TTriggerBufferPips * Point))) && DrawProfitLevel) &&
            (TrailingTriggerLevel <= (Ask - (TTriggerBufferPips * Point))) &&
            ((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
         )
           {
            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                            //DoubleToStr(((Ask - TrailingTriggerLevel)/Point/_TicksPerPIP),1) + MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
                            DoubleToStr(((PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
            //         OriginalTrailingTriggerPips = TrailingTriggerPips;
            //         //// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
            //
            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
           }
         else
           {
            TrailingTriggerLevel = LastTrailingTriggerLevel;
            TrailingTailLevel = LastTrailingTailLevel;

            //TrailingTriggerPips  =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel), Digits)/Point);
            TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);
            //  Should be UNCHANGED...
            //TrailingTailPips     =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - TrailingTailLevel), Digits)/Point);

            dRiskRewardTTRatio = TrailingTriggerPips/StopLossPips;
            //// 07222025 Print("dRiskRewardTTRatio: " + DoubleToString(dRiskRewardTTRatio));

            //  Should be UNCHANGED...
            //dRiskRewardTSRatio = ((double)((double)TrailingTriggerPips - (double)TrailingTailPips)) / (double)StopLossPips;
            ////// 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);

            //      OriginalTrailingTriggerPips = TrailingTriggerPips;
            //      //// 07222025 Print("1.  OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
            //
            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

            //      OriginalTrailingTailPips = TrailingTailPips;
            //      //// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
            //
            
            
            
            //return;
           }
           
           }
           else          
           // 05/01/2025
           if(
               (TrailingTriggerLevel >= (Bid + (TTriggerBufferPips * Point))) &&
               ((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
              )
        {
         DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                         //DoubleToStr(((TrailingTriggerLevel - Bid)/Point/_TicksPerPIP),1) + MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
                         DoubleToStr(((TrailingTriggerLevel-PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                    DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

         MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
         //         OriginalTrailingTriggerPips = TrailingTriggerPips;
         //         //// 07222025 Print("1.  OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
         //
         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

         //         OriginalTrailingTailPips = TrailingTailPips;
         //         //// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
         //
        }
      else
         if(
            (TrailingTriggerLevel <= (Ask - (TTriggerBufferPips * Point))) &&
            ((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
           )
           {
            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                            //DoubleToStr(((Ask - TrailingTriggerLevel)/Point/_TicksPerPIP),1) + MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
                            DoubleToStr(((PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
            //         OriginalTrailingTriggerPips = TrailingTriggerPips;
            //         //// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
            //
            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
           }
         else
           {
            TrailingTriggerLevel = LastTrailingTriggerLevel;
            TrailingTailLevel = LastTrailingTailLevel;

            //TrailingTriggerPips  =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel), Digits)/Point);
            TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);
            //  Should be UNCHANGED...
            //TrailingTailPips     =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - TrailingTailLevel), Digits)/Point);

            dRiskRewardTTRatio = TrailingTriggerPips/StopLossPips;
            //// 07222025 Print("dRiskRewardTTRatio: " + DoubleToString(dRiskRewardTTRatio));

            //  Should be UNCHANGED...
            //dRiskRewardTSRatio = ((double)((double)TrailingTriggerPips - (double)TrailingTailPips)) / (double)StopLossPips;
            ////// 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);

            //      OriginalTrailingTriggerPips = TrailingTriggerPips;
            //      //// 07222025 Print("1.  OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
            //
            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);

            //      OriginalTrailingTailPips = TrailingTailPips;
            //      //// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
            //
            
            
            
            //return;
           }
           
           
           
           
           UpdatePriceLevels();

     }
   else // IF !OrderOpened
     {
      if(DrawProfitLevel)
      {
      if(
         ((TrailingTriggerLevel <= (TakeProfitLevel - (TTriggerBufferPips * Point))) && DrawProfitLevel) &&
         (TrailingTriggerLevel >= (PriceTargetLevel + (TTriggerBufferPips * Point))) &&
         ((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
        )
        {
         DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                         DoubleToStr(((TrailingTriggerLevel-PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                    DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

         MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
         //         OriginalTrailingTriggerPips = TrailingTriggerPips;
         //         //// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
         //
         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
         //OriginalTrailingTailPips = TrailingTailPips;
         ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
        }
      else
         if(
            ((TrailingTriggerLevel >= (TakeProfitLevel + (TTriggerBufferPips * Point))) && DrawProfitLevel) &&
            (TrailingTriggerLevel <= (PriceTargetLevel - (TTriggerBufferPips * Point))) &&
            ((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
         )
           {
            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                                                                          DoubleToStr(((PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                          RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
            //OriginalTrailingTriggerPips = TrailingTriggerPips;
            ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
           }
         else
           {
            TrailingTriggerLevel=LastTrailingTriggerLevel;
            TrailingTailLevel=LastTrailingTailLevel;

            //TrailingTriggerPips  =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel), Digits)/Point);
            TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);

            //  Should be UNCHANGED...
            //TrailingTailPips     =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - TrailingTailLevel), Digits)/Point);

            dRiskRewardTTRatio = TrailingTriggerPips/StopLossPips;
            //// 07222025 Print("dRiskRewardTTRatio: " + DoubleToString(dRiskRewardTTRatio));

            //  Should be UNCHANGED...
            //dRiskRewardTSRatio = ((double)((double)TrailingTriggerPips - (double)TrailingTailPips)) / (double)StopLossPips;
            ////// 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);

            //OriginalTrailingTriggerPips = TrailingTriggerPips;
            ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);

            //return;
           }
         }
         else
         if(
            (TrailingTriggerLevel >= (PriceTargetLevel + (TTriggerBufferPips * Point))) &&
            ((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
           )
        {
         DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                         DoubleToStr(((TrailingTriggerLevel-PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                    DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

         MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
         //         OriginalTrailingTriggerPips = TrailingTriggerPips;
         //         //// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
         //
         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
         //OriginalTrailingTailPips = TrailingTailPips;
         ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
        }
      else
         if(
            (TrailingTriggerLevel <= (PriceTargetLevel - (TTriggerBufferPips * Point))) &&
            ((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
         )
           {
            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                                                                          DoubleToStr(((PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                          RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
            //OriginalTrailingTriggerPips = TrailingTriggerPips;
            ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
           }
         else
           {
            TrailingTriggerLevel=LastTrailingTriggerLevel;
            TrailingTailLevel=LastTrailingTailLevel;

            //TrailingTriggerPips  =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel), Digits)/Point);
            TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);

            //  Should be UNCHANGED...
            //TrailingTailPips     =  (int)(NormalizeDouble(MathAbs(TrailingTriggerLevel - TrailingTailLevel), Digits)/Point);

            dRiskRewardTTRatio = TrailingTriggerPips/StopLossPips;
            //// 07222025 Print("dRiskRewardTTRatio: " + DoubleToString(dRiskRewardTTRatio));

            //  Should be UNCHANGED...
            //dRiskRewardTSRatio = ((double)((double)TrailingTriggerPips - (double)TrailingTailPips)) / (double)StopLossPips;
            ////// 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);

            //OriginalTrailingTriggerPips = TrailingTriggerPips;
            ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);

            //return;
           }

      //  Recalculate LOTS for Display purposes only...
      //if(AutoLotIncrease)
      //   Lots = CalcNewLotSize(AcumulatedFloatingLoss);
      //if(!RoundUpLots)
      //  {
      //   //Lots = NormalizeDouble((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
      //   Lots=NormalizeDouble(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
      //   ////// 07222025 Print("LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
      //  }
      //else
      //  {  //Lots = RoundUp((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
      //   Lots=RoundUp(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
      //   ////// 07222025 Print("RoundUp LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
      //  }
          

      UpdatePriceLevels();
      
      //ConvertSecondsToHHMMSS((uint)NormalizeDouble(MathAbs((GetTickCount()-LastStartTickTarget)/1000),0))+MeasureSec);

      // return;
     }

#ifdef _MOVE_RR_RECTS_
   if(ShowTargetLayout && !(ObjectFind(objTargetLayoutMap)<0))
     {
      MoveTargetLayout();
      ////// 07222025 Print("<<< Layout MOVED... >>>");
     }
#endif

   return;

  }
  
#endif

//  ===================================================================

#ifdef   _TrailingStop_


void AdjustNewTrailingTriggerLevelPosition(MarketRefPoints _PriceDir, double Diff)
  {

   double LastTTriggerLevel      = TrailingTriggerLevel;
   double LastTrailingTailLevel  = TrailingTailLevel;

   if(Diff != 0)
     {
      TrailingTriggerLevel = TrailingTriggerLevel  + Diff;
      TrailingTailLevel    = TrailingTailLevel     + Diff;
//
//      TrailingTriggerPips  =  MathAbs(TrailingTriggerLevel - PriceTargetLevel) / Point;
//      TrailingTailPips     =  MathAbs(TrailingTriggerLevel - TrailingTailLevel) / Point;
     }
   else
      return;


//// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
//// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);
//// 07222025 Print("TrailingTriggerLevel - TrailingTailLevel = " + (TrailingTriggerLevel - TrailingTailLevel) );
//// 07222025 Print("TrailingTriggerLevel - TrailingTailLevel = " + (TrailingTriggerLevel - TrailingTailLevel) );

//// 07222025 Print("PriceDir: " + EnumToString(PriceDir) + " ExecCommand: " + EnumToString(ExecCommand));

   RefreshRates();

   if(OrderOpened)
     {
      //// 07222025 Print("AdjustNewTrailingTriggerLevelPosition: HAVING A PROBLEM...");
     }
   else     //  IF !OrderOpen
     {
      if(
         (ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
        {
         //// 07222025 Print("ExecCommand==BUY***");
         MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
         DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                         //DoubleToStr(((TrailingTriggerLevel-PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips+
                         DoubleToStr(TrailingTriggerPips/_TicksPerPIP,1)+MeasurePips+
                         Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

         MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                    DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

         
         //OriginalTrailingTriggerPips = TrailingTriggerPips;
         ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

         
         //OriginalTrailingTailPips = TrailingTailPips;
         ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
        }
      else
         if(
            (ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
           {
            //// 07222025 Print("ExecCommand==SELL***");
            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                            //DoubleToStr(((PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+
                            DoubleToStr(TrailingTriggerPips/_TicksPerPIP,1)+MeasurePips+
                            Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

            //OriginalTrailingTriggerPips = TrailingTriggerPips;
            ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

            
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
           }
         else
           {
            TrailingTriggerLevel=LastTTriggerLevel;
            TrailingTailLevel=LastTrailingTailLevel;

            return;
           }
     }

   UpdatePriceLevels();
   
   return;

  }
  
#endif


//  ===================================================================


void AdjustNewStopLossLevelPosition(MarketRefPoints _PriceDir)
  {

   double LastStopLossLevel=StopLossLevel;

//StopLossLevel=NormalizeDouble(ObjectGetDouble(ChartID(),objStopLossLevelLineName,OBJPROP_PRICE),Digits);

   StopLossLevel = AccuChop_ToFracNum(ObjectGetDouble(ChartID(),objStopLossLevelLineName,OBJPROP_PRICE));

   // No Change in location -> no move...
   if(LastStopLossLevel == StopLossLevel)
      return;
      
   StopLossPips = NormalizeDouble(MathAbs(PriceTargetLevel-StopLossLevel)/Point, 0);

//OriginalStopLossPips = StopLossPips;

//// 07222025 Print("LastStopLossLevel="+LastStopLossLevel);
//// 07222025 Print("StopLossLevel="+StopLossLevel);
//// 07222025 Print("StopLossPips="+StopLossPips);
//// 07222025 Print("OriginalStopLossPips: " + OriginalStopLossPips);


   RefreshRates();
   if(OrderOpened)
     {

      if(
         (StopLossLevel<=(Bid -(SLBufferPips*Point))) && //  Limit movement to spread
         (ExecCommand==BUY_STOP)
      )
        {
         MoveHLine(objStopLossLevelLineName,StopLossLevel);
         DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_TOP,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
         ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
        }
      else
         if(
            (StopLossLevel>=(Ask+(SLBufferPips*Point))) &&
            (ExecCommand==SELL_STOP)
         )
           {
            MoveHLine(objStopLossLevelLineName,StopLossLevel);
            DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
            ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                   DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
           }
         else
            if(
               (StopLossLevel<=(Bid -(SLBufferPips*Point))) && //  Limit movement to spread
               (ExecCommand==BUY_LIMIT)
            )
              {
               MoveHLine(objStopLossLevelLineName,StopLossLevel);
               DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_TOP,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
               ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                      DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
              }
            else
               if(
                  (StopLossLevel>=(Ask+(SLBufferPips*Point))) &&
                  (ExecCommand==SELL_LIMIT)
               )
                 {
                  MoveHLine(objStopLossLevelLineName,StopLossLevel);
                  DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                  ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                         DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                 }
               else
                 {
                  //// 07222025 Print("PriceTargetLevel >= StopLossLevel && ExecCommand == BUY_LIMIT ->>> " + DoubleToStr(PriceTargetLevel) + " " + DoubleToStr(StopLossLevel) + " " + EnumToString(ExecCommand));
                  StopLossLevel=LastStopLossLevel;
                  StopLossPips = NormalizeDouble(MathAbs(PriceTargetLevel - StopLossLevel) / Point,0);
                  //OriginalStopLossPips = StopLossPips;
                  //// 07222025 Print("1. Restore OriginalStopLossPips: " + OriginalStopLossPips + "   ExecCommand: " + EnumToString(ExecCommand));

                  MoveHLine(objStopLossLevelLineName,StopLossLevel);

                  return;
                 }

#ifdef _MOVE_RR_RECTS_
      if(ShowRiskLayout && !(ObjectFind(objRiskLayoutMap)<0))
        {
         MoveRiskLayout();
         ////// 07222025 Print("<<< Layout MOVED... >>>");
        }
#endif

     }
   else // IF !OrderOpened
     {
      if(
         (StopLossLevel<=(PriceTargetLevel -(SLBufferPips*Point))) &&
         (ExecCommand==BUY_STOP)
      )
        {
         MoveHLine(objStopLossLevelLineName,StopLossLevel);
         DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_TOP,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
         ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
        }
      else
         if(
            (StopLossLevel>=(PriceTargetLevel+(SLBufferPips*Point))) &&
            (ExecCommand==SELL_STOP)
         )
           {
            MoveHLine(objStopLossLevelLineName,StopLossLevel);
            DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
            ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                   DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
           }
         else
            if(
               // Limit movement to ENTRY Point
               (StopLossLevel<=(PriceTargetLevel -(SLBufferPips*Point))) &&
               (ExecCommand==BUY_LIMIT)
            )
              {
               MoveHLine(objStopLossLevelLineName,StopLossLevel);
               DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_TOP,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
               ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                      DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
              }
            else
               if(
                  (StopLossLevel>=(PriceTargetLevel+(SLBufferPips*Point))) &&
                  (ExecCommand==SELL_LIMIT))
                 {
                  MoveHLine(objStopLossLevelLineName,StopLossLevel);
                  DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                  ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                         DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                 }
               else
                 {
                  //// 07222025 Print("PriceTargetLevel >= StopLossLevel && ExecCommand == BUY_LIMIT ->>> " + DoubleToStr(PriceTargetLevel) + " " + DoubleToStr(StopLossLevel) + " " + EnumToString(ExecCommand));
                  StopLossLevel=LastStopLossLevel;
                  StopLossPips = NormalizeDouble(MathAbs(PriceTargetLevel - StopLossLevel) / Point, 0);
                  //OriginalStopLossPips = StopLossPips;
                  //// 07222025 Print("2. Restore OriginalStopLossPips: " + OriginalStopLossPips + "   ExecCommand: " + EnumToString(ExecCommand));

                  MoveHLine(objStopLossLevelLineName,StopLossLevel);

                  return;
                 }
     }

//  Risk & Reward - Derive Take Profit calculation based on current Stop Loss position
//  ONLY prior to OPENING the POSITION
//  After that STOP LOSS is DETACHED thus available for PROFIT PROTECTION by moving it ABOVE/BELOW Entry Point - Equivalent to hitting Trailing Trigger BUT by means of MOVING SL accordingly
   if(
//UseRiskReward
//&&
//  When Orden NOT Opened
      !OrderOpened
      &&
//   When AspectRatio = TRUE
      ButtonIsPressed
   )
     {

      if(KeepOriginalRRRatios)
        {
         string result1[];
         string result2[];
         string result3[];

         
         int k1=StringSplit(RiskRewardTPRatio,FRACTION_SEPARATOR,result1);
         int k2=StringSplit(RiskRewardTTRatio,FRACTION_SEPARATOR,result2);
         int k3=StringSplit(RiskRewardTSRatio,FRACTION_SEPARATOR,result3);

         //// 07222025 Print("INSIDE SL CONTROLLED TP/TT/TS");

         //// 07222025 Print("TakeProfitPips: " + TakeProfitPips);
         TakeProfitPips=EvaluateDivisionExpression(result1[1]) * StopLossPips;
         
         
#ifdef   _TrailingStop_
         if(DrawTTriggerLevel)
           {
            //// 07222025 Print("TrailingTriggerPips: " + TrailingTriggerPips);
            TrailingTriggerPips = StringToDouble(result2[1]) * StopLossPips;

            //// 07222025 Print("TrailingTailPips: " + TrailingTailPips);
            TrailingTailPips = StringToDouble(result3[1]) * StopLossPips;
            //TrailingTailPips = TrailingTriggerPips - TrailingTailPips;         01/11/2022
           }
#endif
        }
      else
        {
         //// 07222025 Print("INSIDE SL CONTROLLED TP/TT/TS");
         //// 07222025 Print("TAKEPROFIT / STOPLOSS: " + DoubleToString(dRiskRewardTPRatio));

#ifdef   _TrailingStop_
         if(DrawTTriggerLevel)
           {
            //// 07222025 Print("TRAILING-TRIGGER / STOPLOSS: " + DoubleToString(dRiskRewardTTRatio));
            //// 07222025 Print("TRAILING-STOP / STOPLOSS: " + DoubleToString(dRiskRewardTSRatio));
           }
#endif

         TakeProfitPips = NormalizeDouble(dRiskRewardTPRatio * StopLossPips, 0);
         dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         //// 07222025 Print("TAKE_PROFIT_PIPS: " + TakeProfitPips);

#ifdef   _TrailingStop_
         if(DrawTTriggerLevel)
           {
            TrailingTriggerPips= NormalizeDouble(dRiskRewardTTRatio * StopLossPips, 0);
            dRiskRewardTTRatio = TrailingTriggerPips/StopLossPips;
            //// 07222025 Print("TrailingTriggerPips: " + TrailingTriggerPips);

            TrailingTailPips = NormalizeDouble(dRiskRewardTSRatio * StopLossPips, 0);
            //19.10.2022 4:42pm
            //TrailingTailPips = TrailingTriggerPips - TrailingTailPips;
            dRiskRewardTSRatio= TrailingTailPips/StopLossPips;
            //// 07222025 Print("TrailingTailPips: " + TrailingTailPips);
           }
#endif
        }


      if((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
        {
         //// 07222025 Print("TakeProfit Level" + TakeProfitLevel);
         //TakeProfitLevel = NormalizeDouble(PriceTargetLevel, Digits) + NormalizeDouble(TakeProfitPips * Point, Digits);
         //TakeProfitLevel=NormalizeDouble(TakeProfitLevel, Digits);
         TakeProfitLevel=((PriceTargetLevel/Point)+TakeProfitPips)*Point;
         //// 07222025 Print("NEW TakeProfit Level" + TakeProfitLevel);

         //TrailingTriggerLevel=NormalizeDouble(PriceTargetLevel, Digits)+NormalizeDouble(TrailingTriggerPips*Point,Digits);
         //TrailingTriggerLevel=NormalizeDouble(TrailingTriggerLevel, Digits);
         TrailingTriggerLevel=((PriceTargetLevel/Point)+TrailingTriggerPips)*Point;

         //TrailingTailLevel=NormalizeDouble(TrailingTriggerLevel, Digits)-NormalizeDouble(TrailingTailPips*Point,Digits);
         //TrailingTailLevel=NormalizeDouble(TrailingTailLevel, Digits);
         //  19.10.2022 4:42pm
         TrailingTailLevel=((PriceTargetLevel/Point)+TrailingTailPips)*Point;

         //            if(TakeProfitPips < TrailingTriggerPips)
         //            {
         //               TrailingTriggerPips = TakeProfitPips - TTriggerBufferPips;
         //
         //               TrailingTriggerLevel=NormalizeDouble(PriceTargetLevel, Digits)+NormalizeDouble(TrailingTriggerPips*Point,Digits);
         //               TrailingTriggerLevel=NormalizeDouble(TrailingTriggerLevel, Digits);
         //
         //               TrailingTailLevel=NormalizeDouble(TrailingTriggerLevel, Digits)-NormalizeDouble(TrailingTailPips*Point,Digits);
         //               TrailingTailLevel=NormalizeDouble(TrailingTailLevel, Digits);
         //            }
        }
      else
         if((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
           {
            //TakeProfitLevel=NormalizeDouble(PriceTargetLevel, Digits) - NormalizeDouble(TakeProfitPips*Point,Digits);
            //TakeProfitLevel=NormalizeDouble(TakeProfitLevel, Digits);
            TakeProfitLevel=((PriceTargetLevel/Point)-TakeProfitPips)*Point;

            //TrailingTriggerLevel=NormalizeDouble(PriceTargetLevel, Digits)-NormalizeDouble(TrailingTriggerPips*Point,Digits);
            //TrailingTriggerLevel=NormalizeDouble(TrailingTriggerLevel, Digits);
            TrailingTriggerLevel=((PriceTargetLevel/Point)-TrailingTriggerPips)*Point;

            //TrailingTailLevel=NormalizeDouble(TrailingTriggerLevel, Digits)+NormalizeDouble(TrailingTailPips*Point,Digits);
            //TrailingTailLevel=NormalizeDouble(TrailingTailLevel, Digits);
            //  19.10.2022 4:42pm
            TrailingTailLevel=((PriceTargetLevel/Point) - TrailingTailPips)*Point;

            //            if(TakeProfitPips < TrailingTriggerPips)
            //            {
            //               TrailingTriggerPips = TakeProfitPips - TTriggerBufferPips;
            //
            //               TrailingTriggerLevel=NormalizeDouble(PriceTargetLevel, Digits)-NormalizeDouble(TrailingTriggerPips*Point,Digits);
            //               TrailingTriggerLevel=NormalizeDouble(TrailingTriggerLevel, Digits);
            //
            //               TrailingTailLevel=NormalizeDouble(TrailingTriggerLevel, Digits)+NormalizeDouble(TrailingTailPips*Point,Digits);
            //               TrailingTailLevel=NormalizeDouble(TrailingTailLevel, Digits);
            //            }
           }

      ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                      DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                      RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));

#ifdef   _TrailingStop_
      if(DrawTTriggerLevel)
        {
         ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                         DoubleToStr((MathAbs(PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

         ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                         DoubleToStr(((MathAbs(TrailingTailLevel-PriceTargetLevel))/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         DoubleToStr((MathAbs(TrailingTriggerLevel-TrailingTailLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));
        }
#endif

      //  Re-Draw Lines to reposition new TP...
      if(!ObjectMove(ChartID(),
                     objProfitArrow,
                     0,
                     (datetime)(TimeCurrent()+(ProfitArrowOffsetHor*Period()*60)),
                     TakeProfitLevel+ProfitArrowOffsetVer))
        {
         //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
        }

#ifdef   _TrailingStop_
      if(DrawTTriggerLevel)
        {
         if(!ObjectMove(ChartID(),
                        objTTriggerArrow,
                        0,
                        (datetime)(TimeCurrent()+(TTriggerArrowOffsetHor*Period()*60)),
                        TrailingTriggerLevel+TTriggerArrowOffsetVer))
           {
            //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
           }

         if(!ObjectMove(ChartID(),
                        objTTailArrow,
                        0,
                        (datetime)(TimeCurrent()+(TTailArrowOffsetHor*Period()*60)),
                        TrailingTailLevel+TTailArrowOffsetVer))
           {
            //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
           }
        }
#endif

      MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
      TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel-TakeProfitLevel)/Point, 0);
      
      //      OriginalTakeProfitPips  = TakeProfitPips;
      //      //// 07222025 Print("OriginalTakeProfitPips: " + OriginalTakeProfitPips);
      //
#ifdef   _TrailingStop_
      if(DrawTTriggerLevel)
        {
         TrailingTriggerPips  =  NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel) / Point, 0);
         //  19.10.2022   5:02pm
         TrailingTailPips     =  NormalizeDouble(MathAbs(PriceTargetLevel - TrailingTailLevel) / Point, 0);

         MoveHLine(objTrailingTriggerLevelLineName, TrailingTriggerLevel);
         //      OriginalTrailingTriggerPips = TrailingTriggerPips;
         //      //// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);
         //
         MoveHLine(objTrailingTailLevelLineName, TrailingTailLevel);
         //      OriginalTrailingTailPips = TrailingTailPips;
         //      //// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
         //
        }
#endif

         //  NEW 05.09.2024
         UpdatePriceLevels();
                     
     }
   else
     {
      if(OrderOpened && ButtonIsPressed)
        {
         ButtonIsPressed=false;
         ReleasePushButtonUP();
        }

      //  AspectRatio = FALSE
      //  When OrderOpened...  Recalculate ratios without moving actual lines
      if(StopLossPips>0)
        {
         dRiskRewardTPRatio = TakeProfitPips/StopLossPips;

#ifdef   _TrailingStop_
         if(DrawTTriggerLevel)
           {
            dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
            //  19.10.2022  5:05pm
            dRiskRewardTSRatio = TrailingTailPips / StopLossPips;
           }
#endif

         ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                         DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                         RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));

#ifdef   _TrailingStop_
         if(DrawTTriggerLevel)
           {
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                            DoubleToStr((MathAbs(PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                            DoubleToStr(((MathAbs(TrailingTailLevel-PriceTargetLevel))/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            DoubleToStr((MathAbs(TrailingTriggerLevel-TrailingTailLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));
           }
#endif

        }
     }

#ifdef   _TrailingStop_
   if(TTriggerActivated)
      if(DrawTTriggerLevel)
        {
         RefreshRates();

         if((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
           {

            //TrailingTailPips=MathAbs((Bid-StopLossLevel)/Point);
            TrailingStopPips = MathAbs((Bid-StopLossLevel)/Point);
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(TrailingStopPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       "ACTIVATED");

           }
         else
            if((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
              {

               //TrailingTailPips=MathAbs((Ask-StopLossLevel)/Point);
               TrailingStopPips = MathAbs((Ask-StopLossLevel)/Point);
               ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                          DoubleToStr(MathAbs(StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                          DoubleToStr(TrailingStopPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                          "ACTIVATED");
              }
        }
#endif

// Get into Tracking Mode if you move SL in Profit Protection Position

#ifdef   _TrailingStop_
   if(DrawTTriggerLevel)
      if(
         //!TTriggerActivated &&
         ((ExecCommand==BUY_LIMIT) || (ExecCommand==BUY_STOP))
         &&
         (StopLossLevel>PriceTargetLevel)) //  SELL STOP is a Profit PROTECTING STOP
        {

         //OriginalStopLossPips = BuffOriginalStopLossPips;
         ////// 07222025 Print("OriginalStopLossPips: "+OriginalStopLossPips);

         if(DrawTTriggerLevel)
           {
            if(!TTriggerActivated)
               TTriggerActivated=true;        //  Flag will be checked inside STOP LOSS HEADER -> To be RESET to FALSE in ReInitialize

            RefreshRates();
            TrailingTriggerLevel = Bid;
            TrailingTriggerPips  =  NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel) / Point, 0);

            TrailingTailLevel = StopLossLevel;
            TrailingTailPips  = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
            TrailingStopPips  = MathAbs((Bid-TrailingTailLevel)/Point);
            
            
            if(DrawTTriggerLevel)
            {
               ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                               DoubleToStr((MathAbs(PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
   
               ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                               DoubleToStr(((MathAbs(TrailingTailLevel-PriceTargetLevel))/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                               DoubleToStr((MathAbs(TrailingTailLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                               RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));
   
               if(!ObjectMove(ChartID(),
                              objTTriggerArrow,
                              0,
                              (datetime)(TimeCurrent()+(TTriggerArrowOffsetHor*Period()*60)),
                              TrailingTriggerLevel+TTriggerArrowOffsetVer))
                 {
                  //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
                 }
   
               if(!ObjectMove(ChartID(),
                              objTTailArrow,
                              0,
                              (datetime)(TimeCurrent()+(TTailArrowOffsetHor*Period()*60)),
                              TrailingTailLevel+TTailArrowOffsetVer))
                 {
                  //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
                 }
   
               MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
               MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
             }

            //ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(TrailingTriggerLevel,Digits)+Separator+"ACTIVATED");
            //ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT, "<<<ACTIVATED>>>");
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(TrailingTriggerLevel,Digits)+Separator+"ACTIVATED");
            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                       DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                       DoubleToStr(TrailingStopPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                       "ACTIVATED");

//              Remove Trailing Levels as they are no longer needed
//            if(!(ObjectFind(objTTriggerArrow)<0))
//               ObjectDelete(objTTriggerArrow);
//
//            if(!(ObjectFind(objTTailArrow)<0))
//               ObjectDelete(objTTailArrow);
//
//            if(!(ObjectFind(objTrailingTriggerLevelLineName)<0))
//               ObjectDelete(objTrailingTriggerLevelLineName);
//
//            if(!(ObjectFind(objTrailingTailLevelLineName)<0))
//               ObjectDelete(objTrailingTailLevelLineName);

            ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,BIDPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                   DoubleToStr(Bid,Digits)+Separator+ToStopLoss+
                                                                   DoubleToStr((Bid-StopLossLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+" PROT: "+
                                                                   DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                            
            UpdatePriceLevels();
            WindowRedraw();

           }
        }
      else
         if(
            //!TTriggerActivated &&
            ((ExecCommand==SELL_LIMIT) || (ExecCommand==SELL_STOP))
            &&
            (StopLossLevel<PriceTargetLevel)) //  SELL STOP is a Profit PROTECTING STOP
           {

            //     OriginalStopLossPips = BuffOriginalStopLossPips;

            if(DrawTTriggerLevel)
              {
               if(!TTriggerActivated)
                  TTriggerActivated=true;        //  Flag will be checked inside STOP LOSS HEADER -> To be RESET to FALSE in ReInitialize

               RefreshRates();
               TrailingTriggerLevel =  Ask;
               TrailingTriggerPips  =  NormalizeDouble(MathAbs(TrailingTriggerLevel - PriceTargetLevel) / Point, 0);

               TrailingTailLevel = StopLossLevel;
               TrailingTailPips  = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
               TrailingStopPips  = MathAbs((Ask-StopLossLevel)/Point);
               
                if(DrawTTriggerLevel)
                {
                  ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                                  DoubleToStr((MathAbs(PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
      
                  ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                  DoubleToStr(((MathAbs(TrailingTailLevel-PriceTargetLevel))/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                  DoubleToStr((MathAbs(TrailingTailLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                  RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));
      
                  if(!ObjectMove(ChartID(),
                                 objTTriggerArrow,
                                 0,
                                 (datetime)(TimeCurrent()+(TTriggerArrowOffsetHor*Period()*60)),
                                 TrailingTriggerLevel+TTriggerArrowOffsetVer))
                    {
                     //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
                    }
      
                  if(!ObjectMove(ChartID(),
                                 objTTailArrow,
                                 0,
                                 (datetime)(TimeCurrent()+(TTailArrowOffsetHor*Period()*60)),
                                 TrailingTailLevel+TTailArrowOffsetVer))
                    {
                     //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
                    }
      
                  MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
                  MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
                 }


               ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(TrailingTriggerLevel,Digits)+Separator+"ACTIVATED");
               ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                          DoubleToStr(MathAbs(StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                          DoubleToStr(TrailingStopPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                          "ACTIVATED");

//               //  Remove Trailing Levels as they are no longer needed
//               if(!(ObjectFind(objTTriggerArrow)<0))
//                  ObjectDelete(objTTriggerArrow);
//
//               if(!(ObjectFind(objTTailArrow)<0))
//                  ObjectDelete(objTTailArrow);
//
//               if(!(ObjectFind(objTrailingTriggerLevelLineName)<0))
//                  ObjectDelete(objTrailingTriggerLevelLineName);
//
//               if(!(ObjectFind(objTrailingTailLevelLineName)<0))
//                  ObjectDelete(objTrailingTailLevelLineName);

               ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                      DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                                                                      DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+" PROT: "+
                                                                      DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                               
                  UpdatePriceLevels();
                  WindowRedraw();

              }
           }
#endif
   

   return;
  }


//  ===================================================================


void AdjustNewStopLossLevelPosition(MarketRefPoints _PriceDir, double Diff)
  {
   double LastStopLossLevel = StopLossLevel;

   //// 07222025 Print("AdjustNewStopLossLevelPosition - Diff: " + Diff);
   
   if(Diff !=0 )
     {
      StopLossLevel = StopLossLevel + Diff;
     }
   else
      return;

   RefreshRates();
   if(OrderOpened)
     {
      //// 07222025 Print("AdjustNewStopLossLevelPosition: HAVING A PROBLEM...");
      return;
     }
   else
     {
      if(
         (ExecCommand==BUY_STOP))
        {
         MoveHLine(objStopLossLevelLineName,StopLossLevel);
         DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_TOP,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
         ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                //DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips
                                                                DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);
                                                                
        }
      else
         if(
            (ExecCommand==SELL_STOP))
           {
            MoveHLine(objStopLossLevelLineName,StopLossLevel);
            DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
            ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                   //DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                                                                   DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);
           }
         else
            if(
               (ExecCommand==BUY_LIMIT))
              {
               MoveHLine(objStopLossLevelLineName,StopLossLevel);
               DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_TOP,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
               ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                      //DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                                                                      DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);
              }
            else
               if(
                  (ExecCommand==SELL_LIMIT))
                 {
                  MoveHLine(objStopLossLevelLineName,StopLossLevel);
                  DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                  ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                         //DoubleToStr((MathAbs(PriceTargetLevel-StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                                                                         DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);
                 }
               else
                 {
                  StopLossLevel=LastStopLossLevel;
                  return;
                 }
     }

   
   return;

  }


//  ===================================================================


void AdjustNewTakeProfitLevelPosition(MarketRefPoints _PriceDir)
  {

   double LastTakeProfitLevel=TakeProfitLevel;

//TakeProfitLevel=NormalizeDouble(ObjectGetDouble(ChartID(), objTakeProfitLevelLineName, OBJPROP_PRICE), Digits);
   TakeProfitLevel = AccuChop_ToFracNum(ObjectGetDouble(ChartID(),objTakeProfitLevelLineName,OBJPROP_PRICE));
   
   // No change in location -> no move...
   if(LastTakeProfitLevel == TakeProfitLevel)
      return;


   if(MathAbs(PriceTargetLevel-TakeProfitLevel)<=0)
      TakeProfitLevel = LastTakeProfitLevel;
   else
     {
      TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel-TakeProfitLevel)/Point, 0);
      dRiskRewardTPRatio = TakeProfitPips / StopLossPips;

      //// 07222025 Print("dRiskRewardTPRatio: " + DoubleToString(dRiskRewardTPRatio));
      //OriginalTakeProfitPips  = TakeProfitPips;
      ////// 07222025 Print("OriginalTakeProfitPips: " + OriginalTakeProfitPips);
     }

   RefreshRates();
//  IF ORDER OPENED
   if(OrderOpened)
     {
      if(
         (TakeProfitLevel >= PriceTargetLevel) &&
         (TakeProfitLevel >= (Bid + (TPBufferPips * Point))) &&
         (ExecCommand==BUY_STOP))
        {
         if(DrawProfitLevel)
         {
         MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
         DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_BOTTOM,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
         ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                  DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                  RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
        }
      else
         if(
            (TakeProfitLevel <= PriceTargetLevel) &&
            (TakeProfitLevel <= (Ask - (TPBufferPips * Point))) &&
            (ExecCommand==SELL_STOP))
           {
            if(DrawProfitLevel)
         {
            MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
            DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_TOP,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
            ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                     DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                     RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
           }
         else
            if(
               (TakeProfitLevel >= PriceTargetLevel) &&
               (TakeProfitLevel >= (Bid + (TPBufferPips * Point))) &&
               (ExecCommand==BUY_LIMIT))
              {
               if(DrawProfitLevel)
         {
               MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
               DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_BOTTOM,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
               ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                        DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                        RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
              }
            else
               if(
                  (TakeProfitLevel <= PriceTargetLevel) &&
                  (TakeProfitLevel <= (Ask - (TPBufferPips * Point))) &&
                  (ExecCommand==SELL_LIMIT))
                 {
                  if(DrawProfitLevel)
         {
                  MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
                  DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_TOP,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
                  ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                           DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                           RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
                 }
               else
                 {
                  TakeProfitLevel=LastTakeProfitLevel;
                  TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel-TakeProfitLevel)/Point, 0);
                  dRiskRewardTPRatio=TakeProfitPips/StopLossPips;
                  //// 07222025 Print("dRiskRewardTPRatio: " + DoubleToString(dRiskRewardTPRatio));
                  //         OriginalTakeProfitPips  = TakeProfitPips;
                  //         //// 07222025 Print("OriginalTakeProfitPips: " + OriginalTakeProfitPips);
                  //
                  if(DrawProfitLevel)
                  MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);

                  return;
                 }

      //  NO RETURN - CONTINUE DOWN
     }
   else
     {
      //  IF ORDER NOT OPENED
      if(
         // Limit movement to ENTRY Point
         (TakeProfitLevel >= PriceTargetLevel) &&
         (TakeProfitLevel >= (PriceTargetLevel + (TPBufferPips * Point))) &&
         (ExecCommand==BUY_STOP))
        {
         if(DrawProfitLevel)
         {
         MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
         DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_BOTTOM,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
         ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                  DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                  RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
        }
      else
         if(
            (TakeProfitLevel <= PriceTargetLevel) &&
            (TakeProfitLevel <= (PriceTargetLevel - (TPBufferPips * Point))) &&
            (ExecCommand==SELL_STOP))
           {
            if(DrawProfitLevel)
         {
            MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
            DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_TOP,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
            ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                     DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                     RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
           }
         else
            if(
               (TakeProfitLevel >= PriceTargetLevel) &&
               (TakeProfitLevel >= (PriceTargetLevel + (TPBufferPips * Point))) &&
               (ExecCommand==BUY_LIMIT))
              {
               if(DrawProfitLevel)
         {
               MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
               DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_BOTTOM,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
               ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                        DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                        RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
              }
            else
               if(
                  (TakeProfitLevel <= PriceTargetLevel) &&
                  (TakeProfitLevel <= (PriceTargetLevel - (TPBufferPips * Point))) &&
                  (ExecCommand==SELL_LIMIT))
                 {
                  if(DrawProfitLevel)
         {
                  MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
                  DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_TOP,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
                  ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                           DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                                                                           RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
                 }
               else
                 {
                  TakeProfitLevel=LastTakeProfitLevel;
                  TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel-TakeProfitLevel)/Point, 0);
                  dRiskRewardTPRatio=TakeProfitPips/StopLossPips;
                  //// 07222025 Print("dRiskRewardTPRatio: " + DoubleToString(dRiskRewardTPRatio));
                  //         OriginalTakeProfitPips  = TakeProfitPips;
                  //         //// 07222025 Print("OriginalTakeProfitPips: " + OriginalTakeProfitPips);
                  //
                  if(DrawProfitLevel)
                     MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);

                  return;
                 }

      //if(AutoLotIncrease)
      //   Lots = CalcNewLotSize(AcumulatedFloatingLoss);
      //if(!RoundUpLots)
      //  {
      //   //Lots = NormalizeDouble((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
      //   Lots=NormalizeDouble(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
      //   ////// 07222025 Print("LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
      //  }
      //else
      //  {  //Lots = RoundUp((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
      //   Lots=RoundUp(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
      //   ////// 07222025 Print("RoundUp LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
      //  }

      //// 07222025 Print("New Calculated LOTS: " + Lots);
      
      //ConvertSecondsToHHMMSS((uint)NormalizeDouble(MathAbs((GetTickCount()-LastStartTickTarget)/1000),0))+MeasureSec);
      //  NO RETURN - CONTINUE DOWN
      

     }

#ifdef _MOVE_RR_RECTS_
   if(ShowTargetLayout && !(ObjectFind(objTargetLayoutMap)<0))
     {
      MoveTargetLayout();
      ////// 07222025 Print("<<< Layout MOVED... >>>");
     }
#endif

#ifdef _TrailingStop_

   bool NeedUpdate=false;

   if(DrawTTriggerLevel)
     {
      //  If Take Profit Line gets BELOW/ABOVE TTrigger -> Move TTrigger DOWN/UP a noch...
      if((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
        {
         //  Already calculated above
         //         TakeProfitLevel=NormalizeDouble(PriceTargetLevel, Digits) + NormalizeDouble(TakeProfitPips*Point,Digits);
         //         TakeProfitLevel=NormalizeDouble(TakeProfitLevel, Digits);
         //
         if(TakeProfitPips < TrailingTriggerPips)
           {
            TrailingStopPips = MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point;
            TrailingTriggerPips = TakeProfitPips - TTriggerBufferPips;
            //TrailingTriggerLevel=NormalizeDouble(PriceTargetLevel, Digits)+NormalizeDouble(TrailingTriggerPips*Point,Digits);
            //TrailingTriggerLevel=NormalizeDouble(TrailingTriggerLevel, Digits);
            TrailingTriggerLevel = PriceTargetLevel + TrailingTriggerPips * Point;

            //TrailingTailLevel=NormalizeDouble(TrailingTriggerLevel, Digits)-NormalizeDouble(TrailingStopPips*Point,Digits);
            //TrailingTailLevel=NormalizeDouble(TrailingTailLevel, Digits);
            TrailingTailLevel = TrailingTriggerLevel - TrailingStopPips * Point;

            TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);

            dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
            dRiskRewardTSRatio = TrailingTailPips / StopLossPips;

            NeedUpdate=true;
           }

        }
      else
         if((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
           {
            //         TakeProfitLevel=NormalizeDouble(PriceTargetLevel, Digits) - NormalizeDouble(TakeProfitPips*Point,Digits);
            //         TakeProfitLevel=NormalizeDouble(TakeProfitLevel, Digits);
            //
            if(TakeProfitPips < TrailingTriggerPips)
              {
               TrailingStopPips = MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point;        
               TrailingTriggerPips = TakeProfitPips - TTriggerBufferPips;
               //TrailingTriggerLevel=NormalizeDouble(PriceTargetLevel, Digits)-NormalizeDouble(TrailingTriggerPips*Point,Digits);
               //TrailingTriggerLevel=NormalizeDouble(TrailingTriggerLevel, Digits);
               TrailingTriggerLevel = PriceTargetLevel - TrailingTriggerPips * Point;

               //TrailingTailLevel=NormalizeDouble(TrailingTriggerLevel, Digits)+NormalizeDouble(TrailingStopPips*Point,Digits);
               //TrailingTailLevel=NormalizeDouble(TrailingTailLevel, Digits);
               //TrailingTailLevel = ((TrailingTriggerLevel/Point) + TrailingTailPips)*Point;
               TrailingTailLevel = TrailingTriggerLevel + TrailingStopPips * Point;
               
               //TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
               TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
               
               dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
               dRiskRewardTSRatio = TrailingTailPips / (double)StopLossPips;

               NeedUpdate=true;
              }
           }

      if(NeedUpdate)
        {
         if(DrawTTriggerLevel)
           {
            ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                            DoubleToStr((MathAbs(PriceTargetLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));

            ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                            DoubleToStr(((MathAbs(TrailingTailLevel-PriceTargetLevel))/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            DoubleToStr((MathAbs(TrailingTailLevel-TrailingTriggerLevel)/Point/_TicksPerPIP),1)+MeasurePips+Separator+
                            RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));

            if(!ObjectMove(ChartID(),
                           objTTriggerArrow,
                           0,
                           (datetime)(TimeCurrent()+(TTriggerArrowOffsetHor*Period()*60)),
                           TrailingTriggerLevel+TTriggerArrowOffsetVer))
              {
               //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
              }

            if(!ObjectMove(ChartID(),
                           objTTailArrow,
                           0,
                           (datetime)(TimeCurrent()+(TTailArrowOffsetHor*Period()*60)),
                           TrailingTailLevel+TTailArrowOffsetVer))
              {
               //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
              }

            MoveHLine(objTrailingTriggerLevelLineName,TrailingTriggerLevel);
            //OriginalTrailingTriggerPips = TrailingTriggerPips;
            ////// 07222025 Print("OriginalTrailingTriggerPips: " + OriginalTrailingTriggerPips);

            MoveHLine(objTrailingTailLevelLineName,TrailingTailLevel);
            //OriginalTrailingTailPips = TrailingTailPips;
            ////// 07222025 Print("OriginalTrailingTailPips: " + OriginalTrailingTailPips);
           }
        }
     }
#endif
                
   UpdatePriceLevels();
   
   return;
  }



//  ===================================================================


void AdjustNewTakeProfitLevelPosition(MarketRefPoints _PriceDir, double Diff)
  {

   double LastTakeProfitLevel = TakeProfitLevel;
   
   //// 07222025 Print("AdjustNewTakeProfitLevelPosition - Diff: " + Diff);
   
   if(Diff != 0)
      TakeProfitLevel = TakeProfitLevel + Diff;
   else
      return;


   RefreshRates();
   if(OrderOpened)
     {
      //// 07222025 Print("AdjustNewTakeProfitLevelPosition: HAVING A PROBLEM...");
      return;
     }
   else
      if(
         (ExecCommand==BUY_STOP))
        {
         if(DrawProfitLevel)
         {
         MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
         DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_BOTTOM,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
         ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                         //DoubleToStr(NormalizeDouble(MathAbs(TakeProfitLevel - PriceTargetLevel),Digits)/Point/_TicksPerPIP,1)+MeasurePips);
                         //DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+
                         DoubleToStr(TakeProfitPips/_TicksPerPIP,1)+MeasurePips+
                         Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
        }
      else
         if(
            (ExecCommand==SELL_STOP))
           {
            if(DrawProfitLevel)
            {
            MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
            DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_TOP,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
            ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                            //DoubleToStr(NormalizeDouble(MathAbs(TakeProfitLevel - PriceTargetLevel),Digits)/Point/_TicksPerPIP,1)+MeasurePips);
                            //DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+
                            DoubleToStr(TakeProfitPips/_TicksPerPIP,1)+MeasurePips+
                            Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
            }                
           }
         else
            if(
               (ExecCommand==BUY_LIMIT))
              {
               if(DrawProfitLevel)
         {
               MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
               DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_BOTTOM,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
               ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                               //DoubleToStr(NormalizeDouble(MathAbs(TakeProfitLevel - PriceTargetLevel),Digits)/Point/_TicksPerPIP,1)+MeasurePips);
                               //DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+
                               DoubleToStr(TakeProfitPips/_TicksPerPIP,1)+MeasurePips+
                               Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }
              }
            else
               if(
                  (ExecCommand==SELL_LIMIT))
                 {
                  if(DrawProfitLevel)
         {
                  MoveHLine(objTakeProfitLevelLineName,TakeProfitLevel);
                  DrawArrow(objProfitArrow,objProfitArrow,TakeProfitLevel,ProfitArrow,ProfitArrowBackground,ANCHOR_TOP,ProfitArrowColor,ProfitArrowSize,ProfitArrowOffsetHor,ProfitArrowOffsetVer);
                  ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                  //DoubleToStr(NormalizeDouble(MathAbs(TakeProfitLevel - PriceTargetLevel),Digits)/Point/_TicksPerPIP,1)+MeasurePips);
                                  //DoubleToStr((MathAbs(PriceTargetLevel-TakeProfitLevel)/Point/_TicksPerPIP),1)+MeasurePips+
                                  DoubleToStr(TakeProfitPips/_TicksPerPIP,1)+MeasurePips+
                                  Separator+RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
         }                                  
                 }
               else
                 {
                  TakeProfitLevel=LastTakeProfitLevel;
                  return;
                 }

   UpdatePriceLevels();
   

   return;
  }


//  ==================================================================


void UpdatePriceTarget(double NewPriceTarget)
  {
   //PriceTarget=NewPriceTarget;

   SetALLLineLevels();
   DrawALLLines();
   DrawALLLinesMetrixs();
  }


//  ==================================================================

// 03.10.2022  Monday
void UpdatePriceLevels()
{

   Lots = CalcNewLotSize(AcumulatedFloatingLoss);

   ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand)+ATLevel+
                                                                 DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+Separator+
                                                                 TimeToStr(TimeOrderInitiated,TargetTimeFormat)+Separator+
                                                                 ConvertSecondsToHHMMSS((uint)((GetTickCount()-LastStartTickTarget)/1000))+MeasureSec);   
}

//  ===================================================================


void ReInitMainLoop()
  {

//// 07222025 Print("INSIDE -> ReInitMainLoop");

#ifdef _COMPENSATION_ENGINE_
   AmIFirst=DontKnowYet;

// Moved to OnInit
//if(UseEnvelopeSlider)
//  if(DynamicOrStaticGrid)
//     EnvelopeSliderActive = true;
//  else
//     EnvelopeSliderActive = false;


// DONT NEED IT HEAR - You have it first in INIT and then after EACH CLOSE including the current LOSS...
//    //  Auto Lot SIZE generate base on instruments TickValue and DESIRED $ PROFIT/LOSS per 1 PIP
//   if(AutoLotGen)
//      {
//         double CurTickVal = MarketInfo(Symbol(),MODE_TICKVALUE);
//
//         if(!RoundUpLots)
//         {
//            Lots = NormalizeDouble((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
//            //// 07222025 Print("LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
//         }
//         else
//         {
//            Lots = RoundUp((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
//            //// 07222025 Print("RoundUp LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
//         }
//      }
//      else
//         Lots = OriginalLots;
//
//   //// 07222025 Print("LOTS: "+Lots);
//

#endif

   AcumulatedFloatingLoss  =  0;

   TotalOpens  = TotalOpens+NumOfOpens;
   NumOfOpens  = 0;

   TotalStops  = TotalStops + NumOfStops;
   NumOfStops  = 0;
   NumOfStops2  = 0;
   
#ifdef   _TAKE_PROFIT_COUNT_  

   // Changed 02/14/2025 per TAKE PROFIT COUNT
   //TotalProfits   =  TotalProfits + NumOfTakeProfits;
   //NumOfTakeProfits  =  0;

#else

   TotalProfits   =  TotalProfits + NumOfTakeProfits;
   NumOfTakeProfits  =  0;

#endif

   NumOfTrys   =  1;

   OrderOpened                = false;
   TransactionComplete        = false;
//OnHold                    = FirstLiveDirectOrder;        //  Whatever the current state is, keep it that way...

#ifdef      _TrendLineControl_
   TrendLineTriggerActive    = false;
#endif   
#ifdef   _TrailingStop_
   TTriggerActivated         = false;
#endif

   TimeOrderInitiated        = 0;
   TimeOrderOpened           = 0;
   TimeOrderStopped          = 0;
   TimeOrderTookProfit       = 0;

   LastStartTickTarget       = 0;
   LastStartTickStop         = 0;
   LastStartTickProfit       = 0;
   LastStartTickOpen         = 0;

   FirstTickTarget           = true;
   FirstTickOpen             = true;
   FirstTickStop             = true;
   FirstTickProfit           = true;
   FirstTimeTransComplete    = true;
   FirstTimeOnHold           = true;

//// 07222025 Print("Current PricDir: " + PriceDir);
   PriceDir=GetCurrentPriceDirection(AccuChop_ToFracNum(PriceTargetLevel), false);
//// 07222025 Print("New PricDir: " + PriceDir);

   AjustColorsAccordingToDir(PriceDir);

//  No Need - Panel already drawn in AdjustSetupVals...
//DrawInitialPanel();

//// 07222025 Print("OnHold: " + OnHold);
//// 07222025 Print("Lots: " + Lots);
//// 07222025 Print("AmIFirst: " + EnumToString(AmIFirst));
// 07222025 Print("NumOfOpens: " + IntegerToString(NumOfOpens) + 
// 07222025 "TotalOpens: " + IntegerToString(TotalOpens) + 
// 07222025 "NumOfStops: " + IntegerToString(NumOfStops) + 
// 07222025 "NumOfStops2: " + IntegerToString(NumOfStops2) + 
// 07222025 "TotalStops: " + IntegerToString(TotalStops) + 
// 07222025 "NumOfTakeProfits: " + IntegerToString(NumOfTakeProfits) + 
// 07222025 "TotalProfits: " + IntegerToString(TotalProfits));


}

//  =====================================================================================================================================


void AdjustSetupVals()
{
   // 07222025 Print("INSIDE AdjustSetupVals");
   // 07222025 Print("======================");
   // 07222025 Print("BEFORE -> PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
   // 07222025 Print("BEFORE -> StopLossPips: " + DoubleToString(StopLossPips));
   // 07222025 Print("BEFORE -> OriginalStopLossPips: " + DoubleToString(OriginalStopLossPips));
   // 07222025 Print("BEFORE -> BeforeLastStopLossPips: " + DoubleToString(BeforeLastStopLossPips));
   // 07222025 Print("BEFORE -> LastStopLossPips: " + DoubleToString(LastStopLossPips));
   // 07222025 Print("BEFORE -> TakeProfitPips: " + DoubleToString(TakeProfitPips));
   // 07222025 Print("BEFORE -> OriginalTakeProfitPips: " + DoubleToString(OriginalTakeProfitPips));
   // 07222025 Print("BEFORE -> TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips));
   // 07222025 Print("BEFORE -> OriginalTrailingTriggerPips: " + DoubleToString(OriginalTrailingTriggerPips));
   // 07222025 Print("BEFORE -> TrailingTailPips: " + DoubleToString(TrailingTailPips));
   // 07222025 Print("BEFORE -> OriginalTrailingTailPips: " + DoubleToString(OriginalTrailingTailPips));

   if(ProtectiveSL)
     {
      ProtectiveSL = false;

      StopLossPips = BeforeLastStopLossPips;        //  Before being dropped at new position
      LastStopLossPips = StopLossPips;
      
      //StopLossPips = LastStopLossPips;                //  The latest position dropped to

      //// 07222025 Print("1. LastStopLossPips: " + LastStopLossPips);
      //// 07222025 Print("2. BeforeLastStopLossPips: " + BeforeLastStopLossPips);
     }


   if(AutoResetSLAfterSL
//|| EmergencyResetSLAfterTrailing        //   Exploring other solution...  See ABOVE!
//  ||
//ProtectiveSL
     )
     {
      StopLossPips = OriginalStopLossPips;
     }
      else
      if(StopLossPips != LastStopLossPips)
      {
         StopLossPips = LastStopLossPips;
         // 07222025 Print("Discrepancy between StopLossPips & LastStopLossPips...");
      }
      else
      {
         // 07222025 Print("StopLossPips unchanged...");
      }

//  If EmergencyReset SET - ReSet it to FALSE
   if(EmergencyResetSLAfterTrailing)
      EmergencyResetSLAfterTrailing =  !EmergencyResetSLAfterTrailing;

//else
//StopLossPips = (MathAbs(PriceTargetLevel - StopLossLevel) / Point);

   if(AutoResetTPAfterTP)
     {
      TakeProfitPips       = OriginalTakeProfitPips;
      dRiskRewardTPRatio   = OriginaldRiskRewardTPRatio;
     }
//else
//TakeProfitPips  =  (MathAbs(PriceTargetLevel - TakeProfitLevel) / Point);

   if(AutoResetTTAfterSLTP)
     {
      TrailingTriggerPips  = OriginalTrailingTriggerPips;
      TrailingTailPips     = OriginalTrailingTailPips;

      dRiskRewardTTRatio   = OriginaldRiskRewardTTRatio;
      dRiskRewardTSRatio   = OriginaldRiskRewardTSRatio;
     }
//else
//{
//  TrailingTriggerPips = (MathAbs(PriceTargetLevel - TrailingTriggerLevel) / Point);
//  TrailingTailPips =  (MathAbs(TrailingTriggerLevel - TrailingTailLevel) / Point);
//}


   if(AutoResetETAfterSLTP)
      PriceTargetLevel=OriginalPriceTarget;
   //else
   //   PriceTarget=PriceTargetLevel;

   // 07222025 Print("AFTER -> PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
   // 07222025 Print("AFTER -> BeforeLastStopLossPips: " + DoubleToString(BeforeLastStopLossPips));
   // 07222025 Print("AFTER -> StopLossPips: " + DoubleToString(StopLossPips));
   // 07222025 Print("AFTER -> OriginalStopLossPips: "+DoubleToString(OriginalStopLossPips));
   // 07222025 Print("AFTER -> TakeProfitPips: "+DoubleToString(TakeProfitPips));
   // 07222025 Print("AFTER -> OriginalTakeProfitPips: "+DoubleToString(OriginalTakeProfitPips));
   // 07222025 Print("AFTER -> TrailingTriggerPips: "+DoubleToString(TrailingTriggerPips));
   // 07222025 Print("AFTER -> OriginalTrailingTriggerPips: "+DoubleToString(OriginalTrailingTriggerPips));
   // 07222025 Print("AFTER -> TrailingTailPips: "+DoubleToString(TrailingTailPips));
   // 07222025 Print("AFTER -> OriginalTrailingTailPips: "+DoubleToString(OriginalTrailingTailPips));

   SetALLLineLevels();
   DrawALLLines();
   DrawALLLinesMetrixs();

   // 07222025 Print("EXIT AdjustSetupVals");
   
  }


//  ===================================================================


void RefreshMarketRefPoint()
{
   string OriginalStr="";

   if((Bid<PriceTargetLevel) &&
      (Ask<=PriceTargetLevel))
     {
      MarketRefPoint=ABOVE;
     }
   else
      if((Bid>=PriceTargetLevel) &&
         (Ask>PriceTargetLevel))
        {
         MarketRefPoint=BELOW;
        }
      else
         if((Bid<PriceTargetLevel) &&
            (Ask>PriceTargetLevel))
           {
            MarketRefPoint=INSIDE;
           }

   if(!DelayedPrintActive)
     {
      OriginalStr=ObjectGetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT);

      //      //// 07222025 Print("1. OriginalStr: " + OriginalStr);
      //
      //      int k=StringSplit(OriginalStr, PLu_sep, PLresult);
      //
      //      //// 07222025 Print("K is: " + IntegerToString(k,2));
      //      //// 07222025 Print("PLresult is: " + PLresult[0]);
      //      //// 07222025 Print("PLresult LENGTH is: " + StringLen(PLresult[0]));
      //
      //      OriginalStr = PLresult[0];
      //      //// 07222025 Print("2. OriginalStr: " + OriginalStr);



      if((StringFind(OriginalStr,EnumToString(MarketRefPoint))<0))
         if(!(StringReplace(OriginalStr,"ABOVE",EnumToString(MarketRefPoint))==0))
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,OriginalStr);
         else
            if(!(StringReplace(OriginalStr,"BELOW",EnumToString(MarketRefPoint))==0))
               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,OriginalStr);
            else
               if(!(StringReplace(OriginalStr,"INSIDE",EnumToString(MarketRefPoint))==0))
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,OriginalStr);
     }


   switch(MarketRefPoint)
     {
      case ABOVE:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,ABOVEColor);
         break;

      case BELOW:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,BELOWColor);
         break;

      case INSIDE:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,INSIDEColor);
         break;
     }

}


//  ===================================================================


void RefreshMarketRefPoint2()
  {
   string OriginalStr="";

   if((Bid<PriceTargetLevel) &&
      (Ask<=PriceTargetLevel))
     {
      MarketRefPoint=ABOVE;
     }
   else
      if((Bid>=PriceTargetLevel) &&
         (Ask>PriceTargetLevel))
        {
         MarketRefPoint=BELOW;
        }
      else
         if((Bid<PriceTargetLevel) &&
            (Ask>PriceTargetLevel))
           {
            MarketRefPoint=INSIDE;
           }

   switch(MarketRefPoint)
     {
      case ABOVE:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,ABOVEColor);
         break;

      case BELOW:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,BELOWColor);
         break;

      case INSIDE:

         ObjectSetInteger(ChartID(),"PositionLocationValue",OBJPROP_COLOR,INSIDEColor);
         break;
     }

//  Current PL
//UpdateCurrentPL(GetCurrentPL());

//  Net PL
   
   
   UpdateCurrentPL(GetCurrentPL());

  }


//  ===================================================================


bool FinalProtectionReached(int _NumOfStops)
  {
   if(NumTimesToProtect==_NumOfStops)
     {
      TransactionComplete=!TransactionComplete;

      //Sleep(30000);

      //ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,FinalReached);
      //ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,FinalReachedVal);

      ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,ObjectGetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT)+" - GAME OVER...");
      //ChangeColorForItem("ProtectionAttemptsValue");
      ObjectSetInteger(ChartID(),"ProtectionAttemptsValue",OBJPROP_COLOR,FinalProtReachedColor);

      if(SendEmailUpdates)
         //SendMail(EA_NAME_IDENTIFIER,FinalReached+StringFormat("\n%02d. ",NumOfStops)+FinalReachedVal);
         SendMail(EA_NAME_IDENTIFIER,ObjectGetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT)+" - GAME OVER...");

      //Debug("Number of STOPS: " + NumOfStops);

      Sleep(30000);  // 10 seconds

      //ExpertRemove();
      return(true);
     }

   return(false);
  }


//  ===================================================================


int ChartFirstVisibleBar(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_FIRST_VISIBLE_BAR,0,result))
     {
      //--- display the error message in Experts journal
      //// 07222025 Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return(int (result));
  }


//  ===================================================================

#ifdef      _TrendLineControl_
void DrawTriggerTrendLine()
  {
   int shift1 = ChartFirstVisibleBar();
   int shift2 = 0;

   if((ExecCommand==BUY_STOP) || (ExecCommand==BUY_LIMIT))
     {
      if(!ObjectCreate(TrendLineName,OBJ_TREND,0,Time[shift1],
                       PriceTargetLevel+(TrendLinePipsAway*Point),
                       Time[shift2],
                       PriceTargetLevel+(TrendLinePipsAway*Point)))
        {
         // 07222025 Print(__FUNCTION__, ": failed to create a trend line! Error code = ",GetLastError());
         return;
        }
     }
   else
      if((ExecCommand==SELL_STOP) || (ExecCommand==SELL_LIMIT))
        {
         if(!ObjectCreate(TrendLineName,OBJ_TREND,0,Time[shift1],
                          PriceTargetLevel -(TrendLinePipsAway*Point),
                          Time[shift2],
                          PriceTargetLevel -(TrendLinePipsAway*Point)))
           {
            // 07222025 Print(__FUNCTION__, ": failed to create a trend line! Error code = ",GetLastError());
            return;
           }
        }


   if(TrendLineTriggerActive)
      ObjectSet(TrendLineName,OBJPROP_STYLE,TrendLineStyle);
   else
      ObjectSet(TrendLineName,OBJPROP_STYLE,STYLE_DASH);

   ObjectSet(TrendLineName,OBJPROP_WIDTH,TrendLineWidth);
   ObjectSet(TrendLineName,OBJPROP_RAY_RIGHT,true);
   ObjectSet(TrendLineName,OBJPROP_BACK,TrendLineBackground);
   ObjectSet(TrendLineName,OBJPROP_COLOR,TrendLineColor);

   
  }
#endif

//  ===================================================================


bool GenerateProtectionLevel()
  {

   if(MarketRefPoint==ABOVE)
     {
      if(MarketOrderType==LONG)
         ExecCommand=BUY_STOP;
      else
         if(MarketOrderType==SHORT)
            ExecCommand=SELL_LIMIT;
     }
   else
      if(MarketRefPoint==BELOW)
        {
         if(MarketOrderType==LONG)
            ExecCommand=BUY_LIMIT;
         else
            if(MarketOrderType==SHORT)
               ExecCommand=SELL_STOP;
        }


   if(!HitLiveMarket)
     {
      //  If PriceTarget is directly specified then AutoPriceGen should be FALSE       
      if(AutoPriceGen && PriceTargetLevel == 0)
        {
         RefreshRates();
         if(MarketRefPoint==ABOVE && ExecCommand==BUY_STOP)
           {
            PriceTargetLevel=AccuChop_ToFracNum(Ask+(PipsAway*Point));
            //// 07222025 Print("SET PriceTarget: " + PriceTarget);
            //// 07222025 Print("ASK: " + Ask);
           }
         else
            if(MarketRefPoint==BELOW && ExecCommand==SELL_STOP)
              {
               PriceTargetLevel=AccuChop_ToFracNum(Bid -(PipsAway*Point));
               //// 07222025 Print("SET PriceTarget: " + PriceTarget);
               //// 07222025 Print("BID: " + Bid);
              }
         if(MarketRefPoint==ABOVE && ExecCommand==SELL_LIMIT)
           {
            PriceTargetLevel=AccuChop_ToFracNum(Bid+(PipsAway*Point));
            //// 07222025 Print("SET PriceTarget: " + PriceTarget);
            //// 07222025 Print("BID: " + Bid);
           }
         else
            if(MarketRefPoint==BELOW && ExecCommand==BUY_LIMIT)
              {
               PriceTargetLevel=AccuChop_ToFracNum(Ask -(PipsAway*Point));
               //// 07222025 Print("SET PriceTarget: " + PriceTarget);
               //// 07222025 Print("ASK: " + Ask);
              }
        }
//    04.05.2022 - Need to allow this condition for automated PENDING SETUPs...        
//      else if(!AutoPriceGen && PriceTargetLevel == 0)
//            {
//                // 07222025 Print("CRITICAL ERROR!!! - AutoPriceGen ON goes with PriceTargetLevelb = 0...");
//                TransactionComplete = true;
//                return(false);
//                
//               //// 07222025 Print(Symbol() + " - PriceTargetLevel: " + PriceTarget);
//                     
//            }
         

      RefreshRates();
      if((Bid<PriceTargetLevel) &&
         (Ask<=PriceTargetLevel))
        {
         MarketRefPoint=ABOVE;
        }
      else
         if((Bid>=PriceTargetLevel) &&
            (Ask>PriceTargetLevel))
           {
            MarketRefPoint=BELOW;
           }
         else
            if((Bid<PriceTargetLevel) &&
               (Ask>PriceTargetLevel))
              {
               MarketRefPoint=INSIDE;
              }

      //  Corrections to PRICE TARGET
      //  If too close to SPREAD or INSIDE SPREAD - PUSH BACK...
      RefreshRates();
      if(ExecCommand == BUY_STOP)
        {
         if(AccuChop_ToFracNum(PriceTargetLevel-Ask)<(PTBufferPips*Point))
           {
            //// 07222025 Print("Diff: " + DoubleToString(PriceTarget - Ask));
            PriceTargetLevel=Ask+(PipsAway*Point);
           }
        }
      else
         if((ExecCommand == SELL_LIMIT))
           {
            if(AccuChop_ToFracNum(PriceTargetLevel-Bid)<(PTBufferPips*Point))
              {
               //// 07222025 Print("Diff: " + DoubleToString(PriceTarget - Ask));
               PriceTargetLevel=Bid+(Ask-Bid)+(PipsAway*Point);
              }
           }
         else
            if((ExecCommand == BUY_LIMIT))
              {
               if(AccuChop_ToFracNum(Ask-PriceTargetLevel)<(PTBufferPips*Point))
                 {
                  //// 07222025 Print("Diff: " + DoubleToString(PriceTarget - Ask));
                  PriceTargetLevel=Ask -(Ask-Bid) -(PipsAway*Point);
                 }
              }
            else
               if((ExecCommand == SELL_STOP))
                 {
                  if(AccuChop_ToFracNum(Bid-PriceTargetLevel)<(PTBufferPips*Point))
                    {
                     //// 07222025 Print("Diff: " + DoubleToString(Bid - PriceTarget));
                     PriceTargetLevel=Bid -(PipsAway*Point);

                    }
                 }
     }
   else
     {
     
     //  HIT Live Market is TRUE
     // ==================================================================================================================================================================
     
     
     if(DelayedTimeActivation)
         { 

         while(!IsStopped())
         {
               if(_CheckActivation && !CheckActivationFirstTime)
                 {
         
                  if(TimeCurrent() < ActivateTime)
                    {
                     if(TimedActiveFirstTime)
                       {
                        
                              
                        ////// 07222025 Print("Waiting TIME Activation..." + TimeToString(ActivateTime));
                        TimedActiveFirstTime=false;
                        TimedDeActiveFirstTime=true;
         
                        OnHold=true;
         
                        //datetime ActivateTime2;
                        //ActivateTime2 = StrToTime(ActivateTimeStr);
                        //ActivateTime2 = AddOneDay(ActivateTime2, NextActivateAfter);
                        //ActivateTimeStr = TimeToString(DeActivateTime)
         
                        //CurrentPosition=" MARKET - TIME Activation at: "+TimeToString(ActivateTime);
                        //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                        ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" Lots "+EnumToString(ExecCommand));
                        ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,"EA is Sleeping...");
                        ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,"Please WAIT!");
         
                        InitToggleOnHold();
                        WindowRedraw();
                       }
         
                     if(OnHold!=true)     //  If you change the HourGlass icon, it will recover back to waiting...
                       {
                        OnHold=true;
                        
                        //CurrentPosition=" MARKET - TIME Activation at: "+TimeToString(ActivateTime);
                        //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                        ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" Lots "+EnumToString(ExecCommand));
                        ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,"EA is Sleeping...");
                        ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,"Please WAIT!");
         
                        InitToggleOnHold();
                        WindowRedraw();
                       }

                       
                       //CurrentPosition = " MARKET - TIME Activation at: " + TimeToString(ActivateTime) + " in: " + ConvertSecondsToHHMMSS(TimeDiff) + "...";
                       //ObjectSetString(ChartID(),"PositionLocationValue", OBJPROP_TEXT, GetPriceDirString(PriceDir) + CurrentPosition);
                       
                       TTimeDiff = (double)ActivateTime - TimeCurrent();
                       //CurrentPosition = " MARKET - TIME: " + TimeToString(TimeCurrent()) + " Activation at: " + TimeToString(ActivateTime);
                       CurrentPosition = "TIME: " + TimeToString(TimeCurrent()) + " -> " + TimeToString(ActivateTime);
                       //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir) + CurrentPosition + " in: " + ConvertSecondsToHHMMSS(TTimeDiff) + "...");
                       ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,CurrentPosition + " -> " + ConvertSecondsToHHMMSS(TTimeDiff));
                        
                       //ObjectSetString(ChartID(),"PositionLocationValue", OBJPROP_TEXT, " MARKET TIME Activation at: " + TimeToString(ActivateTime) + " in: " + ConvertSecondsToHHMMSS(TimeDiff) + "...");
                       
                     //Sleep(60 * 1000);    // Wait One minute
                     //return;
                    }
                  else if(TimeCurrent() >= ActivateTime)
                    {
                     //  Activation Time REACHED...
                     _CheckActivation=false;
                     _CheckDeActivation=true;
                     TimedActiveFirstTime=true;
         
                              
                     // 07222025 Print("Activation TIME Reached..." + TimeToString(ActivateTime));
         
                     OnHold=false;
                     //CurrentPosition = PositionPending;      //  To be replaced eventually...
                     CurrentPosition=" MARKET - Activation TIME Reached: "+TimeToString(ActivateTime);
                     ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                     ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,"EA is Activated...");
                     ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,"");
         
                     InitToggleOnHold();
                     WindowRedraw();
                     
                     
                     //Sleep(3000);   //  Keep message for 3 sec. before moving on
                     
                     break;      // Get out from the loop
                     
                    }
                 }
               else
                 {
                  // CheckActivation is FALSE
                  if(!CheckActivationFirstTime)
                     CheckActivationFirstTime = false;
                     
                  break;
                 }
                 
                 Sleep(800);     //  Wait 
                 
              }   //End While loop

         }       
         
     
     //  Activate ON EXTERNAL SIGNAL
     if(WaitForEntrySignal)
     {
     
      // 07222025 Print("<<< Activate ON EXTERNAL SIGNAL >>>");
      if(!GlobalValDel(_GV_LAUNCH_SIGNAL))
      {
          // 07222025 Print("Can't DELETE Global Variable _GV_LAUNCH_SIGNAL...");
      }
               
      //  TimeToString(TimeCurrent(), TIME_MINUTES | TIME_SECONDS )
      datetime StartTime   =  TimeCurrent();
      double TimeDiff    =  0;
      bool TimedActiveFirstTime2 = true;
      
      while(!SeekLaunchSignal() && !IsStopped())
        {
         
         TimeDiff = (double)TimeCurrent() - StartTime;
        
         if(TimedActiveFirstTime2)
         {
            TimedActiveFirstTime2 = false;
            
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,"AWAITING EXTERNAL LAUNCH SIGNAL " + ConvertSecondsToHHMMSS(TimeDiff) + "...");
            ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" Lots "+EnumToString(ExecCommand));
            ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,"EA is Sleeping...");
            ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,"Please WAIT!");
         }
         else
         {
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,"AWAITING EXTERNAL LAUNCH SIGNAL " + ConvertSecondsToHHMMSS(TimeDiff) + "...");
         }
         
         Sleep(800);
         
        }
         
        TimedActiveFirstTime2 = true; 
         
     }
     
     
         
// ==================================================================================================================================================================
     
      if(ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
        {
         //RefreshRates();
         //PriceTarget = Ask + (Point * 1);
         //PriceTargetLevel = NormalizeDouble(Ask, Digits);
         //PriceTargetLevel = NormalizeDouble(MarketInfo(Symbol(), MODE_ASK),Digits);
         PriceTargetLevel = MarketInfo(Symbol(), MODE_ASK);
        }
      else
         if(ExecCommand==BUY_STOP)
           {
            RefreshRates();
            //PriceTarget = Ask - (Point * 1);
            //PriceTargetLevel = NormalizeDouble(Ask, Digits);
            PriceTargetLevel = MarketInfo(Symbol(), MODE_ASK);
            //PriceTargetLevel = AccuChop_ToFracNum(PriceTargetLevel);
           }
         else
            if(ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
              {
               //RefreshRates();
               //PriceTarget = Bid - (Point * 1);
               //PriceTargetLevel = NormalizeDouble(Bid, Digits);
               PriceTargetLevel = MarketInfo(Symbol(), MODE_BID);
               //PriceTargetLevel = AccuChop_ToFracNum(PriceTargetLevel);
              }
            else
               if(ExecCommand==SELL_STOP)
                 {
                  //RefreshRates();
                  //PriceTarget = Bid + (Point * 1);
                  //PriceTargetLevel = NormalizeDouble(Bid, Digits);
                  PriceTargetLevel = MarketInfo(Symbol(), MODE_BID);
                  //PriceTargetLevel = AccuChop_ToFracNum(PriceTargetLevel);
                 }
     }

//  =========================================================================
//  If StopLossPips is 0 means it has to be calculated...
//  =========================================================================

      if(StopLossPips <= 0)
      {
      
         if(EnableStopLossATR && (StopLossPips <= 0))
         {
            StopLossPips = NormalizeDouble(MultiplierATR * Get_ATR_VAL() / (Point), 0);
            //// 07222025 Print("EnableedStopLossATR -> StopLossPips: " + DoubleToString(StopLossPips));
        }
      else    //  Stop Loss derived as number of current spreads
         if(UseSLasNumOfSpreads && (StopLossPips <= 0))
         {   
            double Spread;
            
            if(SLasAverageSpread == 0)
               Spread = MarketInfo(Symbol(), MODE_SPREAD);
            else
               Spread = SLasAverageSpread;
               
            StopLossPips = NormalizeDouble(SLasNumOfSpreads * Spread, 0);
      
            //// 07222025 Print("SLasNumOfSpreads: " + IntegerToString(SLasNumOfSpreads));
            //// 07222025 Print("MarketInfo(MODE_SPREAD): " + DoubleToString(Spread, 0));
            //// 07222025 Print("StopLossPips: " + DoubleToString(StopLossPips, 0));
         }
      else  //  Stop Loss as a Percentage from current equity
            // $10000 * 1% = $100 affordable loss;  Afordable Loss $100 / (Lots 1.23 * TickValue ) * 10 = Afordable Pips to loos
         if(UseSLasRiskPct && (StopLossPips <= 0))
         {
#ifdef _PARTIAL_CLOSE_         
            string RefPointVal;
            
            if(CalcbyTakeProfit)
               RefPointVal = RiskRewardTPRatio;
            else if(CalcRPbyTrigOrTailLevel)
               RefPointVal = RiskRewardTTRatio;
            else
               RefPointVal = RiskRewardTSRatio;
   
            PercentRiskCalculator objPRC(SLRiskPct,
                                         AccountInfoDouble(ACCOUNT_EQUITY),
                                         RefPointVal,
                                         MultiplierLotSize);
                                
            
            // Plugging IN values...
            StopLossPips        = objPRC.GetStopLossDeltaTicks();
            DesiredNetProfitVal = objPRC.GetDesiredTP();
            
            
            double ActualRiskAmount          = AccuChop_ToFracNum(objPRC.GetAmountPercentRiskFromAccount());
            double ActualStopLossDeltaTicks  = AccuChop_ToFracNum(objPRC.GetStopLossDeltaTicks());
            double ActualDesiredTP           = AccuChop_ToFracNum(objPRC.GetDesiredTP()); 
            double ActualRiskReward          = objPRC.GetRiskRewardRatio();
            
            
            // 07222025 Print("InpDesiredPercentRisk: " + SLRiskPct);
            // 07222025 Print("InpDesiredRiskReward: " + RefPointVal);           
            
            // 07222025 Print("ActualRiskReward: " + ActualRiskReward);
            // 07222025 Print("ActualRiskAmount: " + ActualRiskAmount + " = " + SLRiskPct + "% of " + objPRC.GetTotalAccountBalance()+ " Account Balance" );
            
         
            // 07222025 Print("ActualStopLossDeltaTicks (PlugIn -> StopLossPIPS): " + ActualStopLossDeltaTicks);
            // 07222025 Print("ActualDesiredTP (PlugIn -> DesiredNetProfitVal): " + ActualDesiredTP);
#endif 
         }
        }
        
              //  Just in case somehow StopLossPips is STILL Zero...
      if(StopLossPips <= 0)
        {
         // 07222025 Print("CRITICAL ERROR!!! - StopLossPips INVALID...");
         TransactionComplete=true;
         return(false);
        }
        
        
//  =========================================================================
//  Risk & Reward - Derive Take Profit calculation based on current Stop Loss
//  =========================================================================
   if(UseRiskReward)
     {

      string result1[];
      string result2[];
      string result3[];
      

      if(TakeProfitPips <= 0)
      {
         int k1 = 0;
         
         if(!FirstTimeRR)
            k1=StringSplit(RiskRewardTPRatio,FRACTION_SEPARATOR,result1);
         else
            k1=StringSplit(InitRiskRewardTPRatio,FRACTION_SEPARATOR,result1);
           
         //dRiskRewardTPRatio=StringToDouble(result1[1])/StringToDouble(result1[0]);   
         //dRiskRewardTPRatio = 1 / (StringToDouble(result1[0]) / StringToDouble(result1[1]));
         dRiskRewardTPRatio = EvaluateDivisionExpression(result1[1]);
         // 07222025 Print("dRiskRewardTPRatio: " + DoubleToStr(dRiskRewardTPRatio) + "   " + "StopLossPips: " + DoubleToStr(StopLossPips));
         TakeProfitPips = NormalizeDouble(dRiskRewardTPRatio * StopLossPips, 0);
         // 07222025 Print("Generated TakeProfitPips: " + DoubleToStr(TakeProfitPips));
         
      }
      else
         dRiskRewardTPRatio = TakeProfitPips / StopLossPips;

      
      
         if(TrailingTriggerPips <= 0)
         {
            int k2 = 0;
            
            if(ProtectTakeProfit)
            //if(!FirstTimeRR && !FirstTimeRunAway)
               {
                  TrailingTriggerPips  =  NormalizeDouble(TakeProfitPips - TakeProfitZonePIPS, 0);
                  dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
               }
            else
            if(!FirstTimeRR)
               {
                  k2=StringSplit(RiskRewardTTRatio,FRACTION_SEPARATOR,result2);
                  
                  dRiskRewardTTRatio = EvaluateDivisionExpression(result2[1]);
                  TrailingTriggerPips = NormalizeDouble(dRiskRewardTTRatio * StopLossPips, 0);
               }
            else
               {
                  k2=StringSplit(InitRiskRewardTTRatio,FRACTION_SEPARATOR,result2);
                  
                  //dRiskRewardTTRatio=StringToDouble(result2[1])/StringToDouble(result2[0]);
                  //dRiskRewardTTRatio = 1 / (StringToDouble(result2[0]) / StringToDouble(result2[1]));
                  dRiskRewardTTRatio = EvaluateDivisionExpression(result2[1]);
                  TrailingTriggerPips = NormalizeDouble(dRiskRewardTTRatio * StopLossPips, 0);
               }
         }
      else
         dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
     
      
      
         if(TrailingTailPips <= 0)
         {
            int k3 = 0;
            
            if(ProtectTakeProfit)
            //if(!FirstTimeRR && !FirstTimeRunAway)
               {
                  TrailingTailPips     = TrailingTriggerPips - TakeProfitZonePIPS;
                  dRiskRewardTSRatio   = TrailingTailPips / StopLossPips;
               }
            else 
            if(!FirstTimeRR)
               {
                  k3=StringSplit(RiskRewardTSRatio,FRACTION_SEPARATOR,result3);
                  
                  dRiskRewardTSRatio = EvaluateDivisionExpression(result3[1]);
                  TrailingTailPips  = NormalizeDouble(dRiskRewardTSRatio * StopLossPips, 0);
               }
            else
               {
                  
                  k3=StringSplit(InitRiskRewardTSRatio,FRACTION_SEPARATOR,result3);
               
                  //dRiskRewardTSRatio=StringToDouble(result3[1])/StringToDouble(result3[0]);
                  //dRiskRewardTSRatio = 1 / (StringToDouble(result3[0]) / StringToDouble(result3[1]));
                  dRiskRewardTSRatio = EvaluateDivisionExpression(result3[1]);
                  TrailingTailPips  = NormalizeDouble(dRiskRewardTSRatio * StopLossPips, 0);
                  // Changed 12.03.2021
                  // No NEED to subtract - when TT and TS are the same, as TS level is TT Level less TS pips, then TS level becomes ZERO pips above Entry Level...
                  //TrailingTailPips = TrailingTriggerPips - TrailingTailPips;        //  TTPips is measured as offset from TTarget...
               }
  
         }
         else
         {
            dRiskRewardTSRatio = TrailingTailPips / StopLossPips;  
         }
      }
      else
      {  // NO RISK-REWARD ENABLED...  Use hardcoded values!!!
     
                  //  Check Price levels are right in sequence from Higher to Lower
//         switch (ExecCommand )
//         {
//               case BUY_STOP:
//               case BUY_LIMIT:
//               
//               
//                           {                                         
//                              if(TrailingTriggerLevel <= TrailingTailLevel)
//                                 TrailingTriggerLevel = TrailingTailLevel + TTailBufferPips;
//                                 
//                              if(TakeProfitLevel <= TrailingTriggerLevel) 
//                                 TakeProfitLevel = TrailingTriggerLevel + TTriggerBufferPips;
//                              
//                              TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel-TakeProfitLevel)/Point, 0);
//                              TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);
//                              TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
//                              
//                              // 07222025 Print("BUY Side TakeProfitLevel or TrailingTriggerLevel adjusted...");
//                           }
//                           break;                          
//               
//               case SELL_STOP:                            
//               case SELL_LIMIT:
//               
//                           {                                         
//                              if(TrailingTriggerLevel >= TrailingTailLevel)
//                                 TrailingTriggerLevel = TrailingTailLevel - TTailBufferPips;
//                                 
//                              if(TakeProfitLevel >= TrailingTriggerLevel) 
//                                 TakeProfitLevel = TrailingTriggerLevel - TTriggerBufferPips;
//                              
//                              TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel-TakeProfitLevel)/Point, 0);
//                              TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);
//                              TrailingTailPips = NormalizeDouble(MathAbs(PriceTargetLevel-TrailingTailLevel)/Point, 0);
//                                 
//                              // 07222025 Print("SELL Side TakeProfitLevel or TrailingTriggerLevel adjusted...");
//                           }
//                           break;                               
//         }
//         

         
         if(TrailingTriggerPips <= TrailingTailPips)
         {
            // 07222025 Print("ADJUSTING TrailingTriggerPips: " + TrailingTriggerPips);
            // 07222025 Print("ADJUSTING TrailingTailPips: " + TrailingTailPips);
            
            TrailingTriggerPips = TrailingTailPips + TTriggerBufferPips;
            
            // 07222025 Print("AFTER: TrailingTriggerPips: " + TrailingTriggerPips + " TTriggerBufferPips: " + TTriggerBufferPips);
         }
            
         if(TakeProfitPips <= TrailingTriggerPips) 
         {
            // 07222025 Print("ADJUSTING TakeProfitPips: " + TakeProfitPips);   
            TakeProfitPips = TrailingTriggerPips + TPBufferPips;
            
            // 07222025 Print("AFTER TakeProfitPips: " + TakeProfitPips + " TPBufferPips: " + TPBufferPips);
         }         

                  
                     
         if(TakeProfitPips <= 0)
            {
               // 07222025 Print("CRITICAL ERROR!!! - TakeProfitPips INVALID...");
               TransactionComplete = true;
               return(false);
            }
            else
               dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
               
            
            
            if(DrawTTriggerLevel)
            {
               if(ProtectTakeProfit)
               //if(!FirstTimeRR && !FirstTimeRunAway)
                  {
                     if(TrailingTriggerPips <= 0)
                     { 
                        // 07222025 Print("CRITICAL ERROR!!! - TrailingTriggerPips INVALID...");
                        TransactionComplete = true;
                        return(false);  
                     }
                     else
                        dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
                        
                     if(TrailingTailPips <= 0)
                     {
                        // 07222025 Print("CRITICAL ERROR!!! - TrailingTailPips INVALID...");
                        TransactionComplete = true;
                        return(false); 
                     }
                     else 
                     {  
                        dRiskRewardTSRatio = TrailingTailPips / StopLossPips;
                     }
                  }
                  else
                  {
                     //  Rebuild the rest based on TakeProfitPips...
                     TrailingTriggerPips  = MathAbs(TakeProfitPips - TakeProfitZonePIPS);
                     dRiskRewardTTRatio = TrailingTriggerPips / StopLossPips;
                     
                     TrailingTailPips     = MathAbs(TrailingTriggerPips - TakeProfitZonePIPS);
                     dRiskRewardTSRatio   = TrailingTailPips / StopLossPips;
                  }
            }
            
      }
      
      
      
                     
      
      // Pips must be with .000 behind decimal point
      //// 07222025 Print(">>> GENERATE PROTECTION LEVEL...");
      //// 07222025 Print("UseRiskReward: " + IntegerToString(UseRiskReward));
      //// 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
      //// 07222025 Print("StopLossPips: " + DoubleToString(StopLossPips));
      //// 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips));
      //// 07222025 Print("TrailingTriggerPips" + DoubleToString(TrailingTriggerPips));        
      //// 07222025 Print("TrailingTailPips" + DoubleToString(TrailingTailPips));
      
//OriginalLots = Lots;

//  Auto Lot SIZE generate base on instruments TickValue and DESIRED $ PROFIT/LOSS per 1 PIP
   if(AutoLotGen)
     {
      //  AutoLotGen MUST BE FALSE! for Lots to be > 0    
      //  If Lots is hardcoded in .SET definitions then CALC ProfitLossPerPip for this LOT SIZE
//      if(Lots > 0)
//        {
//         
//         // 07222025 Print ("CRITICAL:  Lots > 0 is Under Construction!!!");
//         TransactionComplete = true;
//                  
//         return(false);
//         //ProfitLossPerPip = NormalizeDouble(Lots * TicksPerPIP * MarketInfo(Symbol(),MODE_TICKVALUE), PL_PipPrecision);
//         
//         CurrProfitLossPerPip = Lots * TicksPerPIP * MarketInfo(Symbol(),MODE_TICKVALUE);
//         
//         //ProfitLossPerPip = NormalizeDouble(Lots * TicksPerPIP * UpdateTickVal(MarketInfo(Symbol(),MODE_TICKVALUE)), PL_PipPrecision);
//         //CurrProfitLossPerPip = ProfitLossPerPip;
//
//         // WARNING - YOu can't have desired Profit/Loss per PIP when hard-coding the Lot size
//         //CurrProfitLossPerPip = ProfitLossPerPip;
//         //// 07222025 Print("Desired ProfitLossPerPip: "+ ProfitLossPerPip);
//         AcumulatedFloatingLoss = 0;
//         if(GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
//           {
//
//            if(ShowCompensateLossMsgBox)
//            {
//               int iRet = MessageBox("Do you want to COMPENSATE this Accumulated Loss now?",
//                                     "CURRENCY_SIGN" + DoubleToString(AcumulatedFloatingLoss, 2) + " Prior Accumulated Loss Found...",
//                                     MB_YESNO);
//   
//               if(iRet == IDYES)
//                 {
//                  Lots = CalcNewLotSize(AcumulatedFloatingLoss);
//                  if (TransactionComplete)
//                     return(false);
//                  // 07222025 Print("Init Accumulated Loss REFRESHED & LOTS Updated...");
//                 }
//               else
//                  if(iRet == IDNO)
//                    {
//                     if(GlobalValDel(_GV_CURRENT_LOSS))
//                       {
//                        AcumulatedFloatingLoss = 0;
//                        // 07222025 Print("<<< 1. AcumulatedFloatingLoss DELETED!");
//                       }
//                    }
//             }
//             else
//             {
//               if(CompensateLossYesNo)
//               {
//                  Lots = CalcNewLotSize(AcumulatedFloatingLoss);
//                  if (TransactionComplete)
//                     return(false);
//                  // 07222025 Print("Init Accumulated Loss REFRESHED & LOTS Updated...");
//               }
//               else
//               {
//                  if(GlobalValDel(_GV_CURRENT_LOSS))
//                       {
//                        AcumulatedFloatingLoss = 0;
//                        // 07222025 Print("<<< 2. AcumulatedFloatingLoss DELETED!");
//                       }
//               }
//             }
//           }
//         else
//           {
//               if(AcumulatedFloatingLoss < 0)
//               {
//                  // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
//                  TransactionComplete = true;
//                  
//                  return(false);
//               }
//               
//               // 07222025 Print("Init No AcumulatedFloatingLoss FOUND!!!");
//           }
//
//         //if(AcumulatedFloatingLoss > 0)
//         //   BreakEvenPips = GetCurrentBreakEvenPips(AcumulatedFloatingLoss, Lots);
//
//        }
//      else
//        {
         // If Lots is 0, meaning auto-calculate Lots...
         // Calculating ProfitLossPerPIP by DesiredNetProfitVal
         
         // =====================================================================================
         // Need to CALCULATE CurrProfitLossPerPip here - used in CalcNewLotSize
         // =====================================================================================

// 24/02/2025
// No NEED for this code here -  CurrProfitLossPerPip calculated inside LotCalculate call...        
//         if(!PLperPipOrDesiredTP)
//         {
//            //ProfitLossPerPip = NormalizeDouble(DesiredNetProfitVal / (TakeProfitPips / 10), 2);
//            if(CalcbyTakeProfit)
//            {
//               CurrProfitLossPerPip = DesiredNetProfitVal / (TakeProfitPips / _TicksPerPIP);
//               // 07222025 Print("NEW1 ProfitLossPerPIP: " + DoubleToString(CurrProfitLossPerPip, 2) + " relative to DesiredNetProfit: " + DoubleToString(DesiredNetProfitVal, 2) + " and TakeProfitPips: " + DoubleToString(TakeProfitPips, 0));
//            }
//            else if(CalcRPbyTrigOrTailLevel)
//            {
//               CurrProfitLossPerPip = DesiredNetProfitVal / (TrailingTriggerPips / _TicksPerPIP);
//               // 07222025 Print("NEW2 ProfitLossPerPIP: " + DoubleToString(CurrProfitLossPerPip, 2) + " relative to DesiredNetProfit: " + DoubleToString(DesiredNetProfitVal, 2) + " and TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips, 0));
//            }
//            else
//            {
//               CurrProfitLossPerPip = DesiredNetProfitVal / (TrailingTailPips / _TicksPerPIP);
//               // 07222025 Print("NEW3 ProfitLossPerPIP: " + DoubleToString(CurrProfitLossPerPip, 2) + " relative to DesiredNetProfit: " + DoubleToString(DesiredNetProfitVal, 2) + " and TrailingTailPips: " + DoubleToString(TrailingTailPips, 0));
//            }
//          }
//         else
//         {
//            if(CalcbyTakeProfit) //  NEW 09/03/2024
//            {
//               // 07222025 Print(" ProfitLossPerPIP: " + DoubleToString(ProfitLossPerPIP, 2) + " relative to TakeProfitPips: " + DoubleToString(TakeProfitPips, 0));
//            }
//            else if(CalcRPbyTrigOrTailLevel)
//            {
//               // 07222025 Print("ProfitLossPerPIP: " + DoubleToString(ProfitLossPerPIP, 2) + " relative to TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips, 0));
//            }
//            else
//            {
//               // 07222025 Print("ProfitLossPerPIP: " + DoubleToString(ProfitLossPerPIP, 2) + " relative to TrailingTailPips: " + DoubleToString(TrailingTailPips, 0));
//            }
//         
//            CurrProfitLossPerPip = ProfitLossPerPip;  // NEW 12.13.2021 - If PL per PIP then just assign to CurrProfitLossPerPip!!!
//         }
         
         // =====================================================================================
         
         AcumulatedFloatingLoss = 0;
         bool bRes1 = GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss);
         
         if(bRes1)
           {
           
            if(ShowCompensateLossMsgBox)
            {
            int iRet = MessageBox("Do you want to COMPENSATE this Accumulated Loss now?",
                                  "$" + DoubleToString(AcumulatedFloatingLoss,2) + " Prior Accumulated Loss Found...",
                                  MB_YESNO);

            if(iRet == IDYES)  
            {            
               // 07222025 Print("Init Accumulated Loss REFRESHED to: " + DoubleToString(AcumulatedFloatingLoss,2));
            }
            else
               if(iRet == IDNO)
                 {
                     AcumulatedFloatingLoss = 0;
                     // 07222025 Print("Init Accumulated Loss REFRESHED to: " + DoubleToString(AcumulatedFloatingLoss,2));
                     
                     if(GlobalValDel(_GV_CURRENT_LOSS))
                     {
                        // 07222025 Print("Global Variable DELETED: _CURRENT_LOSS_ - " + DoubleToString(AcumulatedFloatingLoss,2));
                     }
                 }  
            }
            else 
            if(CompensateLossYesNo)
                  Print("Init Accumulated Loss REFRESHED... " + DoubleToString(AcumulatedFloatingLoss,2));
               else
               {
                     AcumulatedFloatingLoss = 0;
                     // 07222025 Print("Init Accumulated Loss REFRESHED to: " + DoubleToString(AcumulatedFloatingLoss,2));
                     
                     if(GlobalValDel(_GV_CURRENT_LOSS))
                     {
                        // 07222025 Print("Global Variable DELETED: _CURRENT_LOSS_ - " + DoubleToString(AcumulatedFloatingLoss,2));
                     }
               }
  
            
            //  06242025  -  Dont remove the Curr Loss...  Needed to ad on to!!!
            //if(GlobalValDel(_GV_CURRENT_LOSS))
            //         // 07222025 Print("Global Variable DELETED: _CURRENT_LOSS_ - " + DoubleToString(AcumulatedFloatingLoss,2));
                     
           }
         else
           {
            //  No CURENT_LOSS variable
//            if(AcumulatedFloatingLoss < 0)
//               {
//                  // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
//                  TransactionComplete = true;
//                  
//                  return(false);
//               }
               
            // 07222025 Print("Init No AcumulatedFloatingLoss FOUND!!!");
           }

         // 07222025 Print(DoubleToString(AcumulatedFloatingLoss,2));
         
         if (TransactionComplete)
         {
             // 07222025 Print(">>>CRITICAL: Transaction Complete Raised!!!");
             return(false);
         }

         // BreakEvenPips embbeded in CalcNewLotSize...
         //if(AcumulatedFloatingLoss > 0)
         //   BreakEvenPips = GetCurrentBreakEvenPips(AcumulatedFloatingLoss, Lots);

         //if(!RoundUpLots)
         //  {
         //      //Lots = NormalizeDouble((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
         //      Lots=NormalizeDouble(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
         //      ////// 07222025 Print("LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );
         //  }
         //  else
         //  {   //Lots = RoundUp((ProfitLossPerPip / (CurTickVal * TicksPerPIP)), LotsPrecision);
         //      Lots=RoundUp(CalcNewLotSize(AcumulatedFloatingLoss),LotsPrecision);
         //      ////// 07222025 Print("RoundUp LOTS: " + Lots + " TickValue: " + CurTickVal + " ProfitLossPerPip: " + ProfitLossPerPip );

        
     }
   else
     {
//      if(Lots > 0)     //  AutoLotGen is FALSE
//        {
//        
//         // 07222025 Print ("CRITICAL:  AutoLotGen = FALSE is Under Construction!!!");
//         TransactionComplete = true;
//                  
//         return(false);
//        
//         //ProfitLossPerPip = NormalizeDouble(Lots * TicksPerPIP * MarketInfo(Symbol(),MODE_TICKVALUE), PL_PipPrecision);
//         CurrProfitLossPerPip = Lots * TicksPerPIP * MarketInfo(Symbol(),MODE_TICKVALUE);
//         
//         //ProfitLossPerPip = NormalizeDouble(Lots * TicksPerPIP * UpdateTickVal(MarketInfo(Symbol(),MODE_TICKVALUE)), PL_PipPrecision);
//         //CurrProfitLossPerPip = ProfitLossPerPip;
//
//         // WARNING - YOu can't have desired Profit/Loss per PIP when hard-coding the Lot size
//         //CurrProfitLossPerPip = ProfitLossPerPip;
//         //// 07222025 Print("Desired ProfitLossPerPip: "+ ProfitLossPerPip);
//         //// 07222025 Print("Initial LOTs: " + Lots);
//         
//         if(ShowCompensateLossMsgBox)
//         {
//            AcumulatedFloatingLoss = 0;
//            if(GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
//              {
//               int iRet = MessageBox("Do you want to COMPENSATE this Accumulated Loss now?",
//                                     DepositCurrencyName + " "+ DoubleToString(AcumulatedFloatingLoss,2) + " Prior Accumulated Loss Found...",
//                                     MB_YESNO);
//   
//               if(iRet == IDYES)
//                 {
//                  Lots = CalcNewLotSize(AcumulatedFloatingLoss);
//                  // 07222025 Print("Init Accumulated Loss REFRESHED & LOTS Updated...");
//                 }
//               else
//                  if(iRet == IDNO)
//                    {
//                     if(GlobalValDel(_GV_CURRENT_LOSS))
//                       {
//                        AcumulatedFloatingLoss = 0;
//                        // 07222025 Print("<<< 5. AcumulatedFloatingLoss DELETED!");
//                       }
//                    }
//              }
//            else
//              {
//               if(AcumulatedFloatingLoss < 0)
//               {
//                  // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
//                  TransactionComplete = true;
//                  
//                  return(false);
//               }
//               
//               // 07222025 Print("Init No AcumulatedFloatingLoss FOUND!!!");
//              }
//         }
//         else
//         {
//            AcumulatedFloatingLoss = 0;
//            if(GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
//            {
//               // 07222025 Print("There is residual loss from a prior RUN...");
//            }
//            else
//            {
//               if(AcumulatedFloatingLoss < 0)
//               {
//                  // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
//                  TransactionComplete = true;
//                  
//                  return(false);
//               }
//               else
//               {
//                  // 07222025 Print("There is NO residual loss from a prior RUN...");
//               }
//            }
//            
//            if(CompensateLossYesNo)
//            {
//               Lots = CalcNewLotSize(AcumulatedFloatingLoss);
//               // 07222025 Print("Init Accumulated Loss REFRESHED & LOTS Updated...");
//            }
//            else
//            {
//               if(GlobalValDel(_GV_CURRENT_LOSS))
//               {
//                  AcumulatedFloatingLoss = 0;
//                  // 07222025 Print("<<< 6. AcumulatedFloatingLoss DELETED!");
//               }
//            }
//             
//         }
//
//
//         //  Lots remain as defined in SET file
//         //
//         //if(AcumulatedFloatingLoss > 0)
//         //   BreakEvenPips = GetCurrentBreakEvenPips(AcumulatedFloatingLoss, Lots);
//
//        }
//      else
//        {
//         // 07222025 Print("CRITICAL ERROR!!! - AutoLotGen is FALSE & Lots = 0");
//         TransactionComplete = true;
//         return(false);
//        }
     }
     
      // Pips must be with .000 behind decimal point
      // 07222025 Print("END_GenerateProtectionLevel");
      // 07222025 Print("Initial LOTs: " + DoubleToString(Lots));
      // 07222025 Print("CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
      // 07222025 Print("AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss,2));
      // 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel, Digits));
      // 07222025 Print("StopLossPips: " + DoubleToString(StopLossPips, Digits));
      // 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips, Digits));
      // 07222025 Print("dRiskRewardTPRatio: " + DoubleToString(dRiskRewardTPRatio));
      // 07222025 Print("TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips, Digits));
      // 07222025 Print("dRiskRewardTTRatio: " + DoubleToString(dRiskRewardTTRatio));
      // 07222025 Print("TrailingTailPips: " + DoubleToString(TrailingTailPips, Digits));
      // 07222025 Print("dRiskRewardTSRatio: " + DoubleToString(dRiskRewardTSRatio));
      // 07222025 Print("Break Even Pips: " + DoubleToString(BreakEvenPips));
   
      //02/21/2025
      // Beeing RUN individually above...
      Lots = CalcNewLotSize(AcumulatedFloatingLoss);
      // 07222025 Print("LOTS: " + DoubleToStr(Lots, 4) + " TickValue: " + DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),8) + " CurrProfitLossPerPip: " + DoubleToStr(CurrProfitLossPerPip, 4) );
      
   
      // May NOT be needed as it exist in Main Loop
      //    
      //ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand)+ATLevel+
      //                                                              DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+Separator+
      //                                                              TimeToStr(TimeOrderInitiated,TargetTimeFormat)+Separator+
      //                                                              ConvertSecondsToHHMMSS((uint)((GetTickCount() - LastStartTickTarget) / 1000)) + MeasureSec);

                         
  
   //PriceTargetLevel = PriceTarget;

   return(true);
   
  }


//  ===================================================================


//string ConvertSecondsToHHMMSS(double TimeSpenInSec)
//  {
//
//   double NumHours = 0;          //  There are 60 minutes per 1 Hour or 60 * 60 = 3600 seconds per 1 Hour
//   double NumMinutes = 0;        //  There are 60 sec per 1 Min
//   double NumSeconds = 0;
//
//   if(TimeSpenInSec < 0)
//   {
//      // 07222025 Print("ConvertSecondsToHHMMSS - NEGATIVE!!!");
//      TimeSpenInSec = 0;
//   }
//      
//   NumHours    = MathFloor(TimeSpenInSec / 3600);
//   NumMinutes  = MathFloor(MathMod(TimeSpenInSec / 60, 60));
//   NumSeconds  = MathMod(TimeSpenInSec, 60);
//
//   return(StringFormat("%02u:%02u:%02u",
//                       (uint)NumHours,
//                       (uint)NumMinutes,
//                       (uint)NumSeconds));
//  }


inline string ConvertSecondsToHHMMSS(double TimeSpenInSec)
{

   if(TimeSpenInSec < 0)
   {
      // 07222025 Print("ConvertSecondsToHHMMSS - NEGATIVE!!!");
      TimeSpenInSec = 0;
   }
      
   return(StringFormat("%02u:%02u:%02u",
                       (uint)MathFloor(TimeSpenInSec / 3600),
                       (uint)MathFloor(MathMod(TimeSpenInSec / 60, 60)),
                       (uint)MathMod(TimeSpenInSec, 60)));
}

//  ===================================================================


void DrawArrow(string objName,
               string objName2,
               double _TargetLevel,
               double _Arrow,
               bool _Background,
               int _ArrowAncor,
               double _ArrowColor,
               int _ArrowSize,
               double _ArrowOffsetHor,
               double _ArrowOffsetVer
              )
  {
   bool Res=false;
//if(!(ObjectFind(objName)<0))
//   ObjectDelete(objName);

//if(!(ObjectFind(objName2)<0))
//   ObjectDelete(objName2);

   if((ObjectFind(objName)<0))
     {
      if(!ObjectCreate(objName,
                       OBJ_ARROW,
                       0,
                       (datetime)(TimeCurrent()+(_ArrowOffsetHor*Period()*60)),
                       _TargetLevel+_ArrowOffsetVer
                      ))
        {
         // 07222025 Print("Error: can't create OBJ_ARROW code #",GetLastError());
         return;
        }

      ObjectSet(objName,
                OBJPROP_STYLE,
                STYLE_SOLID);

      if(_ArrowOffsetVer==0.0)
         ObjectSet(objName,
                   OBJPROP_ANCHOR,
                   _ArrowAncor);

      ObjectSet(objName,
                OBJPROP_ARROWCODE,
                _Arrow);

      ObjectSet(objName,
                OBJPROP_BACK,
                _Background);

      ObjectSet(objName,
                OBJPROP_COLOR,
                _ArrowColor);

      ObjectSet(objName,
                OBJPROP_WIDTH,
                _ArrowSize);

      ////// 07222025 Print("TargetLevel1: " + _TargetLevel);

     }
   else
     {
      if(!ObjectMove(ChartID(),
                     objName,
                     0,
                     (datetime)(TimeCurrent()+(_ArrowOffsetHor*Period()*60)),
                     _TargetLevel+_ArrowOffsetVer))
        {
         //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
        }

      ////// 07222025 Print("TargetLevel2: " + _TargetLevel);
     }

  }


//  ===================================================================


void DrawArrowEntry2(string objName,
                    string objName2,
                    double _TargetLevel,
                    double _Arrow,
                    bool _Background,
                    int _ArrowAncor,
                    double _ArrowColor,
                    int _ArrowSize,
                    double _ArrowOffsetHor,
                    double _ArrowOffsetVer)
  {

   if((ObjectFind(objName)<0))
     {
      if(!ObjectCreate(objName,
                       OBJ_ARROW,
                       0,
                       (datetime)(TimeCurrent()+(_ArrowOffsetHor*Period()*60)),
                       _TargetLevel+_ArrowOffsetVer
                      ))
        {
         // 07222025 Print("Error: can't create OBJ_ARROW code #",GetLastError());
         return;
        }

      ObjectSet(objName,
                OBJPROP_STYLE,
                STYLE_SOLID);

      if(_ArrowOffsetVer==0.0)
         ObjectSet(objName,
                   OBJPROP_ANCHOR,
                   _ArrowAncor);

      ObjectSet(objName,
                OBJPROP_ARROWCODE,
                _Arrow);

      ObjectSet(objName,
                OBJPROP_BACK,
                _Background);

      ObjectSet(objName,
                OBJPROP_COLOR,
                _ArrowColor);

      ObjectSet(objName,
                OBJPROP_WIDTH,
                _ArrowSize);

      //// 07222025 Print("DrawArrowEntry2: " + _TargetLevel);

     }
}



void DrawArrowEntry(string objName,
                    string objName2,
                    double _TargetLevel,
                    double _Arrow,
                    bool _Background,
                    int _ArrowAncor,
                    double _ArrowColor,
                    int _ArrowSize,
                    double _ArrowOffsetHor,
                    double _ArrowOffsetVer
                   )
  {
   bool Res=false;
//if(!(ObjectFind(objName)<0))
//   ObjectDelete(objName);

   if(!(ObjectFind(objName2)<0))
      ObjectDelete(objName2);

   if((ObjectFind(objName)<0))
     {
      if(!ObjectCreate(objName,
                       OBJ_ARROW,
                       0,
                       (datetime)(TimeCurrent()+(_ArrowOffsetHor*Period()*60)),
                       _TargetLevel+_ArrowOffsetVer
                      ))
        {
         // 07222025 Print("Error: can't create OBJ_ARROW code #",GetLastError());
         return;
        }

      ObjectSet(objName,
                OBJPROP_STYLE,
                STYLE_SOLID);

      if(_ArrowOffsetVer==0.0)
         ObjectSet(objName,
                   OBJPROP_ANCHOR,
                   _ArrowAncor);

      ObjectSet(objName,
                OBJPROP_ARROWCODE,
                _Arrow);

      ObjectSet(objName,
                OBJPROP_BACK,
                _Background);

      ObjectSet(objName,
                OBJPROP_COLOR,
                _ArrowColor);

      ObjectSet(objName,
                OBJPROP_WIDTH,
                _ArrowSize);

      ////// 07222025 Print("TargetLevel1: " + _TargetLevel);

     }
   else
     {
      if(!ObjectMove(ChartID(),
                     objName,
                     0,
                     (datetime)(TimeCurrent()+(_ArrowOffsetHor*Period()*60)),
                     _TargetLevel+_ArrowOffsetVer
                    ))
        {
         //// 07222025 Print("LastError: "+IntegerToString(GetLastError()));
        }

      ////// 07222025 Print("TargetLevel2: " + _TargetLevel);
     }

  }




bool MoveArrowEntry(string objName,
                    string objName2,
                    double _TargetLevel,
                    double _Arrow,
                    bool _Background,
                    int _ArrowAncor,
                    double _ArrowColor,
                    int _ArrowSize,
                    double _ArrowOffsetHor,
                    double _ArrowOffsetVer
                   )
{
   ResetLastError();
   
   if(ObjectFind(objName)>=0)
   {
      if(!ObjectMove(ChartID(),
                     objName,
                     0,
                     (datetime)(TimeCurrent()+(_ArrowOffsetHor * Period() * 60)),
                     _TargetLevel + _ArrowOffsetVer
                    ))
        {
         // 07222025 Print("MoveArrowEntry: LastError: "+IntegerToString(GetLastError()));
        }

      //// 07222025 Print("MoveArrowEntry: " + _TargetLevel);
      return true;
    }
    else
    {
      // 07222025 Print("Arrow Not found...");
      return false;
    }
}

//  ===================================================================


void ResetFirstTimeFlags()
  {

   FirstTickTarget          = true;
   FirstTickOpen            = true;
   FirstTickStop            = true;
   FirstTickProfit          = true;

  }


//  ===================================================================


string getUninitReasonText(int reasonCode)
  {
   string text="";
//---
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";
         break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";
         break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";
         break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";
         break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";
         break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";
         break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";
         break;
      default:
         text="Another reason";
     }

   return text;
  }


//  ===================================================================


string GetCurrentPL()
  {
   static double CurrentLoss = 0;
   static double CurrentComm = 0;
   static double CurrentSwap = 0;

//                              if(GetTicketInfo(CurOpenTicket,"PR",CurrentLoss))
//                                {
//                                 //CurrentLoss = MathAbs(CurrentLoss);
//                                 ////// 07222025 Print("CurrentLoss EXTRACTED successfully -> " + CurrentLoss);
//                                }
//                              else
//                                {
//                                 //// 07222025 Print("Can't EXTRACT CurrentLoss...");
//                                 return("");
//                                }
//
//                              if(GetTicketInfo(CurOpenTicket,"CO",CurrentComm))
//                                {
//                                 //CurrentComm = MathAbs(CurrentComm);
//                                 ////// 07222025 Print("CurrentComm EXTRACTED successfully -> " + CurrentComm);
//                                }
//                              else
//                                {
//                                 //// 07222025 Print("Can't EXTRACT CurrentComm...");
//                                 return("");
//                                }
//
//                              if(GetTicketInfo(CurOpenTicket,"SW",CurrentSwap))
//                                {
//                                 //CurrentSwap = MathAbs(CurrentSwap);
//                                 ////// 07222025 Print("CurrentSwap EXTRACTED successfully -> " + CurrentSwap);
//                                }
//                              else
//                                {
//                                 //// 07222025 Print("Can't EXTRACT CurrentComm...");
//                                 return("");
//                                }

   uint SuspendCounter = 0;
   uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
   bool isOrderSelected = OrderSelect(CurOpenTicket, SELECT_BY_TICKET,MODE_TRADES);
   uint thisTickValue = GetTickCount();

   while(!isOrderSelected &&
         ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel))
     {
      Sleep(SuspendThread_TimePeriod);
      SuspendCounter++;

      isOrderSelected = OrderSelect(CurOpenTicket, SELECT_BY_TICKET,MODE_TRADES);
     }


   if(isOrderSelected)
     {
      CurrentLoss = OrderProfit();
      CurrentComm = OrderCommission();
      CurrentSwap = OrderSwap();


      double TotalNETLoss = (CurrentLoss) + (CurrentComm) + (CurrentSwap) - (AcumulatedFloatingLoss);
      //// 07222025 Print("CurrentLoss: " + DoubleToString(CurrentLoss) + " CurrentComm: " + DoubleToString(CurrentComm) + " CurrentSwap: " + DoubleToString(CurrentSwap) + " AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));

      return(" " + DoubleToString(TotalNETLoss, 2) + " " + DepositCurrencyName);
      //return(DoubleToString(TotalNETLoss, 2));
     }
   else
     {
      int Err = GetLastError();
      // 07222025 Print("GetCurrentPL: GetTicketInfo() - Can\'t OrderSelect: " + IntegerToString(CurOpenTicket));

      return("Critical Error!!!");
     }

   return("Critical Error!!!");


// ====================================================================================================

//     double CurrProfLoss;
//
//     if(GetTicketInfo(CurOpenTicket, "PR", CurrProfLoss))
//      {
//         //CurrentLoss = MathAbs(CurrentLoss);
//         ////// 07222025 Print("CurrProfLoss EXTRACTED successfully -> " + CurrProfLoss);
//         return(CurrProfLoss);
//      }
//      else
//      {
//         ////// 07222025 Print("Can't EXTRACT CurrProfLoss...");
//         return("");
//      }

  }

//  ==================================================================

// Usage: UpdateCurrentPL(GetCurrentPL());
//
void UpdateCurrentPL(string CurrProfitLoss)
{

   ArrayFree(PLresult1);
   //ArraySize
                                                                         //>>>>> $
   //int k = StringSplit(ObjectGetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT), PLu_sep, PLresult);
   
   int k = StringSplit(ObjectGetString(ChartID(), "PositionLocationValue",OBJPROP_TEXT), 
                       CURRENCY_SIGN_DELIMITER,  
                       PLresult1);
   
   //// 07222025 Print("Current PositionLocationValue: " + ObjectGetString(ChartID(), "PositionLocationValue",OBJPROP_TEXT));   
   //// 07222025 Print("Separator is: " + CharToStr(CURRENCY_SIGN_DELIMITER));                                    
   //// 07222025 Print("K is: " + IntegerToString(k,2));
   //// 07222025 Print("PLresult0 is: " + PLresult1[0]);
   //// 07222025 Print("PLresult1 is: " + PLresult1[1]);
   //// 07222025 Print("PLresult LENGTH is: " + IntegerToString(StringLen(PLresult1[0])));
   
   string FinalConcatString = PLresult1[0] + CharToStr(CURRENCY_SIGN_DELIMITER) + CurrProfitLoss;

   //// 07222025 Print("FinalConcatString: " + FinalConcatString);
   
   ObjectSetString(ChartID(),
                   "PositionLocationValue",
                   OBJPROP_TEXT,
                   FinalConcatString);

}


//  ===================================================================


void SetALLLineLevels()
  {

//// 07222025 Print("<<< INSIDE SetALLLineLevels >>>");

   if(((ExecCommand==BUY_STOP)) || ((ExecCommand==BUY_LIMIT)))
     {

      //PriceTargetLevel = AccuChop_ToFracNum(PriceTarget);
      //PriceTargetLevel = PriceTarget;
      
      //// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel);
      
      
      DrawArrowEntry(objUpArrowTarget,
                     objDownArrowTarget,
                     PriceTargetLevel,
                     ArrowUP,
                     ArrowUPBackground,
                     ANCHOR_BOTTOM,
                     ArrowUPColor,
                     ArrowUPSize,
                     ArrowUPOffsetHor,
                     ArrowUPOffsetVer
                    );

      //StopLossLevel = PriceTargetLevel - MathRound(StopLossPips * Point);
      StopLossLevel = PriceTargetLevel - (StopLossPips * Point);
      //// 07222025 Print("StopLossLevel: " + StopLossLevel);

      DrawArrow(objStopArrow,
                objStopArrow,
                StopLossLevel,
                StopArrow,
                StopArrowBackground,
                ANCHOR_TOP,
                StopArrowColor,
                StopArrowSize,
                StopArrowOffsetHor,
                StopArrowOffsetVer
               );

      //TakeProfitLevel = PriceTargetLevel + MathRound(TakeProfitPips * Point);
      TakeProfitLevel = PriceTargetLevel + (TakeProfitPips * Point);
      //// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);

      if(DrawProfitLevel)
      DrawArrow(objProfitArrow,
                objProfitArrow,
                TakeProfitLevel,
                ProfitArrow,
                ProfitArrowBackground,
                ANCHOR_BOTTOM,
                ProfitArrowColor,
                ProfitArrowSize,
                ProfitArrowOffsetHor,
                ProfitArrowOffsetVer
               );

#ifdef   _TrailingStop_
      if(DrawTTriggerLevel)
        {
         //TrailingTriggerLevel = PriceTargetLevel + MathRound(TrailingTriggerPips * Point);
         TrailingTriggerLevel = PriceTargetLevel + (TrailingTriggerPips * Point);
         //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);

         //TrailingTailLevel = TrailingTriggerLevel - MathRound(TrailingTailPips * Point);
         TrailingTailLevel = PriceTargetLevel + (TrailingTailPips * Point);
         //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);

         DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
         DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
        }
        else
        {
         if(!(ObjectFind(objTTriggerArrow)<0))
            ObjectDelete(objTTriggerArrow);

         if(!(ObjectFind(objTTailArrow)<0))
            ObjectDelete(objTTailArrow);            
        }
#endif

      if(!ObjectSetInteger(ChartID(),"ExecutePositionValue",OBJPROP_COLOR, ExecPosLONG)) {}
      //Debug("Error Setting Color: " + IntegerToString(GetLastError()));
     }
   else
      if(((ExecCommand==SELL_STOP)) || ((ExecCommand==SELL_LIMIT)))
        {

         PriceTargetLevel=AccuChop_ToFracNum(PriceTargetLevel);
         //// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel);

         DrawArrowEntry(objDownArrowTarget,
                        objDownArrowTarget,
                        PriceTargetLevel,
                        ArrowDOWN,
                        ArrowDOWNBackground,
                        ANCHOR_TOP,
                        ArrowDOWNColor,
                        ArrowDOWNSize,
                        ArrowDOWNOffsetHor,
                        ArrowDOWNOffsetVer
                       );

         //StopLossLevel = PriceTargetLevel + MathRound(StopLossPips * Point);
         StopLossLevel = PriceTargetLevel + (StopLossPips * Point);
         //// 07222025 Print("StopLossLevel: " + StopLossLevel);

         DrawArrow(objStopArrow,
                   objStopArrow,
                   StopLossLevel,
                   StopArrow,
                   StopArrowBackground,
                   ANCHOR_BOTTOM,
                   StopArrowColor,
                   StopArrowSize,
                   StopArrowOffsetHor,
                   StopArrowOffsetVer
                  );

         //TakeProfitLevel = PriceTargetLevel - MathRound(TakeProfitPips * Point);
         TakeProfitLevel = PriceTargetLevel - (TakeProfitPips * Point);
         //// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);
         
         if(DrawProfitLevel)
         DrawArrow(objProfitArrow,
                   objProfitArrow,
                   TakeProfitLevel,
                   ProfitArrow,
                   ProfitArrowBackground,
                   ANCHOR_TOP,
                   ProfitArrowColor,
                   ProfitArrowSize,
                   ProfitArrowOffsetHor,
                   ProfitArrowOffsetVer
                  );

#ifdef   _TrailingStop_
         if(DrawTTriggerLevel)
           {
            //TrailingTriggerLevel = PriceTargetLevel - MathRound(TrailingTriggerPips * Point);
            TrailingTriggerLevel = PriceTargetLevel - (TrailingTriggerPips * Point);
            //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);

            //TrailingTailLevel = TrailingTriggerLevel + MathRound(TrailingTailPips * Point);
            TrailingTailLevel = PriceTargetLevel - (TrailingTailPips * Point);
            //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);

            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
           }
           else
           {
            if(!(ObjectFind(objTTriggerArrow)<0))
               ObjectDelete(objTTriggerArrow);

            if(!(ObjectFind(objTTailArrow)<0))
               ObjectDelete(objTTailArrow);            
           }

         if(!ObjectSetInteger(ChartID(),"ExecutePositionValue",OBJPROP_COLOR,ExecPosSHORT)) {}
         //Debug("Error Setting Color: " + IntegerToString(GetLastError()));
#endif

        }

//// 07222025 Print("<<< EXIT SetALLLineLevels >>>");

  }


//  ===================================================================


void DrawAllArrows()
  {

//// 07222025 Print("<<< Inside DrawAllArrows >>>");
//// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel);
//// 07222025 Print("StopLossLevel: " + StopLossLevel);
//// 07222025 Print("TakeProfitLevel: " + TakeProfitLevel);

   if(((ExecCommand==BUY_STOP)) || ((ExecCommand==BUY_LIMIT)))
     {
      
      //if(!(ObjectFind(objUpArrowTarget)<0))
      //   ObjectDelete(objUpArrowTarget);
   
      DrawArrowEntry(objUpArrowTarget,
                     objDownArrowTarget,
                     PriceTargetLevel,
                     ArrowUP,
                     ArrowUPBackground,
                     ANCHOR_BOTTOM,
                     ArrowUPColor,
                     ArrowUPSize,
                     ArrowUPOffsetHor,
                     ArrowUPOffsetVer
                    );

      DrawArrow(objStopArrow,
                objStopArrow,
                StopLossLevel,
                StopArrow,
                StopArrowBackground,
                ANCHOR_TOP,
                StopArrowColor,
                StopArrowSize,
                StopArrowOffsetHor,
                StopArrowOffsetVer
               );

      if(DrawProfitLevel)
      DrawArrow(objProfitArrow,
                objProfitArrow,
                TakeProfitLevel,
                ProfitArrow,
                ProfitArrowBackground,
                ANCHOR_BOTTOM,
                ProfitArrowColor,
                ProfitArrowSize,
                ProfitArrowOffsetHor,
                ProfitArrowOffsetVer
               );

//  BreakEven Arrow drawn only prior to opening market order
//  No NEED to be re-Drawn
      if(ShowBreakEvenLine && (BreakEvenPips>=0) && OrderOpened)
         DrawArrow(objBreakEvenArrow,
                   objBreakEvenArrow,
                   dBreakEvenLevel,
                   BreakEvenArrow,
                   BreakEvenArrowBackground,
                   ANCHOR_BOTTOM,
                   BreakEvenArrowColor,
                   BreakEvenArrowSize,
                   BreakEvenArrowOffsetHor,
                   BreakEvenArrowOffsetVer
                  );
                  
#ifdef _PARTIAL_CLOSE_                  
                  //  01.15.2025 - Partial Close...
                  if(ShowPartialCloseLine && (StopLossPips > 0) && OrderOpened)                
                     DrawArrow(objPartialCloseArrow,
                               objPartialCloseArrow,
                               PartialCloseLevel,
                               PartialCloseArrow,
                               PartialCloseArrowBackground,
                               ANCHOR_BOTTOM,
                               PartialCloseArrowColor,
                               PartialCloseArrowSize,
                               PartialCloseArrowOffsetHor,
                               PartialCloseArrowOffsetVer
                               );       
#endif
                  

#ifdef   _TrailingStop_
      //if(!TTriggerActivated)
      //  {
         if(DrawTTriggerLevel)
           {
            DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_BOTTOM,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
            DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_TOP,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
           }
           else
           {
            if(!(ObjectFind(objTTriggerArrow)<0))
               ObjectDelete(objTTriggerArrow);

            if(!(ObjectFind(objTTailArrow)<0))
               ObjectDelete(objTTailArrow);           
           }
        //}
#endif

     }
   else
      if(((ExecCommand==SELL_STOP)) || ((ExecCommand==SELL_LIMIT)))
        {
        
         if(!(ObjectFind(objDownArrowTarget)<0))
            ObjectDelete(objDownArrowTarget);
         
         DrawArrowEntry(objDownArrowTarget,
                        objUpArrowTarget,
                        PriceTargetLevel,
                        ArrowDOWN,
                        ArrowDOWNBackground,
                        ANCHOR_TOP,
                        ArrowDOWNColor,
                        ArrowDOWNSize,
                        ArrowDOWNOffsetHor,
                        ArrowDOWNOffsetVer
                       );

         DrawArrow(objStopArrow,
                   objStopArrow,
                   StopLossLevel,
                   StopArrow,
                   StopArrowBackground,
                   ANCHOR_BOTTOM,
                   StopArrowColor,
                   StopArrowSize,
                   StopArrowOffsetHor,
                   StopArrowOffsetVer
                  );

         if(DrawProfitLevel)
         DrawArrow(objProfitArrow,
                   objProfitArrow,
                   TakeProfitLevel,
                   ProfitArrow,
                   ProfitArrowBackground,
                   ANCHOR_TOP,
                   ProfitArrowColor,
                   ProfitArrowSize,
                   ProfitArrowOffsetHor,
                   ProfitArrowOffsetVer
                  );


         if(ShowBreakEvenLine && (BreakEvenPips>=0) && OrderOpened)
            DrawArrow(objBreakEvenArrow,
                      objBreakEvenArrow,
                      dBreakEvenLevel,
                      BreakEvenArrow,
                      BreakEvenArrowBackground,
                      ANCHOR_TOP,
                      BreakEvenArrowColor,
                      BreakEvenArrowSize,
                      BreakEvenArrowOffsetHor,
                      BreakEvenArrowOffsetVer
                     );
                     
#ifdef _PARTIAL_CLOSE_                  
                  //  01.15.2025 - Partial Close...
                  if(ShowPartialCloseLine && (StopLossPips > 0) && OrderOpened)                
                     DrawArrow(objPartialCloseArrow,
                               objPartialCloseArrow,
                               PartialCloseLevel,
                               PartialCloseArrow,
                               PartialCloseArrowBackground,
                               ANCHOR_TOP,
                               PartialCloseArrowColor,
                               PartialCloseArrowSize,
                               PartialCloseArrowOffsetHor,
                               PartialCloseArrowOffsetVer
                               );       
#endif
                     

#ifdef   _TrailingStop_
         //if(!TTriggerActivated)
         //  {
            if(DrawTTriggerLevel)
              {
               DrawArrow(objTTriggerArrow,"",TrailingTriggerLevel,TTriggerArrow,TTriggerArrowBackground,ANCHOR_TOP,TTriggerArrowColor,TTriggerArrowSize,TTriggerArrowOffsetHor,TTriggerArrowOffsetVer);
               DrawArrow(objTTailArrow,"",TrailingTailLevel,TTailArrow,TTailArrowBackground,ANCHOR_BOTTOM,TTailArrowColor,TTailArrowSize,TTailArrowOffsetHor,TTailArrowOffsetVer);
              }
              else
              {
               if(!(ObjectFind(objTTriggerArrow)<0))
                  ObjectDelete(objTTriggerArrow);
   
               if(!(ObjectFind(objTTailArrow)<0))
                  ObjectDelete(objTTailArrow);
              }
           //}
#endif

        }

//// 07222025 Print("<<< Exit DrawAllArrows >>>");
  }


//  ===================================================================


void DrawInitialPanel()
{
   // Determind later after initiating Line objects
   //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir) + CurrentPosition);
   
   ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" Lots "+EnumToString(ExecCommand));
   ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,OutcomeStr);
   ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,OutcomeStr);
   
   DrawALLLinesMetrixs();
   //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,IntegerToString(0) + " of " + IntegerToString(NumTimesToProtect));
   //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops)+" of "+StringFormat("%02d",NumTimesToProtect));
   ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
}


//  ===================================================================


void DrawALLLinesMetrixs()
{
   ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,DoubleToStr(PriceTargetLevel,Digits));
   
   ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                          DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);
   
   if(DrawProfitLevel)
      ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                               DoubleToStr(TakeProfitPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                               RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
   else
      ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,TakeProfitDisabled);
   
   
   #ifdef   _TrailingStop_
   if(DrawTTriggerLevel)
     {
      ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                                                                    DoubleToStr(TrailingTriggerPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                    RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));
   
      ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,DoubleToStr(TrailingTailLevel,Digits)+Separator+
                                                                 DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                 DoubleToStr(MathAbs(TrailingTriggerLevel - TrailingTailLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                 RiskRewardRatio+DoubleToStr(dRiskRewardTSRatio,2));
     }
   else
     {
      ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,TTriggerDisabled);
      ObjectSetString(ChartID(),"TrailingTailValue",OBJPROP_TEXT,TTailDisabled);
     }
   #endif

}


//  ===================================================================


void DrawALLLines()
  {

//// 07222025 Print("<<< INSIDE DrawALLLines >>>");
//// 07222025 Print("PriceDir: " + EnumToString(PriceDir));
//// 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
//// 07222025 Print("StopLossLevel: " + DoubleToString(StopLossLevel));
//// 07222025 Print("TakeProfitLevel: " + DoubleToString(TakeProfitLevel));

   if(PriceDir==ABOVE)
     {
      if(DrawTargetLevel)
        {
         DrawHorizontalLine(objPriceTargetLevelLineName,
                            PriceTargetLevel,
                            TargetLineStyle,
                            TargetLineColor,
                            TargetLineWidth,
                            TargetBackground,
                            "PriceTargetLevelLine");
        }
     }
   else
      if(PriceDir==BELOW)
        {
         if(DrawTargetLevel)
           {
            DrawHorizontalLine(objPriceTargetLevelLineName,
                               PriceTargetLevel,
                               TargetLineStyle,
                               TargetLineColor2,
                               TargetLineWidth,
                               TargetBackground,
                               "PriceTargetLevelLine");
           }
        }
      else
         //if(PriceDir==INSIDE)
         //  {
            if(DrawTargetLevel)
              {
               DrawHorizontalLine(objPriceTargetLevelLineName,
                                  PriceTargetLevel,
                                  TargetLineStyle,
                                  TargetLineColor3,
                                  TargetLineWidth,
                                  TargetBackground,
                                  "PriceTargetLevelLine");
              }
        //   }


   if(AutoFireAfterSL)
     {
      if(DrawStopLevel)
        {
         DrawHorizontalLine(objStopLossLevelLineName,
                            StopLossLevel,
                            StopLineStyle,
                            StopLineColor,
                            StopLineWidth,
                            StopBackground,
                            "StopLossLevelLine");
        }
     }
   else
     {
      if(DrawStopLevel)
        {
         DrawHorizontalLine(objStopLossLevelLineName,
                            StopLossLevel,
                            DASH,
                            StopLineColor,
                            StopLineWidth,
                            StopBackground,
                            "StopLossLevelLine");
        }
     }


   if(AutoFireAfterTP)
     {
      if(DrawProfitLevel)
        {
         DrawHorizontalLine(objTakeProfitLevelLineName,
                            TakeProfitLevel,
                            ProfitLineStyle,
                            ProfitLineColor,
                            ProfitLineWidth,
                            ProfitBackground,
                            "TakeProfitLevelLine");
        }
     }
   else
     {
      if(DrawProfitLevel)
        {
         DrawHorizontalLine(objTakeProfitLevelLineName,
                            TakeProfitLevel,
                            DASH,
                            ProfitLineColor,
                            ProfitLineWidth,
                            ProfitBackground,
                            "TakeProfitLevelLine");
        }
     }


#ifdef   _TrailingStop_
   if(TTriggerLineActive)
     {
      //// 07222025 Print("TTriggerLineActive: " + TTriggerLineActive);

      if(DrawTTriggerLevel)
        {
         DrawHorizontalLine(objTrailingTriggerLevelLineName,
                            TrailingTriggerLevel,
                            TTriggerLineStyle,
                            TTriggerLineColor,
                            TTriggerLineWidth,
                            TTriggerLineBackground,
                            "TrailingTriggerLevelLine");

         DrawHorizontalLine(objTrailingTailLevelLineName,
                            TrailingTailLevel,
                            TTailLineStyle,
                            TTailLineColor,
                            TTailLineWidth,
                            TTailLineBackground,
                            "TrailingTailLevelLine");
        }
        else
        {
          if(!(ObjectFind(objTrailingTriggerLevelLineName)<0))
            ObjectDelete(objTrailingTriggerLevelLineName);

          if(!(ObjectFind(objTrailingTailLevelLineName)<0))
            ObjectDelete(objTrailingTailLevelLineName);         
        }
     }
   else
     {
      //// 07222025 Print("TTriggerLineActive: " + TTriggerLineActive);

      if(DrawTTriggerLevel)
        {
         DrawHorizontalLine(objTrailingTriggerLevelLineName,
                            TrailingTriggerLevel,
                            DASH,
                            TTriggerLineColor,
                            TTriggerLineWidth,
                            TTriggerLineBackground,
                            "TrailingTriggerLevelLine");

         DrawHorizontalLine(objTrailingTailLevelLineName,
                            TrailingTailLevel,
                            TTailLineStyle,
                            TTailLineColor,
                            TTailLineWidth,
                            TTailLineBackground,
                            "TrailingTailLevelLine");
        }
        else
        {
          if(!(ObjectFind(objTrailingTriggerLevelLineName)<0))
            ObjectDelete(objTrailingTriggerLevelLineName);

         if(!(ObjectFind(objTrailingTailLevelLineName)<0))
            ObjectDelete(objTrailingTailLevelLineName);
        }

     }
#endif

//// 07222025 Print("<<< EXIT DrawALLLines >>>");
   ChartRedraw();
  }


//  ===================================================================


void MoveALLLines()
{
   if(DrawTargetLevel)
      MoveHLine(objPriceTargetLevelLineName,
                PriceTargetLevel);

   if(DrawStopLevel)
      MoveHLine(objStopLossLevelLineName,
                StopLossLevel);

   if(DrawProfitLevel)
      MoveHLine(objTakeProfitLevelLineName,
                TakeProfitLevel);

#ifdef   _TrailingStop_
   if(DrawTTriggerLevel)
     {
      MoveHLine(objTrailingTriggerLevelLineName,
                TrailingTriggerLevel);

      MoveHLine(objTrailingTailLevelLineName,
                TrailingTailLevel);
     }
#endif

ChartRedraw();

}


//  ===================================================================


void RefreshDirection2()
  {
////// 07222025 Print("<<< INSIDE RefreshDirection2 >>>");

//static MarketRefPoints CurrDir;
//
//
//   if((Bid<PriceTargetLevel) &&
//      (Ask<=PriceTargetLevel))
//        {
//         // ABOVE
//         CurrDir = ABOVE;
//        }
//    else if((Bid>=PriceTargetLevel) &&
//            (Ask>PriceTargetLevel))
//        {
//         // BELOW
//         CurrDir = BELOW;
//        }
//    else if((Bid<PriceTargetLevel) &&
//            (Ask>PriceTargetLevel))
//        {
//         // INSIDE
//         CurrDir = INSIDE;
//        }
//
//AjustColorsAccordingToDir(CurrDir);

//if(LastPriceDir != PriceDir)
//   //// 07222025 Print("PriceDir CHANGED!!! From: " + LastPriceDir + " To: " + PriceDir + " At: " + TimeToString(TimeCurrent()));

   RefreshRates();
   if(ExecCommand==BUY_STOP)
     {
      if((NormalizeDouble(PriceTargetLevel,Digits)-Ask)<=(PTBufferPips*Point))
        {
         PriceTargetLevel = NormalizeDouble(Ask+(PTBufferPips*Point),Digits);
         SetALLLineLevels();
         DrawALLLines();
        }
     }
   else
      if(ExecCommand==SELL_STOP)
        {
         if((Bid-NormalizeDouble(PriceTargetLevel,Digits))<=(PTBufferPips*Point))
           {
            PriceTargetLevel = NormalizeDouble(Bid -(PTBufferPips*Point),Digits);
            SetALLLineLevels();
            DrawALLLines();
           }
        }
      else
         if(ExecCommand==BUY_LIMIT)
           {
            if((Ask-NormalizeDouble(PriceTargetLevel,Digits))<=(PTBufferPips*Point))
              {
               PriceTargetLevel = NormalizeDouble(Ask -(PTBufferPips*Point),Digits);
               SetALLLineLevels();
               DrawALLLines();
              }
           }
         else
            if(ExecCommand==SELL_LIMIT)
              {
               if((NormalizeDouble(PriceTargetLevel,Digits)-Bid)<=(PTBufferPips*Point))
                 {
                  PriceTargetLevel = NormalizeDouble(Bid+(PTBufferPips*Point),Digits);
                  SetALLLineLevels();
                  DrawALLLines();
                 }
              }

////// 07222025 Print("OnHold: " + OnHold);

////// 07222025 Print("<<< EXIT RefreshDirection2 >>>");

  }


//  ==================================================================


void DrawTargetLayout()
  {
   int FBar=0;

   if(TargetLayoutWidth==0)
     {
      FBar=WindowFirstVisibleBar();
      //// 07222025 Print("FBar: " + FBar);
     }
   else
     {
      FBar=TargetLayoutWidth;     //  Only last 12 bars width for example...
      //// 07222025 Print("FBar: " + FBar);
     }

   if(byTakeProfit)
     {
      // Draw RECTANGLE between Entry Point and Take Profit Level
      CreateLayoutRect(Time[FBar],
                       PriceTargetLevel,
                       Time[0],//t2 = (datetime)MarketInfo(Symbol(), MODE_TIME) + (_SpreadRectWidth * Period() * 60);
                       TakeProfitLevel,// TakePROFIT
                       objTargetLayoutMap,TargetLayoutRectColor,TargetLayoutRectBackGround);

     }

#ifdef   _TrailingStop_
   else
      if(byTrailingTrigger)
        {
         // Draw RECTANGLE between Entry Point and Trailing Trigger Level
         CreateLayoutRect(Time[FBar],
                          PriceTargetLevel,
                          Time[0],
                          TrailingTriggerLevel,// TrailingTRIGGER
                          objTargetLayoutMap,TargetLayoutRectColor,TargetLayoutRectBackGround);
        }
      else
         if(byTrailingStop)
           {
            // Draw RECTANGLE between Entry Point and Trailing Stop Level
            CreateLayoutRect(Time[FBar],
                             PriceTargetLevel,
                             Time[0],
                             TrailingTailLevel,// TrailingSTOP
                             objTargetLayoutMap,TargetLayoutRectColor,TargetLayoutRectBackGround);
           }
#endif

  }


//  ==================================================================


void DrawRiskLayout()
  {
   int FBar=0;

   if(RiskLayoutWidth==0)
     {
      FBar=WindowFirstVisibleBar();
      //// 07222025 Print("FBar: " + FBar);
     }
   else
     {
      FBar=TargetLayoutWidth;     //  Only last 12 bars width for example...
      //// 07222025 Print("FBar: " + FBar);
     }

// Draw RECTANGLE between Entry Point and Take Profit Level
   CreateLayoutRect(Time[FBar],
                    PriceTargetLevel,
                    Time[0],//t2 = (datetime)MarketInfo(Symbol(), MODE_TIME) + (_SpreadRectWidth * Period() * 60);
                    StopLossLevel,// StopLOSS
                    objRiskLayoutMap,RiskLayoutRectColor,RiskLayoutRectBackGround);

  }


//  ==================================================================


void CreateLayoutRect(datetime t1,double p1,datetime t2,double p2,string name,color _LayoutRectColor,bool __LayoutRectColortBackground)
  {

   if(ObjectFind(name)!=-1)
      ObjectDelete(name);

   if(!ObjectCreate(name,OBJ_RECTANGLE,0,t1,p1,t2,p2))
     {
      // 07222025 Print("Error: can't create OBJ_RECTANGLE code #",GetLastError());
      return;
     }

   ObjectSet(name,OBJPROP_BACK,__LayoutRectColortBackground);
   ObjectSet(name,OBJPROP_COLOR,_LayoutRectColor);

   ObjectSet(name,OBJPROP_STYLE,TargetLayoutLineStyle);     // ENUM_LINE_STYLE - Line Style   STYLE_DASH   STYLE_DOT
   ObjectSet(name,OBJPROP_WIDTH,TargetLayoutLineWidth);               // int - WIDTH
//
//   ObjectSet(name,OBJPROP_SELECTABLE,false); //   bool - Non-Selectable

   WindowRedraw();

  }


//  ==================================================================


void MoveRiskLayout()
  {

   int FBar=0;

   if(RiskLayoutWidth==0)
     {
      FBar=WindowFirstVisibleBar();
      // 07222025 Print("MoveRiskLayout -> FBar: " + IntegerToString(FBar));
     }
   else
     {
      FBar=TargetLayoutWidth;     //  Only last 12 bars width for example...
      // 07222025 Print("MoveRiskLayout -> FBar: " + IntegerToString(FBar));
     }

// Draw RECTANGLE between Entry Point and Take Profit Level
   MoveLayoutRect(Time[FBar],
                  PriceTargetLevel,
                  Time[0],//t2 = (datetime)MarketInfo(Symbol(), MODE_TIME) + (_SpreadRectWidth * Period() * 60);
                  StopLossLevel,// TakePROFIT
                  objRiskLayoutMap);

  }


//  ==================================================================


void MoveTargetLayout()
  {

   int FBar=0;

   if(TargetLayoutWidth==0)
     {
      FBar=WindowFirstVisibleBar();
      // 07222025 Print("MoveTargetLayout -> FBar: " + IntegerToString(FBar));
     }
   else
     {
      FBar=TargetLayoutWidth;     //  Only last 12 bars width for example...
      // 07222025 Print("MoveTargetLayout -> FBar: " +IntegerToString(FBar));
     }

   if(byTakeProfit)
     {
      // Draw RECTANGLE between Entry Point and Take Profit Level
      MoveLayoutRect(Time[FBar],
                     PriceTargetLevel,
                     Time[0],//t2 = (datetime)MarketInfo(Symbol(), MODE_TIME) + (_SpreadRectWidth * Period() * 60);
                     TakeProfitLevel,// TakePROFIT
                     objTargetLayoutMap);

     }
#ifdef   _TrailingStop_
   else
      if(byTrailingTrigger)
        {
         // Draw RECTANGLE between Entry Point and Trailing Trigger Level
         MoveLayoutRect(Time[FBar],
                        PriceTargetLevel,
                        Time[0],
                        TrailingTriggerLevel,// TrailingTRIGGER
                        objTargetLayoutMap);
        }
      else
         if(byTrailingStop)
           {
            // Draw RECTANGLE between Entry Point and Trailing Stop Level
            MoveLayoutRect(Time[FBar],
                           PriceTargetLevel,
                           Time[0],
                           TrailingTailLevel,// TrailingSTOP
                           objTargetLayoutMap);
           }
#endif

  }


// ================================================================================================================


void MoveLayoutRect(datetime t1,double p1,datetime t2,double p2,string name)
  {

   ObjectSet(name,OBJPROP_TIME1,t1);
   ObjectSet(name,OBJPROP_PRICE1,p1);
   ObjectSet(name,OBJPROP_TIME2,t2);
   ObjectSet(name,OBJPROP_PRICE2,p2);

//ObjectSet(name,OBJPROP_COLOR,_LayoutRectColor);
//ObjectSet(name,OBJPROP_BACK,__LayoutRectColortBackground);

   WindowRedraw();

  }


// ================================================================================================================


//void GlobalInitialize()
//  {
//   double lPriceTarget = AccuChop_ToFracNum(PriceTarget);
//   PriceDir=GetCurrentPriceDirection(lPriceTarget);
//   AjustColorsAccordingToDir(PriceDir);
//
////  Assign PriceTargetLevel for the FIRST Time
//
//   //  Corrected 20.01.2020
//   SetALLLineLevels();
//   DrawALLLines();
//   DrawInitialPanel();
//   
//   
//   //DrawInitialPanel();
//   //SetALLLineLevels();
//   //DrawALLLines();
//
////WindowRedraw();
//  }


// ================================================================================================================

#ifdef _Envelopes_Slider_
void DrawEntryOnEnvelope()
  {
   PriceTargetLevel=Get_SliderVAL();
   PriceTargetLevel=PriceTargetLevel;

   SetALLLineLevels();
   DrawALLLines();

//// 07222025 Print("Envelopes_Slider SET: " + PriceTargetLevel);
  }
#endif

// ================================================================================================================


string GetFilterCode()
  {
   int Ret=0;
   string wStr="";

   Ret=FilterKey(wStr);

   if(Ret>0)
     {
      string PureVal[];
      int iRet=StringSplit(wStr,StringGetCharacter(":",0),PureVal);

      return(PureVal[1]);
     }
   else
     {
      return("");
     }
  }



//  =====================================================================================================================================


int OnInit()
{ 
   
   //  Delete All Globval Vars - leave only _GV_CURRENT_LOSS if exists
   if(MasterSlave)
   {
   
      double CurrentLossFromPreviousRun;
      
      if( GlobalValEXIST(_GV_CURRENT_LOSS) )
      {
         if(GlobalValGet(_GV_CURRENT_LOSS, CurrentLossFromPreviousRun))
            {
               // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " GET successfully..." + DoubleToString(CurrentLossFromPreviousRun));
            }
         else
            {
               // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " CAN'T  GET...");
            }
   
         DeleteAllGlobalVariables();
            
         
         if(GlobalValSet(_GV_CURRENT_LOSS, CurrentLossFromPreviousRun) )
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_LOSS + " SET Successfully TO: " + DoubleToString(CurrentLossFromPreviousRun));
            }
          else
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_LOSS + " CAN'T be SET TO: " + DoubleToString(CurrentLossFromPreviousRun));
            }
       }
       else
       {
         DeleteAllGlobalVariables();
         // 07222025 Print("GlobalVAL " + _GV_CURRENT_LOSS + " Doesn't EXIST from a previous run..." );
       }

   
//  Initialize value for floating Global var NumOfTakeProfits   
#ifdef   _TAKE_PROFIT_COUNT_     
if(!TPAutoFire)
{                 // 07222025 Print(">>> AutoHoldPeriodTP: " + IntegerToString(AutoHoldPeriodTP));
                  if( GlobalValSet(_GV_REFRESH_TAKE_PROFIT, NumOfTakeProfits) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REFRESH_TAKE_PROFIT + " SET Successfully TO: " + DoubleToString(NumOfTakeProfits));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REFRESH_TAKE_PROFIT + " CAN'T be SET TO: " + DoubleToString(NumOfTakeProfits));  
                  }
}
#endif
}
    
   
   if(!gPreventReset)
   {
      if(IsTimeCurrentFT)
      {
         IsTimeCurrentFT = false;
         IsTimeCurrent();
      }
      
      GetAllStartupVariables();
   }
   
   if(FirstTimeCrossEqualizeTP)
   {
      if(MarketOrderType == 1)   
      {
         // LONG
         CrossEqualizeTPFileName = "LONG" + CrossEqualizeTPFileNameBase;
      }
      else
      {
         // SHORT
         CrossEqualizeTPFileName = "SHORT" + CrossEqualizeTPFileNameBase;
      }
      // 07222025 Print("CrossEqualizeTPFileName: " + CrossEqualizeTPFileName);
   }
   
   int RetOnInit = _OnInit();
   
   ////  If Manual mode set, then after initial configuration - reset EnableCrossSynch so that it can continue after Take Profit 01.04.2022
   //if(EnableCrossSynch && !HitLiveMarket)
   //{
   //   EnableCrossSynch = false;
   //   AutoPriceGen = true;
   //}
      
   
   return(RetOnInit);
   //return(_OnInit());
}


//  =====================================================================================================================================


int _OnInit()
{
      
                       
                                  
      // Wait for SynchSignal from reciprocal side...      
//      if(EnableCrossSynch)
//         SynchWithReciprocalSide(MarketOrderType, DestinationInstance);
//         
//         
//      if(RemoveNavigatorOnLaunch)
//            CloseNavigatorPopUpWindow();

      
      //if(WaitForKeyPress && EndOfRunCycle)
      //{
      //   // 07222025 Print(">>> _OnInit: RETURN...");
      //   // 07222025 Print("======================");
      //   return(-555);    //  Return here so that the only run can occur ONLY when EndOfRunCycle is FALSE and is called from within OnTick...
      //}  
       
          
      if(DeInitReson > 0)
         Lots=SLots;

// 07222025 Print("<<< INSIDE _OnInit >>>");
////// 07222025 Print("LOTS: " + Lots + " TickValue: " + MarketInfo(Symbol(), MODE_TICKVALUE) + " ProfitLossPerPip: " + ProfitLossPerPip );

   

   if(!gPreventReset)
     {
      
      // Wait for SynchSignal from reciprocal side... 
      if(HitLiveMarket)
      {
         // 07222025 Print("Initial Synching...");
         if(EnableCrossSynch)
            SynchWithReciprocalSide(MarketOrderType, DestinationInstance);
         
        
      }
      else
      {
         // 07222025 Print("No Initial Synching...");
      }
        
         
      if(RemoveNavigatorOnLaunch)
            CloseNavigatorPopUpWindow();

      //if(!InitializeAccountCurrency())
      //    return(INIT_FAILED);
 


#ifdef _WEB_Request_
      ZennUserName=GetFilterCode();
#endif

      
      // NEW: Lots Specification Management
      ActiveMarketRoundUp     =  RoundUpLots;             
      ActiveCommissionRoundUp =  RoundUpLots;

      NormDoublePrecission    =  LotsPrecision;
      ActiveMarketPrecission  =  LotsPrecision;


      ////// 07222025 Print("<<< OnInit - Initializing ENTERING>>>");
      ActivateTime         = StrToTime(_ActivateTimeStr);
      DeActivateTime       = StrToTime(_DeActivateTimeStr);

      
      
         
         

#ifdef   _ASPECT_RATIO_
      //ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);

      ResetLastError();
      // Create the button
      if(!OnOffButtonCreate(0, InpName, 0, x_coord, y_coord, x_size, y_size, InpCorner, TitleClicked, InpFont, InpFontSize, InpColor, InpBackColor, InpBorderColor, InpState, InpBack, InpSelection, InpHidden, InpZOrder))
        {
         int Err=GetLastError();
         // 07222025 Print("Error creating On/Off Button. Error code ", Err, ". ", ErrorDescription(Err));

         return(INIT_FAILED);
        }

      if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
        {
         ////// 07222025 Print("Failed to get the chart width! Error code = ",GetLastError());
         //return(0);
        }

      if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
        {
         ////// 07222025 Print("Failed to get the chart height! Error code = ",GetLastError());
         //return(0);
        }

      x_coord = x_distance - x_coord;
      y_coord = y_distance - y_coord;

#endif

#ifdef _SNAG_IT_BUTTON_

ActionButton001.CreateDDButon();

#endif

      LastCandleStart = Time[0];

      DetermineCommissionMode(Symbol());
      //AvarageSpreadPoints

#ifdef   _TIMER_ENABLED_
      EventSetTimer(1);
#endif

      if(!(MarketRefPoint==ABOVE || MarketRefPoint==BELOW))
        {
         //Debug("Market Reference Point should be either ABOVE or BELOW...");
         return(INIT_FAILED);
        }
     

        
      // Generate Protection Level and Lot size
      if(!GenerateProtectionLevel())
         return(INIT_FAILED);

      SaveOriginalSetupVals();

      // 07222025 Print("<<< DrawFrontInterface >>>");
      if(OrientPannelToURorUL)
        {
         DrawFrontInterfaceUR(XCoord_Labels,
                              YCoord_Labels,
                              XDiff,
                              YDiff,
                              FontNameChoice,
                              FontSizeChoice,
                              LabelColor,
                              TitleColor,
                              ValueColor);
         //,clrGray             //  Labels
         //,clrDarkOrange       //  Title
         //,ValueColor  clrBrown            //  Values
        }
      else
        {
         DrawFrontInterfaceUL(XCoord_Labels,
                              YCoord_Labels,
                              XDiff,
                              YDiff,
                              FontNameChoice,
                              FontSizeChoice,
                              LabelColor,
                              TitleColor,
                              ValueColor);
        }
      
        

#ifdef      _TrendLineControl_
      if(TrendLineTrigger)
         DrawTriggerTrendLine();
#endif

     // Maybe NOT needed anymore...
     // GlobalInitialize();
     //double lPriceTarget = AccuChop_ToFracNum(PriceTargetLevel);
     PriceDir=GetCurrentPriceDirection(PriceTargetLevel, false);
     AjustColorsAccordingToDir(PriceDir);

     //  Assign PriceTargetLevel for the FIRST Time

     //  Corrected 20.01.2020
     SetALLLineLevels();
     DrawALLLines();
     DrawInitialPanel();

#ifdef _SEND_EMAIL_
     
     if(SendEmailUpdates)
      {
      
         string ActualProfitTargetName;
         
         ActualProfitTargetName = (CalcRPbyTakeProfit == true ? "Take Profit Level" : (CalcRPbyTrigOrTailLevel == true ? "Trailing Trigger Level" : "Trailing Stop Level"));
                 
         SendMail(EA_NAME_IDENTIFIER+" - EA Has Been LAUNCHED!",
                  "EA Has Been LAUNCHED!"+"\n"+
                  Symbol()+","+IntegerToString(Period())+"\n"+                 
                  "ExecCommand: "+EnumToString(ExecCommand)+": "+DoubleToStr(Lots,Lot_Precision)+" Lots"+ATLevel+DoubleToString(CurrProfitLossPerPip,4)+"\n"+
                  "Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"\n"+
                  "Entry Level: "+DoubleToString(PriceTargetLevel,Digits)+"\n"+
                  "Stop Loss Level: "+DoubleToString(StopLossLevel,Digits)+Separator+DoubleToStr(MathAbs((StopLossLevel - PriceTargetLevel))/Point/_TicksPerPIP,1)+MeasurePips+"\n"+
                  "Profit Target: "+ActualProfitTargetName+"\n"+
                  "Take Profit Level: "+DoubleToString(TakeProfitLevel,Digits)+Separator+DoubleToStr(MathAbs((TakeProfitLevel - PriceTargetLevel))/Point/_TicksPerPIP,1)+MeasurePips+"\n"+
                  "Trailing Trigger Level: "+DoubleToString(TrailingTriggerLevel,Digits)+Separator+DoubleToStr(MathAbs((TrailingTriggerLevel - PriceTargetLevel))/Point/_TicksPerPIP,1)+MeasurePips+"\n"+
                  "Trailing Stop Level: "+DoubleToString(TrailingTailLevel,Digits)+Separator+DoubleToStr(MathAbs((TrailingTailLevel - PriceTargetLevel))/Point/_TicksPerPIP,1)+MeasurePips
                 );
      }
#endif

      if(!HitLiveMarket)
        {
                     
         if(!FirstLiveDirectOrder)
           {
            if(!(ObjectFind(objPriceTargetLevelLineName)<0))
              {
               OnHold=true;
               CurrentPosition = PositionOnHolt;
               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
              }
           }
         else
           {
            CurrentPosition = PositionPending;
            ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
           }
        }
      else
        {

         
//  Waiting for Entry Signal           
//  Waiting for Time Activation (used to be here -> now in GenerateProtectionLevel
        

         if(ExecCommand==BUY_LIMIT)
           {
            //            RefreshRates();
            //            PriceTarget=Ask;
            //


#include<OpenPosLevel_BUY_LIMIT2.mqh>

            //SetALLLineLevels();
            //DrawALLLines();
            //DrawALLLinesMetrixs();    
           }
         else
            if(ExecCommand==BUY_STOP)
              {
               //RefreshRates();
               //PriceTarget=Ask;


#include<OpenPosLevel_BUY_STOP2.mqh>

               //SetALLLineLevels();
               //DrawALLLines();
               //DrawALLLinesMetrixs();
              }
            else
               if(ExecCommand==SELL_LIMIT)
                 {
                  //RefreshRates();
                  //PriceTarget=Bid;

#include<OpenPosLevel_SELL_LIMIT2.mqh>

                  //SetALLLineLevels();
                  //DrawALLLines();
                  //DrawALLLinesMetrixs();
                 }
               else
                  if(ExecCommand==SELL_STOP)
                    {
                     //RefreshRates();
                     //PriceTarget=Bid;

#include <OpenPosLevel_SELL_STOP2.mqh>

                     //SetALLLineLevels();
                     //DrawALLLines();
                     //DrawALLLinesMetrixs();
                    }                   

}
      
      //  Resize the Chart
      if(EnableCrossSynch)
         ReSizeMainChartToCenter();
      
      int RetPCS;
      if(HitLiveMarket)  
      {
         // 07222025 Print("MARKET SETUP...");
         RetPCS = PerformCrossSynch();
         // 07222025 Print("Returned: " + IntegerToString(RetPCS));
         if(RetPCS == INIT_FAILED)
            return(INIT_FAILED);
      }
      else
      {
         // 07222025 Print("PENDING SETUP...");
         //RetPCS = PerformCrossSynch();
         //// 07222025 Print("Returned: " + IntegerToString(RetPCS));
         //if(RetPCS == INIT_FAILED)
         //   return(INIT_FAILED);
         
         if(EnableCrossSynch)
         {
         // Calculate LOCAL counter Bot Levels based on internal and 
         double counterPriceTarget = 0;
         double counterStopLossPips = 0;
         double counterTakeProfitPips = 0;
         
  
         if(MarketOrderType == 1)   
         {
            // Curr position is LONG - calculate SHORT
            // Calculate SELL_STOP
            counterPriceTarget    =  StopLossLevel;
            counterStopLossPips   =  StopLossPips;
            counterTakeProfitPips =  StopLossPips;
         }
         else
         {
            // Curr position is SHORT - calculate LONG
            // Calculate BUY_STOP
            counterPriceTarget    =  StopLossLevel;
            counterStopLossPips   =  StopLossPips;
            counterTakeProfitPips =  StopLossPips;
         }
   
         //// 07222025 Print("StopLossLevel = " + StopLossLevel);
         //// 07222025 Print("StopLossPips = " + StopLossPips);

         //// 07222025 Print(">>>MarketOrderType = " + MarketOrderType);
         int newMarketOrderType = (MarketOrderType == 1 ? 2 : 1);
         //// 07222025 Print(">>>NewMarketOrderType = " + newMarketOrderType);
         // 07222025 Print(">>>LaunchTemplateFileName = " + LaunchTemplateFileName);
         
         // Plug NEW calculated values of local counter position Bot into corresponding Template and SAVE them
         bool UpdateTemplateRes = UpdateCounterBotTemplate(MarketOrderType,
                                                           LaunchTemplateFileName, 
                                                           counterPriceTarget,
                                                           counterStopLossPips,
                                                           counterTakeProfitPips);

         if(!UpdateTemplateRes){
            // 07222025 Print("Error Updating Counter Bot Launch Template...");
            TransactionComplete = true;
            return(INIT_FAILED);
         }
         
         // Activate the above Template in the second Chart Window and ReSize according to first one
         bool ApplyChartTemplateRes = ApplyChartTemplate(LaunchTemplateFileName);
         
         if(!ApplyChartTemplateRes)
         {
            // 07222025 Print("Error Applying Templete or Template Name not Found...");
            
            TransactionComplete = true;
            return(INIT_FAILED);
         }
         
         Sleep(SuspendThread2_TimePeriod);
         // Resize Second Chart according to First one...
         ReSizeSecondChart();
         
         Sleep(SuspendThread2_TimePeriod);
         
         //// Remove the Navigator Pannel from the Chart Window...'
         if(RemoveNavigatorOnLaunch)
            CloseNavigatorPopUpWindow();
            
      }     
      }
        


//
//      // Perform CrossSynch BID/ASK data exchangeactivities
//      if(EnableCrossSynch)
//      {
//         
//         bool FileGenRes;
//         
//         if(CalcRPbyTakeProfit)     //  Calculate Recurrent Profit by 3 Price Levels
//         {   
//         // 1. Generate Levels file and copy to destination directory
//              FileGenRes = GenerateSychLevelFile(MarketOrderType,
//                                                 DestinationInstance,
//                                                 PriceTargetLevel,
//                                                 StopLossLevel,
//                                                 TakeProfitLevel           //  Push TakeProfitLevel...
//                                                 );
//         }
//         else
//         {
//            if(CalcRPbyTrigOrTailLevel)
//              FileGenRes = GenerateSychLevelFile(MarketOrderType,
//                                                 DestinationInstance,
//                                                 PriceTargetLevel,
//                                                 StopLossLevel,
//                                                 TrailingTriggerLevel      //  Push TrailingTriggerLevel instead...
//                                                 );
//            else
//              FileGenRes = GenerateSychLevelFile(MarketOrderType,
//                                                 DestinationInstance,
//                                                 PriceTargetLevel,
//                                                 StopLossLevel,
//                                                 TrailingTailLevel      //  Push TrailingTailLevel instead...
//                                                 ); 
//         }
//                                                                                         
//         if(!FileGenRes){
//            // 07222025 Print("Error Generating Cross Synch Files...");
//            TransactionComplete = true;
//            return(INIT_FAILED);
//         }
//
//   
//         // 2. Wait for Cross Process to send its Levels File
//         string SynchFileName = "";
//         //uint TimeDelayBeforeCancel = 5;
//         //int RecurrentDelay = 150; // Equal to 1s
//         bool ReceiveFileRes = WaitToReceiveFile(SynchFileName,
//                                                 MarketOrderType,
//                                                 SuspendThread_TimePeriod,
//                                                 CrossSynchTimeDelayBeforeCancel);
//         
//         if(!ReceiveFileRes){
//            // 07222025 Print("CrossSynch WaitToReceiveFile Waiting Timeout...");
//            TransactionComplete = true;
//            return(INIT_FAILED);
//         }
//         
//         
//         //if(!PopUpRemoved)
//         //{
//         //   bool bRes = SetForegroundWindow(hWinCurrentTop); 
//         //   RemoveNavigatorPopUp();
//         //}
//         
//         
//         //// READE values in Received synch file
//         double extPriceTargetLevel;
//         double extStopLossLevel;
//         double extTakeProfitLevel;  
//         double extTrailingTriggerLevel;          
//         
//         bool GetValsRes = GetSychFileVals(SynchFileName,
//                                           extPriceTargetLevel,
//                                           extStopLossLevel,
//                                           extTakeProfitLevel
//                                           //,extTrailingTriggerLevel
//                                           );
//         
//         if(!GetValsRes){
//            // 07222025 Print("Error Reading Synch file values...");
//            TransactionComplete = true;
//            return(INIT_FAILED);
//         }
//         
//         
//         // Calculate LOCAL counter Bot Levels based on internal and 
//         double counterPriceTarget = 0;
//         double counterStopLossPips = 0;
//         double counterTakeProfitPips = 0;
//         //double counterTrailingTriggerPips = 0;
//         
//         bool CalcCounterLevelRes = CalcCounterLevels(MarketOrderType,
//                                                      PriceTargetLevel,
//                                                      StopLossLevel,
//                                                      extTakeProfitLevel,
//                                                      counterPriceTarget,
//                                                      counterStopLossPips,
//                                                      counterTakeProfitPips
//                                                      //,counterTrailingTriggerPips
//                                                      );
//                                                      
//         if(!CalcCounterLevelRes){
//            // 07222025 Print("Error Calculating Counter Levels...");
//            TransactionComplete = true;
//            return(INIT_FAILED);
//         }
//         
//         
//         // Plug NEW calculated values of local counter position Bot into corresponding Template and SAVE them
//         bool UpdateTemplateRes = UpdateCounterBotTemplate(MarketOrderType,
//                                                           LaunchTemplateFileName, 
//                                                           counterPriceTarget,
//                                                           counterStopLossPips,
//                                                           counterTakeProfitPips
//                                                           //,counterTrailingTriggerPips
//                                                           );
//
//         if(!UpdateTemplateRes){
//            // 07222025 Print("Error Updating Counter Bot Launch Template...");
//            TransactionComplete = true;
//            return(INIT_FAILED);
//         }
//         
//         // Activate the above Template in the second Chart Window and ReSize according to first one
//         bool ApplyChartTemplateRes = ApplyChartTemplate(LaunchTemplateFileName);
//         
//         if(!ApplyChartTemplateRes)
//         {
//            // 07222025 Print("Error Applying Templete or Template Name not Found...");
//            TransactionComplete = true;
//            return(INIT_FAILED);
//         }
//         
//         
//         // Resize Second Chart according to First one...
//         ReSizeSecondChart();
//         
//         //// Remove the Navigator Pannel from the Chart Window...'
//         if(RemoveNavigatorOnLaunch)
//            CloseNavigatorPopUpWindow();
//         
//         //RemoveNavigatorPopUp();
//         
//      }  

               
                    
        

      InitToggleOnHold();

#ifdef      _Envelopes_Slider_
      if(UseEnvelopeSlider)
        {
         if(EnvelopeDynamicOrStaticGrid)
            EnvelopeSliderActive=true;
         else 
            EnvelopeSliderActive=false;

         DrawEntryOnEnvelope();
        }
#endif


      
      
      
      gPreventReset=true;
      
      return(INIT_SUCCEEDED);
     }
   else
     {
      //   //// 07222025 Print("<<< OnInit NON-LEGIT - EXITING >>>");
      //   //// 07222025 Print("gPreventReset: " + gPreventReset);
      //
      //   //if(!OrderOpened)
      //      GenerateProtectionLevel();

      return(INIT_SUCCEEDED);
     }

}


//  =====================================================================================================================================


void OnDeinit(const int reason)
  {
      _OnDeinit(reason);

  }


//  =====================================================================================================================================


void _OnDeinit(int reason)
{


    
   // 07222025 Print("<<< Inside DeInint >>>");
	//  Symbol or chart period has been changed
//  Input parameters have been changed by a user
//  Another account has been activated or reconnection
//  A new template has been applied

////// 07222025 Print("<<< INSIDE DeInti >>>");
////// 07222025 Print("LOTS: " + Lots + " TickValue: " + MarketInfo(Symbol(), MODE_TICKVALUE) + " ProfitLossPerPip: " + ProfitLossPerPip );

   if(reason==3 || reason==5 || reason==6 || reason==7)
     {
      gPreventReset=true;
      SLots=Lots;
      DeInitReson=reason;

      // 07222025 Print("<<< NON-LEGIT DeInti EXIT>>>");
      // 07222025 Print("UninitializeReason: " + IntegerToString(UninitializeReason()));
      
      return;
     }
   else
      if(reason==1 || reason==0 || reason==4 || reason==8 || reason==9)
        {
         // 07222025 Print("<<< LEGIT DeInti ENTER>>>");
         // 07222025 Print("UninitializeReason: " + IntegerToString(UninitializeReason()));
         
         ResetLastError();

         Comment("");
         RemoveFrontInterface();

         if(!(ObjectFind(objTargetLayoutMap)<0))
            ObjectDelete(objTargetLayoutMap);

         if(!(ObjectFind(objRiskLayoutMap)<0))
            ObjectDelete(objRiskLayoutMap);

         if(!(ObjectFind(objBreakEvenArrow)<0))
            ObjectDelete(objBreakEvenArrow);          

         if(!(ObjectFind(objBreakEvenLevelLineName)<0))
            ObjectDelete(objBreakEvenLevelLineName);
            

#ifdef _SNAG_IT_BUTTON_         
   
   if(!(ObjectFind("PushButtonSnagIt")<0))
            ObjectDelete("PushButtonSnagIt");
#endif

            
#ifdef  _PARTIAL_CLOSE_                  
               //  25.01.2025     
               if(!(ObjectFind(objPartialCloseLevelLineName)<0))
                  ObjectDelete(objPartialCloseLevelLineName);
                  
               if(!(ObjectFind(objPartialCloseArrow)<0))
                  ObjectDelete(objPartialCloseArrow);
#endif               

         if(!(ObjectFind(objUpArrowTarget)<0))
            ObjectDelete(objUpArrowTarget);

         if(!(ObjectFind(objDownArrowTarget)<0))
            ObjectDelete(objDownArrowTarget);

         if(!(ObjectFind(objStopArrow)<0))
            ObjectDelete(objStopArrow);

         if(!(ObjectFind(objProfitArrow)<0))
            ObjectDelete(objProfitArrow);

         if(!(ObjectFind(objTTriggerArrow)<0))
            ObjectDelete(objTTriggerArrow);

         if(!(ObjectFind(objTTailArrow)<0))
            ObjectDelete(objTTailArrow);

         if(!(ObjectFind(objPriceTargetLevelLineName)<0))
            ObjectDelete(objPriceTargetLevelLineName);

         if(!(ObjectFind(objStopLossLevelLineName)<0))
            ObjectDelete(objStopLossLevelLineName);

         if(!(ObjectFind(objTakeProfitLevelLineName)<0))
            ObjectDelete(objTakeProfitLevelLineName);

         if(!(ObjectFind(objTrailingTriggerLevelLineName)<0))
            ObjectDelete(objTrailingTriggerLevelLineName);

         if(!(ObjectFind(objTrailingTailLevelLineName)<0))
            ObjectDelete(objTrailingTailLevelLineName);
         
         if(!(ObjectFind(sButtonName)<0))
            ObjectDelete(sButtonName);
            

#ifdef   _ASPECT_RATIO_
         if(!ObjectDelete(0,InpName))
           {
            // 07222025 Print(__FUNCTION__, ": failed to delete Button! Error code = ",GetLastError());
           }
#endif

         ////// 07222025 Print(__FUNCTION__,"_Uninitalization reason code = ",reason);

         ////// 07222025 Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));

         ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0);

#ifdef   _TIMER_ENABLED_
         EventKillTimer();
#endif

#ifdef   _COMPENSATION_ENGINE_
         // Shouldn't orphan, must be DELETED when OPEN POSITION is CLOSED at a LOSS
         // But you may EXIT EA while position is OPEN in DEMO
         if(GlobalValDel(_GV_OPEN_POSITION_EXISTS))
           {
            // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " DELETED successfully...");
           }
         else
           {
            // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " CAN'T be DELETED...");
           }

         //  IF you accidentally CLOSE or EXIT an EA in MID SESSION - LEAVE THE CURRENT LOSS for NEXT RUN
         //if( GlobalValDel( _GV_CURRENT_LOSS ) )
         //   //// 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " DELETED successfully...");
         //else
         //   //// 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " CAN'T be DELETED...");
#endif

#ifdef   _TrendLineControl_
         if(!(ObjectFind(TrendLineName)<0))
            ObjectDelete(TrendLineName);
#endif

         if(!EnableCrossSynch && NumOfStops >= 1)
         {  
            // 07222025 Print("<<< SAVING TEMPLATE >>>");
            // 07222025 Print("LaunchTemplateFileName: " + LaunchTemplateFileName);
            
            long hWndFirstChart  = ChartFirst();
            long hWndSecondChart = ChartNext(hWndFirstChart);
            
            int SuspendCounter = 0;
            bool ChartSaveRes = 0;
               
            while (true)   
            {   
               ResetLastError();
               ChartSaveRes = ChartSaveTemplate(hWndSecondChart, LaunchTemplateFileName);

                 
               //if(!ChartSaveRes) 
               //{
                  // 07222025 Print("ChartSaveRes: " + IntegerToString(ChartSaveRes));
                  // 07222025 Print("ChartSaveTemplate Error: " + IntegerToString(GetLastError()) + " - Template Saved: " + LaunchTemplateFileName);
               //}
               
               if(ChartSaveRes)
                  break;
               
               Sleep(SuspendThread2_TimePeriod);
               
               if(SuspendCounter++ > 35) 
                  break;
            }
            
            // 07222025 Print("ChartSaveTemplate LAST - ChartSaveRes: " + IntegerToString(ChartSaveRes));
            // 07222025 Print("ChartSaveTemplate LAST - ChartSaveTemplate Error: " + IntegerToString(GetLastError()));
            // 07222025 Print("SuspendCounter: " + IntegerToString(SuspendCounter));
            
            UpdateSourceTemplateWithLastDevelopments();
            
         }

        }
}


//bool IsEscKeyPress()
//{
//   return EscKeyPressed;
//}
//
//
//void ResetEscKey()
//{
//   EscKeyPressed = false;
//}


//  =====================================================================================================================================


//bool     TimedActiveFirstTime2 = true;
//datetime ERCStartTime = 0;
//double   TimeDiff    =  0;

void OnTick()
{

//if(bMyOnTick)
//   return;

#ifdef   _LOCK_PROTECT_
   if(TimeConstraints && !(TimeCurrent()<STOP_DATE))
     {
      Comment("© 2017 Price Level Difender by ZennerTrading, LLC.\n"+
              "Your Demo has Expired!  \n"+
              "Please Contact Your Sales Representative for a fully functioning version at +359-877-265-993...");
      return;
     }
#endif


DelayedTimeActivationCheck();


if(!TransactionComplete && !OnHold)
{




      if(!FlowtingOrStatIcons)
         if(LastCandleStart!=Time[0])
           {
            NewCandelPoped=true;
            DrawAllArrows();
#ifdef _MOVE_RR_RECTS_
            if(ShowTargetLayout && !(ObjectFind(objTargetLayoutMap)<0))
              {
               MoveTargetLayout();
               //////// 07222025 Print("<<< Layout MOVED... >>>");
              }

            if(ShowRiskLayout && !(ObjectFind(objRiskLayoutMap)<0))
              {
               MoveRiskLayout();
               //////// 07222025 Print("<<< Layout MOVED... >>>");
              }
#endif
            LastCandleStart=Time[0];

            //////// 07222025 Print("ReDraw Arrows Now... ");
           }
           
#ifdef _ENABLE_BENCHMARK_      
if(OrderOpened)
{
   // 07222025 Print("1. Counter: " + counter);     
}      
#endif
     

#ifdef _CROSS_TICKET_TRANSFER_
if(ShowNetCrossPL && OrderOpened)
{

//      if((objTicketNumSync.GetCurCrossTicketNumber()) != 0 && (objTicketNumSync.GetExternCrossTicketNumber() != 0)) 
//      {
         int T1 = objTicketNumSync.GetCurCrossTicketNumber();
         int T2 = objTicketNumSync.GetExternCrossTicketNumber();
         
         //// 07222025 Print("T1: " + T1);
         //// 07222025 Print("T2: " + T2);
         
         double PL1;
         double PL2;
         
         if(T1 > 0)
            PL1 = objTicketNumSync.GetButtonPL(T1);
         else
            PL1 = 0;
            
         if(T2 > 0)
            PL2 = objTicketNumSync.GetButtonPL(T2);
         else
            PL2 = 0;
         
         //// 07222025 Print("PL1: " + DoubleToString(PL1, 2));
         //// 07222025 Print("PL2: " + DoubleToString(PL2, 2));
         
         ActionButton001.SetButtonTitle(DoubleToString(PL1 + PL2, 2));
//      }
//      else
//      {
//         // 07222025 Print(">>>>>>> GetCurCrossTicketNumber or GetExternCrossTicketNumber: " + objTicketNumSync.GetCurCrossTicketNumber() + " - " + objTicketNumSync.GetExternCrossTicketNumber());
//      
//         //TransactionComplete =true;
//         //return;
//      }
         
      //ChartRedraw();
      
}
#endif
           
           
      // Block Thread while inside of it...
      //TransactionInProcess=!TransactionInProcess;

      if(
         (ExecCommand==BUY_STOP)
      )
        {

#include <BUY_STOP.mqh>

        }

      else
         if(
            (ExecCommand==SELL_STOP)
         )
           {

#include <SELL_STOP.mqh>

           }

         else
            if(
               (ExecCommand==SELL_LIMIT)
            )
              {

#include <SELL_LIMIT.mqh>

              }
            else
               if(
                  (ExecCommand==BUY_LIMIT)
               )
                 {

#include <BUY_LIMIT.mqh>

                 }
     }
   else
     {
      if(TransactionComplete)
        {
         if(FirstTimeTransComplete)
           {   
            // 07222025 Print("<<< TRANSACTION COMPLETE RAISED!!! >>>");
            // 07222025 Print("======================================");
           

            FirstTimeTransComplete=!FirstTimeTransComplete;
           }
           
           return;
        }
      else
        {
            if(OnHold) 
            {
               if(FirstTimeOnHold)
               {
                 Debug("Temporary ON-HOLD...");
                 // 07222025 Print("====================");
                 FirstTimeOnHold=!FirstTimeOnHold;
               }

         //  Spread will push TargetLevel anytime it comes close to it
         RefreshDirection2();
         //// 07222025 Print("RefreshDirection2...");
         
         
// ****************************************************************************************************
//// 07222025 Print("_CheckActivation: " + IntegerToString(_CheckActivation));
//// 07222025 Print("OrderOpened: " + IntegerToString(OrderOpened));

//#include <DelayedTimeActivation.mqh>
// TRANSFERED OUT OF IF STSTEMENT...  4.04.2022
DelayedTimeActivationCheck();

// ****************************************************************************************************
         return;
         
        }
         
         
     }
}

//  ON_HOLD - OFF_HOLD COMES HERE
// ===============================

#ifdef _ENABLE_BENCHMARK_
if(OrderOpened)
{
   counter++;
   // 07222025 Print("2. Counter: " + counter);
}

return;
#endif


if(!TransactionComplete && !OnHold)
{



//// 07222025 Print(">>>>");
//ResetLastError();
//// 07222025 Print(">>>> objTicketNumSync.GetReceiveCrossTicketNumDataFileName(): " + objTicketNumSync.GetReceiveCrossTicketNumDataFileName());
//// 07222025 Print(">>>> FileIsExist(): " + FileIsExist(objTicketNumSync.GetReceiveCrossTicketNumDataFileName(), FILE_READ));
//int Err = GetLastError();
//// 07222025 Print(">>>> GetLastError(): " + Err);
//// 07222025 Print("TicketUpdate: " + TicketUpdate);
//// 07222025 Print("ShowNetCrossPL: " + ShowNetCrossPL);
//// 07222025 Print("OrderOpened: " + OrderOpened);
//
//// 07222025 Print(">>>>");



//if(FileIsExist(objTicketNumSync.GetReceiveCrossTicketNumDataFileName(), FILE_READ) && 
//   TicketUpdate && 
//   ShowNetCrossPL && 
//   OrderOpened)        
//{
//
//   TicketUpdate = false;
//   // 07222025 Print(">>>> INSIDE EnableCrossSynch...");
//   double ExtTicketNum = (double)objTicketNumSync.ReceiveExternCrossTicketNumber();   
//   // 07222025 Print(">>> ExtTicketNum: " + ExtTicketNum);   
//     
//}

//
//   if(objTicketNumSync.HasFileArrived())
//   {
//      TicketUpdate = false;
//      // 07222025 Print(">>>> INSIDE ReceiveExternCrossTicketNumber...");
//      double ExtTicketNum = (double)objTicketNumSync.ReceiveExternCrossTicketNumber();   
//      // 07222025 Print(">>> ExtTicketNum: " + ExtTicketNum); 
//      
//      Sleep(SuspendThread2_TimePeriod);
//      
//      return;
//   }

#ifdef _CROSS_TICKET_TRANSFER_
int NewSuspendCounter;
NewSuspendCounter = 0;

bool ResT;

do
{ 
   if(TicketUpdate && ShowNetCrossPL && OrderOpened)
   {
      ResT = objTicketNumSync.ProcessRecipricalTicket(TicketUpdate, 
                                                      ShowNetCrossPL, 
                                                      OrderOpened);
      if(ResT) 
         break;
   }
   else
      break;
                                                      

   Sleep(SuspendThread2_TimePeriod);
   if(++NewSuspendCounter > 35) break;
   
   //// 07222025 Print("SuspendCounter: " + SuspendCounter);
   
} while(true);

if(NewSuspendCounter > 0)
   // 07222025 Print("SuspendCounter: " + NewSuspendCounter);
#endif


#ifdef _EA_11_
   if(GlobalValEXIST(_GV_SHUT_OFF_VALVE_HIT_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_SHUT_OFF_VALVE_HIT_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_SHUT_OFF_VALVE_HIT_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_SHUT_OFF_VALVE_HIT_22))
#endif

{

#ifdef _EA_11_

   if(GlobalValDel(_GV_SHUT_OFF_VALVE_HIT_11))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_11 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_11 + " CAN'T be DELETED...");
     }
     
#endif

#ifdef _EA_12_
   
   if(GlobalValDel(_GV_SHUT_OFF_VALVE_HIT_12))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_12 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_12 + " CAN'T be DELETED...");
     }
  
#endif    

#ifdef _EA_21_
   
   if(GlobalValDel(_GV_SHUT_OFF_VALVE_HIT_21))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_21 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_21 + " CAN'T be DELETED...");
     }
#endif     
   
#ifdef _EA_22_
   
   if(GlobalValDel(_GV_SHUT_OFF_VALVE_HIT_22))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_22 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHUT_OFF_VALVE_HIT_22 + " CAN'T be DELETED...");
     }
     
#endif     
      
   ShutOffVeleveHIT = true;
   GlobalShutOFF_Received = true;

}



if(ShutOffVeleveHIT)
         {
              ShutOffVeleveHIT = false;
//            if(!OrderOpened)
//            {
//               OnHold = !OnHold;
//               CreateOnHoldButton(sButtonName,OnHoldIconColorTRUE,"Wingdings",CharToStr(OnHoldIconArrowTRUE));
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, "MAXLots " + DoubleToString(RequiredLots,2) + " > " + DoubleToString(MAXLotsAllowed,2) + " MAXAccumLoss " + DoubleToString(_AcumulatedFloatingLoss,2) + " > " + DoubleToString(MAXAccumLossAllowed,2));
//            }
//            
//            TransactionComplete = true;
//            //CriticalMass = true;
//            RequiredLots = 0;          // Set RequiredLots to ZERO in order to trigger ERROR condition...
//            // 07222025 Print("Shut OFF Valve HIT...");
//            
//            int iRet = MessageBox("Excessive Lot Size or Accumulated Loss value REACHED!!!/n" + 
//                                  "\nMAX Accumulated Loss Allowed: " + "$" + DoubleToString(MAXAccumLossAllowed, 2) + 
//                                  "\nCurrent Accumulated Loss: " + "$" + DoubleToString(_AcumulatedFloatingLoss, 2) + 
//                                  "\nMAX Trading Lots Allowed: " + DoubleToString(MAXLotsAllowed, 2) +
//                                  "\nCurrent Trading Lots: " + DoubleToString(RequiredLots, 2),
//                                  "Emergency Shut OFF Procedure Activated...",
//                                  MB_OK);


                  // 07222025 Print("<<< Shut OFF Valve HIT >>>");
                  // 07222025 Print("==========================");
                  // 07222025 Print("Excessive Lot Size or Accumulated Loss value REACHED!!!/n");
                  // 07222025 Print("MAX Accumulated Loss Allowed: " + "$" + DoubleToString(MAXAccumLossAllowed, 2));
                  // 07222025 Print("Current Accumulated Loss: " + "$" + DoubleToString(AcumulatedFloatingLoss, 2));
                  // 07222025 Print("MAX Trading Lots Allowed: " + DoubleToString(MAXLotsAllowed, 2));
                  // 07222025 Print("Current Trading Lots: " + DoubleToString(Lots, 2));
                  
                  if(!GlobalShutOFF_Received)
                  {
                  
      #ifndef _EA_11_
                  if( GlobalValSet(_GV_SHUT_OFF_VALVE_HIT_11, 1) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_11 + " CAN'T be SET TO: 1");  
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_SHUT_OFF_VALVE_HIT_12, 1) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_12 + " CAN'T be SET TO: 1");  
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_SHUT_OFF_VALVE_HIT_21, 1) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_21 + " CAN'T be SET TO: 1");  
                  }
                     
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_SHUT_OFF_VALVE_HIT_22, 1) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_SHUT_OFF_VALVE_HIT_22 + " CAN'T be SET TO: 1");  
                  }
      #endif      
      
                  }
                  
                  // No need to reset as it either ReRuns or Exits...
                  //if(GlobalShutOFF_Received)
                  //   GlobalShutOFF_Received = false;
                  
                  
#ifdef   _RERUN_FROM_START_                    
                   
         // 07222025 Print("AutoRepeatAfterShutOff: " + IntegerToString(AutoRepeatAfterShutOff));       
             
         if(AutoRepeatAfterShutOff)
            {

#ifdef   _COMPENSATION_ENGINE_                   
                  // Remove CurrentLoss GlobalVAR   
                  if(GlobalValEXIST(_GV_CURRENT_LOSS))
                  {
                     if( GlobalValDel( _GV_CURRENT_LOSS ) )
                     {
                        // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " DELETED successfully...");
                     }
                     else
                     {
                        // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " CAN'T be DELETED...");
                     }
                  }
                     
                  //  Remove Existing Open Pos GlobalVAR, so that other EAs can readjust Curr Loss and Open New Positions              
                  if(GlobalValEXIST(_GV_OPEN_POSITION_EXISTS))
                  {
                     if( GlobalValDel(_GV_OPEN_POSITION_EXISTS) )
                     {
                        // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " DELETED successfully...");
                     }
                     else
                     {
                        // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " CAN'T be DELETED...");
                     }
                  }
#endif
            
            
               //  Pause for 30 seconds before ReRun
               Sleep(SecPauseBeforeReRun * 1000);     
               
                        
               
               if(EnableCrossSynch)
                  {                  
                  
                     // 07222025 Print("<<< AutoRepeatAfterShutOff: SHUTOFF - REINIT AFTER SHUT-OFF >>>");
                     
                     Sleep(SecPauseBeforeReRun * 1000);               
                     _OnDeinit(0);   
                     //Sleep(1000);       // If you want to have a blank screen for 1 sec.
                     ReInitializeAllStartupVariables();                 
                     _OnInit();
                  }
                  else
                  {
                     // 07222025 Print("<<< AutoRepeatAfterShutOff: SHUTOFF - SELF DISTRUCT AFTER SHUT-OFF >>>");
                     ExpertRemove();
                  }
               
               return;       
                                   
               }
               else
               {
                
                     //  Remove Bot
                     // 07222025 Print("<<< GAME OVER - After ShutOFF >>>");
                     Sleep(SecPauseBeforeReRun * 1000);
                     //if(RemoveExpertAtEnd)
                        ExpertRemove();
                  
               return;
               }   
#endif

         }


// ========================================================================================


#ifdef _EA_11_
   if(GlobalValEXIST(_GV_SHIFT_POS_NOW_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_SHIFT_POS_NOW_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_SHIFT_POS_NOW_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_SHIFT_POS_NOW_22))
#endif

{

// 07222025 Print(">>> Inside GV_SHIFT_POS_NOW...");
// 07222025 Print("===============================");
// 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel));

#ifdef _EA_11_

   if(GlobalValGet(_GV_SHIFT_POS_NOW_11, ActualPriceTargetLevel))
   {
   // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_11 + " GET successfully..." + DoubleToString(ActualPriceTargetLevel));
   }
   else
   {
   // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_11 + " CAN'T  GET...");
   }

   if(GlobalValDel(_GV_SHIFT_POS_NOW_11))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_11 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_11 + " CAN'T be DELETED...");
     }
     
#endif

#ifdef _EA_12_

   if(GlobalValGet(_GV_SHIFT_POS_NOW_12, ActualPriceTargetLevel))
   {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_12 + " GET successfully..." + DoubleToString(ActualPriceTargetLevel));
   }
   else
   {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_12 + " CAN'T  GET...");
   }
   
   if(GlobalValDel(_GV_SHIFT_POS_NOW_12))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_12 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_12 + " CAN'T be DELETED...");
     }
  
#endif    

#ifdef _EA_21_

   if(GlobalValGet(_GV_SHIFT_POS_NOW_21, ActualPriceTargetLevel))
   {
   // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_21 + " GET successfully..." + DoubleToString(ActualPriceTargetLevel));
   }
   else
   {
   // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_21 + " CAN'T  GET...");
   }
   
   if(GlobalValDel(_GV_SHIFT_POS_NOW_21))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_21 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_21 + " CAN'T be DELETED...");
     }
#endif     
   
#ifdef _EA_22_

   if(GlobalValGet(_GV_SHIFT_POS_NOW_22, ActualPriceTargetLevel))
   {
   // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_22 + " GET successfully..." + DoubleToString(ActualPriceTargetLevel));
   }
   else
   {
   // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_22 + " CAN'T  GET...");
   }
   
   if(GlobalValDel(_GV_SHIFT_POS_NOW_22))
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_22 + " DELETED successfully...");
     }
   else
     {
      // 07222025 Print("GlobalVAL: " + _GV_SHIFT_POS_NOW_22 + " CAN'T be DELETED...");
     }
     
#endif     

   
   if((ExecCommand==BUY_LIMIT) || (ExecCommand==BUY_STOP))
   {
      // 07222025 Print("Pending Position: BUY_LIMIT/BUY_STOP");
      // 07222025 Print("====================================");
      
      if(!ShiftPosTightOrGap)
         PriceTargetLevel = ActualPriceTargetLevel + (StopLossPips * Point);
      else
         PriceTargetLevel = ActualPriceTargetLevel;
      
   }
   
   else if((ExecCommand==SELL_LIMIT) || (ExecCommand==SELL_STOP))
   {
      // 07222025 Print("Pending Position: SELL_LIMIT/SELL_STOP");
      // 07222025 Print("============================");
      
      if(!ShiftPosTightOrGap)
         PriceTargetLevel = ActualPriceTargetLevel - (StopLossPips * Point);
      else
         PriceTargetLevel = ActualPriceTargetLevel;

      
   }
             
   // 07222025 Print("NEW PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
   if(ShiftPosEqualizeTP2)
   {
      // 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips));
      TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
      // 07222025 Print("NEW TakeProfitPips: " + DoubleToString(TakeProfitPips));
      
#define _KEEP_SHORT_PROFIT_TATGET_
//#define _RESTORE_PROFIT_TATGET_

#ifdef _KEEP_SHORT_PROFIT_TATGET_     
      // #define  _ONE_PIP_   10
      // if(TakeProfitPips < _ONE_PIP_)
      //    TakeProfitPips = StopLossPips;
      
      if(TakeProfitPips < StopLossPips)
         TakeProfitPips = StopLossPips;
         
      dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
#endif

#ifdef _RESTORE_PROFIT_TATGET_      
      string result1[];
      ushort  u_sep=StringGetCharacter(FRACTION_SEPARATOR,0);
      
      int k1 = 0;       
      k1=StringSplit(RiskRewardTPRatio,u_sep,result1);          
   
      dRiskRewardTPRatio = EvaluateDivisionExpression(result1[1]));
      TakeProfitPips = NormalizeDouble(dRiskRewardTPRatio * StopLossPips, 0);
#endif
      
   }
   
   AdjustSetupVals();  
   
   return;

}



// ========================================================================================


#ifdef _EA_11_
   if(GlobalValEXIST(_GV_GOTO_SLEEP_NOW_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_GOTO_SLEEP_NOW_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_GOTO_SLEEP_NOW_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_GOTO_SLEEP_NOW_22))
#endif
              {

               if(EnableWrapUpAndGoToSleep)      
               {
               
		// ========================================================================
         
               _CheckActivation=true;
               _CheckDeActivation=false;
               //FirstActivation = false;
               
               if(AddOneDayToActivateTime)
                 {
                  //  Update Activation time for Next Day...
                  ActivateTime = AddOneWorkingDay(ActivateTime,NextActivateAfter);
                  _ActivateTimeStr = TimeToString(ActivateTime);
                  ini_ActivateTimeStr = _ActivateTimeStr;
                  
                  // 07222025 Print("<<< New ActivateTimeStr: " + _ActivateTimeStr);
                 }
   
               if(AddOneDayToDeActivateTime)
                 {
                  //  Update De-Activation time for Next Day...
                  DeActivateTime = AddOneWorkingDay(DeActivateTime,NextDeActivateAfter);
                  _DeActivateTimeStr = TimeToString(DeActivateTime);
                  ini_DeActivateTimeStr = _DeActivateTimeStr;
                  
                  // 07222025 Print("<<< New DeActivateTimeStr: " + _DeActivateTimeStr);
                 }

               
		// ========================================================================                                          
               
#ifdef _EA_11_
               if(GlobalValDel(_GV_GOTO_SLEEP_NOW_11))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_11 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_11 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_12_
               if(GlobalValDel(_GV_GOTO_SLEEP_NOW_12))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_12 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_12 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_21_
               if(GlobalValDel(_GV_GOTO_SLEEP_NOW_21))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_21 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_21 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_22_

               if(GlobalValDel(_GV_GOTO_SLEEP_NOW_22))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_22 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_GOTO_SLEEP_NOW_22 + " CAN'T be DELETED...");
                 }
#endif
               
               }
               
               return;

               
              }


// ===============================================================================================




#ifdef _EA_11_
   if(GlobalValEXIST(_GV_FINISH_AND_EXIT_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_FINISH_AND_EXIT_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_FINISH_AND_EXIT_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_FINISH_AND_EXIT_22))
#endif
              {

		// ========================================================================
                if(EnableFinishExit)
                {    
   		          // 07222025 Print("Finish and Exit is ACTIVATE...");
                   
                   if(AutoRepeatAfterTP)
                   {
                      AutoRepeatAfterTP  =  !AutoRepeatAfterTP;
                      //ini_AutoRepeatAfterTP   = AutoRepeatAfterTP;
                   }
                      
                   if(!RemoveExpertAtEnd)
                   {
                      RemoveExpertAtEnd  =  !RemoveExpertAtEnd;
                      //ini_RemoveExpertAtEnd   = RemoveExpertAtEnd;
                   }

                }
               
		// ========================================================================  
		
#ifdef _EA_11_
               if(GlobalValDel(_GV_FINISH_AND_EXIT_11))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_11 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_11 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_12_
               if(GlobalValDel(_GV_FINISH_AND_EXIT_12))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_12 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_12 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_21_
               if(GlobalValDel(_GV_FINISH_AND_EXIT_21))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_21 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_21 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_22_
               if(GlobalValDel(_GV_FINISH_AND_EXIT_22))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_22 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_FINISH_AND_EXIT_22 + " CAN'T be DELETED...");
                 }
#endif
               return;
		
              }


// ===============================================================================================


if(!EnableCrossSynch && FirstTimeCrossEqualizeTP && FileIsExist(CrossEqualizeTPFileName, FILE_READ))        
{
   double intDTakeProfitLevel = 0;
   
   int LastErr         =  -1;  
   ResetLastError();
   
   //  Read data from csv file...   
   int file_handle = FileOpen(CrossEqualizeTPFileName, FILE_READ|FILE_CSV|FILE_ANSI, '=');  
   if(file_handle != INVALID_HANDLE) 
     {        
          string Line1_Val1 = FileReadString(file_handle);
          intDTakeProfitLevel = FileReadNumber(file_handle);
          
          FileClose(file_handle); 
          // 07222025 Print("FirstTimeCrossEqualizeTP: File Read Value OK");  
          
          //  DELETE the File...
          // ==================================================
          int SuspendCounter = 0;
   
          ResetLastError();
          while((FileIsExist(CrossEqualizeTPFileName, FILE_READ)))
          {
               LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("ReceiveCrossEqualizeMessage - " + CrossEqualizeTPFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif      
               FileDelete(CrossEqualizeTPFileName);
               LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("ReceiveCrossEqualizeMessage - " + CrossEqualizeTPFileName + " >>> FileDelete Error: " + IntegerToString(LastErr));
#endif
               if(LastErr == 0) break;
               Sleep(SuspendThread2_TimePeriod);
               if(SuspendCounter++ > 35) break;
      
          }
      
      
   if(LastErr == 0 && SuspendCounter <= 35)
   {
#ifndef _NO_PRINTOUT   
      // 07222025 Print("ReceiveCrossEqualizeMessage " + CrossEqualizeTPFileName + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );
#endif 
   }
   else
   {
#ifndef _NO_PRINTOUT   
      // 07222025 Print("ReceiveCrossEqualizeMessage - Can''t Delete File: " + CrossEqualizeTPFileName + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
#endif       
      // RAISE ERROR AND SUSPEND
   }
     }
     else
     {
#ifndef _NO_PRINTOUT_       
         // 07222025 Print("Operation FileOpen for READ failed, error ", GetLastError());
         
         // RAISE ERROR AND SUSPEND
#endif         
         
     }
     
     TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - intDTakeProfitLevel) / Point, 0);
     dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
     
     //if(ProtectTakeProfit)
     //{
         TrailingTriggerPips  = TakeProfitPips - TakeProfitZonePIPS;
         dRiskRewardTTRatio   = TrailingTriggerPips / StopLossPips;
         
         TrailingTailPips     = TrailingTriggerPips - TakeProfitZonePIPS;
         dRiskRewardTSRatio   = TrailingTailPips / StopLossPips; 
     //}
     
     SetALLLineLevels();
     DrawALLLines();
     DrawALLLinesMetrixs();
     
}



#ifdef _EA_11_
   if(GlobalValEXIST(_GV_RUNAWAY_TARGET_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_RUNAWAY_TARGET_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_RUNAWAY_TARGET_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_RUNAWAY_TARGET_22))
#endif
              {
              

		// ========================================================================
                if(FirstTimeEqualizeSL)
                {    
   		          // 07222025 Print("New Calculated RUNAWAY STOP: " + DoubleToString(extStopLossLevel));
                   StopLossPips = NormalizeDouble(MathAbs(PriceTargetLevel - extStopLossLevel) / Point, 0);
                   LastStopLossPips = StopLossPips;
                   dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
                }
               
		// ========================================================================               

#ifdef _EA_11_
               if(GlobalValGet(_GV_RUNAWAY_TARGET_11, extStopLossLevel))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_11 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_11 + " CAN'T  GET...");
                 }
                                         

               if(GlobalValDel(_GV_RUNAWAY_TARGET_11))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_11 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_11 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_12_
               if(GlobalValGet(_GV_RUNAWAY_TARGET_12, extStopLossLevel))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_12 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_12 + " CAN'T  GET...");
                 }

               if(GlobalValDel(_GV_RUNAWAY_TARGET_12))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_12 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_12 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_21_
               if(GlobalValGet(_GV_RUNAWAY_TARGET_21, extStopLossLevel))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_21 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_21 + " CAN'T  GET...");
                 }

               if(GlobalValDel(_GV_RUNAWAY_TARGET_21))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_21 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_21 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_22_
               if(GlobalValGet(_GV_RUNAWAY_TARGET_22, extStopLossLevel))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_22 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_22 + " CAN'T  GET...");
                 }

               if(GlobalValDel(_GV_RUNAWAY_TARGET_22))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_22 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_RUNAWAY_TARGET_22 + " CAN'T be DELETED...");
                 }
#endif

		         SetALLLineLevels();
               DrawALLLines();
               DrawALLLinesMetrixs();
		
		         return;
		         
              }





#ifdef   _COMPENSATION_ENGINE_


#ifdef _EA_11_
   if(GlobalValEXIST(_GV_REFRESH_OPENS_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_REFRESH_OPENS_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_REFRESH_OPENS_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_REFRESH_OPENS_22))
#endif
              {
               // 07222025 Print("INSIDE REMOTE-REFRESH OPENS -> " + DoubleToString(NumOfOpens));


//#include <RefreshStops.mqh>

#ifdef _EA_11_
               if(GlobalValGet(_GV_REFRESH_OPENS_11,NumOfOpensDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_11 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_11 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfOpens=(int)NumOfOpensDb;                 

               if(GlobalValDel(_GV_REFRESH_OPENS_11))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_11 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_11 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_12_
               if(GlobalValGet(_GV_REFRESH_OPENS_12,NumOfOpensDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_12 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_12 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfOpens=(int)NumOfOpensDb;  
              

               if(GlobalValDel(_GV_REFRESH_OPENS_12))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_12 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_12 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_21_
               if(GlobalValGet(_GV_REFRESH_OPENS_21,NumOfOpensDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_21 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_21 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfOpens=(int)NumOfOpensDb;  

               if(GlobalValDel(_GV_REFRESH_OPENS_21))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_21 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_21 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_22_
               if(GlobalValGet(_GV_REFRESH_OPENS_22,NumOfOpensDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_22 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_22 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfOpens=(int)NumOfOpensDb;  

               if(GlobalValDel(_GV_REFRESH_OPENS_22))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_22 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_OPENS_22 + " CAN'T be DELETED...");
                 }
#endif

                 return;

              }

//#ifdef _EA_11_
//   if(GlobalValEXIST(_GV_REFRESH_STOPS_11))
//#endif
//#ifdef _EA_12_
//      if(GlobalValEXIST(_GV_REFRESH_STOPS_12))
//#endif
//#ifdef _EA_21_
//         if(GlobalValEXIST(_GV_REFRESH_STOPS_21))
//#endif
//#ifdef _EA_22_
//            if(GlobalValEXIST(_GV_REFRESH_STOPS_22))
//#endif
//              {
//               // 07222025 Print("INSIDE REMOTE-REFRESH STOPS -> " + StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//
//
////#include <RefreshStops.mqh>
//
//#ifdef _EA_11_
//               if(GlobalValGet(_GV_REFRESH_STOPS_11,NumOfStopsDb))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " GET successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " CAN'T  GET...");
//                 }
//
//               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
//               NumOfStops=(int)NumOfStopsDb;
//               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//               //ObjectSetString(ChartID(),
//               //                "ProtectionAttemptsValue",
//               //                OBJPROP_TEXT,
//               //                StringFormat("%02d",NumOfStops)+
//               //                " of "+
//               //                StringFormat("%02d",NumTimesToProtect));
//                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }                               
//
//               if(GlobalValDel(_GV_REFRESH_STOPS_11))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " DELETED successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " CAN'T be DELETED...");
//                 }
//#endif
//#ifdef _EA_12_
//               if(GlobalValGet(_GV_REFRESH_STOPS_12,NumOfStopsDb))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " GET successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " CAN'T  GET...");
//                 }
//
//               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
//               NumOfStops=(int)NumOfStopsDb;
//               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//               //ObjectSetString(ChartID(),
//               //                "ProtectionAttemptsValue",
//               //                OBJPROP_TEXT,
//               //                StringFormat("%02d",NumOfStops)+
//               //                " of "+
//               //                StringFormat("%02d",NumTimesToProtect));
//                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }                                 
//
//               if(GlobalValDel(_GV_REFRESH_STOPS_12))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " DELETED successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " CAN'T be DELETED...");
//                 }
//#endif
//#ifdef _EA_21_
//               if(GlobalValGet(_GV_REFRESH_STOPS_21,NumOfStopsDb))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " GET successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " CAN'T  GET...");
//                 }
//
//               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
//               NumOfStops=(int)NumOfStopsDb;
//               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//               //ObjectSetString(ChartID(),
//               //                "ProtectionAttemptsValue",
//               //                OBJPROP_TEXT,
//               //                StringFormat("%02d",NumOfStops)+
//               //                " of "+
//               //                StringFormat("%02d",NumTimesToProtect));
//                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }  
//
//               if(GlobalValDel(_GV_REFRESH_STOPS_21))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " DELETED successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " CAN'T be DELETED...");
//                 }
//#endif
//#ifdef _EA_22_
//               if(GlobalValGet(_GV_REFRESH_STOPS_22,NumOfStopsDb))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " GET successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " CAN'T  GET...");
//                 }
//
//               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
//               NumOfStops=(int)NumOfStopsDb;
//               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//               //ObjectSetString(ChartID(),
//               //                "ProtectionAttemptsValue",
//               //                OBJPROP_TEXT,
//               //                StringFormat("%02d",NumOfStops)+
//               //                " of "+
//               //                StringFormat("%02d",NumTimesToProtect));
//                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }  
//
//               if(GlobalValDel(_GV_REFRESH_STOPS_22))
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " DELETED successfully...");
//                 }
//               else
//                 {
//                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " CAN'T be DELETED...");
//                 }
//#endif
//
//                 return;
//                 
//              }
//              
//              
              
//  ==================================================================================================================================================
              




#ifdef _EA_11_
   if(GlobalValEXIST(_GV_REFRESH_STOPS_11))
#endif
#ifdef _EA_12_
      if(GlobalValEXIST(_GV_REFRESH_STOPS_12))
#endif
#ifdef _EA_21_
         if(GlobalValEXIST(_GV_REFRESH_STOPS_21))
#endif
#ifdef _EA_22_
            if(GlobalValEXIST(_GV_REFRESH_STOPS_22))
#endif
              {
               // 07222025 Print("INSIDE REMOTE-REFRESH STOPS -> " + StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));


//#include <RefreshStops.mqh>

#ifdef _EA_11_
               if(GlobalValGet(_GV_REFRESH_STOPS_11,NumOfStopsDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfStops=(int)NumOfStopsDb;
               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
               //ObjectSetString(ChartID(),
               //                "ProtectionAttemptsValue",
               //                OBJPROP_TEXT,
               //                StringFormat("%02d",NumOfStops)+
               //                " of "+
               //                StringFormat("%02d",NumTimesToProtect));
                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }                               

               if(GlobalValDel(_GV_REFRESH_STOPS_11))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_11 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_12_
               if(GlobalValGet(_GV_REFRESH_STOPS_12,NumOfStopsDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfStops=(int)NumOfStopsDb;
               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
               //ObjectSetString(ChartID(),
               //                "ProtectionAttemptsValue",
               //                OBJPROP_TEXT,
               //                StringFormat("%02d",NumOfStops)+
               //                " of "+
               //                StringFormat("%02d",NumTimesToProtect));
                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }                                 

               if(GlobalValDel(_GV_REFRESH_STOPS_12))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_12 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_21_
               if(GlobalValGet(_GV_REFRESH_STOPS_21,NumOfStopsDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfStops=(int)NumOfStopsDb;
               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
               //ObjectSetString(ChartID(),
               //                "ProtectionAttemptsValue",
               //                OBJPROP_TEXT,
               //                StringFormat("%02d",NumOfStops)+
               //                " of "+
               //                StringFormat("%02d",NumTimesToProtect));
                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }  

               if(GlobalValDel(_GV_REFRESH_STOPS_21))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_21 + " CAN'T be DELETED...");
                 }
#endif
#ifdef _EA_22_
               if(GlobalValGet(_GV_REFRESH_STOPS_22,NumOfStopsDb))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " GET successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " CAN'T  GET...");
                 }

               //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
               NumOfStops=(int)NumOfStopsDb;
               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
               //ObjectSetString(ChartID(),
               //                "ProtectionAttemptsValue",
               //                OBJPROP_TEXT,
               //                StringFormat("%02d",NumOfStops)+
               //                " of "+
               //                StringFormat("%02d",NumTimesToProtect));
                               
//               if(!AutoFireAfterSL && MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
//               {
//               CurrentPosition = PositionOnHolt;
//               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//               //ChangeColorForItem("PositionLocationValue");
//               
//               //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
//               if(!OnHold)
//                  OnHold=!OnHold;
//                     
//                  InitToggleOnHold();
//               }  

               if(GlobalValDel(_GV_REFRESH_STOPS_22))
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " DELETED successfully...");
                 }
               else
                 {
                  // 07222025 Print("GlobalVAL: " + _GV_REFRESH_STOPS_22 + " CAN'T be DELETED...");
                 }
#endif

               // 02/27/2025  Synchronize both sides on SLOnHold event...
               if(!AutoFireAfterSL && NumOfStops > (AutoHPStopLoss - 1) && !OrderOpened)
               {

                  //  If in SINGLE SHOT mode THEN set ONHOLD
                  // 07222025 Print(">>>  AutoHOLD ACTIVATED REMOTELY: " + "  NumOfStops: " + IntegerToString(NumOfStops) + "  AutoHoldPeriodSL: " + IntegerToString(AutoHPStopLoss));
                  
                  AutoHPStopLoss = AutoHPStopLoss + AutoHoldPeriodSL;
                  CurrentPosition = PositionOnHolt;
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);

                  if(!OnHold)
                     OnHold=!OnHold;
                     
                  InitToggleOnHold();
               }



#ifndef _EARLY_SEMAPHOR_OFF_               
               //  Remove Existing Open Pos GlobalVAR, so that other EAs can readjust Curr Loss and Open New Positions              
               if( GlobalValDel(_GV_OPEN_POSITION_EXISTS) )
               {
                  // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " DELETED successfully from BODY...");
               }
               else
               {
                  // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " CAN'T be DELETED from BODY...");
               }
#endif
      
                 return;
                 
              }
            //  GV_REFRESH_LOTS & GV_REFRESH_STOPS come at the same time  
            //else
               //  ===========================================================
               
#ifdef _EA_11_
               if(GlobalValEXIST(_GV_REFRESH_LOTS_11))
#endif
#ifdef _EA_12_
                  if(GlobalValEXIST(_GV_REFRESH_LOTS_12))
#endif
#ifdef _EA_21_
                     if(GlobalValEXIST(_GV_REFRESH_LOTS_21))
#endif
#ifdef _EA_22_
                        if(GlobalValEXIST(_GV_REFRESH_LOTS_22))
#endif
                          {
                           // 07222025 Print("INSIDE REMOTE-REFRESH LOTS -> " + DoubleToString(Lots));

                           AcumulatedFloatingLoss = 0;
                           if(GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                             {
                              // 07222025 Print("Accumulated Loss REFRESHED & LOTS Updated...");
                             }
                           else
                             {
                              if(AcumulatedFloatingLoss < 0)
                              {
                                 // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                                 TransactionComplete = true;
                                 
                                 return;
                              }
               
                              // 07222025 Print("No AcumulatedFloatingLoss FOUND!!!");
                             }

                           // Calculate new  Lot VALUE based on current FLOATING LOSS
                           UpdatePriceLevels();


//#include <RefreshLotsDEL.mqh>
#ifdef _EA_11_
                           if(GlobalValDel(_GV_REFRESH_LOTS_11))
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_11 + " DELETED successfully...");
                             }
                           else
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_11 + " CAN'T be DELETED...");
                             }
#endif
#ifdef _EA_12_
                           if(GlobalValDel(_GV_REFRESH_LOTS_12))
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_12 + " DELETED successfully...");
                             }
                           else
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_12 + " CAN'T be DELETED...");
                             }
#endif
#ifdef _EA_21_
                           if(GlobalValDel(_GV_REFRESH_LOTS_21))
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_21 + " DELETED successfully...");
                             }
                           else
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_21 + " CAN'T be DELETED...");
                             }
#endif
#ifdef _EA_22_
                           if(GlobalValDel(_GV_REFRESH_LOTS_22))
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_22 + " DELETED successfully...");
                             }
                           else
                             {
                              // 07222025 Print("GlobalVAL: " + _GV_REFRESH_LOTS_22 + " CAN'T be DELETED...");
                             }
#endif

                          return;
                          
                          }
                        //else
                        

#ifdef _EA_11_
                           if(GlobalValEXIST(_GV_TRANSACTION_COMPLETE_11))
#endif
#ifdef _EA_12_
                              if(GlobalValEXIST(_GV_TRANSACTION_COMPLETE_12))
#endif
#ifdef _EA_21_
                                 if(GlobalValEXIST(_GV_TRANSACTION_COMPLETE_21))
#endif
#ifdef _EA_22_
                                    if(GlobalValEXIST(_GV_TRANSACTION_COMPLETE_22))
#endif
                                      {
                                      
                                       // 07222025 Print("INSIDE Transaction Complete BODY");
                                       TransactionComplete = true;


                                       // 07222025 Print("<<< GAME OVER >>>");
                                       //Sleep(SecPauseBeforeReRun*1000);
//#include <TransCompleteDEL.mqh>
#ifdef _EA_11_
                                       if(GlobalValDel(_GV_TRANSACTION_COMPLETE_11))
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_11 + " DELETED successfully...");
                                         }
                                       else
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_11 + " CAN'T be DELETED...");
                                         }
#endif
#ifdef _EA_12_
                                       if(GlobalValDel(_GV_TRANSACTION_COMPLETE_12))
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_12 + " DELETED successfully...");
                                         }
                                       else
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_12 + " CAN'T be DELETED...");
                                         }
#endif
#ifdef _EA_21_
                                       if(GlobalValDel(_GV_TRANSACTION_COMPLETE_21))
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_21 + " DELETED successfully...");
                                         }
                                       else
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_21 + " CAN'T be DELETED...");
                                         }
#endif
#ifdef _EA_22_
                                       if(GlobalValDel(_GV_TRANSACTION_COMPLETE_22))
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_22 + " DELETED successfully...");
                                         }
                                       else
                                         {
                                          // 07222025 Print("GlobalVAL: " + _GV_TRANSACTION_COMPLETE_22 + " CAN'T be DELETED...");
                                         }
#endif
                                       
                                       ExpertRemove();
                                       
                                       return;
                                        
                                      }
                                    //else

#ifdef _EA_11_
                                       if(GlobalValEXIST(_GV_REINIT_MAIN_LOOP_11))
#endif
#ifdef _EA_12_
                                          if(GlobalValEXIST(_GV_REINIT_MAIN_LOOP_12))
#endif
#ifdef _EA_21_
                                             if(GlobalValEXIST(_GV_REINIT_MAIN_LOOP_21))
#endif
#ifdef _EA_22_
                                                if(GlobalValEXIST(_GV_REINIT_MAIN_LOOP_22))
#endif
                                                  {
                                                  
#ifdef   _READJUST_ORIGINAL_LEVELS_ 
                                                  
                                                   //// 07222025 Print("INSIDE REMOTE-RESET BODY -> Reinint Main Loop...");

                                                   //  If SLIDING Entry_Point is ACTIVE then assume CURRENT Entry Position that has been SLIDED TO...  and adapt according to that...
                                                   if(UseEnvelopeSlider && EnvelopeSliderActive)
                                                      if(ExecCommand==BUY_STOP || ExecCommand==SELL_LIMIT) //  Coming from BELOW to reach its TARGET
                                                         PriceTargetLevel =Get_SliderVAL() - (EnvelopeEntryToleranceRange*Point);
                                                      else
                                                         if(ExecCommand==SELL_STOP || ExecCommand==BUY_LIMIT) //  Coming from ABOVE to reach its TARGET
                                                            PriceTargetLevel= Get_SliderVAL() + (EnvelopeEntryToleranceRange * Point);


                                                   //// 07222025 Print("New PriceTargetLevel: " + DoubleToStr(PriceTargetLevel, Digits));

//#include <ReadjustDirection.mqh>                                                   



                                                   if(ExecCommand==BUY_LIMIT)
                                                     {

                                                      LastExecCommand=ExecCommand;
                                                      //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

                                                      //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
                                                      RefreshRates();
                                                      if((Bid<PriceTargetLevel) &&
                                                         (Ask<=PriceTargetLevel))
                                                        {
                                                         // ABOVE
                                                         // BUY_LIMIT Remains the SAME provided that SPREAD ABOVE EP
                                                         //// 07222025 Print("Market BELOW Entry...");
                                                         if(LastExecCommand==BUY_LIMIT)
                                                            ExecCommand=BUY_STOP;

                                                        }
                                                      else
                                                         if((Bid>=PriceTargetLevel) &&
                                                            (Ask>PriceTargetLevel))
                                                           {
                                                            // BELOW
                                                            // BUY_LIMIT Migrated into a BUY_STOP provided that SPREAD < distance between EN & SL
                                                            //// 07222025 Print("Market ABOVE Entry...");
                                                            if(LastExecCommand==BUY_LIMIT)
                                                               ExecCommand=BUY_LIMIT;

                                                           }
                                                         else
                                                            if((Bid<PriceTargetLevel) &&
                                                               (Ask>PriceTargetLevel))
                                                              {
                                                               // INSIDE
                                                               //// 07222025 Print("Market ABOVE Entry...");
                                                               if(LastExecCommand==BUY_LIMIT)
                                                                  ExecCommand=BUY_LIMIT;

                                                              }

                                                      //// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
                                                     }
                                                   else
                                                      if(ExecCommand==SELL_LIMIT)
                                                        {
                                                         LastExecCommand=ExecCommand;
                                                         //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

                                                         //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
                                                         RefreshRates();
                                                         if((Bid<PriceTargetLevel) &&
                                                            (Ask<=PriceTargetLevel))
                                                           {
                                                            // ABOVE
                                                            // SELL_LIMIT Migrated into a SELL_STOP provided that SPREAD < distance between EN & SL
                                                            //// 07222025 Print("Bid: " + Bid + " Ask: " + Ask + "PriceTargetLevel: " + PriceTargetLevel + " -> Market BELOW Entry...");
                                                            if(LastExecCommand==SELL_LIMIT)
                                                               ExecCommand=SELL_LIMIT;

                                                           }
                                                         else
                                                            if((Bid>=PriceTargetLevel) &&
                                                               (Ask>PriceTargetLevel))
                                                              {
                                                               // BELOW
                                                               // SELL_LIMIT Remains the SAME provided that SPREAD BELOW EP
                                                               //// 07222025 Print("Bid: " + Bid + " Ask: " + Ask + "PriceTargetLevel: " + PriceTargetLevel + " -> Market ABOVE Entry......");
                                                               if(LastExecCommand==SELL_LIMIT)
                                                                  ExecCommand=SELL_STOP;

                                                              }
                                                            else
                                                               if((Bid<PriceTargetLevel) &&
                                                                  (Ask>PriceTargetLevel))
                                                                 {
                                                                  // INSIDE
                                                                  //// 07222025 Print("Bid: " + Bid + " Ask: " + Ask + "PriceTargetLevel: " + PriceTargetLevel + " -> Market ABOVE Entry......");
                                                                  if(LastExecCommand==SELL_LIMIT)
                                                                     ExecCommand=SELL_LIMIT;

                                                                 }

                                                         //// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
                                                        }
                                                      else
                                                         if(ExecCommand==SELL_STOP)
                                                           {
                                                            LastExecCommand=ExecCommand;
                                                            //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

                                                            //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
                                                            RefreshRates();
                                                            if((Bid<PriceTargetLevel) &&
                                                               (Ask<=PriceTargetLevel))
                                                              {
                                                               // PriceTargetLevel is ABOVE SPREAD
                                                               // SELL_STOP Migrated into a SELL_LIMIT provided that SPREAD < distance between EN & SL
                                                               //// 07222025 Print("Market BELOW Entry...");
                                                               if(LastExecCommand==SELL_STOP)
                                                                  ExecCommand=SELL_LIMIT;

                                                              }
                                                            else
                                                               if((Bid>=PriceTargetLevel) &&
                                                                  (Ask>PriceTargetLevel))
                                                                 {
                                                                  // BELOW
                                                                  // SELL_STOP Remains the SAME provided that SPREAD BELOW EP
                                                                  //// 07222025 Print("Market ABOVE Entry...");
                                                                  if(LastExecCommand==SELL_STOP)
                                                                     ExecCommand=SELL_STOP;

                                                                 }
                                                               else
                                                                  if((Bid<PriceTargetLevel) &&
                                                                     (Ask>PriceTargetLevel))
                                                                    {
                                                                     // INSIDE
                                                                     //// 07222025 Print("Market ABOVE Entry...");
                                                                     if(LastExecCommand==SELL_STOP)
                                                                        ExecCommand=SELL_LIMIT;

                                                                    }

                                                            //// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
                                                           }
                                                         else
                                                            if(ExecCommand==BUY_STOP)
                                                              {
                                                               LastExecCommand=ExecCommand;
                                                               //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));

                                                               //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again...
                                                               RefreshRates();
                                                               if((Bid<PriceTargetLevel) &&
                                                                  (Ask<=PriceTargetLevel))
                                                                 {
                                                                  // ABOVE
                                                                  // BUY_LIMIT Remains the SAME provided that SPREAD ABOVE EP
                                                                  //// 07222025 Print("Market BELOW Entry...");
                                                                  if(LastExecCommand==BUY_STOP)
                                                                     ExecCommand=BUY_STOP;

                                                                 }
                                                               else
                                                                  if((Bid>=PriceTargetLevel) &&
                                                                     (Ask>PriceTargetLevel))
                                                                    {
                                                                     // BELOW
                                                                     // BUY_LIMIT Migrated into a BUY_STOP provided that SPREAD < distance between EN & SL
                                                                     //// 07222025 Print("Market ABOVE Entry...");
                                                                     if(LastExecCommand==BUY_STOP)
                                                                        ExecCommand=BUY_LIMIT;

                                                                    }
                                                                  else
                                                                     if((Bid<PriceTargetLevel) &&
                                                                        (Ask>PriceTargetLevel))
                                                                       {
                                                                        // INSIDE
                                                                        //// 07222025 Print("Market ABOVE Entry...");
                                                                        if(LastExecCommand==BUY_STOP)
                                                                           ExecCommand=BUY_LIMIT;

                                                                       }

                                                               //// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
                                                              }

                                                   //  Pause for 30 seconds before ReRun
                                                   //Sleep(SecPauseBeforeReRun*1000);
                                                   
                                                   AdjustSetupVals();
                                                   ReInitMainLoop();

//#include <OnHoldCheck.mqh>                                                   
                                                   if(OnHold)
                                                   {
                                                   CurrentPosition=PositionOnHolt;
                                                   ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                                                   }
                                                   else
                                                   {
                                                   CurrentPosition=PositionPending;
                                                   ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                                                   }

                                                   InitToggleOnHold();

                                                   // Calculate new  Lot VALUE based on current FLOATING LOSS
                                                   UpdatePriceLevels();

                                                   //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops)+" of "+StringFormat("%02d",NumTimesToProtect));
                                                   ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));

                                                   // 07222025 Print("Expert Adviser has Successfully REINITIATED...");
                                                   

//#include <ReinitMainDEL.mqh>
#ifdef _EA_11_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_11))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_11 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_11 + " CAN'T be DELETED...");
                                                     }
#endif
#ifdef _EA_12_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_12))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_12 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_12 + " CAN'T be DELETED...");
                                                     }
#endif
#ifdef _EA_21_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_21))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_21 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_21 + " CAN'T be DELETED...");
                                                     }
#endif
#ifdef _EA_22_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_22))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_22 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_22 + " CAN'T be DELETED...");
                                                     }

#endif

#endif      // _READJUST_ORIGINAL_LEVELS_


#ifdef   _RERUN_FROM_START_

                                                   
#ifdef _EA_11_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_11))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_11 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_11 + " CAN'T be DELETED...");
                                                     }
#endif
#ifdef _EA_12_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_12))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_12 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_12 + " CAN'T be DELETED...");
                                                     }
#endif
#ifdef _EA_21_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_21))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_21 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_21 + " CAN'T be DELETED...");
                                                     }
#endif
#ifdef _EA_22_
                                                   if(GlobalValDel(_GV_REINIT_MAIN_LOOP_22))
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_22 + " DELETED successfully...");
                                                     }
                                                   else
                                                     {
                                                      // 07222025 Print("GlobalVAL: " + _GV_REINIT_MAIN_LOOP_22 + " CAN'T be DELETED...");
                                                     }

#endif

                                                   //  BUG FIX 02/17/2025
                                                   //  RACING condition - Master and Slave ran simultaneously
                                                   // 07222025 Print("<<< REINIT BODY >>>");
                                                   Sleep(SecPauseBeforeReRun * 1000);
                                                   _OnDeinit(0);   
                                                   //Sleep(1000);       // If you want to have a blank screen for 1 sec.
                                                   ReInitializeAllStartupVariables();                 
                                                   _OnInit();
                                                   

#endif      // _RERUN_FROM_START_


                                                  return;
                                                  
                                                  }
#endif   // _COMPENSATION_ENGINE_

}


#ifdef   _TIMER_ENABLED_
   if(!MyOnTick)
      uLastTick=GetTickCount();
#endif

  }


//  =====================================================================================================================================


//#include <InitAllVariables.mqh>


void GetAllStartupVariables()
{                                                                                                                                                                                                                                 
      ini_Lots                = Lots;
      ini_ProfitLossPerPip    = ProfitLossPerPip;
      ini_PriceTargetLevel    = PriceTargetLevel;   
      ini_MarketRefPoint      = MarketRefPoint;
      ini_ExecCommand         = ExecCommand;      
      ini_FirstTimeRR         = FirstTimeRR;         
      ini_StopLossPips        = StopLossPips;         
      ini_TakeProfitPips      = TakeProfitPips;
      ini_CalcRPbyTakeProfit  = CalcRPbyTakeProfit;
      ini_DrawTTriggerLevel   = DrawTTriggerLevel;  
      ini_TTriggerLineActive  = TTriggerLineActive;   
      ini_TrailingTriggerPips = TrailingTriggerPips;  
      ini_TrailingTailPips    = TrailingTailPips; 
      ini_AutoFireAfterSL     = AutoFireAfterSL;    
      ini_AutoFireAfterTP     = AutoFireAfterTP; 
      
      ini_ActivateTimeStr     = _ActivateTimeStr;
      ini_DeActivateTimeStr   = _DeActivateTimeStr;
      
      //ini_WrapUpLastTransTimeStr = _WrapUpLastTransTimeStr;
      
      ini_FirstTimeRunAway    = FirstTimeRunAway;

      ini_AutoRepeatAfterTP   = AutoRepeatAfterTP;
      ini_RemoveExpertAtEnd   = RemoveExpertAtEnd;
      
      ini_AutoRepeatAfterShutOff = AutoRepeatAfterShutOff;
      // 07222025 Print("GetAllStartupVariables - AutoRepeatAfterShutOff: " + IntegerToString(AutoRepeatAfterShutOff));
      
}                                                                             


// =============================================================================


void ReInitializeAllStartupVariables()
{
#ifdef   _PARTIAL_CLOSE_

      // 25.01.2025  Added in connection with Partial_Close...
      PartialCloseHit      =  false;
      FirstTimeGoodUntilCancel = false;
      ShowPartialCloseLine = EnablePartialCloseLine;
#endif

      Lots                 =  ini_Lots;
      ProfitLossPerPip     =  ini_ProfitLossPerPip;
      PriceTargetLevel     =  ini_PriceTargetLevel;
      MarketRefPoint       =  ini_MarketRefPoint;
      ExecCommand          =  ini_ExecCommand;
      FirstTimeRR          =  ini_FirstTimeRR;
      StopLossPips         =  ini_StopLossPips;
      TakeProfitPips       =  ini_TakeProfitPips;
      CalcRPbyTakeProfit   =  ini_CalcRPbyTakeProfit;
      DrawTTriggerLevel    =  ini_DrawTTriggerLevel;
      TTriggerLineActive   =  ini_TTriggerLineActive;
      TrailingTriggerPips  =  ini_TrailingTriggerPips;
      TrailingTailPips     =  ini_TrailingTailPips;
      AutoFireAfterSL      =  ini_AutoFireAfterSL;
      AutoFireAfterTP      =  ini_AutoFireAfterTP;
      
      _ActivateTimeStr     =  ini_ActivateTimeStr;
      _DeActivateTimeStr   =  ini_DeActivateTimeStr;
      
      //_WrapUpLastTransTimeStr = ini_WrapUpLastTransTimeStr;
            
      FirstTimeRunAway     =  ini_FirstTimeRunAway;
      
      AutoRepeatAfterTP    = ini_AutoRepeatAfterTP;
      RemoveExpertAtEnd    = ini_RemoveExpertAtEnd;
      
      AutoRepeatAfterShutOff = ini_AutoRepeatAfterShutOff;
      
      EmergencyResetSLAfterTrailing = false;      
      gPreventReset              =  false;
      _TicksPerPIP               =  10;
      CurrOrderSize              = 100000;
      
      CurrProfitLossPerPip    =  0;
      dRiskRewardTPRatio      =  0;
      OriginaldRiskRewardTPRatio = 0;
      
      dRiskRewardTTRatio      =  0;
      OriginaldRiskRewardTTRatio = 0;
      
      dRiskRewardTSRatio      =  0;
      OriginaldRiskRewardTSRatio = 0;
      
      CalcSLTPbyPipsORDiff    =  true;  
      
      OriginalStopLossPips    =  0;
      ProtectiveSL            =  false;
      
      StopLossLevel           =  0.00000;
      AverageTrueRangeVal     =  0.00000;      
      
      OriginalTakeProfitPips  =  0;
      TakeProfitLevel         =  0;
      
      OriginalTrailingTriggerPips = 0;
      TrailingTriggerLevel    =  0.00000;
      
      OriginalTrailingTailPips = 0;
      TrailingTailLevel       =  0.00000;
      
      BreakEvenPips           =  0; 
      dBreakEvenLevel         =  0;
      
      OriginalPriceTarget     =  0.00000;
      PriceTargetLevel        =  0.00000;
      CurPriceTargetLevel     =  0;
      OriginalExecCommand     =  NO_ORDER;
      LastExecCommand         =  NO_ORDER;
      
      ActiveMarketRoundUp     = true;   
      ActiveCommissionRoundUp = true;     
      NormDoublePrecission    = 2;
      
      PriceDir                =  NA;
      ErrorMessage            =  "";
      
      TradeContexSemaphor        = true;
      
      ActivateTime               = -1;
      DeActivateTime             = -1;
      
      //TimedActiveFirstTime       = true;
      //TimedDeActiveFirstTime     = true;
      
      _GetLastError              = 0;
      CurOpenTicket              = 0;
      ActualSlippage             = 0;
      AvarageSpread              = 0;
      
      AmIFirst                   = DontKnowYet;
      CurFloatingLoss            = 0.0;
      AcumulatedFloatingLoss     = 0.0;
      
      _GV_CURRENT_LOSS_VAL       = 0.0;
      CommissionMode             = 0;
      CommissionBasePair         = "";
      
      LastCandleStart            =  D'1970.01.01 00:00:00';
      
      TTriggerLineSELECTED       =  false;
      
      TTriggerActivated          =  false;
      TTailLineSELECTED          =  false;
      
      byTrailingStop             =  false;
      byTrailingTrigger          =  false;

      byTakeProfit               =  false;
               	 
      NumOfOpens                = 0;
      NumOfStops                = 0;
      NumOfStops2               = 0;
      NumOfStopsDb              = 0;
      
      // Do not reset as we need to count TPs between individual launches
#ifdef   _TAKE_PROFIT_COUNT_        
      //NumOfTakeProfits          = 0;
#else
      NumOfTakeProfits          = 0;
#endif
      
      NumOfTrys                 = 1;
      
      OrderOpened              = false;
      
      TransactionComplete      = false;
      OnHold                   = false;
      
      TimeOrderInitiated       = 0;
      TimeOrderOpened          = 0;
      TimeOrderStopped         = 0;
      TimeOrderTookProfit      = 0;
      
      LastStartTickTarget      = 0;
      LastStartTickStop        = 0;
      LastStartTickProfit      = 0;
      LastStartTickOpen        = 0;
      
      FirstTickTarget          = true;
      FirstTickOpen            = true;
      FirstTickStop            = true;
      FirstTickProfit          = true;
      FirstTimeTransComplete   = true;
      FirstTimeOnHold          = true;
      
      LastExecPos              = "";
      OutputString             = "";
      
      BuffOriginalStopLossPips =  0;
      BeforeLastStopLossPips   =  0;
      LastStopLossPips         =  0;
      
      TotalOpens              = 0;
      TotalStops              = 0;
      TotalProfits            = 0;
      
      DelayedPrintActive      = false;
      
      FirstTimeDelayPrint     = true;
      LastStartTickDelayedPrint = 0;
      
      ButtonIsSelected     =  false;
      ButtonIsPressed      =  true;
      DragEnabled          =  false;
      ScrollingChanged     =  false;
      IsScrolling          =  false;
      
      x_coord              =  155;  // 100
      y_coord              =  30;    // 100
      x_size               =  150;
      y_size               =  25;
      
      AspectRatio          =  true;
      InpName              =  "AspectRatioOnOffButton_01";    // Button name
      
      InpCorner            =  CORNER_RIGHT_LOWER;   // Chart corner for anchoring
      InpFont              =  "Arial Black";                       // Font
      InpFontSize          =  8;                   // Font size
      InpColor             =  clrNavy;             // Text color
      InpBackColor         =  clrFireBrick;        // Background color
      InpBorderColor       =  clrYellow;           // Border color
      InpState             =  true;               // Pressed/Released
      InpBack              =  false;               // Background object
      InpSelection         =  false;               // Highlight to move
      InpHidden            =  false;                             // Hidden in the object list
      InpZOrder=0;                                 // Priority for mouse click
      
      TitleClicked         =  "Aspect Ratio ON";
      TitleReleased        =  "Aspect Ratio OFF";
      TextColorClicked     =  clrYellow;
      TextColorReleased    =  clrNavy;
      TextFontSizeClicked  =  10;
      TextFontSizeReleased =  10;
           
      TickConvertPair   =  "";
      TickConvertVal    =  0;
      
      //GoToSleep         = false;
      //GoToSleepNow      = false;
      ShutOffVeleveHIT  = false;
      
      FirstTimeSidewaysMarketShiftPos = true;
      GlobalShutOFF_Received = false;
   
}


void ReAlignExecCommand()
{
      
      if(PriceDir == NA)
         return;
         
      

         if((PriceDir==BELOW) && (ExecCommand==BUY_STOP))
           {
            if(FlipTargetLevel)
               ExecCommand=SELL_STOP;
            else
               ExecCommand=BUY_LIMIT;

            DiffLevels=0;


            //CalcSLTP(ExecCommand);

            ////// 07222025 Print("HIT2");
           }
         else
            if((PriceDir==ABOVE) && (ExecCommand==BUY_LIMIT))
              {
               if(FlipTargetLevel)
                  ExecCommand=SELL_LIMIT;
               else
                  ExecCommand=BUY_STOP;

               DiffLevels=0;

               //CalcSLTP(ExecCommand);


               ////// 07222025 Print("HIT22");
              }
            else
                     if((PriceDir==ABOVE) && (ExecCommand==SELL_STOP))
                       {
                        if(FlipTargetLevel)
                           ExecCommand=BUY_STOP;
                        else
                           ExecCommand=SELL_LIMIT;

                        DiffLevels=0;

                        //CalcSLTP(ExecCommand);


                        ////// 07222025 Print("HIT4");
                       }
                     else
                        if((PriceDir==BELOW) && (ExecCommand==SELL_LIMIT))
                          {
                           if(FlipTargetLevel)
                              ExecCommand=BUY_LIMIT;
                           else
                              ExecCommand=SELL_STOP;

                           DiffLevels=0;

                           //CalcSLTP(ExecCommand);

                           ////// 07222025 Print("HIT44");
                          }
                          else if((PriceDir==BELOW) && (ExecCommand==BUY_LIMIT))
                          {
                              // NO CHANGE...
                          }
                          else if((PriceDir==ABOVE) && (ExecCommand==BUY_STOP))
                          {
                              // NO CHANGE...
                          }
                          else if((PriceDir==INSIDE) && (ExecCommand==BUY_STOP))
                          {
                              // NO CHANGE...
                          }
                          else if((PriceDir==INSIDE) && (ExecCommand==BUY_LIMIT))
                          {
                              // NO CHANGE...
                          }
                          else
                          {
                           // 07222025 Print("ReAlignExecCommand: ERROR!!!  PriceDir: " + EnumToString(PriceDir) + " - ExecCommand: " + EnumToString(ExecCommand));
                          }


}


double EvaluateDivisionExpression(string strDivisionExpression)
{
   string result[2];

   //ushort  u_sep  =StringGetCharacter(DIVISION_SEPARATOR,0);
   //int k1 = StringSplit(strDivisionExpression, u_sep, result);
   
   int k1 = StringSplit(strDivisionExpression, DIVISION_SEPARATOR, result);
//   
//   if(k1 > 1)
//      dResult = NormalizeDouble((StringToDouble(result[0]) / StringToDouble(result[1])),8);
//   else
//      dResult = NormalizeDouble(StringToDouble(result[0]),8);
      
      if(k1 > 1)
         return((double)((StringToDouble(result[0])) / (StringToDouble(result[1]))));
      else
         return(double)StringToDouble(result[0]);
      
}


void DeleteAllGlobalVariables()
{

    GlobalVariablesDeleteAll("");
    _GetLastError = GetLastError();
		if ( _GetLastError != 0 )
		{
			// 07222025 Print("GlobalVariablesDeleteAll ( \"\") - Error #" + IntegerToString(_GetLastError ));
		}
		else
		{
		    // 07222025 Print("GlobalVariablesDeleteAll ( \"\") - All Deleted...");
		} 
}




void DrawFrontInterface(int X_Coord_Labels,
                        int Y_Coord_Labels,
                        int X_Diff,
                        int Y_Diff,
                        FontNames F_Name,
                        FontSizes F_Size,
                        color LabColor = clrLightSlateGray)
{

   int     X_Coord_Value   =  X_Coord_Labels + X_Diff;
   int     Y_Coord_Value   =  Y_Coord_Labels;
   
   int     FontSize        =  GetFontSize(F_Size);
   string  FontName        =  GetFontName(F_Name);
   

   if(!ShowTitleLine)
   {
      Y_Coord_Labels = Y_Coord_Labels  -  Y_Diff;
      Y_Coord_Value  = Y_Coord_Value   -  Y_Diff;
   } 
      

   string lblMatrix;
   uint lblLength = 0;
   uint lblWidth = 0;

   lblMatrix = PannelLine1;
   
   bool RetResult01 = TextGetSize(lblMatrix, lblLength, lblWidth);   
   uint NewRightTabPos   = X_Coord_Labels + lblLength;
   
   //bool RetResult1 = TextSetFont(FontName, FontSize * 10);
      
   if(!(ObjectFind("ProfitTargetMarker")<0))
            ObjectDelete("ProfitTargetMarker");
            
   ObjectCreate("ProfitTargetMarker", OBJ_LABEL, 0, 0, 0);// Creating obj.
   ObjectSet("ProfitTargetMarker", OBJPROP_CORNER, ActualTableCorrner);    // Reference corner
   ObjectSetInteger(ChartID(),"",OBJPROP_ANCHOR,ActualLabelAnchor);
   ObjectSetInteger(ChartID(),"ProfitTargetMarker",OBJPROP_COLOR, LabColor);
   ObjectSetInteger(ChartID(),"ProfitTargetMarker",OBJPROP_FONTSIZE,FontSize);
   ObjectSetString(ChartID(),"ProfitTargetMarker",OBJPROP_FONT,FontName); 
     
    
   lblMatrix = ProfitTargetMarker;
   bool RetResult02 = TextGetSize(lblMatrix, lblLength, lblWidth);
   
   
   ObjectSet("ProfitTargetMarker", OBJPROP_XDISTANCE, NewRightTabPos + lblLength / 2);// X coordinate
   ObjectSet("ProfitTargetMarker", OBJPROP_YDISTANCE, Y_Coord_Labels + ((CalcRPbyTakeProfit == true ? 7 : (CalcRPbyTrigOrTailLevel == true ? 8 : 9)) * Y_Diff));
   
   ObjectSetString(ChartID(),"ProfitTargetMarker",OBJPROP_TEXT,ProfitTargetMarker);

}



void OnTimer()
{

#ifdef _SNAG_IT_BUTTON_
   ActButton001WithEvents.TimerEvent();
#endif

}





void ButtonClickedResponse()
{
   if(OrderOpened)
   {
    
               // 07222025 Print("<<< SNAG IT BUTTON HIT >>>");
               
               if (WidenedSpreadProtection && CheckSpreadAtStopLoss)
                  if(IsSpreadWidened(AvarageSpread))
                     return;
                     
               if(CurOpenTicket <= 0)
                  return;
               
               if(!CloseOutTicket(CurOpenTicket, true))
               {
                  //// 07222025 Print("At Loss Can't CloseOutTicket: " + CurOpenTicket);
                  OnHold = true;
                  CurrentPosition=PositionOnHolt;
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, GetPriceDirString(PriceDir) + CurrentPosition);
                  ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT, "Critical WARNING: Can't CLOSE Market Order at a LOSS...");
                  ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,       "=======================================================");  
                                  
                  InitToggleOnHold();
                   
                  return;
               }
               else
               {
                  // 07222025 Print("Ticket #" + IntegerToString(CurOpenTicket) + " -> " + StringFormat("%02d. Closed at a LOSS!!!",(NumOfTrys)) + EnumToString(ExecCommand) + " -> " + EA_NAME_IDENTIFIER);
               }
               
               //  Remove the LayoutMap
               if(!(ObjectFind(objTargetLayoutMap)<0))
                  while (!ObjectDelete(objTargetLayoutMap))
                     Sleep(100);
                  
               if(!(ObjectFind(objRiskLayoutMap)<0))
                  while (!ObjectDelete(objRiskLayoutMap))
                     Sleep(100);
                  
               if(!(ObjectFind(objBreakEvenLevelLineName)<0))
                  while (!ObjectDelete(objBreakEvenLevelLineName))
                     Sleep(100);
                  
               if(!(ObjectFind(objBreakEvenArrow)<0))
                  while (!ObjectDelete(objBreakEvenArrow))
                     Sleep(100);
#ifdef   _PARTIAL_CLOSE_                  
               //  25.01.2025                      
               if(!(ObjectFind(objPartialCloseLevelLineName)<0))
                  while (!ObjectDelete(objPartialCloseLevelLineName))
                     Sleep(100);
                  
               if(!(ObjectFind(objPartialCloseArrow)<0))
                  while (!ObjectDelete(objPartialCloseArrow))
                     Sleep(100);
#endif 
                  
                  
                  
                  
                  
#ifdef   _COMPENSATION_ENGINE_  
    
               //  Obtain ACTUAL LOSS including SLIPPAGE
               //  Add it to CURRENT FLOATING LOSS GlobalVAR
               //  Post NEW FLOATING LOSS value inside GlobalVAR
               
               // 07222025 Print("PostCurrentLossToGlobalVAR!!!");
               if(!PostCurrentLossToGlobalVAR(CurOpenTicket))
               {
                  // 07222025 Print("Critical: Can't PostCurrentLossToGlobalVAR...");
                  // 07222025 Print("Emergency EXIT!!!");
                  TransactionComplete = true;
               }
               
               
#ifdef _EARLY_SEMAPHOR_OFF_               
               //  Remove Existing Open Pos GlobalVAR, so that other EAs can readjust Curr Loss and Open New Positions              
               if( GlobalValDel(_GV_OPEN_POSITION_EXISTS) )
               {
                  // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " DELETED successfully...");
               }
               else
               {
                  // 07222025 Print("GlobalVAL: " + _GV_OPEN_POSITION_EXISTS + " CAN'T be DELETED...");
               }
#endif 
#endif                   
          


                     // Closed at a PROFIT
                     // Proceed as if TakeProfit is HIT -> ReInitialize or Complete...                    
               
                     // 07222025 Print("<<<Stopped out by PROTECTIVE STOP...>>>");
                     switch (ExecCommand )
                     {
                           case BUY_STOP:
                           
                                       EmulateTakeProfitBUY_STOP();
                                       break;
                           
                           case SELL_STOP:
                           
                                       EmulateTakeProfitSELL_STOP();
                                       break;                             
                           
                           case BUY_LIMIT:
                           
                                       EmulateTakeProfitBUY_LIMIT();
                                       break;                             
                           
                           case SELL_LIMIT:
                           
                                       EmulateTakeProfitSELL_LIMIT();
                                       break;                             
                     }
                     
                     
                     return;
            }
  
        
     
      return;
}



//double GetCurrentButtonPL()
//{
//   static double CurrentLoss = 0;
//   static double CurrentComm = 0;
//   static double CurrentSwap = 0;
//   
//   
//   uint SuspendCounter = 0;
//   uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
//   bool isOrderSelected = OrderSelect(CurOpenTicket, SELECT_BY_TICKET,MODE_TRADES);
//   uint thisTickValue = GetTickCount();
//   
//   while(!isOrderSelected &&
//         ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel))
//     {
//      Sleep(SuspendThread_TimePeriod);
//      SuspendCounter++;
//   
//      isOrderSelected = OrderSelect(CurOpenTicket, SELECT_BY_TICKET,MODE_TRADES);
//     }
//   
//   
//   if(isOrderSelected)
//     {
//      CurrentLoss = OrderProfit();
//      CurrentComm = OrderCommission();
//      CurrentSwap = OrderSwap();
//   
//   
//      static double TotalNETLoss = (CurrentLoss) + (CurrentComm) + (CurrentSwap) - (AcumulatedFloatingLoss);
//      //// 07222025 Print("CurrentLoss: " + DoubleToString(CurrentLoss) + " CurrentComm: " + DoubleToString(CurrentComm) + " CurrentSwap: " + DoubleToString(CurrentSwap) + " AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
//   
//      return TotalNETLoss;
//      //return(" " + DoubleToString(TotalNETLoss, 2) + " " + DepositCurrencyName);
//      //return(DoubleToString(TotalNETLoss, 2));
//     }
//   else
//     {
//      int Err = GetLastError();
//      // 07222025 Print("GetCurrentPL: GetTicketInfo() - Can\'t OrderSelect: " + IntegerToString(CurOpenTicket));
//   
//      return(0);
//     }
//}