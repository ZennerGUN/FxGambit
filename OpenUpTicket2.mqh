//+------------------------------------------------------------------+
//|                                                 OpenUpTicket.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

//int        MAGICMA                  = 11111111; 
//bool       TradeContexSemaphor      = true;
//int        SuspendThread_TimePeriod = 150;
//bool       WidenedSpreadProtection  = true;
//int        AvarageSpread            = 55;
//bool       CheckSpreadAtStopLoss    = true;

#include <TradeContext2.mqh>
#include <stderror.mqh>
#include <stdlib.mqh>
// =======================================================================================================================


bool OpenUpMarketOrder(OrderTypes ExecuteOrder,           
                       double lots, 
                       string OrdComment,            
                       int &TicketNum)

{
   int resOrderSend = 0;
   const int cntMaxTrials = 15;
   int cnt = 0;
   int err = 0;
   bool bRes = false;
   
//   double currLots = 0;
   
   
//   if(!ActiveMarketRoundUp)        
//         {
//            currLots = NormalizeDouble(lots, NormDoublePrecission);         
//         }
//         else
//         {
//            currLots = RoundUp(lots, ActiveMarketPrecission);
//         }
//         
   
   if(!WaitForTradingGreenLight())
   {
      // 07222025 Print("Critical WaitForTradingGreenLight Error in OpenUpMarketOrder...");
      return(false);
   }
   
   
   if ((ExecuteOrder == BUY_STOP) || (ExecuteOrder == BUY_LIMIT) || (ExecuteOrder == BUY_MARKET))
   {
      while(resOrderSend <= 0  && cnt < cntMaxTrials)
      {
        
        //  Moved to BUY_LIMIT/SELL_LIMIT highlevel OpenOrder
        //if(WidenedSpreadProtection)
        //    CheckSpreadSize(); 
          
        if(IsStopped())
        {
         //Alert("OpenUpMarketOrder - IsStopped: " + (IsStopped() == 0 ? "FALSE" : "TRUE"));
         // 07222025 Print("Critical IsStopped() Error in OpenUpMarketOrder...");
         return(false);
        }
               
        ResetLastError();
        RefreshRates();
        
        resOrderSend = OrderSend(Symbol(),                     // Symbol
                                 OP_BUY,                       // Order Type
                                 lots,                         // Lots
                                 NormalizeDouble(Ask,Digits),  // Price
                                 MaxSlippageAllowed,           // Slippage
                                 0,                            // StopLoss
                                 0,                            // TakeProfit
                                 OrdComment,                   // Comment
                                 MAGICMA,                      // MAGIC Filter Number
                                 0,                            // Pending Expiration time
                                 clrGreen);                    // Entry Arrow color
                                
         err = GetLastError();
         if (err != ERR_NO_ERROR) 
            ResetLastError();
                                   
         if (resOrderSend < 0)
         {
            
            // 07222025 Print("1. OpenUpMarketOrder Error: " + IntegerToString(err) + " - " + IntegerToString(cnt + 1) + ". Can\'t OrderSend: " + IntegerToString(resOrderSend) + " Lots: " + DoubleToString(lots) + " Ask: " + DoubleToString(Ask,Digits));

            cnt++;
            Sleep(SuspendThread_TimePeriod);
         }
      }  // End of While Loop
      
      if  (resOrderSend < 0 && cnt == cntMaxTrials)
      {
        
         // 07222025 Print("1. OpenUpMarketOrder - Can\'t OrderSend for cntMaxTrials times in a row - Ticket: " + IntegerToString(resOrderSend));
                     
         return(false);
      }
      else
      {
         TicketNum = resOrderSend;
         
#ifdef _CROSS_TICKET_TRANSFER_      
         if(!TicketUpdate) 
            TicketUpdate = true;

         objTicketNumSync.SetCurCrossTicketNumber(TicketNum);
         //  ===========================================================
         //  SendTicketNum data here to reciprocal side...   07/14/2025
         //  ===========================================================
         bool res = objTicketNumSync.SendCurCrossTicketNumber();
         // 07222025 Print(">>>>>>>>>>>SendCurCrossTicketNumber: " + res);
#endif

         if(GlobalValSet(_GV_CURRENT_TICKET_NUM, TicketNum) )
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_TICKET_NUM + " SET Successfully TO: " + DoubleToString(TicketNum));
            }
          else
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_TICKET_NUM + " CAN'T be SET TO: " + DoubleToString(TicketNum));
            }
            
         // 07222025 Print("OpenUpMarketOrder: Error Num: " + IntegerToString(err));
         // 07222025 Print("OpenUpMarketOrder: " + IntegerToString(TicketNum) + " SUCCESSFUL!!!");
         return(true);
      }
   }
   else if((ExecuteOrder == SELL_STOP) || (ExecuteOrder == SELL_LIMIT) || (ExecuteOrder == SELL_MARKET))
   {
      while(resOrderSend <= 0  && cnt < cntMaxTrials)
      {
        
        //if(WidenedSpreadProtection)
        //    CheckSpreadSize();
        
        if(IsStopped())
        {
         // 07222025 Print("Critical IsStopped() Error in OpenUpMarketOrder...");
         return(false);
        }
        
        ResetLastError();
        RefreshRates();
        
        resOrderSend = OrderSend(Symbol(),
                                 OP_SELL,
                                 lots,
                                 NormalizeDouble(Bid, Digits),
                                 MaxSlippageAllowed,
                                 0,                     // StopLoss
                                 0,                     // TakeProfit
                                 OrdComment,
                                 MAGICMA,
                                 0,
                                 clrRed);
        
        err = GetLastError();
         if (err != ERR_NO_ERROR) 
            ResetLastError();
                                  
        if (resOrderSend < 0)
        {
            
            // 07222025 Print("2. OpenUpMarketOrder Error: " + IntegerToString(err) + " - " + IntegerToString(cnt + 1) + ". Can\'t OrderSend: " + IntegerToString(resOrderSend) + " Lots: " + DoubleToString(lots) + " Bid: " + DoubleToString(Bid, Digits));                                                                                          
            cnt++;
            
            Sleep(SuspendThread_TimePeriod);
        }
        
      }  // End of While Loop
      
      
      if  (resOrderSend < 0 && cnt == cntMaxTrials)
      {
         
         // 07222025 Print("2. OpenUpMarketOrder - Can\'t OrderSend for cntMaxTrials times in a row - Ticket: " + IntegerToString(resOrderSend));
         return(false);
      }
      else
      {
         TicketNum = resOrderSend; 
         
#ifdef _CROSS_TICKET_TRANSFER_               
         if(!TicketUpdate) 
            TicketUpdate = true;
            
         objTicketNumSync.SetCurCrossTicketNumber(TicketNum);
         //  ===========================================================
         //  SendTicketNum data here to reciprocal side...   07/14/2025
         //  ===========================================================
         bool res = objTicketNumSync.SendCurCrossTicketNumber();
         // 07222025 Print(">>>>>>>>>>>SendCurCrossTicketNumber: " + res);
#endif

         if(GlobalValSet(_GV_CURRENT_TICKET_NUM, TicketNum) )
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_TICKET_NUM + " SET Successfully TO: " + DoubleToString(TicketNum));
            }
          else
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_TICKET_NUM + " CAN'T be SET TO: " + DoubleToString(TicketNum));
            }
            
         // 07222025 Print("OpenUpMarketOrder: Error Num: " + IntegerToString(err) );
         // 07222025 Print("OpenUpMarketOrder: " + IntegerToString(TicketNum) + " SUCCESSFUL!!!");    
                 
         return(true);
      }
   }  

   return(false);
         
}


// =======================================================================================================================


bool ModifyMarketOrder(int TicketNum,
                       double SLLevel = 0,
                       double TPLevel = 0)
{
   bool resOrderModify = false;
   bool resSelect = false;
   const int cntMaxTrials = 15;
   int cnt = 0;
   int cnt1 = 0;
   int err = 0;
   bool bRes = false;
   
   
   if(!WaitForTradingGreenLight())
   {
      // 07222025 Print("Critical WaitForTradingGreenLight Error in ModifyMarketOrder...");
      return(false);
   }
      
      while(!resSelect  && cnt1 < cntMaxTrials)
      {
         resSelect = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
         
         if (resSelect)
         {
         
            while(!resOrderModify  && cnt < cntMaxTrials)
            {
               //if(WidenedSpreadProtection)
               //   CheckSpreadSize(); 
                                       
               if(IsStopped())
               {
                  // 07222025 Print("Critical IsStopped() Error in ModifyMarketOrder...");
                  return(false);
               }     
                resOrderModify = OrderModify(TicketNum, 
                                             OrderOpenPrice(),
                                             NormalizeDouble(SLLevel, Digits),
                                             NormalizeDouble(TPLevel, Digits),
                                             0,
                                             Yellow);
        
               err = GetLastError();                       
               if (!resOrderModify && (err != 1))     //  Error = 1 -> If unchanged values are passed as the function parameters, the error 1 (ERR_NO_RESULT) will be generated. 
               {
                  err = GetLastError();
                  // 07222025 Print("1. ModifyMarketOrder Error: " + IntegerToString(err) + " - " + IntegerToString((cnt + 1)) );
      
                  cnt++;
                  Sleep(SuspendThread_TimePeriod);
                  continue;
               }
               else
                  break;
            }  // End of While Loop
            
            if  (!resOrderModify && cnt == cntMaxTrials)
            {
               
               // 07222025 Print("1. ModifyMarketOrder - Can\'t ModifyMarketOrder for cntMaxTrials times in a row - Ticket: " + IntegerToString(TicketNum));
               return(false);
            }
            else
            {
                                
               // 07222025 Print("ModifyMarketOrder: " + IntegerToString(TicketNum) + " SUCCESSFUL!!!");
               return(true);
            }
         }
         else
         {
               err = GetLastError();
               // 07222025 Print("2. ModifyMarketOrder - OrderSelect Error: " + IntegerToString(err) + " - " + IntegerToString((cnt1 + 1) ));
   
               cnt1++;
               Sleep(SuspendThread_TimePeriod);
               continue;
         }
      }  
      
      if(!resSelect && cnt1 == cntMaxTrials)
            {
               
               // 07222025 Print("2. ModifyMarketOrder - OrderSelect - Can\'t OrderSelect for cntMaxTrials times in a row - Ticket: " + IntegerToString(TicketNum));
            }
            
      return(false);
}


// =======================================================================================================================


//void CheckSpreadSize()
//{
//   //if (WidenedSpreadProtection)
//   //{  
//         while(IsSpreadWidened(AvarageSpread) && !IsStopped())         //  DistanceBetweenPositions or IP_AvarageSpread
//         {
//            Sleep(SuspendThread_TimePeriod);             //  Wait until spread normalizes
//         }
//   
//   //}
//   
//         //return(false);
//}
//

// ======================================================================================


bool IsSpreadWidened(double SpreadSize)
{
   //string thisCurrTime = "";
   //double CurrSpread = 0;
   
   //  FINAL RELEASE TO BE REMOVED TO SPEED UP EXECUTION!!!
   //string thisCurrTime = TimeToStr((datetime)MarketInfo(Symbol(), MODE_TIME), TIME_DATE|TIME_SECONDS);
   string thisCurrTime = TimeToStr((datetime)MarketInfo(Symbol(), MODE_TIME), TIME_SECONDS);
   
   //CurrSpread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point;
         
   //if (CurrSpread > SpreadSize)        //  >= Includes value
   if (NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point > SpreadSize)        //  >= Includes value
   {
      ////// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel + " SPREAD WIDENED!!! CurrSpread: " + CurrSpread  + " - AvarageSpread: " + SpreadSize + " - CurrTime: " + thisCurrTime); 
      // 07222025 Print("PriceTargetLevel: " + DoubleToString(PriceTargetLevel) + " SPREAD WIDENED!!! CurrSpread: " + DoubleToString(NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point, Digits)  + " - AvarageSpread: " + DoubleToString(SpreadSize, Digits) + " - CurrTime: " + thisCurrTime); 
      
      //ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT, "SPREAD WIDENED: " + DoubleToString((NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point), Digits) + " > " + DoubleToString(SpreadSize, Digits) + " - " + thisCurrTime);
      //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, "SPREAD WIDENED: " + DoubleToString((NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point), Digits) + " > " + DoubleToString(SpreadSize, Digits) + " | " + thisCurrTime);
      
      return(true);
   }
   else
   {
      ////// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel + " SPREAD NORMAL!!! CurrSpread: " + CurrSpread  + " - AvarageSpread: " + SpreadSize + " - CurrTime: " + thisCurrTime); 
      //// 07222025 Print("PriceTargetLevel: " + PriceTargetLevel + " SPREAD NORMAL!!! CurrSpread: " + NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point  + " - AvarageSpread: " + SpreadSize + " - CurrTime: " + thisCurrTime); 
      
      //ObjectSetString(ChartID(),"ExecutePositionValue",OBJPROP_TEXT, "SPREAD NORMAL: " + DoubleToString((NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point), Digits) + " > " + DoubleToString(SpreadSize, Digits) + " - " + thisCurrTime);
      //ObjectSetString(ChartID(),"PositionLocationValue",OBJPROP_TEXT, "SPREAD NORMAL: " + DoubleToString((NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits) * Point), Digits) + " > " + DoubleToString(SpreadSize, Digits) + " | " + thisCurrTime);
      
      return(false);
   }
   
}