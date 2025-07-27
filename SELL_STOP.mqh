//+------------------------------------------------------------------+
//|                                                    SELL_STOP.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


         ////// 07222025 Print("LOTS: " + Lots + " TickValue: " + MarketInfo(Symbol(), MODE_TICKVALUE) + " ProfitLossPerPip: " + ProfitLossPerPip );
         //RefreshRates();

         //  Handle ENTRY_INTO_POSITION
         if(!OrderOpened)
           {
            if(FirstTickTarget)
              {             

               FirstTickTarget=!FirstTickTarget;
               TimeOrderInitiated=TimeCurrent();
               LastStartTickTarget=GetTickCount();
               
               //  One Time Code executed here...
              }

            RefreshRates();
//            //// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel + " | " + 
//                  "Ask: " + Ask + " | " + 
//                  "Bid: " + Bid + " | " + 
//                  "PriceDir: " + EnumToString(PriceDir) + " | " + 
//                  "ExecCommand: " + EnumToString(ExecCommand) + " | " + 
//                  "OrderOpened: " + OrderOpened  + " | " + 
//                  "OnHold: " + OnHold    );
            
#ifdef      _TrendLineControl_
            if(TrendLineTrigger && 
               TrendLineTriggerActive && 
               NewCandelPoped)
            {
               UpdatePriceTarget(ObjectGetValueByShift(TrendLineName, 0));
               //LastCandleStart = Time[0];
               //// 07222025 Print("UpdatePriceTarget: " + PriceTargetLevel);
            }

#endif            

#ifdef      _Envelopes_Slider_
            if(UseEnvelopeSlider && EnvelopeSliderActive &&
              NewCandelPoped)
            {
               if(ExecCommand == BUY_STOP || ExecCommand == SELL_LIMIT)                        //  Coming from BELOW to reach its TARGET 
                  if(!EnvelopeExactFloatingOrders)
                     PriceTargetLevel = Get_SliderVAL() - (EnvelopeEntryToleranceRange * Point);
                     else
                        PriceTargetLevel = Get_SliderVAL();
               else if(ExecCommand == SELL_STOP || ExecCommand == BUY_LIMIT)                    //  Coming from ABOVE to reach its TARGET               
                  if(!EnvelopeExactFloatingOrders)
                     PriceTargetLevel = Get_SliderVAL() + (EnvelopeEntryToleranceRange * Point);
                     else
                        PriceTargetLevel = Get_SliderVAL();
                  
               //PriceTarget = PriceTargetLevel;
            
               SetALLLineLevels();
               DrawALLLines();
               DrawALLLinesMetrixs();
               
               RefreshRates();
               LastCandleStart = Time[0];
               //// 07222025 Print("Envelopes_Slider SELL_STOP SET: " + PriceTargetLevel);
            }
#endif

            if(NewCandelPoped)
               NewCandelPoped = false;

            // START SELL_STOP
            RefreshRates();
            if((Bid > PriceTargetLevel)) //  So that you can SELL at this level, AFTER Bid becomes LESS than PriceTargetLevel
              {
               
                  if(DelayedPrintActive)
                  {
                     if(FirstTimeDelayPrint)
                     {
                        FirstTimeDelayPrint = false;
                        LastStartTickDelayedPrint = GetTickCount();
                        ////// 07222025 Print("FirstTimeDelay - GetTickCount()...");
                        //// 07222025 Print("START DELAYING PRINTING...");
                     }
                     else
                     {
                         if(((GetTickCount() - LastStartTickDelayedPrint) / 1000) >= DesiredTimeDelayAfterSL)
                         {
                           DelayedPrintActive =  false;
                           FirstTimeDelayPrint = true;
                           
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
                           
                           UpdatePriceLevels();
                           
                           //// 07222025 Print("Start PRINTING again...");
                         }
                         else
                         {
                           ////// 07222025 Print("Still DELAYING PRINTING...");
                         }
                     }
                  }
                  else
                  {
                     RefreshMarketRefPoint();
                     
                     
                     //  XX BUY_STOP @ $10.00/pip | 08:10:52 | 00:00:10 sec.
                     ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand)+ATLevel+
                                                                                    DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+Separator+
                                                                                    TimeToStr(TimeOrderInitiated,TargetTimeFormat)+Separator+
                                                                                    ConvertSecondsToHHMMSS((uint)((GetTickCount() - LastStartTickTarget) / 1000)) + MeasureSec);
                                                                                    //ConvertSecondsToHHMMSS((uint)NormalizeDouble(MathAbs((GetTickCount()-LastStartTickTarget)/1000),0))+MeasureSec);
                  }

               //ChangeColorForItem("ExecutePositionValue");
               //  Bid:140.223(fixed) | Bid: 140.123(dynamic) | TO ENTRY TARGET: 10.3 pips
               ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,StringFormat("%02d. ",(NumOfTrys))+BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+
                                                                                    DoubleToStr(Bid,Digits)+Separator+
                                                                                    ToEntry+DoubleToStr((Bid-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips);
               //ChangeColorForItem("PriceLevelProtectionValue");
               
#ifdef   _COMPENSATION_ENGINE_                
               if(AmIFirst == DontKnowYet)
               {
                  // If you FIND a GlobalVAR created by an external EA, it means YOU ARE NOT FIRST EA THAT OPENED INITIAL POSITION!!!
                  if( GlobalValEXIST(_GV_OPEN_POSITION_EXISTS) )
                  {
                     AmIFirst = ImNotFirst;
                     //// 07222025 Print("AmIFirst: ImNotFirst");
                     //// 07222025 Print("There is a GlobalVAL named: " + _GV_OPEN_POSITION_EXISTS);
                     
                     //  Disconnect Sliding
#ifdef _Envelopes_Slider_                     
                     if(UseEnvelopeSlider && !EnvelopeDynamicOrStaticGrid)
                        EnvelopeSliderActive = false;
#endif 
                  }
                   //else
                   //  //// 07222025 Print("There is NO GlobalVAL named: " + _GV_OPEN_POSITION_EXISTS);
               }
#endif 
               WindowRedraw();
// //// 07222025 Print("END OF WAITING TO OPEN POSITION...");
              }
            else  
              {
              
                     if(ExecCommand == SELL_STOP && 
                        NumOfOpens == 0 && 
                        EnableCrossSynch == false)
                        {
                           ExecCommand = SELL_LIMIT;
                           RefreshMarketRefPoint();
                           // 07222025 Print("Flipping Sides: SELL_LIMIT");
                           return;
                        }
                     
// OPEN POS LEVEL - TRIGGERED 
               //  If wide spread - EXIT!!! return;
               //  Check for WideSpread inside OpenOrder NO GOOD because after holding on while it DOES EXECUTE THE TRANSACTION TRIGGERED BY THE WIDE SPREAD instead of just CANCEL IT!!!
               if (WidenedSpreadProtection)
                  if(IsSpreadWidened(AvarageSpread))
                     return;
                     
              //  If the spread encapsulates the EP & SL - RE-ADJUST STOP OUTSIDE THE SPREAD AT [X] PIPS AWAY, so that you never open a position with the STOP inside the spread
              RefreshRates();
              if(!CheckEntryToExitDistance(PriceDir, ExecCommand, StopLossLevel, PriceTargetLevel, (Ask - Bid)))
               {
                     StopLossLevel = Ask + (SLBufferPips * Point);
                     MoveHLine(objStopLossLevelLineName,StopLossLevel);
                     DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                     ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                DoubleToStr(((StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                     //// 07222025 Print("SL too close to Entry Level...  SL Adjusted!");
               }
               
               
               
#ifdef   _COMPENSATION_ENGINE_                
               if(AmIFirst == DontKnowYet)
               {
                  AmIFirst = ImFirst;
                  //// 07222025 Print("AmIFirst: ImFirst");
                  
                  //  Disconnect Sliding
#ifdef _Envelopes_Slider_                     
                     if(UseEnvelopeSlider && !EnvelopeDynamicOrStaticGrid)
                        EnvelopeSliderActive = false;
#endif 
               }
               
               if(AmIFirst == ImFirst)   
               {
                  //  Create Open Pos GlobalVAR as a FLAG to ALL other EAs, that a position has been OPENED...                 
                  if( GlobalValSet(_GV_OPEN_POSITION_EXISTS, _GV_OPEN_POSITION_EXISTS_VAL) )
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " SET Successfully TO: " + _GV_OPEN_POSITION_EXISTS_VAL);
                  }
                  else
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " CAN'T be SET TO: " + _GV_OPEN_POSITION_EXISTS_VAL);
                  }
                  
                  //  Next time act as NotFirst - meaning Wait for CLOSED position before OPENING
                  
                  AmIFirst = ImNotFirst;
                  
                  //  Revized Call methodology
                  AcumulatedFloatingLoss = 0;
                  if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                  {
                     if(AcumulatedFloatingLoss < 0)
                     {
                        // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                        TransactionComplete = true;
                        
                        return;
                     }
                     else
                     {
                        // 07222025 Print("There is NO residual loss from a prior RUN...");
                     }
                  }
                  else
                  {
                     // 07222025 Print("There is residual loss from a prior RUN...");
                  }
                  
                  // 07222025 Print("AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
                  
                  if(AutoLotIncrease)
                  {
                     UpdatePriceLevels();    //  NEW 07.09.2024  - Recalculate BreakEvenPips & PipValue & Lots just before OPEN Position
                     // 07222025 Print("1. RECALCULATING LOTS PRIOR TO OPEN - " + DoubleToString(Lots));
                     //Lots = CalcNewLotSize(AcumulatedFloatingLoss);
                  }
                  
                 //// 07222025 Print("New Calculated LOTS: " + Lots);
                 
                 if(ButtonIsPressed)
                  {
                     ButtonIsPressed = false;
                     ReleasePushButtonUP();
                  }
                  
                  if(ShowTargetLayout)
                  {
                     //// 07222025 Print("<< DrawTargetLayout >>>");
                     DrawTargetLayout();
                  }
                  
                  if(ShowRiskLayout)
                  {
                     //// 07222025 Print("<< DrawRiskLayout >>>");
                     DrawRiskLayout();
                  }
                  
                  if(ShowBreakEvenLine && (BreakEvenPips >= 0))
                  {
                     
                     dBreakEvenLevel = NormalizeDouble(PriceTargetLevel - BreakEvenPips, Digits);
                     // 07222025 Print("dBreakEvenLevel: " + DoubleToString(dBreakEvenLevel));
                     
                     DrawHorizontalLine(objBreakEvenLevelLineName,
                                        dBreakEvenLevel,    //  For BUY_LIMIT & BUY_STOP is [PriceTargetLevel + BreakEvenPips] |||  For SELL_LIMIT & SELL_STOP is [PriceTargetLevel - BreakEvenPips]
                                        BreakEvenLineStyle,
                                        BreakEvenLineColor,
                                        BreakEvenLineWidth,
                                        BreakEvenBackground,
                                        "BreakEvenLevelLine");
                                        
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
                  }       

#ifdef _PARTIAL_CLOSE_

                  //  01.15.2025 - Partial Close...
                  if(ShowPartialCloseLine && (StopLossPips > 0))
                  {
                     PartialCloseLevel = NormalizeDouble(PriceTargetLevel - PartialCloseMultiplierPercent / 100 * StopLossPips * Point, Digits);  //  Establish PartialCloseLevel for future use ONLY when OrderOpened is TRUE...
                     // 07222025 Print("PartialCloseLevel: " + DoubleToString(PartialCloseLevel));
                     
                     DrawHorizontalLine(objPartialCloseLevelLineName,
                                        PartialCloseLevel,    
                                        PartialCloseLineStyle,
                                        PartialCloseLineColor,
                                        PartialCloseLineWidth,
                                        PartialCloseBackground,
                                        "PartialCloseLevelLine");
                                        
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
                  }    
#endif

                 if(EmergencyBreakEvenEXIT && (EmergencyBreakEvenAtRun <= NumOfStops))
                 {     
                       
                       TrailingTriggerLevel = dBreakEvenLevel;
                     TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);
                     
                     TrailingTailLevel = TrailingTriggerLevel;
                     TrailingTailPips = 0;
                     
                     if(!TTriggerLineActive)
                        TTriggerLineActive = !TTriggerLineActive;
                     
                     DrawAllArrows();
                     DrawALLLines();
                     DrawALLLinesMetrixs();

                
                 }                                   
               }
               else if(AmIFirst == ImNotFirst)
               {              
                  //// 07222025 Print("AmIFirst: ImNotFirst"); 
                     
                  // Received SIGNAL to OPEN POSITION...
                  // CHECK if another EA has ALREADY opened a Position
                  // If YES then CANCEL this SIGNAL!!!
                  
                  uint SuspendCounter = 0;    
                  uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
                  bool isThereOpenPosition = GlobalValEXIST(_GV_OPEN_POSITION_EXISTS);
                  uint thisTickValue = GetTickCount();
                  
                  while(isThereOpenPosition &&
                        ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel))
                        {
                           Sleep(SuspendThread_TimePeriod);
                           isThereOpenPosition = GlobalValEXIST(_GV_OPEN_POSITION_EXISTS);
                           SuspendCounter++;
                        }      
                  
                  //// 07222025 Print("SuspendCounter: " + SuspendCounter);
                  
                  //if(GlobalValEXIST(_GV_OPEN_POSITION_EXISTS))
                  if(isThereOpenPosition)
                  {
                     //// 07222025 Print("CANCELING SIGNAL!!!  There is an EXTERNAL OPEN POSITION...");
                     double EAhavingOpenPos = 0;
                     if(GetCurrentOpenPosGlobalVAR(EAhavingOpenPos))
                     {
                        //// 07222025 Print("EA Currently Holding Open Position: " + DoubleToStr(EAhavingOpenPos,1));
                     }
                     else
                     {
                        //// 07222025 Print("Can't EXTRACT GlobalVAR or Doesn't EXIST... ");
                     }
                     
                     //  This will make so that it NO LONGER trys to open SELL_STOP order
                     LastExecCommand = ExecCommand;
            		   //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));
            
                     //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again... 
                     RefreshRates();
                     if((Bid<PriceTargetLevel) && 
                        (Ask<=PriceTargetLevel))
                          {
                           // PriceTargetLevel is ABOVE SPREAD
                           // SELL_STOP Migrated into a SELL_LIMIT provided that SPREAD < distance between EN & SL
                  	      //// 07222025 Print("Market BELOW Entry...");
                           if(LastExecCommand == SELL_STOP)
                              ExecCommand = SELL_LIMIT;
                          }
                      else if((Bid>=PriceTargetLevel) && 
                              (Ask>PriceTargetLevel))
                          {
                           // BELOW
                           // SELL_STOP Remains the SAME provided that SPREAD BELOW EP
                  	      //// 07222025 Print("Market ABOVE Entry...");
                           if(LastExecCommand == SELL_STOP)
                              ExecCommand = SELL_STOP;

                          }
                      else if((Bid<PriceTargetLevel) && 
                              (Ask>PriceTargetLevel))
                          {
                           // INSIDE
                  	      //// 07222025 Print("Market ABOVE Entry...");
                           if(LastExecCommand == SELL_STOP)
                              ExecCommand = SELL_LIMIT;

                          }
                        
               		   //// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));

               		   
               		   //  Recalculate PriceTarget
#ifdef _Envelopes_Slider_               		   
               		   if(UseEnvelopeSlider && EnvelopeSliderActive ) 
       		            { 
                  		   if(ExecCommand == BUY_STOP || ExecCommand == SELL_LIMIT)                        //  Coming from BELOW to reach its TARGET 
                           if(!EnvelopeExactFloatingOrders)
                              PriceTargetLevel = Get_SliderVAL() - (EnvelopeEntryToleranceRange * Point);
                              else
                                 PriceTargetLevel = Get_SliderVAL();
                           else if(ExecCommand == SELL_STOP || ExecCommand == BUY_LIMIT)                    //  Coming from ABOVE to reach its TARGET               
                              if(!EnvelopeExactFloatingOrders)
                                 PriceTargetLevel = Get_SliderVAL() + (EnvelopeEntryToleranceRange * Point);
                                 else
                                    PriceTargetLevel = Get_SliderVAL();
                      
                           //PriceTarget = PriceTargetLevel;
                           
                           SetALLLineLevels();
                           DrawALLLines();
                           DrawALLLinesMetrixs();
                           
                        }
#endif                        
                     return;
                  }
                  
                  // *****************************************************************************************
                  // CHECK AND SEE IF OPEN ENTRY STILL RELEVANT!!!
                  // Is it ENVELOP situation BUY         -  EXIT if out of range

                     // 07222025 Print("PREPING TO OPEN NEW POSITION...");
                     
                     //  Revized Call methodology
                     AcumulatedFloatingLoss = 0;
                     if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                     {
                        if(AcumulatedFloatingLoss < 0)
                        {
                           // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                           TransactionComplete = true;
                           
                           return;
                        }

                                                   // Meaning no need to OPEN position as someone else took PROFIT when there is NO FloatingLoss Var - JUST RESET yourself!!!
                        //// 07222025 Print("CAN'T GET AcumulatedFloatingLoss...");
#ifdef _Envelopes_Slider_                        
                       if(UseEnvelopeSlider && EnvelopeSliderActive ) 
       		            { 
                  		   if(ExecCommand == BUY_STOP || ExecCommand == SELL_LIMIT)                        //  Coming from BELOW to reach its TARGET 
                           if(!EnvelopeExactFloatingOrders)
                              PriceTargetLevel = Get_SliderVAL() - (EnvelopeEntryToleranceRange * Point);
                              else
                                 PriceTargetLevel = Get_SliderVAL();
                           else if(ExecCommand == SELL_STOP || ExecCommand == BUY_LIMIT)                    //  Coming from ABOVE to reach its TARGET               
                              if(!EnvelopeExactFloatingOrders)
                                 PriceTargetLevel = Get_SliderVAL() + (EnvelopeEntryToleranceRange * Point);
                                 else
                                    PriceTargetLevel = Get_SliderVAL();
                      
                           //PriceTarget = PriceTargetLevel;
                        }
                        
                        //  This will make so that it NO LONGER trys to open SELL_STOP order
                        LastExecCommand = ExecCommand;
               		   //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));
               
                        //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again... 
                        RefreshRates();
                        if((Bid<PriceTargetLevel) && 
                           (Ask<=PriceTargetLevel))
                             {
                              // PriceTargetLevel is ABOVE SPREAD
                              // SELL_STOP Migrated into a SELL_LIMIT provided that SPREAD < distance between EN & SL
                     	      //// 07222025 Print("Market BELOW Entry...");
                              if(LastExecCommand == SELL_STOP)
                                 ExecCommand = SELL_LIMIT;
                             }
                         else if((Bid>=PriceTargetLevel) && 
                                 (Ask>PriceTargetLevel))
                             {
                              // BELOW
                              // SELL_STOP Remains the SAME provided that SPREAD BELOW EP
                     	      //// 07222025 Print("Market ABOVE Entry...");
                              if(LastExecCommand == SELL_STOP)
                                 ExecCommand = SELL_STOP;

                             }
                         else if((Bid<PriceTargetLevel) && 
                                 (Ask>PriceTargetLevel))
                             {
                              // INSIDE
                     	      //// 07222025 Print("Market ABOVE Entry...");
                              if(LastExecCommand == SELL_STOP)
                                 ExecCommand = SELL_LIMIT;

                             }
                        
              		//// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));
               		
#endif
               		   // Meaning no need to OPEN position as someone else took PROFIT when there is NO FloatingLoss Var - JUST RESET yourself!!!                         
                        //  RESPONSE HERE...
                        //  Put the HANDLER for Remote Initialization as if this EA wasn't stuck WAITING for Remote CLOSE of position to OPEN it would have executed the EA COMPLETE or EA ReInit HANDLER at the END of BODY

// Do NOTHING!!!
//#include <RemoteReset2.mqh>
                        
                        TransactionComplete = true;
                        
                        return;

                     }
                     else
                     {
                        //  Create Open Pos GlobalVAR as a FLAG to ALL other EAs, that a position has been OPENED...                 
                        if( GlobalValSet(_GV_OPEN_POSITION_EXISTS, _GV_OPEN_POSITION_EXISTS_VAL) )
                        {
                           //// 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " SET Successfully TO: " + _GV_OPEN_POSITION_EXISTS_VAL);
                        }
                        else
                        {
                           //// 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " CAN'T be SET TO: " + _GV_OPEN_POSITION_EXISTS_VAL);
                        }
      
                        
                        //  Simulate CLICK on Aspect Ratio Button
                        if(ButtonIsPressed)
                        {
                           ButtonIsPressed = false;
                           ReleasePushButtonUP();
                        }

                        if(ShowTargetLayout)
                        {
                           //// 07222025 Print("<< DrawTargetLayout >>>");
                           DrawTargetLayout();
                        }
                        
                        if(ShowRiskLayout)
                        {
                           //// 07222025 Print("<< DrawRiskLayout >>>");
                           DrawRiskLayout();
                        }               
                                  
                        
                        //// Calculate new  Lot VALUE based on current FLOATING LOSS 
                        if(AutoLotIncrease)
                        {
                           UpdatePriceLevels();    //  NEW 07.09.2024  - Recalculate BreakEvenPips & PipValue & Lots just before OPEN Position
                           // 07222025 Print("2. RECALCULATING LOTS PRIOR TO OPEN - " + DoubleToString(Lots));
                           //Lots = CalcNewLotSize(AcumulatedFloatingLoss);
                        }      
                                                
                  
                        if(ShowBreakEvenLine && (BreakEvenPips >= 0))
                        {
                           dBreakEvenLevel = NormalizeDouble(PriceTargetLevel - BreakEvenPips, Digits);
                           // 07222025 Print("dBreakEvenLevel: " + DoubleToString(dBreakEvenLevel));
                     
                           DrawHorizontalLine(objBreakEvenLevelLineName,
                                              dBreakEvenLevel,    //  For BUY_LIMIT & BUY_STOP is [PriceTargetLevel + BreakEvenPips] |||  For SELL_LIMIT & SELL_STOP is [PriceTargetLevel - BreakEvenPips]
                                              BreakEvenLineStyle,
                                              BreakEvenLineColor,
                                              BreakEvenLineWidth,
                                              BreakEvenBackground,
                                              "BreakEvenLevelLine");
                                              
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
                                     
                       }
                  
#ifdef _PARTIAL_CLOSE_                         
                  //  01.15.2025 - Partial Close...
                  if(ShowPartialCloseLine && (StopLossPips > 0))
                  {
                     PartialCloseLevel = NormalizeDouble(PriceTargetLevel - PartialCloseMultiplierPercent / 100 * StopLossPips * Point, Digits);  //  Establish PartialCloseLevel for future use ONLY when OrderOpened is TRUE...
                     // 07222025 Print("PartialCloseLevel: " + DoubleToString(PartialCloseLevel));
                     
                     DrawHorizontalLine(objPartialCloseLevelLineName,
                                        PartialCloseLevel,    
                                        PartialCloseLineStyle,
                                        PartialCloseLineColor,
                                        PartialCloseLineWidth,
                                        PartialCloseBackground,
                                        "PartialCloseLevelLine");
                                        
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
                  }    
#endif
           
                       if(EmergencyBreakEvenEXIT && (EmergencyBreakEvenAtRun <= NumOfStops))
                       {     
                          
                          TrailingTriggerLevel = dBreakEvenLevel;
                     TrailingTriggerPips = NormalizeDouble(MathAbs(TrailingTriggerLevel-PriceTargetLevel)/Point, 0);
                     
                     TrailingTailLevel = TrailingTriggerLevel;
                     TrailingTailPips = 0;
                     
                     if(!TTriggerLineActive)
                        TTriggerLineActive = !TTriggerLineActive;
                     
                     DrawAllArrows();
                     DrawALLLines();
                     DrawALLLinesMetrixs();
                           
                       }  
                     }
                  
                     

               }
#endif

          
         
               //  =============================
               //  OPEN MARKET POSITION HERE!!!
               //  =============================
               //string ActiveComment = StringFormat("%02d %d %s %s", NumOfTrys, MAGICMA, EnumToString(ExecCommand), EA_IDENTIFIER);
               string ActiveComment = StringFormat("%02d %s %s", NumOfTrys, EnumToString(ExecCommand), EA_IDENTIFIER);
               int ActiveCommentLen=StringLen(ActiveComment);
               if(ActiveCommentLen >31)// Maximum String length available for order comment
               ActiveComment=StringSubstr(ActiveComment,0,31);// Shorten the String to 31 characters
               ActiveCommentLen=StringLen(ActiveComment);// Modify the Order Comment to fit in the Order Comment
               //// 07222025 Print("ActiveComment: " + ActiveComment);
               //// 07222025 Print("ActiveCommentLen: " + ActiveCommentLen);
               if(ActiveComment=="") Alert("NumOfTrys: " +IntegerToString(NumOfTrys) + " ExecCommand: " + EnumToString(ExecCommand) + "EA_IDENTIFIER: " + EA_IDENTIFIER );         
               
               if(Lots <= 0)
                  return;
                  
               if(!OpenUpMarketOrder(ExecCommand,
                                     Lots,
                                     ActiveComment,
                                     CurOpenTicket))
               {
                  //// 07222025 Print("Critical Can't OPEN Market Order...");
                  OnHold = true;
                  CurrentPosition=PositionOnHolt;
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, GetPriceDirString(PriceDir) + CurrentPosition);
                  ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT, "Critical WARNING: Can't OPEN Market Order...");
                  ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,       "============================================");
                  
                  InitToggleOnHold();

                  return;
               }
               else
               {
                  //// 07222025 Print("Ticket #" + CurOpenTicket + " -> " + StringFormat("%02d. Activated SUCCESSFULLY ",(NumOfTrys)) + EnumToString(ExecCommand) + " -> " + EA_NAME_IDENTIFIER);
                  
                  ////  VARIANT TO POST GLOBAL VAR AFTER THE ACTUAL POSITION OPENING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                  ////  Create Open Pos GlobalVAR as a FLAG to ALL other EAs, that a position has been OPENED...                 
                  //if( GlobalValSet(_GV_OPEN_POSITION_EXISTS, _GV_OPEN_POSITION_EXISTS_VAL) )
                  //   //// 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " SET Successfully TO: " + _GV_OPEN_POSITION_EXISTS_VAL);
                  //else
                  //   //// 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " CAN'T be SET TO: " + _GV_OPEN_POSITION_EXISTS_VAL);
               }
               
               //Debug("Price Level Reached on Ask: "+DoubleToStr(Ask,Digits));               

               OrderOpened=!OrderOpened;
               NumOfOpens++;


               #ifndef _EA_11_
                  if( GlobalValSet(_GV_REFRESH_OPENS_11, NumOfOpens) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_11 + " SET Successfully TO: " + DoubleToString(NumOfOpens));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_11 + " CAN'T be SET TO: " + DoubleToString(NumOfOpens));  
                  }
               #endif
               #ifndef _EA_12_
                           if( GlobalValSet(_GV_REFRESH_OPENS_12, NumOfOpens) )
                           {
                              // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_12 + " SET Successfully TO: " + DoubleToString(NumOfOpens));
                           }
                           else
                           {
                              // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_12 + " CAN'T be SET TO: " + DoubleToString(NumOfOpens));  
                           }
               #endif
               #ifndef _EA_21_
                           if( GlobalValSet(_GV_REFRESH_OPENS_21, NumOfOpens) )
                           {
                              // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_21 + " SET Successfully TO: " + DoubleToString(NumOfOpens));
                           }
                           else
                           {
                              // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_21 + " CAN'T be SET TO: " + DoubleToString(NumOfOpens));  
                           }
               #endif
               #ifndef _EA_22_
                           if( GlobalValSet(_GV_REFRESH_OPENS_22, NumOfOpens) )
                           {
                              // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_22 + " SET Successfully TO: " + DoubleToString(NumOfOpens));
                           }
                           else
                           {
                              // 07222025 Print("GlobalVAL " + _GV_REFRESH_OPENS_22 + " CAN'T be SET TO: " + DoubleToString(NumOfOpens));  
                           }
               #endif 


               RefreshRates();
               ObjectSetString(ChartID(), "PositionLocationValue", OBJPROP_TEXT, PositionActive + GetCurrentPL());
               //// 07222025 Print("PositionActive + GetCurrentPL(): " + PositionActive + GetCurrentPL());
               
               //ChangeColorForItem("PositionLocationValue");
               ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" SHORT"+ATLevel+
                                                                              DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip);
               
               //ChangeColorForItem("ExecutePositionValue");
               //  OPENED > 
               ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,OpenHeader);
               //ChangeColorForItem("PositionOutcomeHeaderValue");
               //  OPENED > Bid:140.223 | @Bid:140.225 | -0.02 pip slip | 08:13:15
               ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,StringFormat("%02d. ",NumOfTrys)+BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+
                                                                              ATLevel+DoubleToStr(Bid,Digits)+Separator+
                                                                              DoubleToStr((Bid-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+Separator+
                                                                              TimeToStr(TimeCurrent(),TargetTimeFormat));
               //ChangeColorForItem("PositionOutcomeValue");

               ObjectSetString(ChartID(),"PriceLevelProtectionValue",OBJPROP_TEXT,DoubleToStr(PriceTargetLevel,Digits));
               //ChangeColorForItem("PriceLevelProtectionValue");
               
               
               if(StopAdjustSlippage || ProfitAdjustSlippage || PriceTargetAdjustSlippage)
               {
                  ActualSlippage = 0;
                  if(!GetSlippage(CurOpenTicket, PriceTargetLevel, ActualSlippage))
                     {
                        // 07222025 Print("Can't Get SLIPPAGE...");
                        return;
                     }
                     else
                     {
                        // 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel) + "  ActualSlippage: " + DoubleToString((ActualSlippage / Point)));
                        // 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel) + "  ActualSlippage: " + DoubleToString((ActualSlippage)));
                     }
                  
                  
                  if(ShowBreakEvenLine && (ActualSlippage != 0) && (BreakEvenPips >= 0))
                     { 
                        dBreakEvenLevel = NormalizeDouble(PriceTargetLevel - ActualSlippage - BreakEvenPips, Digits);
                        
                        DrawHorizontalLine(objBreakEvenLevelLineName,
                                           dBreakEvenLevel,    //  For BUY_LIMIT & BUY_STOP is [PriceTargetLevel + BreakEvenPips] |||  For SELL_LIMIT & SELL_STOP is [PriceTargetLevel - BreakEvenPips]
                                           BreakEvenLineStyle,
                                           BreakEvenLineColor,
                                           BreakEvenLineWidth,
                                           BreakEvenBackground,
                                           "BreakEvenLevelLine2");
                                           
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
                     }          

#ifdef _PARTIAL_CLOSE_                  
                  //  01.15.2025 - Partial Close...
                  if(ShowPartialCloseLine && (StopLossPips > 0))
                  {
                     PartialCloseLevel = NormalizeDouble(PriceTargetLevel - ActualSlippage - PartialCloseMultiplierPercent / 100 * StopLossPips * Point, Digits);  //  Establish PartialCloseLevel for future use ONLY when OrderOpened is TRUE...
                     // 07222025 Print("PartialCloseLevel: " + DoubleToString(PartialCloseLevel));
                     
                     // For SELL order <=
                     //if(PartialCloseLevel <= dBreakEvenLevel)
                     if(PartialCloseLevel <= dBreakEvenLevel - PartialCloseBuffSL * Point)
                     {
                     DrawHorizontalLine(objPartialCloseLevelLineName,
                                        PartialCloseLevel,    
                                        PartialCloseLineStyle,
                                        PartialCloseLineColor,
                                        PartialCloseLineWidth,
                                        PartialCloseBackground,
                                        "PartialCloseLevelLine");
                                        
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
                   }
                    else
                    {
                     ShowPartialCloseLine = false;
                     if(!(ObjectFind(objPartialCloseLevelLineName)<0))
                     ObjectDelete(objPartialCloseLevelLineName);
                  
                     if(!(ObjectFind(objPartialCloseArrow)<0))
                     ObjectDelete(objPartialCloseArrow);
                     
                     // 07222025 Print("Partial Close SELL_STOP can't be implemented!!!");
                    }   
                  }    
#endif

   
                  //  Adjust the Entry Price Target by Actual Slippage
                  if(PriceTargetAdjustSlippage  && (ActualSlippage != 0))
                  {  
                     double LastPriceTarget = PriceTargetLevel;
                     //      FOR BUY ORDRTS is +
                     PriceTargetLevel = PriceTargetLevel - ActualSlippage; 
                     // Correct BreakEven Level too...
                     //dBreakEvenLevel = NormalizeDouble(PriceTargetLevel - BreakEvenPips, Digits);
	       	         //PriceTarget = PriceTargetLevel;
	       	         
	       	         // 07222025 Print("Adjusting for SLIPPAGE...");
	       	         // 07222025 Print("New PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
	       	         // 07222025 Print("New dBreakEvenLevel: " + DoubleToString(dBreakEvenLevel));
	       	         
   		            DrawArrowEntry(objDownArrowTarget,
               			           objDownArrowTarget,
               			           PriceTargetLevel,
               			           ArrowDOWN,
               			           ArrowDOWNBackground,
               		   		     ANCHOR_TOP,
               			           ArrowDOWNColor,
               			           ArrowDOWNSize,
               			           ArrowDOWNOffsetHor,
               			           ArrowDOWNOffsetVer);

                     if(PriceDir==ABOVE)
                     {
                        if(DrawTargetLevel)
                           DrawHorizontalLine(objPriceTargetLevelLineName,
                                              PriceTargetLevel,
                                              TargetLineStyle,
                                              TargetLineColor,          //  Color 1
                                              TargetLineWidth,
                                              TargetBackground,
                                              "PriceTargetLevelLine");
                     }
                     else if(PriceDir==BELOW)
                     {
                        if(DrawTargetLevel)
                           DrawHorizontalLine(objPriceTargetLevelLineName,
                                              PriceTargetLevel,
                                              TargetLineStyle,
                                              TargetLineColor2,         //  Color 2
                                              TargetLineWidth,
                                              TargetBackground,
                                              "PriceTargetLevelLine");
                     }        
                     else if(PriceDir==INSIDE)
                     {
                        if(DrawTargetLevel)
                           DrawHorizontalLine(objPriceTargetLevelLineName,
                                              PriceTargetLevel,
                                              TargetLineStyle,
                                              TargetLineColor3,         //  Color 3 
                                              TargetLineWidth,
                                              TargetBackground,
                                              "PriceTargetLevelLine");
                     }
                     
                     
                                    
                     //  Correct the Actual Slippage 
                     //  OPENED > Ask:140.223 | @Ask:140.225 | -0.02 pip slip | 08:13:15
                     ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,StringFormat("%02d. ",NumOfTrys)+ASKPrefix+DoubleToStr(LastPriceTarget,Digits)+Separator+
                                                                                   ATLevel+DoubleToStr(PriceTargetLevel,Digits)+Separator+
                                                                                   DoubleToStr(ActualSlippage/Point/_TicksPerPIP,1)+MeasurePips+Slippage+Separator+
                                                                                   TimeToStr(TimeCurrent(),TargetTimeFormat));

                  }
                  else   //                                                                                                                                                                               FOR BUY ORDRTS is +
                     ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,StringFormat("%02d. ",NumOfTrys)+ASKPrefix+DoubleToStr(PriceTargetLevel,Digits)+Separator+
                                                                                    ATLevel+DoubleToStr(PriceTargetLevel - ActualSlippage,Digits)+Separator+
                                                                                    DoubleToStr(ActualSlippage/Point/_TicksPerPIP,1)+MeasurePips+Slippage+Separator+
                                                                                    TimeToStr(TimeCurrent(),TargetTimeFormat));

                                     
                     
                  if(StopAdjustSlippage  && (ActualSlippage != 0))
                  {  
                     
                     //// 07222025 Print("Original StopLossLevel: " + StopLossLevel);
                     //          FOR BUY ORDRTS is +
                     StopLossLevel = StopLossLevel - ActualSlippage;
                     //// 07222025 Print("New StopLossLevel: " + StopLossLevel);
               
                     
                     if(AutoFireAfterSL )
                     {
                     if(DrawStopLevel)
                     {
                        DrawArrow(objStopArrow,
                               objStopArrow,
                               StopLossLevel,
                               StopArrow,
                               StopArrowBackground,
                               ANCHOR_BOTTOM,
                               StopArrowColor,
                               StopArrowSize,
                               StopArrowOffsetHor,
                               StopArrowOffsetVer);
                               
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
                        DrawArrow(objStopArrow,
                               objStopArrow,
                               StopLossLevel,
                               StopArrow,
                               StopArrowBackground,
                               ANCHOR_BOTTOM,
                               StopArrowColor,
                               StopArrowSize,
                               StopArrowOffsetHor,
                               StopArrowOffsetVer);
                               
                        DrawHorizontalLine(objStopLossLevelLineName,
                                              StopLossLevel,
                                              DASH,
                                              StopLineColor,
                                              StopLineWidth,
                                              StopBackground,
                                              "StopLossLevelLine");
                     }                                              
                     }
                  }
                  
                  
                  if(ProfitAdjustSlippage && (ActualSlippage != 0))
                  {
                     //// 07222025 Print("Original TakeProfitLevel: " + TakeProfitLevel);
                     //              FOR BUY ORDRTS is +
                     TakeProfitLevel = TakeProfitLevel - ActualSlippage;
                     //// 07222025 Print("New TakeProfitLevel: " + TakeProfitLevel);
                     
                     
                     if(AutoFireAfterTP )
                     {
                        if(DrawProfitLevel)
                        {
                           DrawArrow(objProfitArrow,
                               objProfitArrow,
                               TakeProfitLevel,
                               ProfitArrow,
                               ProfitArrowBackground,
                               ANCHOR_TOP,
                               ProfitArrowColor,
                               ProfitArrowSize,
                               ProfitArrowOffsetHor,
                               ProfitArrowOffsetVer);
                               
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
                           DrawArrow(objProfitArrow,
                               objProfitArrow,
                               TakeProfitLevel,
                               ProfitArrow,
                               ProfitArrowBackground,
                               ANCHOR_TOP,
                               ProfitArrowColor,
                               ProfitArrowSize,
                               ProfitArrowOffsetHor,
                               ProfitArrowOffsetVer);
                               
                           DrawHorizontalLine(objTakeProfitLevelLineName,
                                              TakeProfitLevel,
                                              DASH,
                                              ProfitLineColor,
                                              ProfitLineWidth,
                                              ProfitBackground,
                                              "TakeProfitLevelLine");
                        }
                     }
                  }
                  



#ifdef   _TrailingStop_
                  
                  if(TTriggerAdjustSlippage && (ActualSlippage != 0))
                  {
                     //// 07222025 Print("TrailingTriggerLevel: " + TrailingTriggerLevel);
                     TrailingTriggerLevel = TrailingTriggerLevel - ActualSlippage;
                     //// 07222025 Print("New TrailingTriggerLevel: " + TrailingTriggerLevel);
                     
                     //// 07222025 Print("TrailingTailLevel: " + TrailingTailLevel);
                     //                                            FOR BUY ORDRTS is -
                     TrailingTailLevel = TrailingTailLevel - ActualSlippage;
                     //// 07222025 Print("New TrailingTailLevel: " + TrailingTailLevel);
                     
                     
                               
                        if(TTriggerLineActive)
                        {
                        if(DrawTTriggerLevel)
                           {
                              DrawArrow(objTTriggerArrow,
                                        objTTriggerArrow,
                                        TrailingTriggerLevel,
                                        TTriggerArrow,
                                        TTriggerArrowBackground,
                                        ANCHOR_TOP,
                                        TTriggerArrowColor,
                                        TTriggerArrowSize,
                                        TTriggerArrowOffsetHor,
                                        TTriggerArrowOffsetVer);
                                        
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
                        }                        
                        else
                        {
                        if(DrawTTriggerLevel)
                           {
                              DrawArrow(objTTriggerArrow,
                                        objTTriggerArrow,
                                        TrailingTriggerLevel,
                                        TTriggerArrow,
                                        TTriggerArrowBackground,
                                        ANCHOR_TOP,
                                        TTriggerArrowColor,
                                        TTriggerArrowSize,
                                        TTriggerArrowOffsetHor,
                                        TTriggerArrowOffsetVer);
                                        
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
                        }
                  }
#endif                  
                  
                  // REMOVE ALL THAT BELOW AS IT IS AVAILABLE INDEPENDANTLY FOR EACH IF...
                  //SetALLLineLevels();
                  //DrawALLLines();
                  
               }
               
#ifdef _SEND_EMAIL_

               if(SendEmailUpdates)
               {
                  double ActualEntryPrice;
                  double ActualProfitTarget;
                  string ActualProfitTargetName;
                  double ActualCommission;
                  datetime ActualOpenTime;
                  
                  GetTicketOpenDateTime(CurOpenTicket, ActualOpenTime);
                  GetTicketOpenPrice(CurOpenTicket, ActualEntryPrice);
                  ActualProfitTarget = (CalcRPbyTakeProfit == true ? TakeProfitPips : (CalcRPbyTrigOrTailLevel == true ? TrailingTriggerPips : TrailingTailPips));
                  ActualProfitTargetName = (CalcRPbyTakeProfit == true ? "Take Profit Level" : (CalcRPbyTrigOrTailLevel == true ? "Trailing Trigger Level" : "Trailing Stop Level"));
                  GetTicketCommission(CurOpenTicket, ActualCommission);
                  
                  SendMail(EA_NAME_IDENTIFIER + " - " + OpenHeader,
                           OpenHeader+"\n"+
                           Symbol()+","+IntegerToString(Period())+"\n"+
                           StringFormat("%02d. ",NumOfOpens)+
                           " Ticket# "+IntegerToString(CurOpenTicket)+
                           " SHORT: "+DoubleToStr(Lots,2)+" Lots "+ATLevel+DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+"\n"+
                           BIDPrefix+DoubleToStr(PriceTargetLevel,Digits)+
                           Separator+ATLevel+DoubleToStr(ActualEntryPrice,Digits)+
                           Separator+DoubleToStr((ActualEntryPrice-PriceTargetLevel)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+
                           Separator+TimeToStr(ActualOpenTime,TargetTimeFormat)+"\n"+
                           "Commission: "+DoubleToString(ActualCommission,2)+"\n"+
                           "Stop Target Delta: "+DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips+"\n"+
                           "Profit Target Name: "+ActualProfitTargetName+"\n"+
                           "Profit Target Delta: "+DoubleToStr(ActualProfitTarget/_TicksPerPIP,1)+MeasurePips
                           );
                           
                          
               }
#endif
               
               
               WindowRedraw();
// //// 07222025 Print("END OF OPEN POSITION...");
              }
           }

// Handle STOP_LOSS 
         //else if(OrderOpened)
         if(OrderOpened)
           {
            if(FirstTickOpen)
              {
               LastExecPos=ObjectGetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT);
               FirstTickOpen=!FirstTickOpen;
               TimeOrderOpened=TimeCurrent();
               LastStartTickOpen=GetTickCount();
              }
              
            RefreshMarketRefPoint2();
            
            RefreshRates();
            if(Ask < StopLossLevel) //  So that you can BUY and CLOSE at this level
              {
              
               //if (WidenedSpreadProtection && CheckSpreadAtStopLoss)
               //   if(IsSpreadWidened(AvarageSpread))
               //      return;
                     
               //  1.00 SHORT |  00:00:10 sec.(dynamic)
               //ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,LastExecPos+Separator+ConvertSecondsToHHMMSS((uint)NormalizeDouble(MathAbs((GetTickCount()-LastStartTickTarget)/1000),0))+MeasureSec);
               ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,LastExecPos+Separator+
                                                                             ConvertSecondsToHHMMSS((uint)((GetTickCount()-LastStartTickOpen)/1000)) + MeasureSec); 
                                                                             //ConvertSecondsToHHMMSS((uint)NormalizeDouble(MathAbs((GetTickCount()-LastStartTickOpen)/1000),0))+MeasureSec);
               //ChangeColorForItem("ExecutePositionValue");
               
               //  Ask:140.020(fixed) | Ask:140.210(dynamic) | TO STOP LOSS: 20.3 pips

#ifdef   _TrailingStop_                
               if(!StopLossLevelLineSELECTED && !TTriggerActivated)  //  DON"T refresh here WHEN TTrigger Activated as REFRESH is done from the actual TTrailing section
               {
                  ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                                   DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                                                                                   DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                       									       DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);  // NEW 07.09.2024                                                                                                                                                 
                  //ChangeColorForItem("StopLossValue");
               }
#else
               if(!StopLossLevelLineSELECTED)  //  DON"T refresh here WHEN TTrigger Activated as REFRESH is done from the actual TTrailing section
               {
                  ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                                   DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                                                                                   DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                       									       DoubleToStr(StopLossPips/_TicksPerPIP,1)+MeasurePips);  // NEW 07.09.2024                                                                                                                                                  
                  //ChangeColorForItem("StopLossValue");
               }
#endif

               
#ifdef   _TrailingStop_            
               
               //  Trail STOP LOSS Here...
               if(TTriggerActivated)
               {
                  //double NewStopLossLevel = (Ask + (TrailingTailPips * Point));
                  double NewStopLossLevel = (Ask + (TrailingStopPips * Point));
                  
                  if((StopLossLevel > NewStopLossLevel) && TrailingENABLED)  //NEW 09.13.2024 - Move SL only if TrailingENABLED...
                  {
                     //  Move SL to this Level 
                     StopLossLevel = NewStopLossLevel;  
//                     ModifyMarketOrder(CurOpenTicket,
//                                       StopLossLevel);   
//                                       
                     MoveHLine(objStopLossLevelLineName,StopLossLevel);
                     DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                  
                     
                     ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                                      DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                                                                                      DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+" PROT: " +
                                                                                     DoubleToStr(((PriceTargetLevel - StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                  }
                                                                                   
                  //// 07222025 Print(ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                    //DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                    //DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+" PROT: " +
                    //DoubleToStr(((PriceTargetLevel - StopLossLevel)/Point/_TicksPerPIP),1)+MeasurePips);                                                                                   
               }
#endif               
               
               WindowRedraw();
// //// 07222025 Print("END OF WAITING TO CLOSE POSITION...");
              }
            else    	//  STOP HIT SELL_STOP 
              {
               
               //  =============================
               //  CLOSE MARKET POSITION HERE!!!
               //  TAKE A LOSS
               //  =============================
               // 07222025 Print("<<< STOP HIT SELL_STOP >>>");
               
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
               //// 07222025 Print("PostCurrentLossToGlobalVAR!!!");
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


#ifdef   _TrailingStop_                
               //  Check if CLOSED at LOSS or PROFIT
               //  Check if StopLossLevel was ABOVE or BELOW Entry Level
               //  If ABOVE - treat as TakeProfit
               //  If BELOW regardles of Trailing or NoTrailing - treat as LOSS
               if(TTriggerActivated)
               {
                  //  No NEED to CHECK Profit/Loss 
                  //double FinalResult = 0
                  //if(GetTicketInfo(CurOpenTicket, "PR", FinalResult))
                  //{
                  //   //// 07222025 Print("FinalResult EXTRACTED successfully -> " + FinalResult);
                  //}  
                  //else
                  //{
                  //   //// 07222025 Print("Can't EXTRACT FinalResult...");
                  //}
                  
                  // For BUY_LIMIT & Buy_STOP
                  if(PriceTargetLevel < StopLossLevel)
                  {
                     // Closed at a LOSS
                     // Proceed with LOSS COMPANSATION
                     // 07222025 Print("<<<Stopped out by TAKING LOSS...>>>");
                  }
                  else
                  {
                     // Closed at a PROFIT
                     // Proceed as if TakeProfit is HIT -> ReInitialize or Complete...
                     
                     // 07222025 Print("<<<Stopped out by PROTECTIVE STOP...>>>");
                     EmulateTakeProfitSELL_STOP();
                     
                     return;
                  }
               }
#endif 
               
               
               //Debug("Stop Loss Level Reached on Bid: "+DoubleToStr(Ask,Digits));
               OrderOpened=!OrderOpened;
               FirstTickOpen=!FirstTickOpen;
               FirstTickTarget=!FirstTickTarget;
               NumOfStops++;
               NumOfStops2++;
                           
               //  SEND SIGNAL TO REMOTE EAs to REFRESH NUMBER OF STOPS!!!                
                  
               #ifndef _EA_11_
                  if( GlobalValSet(_GV_REFRESH_STOPS_11, NumOfStops) )
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_11 + " SET Successfully TO: " + NumOfStops);
                  }
                  else
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_11 + " CAN'T be SET TO: " + NumOfStops);  
                  }
               #endif
               #ifndef _EA_12_
                           if( GlobalValSet(_GV_REFRESH_STOPS_12, NumOfStops) )
                           {
                              //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_12 + " SET Successfully TO: " + NumOfStops);
                           }
                           else
                           {
                              //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_12 + " CAN'T be SET TO: " + NumOfStops);  
                           }
               #endif
               #ifndef _EA_21_
                           if( GlobalValSet(_GV_REFRESH_STOPS_21, NumOfStops) )
                           {
                              //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_21 + " SET Successfully TO: " + NumOfStops);
                           }
                           else
                           {
                              //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_21 + " CAN'T be SET TO: " + NumOfStops);  
                           }
               #endif
               #ifndef _EA_22_
                           if( GlobalValSet(_GV_REFRESH_STOPS_22, NumOfStops) )
                           {
                              //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_22 + " SET Successfully TO: " + NumOfStops);
                           }
                           else
                           {
                              //// 07222025 Print("GlobalVAL " + _GV_REFRESH_STOPS_22 + " CAN'T be SET TO: " + NumOfStops);  
                           }
               #endif 
               
               
               // STOPPED-OUT>
               ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,StopHeader);
               //ChangeColorForItem("PositionOutcomeHeaderValue");
               // STOPPED-OUT> Ask:140.020 | @Ask:140.025 | -0.05 pip slip | 08:18:15
               ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,StringFormat("%02d. ",NumOfTrys)+ ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                             ATLevel+DoubleToStr(Ask,Digits)+Separator+
                                                                             DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+Separator+
                                                                             TimeToStr(TimeCurrent(),TargetTimeFormat));
               AcumulatedFloatingLoss = 0;
               if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
               {
                  if(AcumulatedFloatingLoss < 0)
                  {
                     // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                     TransactionComplete = true;
                     
                     return;
                  }

                     // 07222025 Print("There is NO residual loss from a prior RUN...");
               }
               else
               {
                  // 07222025 Print("There is residual loss from a prior RUN...");
               }
               
               // 07222025 Print("AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
               
#ifdef _SEND_EMAIL_
  
               string strTotalCloseLoss = GetTotalCloseLoss(CurOpenTicket);
               
               if(SendEmailUpdates)
               {
                  double ActualClosePrice; 
                  datetime ActualCloseTime;

                  double ActualOpenPrice;
                  double ActualDeltaPips;
                  double ActualCommission;
                                  
                  GetTicketClosePrice(CurOpenTicket, ActualClosePrice);
                  GetTicketCloseDateTime(CurOpenTicket, ActualCloseTime);
                  GetTicketOpenPrice(CurOpenTicket, ActualOpenPrice);
                  GetTicketCommission(CurOpenTicket, ActualCommission);
                  
                  ActualDeltaPips = MathAbs(ActualClosePrice-ActualOpenPrice);
                  
                  SendMail(EA_NAME_IDENTIFIER + " - " + StopHeader,
                           StopHeader+"\n"+
                           Symbol()+","+IntegerToString(Period())+"\n"+
                           StringFormat("%02d. ",NumOfTrys)+
                           " Ticket# "+IntegerToString(CurOpenTicket)+
                           " SHORT: "+DoubleToStr(Lots,2)+" Lots "+ATLevel+ DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+"\n"+
                           ASKPrefix+DoubleToStr(StopLossLevel,Digits)+
                           Separator+ATLevel+DoubleToStr(ActualClosePrice,Digits)+
                           Separator+DoubleToStr((StopLossLevel - ActualClosePrice)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+
                           Separator+TimeToStr(ActualCloseTime,TargetTimeFormat)+"\n"+
                           "Commission: "+DoubleToString(ActualCommission,2)+"\n"+
                           "Delta Pips: "+DoubleToStr(ActualDeltaPips/Point/_TicksPerPIP,1)+MeasurePips+"\n"+ 
                           "Current Loss: " + strTotalCloseLoss+"\n"+
                           "Cumulative Losses: -" + DoubleToStr(AcumulatedFloatingLoss, 2)
                           );

               }                         
#endif
                           
               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,PositionClosed + strTotalCloseLoss);
               //ChangeColorForItem("PositionLocationValue");
               ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,"CLOSE "+DoubleToStr(Lots,Lot_Precision)+" SHORT");
               //ChangeColorForItem("ExecutePositionValue");
               
               DelayedPrintActive = true;
               
               //  Show retries...
               //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT, IntegerToString(NumOfStops));
               //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
               ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
               
               //ChangeColorForItem("ProtectionAttemptsValue");
               
               if(FinalProtectionReached(NumOfStops))
                  return;
               

                  if(ShutOffValve && !ShutOffVeleveHIT && 
                  ((MAXLotsTrigger && Lots > MAXLotsAllowed) || 
                  (MAXAccumLossTrigger && AcumulatedFloatingLoss > MAXAccumLossAllowed)))
                  {
                  
                     // 07222025 Print("<<< ShutOFF Hit inside BUY_STOP...");
                     ShutOffVeleveHIT = true;
                     TransactionComplete = true;
                     
                     return;
                  }
                  

#ifdef _PARTIAL_CLOSE_

                if(PartialCloseHit)
               {                
                                    
                     // 07222025 Print("<<<Stopped out by SELL_STOP PROTECTIVE...>>>");
                     EmulateTakeProfitSELL_STOP();
                     
                     return;
                     
               }
#endif


#ifndef _NO_RECALC_LOTS_FOR_DISPLAY_
               //  Recalculate LOTS for Display purposes only...
               if(AutoLotIncrease)
                  Lots = CalcNewLotSize(AcumulatedFloatingLoss);
                  // 07222025 Print("New Calculated LOTS for Display purposes: " + Lots);
#endif       
                 
//  SEND SIGNAL TO REMOTE EAs to REFRESH FUTURE LOT SIZE!!!

      #ifndef _EA_11_
                  if( GlobalValSet(_GV_REFRESH_LOTS_11, Lots) )
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_11 + " SET Successfully TO: " + Lots);
                  }
                  else
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_11 + " CAN'T be SET TO: " + Lots);  
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_REFRESH_LOTS_12, Lots) )
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_12 + " SET Successfully TO: " + Lots);
                  }
                  else
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_12 + " CAN'T be SET TO: " + Lots);  
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_REFRESH_LOTS_21, Lots) )
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_21 + " SET Successfully TO: " + Lots);
                  }
                  else
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_21 + " CAN'T be SET TO: " + Lots);  
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_REFRESH_LOTS_22, Lots) )
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_22 + " SET Successfully TO: " + Lots);
                  }
                  else
                  {
                     //// 07222025 Print("GlobalVAL " + _GV_REFRESH_LOTS_22 + " CAN'T be SET TO: " + Lots);  
                  }
      #endif      
                                         
               RefreshRates();
               if(!CheckEntryToExitDistance(PriceDir, ExecCommand, StopLossLevel, PriceTargetLevel, (Ask - Bid)))
                 {
                  //  If the spread encapsulates the EP & SL - Put the system ON HOLD, so that the PENDING ORDER doesn't get activated within this EP/SL distance OR RE-ADJUST STOP OUTSIDE THE SPREAD AT [X] PIPS AWAY
                  if(AutoFireAfterSL)
                  {
                     StopLossLevel = Ask + (SLBufferPips * Point);
                     //StopLossPips =  (StopLossLevel - PriceTargetLevel) / Point;
                     MoveHLine(objStopLossLevelLineName,StopLossLevel);
                     DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                     ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                            DoubleToStr(((StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                  }
                  else
                  {
                     if(MathMod(NumOfStops, AutoHoldPeriodSL) == 0)
                     {
                        CurrentPosition = PositionOnHolt;
                        ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                        //ChangeColorForItem("PositionLocationValue");
                        
                        //// 07222025 Print("Put ONHOLD after taking STOP!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
                        if(!OnHold)
                           OnHold=!OnHold;
                           
                        InitToggleOnHold();
                     }
                  }
               } 
               //else if(!AutoFireAfterSL && ((MathMod(NumOfStops, AutoHoldPeriodSL) == 0)))    //if(!AutoFireAfterSL && (MathMod(NumOfStops, AutoHoldPeriodSL) == 0))
               else if(!AutoFireAfterSL && NumOfStops > AutoHPStopLoss - 1)    
               {

                  //  If in SINGLE SHOT mode THEN set ONHOLD
                  // 07222025 Print(">>>  AutoHOLD ACTIVATED: " + "  NumOfStops: " + IntegerToString(NumOfStops) + "  AutoHoldPeriodSL: " + IntegerToString(AutoHPStopLoss));
                  // 07222025 Print("OnHold BEFORE:" + IntegerToString(OnHold));
                  
                  AutoHPStopLoss = AutoHPStopLoss + AutoHoldPeriodSL;
                  CurrentPosition = PositionOnHolt;
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                  //ChangeColorForItem("PositionLocationValue");
                  //// 07222025 Print("Put ONHOLD after taking STOP - SINGLE SHOT MODE IS ON!!!" + " SL: " + StopLossLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
                  if(!OnHold)
                     OnHold=!OnHold;
                  
                  // 07222025 Print("OnHold AFTER:" + IntegerToString(OnHold));
                     
                  InitToggleOnHold();
               }
               else
               {
               }
               
               //  If SLIDING Entry_Point is ACTIVE then assume CURRENT Entry Position that has been SLIDED TO...  and adapt according to that...
#ifdef _Envelopes_Slider_               
               if(UseEnvelopeSlider && EnvelopeSliderActive ) 
       		      PriceTargetLevel = Get_SliderVAL();                 
#endif       		      
               
               LastExecCommand = ExecCommand;
      		   //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));
           
               //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again... 
               RefreshRates();
               if((Bid<PriceTargetLevel) && 
                  (Ask<=PriceTargetLevel))
                    {
                     // PriceTargetLevel is ABOVE SPREAD
                     // SELL_STOP Migrated into a SELL_LIMIT provided that SPREAD < distance between EN & SL
            	      //// 07222025 Print("Market BELOW Entry...");
                     if(LastExecCommand == SELL_STOP)
                        ExecCommand = SELL_LIMIT;
                    }
                else if((Bid>=PriceTargetLevel) && 
                        (Ask>PriceTargetLevel))
                    {
                     // BELOW
                     // SELL_STOP Remains the SAME provided that SPREAD BELOW EP
            	      //// 07222025 Print("Market ABOVE Entry...");
                     if(LastExecCommand == SELL_STOP)
                        ExecCommand = SELL_STOP;

                    }
                else if((Bid<PriceTargetLevel) && 
                        (Ask>PriceTargetLevel))
                    {
                     // INSIDE
            	      //// 07222025 Print("Market ABOVE Entry...");
                     if(LastExecCommand == SELL_STOP)
                        ExecCommand = SELL_LIMIT;

                    }
                 
         		 //// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));

      		   
      		   //  Recalculate PriceTarget
#ifdef _Envelopes_Slider_
      		   if(UseEnvelopeSlider && EnvelopeSliderActive ) 
	            { 
         		   if(ExecCommand == BUY_STOP || ExecCommand == SELL_LIMIT)                        //  Coming from BELOW to reach its TARGET 
                  if(!EnvelopeExactFloatingOrders)
                     PriceTargetLevel = Get_SliderVAL() - (EnvelopeEntryToleranceRange * Point);
                     else
                        PriceTargetLevel = Get_SliderVAL();
                  else if(ExecCommand == SELL_STOP || ExecCommand == BUY_LIMIT)                    //  Coming from ABOVE to reach its TARGET               
                     if(!EnvelopeExactFloatingOrders)
                        PriceTargetLevel = Get_SliderVAL() + (EnvelopeEntryToleranceRange * Point);
                        else
                           PriceTargetLevel = Get_SliderVAL();
             
                  //PriceTarget = PriceTargetLevel;
                  
                  
               //  Recalculate one more time to include the EnvelopeEntryToleranceRange 
                  LastExecCommand = ExecCommand;
         		   //// 07222025 Print("Current ExecCommand: " + EnumToString(LastExecCommand));
         
                  //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again... 
                  RefreshRates();
                  if((Bid<PriceTargetLevel) && 
                     (Ask<=PriceTargetLevel))
                       {
                        // PriceTargetLevel is ABOVE SPREAD
                        // SELL_STOP Migrated into a SELL_LIMIT provided that SPREAD < distance between EN & SL
               	      //// 07222025 Print("Market BELOW Entry...");
                        if(LastExecCommand == SELL_STOP)
                           ExecCommand = SELL_LIMIT;
                       }
                   else if((Bid>=PriceTargetLevel) && 
                           (Ask>PriceTargetLevel))
                       {
                        // BELOW
                        // SELL_STOP Remains the SAME provided that SPREAD BELOW EP
               	      //// 07222025 Print("Market ABOVE Entry...");
                        if(LastExecCommand == SELL_STOP)
                           ExecCommand = SELL_STOP;

                       }
                   else if((Bid<PriceTargetLevel) && 
                           (Ask>PriceTargetLevel))
                       {
                       // INSIDE
               	      //// 07222025 Print("Market ABOVE Entry...");
                        if(LastExecCommand == SELL_STOP)
                           ExecCommand = SELL_LIMIT;

                       }
                     
            		//// 07222025 Print("NEW ExecCommand: " + EnumToString(ExecCommand));

      		   
                  SetALLLineLevels();
                  DrawALLLines();
                  DrawALLLinesMetrixs();
                  
               } 
#endif


   if(FirstTimeSidewaysMarketShiftPos && 
     (MathMod(NumOfStops2, AutoHoldPeriodSL2) == 0 && 
     SidewaysMarketShiftPos && 
     !OnHold))
   {
      //  Shift at every other MOD condition...
      if(!MultiSidewaysShifts)
         FirstTimeSidewaysMarketShiftPos = false;  
      
      // 07222025 Print(">>> Inside SidewaysMarketShiftPos: " + IntegerToString(SidewaysMarketShiftPos) + " - " + "NumOfStops2: " + IntegerToString(NumOfStops2));
      // 07222025 Print("==========================================================");
      //  Get the actual difference in price levels      
      //  Shift all levels with the same offset 
      
      // VARIANT 1
      // RR 1 to 1 - HIGH RISK because TP distance very short...
      //TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - StopLossLevel) / Point, 0);
      //dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         
      // Jump One level lower...   
      //// 07222025 Print("Before - PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
      //PriceTargetLevel     =  (PriceTargetLevel - (PriceTargetLevel - StopLossLevel));
      //// 07222025 Print("After - PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
      
      // VARIANT 2
      // RR 1 to 3 - LOW RISK because TP distance extended from 2*SL to 3*SL to match reciprocal LONG
      //TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
      //dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
      
      //All other levels recalculated based on offset PIPs in SetALLLineLevels();
      //StopLossLevel        =  StopLossLevel        - LvlDiff;
      //TakeProfitLevel      =  TakeProfitLevel      - LvlDiff;
      //TrailingTriggerLevel =  TrailingTriggerLevel - LvlDiff;
      //TrailingTailLevel    =  TrailingTailLevel    - LvlDiff;
      
      // 07222025 Print("'>>> Attemting to OPEN EMERGENCY ORDER at TOP of CHANNEL...");
      
if(ExecCommand==BUY_LIMIT)
              {
               RefreshRates();
               PriceTargetLevel=Ask;
               //PriceTargetLevel = PriceTarget;
               
               // 07222025 Print("NEW PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
               if(ShiftPosEqualizeTP)
               {
                  // 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips));
                  TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
                  // 07222025 Print("NEW TakeProfitPips: " + DoubleToString(TakeProfitPips));
                  dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
               }
               
               SetALLLineLevels();
               
               PriceDir=GetCurrentPriceDirection(PriceTargetLevel,false);
               AjustColorsAccordingToDir(PriceDir);

               //AmIFirst = ImFirst;
               
               OpenPos_BUY_LIMIT();

               DrawALLLines();
               DrawALLLinesMetrixs();

              }
            else
               if(ExecCommand==BUY_STOP)
                 {
                  RefreshRates();
                  PriceTargetLevel=Ask;
                  //PriceTargetLevel = PriceTarget;
                  
                  // 07222025 Print("NEW PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
                  if(ShiftPosEqualizeTP)
                  {
                     // 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips));
                     TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
                     // 07222025 Print("NEW TakeProfitPips: " + DoubleToString(TakeProfitPips));
                     dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
                  }                  
                  
                  SetALLLineLevels();
                  
                  PriceDir=GetCurrentPriceDirection(PriceTargetLevel,false);
                  AjustColorsAccordingToDir(PriceDir);

                  //AmIFirst = ImFirst;
                  
                  OpenPos_BUY_STOP();

                  DrawALLLines();
                  DrawALLLinesMetrixs();
                 }
               else
                  if(ExecCommand==SELL_LIMIT)
                    {
                     RefreshRates();
                     PriceTargetLevel=Bid;
                     //PriceTargetLevel = PriceTarget;
                     
                     // 07222025 Print("NEW PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
                     if(ShiftPosEqualizeTP)
                     {
                        // 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips));
                        TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
                        // 07222025 Print("NEW TakeProfitPips: " + DoubleToString(TakeProfitPips));
                        dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
                     }                     
                     
                     SetALLLineLevels();
                     
                     PriceDir=GetCurrentPriceDirection(PriceTargetLevel,false);
                     AjustColorsAccordingToDir(PriceDir);

                     //AmIFirst = ImFirst;
                     
                     OpenPos_SELL_LIMIT();


                     DrawALLLines();
                     DrawALLLinesMetrixs();
                    }
                  else
                     if(ExecCommand==SELL_STOP)
                       {
                        RefreshRates();
                        PriceTargetLevel=Bid;
                        //PriceTargetLevel = PriceTarget;
                        
                        // 07222025 Print("NEW PriceTargetLevel: " + DoubleToString(PriceTargetLevel));
                        if(ShiftPosEqualizeTP)
                        {
                           // 07222025 Print("TakeProfitPips: " + DoubleToString(TakeProfitPips));
                           TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
                           // 07222025 Print("NEW TakeProfitPips: " + DoubleToString(TakeProfitPips));
                           dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
                        }                        
                        
                        SetALLLineLevels();
                        
                        PriceDir=GetCurrentPriceDirection(PriceTargetLevel,false);
                        AjustColorsAccordingToDir(PriceDir);

                        //AmIFirst = ImFirst;
                        
                        OpenPos_SELL_STOP();


                        DrawALLLines();
                        DrawALLLinesMetrixs();
                       }


            if(OrderOpened)  
            { 
      
      
#ifndef _EA_11_
            if( GlobalValSet(_GV_SHIFT_POS_NOW_11, StopLossLevel) )
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_11 + " SET Successfully TO:" + DoubleToString(StopLossLevel));
            }
            else
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_11 + " CAN'T be SET TO: 1"); 
            }
#endif
#ifndef _EA_12_
            if( GlobalValSet(_GV_SHIFT_POS_NOW_12, StopLossLevel) )
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_12 + " SET Successfully TO:" + DoubleToString(StopLossLevel));
            }
            else
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_12 + " CAN'T be SET TO: 1"); 
            }
#endif
#ifndef _EA_21_
            if( GlobalValSet(_GV_SHIFT_POS_NOW_21, StopLossLevel) )
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_21 + " SET Successfully TO:" + DoubleToString(StopLossLevel));
            }
            else
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_21 + " CAN'T be SET TO: 1"); 
            }
#endif
#ifndef _EA_22_
            if( GlobalValSet(_GV_SHIFT_POS_NOW_22, StopLossLevel) )
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_22 + " SET Successfully TO:" + DoubleToString(StopLossLevel));
            }
            else
            {
               // 07222025 Print("GlobalVAL " + _GV_SHIFT_POS_NOW_22 + " CAN'T be SET TO: 1"); 
            }
#endif
      }
            else
            {
               // 07222025 Print(">>>  Couldn't OPEN Emergency order at TOP of channel...");
            }
      
   }
   
   if(EnableCrossSynch && HitLiveMarket && FirstTimeRunAway)       // RunAway from Original Price Target
   {
      //  Get Reciprocal SL level
      //  Move Price Target (PT) to that level
      
      //  UpdatePriceTarget(Reciprocal Stop Loss Level)
      //  Send message to compansator to match its SL level with new master PT level
         // 07222025 Print(">>> Inside FirstTimeRunAway: " + "NumOfStops2: " + IntegerToString(NumOfStops2));
         // 07222025 Print("==========================================================");
         // 07222025 Print("External Stop Loss Level: " + DoubleToString(extStopLossLevel));
         
         FirstTimeRunAway = false;
         PriceTargetLevel = extStopLossLevel;

      
      //DrawTTriggerLevel = false;                       
      //TTriggerLineActive = false;
      
      if(FirstTimeEqualizeTP)
      {
         if(CalcRPbyTakeProfit)
         {
            TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
            dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
         else if(CalcRPbyTrigOrTailLevel)
         {
            TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TrailingTriggerLevel) / Point, 0);
            dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
         else
         {
            TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TrailingTailLevel) / Point, 0);
            dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
      }
      else
      {
         if(CalcRPbyTakeProfit)
         {
            //  Stays the same!!!
            //TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
            //dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
         else if(CalcRPbyTrigOrTailLevel)
         {
#ifdef   _AGRESSIVE_TPPIPS_RECALC_
            TakeProfitPips = TrailingTriggerPips;  // Alternative:  Add [+] TakeProfitZonePIPS to push it further away so that Trailing Trigg Level remains at the same level after TP Level - TakeProfitZonePIPS... 
#else
            TakeProfitPips = TrailingTriggerPips + TakeProfitZonePIPS; 
#endif

            dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
         else
         {
#ifdef   _AGRESSIVE_TPPIPS_RECALC_
            TakeProfitPips = TrailingTailPips;     // Alternative:  Add [+] 2 x TakeProfitZonePIPS to push it further away so that Trailing Trigg Level remains at the same level after TP Level - TakeProfitZonePIPS...
#else
            TakeProfitPips = TrailingTailPips + (2 * TakeProfitZonePIPS); 
#endif

            dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
      }

      if(!CalcRPbyTakeProfit)
         CalcRPbyTakeProfit = true;
         
         DrawFrontInterface(XCoord_Labels,
                            YCoord_Labels,
                            XDiff,
                            YDiff,
                            FontNameChoice,
                            FontSizeChoice,
                            LabelColor);
         
      //if(ProtectTakeProfit)
      //{
         //TrailingTriggerPips  =  (TakeProfitLevel - (TakeProfitZonePIPS * Point)) / Point;
         TrailingTriggerPips  =  TakeProfitPips - TakeProfitZonePIPS;
         dRiskRewardTTRatio   = TrailingTriggerPips / StopLossPips;
         
         TrailingTailPips     = TrailingTriggerPips - TakeProfitZonePIPS;
         dRiskRewardTSRatio   = TrailingTailPips / StopLossPips;
      //}
      
         
      if(FirstTimeEqualizeSL)
      {
         StopLossPips = NormalizeDouble(MathAbs(PriceTargetLevel - StopLossLevel) / Point, 0);
         LastStopLossPips = StopLossPips;
         dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         
         NotifySlaveToAdjustSL(extStopLossLevel);
      }
            
      if(FirstTimeCrossEqualizeTP)
      {
         SendCrossEqualizeMessage(PriceTargetLevel - (TakeProfitPips * Point));
      }
      
   }

               else if(EnableCrossSynch && HitLiveMarket && FirstTimeRR)
               {
               
                     FirstTimeRR = false;
                     //DrawTTriggerLevel = false;                       
                     //TTriggerLineActive = false;
                     
                     if(CalcRPbyTakeProfit)
                     {
                        //  Stays the same!!!
                        //TakeProfitPips = NormalizeDouble(MathAbs(PriceTargetLevel - TakeProfitLevel) / Point, 0);
                        //dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
                     }
                     else if(CalcRPbyTrigOrTailLevel)
                     {
#ifdef   _AGRESSIVE_TPPIPS_RECALC_
                     TakeProfitPips = TrailingTriggerPips;  // Alternative:  Add [+] TakeProfitZonePIPS to push it further away so that Trailing Trigg Level remains at the same level after TP Level - TakeProfitZonePIPS... 
#else
                     TakeProfitPips = TrailingTriggerPips + TakeProfitZonePIPS; 
#endif

                     dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
                     }
         else
         {
#ifdef   _AGRESSIVE_TPPIPS_RECALC_
                     TakeProfitPips = TrailingTailPips;     // Alternative:  Add [+] 2 x TakeProfitZonePIPS to push it further away so that Trailing Trigg Level remains at the same level after TP Level - TakeProfitZonePIPS...
#else
                     TakeProfitPips = TrailingTailPips + (2 * TakeProfitZonePIPS); 
#endif

                      dRiskRewardTPRatio = TakeProfitPips / StopLossPips;
         }
         
                     
                     
                        
                     //if(ProtectTakeProfit)
                     //{
                        //TrailingTriggerPips  =  (TakeProfitLevel - (TakeProfitZonePIPS * Point)) / Point;
                        TrailingTriggerPips  =  TakeProfitPips - TakeProfitZonePIPS;
                        dRiskRewardTTRatio   = TrailingTriggerPips / StopLossPips;
                        
                        TrailingTailPips     = TrailingTriggerPips - TakeProfitZonePIPS;
                        dRiskRewardTSRatio   = TrailingTailPips / StopLossPips;
                     //}
                     
                        if(!CalcRPbyTakeProfit)
                        CalcRPbyTakeProfit = true;
                        
                       DrawFrontInterface(XCoord_Labels,
                                          YCoord_Labels,
                                          XDiff,
                                          YDiff,
                                          FontNameChoice,
                                          FontSizeChoice,
                                          LabelColor);
                     

               }
               


#ifdef   _DYNAMIC_TARGETS_
               // Check & Resolve Canned Targets in MATRIX...
               if(UseDynamicTargets)
                  UpdateAllDynamicTargets();
#endif 
                  
               UpdatePriceLevels();
                  
               AdjustSetupVals();  
                  
               //  Number of tryes gets increased after taking a LOSS or a PROFIT
               NumOfTrys++;
               
               WindowRedraw();
//               //// 07222025 Print("END OF CLOSE POSITION...");
              }
           }
           
           
         if(OrderOpened && TakeProfitENABLED)
           {
            //  Handle TAKE_PROFIT
            RefreshRates();
            if(Ask>TakeProfitLevel && TakeProfitENABLED) //  So that you can BUY at this level
              {
               //  Ask:140.020(fixed) | Ask:140.210(dynamic) | TO TAKE-PROFIT: 20.3 pips
               if(!TakeProfittLevelLineSELECTED)
               {
                  ObjectSetString(ChartID(),"TakeProfitValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                           DoubleToStr(Ask,Digits)+Separator+
                                                                           ToProfit+DoubleToStr((Ask-TakeProfitLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                           DoubleToStr((PriceTargetLevel - TakeProfitLevel-ActualSlippage)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                           //"<"+CalcPercentComplete(Ask,TakeProfitLevel,PriceTargetLevel)+">"+Separator+
                                                                           RiskRewardRatio+DoubleToStr(dRiskRewardTPRatio,2));
                                                                           // NEW 09.09.2024
                                                                           
                  // Moved DOWN to HANDEL TRAILING TRIGGER SECTION
                  //ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(TrailingTriggerLevel,Digits)+Separator+ASKPrefix+DoubleToStr(Ask,Digits)+Separator+ToProfit+DoubleToStr(NormalizeDouble(Ask-TrailingTriggerLevel,Digits)/Point/10,1)+MeasurePips);

                  //ChangeColorForItem("TakeProfitValue");
               }
               
               WindowRedraw();
              
              }
            else   //  PROFIT HIT SELL_STOP
              {
              
              //  =============================
               //  CLOSE MARKET POSITION HERE!!!
               //  TAKE A PROFIT
               //  =============================
               // 07222025 Print("<<< PROFIT HIT SELL_STOP >>>");
               
                    
               if(CurOpenTicket <= 0)
                  return;
                  
               if(!CloseOutTicket(CurOpenTicket, false))
               {
                  //// 07222025 Print("At Profit Can't CloseOutTicket: " + CurOpenTicket);
                  OnHold = true;
                  CurrentPosition=PositionOnHolt;
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, GetPriceDirString(PriceDir) + CurrentPosition);
                  ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT, "Critical WARNING: Can't CLOSE Market Order at a PROFIT...");
                  ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,       "======================================================="); 
                                    
                  InitToggleOnHold();
                  
                  return;
               }
               else
               {
                  //// 07222025 Print("Ticket #" + CurOpenTicket + " -> " + StringFormat("%02d. Closed at a PROFIT!!!",(NumOfTrys)) + EnumToString(ExecCommand) + " -> " + EA_NAME_IDENTIFIER);
               }

               //  Remove the LayoutMap
               if(!(ObjectFind(objTargetLayoutMap)<0))
                  ObjectDelete(objTargetLayoutMap);

               if(!(ObjectFind(objRiskLayoutMap)<0))
                  ObjectDelete(objRiskLayoutMap);

               if(!(ObjectFind(objBreakEvenLevelLineName)<0))
                  ObjectDelete(objBreakEvenLevelLineName);

               if(!(ObjectFind(objBreakEvenArrow)<0))
                  ObjectDelete(objBreakEvenArrow);

#ifdef   _PARTIAL_CLOSE_                  
               //  25.01.2025     
               if(!(ObjectFind(objPartialCloseLevelLineName)<0))
                  ObjectDelete(objPartialCloseLevelLineName);
                  
               if(!(ObjectFind(objPartialCloseArrow)<0))
                  ObjectDelete(objPartialCloseArrow);
#endif 

               WindowRedraw();

               // 07222025 Print("<<<  TOOK PROFIT - SELL_STOP " + DoubleToString(EA_INDEX_NUMBER,1));

#ifdef   _COMPENSATION_ENGINE_                   
                  // Remove CurrentLoss GlobalVAR   
                  if( GlobalValDel( _GV_CURRENT_LOSS ) )
                  {
                     // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " DELETED successfully...");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " CAN'T be DELETED...");
                  }
                     
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
                  

               //  Do something here...
               //Debug("Take Profit Level Reached on Bid: "+DoubleToStr(Ask,Digits));
               OrderOpened=!OrderOpened;
               FirstTickTarget=!FirstTickTarget;
               FirstTickOpen=!FirstTickOpen;
               //TransactionComplete=!TransactionComplete;
#ifndef  _TAKE_PROFIT_COUNT_               
      
               NumOfTakeProfits++;
#endif
             
//  Get the latest value and increase it to reflect this last Profit taking and put it back in the Global Var so next time some other process can read it and increment it...               
#ifdef   _TAKE_PROFIT_COUNT_     


               if(!TPAutoFire)
               {
                  if(GlobalValGet(_GV_REFRESH_TAKE_PROFIT,NumOfTakeProfitsDb))
                    {
                     // 07222025 Print("GlobalVAL: " + _GV_REFRESH_TAKE_PROFIT + " GET successfully...");
                    }
                  else
                    {
                     // 07222025 Print("GlobalVAL: " + _GV_REFRESH_TAKE_PROFIT + " CAN'T  GET...");
                    }
   
                  //// 07222025 Print("New Calculated STOPS: " + NumOfStopsDb);
                  NumOfTakeProfits=(int)NumOfTakeProfitsDb + 1;  
                               

                  //  Store the latest Take Profit value from above...

                  if( GlobalValSet(_GV_REFRESH_TAKE_PROFIT, NumOfTakeProfits) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REFRESH_TAKE_PROFIT + " SET Successfully TO: " + DoubleToString(NumOfTakeProfits));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REFRESH_TAKE_PROFIT + " CAN'T be SET TO: " + DoubleToString(NumOfTakeProfits));  
                  }
                  
               //  Throw ExitWhenFinished one iteration before desired end
               // 07222025 Print(">>> NumOfTakeProfits: " + IntegerToString(NumOfTakeProfits));
               // 07222025 Print(">>> AutoHoldPeriodTP: " + IntegerToString(AutoHoldPeriodTP));
               // 07222025 Print("=========================================");
               if(!TPAutoFire && (NumOfTakeProfits == AutoHoldPeriodTP))
               {
                  //  Set the stage so next time doesn't come HERE but rather explores the alternative route to EXITING...
                  if(AutoRepeatAfterTP)
                      AutoRepeatAfterTP  =  !AutoRepeatAfterTP;
                      
                  if(!RemoveExpertAtEnd)
                      RemoveExpertAtEnd  =  !RemoveExpertAtEnd;
                      
                  // 07222025 Print(">>> AutoRepeatAfterTP: " + IntegerToString(AutoRepeatAfterTP));
                  // 07222025 Print(">>> RemoveExpertAtEnd: " + IntegerToString(RemoveExpertAtEnd));
                  
               }
                  
               }
               else
                  NumOfTakeProfits++;  
                  
#endif

               // TOOK PROFIT
               ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT, ProfitHeader);
               //ChangeColorForItem("PositionOutcomeHeaderValue");
               
               // TOOK PROFIT > Ask:140.020 | @Ask:140.025 | -0.05 pip slip | 08:18:15
               ObjectSetString(ChartID(),"PositionOutcomeValue",OBJPROP_TEXT,StringFormat("%02d. ",NumOfTrys)+ ASKPrefix+DoubleToStr(TakeProfitLevel,Digits)+Separator+
                                                                              ATLevel+DoubleToStr(Ask,Digits)+Separator+
                                                                              DoubleToStr((TakeProfitLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+Separator+
                                                                              TimeToStr(TimeCurrent(),TargetTimeFormat));
               //ChangeColorForItem("PositionOutcomeValue");
               
               ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,PositionClosed + GetTotalCloseLoss(CurOpenTicket));
               //  Reset Ticket number
               //CurOpenTicket = 0;
               
               //ChangeColorForItem("PositionLocationValue");
               ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,"CLOSE "+DoubleToStr(Lots,Lot_Precision)+" SHORT");
               //ChangeColorForItem("ExecutePositionValue");
               
               // Delay PrintOut
               DelayedPrintActive = true;
               
#ifdef _SEND_EMAIL_

               if(SendEmailUpdates)
               {
                  double ActualProfit; 
                  double ActualClosePrice;
                  datetime ActualCloseTime;
                  double ActualOpenPrice;
                  double ActualDeltaPips;
                  double ActualCommission;
                                  
                  GetTicketProfit(CurOpenTicket, ActualProfit);
                  GetTicketClosePrice(CurOpenTicket, ActualClosePrice);
                  GetTicketCloseDateTime(CurOpenTicket, ActualCloseTime);
                  GetTicketOpenPrice(CurOpenTicket, ActualOpenPrice);
                  GetTicketCommission(CurOpenTicket, ActualCommission);
                  
                  ActualDeltaPips = MathAbs(ActualClosePrice-ActualOpenPrice);
                  
                  SendMail(EA_NAME_IDENTIFIER + " - " + ProfitHeader,
                           ProfitHeader+"\n"+
                           Symbol()+","+IntegerToString(Period())+"\n"+
                           StringFormat("%02d. ",NumOfTrys)+
                           " Ticket# "+IntegerToString(CurOpenTicket)+
                           " SHORT: "+DoubleToStr(Lots,2)+" Lots "+ATLevel+ DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+"\n"+
                           ASKPrefix+DoubleToStr(TakeProfitLevel,Digits)+
                           Separator+ATLevel+DoubleToStr(ActualClosePrice,Digits)+
                           Separator+DoubleToStr((ActualClosePrice-TakeProfitLevel)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+
                           Separator+TimeToStr(ActualCloseTime,TargetTimeFormat)+"\n"+
                           "Commission: "+DoubleToString(ActualCommission,2)+"\n"+
                           "Delta Pips: "+DoubleToStr(ActualDeltaPips/Point/_TicksPerPIP,1)+MeasurePips+"\n"+ 
                           "Total Profit: " + DoubleToStr(ActualProfit,2));
               }
#endif

//                TAKE PROFIT DOESN'T REQUIRE TO BE MORE THAN ONE SPREAD AWAY FROM ENTRY POINT THE WAY STOP LOSS IS REQUIRED!!!              
               if(!AutoFireAfterTP && (MathMod(NumOfTakeProfits, AutoHoldPeriodTP) == 0))
               {
                  //  If in SINGLE SHOT mode THEN set ONHOLD
                  CurrentPosition = PositionOnHolt;
                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
                  //ChangeColorForItem("PositionLocationValue");
                  //// 07222025 Print("Put ONHOLD after taking PROFIT - SINGLE SHOT MODE IS ON!!!" + " SL: " + TakeProfitLevel + " EP: " + PriceTargetLevel + " Spread: " + (Ask - Bid));
                  if(!OnHold)
                     OnHold=!OnHold;
                     
                  InitToggleOnHold();
               }
               else
               {
               }
               

//             SELL_STOP DOES MIGRATE/MORPH INTO ANOTHER ORDER TYPE AFTER TAKE PROFIT (ONLY BUY_STOP & SELL_STOP MORPHS INTO A BUY_LIMIT & SELL_LIMITAFTER TAKE PROFIT
               LastExecCommand = ExecCommand;
               
               //  Re-Orient if spread ABOVE and BELOW so that it can switch into STOP or LIMIT again... 
               RefreshRates();
               if((Bid<PriceTargetLevel) && 
                  (Ask<=PriceTargetLevel))
                    {
                     // ABOVE
                     // BUY_LIMIT Remains the SAME provided that SL ABOVE EP
                     if(LastExecCommand == SELL_STOP)
                        ExecCommand = SELL_LIMIT;
                        
                   }
                else if((Bid>=PriceTargetLevel) && 
                        (Ask>PriceTargetLevel))
                    {
                     // BELOW
                     // BUY_LIMIT Migrated into a BUY_STOP provided that SPREAD < distance between EN & SL
                     if(LastExecCommand == SELL_STOP)
                        ExecCommand = SELL_STOP;
                     
                    }
               else if((Bid<PriceTargetLevel) && 
                        (Ask>PriceTargetLevel))
                    {
                    // INSIDE
                     if(LastExecCommand == SELL_STOP)
                        ExecCommand = SELL_LIMIT;
		              }



 #ifdef   _READJUST_ORIGINAL_LEVELS_ 
               if(AutoRepeatAfterTP)
               {
                    //  Pause for 30 seconds before ReRun
                    Sleep(SecPauseBeforeReRun * 1000);
                    

                    AdjustSetupVals();
                    ReInitMainLoop();
                    
                    // 07222025 Print("Expert Adviser has Successfully REINITIATED...");
                 
//#include <ReinitMainSET.mqh>                                  
#ifdef   _COMPENSATION_ENGINE_  
                 
      #ifndef _EA_11_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_11, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_11 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_12, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_12 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_21, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_21 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_22, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_22 + " CAN'T be SET TO: 1"); 
                  }
      #endif
#endif                   
                    
                    //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
                    ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
                    
                    //ChangeColorForItem("ProtectionAttemptsValue");
                    
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
                  
                  //// 07222025 Print("4. AutoRepeatAfterTP: " + AutoRepeatAfterTP);
               }
               else
               {
                  TransactionComplete=!TransactionComplete;

                  //// 07222025 Print("Expert Adviser has Successfully Completed this Session...\n==============================================");           
                  
//#include <TransCompleteSET.mqh> 
#ifdef   _COMPENSATION_ENGINE_  
      #ifndef _EA_11_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_11, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_11 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_12, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_12 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_21, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_21 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_22, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_22 + " CAN'T be SET TO: 1"); 
                  }
      #endif               
#endif

               // 07222025 Print("<<< GAME OVER - TRANSACTION COMPLETE>>>");
               Sleep(SecPauseBeforeReRun * 1000);
               if(RemoveExpertAtEnd)
                  ExpertRemove();
               
                                   
               }
#endif


//// SLAVE BOTS SHOULD ALWAYS HAVE ReRunFromStartOnActivation = FALSE & EnableCrossSynch = FALSE
//// TRUE for Master Bot in CROSSED - MARKET - AUTO RERUN FROM TP mode
//// FALSE for Slave Bot in BIASED - PENDING mode
//// FALSE for Master Bot in BIASED - PENDIG mode
//if(EnableCrossSynch)
//
//{                                      
//	_OnDeinit(0);   
//        ReInitializeAllStartupVariables();                 
//        _OnInit();
//}
//else
//{
//	// TRUE can be both Master in BIASED and Slave in BIASED mode
//	// FALSE can be only Slave in CROSSED - MARKET - AUTO RERUN FROM TP mode
//	if(ReRunFromStartOnActivation)
//	{
//		[<<<Reinit Reciprocal Bot>>>]
//
//		AdjustSetupVals();
//                ReInitMainLoop();
//	}
//	else 
//	{
//		[<<<Reinit Master Bot>>>]
//
//		ExpertRemove();
//		// Not needed as Master will replace template and initiate launch that way
//	}
//}


#ifdef   _RERUN_FROM_START_                    
                    
         if(AutoRepeatAfterTP)
            {
               //  Pause for 30 seconds before ReRun
               Sleep(DesiredTimeDelayAfterTP * 1000);


               //  Set to TRUE so that you can WAIT for a Key-Press in OnTick...
               //if(WaitForKeyPress)
               // EndOfRunCycle = true;
                                  
               if((TimeCurrent() > (DeActivateTime - (WrapUpAndGoToSleepEarly * 60 * 60))) && EnableWrapUpAndGoToSleep && DelayedTimeDeActivation)
               {
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

       #ifndef _EA_11_
                  if( GlobalValSet(_GV_GOTO_SLEEP_NOW_11, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_11 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_GOTO_SLEEP_NOW_12, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_12 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_GOTO_SLEEP_NOW_21, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_21 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_GOTO_SLEEP_NOW_22, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_GOTO_SLEEP_NOW_22 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      
                  return;
               }      
               
               
               if(EnableCrossSynch)
                  {                  
                   // 07222025 Print("<<< REINIT SELL_STOP >>>");
//#include <TransCompleteSET.mqh> 
         #ifndef _EA_11_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_11, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_11 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_12, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_12 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_21, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_21 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_22, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_22 + " CAN'T be SET TO: 1"); 
                  }
      #endif

                        Sleep(SecPauseBeforeReRun * 1000);
                        _OnDeinit(0);   
                        //Sleep(1000);       // If you want to have a blank screen for 1 sec.
                        ReInitializeAllStartupVariables();                 
                        _OnInit();
                  }
                  else
                  {
//                     if(ReRunFromStartOnActivation)
//                    {
//#ifdef   _ADJUST_SETUP_VALS_                    
//                    AdjustSetupVals();
//                    ReInitMainLoop();
//#endif
//
//#ifdef   _REINIT_ALL_STARTUP_VARS_
//                     _OnDeinit(0);   
//                     ReInitializeAllStartupVariables();                 
//                     _OnInit();   
//#endif  
//                    
//                    // 07222025 Print("Expert Adviser BUY_STOP has Successfully REINITIATED...");                             
//
//
//#ifdef   _COMPENSATION_ENGINE_  
//                 
//      #ifndef _EA_11_
//                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_11, EA_INDEX_NUMBER) )
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_11 + " SET Successfully TO: 1");
//                  }
//                  else
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_11 + " CAN'T be SET TO: 1"); 
//                  }
//      #endif
//      #ifndef _EA_12_
//                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_12, EA_INDEX_NUMBER) )
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_12 + " SET Successfully TO: 1");
//                  }
//                  else
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_12 + " CAN'T be SET TO: 1"); 
//                  }
//      #endif
//      #ifndef _EA_21_
//                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_21, EA_INDEX_NUMBER) )
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_21 + " SET Successfully TO: 1");
//                  }
//                  else
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_21 + " CAN'T be SET TO: 1"); 
//                  }
//      #endif
//      #ifndef _EA_22_
//                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_22, EA_INDEX_NUMBER) )
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_22 + " SET Successfully TO: 1");
//                  }
//                  else
//                  {
//                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_22 + " CAN'T be SET TO: 1"); 
//                  }
//      #endif
//#endif                   
//                    
//                    //ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//                    ObjectSetString(ChartID(),"ProtectionAttemptsValue",OBJPROP_TEXT,StringFormat("%02d",NumOfStops2)+ "/" +StringFormat("%02d",NumOfStops)+ " of "+StringFormat("%02d",NumTimesToProtect));
//                    //ChangeColorForItem("ProtectionAttemptsValue");
//                    
////#include <OnHoldCheck.mqh> 
//                  
//                  OnHold = true;
//                  
//                  if(OnHold)
//                  {
//                  CurrentPosition=PositionOnHolt;
//                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//                  }
//                  else
//                  {
//                  CurrentPosition=PositionPending;
//                  ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT,GetPriceDirString(PriceDir)+CurrentPosition);
//                  }
//                  
//                  InitToggleOnHold();
//                  }
//                  else
//                  {
                  // 07222025 Print(">>> Sending ReInit Message to Master Bot...");
#ifdef   _COMPENSATION_ENGINE_  
                 
      #ifndef _EA_11_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_11, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_11 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_12, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_12 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_21, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_21 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_REINIT_MAIN_LOOP_22, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_REINIT_MAIN_LOOP_22 + " CAN'T be SET TO: 1"); 
                  }
      #endif
#endif                   
                     //  Remove Bot
                     // 07222025 Print("<<< GAME OVER - BUY LIMIT>>>");
                     Sleep(SecPauseBeforeReRun * 1000);
                     //if(RemoveExpertAtEnd)
                        ExpertRemove();
//                  }
                  }
               
               return;       
                                   
               }
               else
               {
                  // ==================================================================================
                  // Terminate...
                  

                  TransactionComplete = !TransactionComplete;

                  //// 07222025 Print("Expert Adviser has Successfully Completed this Session...");           
                  
//#include <TransCompleteSET.mqh> 
#ifdef   _COMPENSATION_ENGINE_  
      #ifndef _EA_11_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_11, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_11 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_11 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_12, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_12 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_12 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_21, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_21 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_21 + " CAN'T be SET TO: 1"); 
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_TRANSACTION_COMPLETE_22, EA_INDEX_NUMBER) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_22 + " SET Successfully TO: 1");
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_TRANSACTION_COMPLETE_22 + " CAN'T be SET TO: 1"); 
                  }
      #endif               
#endif

               // 07222025 Print("<<< GAME OVER - SELL STOP>>>");
               Sleep(SecPauseBeforeReRun * 1000);
               //// 07222025 Print("RemoveExpertAtEnd: " + (string)RemoveExpertAtEnd);
               if(RemoveExpertAtEnd)
                  ExpertRemove();
               
               return;
               }
                      
#endif
              }
           }
           
#ifdef   _TrailingStop_    
         if(DrawTTriggerLevel)        
           if(OrderOpened 
               && !TTriggerActivated
           )
           {
            //  Handle TRAILING TRIGGER
            RefreshRates();
            if(Ask >= TrailingTriggerLevel) //  So that you can TRAIL from this level onwards
              {
               //  Bid:140.020(fixed) | Bid:140.210(dynamic) | TO TAKE-PROFIT: 20.3 pips
               if(!TTriggerLineSELECTED)
               {
                  ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(TrailingTriggerLevel,Digits)+Separator+
                                                                                DoubleToStr(Ask,Digits)+Separator+
                                                                                ToTTarget+DoubleToStr((Ask-TrailingTriggerLevel)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                                DoubleToStr((PriceTargetLevel - TrailingTriggerLevel-ActualSlippage)/Point/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                                //"<"+CalcPercentComplete(Ask,TrailingTriggerLevel,PriceTargetLevel)+">"+Separator+
                                                                                RiskRewardRatio+DoubleToStr(dRiskRewardTTRatio,2));                                                                                       
                               
                  //ChangeColorForItem("TakeProfitValue");
               }
               
               WindowRedraw();
              
              }
            else   //  TRAILING TRIGGER HIT BUY_LIMIT
              {
              
                   //  =============================
                   //  TTriger
                   //  First TIME Move SL to this Level!!!
                   //  START UPDATING TRAILING STOP IN STOP LOSS HEADER - the actual stop will be hit in the STOP LOSS HANDLER - > You have to check if TICKET CLOSED AT LOSS or PROFIT -> If closed at Loss proceed as normal, if CLOSED at PROFIT than act as if PROFIT HIT
                   //  =============================
                  
                  
                  if(TTriggerLineActive)
                  {
                     
                     TTriggerActivated = true;        //  Flag will be checked inside STOP LOSS HEADER -> To be RESET to FALSE in ReInitialize
                     
                     StopLossLevel = TrailingTailLevel;
                     TrailingStopPips = MathAbs(TrailingTriggerLevel - TrailingTailLevel) / Point;
                     
                     ObjectSetString(ChartID(),"TrailingTriggerValue",OBJPROP_TEXT, BIDPrefix+DoubleToStr(TrailingTriggerLevel,Digits)+Separator+"ACTIVATED"); 
                     ObjectSetString(ChartID(), "TrailingTailValue", OBJPROP_TEXT,  BIDPrefix+DoubleToStr(TrailingTailLevel,Digits) + Separator + 
                                                                                    DoubleToStr(MathAbs(TrailingTailLevel - PriceTargetLevel)/Point/_TicksPerPIP,1) + MeasurePips + Separator +
                                                                                    DoubleToStr(TrailingStopPips/_TicksPerPIP,1)+MeasurePips+Separator+
                                                                                    "ACTIVATED");                                                                                 

                     //  Remove Trailing Levels as they are no longer needed
//                     if(!(ObjectFind(objTTriggerArrow)<0))
//                        ObjectDelete(objTTriggerArrow);
//                        
//                     if(!(ObjectFind(objTTailArrow)<0))
//                        ObjectDelete(objTTailArrow);
//
//                     if(!(ObjectFind(objTrailingTriggerLevelLineName)<0))
//                        ObjectDelete(objTrailingTriggerLevelLineName);
//                  
//                     if(!(ObjectFind(objTrailingTailLevelLineName)<0))
//                        ObjectDelete(objTrailingTailLevelLineName);
                     
                     MoveHLine(objStopLossLevelLineName,StopLossLevel);
                     DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                     ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                                   DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                                                                                   DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+" PROT: " +
                                                                                   DoubleToStr(((StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                     
                     WindowRedraw();   
                     //  Move SL to this Level   
//                     ModifyMarketOrder(CurOpenTicket,
//                                       StopLossLevel);
//                                       
                     //  From now on Trailing Tail is DETERMINED by DIFF between CURR_PRICE Bid/Ask & SL...  On SL Move UP & DOWN
                                       
                  }
                     
              }
              
              }
#endif

#ifdef _PARTIAL_CLOSE_

      if(ShowPartialCloseLine && !PartialCloseHit)       
           if(OrderOpened)
           {
            //  Handle PARTIAL CLOSE
            RefreshRates();
            if(Ask >= PartialCloseLevel) //  So that you can PARTIAL CLOSE at this level 
              {
               //  PARTIAL CLOSE NOT HIT BUY_LIMIT
               //  ===============================
               //  PARTIAL CLOSE NOT HIT BUY_LIMIT
               //  ===============================
               
               //  Time Counter
               //  If it comes here after 30 mins it means Trade is stagnating to go further in the direction of the trade
               //  TERMINATE if IN THE MONEY!!!
#ifdef _SELF_DESTRUCT_ORDER_ 
               if(EnableGoodUntilCancel)
               { 
               if(Ask <= PriceTargetLevel) //  && TimeTicks > BeginingTicks)
               {
                  // If 30mins since first pass...
                  // CLOSE position no mater how much in profit!

                     
                     if(!FirstTimeGoodUntilCancel)
                     {
                        FirstTimeGoodUntilCancel = true;
                        InitialGoodUntilCancelTick = GetTickCount();
                        // 07222025 Print(">" + TimeToString(TimeCurrent(), TIME_MINUTES | TIME_SECONDS)); 
                     }
                     
                     uint uRet = GetTickCount();
                     if(uRet - InitialGoodUntilCancelTick >= GoodUntilCancelTimePeriodInMinutes * 1000 * 60)
                     {
                        
                        // 07222025 Print(">>" + TimeToString(TimeCurrent(), TIME_MINUTES | TIME_SECONDS)); 
                        //  CLOSE ALL....
                        //  =================================================
                          
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
                           // 07222025 Print("Ticket #" + IntegerToString(CurOpenTicket) + " -> " + StringFormat("%02d. Closed at a PROFIT!!!",(NumOfTrys)) + EnumToString(ExecCommand) + " -> " + EA_NAME_IDENTIFIER);
                        }
                        
                        AcumulatedFloatingLoss = 0;
                     if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                     { 
                        if(AcumulatedFloatingLoss < 0)
                        {
                           // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                           TransactionComplete = true;
                           
                           return;
                        }
      
                           // 07222025 Print("There is NO residual loss from a prior RUN...");
                     }
                     else
                     {
                        // 07222025 Print("There is residual loss from a prior RUN...");
                     }
                     
                     // 07222025 Print("Before PARTIAL CLOSE -> AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
                     
                     // 07222025 Print("PostCurrentLossToGlobalVAR!!!");
                     if(!PostCurrentLossToGlobalVAR(CurOpenTicket))
                     {
                        // 07222025 Print("Critical: Can't PostCurrentLossToGlobalVAR...");
                        // 07222025 Print("Emergency EXIT!!!");
                        TransactionComplete = true;
                     }
                     

                     //  Add the profit from the Partial Close to the AcumulatedFloatingLoss with a Positive Sign in order to offset the new reduced lot size PL properly!!!
                     //  Get the Profit from the Partial Close...
                     AcumulatedFloatingLoss = 0;
                     if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                     { 
                        if(AcumulatedFloatingLoss < 0)
                        {
                           // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                           TransactionComplete = true;
                           
                           return;
                        }
      
                           // 07222025 Print("There is NO residual loss from a prior RUN...");
                     }
                     else
                     {
                        // 07222025 Print("There is residual loss from a prior RUN...");
                     }
                     
                     // 07222025 Print("After PARTIAL CLOSE -> AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
                        
#ifdef _SEND_EMAIL_

               if(SendEmailUpdates)
               {
                  double ActualProfit; 
                  double ActualClosePrice;
                  datetime ActualCloseTime;
                  double ActualOpenPrice;
                  double ActualDeltaPips;
                  double ActualCommission;
                                  
                  GetTicketProfit(CurOpenTicket, ActualProfit);
                  GetTicketClosePrice(CurOpenTicket, ActualClosePrice);
                  GetTicketCloseDateTime(CurOpenTicket, ActualCloseTime);
                  GetTicketOpenPrice(CurOpenTicket, ActualOpenPrice);
                  GetTicketCommission(CurOpenTicket, ActualCommission);
                  
                  ActualDeltaPips = MathAbs(ActualClosePrice-ActualOpenPrice);
                  
                  SendMail(EA_NAME_IDENTIFIER + " - " + StagnantClose,
                           ProfitHeader+"\n"+
                           Symbol()+","+IntegerToString(Period())+"\n"+
                           StringFormat("%02d. ",NumOfTrys)+
                           " Ticket# "+IntegerToString(CurOpenTicket)+
                           " SHORT: "+DoubleToStr(Lots,2)+" Lots "+ATLevel+ DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+"\n"+
                           ASKPrefix+DoubleToStr(PartialCloseLevel,Digits)+
                           Separator+ATLevel+DoubleToStr(ActualClosePrice,Digits)+
                           Separator+DoubleToStr((ActualClosePrice-PartialCloseLevel)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+
                           Separator+TimeToStr(ActualCloseTime,TargetTimeFormat)+"\n"+
                           "Commission: "+DoubleToString(ActualCommission,2)+"\n"+
                           "Delta Pips: "+DoubleToStr(ActualDeltaPips/Point/_TicksPerPIP,1)+MeasurePips+"\n"+ 
                           "Total Profit: " + DoubleToStr(ActualProfit,2));
               }
#endif                         
                        
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
                           
               //  25.01.2025                      
               if(!(ObjectFind(objPartialCloseLevelLineName)<0))
                  while (!ObjectDelete(objPartialCloseLevelLineName))
                     Sleep(100);
                  
               if(!(ObjectFind(objPartialCloseArrow)<0))
                  while (!ObjectDelete(objPartialCloseArrow))
                     Sleep(100);
                           
                         
                        // 07222025 Print("<<<Order falling behind on schedule!  Stopped out by GOOD UNTIL CANCEL...>>>");
                        EmulateTakeProfitSELL_STOP();
                              
                        return;
     
                     }
                     else
                     { 
                       //// 07222025 Print(TimeToString(TimeCurrent(), TIME_MINUTES | TIME_SECONDS)); 
                     }
                     
                  
               }
               else
                     {
                        //  Reset CountDown to self-destruct...
                        if(FirstTimeGoodUntilCancel)
                           FirstTimeGoodUntilCancel = false;
                           
                        return;
                     }
               }
#endif 
              
              }
            else   //  PARTIAL CLOSE HIT BUY_LIMIT
              {
                   //  =============================
                   //  PARTIAL CLOSE
                   //  First TIME Move SL to Entry Level + 1pip!!!
                   //  =============================
                 
                     PartialCloseHit = true;
                     
                     double PartialCloseLots = AccuChop_ToFracNum(Lots * PartialClosePercent / 100, LotsPrecision);

                     int RetTicket = FXPartialClose::Execute(CurOpenTicket, PartialCloseLots);
                     // 07222025 Print("CurOpenTicket: " + IntegerToString(CurOpenTicket));
                     
                     
                     
                      AcumulatedFloatingLoss = 0;
                     if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                     { 
                        if(AcumulatedFloatingLoss < 0)
                        {
                           // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                           TransactionComplete = true;
                           
                           return;
                        }
      
                           // 07222025 Print("There is NO residual loss from a prior RUN...");
                     }
                     else
                     {
                        // 07222025 Print("There is residual loss from a prior RUN...");
                     }
                     
                     // 07222025 Print("Before PARTIAL CLOSE -> AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
                     
                     // 07222025 Print("PostCurrentLossToGlobalVAR!!!");
                     if(!PostCurrentLossToGlobalVAR(CurOpenTicket))
                     {
                        // 07222025 Print("Critical: Can't PostCurrentLossToGlobalVAR...");
                        // 07222025 Print("Emergency EXIT!!!");
                        TransactionComplete = true;
                     }
                     

                     //  Add the profit from the Partial Close to the AcumulatedFloatingLoss with a Positive Sign in order to offset the new reduced lot size PL properly!!!
                     //  Get the Profit from the Partial Close...
                     AcumulatedFloatingLoss = 0;
                     if(!GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
                     { 
                        if(AcumulatedFloatingLoss < 0)
                        {
                           // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                           TransactionComplete = true;
                           
                           return;
                        }
      
                           // 07222025 Print("There is NO residual loss from a prior RUN...");
                     }
                     else
                     {
                        // 07222025 Print("There is residual loss from a prior RUN...");
                     }
                     
                     // 07222025 Print("After PARTIAL CLOSE -> AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));


#ifdef _SEND_EMAIL_

               if(SendEmailUpdates)
               {
                  double ActualProfit; 
                  double ActualClosePrice;
                  datetime ActualCloseTime;
                  double ActualOpenPrice;
                  double ActualDeltaPips;
                  double ActualCommission;
                                  
                  GetTicketProfit(CurOpenTicket, ActualProfit);
                  GetTicketClosePrice(CurOpenTicket, ActualClosePrice);
                  GetTicketCloseDateTime(CurOpenTicket, ActualCloseTime);
                  GetTicketOpenPrice(CurOpenTicket, ActualOpenPrice);
                  GetTicketCommission(CurOpenTicket, ActualCommission);
                  
                  ActualDeltaPips = MathAbs(ActualClosePrice-ActualOpenPrice);
                  
                  SendMail(EA_NAME_IDENTIFIER + " - " + PartialClose,
                           ProfitHeader+"\n"+
                           Symbol()+","+IntegerToString(Period())+"\n"+
                           StringFormat("%02d. ",NumOfTrys)+
                           " Ticket# "+IntegerToString(CurOpenTicket)+
                           " SHORT: "+DoubleToStr(Lots,2)+" Lots "+ATLevel+ DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip+"\n"+
                           ASKPrefix+DoubleToStr(PartialCloseLevel,Digits)+
                           Separator+ATLevel+DoubleToStr(ActualClosePrice,Digits)+
                           Separator+DoubleToStr((ActualClosePrice-PartialCloseLevel)/Point/_TicksPerPIP,1)+MeasurePips+Slippage+
                           Separator+TimeToStr(ActualCloseTime,TargetTimeFormat)+"\n"+
                           "Commission: "+DoubleToString(ActualCommission,2)+"\n"+
                           "Delta Pips: "+DoubleToStr(ActualDeltaPips/Point/_TicksPerPIP,1)+MeasurePips+"\n"+ 
                           "Total Profit: " + DoubleToStr(ActualProfit,2));
               }
#endif
                     
                     CurOpenTicket = RetTicket;
                     // 07222025 Print("SECOND Partial CurOpenTicket: " + IntegerToString(CurOpenTicket));
                     
                     // Whats is left after the Partial Close
                     Lots = Lots - PartialCloseLots;
                     CurrProfitLossPerPip =  CurrProfitLossPerPip * PartialClosePercent / 100;
                     
                     ObjectSetString(ChartID(), "PositionLocationValue", OBJPROP_TEXT, PositionActive + GetCurrentPL());
                     
                     ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT,DoubleToStr(Lots,Lot_Precision)+" "+EnumToString(ExecCommand)+ATLevel+
                                                                                   DoubleToStr(CurrProfitLossPerPip,PL_PipPrecision)+" "+DepositCurrencyName+MeasurePerPip);
                                                                                   
                     ObjectSetString(ChartID(),"PositionOutcomeHeaderValue",OBJPROP_TEXT,PartialClose);                                                                                      
                                                                                   
                     LastExecPos=ObjectGetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT);
                     TimeOrderInitiated = TimeCurrent();
                     LastStartTickTarget = GetTickCount();
 
                     //  12.02.2025 - After hitting partial Close level REMOVE the Line & Icon  
                     if(!(ObjectFind(objPartialCloseLevelLineName)<0))
                        ObjectDelete(objPartialCloseLevelLineName);
                        
                     if(!(ObjectFind(objPartialCloseArrow)<0))
                        ObjectDelete(objPartialCloseArrow);
                        
                     ShowPartialCloseLine = false;
                                                                                     
                     if(PartialCloseAdjustSL)
                     {  		               
   		               //StopLossLevel = PriceTargetLevel - PartialCloseBuffSL * Point;   //  Add 1 pip to PriceTargetLevel for BUYs 
                        StopLossLevel = dBreakEvenLevel - PartialCloseBuffSL * Point;
                        
                        MoveHLine(objStopLossLevelLineName,StopLossLevel);
                        DrawArrow(objStopArrow,objStopArrow,StopLossLevel,StopArrow,StopArrowBackground,ANCHOR_BOTTOM,StopArrowColor,StopArrowSize,StopArrowOffsetHor,StopArrowOffsetVer);
                        ObjectSetString(ChartID(),"StopLossValue",OBJPROP_TEXT,ASKPrefix+DoubleToStr(StopLossLevel,Digits)+Separator+
                                                                                      DoubleToStr(Ask,Digits)+Separator+ToStopLoss+
                                                                                      DoubleToStr((StopLossLevel-Ask)/Point/_TicksPerPIP,1)+MeasurePips+Separator+" PROT: " +
                                                                                      DoubleToStr(((StopLossLevel - PriceTargetLevel)/Point/_TicksPerPIP),1)+MeasurePips);
                     }
                                       
              }
             
              
              }
#endif
