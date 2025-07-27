//+------------------------------------------------------------------+
//|                                                 GlobalVarOps.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#import "kernel32.dll"
   bool CopyFileW(string lpExistingFileName, string lpNewFileName, bool failIfExists); 
#import


bool SendCrossEqualizeMessage(double PriceLevelTP)
{
   int LastErr         =  -1;
   string mainLocalPath = "";
   string mainDestPath =  "";
   string InternalPath =  "\\MQL4\\Files\\";   // Internal Path
   string TPStr        =  "TakeProfitLvl";
   
#ifndef _NO_PRINTOUT_    
   // 07222025 Print("<<< Inside - SendCrossEqualizeMessage >>>");
#endif   
   // ===============================================
   // Create the Synch File...
   // ===============================================   

   
   
#ifndef _NO_PRINTOUT_
   // 07222025 Print("Created: " + CrossEqualizeTPFileName)   ;
#endif 
   
   ResetLastError();
   
   int file_handle = FileOpen(CrossEqualizeTPFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, '=');  
   if(file_handle != INVALID_HANDLE) 
     {          
      FileWrite(file_handle, TPStr, AccuChop_ToFracNum(PriceLevelTP));
      FileClose(file_handle); 
     } 
   else 
   {
      // 07222025 Print("SendCrossEqualizeMessage: Operation FileOpen for WRITE failed, error ", GetLastError()); 
      return false;
   }
   
   // Copy Synch File to Destination dir...
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SendCrossEqualizeMessage: Copy Synch file to Destination Dir...");
#endif
   mainLocalPath = TerminalInfoString(TERMINAL_DATA_PATH);
#ifndef _NO_PRINTOUT_    
   // 07222025 Print("SendCrossEqualizeMessage - mainLocalPath: " + mainLocalPath);
#endif   
   int sLen = StringLen(mainLocalPath);
   
   while(sLen >=0 && mainLocalPath[sLen] != '\\')
      sLen--;
      
   if(sLen < 0)
      return false;
      
   mainDestPath = StringSubstr(mainLocalPath,0, sLen);
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SendCrossEqualizeMessage - mainDestPath: " + mainDestPath);
#endif   
   mainDestPath = mainDestPath + DestinationInstance + InternalPath + CrossEqualizeTPFileName;
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SendCrossEqualizeMessage - mainDestPath: " + mainDestPath);
   
   // 07222025 Print("UserName: " + UserName);
#endif   
   if(!(UserName == ""))
   {
      string currUserName = "";
      string targetString = "Users";
      
      int i = StringFind(mainDestPath, targetString);
      i = i + StringLen(targetString) + 1;
      int j = i;
      
      while(mainDestPath[i] != '\\')
         i++;
      
      currUserName = StringSubstr(mainDestPath, j,  (i - j));   
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SendCrossEqualizeMessage: currUserName: " + currUserName);
#endif      
      int Res = StringReplace(mainDestPath, currUserName, UserName);
      
      
      if(Res == -1)
      {
         // 07222025 Print("SendCrossEqualizeMessage: Result from REPLACE: " + IntegerToString(Res));
         return false;
      }
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SendCrossEqualizeMessage - mainDestPath: " + mainDestPath);
#endif      
   }
   
   mainLocalPath = mainLocalPath + InternalPath + CrossEqualizeTPFileName;
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SendCrossEqualizeMessage - mainLocalPath: " + mainLocalPath);
#endif   
   
   
ResetLastError();
int SuspendCounter = 0;
int bResCopyFile = 0;

while (True)   
{
    bResCopyFile = CopyFileW(mainLocalPath,      //  Existing File
                                mainDestPath, //  New File destination
                                false  );     //  TRUE - Do NOT overwrite new file
                                              //  FALSE - Overwrite new file
    if(bResCopyFile != 0)
      break;
    
    Sleep(SuspendThread2_TimePeriod);
    if(SuspendCounter++ > 35) break;
   
}


#ifndef _NO_PRINTOUT_   
      // 07222025 Print("SendCrossEqualizeMessage LAST - bResCopyFile: " + IntegerToString(bResCopyFile));
      // 07222025 Print("SendCrossEqualizeMessage LAST - CopyFileW Error: " + IntegerToString(GetLastError()));
#endif   
   
   if(LastErr == 0 && SuspendCounter <= 35)
   {
#ifndef _NO_PRINTOUT   
      // 07222025 Print("SendCrossEqualizeMessage " + CrossEqualizeTPFileName + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );
#endif 
   }
   else
   {
#ifndef _NO_PRINTOUT   
      // 07222025 Print("SendCrossEqualizeMessage - Can''t Delete File: " + CrossEqualizeTPFileName + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
#endif       
      return (false); 
   }
           


   // ===============================================
   // NOW Delete the Signal file after signal has been Sent 
   // ===============================================       
   SuspendCounter = 0;
   
   ResetLastError();
   
   while((FileIsExist(CrossEqualizeTPFileName, FILE_READ)))
   {
      LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SendCrossEqualizeMessage - " + CrossEqualizeTPFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif      
      FileDelete(CrossEqualizeTPFileName);
      LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SendCrossEqualizeMessage - " + CrossEqualizeTPFileName + " >>> FileDelete Error: " + IntegerToString(LastErr));
#endif
      if(LastErr == 0) break;
      Sleep(SuspendThread2_TimePeriod);
      if(SuspendCounter++ > 35) break;
      
   }
   if(LastErr == 0 && SuspendCounter <= 35)
   {
#ifndef _NO_PRINTOUT   
      // 07222025 Print("SendCrossEqualizeMessage " + CrossEqualizeTPFileName + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );
#endif 
   }
   else
   {
#ifndef _NO_PRINTOUT   
      // 07222025 Print("SendCrossEqualizeMessage - Can''t Delete File: " + CrossEqualizeTPFileName + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
#endif       
      return (false); 
   }
    
    
   return (true);            
}



// =========================================================================================================


void NotifySlaveToAdjustSL(double extStopLossLv)
{

   if(extStopLossLevel > 0)
   {
      #ifndef _EA_11_
                  if( GlobalValSet(_GV_RUNAWAY_TARGET_11 , extStopLossLv) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_11 + " SET Successfully TO: " + DoubleToString(extStopLossLv));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_11 + " CAN'T be SET TO: " + DoubleToString(extStopLossLv));  
                  }
      #endif
      #ifndef _EA_12_
                  if( GlobalValSet(_GV_RUNAWAY_TARGET_12 , extStopLossLv) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_12 + " SET Successfully TO: " + DoubleToString(extStopLossLv));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_12 + " CAN'T be SET TO: " + DoubleToString(extStopLossLv));  
                  }
      #endif
      #ifndef _EA_21_
                  if( GlobalValSet(_GV_RUNAWAY_TARGET_21 , extStopLossLv) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_21 + " SET Successfully TO: " + DoubleToString(extStopLossLv));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_21 + " CAN'T be SET TO: " + DoubleToString(extStopLossLv));  
                  }
      #endif
      #ifndef _EA_22_
                  if( GlobalValSet(_GV_RUNAWAY_TARGET_22 , extStopLossLv) )
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_22 + " SET Successfully TO: " + DoubleToString(extStopLossLv));
                  }
                  else
                  {
                     // 07222025 Print("GlobalVAL " + _GV_RUNAWAY_TARGET_22 + " CAN'T be SET TO: " + DoubleToString(extStopLossLv));  
                  }
      #endif      
   }
         
}



bool SeekSynchSignal(int    _MarketOrderType,
                     string _DestinationInstance)
{

   int LastErr         =  -1;
   string mainLocalPath = "";
   string mainDestPath =  "";
   string InternalPath =  "\\MQL4\\Files\\";   // Internal Path
   string FileName     =  "Synch.Signal";
   
#ifndef _NO_PRINTOUT_    
   // 07222025 Print("<<< Inside - SeekSynchSignal >>>");
#endif   
   // ===============================================
   // Create the Synch File...
   // ===============================================   
   if(_MarketOrderType == 1)   
   {
      // LONG
      FileName = "LONG" + FileName;
   }
   else
   {
      // SHORT
      FileName = "SHORT" + FileName;
   }
#ifndef _NO_PRINTOUT_
   // 07222025 Print("Created: " + FileName)   ;
#endif 
   
   ResetLastError();
   
   int file_handle = FileOpen(FileName, FILE_WRITE|FILE_CSV|FILE_ANSI, '=');  
   if(file_handle != INVALID_HANDLE) 
     {          
      FileClose(file_handle); 
     } 
   else 
   {
      // 07222025 Print("Operation FileOpen for WRITE failed, error ", GetLastError()); 
      return false;
   }
   
   // Copy Synch File to Destination dir...
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("Copy Synch file to Destination Dir...");
#endif
   mainLocalPath = TerminalInfoString(TERMINAL_DATA_PATH);
#ifndef _NO_PRINTOUT_    
   // 07222025 Print("SeekSynchSignal - mainLocalPath: " + mainLocalPath);
#endif   
   int sLen = StringLen(mainLocalPath);
   
   while(sLen >=0 && mainLocalPath[sLen] != '\\')
      sLen--;
      
   if(sLen < 0)
      return false;
      
   mainDestPath = StringSubstr(mainLocalPath,0, sLen);
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SeekSynchSignal - mainDestPath: " + mainDestPath);
#endif   
   mainDestPath = mainDestPath + _DestinationInstance + InternalPath + FileName;
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SeekSynchSignal - mainDestPath: " + mainDestPath);
   
   // 07222025 Print("UserName: " + UserName);
#endif   
   if(!(UserName == ""))
   {
      string currUserName = "";
      string targetString = "Users";
      
      int i = StringFind(mainDestPath, targetString);
      i = i + StringLen(targetString) + 1;
      int j = i;
      
      while(mainDestPath[i] != '\\')
         i++;
      
      currUserName = StringSubstr(mainDestPath, j,  (i - j));   
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("currUserName: " + currUserName);
#endif      
      int Res = StringReplace(mainDestPath, currUserName, UserName);
      
      
      if(Res == -1)
      {
         // 07222025 Print("Result from REPLACE: " + IntegerToString(Res));
         return false;
      }
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SeekSynchSignal - mainDestPath: " + mainDestPath);
#endif      
   }
   
   mainLocalPath = mainLocalPath + InternalPath + FileName;
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("SeekSynchSignal - mainLocalPath: " + mainLocalPath);
#endif   
   
//   ResetLastError();
//   
//   // ===============================================
//   // Copy the Synch File...
//   // ===============================================      
//   int bResCopyFile = CopyFileW(mainLocalPath,      //  Existing File
//                                mainDestPath, //  New File destination
//                                false  );     //  TRUE - Do NOT overwrite new file
//                                              //  FALSE - Overwrite new file
//                                                
//
//#ifndef _NO_PRINTOUT_   
//   // 07222025 Print("SeekSynchSignal - bResCopyFile: " + IntegerToString(bResCopyFile));
//   // 07222025 Print("SeekSynchSignal - CopyFileW Error: " + IntegerToString(GetLastError()));
//#endif   
   
   // ===============================================
   // NOW Delete the Signal file after signal has been Sent...
   // ===============================================       
//   uint SuspendCounter = 0;
//   //uint _SuspendThread_TimePeriod = 150;
//   uint MiliTimeDelayBeforeCancel = 0;          //10 * 1000;
//   uint thisTickValue = GetTickCount();
//   
//   ResetLastError();
//   
//   while((FileIsExist(FileName, FILE_READ)) 
//        // && 
//        //(GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel)
//        )
//   {
//      LastErr = GetLastError();
//#ifndef _NO_PRINTOUT_      
//      // 07222025 Print("SeekSynchSignal - " + FileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
//#endif      
//      FileDelete(FileName);
//      LastErr = GetLastError();
//#ifndef _NO_PRINTOUT_      
//      // 07222025 Print("SeekSynchSignal - " + FileName + " >>> FileDelete Error: " + IntegerToString(LastErr));
//#endif
//      if(LastErr == 0) break;
//      Sleep(SuspendThread2_TimePeriod);
//      SuspendCounter++;
//   }
//#ifndef _NO_PRINTOUT_   
//   if(LastErr == 0)
//   {
//      // 07222025 Print("SeekSynchSignal " + FileName + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );
//
//   }
//   else
//   {
//      // 07222025 Print("SeekSynchSignal - Can''t Delete File: " + FileName + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
//      return (false); 
//   }
//#endif     
 
   
   // ===============================================
   // Wait for reciprocal side to Send Synch Signal...
   // ===============================================     
   string FileName2     =  "Synch.Signal";
   
   if(_MarketOrderType == 2)   
   {
      // LONG
      FileName2 = "LONG" + FileName2;
   }
   else
   {
      // SHORT
      FileName2 = "SHORT" + FileName2;
   }

#ifndef _NO_PRINTOUT_
   // 07222025 Print("SEEKING: " + FileName2)   ;
#endif

   uint SuspendCounter = 0;
   uint MiliTimeDelayBeforeCancel = 0;
   //uint thisTickValue = GetTickCount();
   
   if(MiliTimeDelayBeforeCancel > 0)
   {
//      ResetLastError();
//      
//      while(((!FileIsExist(FileName2, FILE_READ)) && (!IsStopped())) && 
//            (GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel))
//      {
//#ifndef _NO_PRINTOUT_       
//         LastErr = GetLastError();
//         // 07222025 Print("SeekSynchSignal - " + FileName2 + " >>> WAITING FileIsExist Error: " + IntegerToString(LastErr));
//#endif          
//         Sleep(SuspendThread2_TimePeriod);
//         SuspendCounter++;
//
//#ifndef _NO_PRINTOUT_          
//         if(MathMod(SuspendCounter, 35) == 0)   // 5 sec
//            // 07222025 Print("SeekSynchSignal: " + FileName2 + " >>> While WAITING 5sec..." + IntegerToString(LastErr));
//#endif             
//
//      }
   }
   else
   {
   
#define _ONE_LINE_NOTIFICATION2_
#ifdef   _ONE_LINE_NOTIFICATION2_
         bool OneLine_FirstTime2 = true;
#endif
   
      ResetLastError();     
      while((!FileIsExist(FileName2, FILE_READ)) && (!IsStopped()))
      {
#ifndef  _ONE_LINE_NOTIFICATION2_     
#ifndef _NO_PRINTOUT_       
         LastErr = GetLastError();
         // 07222025 Print("SeekSynchSignal - " + FileName2 + " >>> WAITING FileIsExist Error: " + IntegerToString(LastErr));
#endif  
             
         Sleep(SuspendThread2_TimePeriod);
         
      int bResCopyFile = CopyFileW(mainLocalPath,      //  Existing File
                                mainDestPath, //  New File destination
                                false  );     //  TRUE - Do NOT overwrite new file
                                              //  FALSE - Overwrite new file

#ifndef _NO_PRINTOUT_   
      // 07222025 Print("SeekSynchSignal - bResCopyFile: " + IntegerToString(bResCopyFile));
      // 07222025 Print("SeekSynchSignal - CopyFileW Error: " + IntegerToString(GetLastError()));
#endif   
         
         Sleep(SuspendThread2_TimePeriod);
         SuspendCounter++;
         
#ifndef _NO_PRINTOUT_          
         if(MathMod(SuspendCounter, 35) == 0)   // 5 sec
            // 07222025 Print("SeekSynchSignal: " + FileName2 + " >>> While WAITING 5sec..." + IntegerToString(LastErr));
#endif 
#endif


#ifdef   _ONE_LINE_NOTIFICATION2_

         LastErr = GetLastError();
         
         if(OneLine_FirstTime2)
         { 
            // 07222025 Print("SeekSynchSignal - " + FileName2 + " >>> WAITING FileIsExist - Error: " + IntegerToString(LastErr));
            //OneLine_FirstTime2 = false
         }
         
         Sleep(SuspendThread2_TimePeriod);
         
         int bResCopyFile = CopyFileW(mainLocalPath,      //  Existing File
                                      mainDestPath, //  New File destination
                                      false  );     //  TRUE - Do NOT overwrite new file
                                                   //  FALSE - Overwrite new file
                                                   
         if(OneLine_FirstTime2)
         {
            // 07222025 Print("SeekSynchSignal - bResCopyFile: " + IntegerToString(bResCopyFile));
            // 07222025 Print("SeekSynchSignal - CopyFileW Error: " + IntegerToString(GetLastError()));
            OneLine_FirstTime2 = false;
         }
         
         Sleep(SuspendThread2_TimePeriod);
         SuspendCounter++;
          
         if(MathMod(SuspendCounter, 35*12) == 0)   // 5 sec
         {
            // 07222025 Print("SeekSynchSignal: " + FileName2 + " >>> WAITING 1min..." + IntegerToString(LastErr));                                    
         }
#endif
            
      }
   }   
   
   // 07222025 Print("<<< RECEIVED!!! >>> " + FileName);
   
   int bResCopyFile = CopyFileW(mainLocalPath,      //  Existing File
                                mainDestPath, //  New File destination
                                false  );     //  TRUE - Do NOT overwrite new file
                                              //  FALSE - Overwrite new file

#ifndef _NO_PRINTOUT_   
      // 07222025 Print("SeekSynchSignal LAST - bResCopyFile: " + IntegerToString(bResCopyFile));
      // 07222025 Print("SeekSynchSignal LAST - CopyFileW Error: " + IntegerToString(GetLastError()));
#endif   
   
   // ===============================================
   // Delete the Signal file after RECEIVING it from Reciprocal side...
   ResetLastError();
   
   SuspendCounter = 0;
   //thisTickValue = GetTickCount();
   
   while((FileIsExist(FileName2, FILE_READ)) 
        //  && 
        //(GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel)
        )
   {
      LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SeekSynchSignal - " + FileName2 + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif      
      FileDelete(FileName2);
      LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SeekSynchSignal - " + FileName2 + " >>> FileDelete Error: " + IntegerToString(LastErr));
#endif
      if(LastErr == 0) break;
      Sleep(SuspendThread2_TimePeriod);
      SuspendCounter++;
      
   }
#ifndef _NO_PRINTOUT_    
   if(LastErr == 0)
   {
      // 07222025 Print("SeekSynchSignal " + FileName2 + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );

   }
   else
   {
      // 07222025 Print("SeekSynchSignal - Can''t Delete File: " + FileName2 + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
      return (false); 
   }
#endif     
    


   // ===============================================
   // NOW Delete the Signal file after signal has been Sent and reciprocal Signal file has been received...
   // ===============================================       
   SuspendCounter = 0;
   //uint _SuspendThread_TimePeriod = 150;
   //MiliTimeDelayBeforeCancel = 0;          //10 * 1000;
   //thisTickValue = GetTickCount();
   
   ResetLastError();
   
   while((FileIsExist(FileName, FILE_READ)) 
        // && 
        //(GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel)
        )
   {
      LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SeekSynchSignal - " + FileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif      
      FileDelete(FileName);
      LastErr = GetLastError();
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("SeekSynchSignal - " + FileName + " >>> FileDelete Error: " + IntegerToString(LastErr));
#endif
      if(LastErr == 0) break;
      Sleep(SuspendThread2_TimePeriod);
      SuspendCounter++;
   }
#ifndef _NO_PRINTOUT_   
   if(LastErr == 0)
   {
      // 07222025 Print("SeekSynchSignal " + FileName + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );

   }
   else
   {
      // 07222025 Print("SeekSynchSignal - Can''t Delete File: " + FileName + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
      return (false); 
   }
#endif         
    
    
   return (true);              
}


// ==========================================================================================================


bool SeekLaunchSignal()
{
      if(GlobalValEXIST(_GV_LAUNCH_SIGNAL))
         {
            //// 07222025 Print( "GlobalValEXIST( " + _GV_LAUNCH_SIGNAL + " ) - LAUNCH SIGNAL RECEIVED!!!" );
            if(!GlobalValDel(_GV_LAUNCH_SIGNAL))
               // 07222025 Print("Can't DELETE Global Variable _GV_LAUNCH_SIGNAL...");
            
            return (true);
         }
      else
         {
            //// 07222025 Print( "GlobalValEXIST( " + _GV_LAUNCH_SIGNAL + " ) - No LAUNCH SIGNAL yet..." );
            return (false);
         }
         
   return (false);              
}


// ==========================================================================================================


bool GetCurrentLossFromGlobalVAR(double &AcumuFloatingLoss)
{
      if(GlobalValEXIST(_GV_CURRENT_LOSS))
      {
         if( GlobalValGet(_GV_CURRENT_LOSS, AcumuFloatingLoss) )
         {
            // 07222025 Print("GetCurrentLossFromGlobalVAR - GlobalVAL " + _GV_CURRENT_LOSS + " GOT Successfully Value: " + DoubleToString(AcumuFloatingLoss));
            return (true);
         }
         else
         {
            AcumuFloatingLoss = -1;
            // 07222025 Print("GetCurrentLossFromGlobalVAR - GlobalVAL " + _GV_CURRENT_LOSS + " CAN'T GET Value");
            //  Raise CRITICAL ERROR set TransactionCOMPLETE to TRUE
            return (false);
         }
      }
      else
         {
            //if(AcumuFloatingLoss > 0)
            //{
            //   // 07222025 Print("GetCurrentLossFromGlobalVAR - AcumuFloatingLoss = " + DoubleToString(AcumuFloatingLoss) + " was RESET successfully...");
            //   AcumuFloatingLoss = 0;
            //}
            
            // 07222025 Print( "GetCurrentLossFromGlobalVAR - GlobalValEXIST( " + _GV_CURRENT_LOSS + " ) - GlobalVAL DOESN'T Exist..." );
            return (false);
         }
         
   return (false);              
}


// ==========================================================================================================


bool GetCurrentOpenPosGlobalVAR(double &EAwithOpenPos)
{
      if(GlobalValEXIST(_GV_OPEN_POSITION_EXISTS))
         if( GlobalValGet(_GV_OPEN_POSITION_EXISTS, EAwithOpenPos) )
         {
            // 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " GOT Successfully Value: " + DoubleToString(EAwithOpenPos));
            return (true);
         }
         else
         {
            // 07222025 Print("GlobalVAL " + _GV_OPEN_POSITION_EXISTS + " CAN'T GET Value");
            return (false);
         }
      else
         {
            // 07222025 Print( "GlobalValEXIST( " + _GV_OPEN_POSITION_EXISTS + " ) - GlobalVAL DOESN'T Exist..." );
            return (false);
         }
         
   return (false);              
}


// ==========================================================================================================


string GetTotalCloseLoss(int TicketNum)
{
   double CurrentLoss = 0;
   double CurrentComm = 0;
   double CurrentSwap = 0;
      
//   if(GetTicketInfo(TicketNum, "PR", CurrentLoss))
//      {
//         CurrentLoss = CurrentLoss;
//         //// 07222025 Print("CurrentLoss EXTRACTED successfully -> " + CurrentLoss);
//      }  
//      else
//      {
//         //// 07222025 Print("Can't EXTRACT CurrentLoss...");
//         return("-0.00");
//      } 
//         
//      
//      if(GetTicketInfo(TicketNum, "CO", CurrentComm))
//      {
//         CurrentComm = CurrentComm;
//         //// 07222025 Print("CurrentComm EXTRACTED successfully -> " + CurrentComm);
//      }  
//      else
//      {
//         //// 07222025 Print("Can't EXTRACT CurrentComm...");
//         return("-0.00");
//      }   
//      
//      
//      if(GetTicketInfo(TicketNum, "SW", CurrentSwap))
//      {
//         CurrentSwap = CurrentSwap;
//         //// 07222025 Print("CurrentSwap EXTRACTED successfully -> " + CurrentSwap);
//      }  
//      else
//      {
//         //// 07222025 Print("Can't EXTRACT CurrentComm...");
//         return("-0.00");
//      }   

      if(!WaitForTradingGreenLight())
       {
          // 07222025 Print("Critical WaitForTradingGreenLight Error in ModifyMarketOrder...");
          return("Critical Error!!!");
       }
       
      uint SuspendCounter = 0;    
      uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
      bool isOrderSelected = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
      uint thisTickValue = GetTickCount();
      
      while(!isOrderSelected &&
            ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel))
      {
          Sleep(SuspendThread_TimePeriod);
          SuspendCounter++;
         
          isOrderSelected = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
      }      
                                    
     
      if(isOrderSelected)                      
      {   
         CurrentLoss = OrderProfit();
         CurrentComm = OrderCommission();           
         CurrentSwap = OrderSwap();
      
      
         return(DoubleToString((CurrentLoss) + (CurrentComm) + (CurrentSwap), 2));
      }
      else
      {
         int Err = GetLastError();
         // 07222025 Print("GetTotalCloseLoss: GetTicketInfo() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
         
         return("Critical Error!!!");
      }
      
   return("Critical Error!!!");      
}


// ==========================================================================================================


bool PostCurrentLossToGlobalVAR(int TicketNum)
{
      double CurrentOrderProfit = 0;
      double CurrentLoss = 0;
      double CurrentComm = 0;
      double CurrentSwap = 0;
      
      // 07222025 Print("<<< Inside PostCurrentLossToGlobalVAR >>>");
//      if(GetTicketInfo(TicketNum, "PR", CurrentLoss))
//      {
//         CurrentLoss = MathAbs(CurrentLoss);
//         //// 07222025 Print("CurrentLoss EXTRACTED successfully -> " + CurrentLoss);
//      }  
//      else
//      {
//         //// 07222025 Print("Can't EXTRACT CurrentLoss...");
//         return(false);
//      } 
//         
//      
//      if(GetTicketInfo(TicketNum, "CO", CurrentComm))
//      {
//         CurrentComm = MathAbs(CurrentComm);
//         //// 07222025 Print("CurrentComm EXTRACTED successfully -> " + CurrentComm);
//      }  
//      else
//      {
//         //// 07222025 Print("Can't EXTRACT CurrentComm...");
//         return(false);
//      }   
//      
//      
//      if(GetTicketInfo(TicketNum, "SW", CurrentSwap))
//      {
//         CurrentSwap = MathAbs(CurrentSwap);
//         //// 07222025 Print("CurrentSwap EXTRACTED successfully -> " + CurrentSwap);
//      }  
//      else
//      {
//         //// 07222025 Print("Can't EXTRACT CurrentComm...");
//         return(false);
//      }    

       if(!WaitForTradingGreenLight())
       {
          // 07222025 Print("Critical WaitForTradingGreenLight Error in ModifyMarketOrder...");
          return(false);
       }

      
      uint SuspendCounter = 0;    
      uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
      bool isOrderSelected = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
      uint thisTickValue = GetTickCount();
      
      while(!isOrderSelected &&
            ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel))
      {
         Sleep(SuspendThread_TimePeriod);
         SuspendCounter++;
         
         isOrderSelected = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
      }      
                                               
      bool NegativeOutcome;
      
      if(isOrderSelected)                      
      {   
         CurrentOrderProfit = OrderProfit();
         // 07222025 Print("CurrentOrderProfit: " + DoubleToString(CurrentOrderProfit));
         
         //CurrentLoss = (CurrOrderProfit < 0 ? CurrOrderProfit : 0);
         CurrentComm = OrderCommission();   
         // 07222025 Print("CurrentComm: " + DoubleToString(CurrentComm));
                 
         CurrentSwap = OrderSwap();
         // 07222025 Print("CurrentSwap: " + DoubleToString(CurrentSwap));
      
         // Calculate the Current Floating Loss including Commisions & Swap
         if(CurrentOrderProfit < 0)
         {
            CurFloatingLoss = MathAbs(CurrentOrderProfit + 
                                      CurrentComm + 
                                      CurrentSwap);
                                      
            NegativeOutcome = true;                                      
         }
         else
         {
            CurFloatingLoss = CurrentOrderProfit + 
                              CurrentComm + 
                              CurrentSwap;
                              
            if(CurFloatingLoss < 0)
            {
               CurFloatingLoss = MathAbs(CurFloatingLoss);
               NegativeOutcome = true;
            }
            else
               {
                  //CurFloatingLoss = MathAbs(CurFloatingLoss);
                  NegativeOutcome = false; 
                  // CurFloatingLoss = 0;           // 07/05/2025
               }
         }
         
         // 07222025 Print("CurFloatingLoss: " + DoubleToString(CurFloatingLoss));
                       
      
         if(NumOfStops > 0)
         {
            AcumulatedFloatingLoss = 0;
            if(GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
            {
               // 07222025 Print("AcumulatedFloatingLoss EXTRACTED successfully -> " + DoubleToString(AcumulatedFloatingLoss));
            }
            else
            {
               if(AcumulatedFloatingLoss < 0)
               {
                  // 07222025 Print("CRITICAL: Can't GET Floating LOSS!!!");
                  TransactionComplete = true;
                  
                  return(false);
               }
               
               // 07222025 Print("Cant't GET AcumulatedFloatingLoss..." + DoubleToString(AcumulatedFloatingLoss));
               //return(false);
               
            }
         }
         else
            // 07222025 Print("FIRST Time AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss));
         
         
         if(NegativeOutcome)
            // ADD the Current LOSS to the ACCUMULATED one in the GlobalVAR...
            _GV_CURRENT_LOSS_VAL = AcumulatedFloatingLoss + CurFloatingLoss;
          else
            _GV_CURRENT_LOSS_VAL = (AcumulatedFloatingLoss - CurFloatingLoss < 0 ? 0 :  AcumulatedFloatingLoss - CurFloatingLoss);
         
         // 07222025 Print("_GV_CURRENT_LOSS_VAL: " + DoubleToString(_GV_CURRENT_LOSS_VAL));
         // 07222025 Print("<<< END PostCurrentLossToGlobalVAR >>>");
         
         //  This can go to ReInitialize MAYBE???  Keep here for now!!!
         AcumulatedFloatingLoss = 0;
         CurFloatingLoss = 0;
         
         if(_GV_CURRENT_LOSS_VAL > 0)
         {
            if( GlobalValSet(_GV_CURRENT_LOSS, _GV_CURRENT_LOSS_VAL) )
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_LOSS + " SET Successfully TO: " + DoubleToString(_GV_CURRENT_LOSS_VAL));
            }
            else
            {
               // 07222025 Print("GlobalVAL " + _GV_CURRENT_LOSS + " CAN'T be SET TO: " + DoubleToString(_GV_CURRENT_LOSS_VAL));
               return(false);
            }
         }
         else
         {
            // Remove CurrentLoss GlobalVAR   
            if( GlobalValDel( _GV_CURRENT_LOSS ) )
            {
               // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " DELETED successfully...");
            }
            else
            {
               // 07222025 Print("GlobalVAL: " + _GV_CURRENT_LOSS + " CAN'T be DELETED...");
            }
         }
         
         return(true);
      }
      else
      {
         int Err = GetLastError();
         // 07222025 Print("GetTicketInfo() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
         
         return(false);
      }

   return(false);
   
}


// ==========================================================================================================

         
bool GlobalValEXIST(string GVName)
{         
   ResetLastError();
   if ( GlobalVariableCheck( GVName ) ) 
   		   return(true);
   		else
   		{
   			_GetLastError = GetLastError();
   			if ( _GetLastError != 0 )
   			{
   				// 07222025 Print( "DoesGlobalValEXIST() - ( " + GVName + " ) - Error #" + IntegerToString(_GetLastError ));
   			}
   		}       
   		
   return(false);

}		            


// ==========================================================================================================


bool GlobalValSet(string GVName, double GVValue)
{
   ResetLastError();
   if ( GlobalVariableSet( GVName, GVValue ) > 0 ) 
		   return(true);
		else
		{
			_GetLastError = GetLastError();
			if ( _GetLastError != 0 )
			{
				// 07222025 Print( "GlobalValSet( " + GVName + ", " + DoubleToString(GVValue) + " ) - Error #" + IntegerToString(_GetLastError ));
			}
		}
		
   return(false);

}      


// ==========================================================================================================


bool GlobalValGet(string GVName, double &GVValue)
{
   ResetLastError();
   if ( GlobalVariableGet( GVName, GVValue ) ) 
		   return(true);
		else
		{
			_GetLastError = GetLastError();
			if ( _GetLastError != 0 )
			{
				// 07222025 Print( "GlobalValGet( " + GVName + ", " + DoubleToString(GVValue) + " ) - Error #" + IntegerToString(_GetLastError ));
			}
		}
		
   return(false);

}      


// ==========================================================================================================


bool GlobalValDel(string GVName)
{
   ResetLastError();
   if(GlobalValEXIST( GVName))
   {
      if ( GlobalVariableDel( GVName))
      {
   		   return(true);
      }
		else
		{
			_GetLastError = GetLastError();
			if ( _GetLastError != 0 )
			{
				// 07222025 Print( "GlobalValDel( " + GVName + " ) - Error #" + IntegerToString(_GetLastError ));
				return(false);
			}
		}
   }
   else
   {
      // 07222025 Print( "GlobalValDel( " + GVName + " ) - No GlobalVAL to DELETE..." );
      return(true);
   }  
   
   return(true);
}      


// ==========================================================================================================

//
//bool GetTicketInfo(int TicketNum, string subOption, double &resultVal)
//{
//   // EN - Entry
//   // SL - StopLoss
//   // TP - TakeProfit
//   // LT - Lots
//   // PR - Profit
//   
//   uint SuspendCounter = 0;    
//   uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
//   bool isOrderSelected = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
//   uint thisTickValue = GetTickCount();
//   
//   while(!isOrderSelected &&
//         ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel))
//   {
//      Sleep(SuspendThread_TimePeriod);
//      SuspendCounter++;
//      
//      isOrderSelected = OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES);
//   }      
//                                               
//
//   if(isOrderSelected)                      
//   {   
//      if (subOption == "EN")           
//         resultVal = OrderOpenPrice();     
//      else 
//      if (subOption == "SL")      
//         resultVal = OrderStopLoss();      
//      else 
//      if (subOption == "TP")      
//         resultVal = OrderTakeProfit();
//      else 
//      if (subOption == "LT")       
//         resultVal = OrderLots();
//      else 
//      if (subOption == "PR")      
//         resultVal = OrderProfit();
//      else 
//      if (subOption == "CO")         
//         resultVal = OrderCommission();
//      if (subOption == "SW")         
//         resultVal = OrderSwap();
//         
//      return(true);
//   }
//   else
//   {
//      int Err = GetLastError();
//      // 07222025 Print("GetTicketInfo() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
//   }
//   
//   return(false);
//   
//}


// ==========================================================================================================


bool GetTicketOrderType(int TicketNum, int &resultVal)
{
        
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderType();
            return(true);
   }
   else
   {
      // 07222025 Print("GetTicketOrderType() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketOpenDateTime(int TicketNum, datetime &resultVal)
{
         
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderOpenTime();
            return(true);
   }
   else
   {
      // 07222025 Print("GetTicketOpenDateTime() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketCloseDateTime(int TicketNum, datetime &resultVal)
{
         
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderCloseTime();
            return(true);
   }
   else
   {
      // 07222025 Print("GetTicketCloseDateTime() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketOpenPrice(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderOpenPrice();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderOpenPrice() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketClosePrice(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderClosePrice();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderClosePrice() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketStopLoss(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderStopLoss();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderStopLoss() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketTakeProfit(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderTakeProfit();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderTakeProfit() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketLots(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderLots();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderLots() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketProfit(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderProfit();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderProfit() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketCommission(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderCommission();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderCommission() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================


bool GetTicketSwap(int TicketNum, double &resultVal)
{
       
   if (OrderSelect(TicketNum, SELECT_BY_TICKET ,MODE_TRADES))
   {        
            resultVal = OrderSwap();
            return(true);
   }
   else
   {
      // 07222025 Print("OrderSwap() - Can\'t OrderSelect: " + IntegerToString(TicketNum));
   }
   
   return(false);
   
}


// ==========================================================================================================

void DetermineCommissionMode(string curPair)
{

   AvarageSpread = AvarageSpreadPoints * Point;

//   // Check for GOLD first
//   int iRes0 = StringFind(curPair, SymbolForGOLD);
//   if(iRes0 == 0)
//   {
//      //// 07222025 Print(SymbolForGOLD);
//      CommissionMode = 4;
//      _TicksPerPIP = GoldTicksPerPIP;
//      CurrOrderSize = GoldOrderSize;   // 100
//      return;
//   }
//   
//   // Check for Silver 
//   iRes0 = StringFind(curPair, SymbolForSILVER);
//   if(iRes0 == 0)
//   {
//      //// 07222025 Print(SymbolForSILVER);
//      CommissionMode = 4;
//      _TicksPerPIP = SilverTicksPerPIP;
//      CurrOrderSize = SilverOrderSize;   // 100
//      return;
//   }
//   
//   // Check for BITCOIN 
//   int iRes1 = StringFind(curPair, SymbolForBTC);
//   if(iRes1 == 0)
//   {
//      //// 07222025 Print(SymbolForBTC);
//      CommissionMode = 4;
//      _TicksPerPIP = BTCTicksPerPIP;
//      CurrOrderSize = BTCOrderSize;   // 1
//      return;
//   }
//   
//   // Check for BRENT first
//   int iRes2 = StringFind(curPair, SymbolForBRENT);
//   if(iRes2 == 0)
//   {
//      //// 07222025 Print(SymbolForBRENT);
//      CommissionMode = 4;
//      _TicksPerPIP = BrentTicksPerPIP;
//      CurrOrderSize = BrentOrderSize;
//      return;
//   }
//   
//   // Check for WTI first
//   int iRes3 = StringFind(curPair, SymbolForWTI);
//   if(iRes3 == 0)
//   {
//      //// 07222025 Print(SymbolForWTI);
//      CommissionMode = 4;
//      _TicksPerPIP = WTITicksPerPIP;
//      CurrOrderSize = WTIOrderSize;
//      return;
//   }
//   
//   // Check for SP500 first
//   int iRes4 = StringFind(curPair, SymbolForSP500);
//   if(iRes4 == 0)
//   {
//      //// 07222025 Print(SymbolForSP500);
//      CommissionMode = 4;
//      _TicksPerPIP = SP500TicksPerPIP;
//      CurrOrderSize = SP500OrderSize;
//      return;
//   }
//   
//   // Check for DAX30 first
//   int iRes5 = StringFind(curPair, SymbolForDAX30);
//   if(iRes5 == 0)
//   {
//      //// 07222025 Print(SymbolForDAX30);
//      CommissionMode = 4;
//      _TicksPerPIP = DAX30TicksPerPIP;
//      CurrOrderSize = DAX30OrderSize;
//      return;
//   }
//   
//   
//   // =================================================================
//   
//   
//   _TicksPerPIP = TicksPerPIP;
   //CurrOrderSize = 1;         // 100000
   //CurrOrderSize = 100000;
   
//   int iRes = StringFind(curPair, "USD");
//   
//   if(iRes == 0)
//   {
//      // 07222025 Print("USD/XXX"); // USD/CHF | USD/CAD | USD/JPY | = 3
//      CommissionMode = 1;
//   }
//   else if(iRes > 0) 
//   {
//      // 07222025 Print("XXX/USD"); // EUR/USD | GBP/USD | AUD/USD | NZD/USD | = 4
//      CommissionMode = 2;
//   }
//   // EUR/GBP -> EUR/USD | EUR/AUD -> EUR/USD | EUR/CHF -> EUR/USD | EUR/JPY -> EUR/USD | EUR/NZD -> EUR/USD | EUR/CAD -> EUR/USD | = 6 pairs
//   // GBP/AUD -> GBP/USD | GBP/CHF -> GBP/USD | GBP/JPY -> GBP/USD | GBP/NZD -> GBP/USD | GBP/CAD -> GBP/USD | = 5 pairs
//   // AUD/CHF -> AUD/USD | AUD/JPY -> AUD/USD | AUD/NZD -> AUD/USD | AUD/CAD -> AUD/USD | = 4 pairs
//   // NZD/CHF -> NZD/USD | NZD/JPY -> NZD/USD | NZD/CAD -> NZD/USD | = 3 pairs
//   // TO BE DETERMINED (TBD)
//   // CAD/CHF -> CAD/USD -> 1 / USD/CAD | CAD/JPY -> CAD/USD -> 1 / USD/CAD | = 2 pairs
//   // CHF/JPY -> CHF/USD -> 1 / USD/CHF | = 1 pair   
//   else if(iRes == -1) 
//   {
//      // 07222025 Print("XXX/YYY");
//      CommissionMode = 3;
//      CommissionBasePair = StringSubstr(Symbol(),0,3) + "USD" + CurrencyPairNameExt;   
//      // 07222025 Print("CommissionBasePair: ", CommissionBasePair );
//   }  
//  

     
   return;
   
}                                                                          


// ==========================================================================================================
// Required Values:
// 1. Ticks Per Pip
// 2. Current Pip Value in the deposit currency
// 3. TakeProfitPips or TrailingTriggerPips or (TrailingTriggerPips - TrailingTailPips)
// 4. CurrOrderSize
// 5. CurrProfitLossPerPip
// 6. 

//double CalcNewLotSize(double _AcumulatedFloatingLoss)
//{
//#ifndef _NO_PRINTOUT_ 
//         // 07222025 Print("Inside CalcNewLotSize");
//         // 07222025 Print("1. Lots = " + DoubleToString(Lots));
//         // 07222025 Print("2. TicksPerPIP = " + DoubleToString(_TicksPerPIP));
//         //// 07222025 Print("3. PipValue = " + DoubleToString(PipValue));
//         // 07222025 Print("4. StopLossPips = " + DoubleToString(StopLossPips));
//         // 07222025 Print("5. TakeProfitPips = " + DoubleToString(TakeProfitPips));
//         // 07222025 Print("6. TrailingTriggerPips = " + DoubleToString(TrailingTriggerPips));
//         // 07222025 Print("7. TrailingTailPips = " + DoubleToString(TrailingTailPips));
//         
//#endif          
//         //// 07222025 Print("");
//         //// 07222025 Print("");
//         //// 07222025 Print("");
//         
//         
//         double CurrPrice = 0;
////#ifndef _NO_PRINTOUT_          
////         // 07222025 Print("CommissionMode: ", CommissionMode);
////#endif          
////         
////         //  Commission in USD by DEFAULT - USD is Base Currency
////         if(CommissionMode == 1)                                 //  USD/CHF | USD/CAD | USD/JPY - Uses strait commission rate for commission calculation
////         {
////            // 07222025 Print("1 - CommissionMode..."); 
////            //CurrPrice = 1;
////            if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                  CurrPrice = MarketInfo(Symbol(), MODE_ASK);
////               else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                   CurrPrice = MarketInfo(Symbol(), MODE_BID);
////         }
////         // Commission in EUR, GBP, AUD, and NZD - Since pairs end in USD and are in USD as quote currency, multiplying by the value of the current pair, converts Base Currency into Quote Currency...  Or converts in USDm
////         else if(CommissionMode == 2) 
////            {    
////            //if (CommissionNotional)     
////            //   {   
////#ifndef _NO_PRINTOUT_ 
////               // 07222025 Print("2 - CommissionMode..."); 
////#endif         //  EUR/USD | GBP/USD | AUD/USD | NZD/USD - Uses same price quote for commission calculation
////               if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                  CurrPrice = MarketInfo(Symbol(), MODE_ASK);
////               else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                   CurrPrice = MarketInfo(Symbol(), MODE_BID);
//////               }
//////            else
//////               {
//////#ifndef _NO_PRINTOUT_                
//////                  // 07222025 Print("2 - Commission NOT Notional..."); 
//////#endif                   
//////                  CurrPrice = 1;
//////                  
//////               }
////            }
////            // Commission of currency CROSS pair doesn't contain USD nither as Base or Quote currency...  Thus we seek the USD pair for the BASE currency of the CROSS pair...  We use this pair for calculating the commission in USD...  
////         else if(CommissionMode == 3)
////            {    
////            //if (CommissionNotional)     
////            //   {            
////#ifndef _NO_PRINTOUT_                
////               // 07222025 Print("3 - CommissionMode..."); 
////               // 07222025 Print("CommissionBasePair: " + CommissionBasePair);                                                   //  GBP/JPY; EUR/JPY - Uses GBP/USD and EUR/USD for commission calculation
////#endif                
////               
////               // IF NOT  CAD/CHF -> CAD/USD -> 1 / USD/CAD ||| CAD/JPY -> CAD/USD -> 1 / USD/CAD  | = 2 pairs
////               //         CHF/JPY -> CHF/USD -> 1 / USD/CHF                                        | = 1 pair
////               
////                  if((CommissionBasePair != "CADUSD" + CurrencyPairNameExt) && (CommissionBasePair != "CHFUSD" + CurrencyPairNameExt))
////                  {
////#ifndef _NO_PRINTOUT_                   
////                     // 07222025 Print("1. Inside CommissionBasePair Comparison...");
////                     // 07222025 Print("CommissionBasePair: " + CommissionBasePair);
////#endif                     
////                     if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                        CurrPrice = MarketInfo(CommissionBasePair, MODE_ASK);
////                     else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                        CurrPrice = MarketInfo(CommissionBasePair, MODE_BID);
////                   }
////                   else
////                   {
////#ifndef _NO_PRINTOUT_                     
////                    // 07222025 Print("2. Inside CommissionBasePair Comparison...");
////                    // 07222025 Print("CommissionBasePair: " + CommissionBasePair);
////#endif                     
////                     if(CommissionBasePair == "CADUSD" + CurrencyPairNameExt)
////                     {
////                        CommissionBasePair = "USDCAD" + CurrencyPairNameExt;
////#ifndef _NO_PRINTOUT_                         
////                        // 07222025 Print("Switched to CommissionBasePair: " + CommissionBasePair);
////#endif                         
////                     }
////                     else if(CommissionBasePair == "CHFUSD" + CurrencyPairNameExt)
////                     {
////                        CommissionBasePair = "USDCHF" + CurrencyPairNameExt;
////#ifndef _NO_PRINTOUT_                         
////                        // 07222025 Print("Switched to CommissionBasePair: " + CommissionBasePair);
////#endif                         
////                     }
////                     //else
////                        //// 07222025 Print("No MATCH!!!");
////                     
////                     if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     {
////                        CurrPrice = 1 / MarketInfo(CommissionBasePair, MODE_ASK);
////#ifndef _NO_PRINTOUT_                         
////                        // 07222025 Print("MODE_ASK CurrPrice = ", DoubleToString(CurrPrice)); 
////#endif                         
////                     }
////                     else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                     {
////                        CurrPrice = 1 / MarketInfo(CommissionBasePair, MODE_BID);
////#ifndef _NO_PRINTOUT_ 
////                        // 07222025 Print("MODE_BID CurrPrice = ", DoubleToString(CurrPrice)); 
////#endif                         
////                     }
////                   }
////               //}
////               //else
////               //{
//////#ifndef _NO_PRINTOUT_                      
//////                     // 07222025 Print("3 - Commission NOT Notional..."); 
//////#endif                      
//////                     CurrPrice = 1;
//////               }
////              
////            }  
////         else if(CommissionMode == 4)
////            {              
////               //if (CommissionNotional)     
////               //{   
////#ifndef _NO_PRINTOUT_                
////               // 07222025 Print("4 - CommissionMode...");   
////#endif                
////               if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                  CurrPrice = MarketInfo(Symbol(), MODE_ASK);
////               else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                  CurrPrice = MarketInfo(Symbol(), MODE_BID);
//////               }
//////               else
//////               {
//////#ifndef _NO_PRINTOUT_                
//////                  // 07222025 Print("4 - Commission NOT Notional..."); 
//////#endif                   
//////                  CurrPrice = 1;
//////                  
//////               }               
////            }      
////#ifndef _NO_PRINTOUT_         
////         // 07222025 Print(((CommissionMode == 3) ? CommissionBasePair : Symbol()) + " CurrPrice = ", DoubleToString(CurrPrice)); 
////#endif          
////         
////         if(CurrPrice <= 0)
////         {
////            TransactionComplete = true;
////            // 07222025 Print("1. CRITICAL ERROR!!!");
////            return(0);              //  EXIT if ZERO...
////         } 
////          
//         
//         double PipValue = 0;
//         
//         for(int i=0; i<15; i++)
//         {
//            PipValue = MarketInfo(Symbol(), MODE_TICKVALUE) * _TicksPerPIP;
//            if(PipValue > 0)
//               break;
//               
//            Sleep(SuspendThread_TimePeriod);
//         }
//         
//         //PipValue = UpdateTickVal(MarketInfo(Symbol(), MODE_TICKVALUE) * _TicksPerPIP);
//         
//#ifndef _NO_PRINTOUT_          
//         // 07222025 Print("PIPVal = ", DoubleToString(PipValue)); 
//#endif          
//   
//         
//         if(PipValue <= 0)
//         {
//            TransactionComplete = true;
//            // 07222025 Print("2. CRITICAL ERROR!!!");
//            return(0);              //  EXIT if ZERO...
//         }
//         
//         //  PARAM1 Calculation
//         //  ==================
//         double Param1;
//         
//         string param_1 = "";
//         string param_2 = "";
//         string param_3 = "";
//         string param_4 = "";
//         
//         string url  = "";
//         
//         
//#ifdef   _TrailingStop_
//         
//         //if(!TTriggerLineActive)
//         if(CalcRPbyTakeProfit)
//                  {
//#ifndef   _WEB_Request_                  
//                     Param1 = (TakeProfitPips / _TicksPerPIP) * PipValue;
//#ifndef _NO_PRINTOUT_          
//                     // 07222025 Print("PARAM1 - CalcRPbyTakeProfit = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TakeProfitPips: " + DoubleToString(TakeProfitPips / _TicksPerPIP,1)); 
//#endif                      
//#else
//                     param_1 = DoubleToString( TakeProfitPips);
//                     param_2 = DoubleToString( _TicksPerPIP);
//                     param_3 = DoubleToString( PipValue);
//                     
//                     //               178.32.50.14          Tenko_Savov
//                     // http://178.32.50.14/Tenko_Savov/CalcFormula01.aspx?TPP1=1500&TPP2=10&TPP3=1
//                     url = "http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula01.aspx?TPP1=" + param_1 +  
//                                                                                                     "&TPP2=" + param_2 + 
//                                                                                                     "&TPP3=" + param_3;
//                                                                                                     
//                     
//                                                                                                  
//                                                                                  
//                     Param1 = SendWEBRequest(url);
//                                                                                               
//#endif               
//                     
//                  }
//               else
//                  {
//                     // TRUE - By Trigger Level  |   FALSE - By Tail Level
//                     if(CalcRPbyTrigOrTailLevel) 
//                     {                 
//                        
//#ifndef   _WEB_Request_                  
//                     Param1 = (TrailingTriggerPips / _TicksPerPIP) * PipValue;
//#ifndef _NO_PRINTOUT_          
//                     // 07222025 Print("PARAM1 - CalcRPbyTrigOrTailLevel(1) = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips / _TicksPerPIP,1)); 
//#endif                      
//#else
//                     param_1 = DoubleToString( TrailingTriggerPips);
//                     param_2 = DoubleToString( _TicksPerPIP);
//                     param_3 = DoubleToString( PipValue);
//                     
//                     //               178.32.50.14          Tenko_Savov
//                     url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula02.aspx?TPP1=" + param_1 + 
//                                                                                                   "&TPP2=" + param_2 + 
//                                                                                                   "&TPP3=" + param_3;
//                                                                                 
//                     Param1 = SendWEBRequest(url);                                                                                       
//#endif                  
//                        
//                     }
//                     else
//                     {
//                        
//#ifndef   _WEB_Request_      
//                     Param1 = (TrailingTailPips / _TicksPerPIP) * PipValue;
//
//#ifndef _NO_PRINTOUT_
//                     // 28.04.2022  
//                     // 07222025 Print("TrailingTriggerPips" + DoubleToString(TrailingTriggerPips));        
//                     // 07222025 Print("TrailingTailPips" + DoubleToString(TrailingTailPips));  
//                     // 07222025 Print("_TicksPerPIP" + DoubleToString(_TicksPerPIP));  
//
//                     // 07222025 Print("PARAM1 - CalcRPbyTrigOrTailLevel(0) = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TrailingTailPips: " + DoubleToString(MathAbs(TrailingTriggerPips - TrailingTailPips) / _TicksPerPIP,1)); 
//#endif                      
//#else
//                     param_1 = DoubleToString( TrailingTriggerPips);
//                     param_2 = DoubleToString( TrailingTailPips);
//                     param_3 = DoubleToString( _TicksPerPIP);
//                     param_4 = DoubleToString( PipValue);
//                     
//                     //               178.32.50.14          Tenko_Savov
//                     url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula03.aspx?TPP1=" + param_1 + 
//                                                                                                   "&TPP2=" + param_2 + 
//                                                                                                   "&TPP3=" + param_3 + 
//                                                                                                   "&TPP4=" + param_4;
//                                                                                 
//                     Param1 = SendWEBRequest(url);                                                                                       
//#endif                  
//                        
//                     }
//                  }
//#else
//         Param1 = (TakeProfitPips / _TicksPerPIP) * PipValue;
//         
//#ifndef _NO_PRINTOUT_          
//         // 07222025 Print("Param1 = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TakeProfitPips: " + DoubleToString(TakeProfitPips / _TicksPerPIP,1)); 
//#endif          
//
//#endif                  
//         
//         //  PARAM2 Calculation
//         //  ==================
//         double Param2 = 0;
//         
//         if(!CommissionBakedIn)
//         {
//         if(CommissionNotional)
//            Param2 = FXOpenCommissions::CalculateCommission(Symbol(), 1);
//         else
//            Param2 = CommissionConst;
//         }
//         else
//            Param2 = 0;
//
////         double CommConst = CommissionConst;        
////         
////#ifndef _NO_PRINTOUT_             
////         // 07222025 Print("PARAM2 - CommissionNotional = ", DoubleToString(Param2));          
////         // 07222025 Print("CurrOrderSize = " + DoubleToString(CurrOrderSize) + " CurrPrice = " + DoubleToString(CurrPrice) + "CommissionConst = " + DoubleToString(CommConst));
////#endif          
////         
////         
//
////         
////         
////         if(!CommissionBakedIn)
////         {
////            if(CommissionCurrency == "USD")
////            {
////               if(DepositCurrencyName == "EUR")
////               {
////                  if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     CommConst = CommissionConst * (1 / MarketInfo("EURUSD", MODE_ASK));
////                  else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                      CommConst = CommissionConst * (1 / MarketInfo("EURUSD", MODE_BID));
////               }
////               else if(DepositCurrencyName == "GBP")
////               {
////                  if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     CommConst = CommissionConst * (1 / MarketInfo("GBPUSD", MODE_ASK));
////                  else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                      CommConst = CommissionConst * (1 / MarketInfo("GBPUSD", MODE_BID));
////               }
////               else if(DepositCurrencyName == "CHF")
////               {
////                  if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     CommConst = CommissionConst * MarketInfo("USDCHF", MODE_ASK);
////                  else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                      CommConst = CommissionConst * MarketInfo("USDCHF", MODE_BID);
////               }
////               else if(DepositCurrencyName == "USD")
////               {
////               }
////            }
////            else if(CommissionCurrency == "EUR")
////            {
////               if(DepositCurrencyName == "EUR")
////               {
////               }
////               else if(DepositCurrencyName == "GBP")
////               {
////                  if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     CommConst = CommissionConst * MarketInfo("EURGBP", MODE_ASK);
////                  else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                      CommConst = CommissionConst * MarketInfo("EURGBP", MODE_BID);
////               }
////               else if(DepositCurrencyName == "CHF")
////               {
////                  if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     CommConst = CommissionConst * MarketInfo("EURCHF", MODE_ASK);
////                  else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                      CommConst = CommissionConst * MarketInfo("EURCHF", MODE_BID);
////               }
////               else if(DepositCurrencyName == "USD")
////               {
////                  if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                     CommConst = CommissionConst * MarketInfo("EURUSD", MODE_ASK);
////                  else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                      CommConst = CommissionConst * MarketInfo("EURUSD", MODE_BID);
////               }
////            }
////            
////            //// 07222025 Print("CommConst: " + CommConst);
////            
////            
////            if(CommissionNotional)
////            {  
////               
////#ifndef   _WEB_Request_                  
////                     if(CommissionMode == 1)
////                        Param2 = CurrOrderSize * 1 * CommConst / 100;  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005
////                     else if(CommissionMode == 2 || CommissionMode == 3)
////                        Param2 = CurrOrderSize * CurrPrice * CommConst / 100;  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005
////                     else if(CommissionMode == 4)
////                        Param2 = CurrPrice * CommConst * 1000;                      
////                                                
////#ifndef _NO_PRINTOUT_             
////                     // 07222025 Print("PARAM2 - Commission Notional = ", DoubleToString(Param2));          
////                     // 07222025 Print("CurrOrderSize = " + DoubleToString(CurrOrderSize) + " CurrPrice = " + DoubleToString(CurrPrice) + "CommissionConst = " + DoubleToString(CommConst));
////#endif                      
////#else
////                     param_1 = DoubleToString( CurrOrderSize);
////                     param_2 = DoubleToString( CurrPrice);
////                     param_3 = DoubleToString( CommConst);
////                     
////                     //               178.32.50.14          Tenko_Savov
////                     url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula10.aspx?TPP1=" + param_1 + 
////                                                                                                   "&TPP2=" + param_2 + 
////                                                                                                   "&TPP3=" + param_3;
////                                                                                 
////                     Param2 = SendWEBRequest(url);                                                                                  
////#endif                
////            }
////            else
////            {
////               
////#ifndef   _WEB_Request_   
////                     if(CommissionMode == 1 || CommissionMode == 2 || CommissionMode == 3 )               
////                        Param2 = CurrOrderSize * CommConst / 100;              //  NON-NOTIONAL:
////                     else if(CommissionMode == 4)
////                        Param2 = CommConst * 1000;
////#ifndef _NO_PRINTOUT_             
////                     // 07222025 Print("PARAM2 - Commission NON Notional = ", DoubleToString(Param2));          
////                     // 07222025 Print("CurrOrderSize = " + DoubleToString(CurrOrderSize) + " CurrPrice = " + DoubleToString(CurrPrice) + "CommissionConst = " + DoubleToString(CommConst));
////#endif                     
////#else
////                     param_1 = DoubleToString( CurrOrderSize);
////                     param_2 = DoubleToString( CommConst);
////                     
////                     //               178.32.50.14          Tenko_Savov
////                     url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula11.aspx?TPP1=" + param_1 + 
////                                                                                                   "&TPP2=" + param_2;
////                                                                                 
////                     Param2 = SendWEBRequest(url);                                                                                                               
////#endif               
////            }
////         }
////         else
////         {
////            Param2 = 0;
////            
////#ifndef _NO_PRINTOUT_             
////         // 07222025 Print("PARAM2 - CommissionBakedIn = ", DoubleToString(Param2));          
////         // 07222025 Print("CurrOrderSize = " + DoubleToString(CurrOrderSize) + " CurrPrice = " + DoubleToString(CurrPrice) + "CommissionConst = " + DoubleToString(CommConst));
////#endif    
////         }
////              
//              
//         //  Check Param1 & Param2 Values              
//         if((Param1 - Param2) <= 0)
//         {
//            TransactionComplete = true;
//            // 07222025 Print("3. CRITICAL ERROR!!!  Param1 - Param2 <= 0");
//            return(0);              //  EXIT if ZERO...
//         }
//
//
//         //double RequiredProfit = DesiredNetProfit + CurFloatingLoss;  
//         double RequiredProfit = 0;
//         
//
//#ifdef   _TrailingStop_         
//         //if(!TTriggerLineActive)
//         if(CalcRPbyTakeProfit)
//                  {
//                     byTakeProfit = true;
//                     
//                     
//   #ifndef   _WEB_Request_                  
//                        RequiredProfit = (TakeProfitPips / _TicksPerPIP) * CurrProfitLossPerPip;
//                        
//   #ifndef _NO_PRINTOUT_                      
//                        // 07222025 Print("ORIGINAL RequiredProfit - CalcRPbyTakeProfit: " + DoubleToString(RequiredProfit, 2)  + " BASED ON TakeProfitPips: " + DoubleToString((TakeProfitPips / _TicksPerPIP),1) + " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
//   #endif                     
//                        
//   #else
//                        param_1 = DoubleToString( TakeProfitPips);
//                        param_2 = DoubleToString( _TicksPerPIP);
//                        param_3 = DoubleToString( CurrProfitLossPerPip);
//                        
//                        //               178.32.50.14          Tenko_Savov
//                        url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula20.aspx?TPP1=" + param_1 + 
//                                                                                                      "&TPP2=" + param_2 +
//                                                                                                      "&TPP3=" + param_3;
//                                                                                    
//                        RequiredProfit = SendWEBRequest(url);                                                                                       
//   #endif                        
//                      
//                  }
//               else
//                  {
//                     // TRUE - By Trigger Level  |   FALSE - By Tail Level
//                     if(CalcRPbyTrigOrTailLevel == true)   
//                     {               
//                        byTrailingTrigger = true;
//                        
//                        
//   #ifndef   _WEB_Request_                  
//                        RequiredProfit = (TrailingTriggerPips / _TicksPerPIP) * CurrProfitLossPerPip;
//                        
//   #ifndef _NO_PRINTOUT_                      
//                        // 07222025 Print("ORIGINAL RequiredProfit - CalcRPbyTrigOrTailLevel(1): " + DoubleToString(RequiredProfit, 2) + 
//                              " BASED ON TrailingTriggerPips: " + DoubleToString((TrailingTriggerPips / _TicksPerPIP),1)+ 
//                              " TrailingTailPips: " + DoubleToString(TrailingTailPips / _TicksPerPIP,1) + " " +
//                              " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
//   #endif                     
//   #else
//                        param_1 = DoubleToString( TrailingTriggerPips);
//                        param_2 = DoubleToString( _TicksPerPIP);
//                        param_3 = DoubleToString( CurrProfitLossPerPip);
//                        
//                        //               178.32.50.14          Tenko_Savov
//                        url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula21.aspx?TPP1=" + param_1 + 
//                                                                                                      "&TPP2=" + param_2 +
//                                                                                                      "&TPP3=" + param_3;
//                                                                                    
//                        RequiredProfit = SendWEBRequest(url);                                                                                       
//   #endif                                           
//                     }
//                     else if(CalcRPbyTrigOrTailLevel == false) 
//                     {
//                        byTrailingStop = true;
//                        
//                        
//   #ifndef   _WEB_Request_         
//                        RequiredProfit = ((TrailingTailPips / _TicksPerPIP) * CurrProfitLossPerPip);
//                        
//   #ifndef _NO_PRINTOUT_                      
//                        // 07222025 Print("ORIGINAL RequiredProfit - CalcRPbyTrigOrTailLevel(0): " + DoubleToString(RequiredProfit, 2) + 
//                              " TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips / _TicksPerPIP,1) + " " +
//                              " BASED ON TrailingTailPips: " + DoubleToString((TrailingTailPips / _TicksPerPIP),1)+ 
//                              " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
//   #endif                     
//   #else
//                        param_1 = DoubleToString( TrailingTriggerPips);
//                        param_2 = DoubleToString( TrailingTailPips);
//                        param_3 = DoubleToString( _TicksPerPIP);
//                        param_4 = DoubleToString( CurrProfitLossPerPip);
//                        
//                        //               178.32.50.14          Tenko_Savov
//                        url="http://" + ZennServerName + "/" + ZennUserName + "/" + "CalcFormula22.aspx?TPP1=" + param_1 + 
//                                                                                                      "&TPP2=" + param_2 +
//                                                                                                      "&TPP3=" + param_3 +
//                                                                                                      "&TPP4=" + param_4;
//                                                                                    
//                        RequiredProfit = SendWEBRequest(url);                                                                                       
//   #endif                              
//                                             
//                     }
//                  }
//#else
//         if(CalcRPbyTakeProfit)
//         {
//            byTakeProfit = true;
//            RequiredProfit = (TakeProfitPips / _TicksPerPIP) * CurrProfitLossPerPip;
//            
//            #ifndef _NO_PRINTOUT_                      
//            // 07222025 Print("FALLBACK RequiredProfit - CalcRPbyTakeProfit: " + DoubleToString(RequiredProfit, 2)  + " BASED ON TakeProfitPips: " + DoubleToString((TakeProfitPips / _TicksPerPIP),1) + " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
//            #endif 
//         }
//
//#endif                   
//         
//
//         //// 07222025 Print("AcumulatedFloatingLoss: " + _AcumulatedFloatingLoss);
//         
//#ifdef      _Lot_Optimization_         
//         if(EnableLotReductionAlgo)
//         {
//         // Start Optimizing LOT size in exchange for TAKING some % LOSS...
//            if(NumOfTrys <= NumTimesBeforeBreakEven)
//            {
//               //  If TRAILING Enabled
//               RequiredProfit = RequiredProfit + _AcumulatedFloatingLoss;
//#ifndef _NO_PRINTOUT_                
//               // 07222025 Print("RequiredProfit + _AcumulatedFloatingLoss: " + DoubleToString(RequiredProfit + _AcumulatedFloatingLoss,2));
//#endif 
//               
//            }
//            else if((NumOfTrys > NumTimesBeforeBreakEven) && (NumOfTrys <= NumTimesBeforeTakingLoss))
//            {
//               RequiredProfit = _AcumulatedFloatingLoss;
//#ifndef _NO_PRINTOUT_                
//               // 07222025 Print("RequiredProfit = _AcumulatedFloatingLoss: " + DoubleToString(_AcumulatedFloatingLoss,2));
//#endif                
//            }
//            else if(NumOfTrys > NumTimesBeforeTakingLoss)
//            {
//               RequiredProfit = _AcumulatedFloatingLoss - ((AcceptedPercentageLoss / 100 ) * _AcumulatedFloatingLoss);
//#ifndef _NO_PRINTOUT_                
//               // 07222025 Print("RequiredProfit = % LOSS from _AcumulatedFloatingLoss: " + DoubleToString(RequiredProfit,2));
//#endif                
//            }
//         }
//         else 
//         {  
//#endif         
//
//            // FINAL RequiredProfit... 
//            //// 07222025 Print("RequiredProfit + _AcumulatedFloatingLoss: " + DoubleToString(RequiredProfit + _AcumulatedFloatingLoss,2));   
//            
//            // OVERRIDE RequiredProfit value...
//            if((_AcumulatedFloatingLoss > 0) && 
//               EmergencyBreakEvenEXIT && 
//               NumOfStops >= EmergencyBreakEvenAtRun)    
//               {
//                     RequiredProfit = _AcumulatedFloatingLoss;
//#ifndef _NO_PRINTOUT_                      
//                     // 07222025 Print("FINAL EMERGENCY - RequiredProfit = _AcumulatedFloatingLoss: " + DoubleToString(_AcumulatedFloatingLoss,2));
//#endif                      
//               }
//               else
//               {
//                        
//#ifndef _NO_PRINTOUT_                      
//                     // 07222025 Print("CURRENT - RequiredProfit = " + DoubleToString(RequiredProfit + _AcumulatedFloatingLoss, 2) + " _AcumulatedFloatingLoss: " + DoubleToString(_AcumulatedFloatingLoss,2) + " " + "ORIGINAL RequiredProfit: " + DoubleToString(RequiredProfit, 2));
//#endif
//                     RequiredProfit = RequiredProfit + _AcumulatedFloatingLoss;                     
//               }
//                 
//#ifdef      _Lot_Optimization_
//         }
//#endif         
//
//         
//         //// 07222025 Print("INSIDE CalcNewLotSize -> RequiredProfit = ",DoubleToString(RequiredProfit,2) );
//         
//         //  No RoundUps FULL Precission NEEDED!!!
//         double RequiredLots = 0;
//         RequiredLots = RequiredProfit / (Param1 - Param2); 
//         
//         if( MarketInfo(Symbol(), MODE_MAXLOT) < RequiredLots )
//         {
//               // 07222025 Print("<<< MAX_LOT reached inside CalcNewLotSize()...");
//               // 07222025 Print("<<< ====================================== >>>");
//               MessageBox("MAX_LOT reached inside CalcNewLotSize()...\nProgram Terminated!!!", "CRITICAL WARNING!!!", MB_OK);
//               
//               ShutOffVeleveHIT = true;
//               TransactionComplete = true;
//               
//               return(RequiredLots);
//         }
//               
//#ifndef _NO_PRINTOUT_           
//         // 07222025 Print("1. RequiredLOTS = [RequiredProfit / (Param1 - Param2)]= ",DoubleToString(RequiredLots), " - " + DoubleToString(Param1), " - " + DoubleToString(Param2));
//#endif          
//
//         // Roundup and Normalize needed ONLY prior to Opening Position
//         if(!ActiveMarketRoundUp)        
//         {
//            RequiredLots = NormalizeDouble(RequiredLots, NormDoublePrecission);         
//         }
//         else
//         {
//            RequiredLots = RoundUp(RequiredLots, ActiveMarketPrecission);
//         }
//
//#ifndef _NO_PRINTOUT_           
//         // 07222025 Print("2. RoundUp RequiredLOTS = [RequiredProfit / (Param1 - Param2)]= ", DoubleToString(RequiredLots));
//#endif          
//         
//                  
////         //  Adjust Commission as fractional LOTs to Current RequiredLots
////         //  ============================================================
////         
////         double CurrCommission = 0;
////         
////         //  Only if Commission is calculated on the side as in LMAX
////         if(!CommissionBakedIn)
////         {
////            if(CommissionNotional)  
////               if(CommissionMode == 1)
////                  CurrCommission = RequiredLots * 1 * CurrOrderSize * (CommissionConst / 100);  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005
////               else
////                  CurrCommission = RequiredLots * CurrPrice * CurrOrderSize * (CommissionConst / 100);  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005                              
////            else
////               CurrCommission = RequiredLots * CurrOrderSize * (CommissionConst / 100);              //  NON-NOTIONAL:
////            
////            //  If Deposit Currency is NOT USD, we have to convert the commission into alternative Deposit Currency like EUR, GBP or CHF according to according to the corresponding AccountCurrency()!!!
////            if(DepositCurrencyName == "EUR")
////            {
////               if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                  CurrCommission = CurrCommission * 1 / MarketInfo("EURUSD", MODE_ASK);
////               else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                   CurrCommission = CurrCommission * 1 / MarketInfo("EURUSD", MODE_BID);
////            }
////            else if(DepositCurrencyName == "GBP")
////            {
////               if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                  CurrCommission = CurrCommission * 1 / MarketInfo("GBPUSD", MODE_ASK);
////               else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                   CurrCommission = CurrCommission * 1 / MarketInfo("GBPUSD", MODE_BID);
////            }
////            else if(DepositCurrencyName == "CHF")
////            {
////               if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
////                  CurrCommission = CurrCommission * MarketInfo("USDCHF", MODE_ASK);
////               else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
////                   CurrCommission = CurrCommission * MarketInfo("USDCHF", MODE_BID);
////            }
////#ifndef _NO_PRINTOUT            
////            // 07222025 Print("CurrCommission = ",DoubleToString(CurrCommission) );
////#endif
////            // Calculate Lots per One Dollar
////            double FractionalLotsPerDollar = RequiredLots / RequiredProfit;
////#ifndef _NO_PRINTOUT_             
////            // 07222025 Print("FractionalLotsPerDollar = ",DoubleToString(FractionalLotsPerDollar) );
////#endif             
////            
////            // Convert CurrCommision into fractional LOTs
////            double CurrCommisionAsLots = FractionalLotsPerDollar * CurrCommission;
////#ifndef _NO_PRINTOUT_             
////            // 07222025 Print("1. CurrCommisionAsLots = ",DoubleToString(CurrCommisionAsLots) );
////#endif             
////            
////            if(ActiveCommissionRoundUp)
////            {
////               CurrCommisionAsLots = RoundUp(CurrCommisionAsLots, ActiveMarketPrecission) ;
////            }
////            else
////            {
////               CurrCommisionAsLots = NormalizeDouble(CurrCommisionAsLots, ActiveMarketPrecission) ;
////            }
////#ifndef _NO_PRINTOUT_            
////            // 07222025 Print("2. CurrCommisionAsLots = ",DoubleToString(CurrCommisionAsLots) );
////#endif
////#ifndef _NO_PRINTOUT_           
////         // 07222025 Print("ORIGINAL RequiredLOTS: ",DoubleToString(RequiredLots,2) );
////#endif   
////            // Unrestricted FULL precision calcualtion NEEDED...
////            RequiredLots = RequiredLots + CurrCommisionAsLots;
////            
////#ifndef _NO_PRINTOUT_             
////            // 07222025 Print("ADJUSTED RequiredLOTS with Current Commision as Lot Size...");
////            // 07222025 Print("2. RequiredLots = ", DoubleToString(RequiredLots,2));
////            // 07222025 Print("3. RequiredLots = ", DoubleToString(RequiredLots));
////#endif             
////            
////         }
//         
//         //  Calculate BREAK EVEN
//         //double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
//         //double tickVal = UpdateTickVal(MarketInfo(Symbol(), MODE_TICKVALUE));
//         
//         double CurrCommission = 0;
//         
//         //  Only if Commission is calculated on the side as in LMAX
//         if(!CommissionBakedIn)
//         {
//            if(CommissionNotional)  
//            {
//               CurrCommission = FXOpenCommissions::CalculateCommission(Symbol(), RequiredLots);
//               
//               //if(CommissionMode == 1)
//               //   CurrCommission = RequiredLots * 1 * CurrOrderSize * (CommConst / 100);  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005
//               //else if(CommissionMode == 2 || CommissionMode == 3)
//               //   CurrCommission = RequiredLots * CurrPrice * CurrOrderSize * (CommConst / 100);  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005                              
//               //else if(CommissionMode == 4)
//               //   CurrCommission = RequiredLots * CurrPrice * (CommConst * 1000); 
//            }      
//            else
//            {
//               CurrCommission = CommissionConst * RequiredLots;
//               
//               //if(CommissionMode == 1 || CommissionMode == 2 || CommissionMode == 3)
//               //   CurrCommission = RequiredLots * CurrOrderSize * (CommConst / 100);  //  NOTIONAL: Order Size 100,000 (Currencies) 100 (Metals & Oil) | CurrPrice 1318.78 | CommissionConst 0.005% | CommissionConst in percentage 0.005 / 100 = 0.00005                              
//               //else if(CommissionMode == 4)
//               //   CurrCommission = RequiredLots * (CommConst * 1000); 
//            }
//               // OLD Way
//               // CurrCommission = RequiredLots * CurrOrderSize * (CommConst / 100);              //  NON-NOTIONAL:
//            
//#ifndef _NO_PRINTOUT_            
//            // 07222025 Print("1. CurrCommission = ",DoubleToString(CurrCommission) );
//#endif
//            
//            if(ActiveCommissionRoundUp)
//            {
//               CurrCommission = RoundUp(CurrCommission, ActiveMarketPrecission) ;
//            }
//            else
//            {
//               CurrCommission = NormalizeDouble(CurrCommission, ActiveMarketPrecission) ;
//            }
//
//         
//            // ===================================================================================================================
//            // CommConst is already in Deposit Currency!!!  No Need to calc CurrCommission by converting it to Deposit Curency!!!
//            // ===================================================================================================================
//            ////  If Deposit Currency is NOT USD, we have to convert the commission into alternative Deposit Currency like EUR, GBP or CHF according to according to the corresponding AccountCurrency()!!!
//            //if(DepositCurrencyName == "EUR")
//            //{
//            //   if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
//            //      CurrCommission = CurrCommission * 1 / MarketInfo("EURUSD", MODE_ASK);
//            //   else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
//            //       CurrCommission = CurrCommission * 1 / MarketInfo("EURUSD", MODE_BID);
//            //}
//            //else if(DepositCurrencyName == "GBP")
//            //{
//            //   if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
//            //      CurrCommission = CurrCommission * 1 / MarketInfo("GBPUSD", MODE_ASK);
//            //   else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
//            //       CurrCommission = CurrCommission * 1 / MarketInfo("GBPUSD", MODE_BID);
//            //}
//            //else if(DepositCurrencyName == "CHF")
//            //{
//            //   if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
//            //      CurrCommission = CurrCommission * MarketInfo("USDCHF", MODE_ASK);
//            //   else if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
//            //       CurrCommission = CurrCommission * MarketInfo("USDCHF", MODE_BID);
//            //}
//            
//#ifndef _NO_PRINTOUT_            
//            // 07222025 Print("2. RoundUp CurrCommission = ",DoubleToString(CurrCommission) );
//#endif
//         }
//         else
//            // 07222025 Print("3. CurrCommission = ",DoubleToString(CurrCommission) );
//            
//         
//#ifndef _NO_PRINTOUT_      
//         // 07222025 Print("Calculate BREAK EVEN...");    
//         // 07222025 Print("PipValue = ",DoubleToString(PipValue) );
//#endif          
//         
//         if((PipValue) <= 0)
//         {
//            TransactionComplete = true;
//            // 07222025 Print("4. CRITICAL ERROR!!!");
//            return(0);              //  EXIT if ZERO...
//         }
//                 
////         BreakEvenPips =  _AcumulatedFloatingLoss / (tickVal * RequiredLots) * Point;
////         // 07222025 Print("BreakEvenPips1 = ",DoubleToString(BreakEvenPips, Digits) );
////         
////         BreakEvenPips =  (_AcumulatedFloatingLoss / (PipValue * RequiredLots * _TicksPerPIP)) * (Point * _TicksPerPIP);
////         // 07222025 Print("BreakEvenPips2 = ",DoubleToString(BreakEvenPips, Digits) );
//           
//
////         CurrProfitLossPerPip = NormalizeDouble((tickVal * TicksPerPIP * RequiredLots), 2);
////         //// 07222025 Print("CurrProfitLossPerPip = ",DoubleToString(CurrProfitLossPerPip, 2) );
////         
//
//          //if(!ActiveMarketRoundUp) 
//          //{       
//          //  //CurrProfitLossPerPip = NormalizeDouble(tickVal * _TicksPerPIP * RequiredLots, PL_PipPrecision);         
//          //  //CurrProfitLossPerPip = NormalizeDouble(PipValue * RequiredLots, PL_PipPrecision);  
//          //  CurrProfitLossPerPip = PipValue * RequiredLots;  
//          //}       
//          //else
//          //{
//          //  //CurrProfitLossPerPip = RoundUp(tickVal * _TicksPerPIP * RequiredLots, PL_PipPrecision);
//          //  CurrProfitLossPerPip = RoundUp(PipValue * RequiredLots, PL_PipPrecision);
//          //}
//          
//          // Keep it as Unlimited accuracy number...
//          // 02/24/2025 - It is coming from OUTSIDE...
//          CurrProfitLossPerPip = PipValue * RequiredLots; 
//          
//#ifndef _NO_PRINTOUT_           
//         // 07222025 Print("CurrProfitLossPerPip = ", DoubleToString(CurrProfitLossPerPip));
//#endif      
//// =======================================================================================================================    
//         // Add Current Commission to Floating Loss...                   [ Convert to decimal Pips ] 
//// =======================================================================================================================         
//         BreakEvenPips =  ((_AcumulatedFloatingLoss + CurrCommission) / CurrProfitLossPerPip) * (Point * _TicksPerPIP);
//         //  No CurrCommissions needed - baked into RequiredLots...
//         //BreakEvenPips =  ((_AcumulatedFloatingLoss) / CurrProfitLossPerPip) * (Point * _TicksPerPIP);
//#ifndef _NO_PRINTOUT_         
//         // 07222025 Print("BreakEvenPips = ", DoubleToString(BreakEvenPips) );
//#endif
//         
//         //// 07222025 Print("2. RequiredLots = " + RequiredLots); 
//         
//         
//         // No Need to remove precission detail here...
//         // Roundup and Normalize needed ONLY prior to Opening Position
//         //if(!ActiveMarketRoundUp)        
//         //{
//         //   RequiredLots = NormalizeDouble(RequiredLots, NormDoublePrecission);         
//         //}
//         //else
//         //{
//         //   RequiredLots = RoundUp(RequiredLots, ActiveMarketPrecission);
//         //}
//         
//         //// 07222025 Print("MAXLotsTrigger: " + IntegerToString(MAXLotsTrigger) + "RequiredLots: " + DoubleToString(RequiredLots,2) + " > MAXLots: " + DoubleToString(MAXLotsAllowed,2) + 
//         //      "MAXAccumLossTrigger: " + IntegerToString(MAXAccumLossTrigger) +" AcumulatedFloatingLoss: " + DoubleToString(_AcumulatedFloatingLoss,2) + " > MAXAccumLoss: " + DoubleToString(MAXAccumLossAllowed,2));
//         
//         if(ShutOffValve && !ShutOffVeleveHIT && 
//           ((MAXLotsTrigger && Lots > MAXLotsAllowed) || 
//           (MAXAccumLossTrigger && AcumulatedFloatingLoss > MAXAccumLossAllowed))
//           )
//           {
//            
//               // 07222025 Print("<<< ShutOFF Hit or MAX_LOT reached inside CalcNewLotSize()...");
//               // 07222025 Print("<<< ========================================================= >>>");
//               MessageBox("ShutOFF Hit or MAX_LOT reached inside CalcNewLotSize()...\nProgram Terminated!!!", "CRITICAL WARNING!!!", MB_OK);
//               ShutOffVeleveHIT = true;
//               TransactionComplete = true;
//           }
//         
//#ifndef _NO_PRINTOUT_            
//         // 07222025 Print("<<< RETURNING RequiredLOTS: " + DoubleToString(RequiredLots));
//#endif          
//         return(RequiredLots);  
//           
//}




double CalcNewLotSize(double _AcumulatedFloatingLoss)
{

#ifndef _NO_PRINTOUT_ 
         // 07222025 Print("Inside CalcNewLotSize");
         // 07222025 Print("1. Lots = " + DoubleToString(Lots));
         // 07222025 Print("2. TicksPerPIP = " + DoubleToString(_TicksPerPIP));
         //// 07222025 Print("3. PipValue = " + DoubleToString(PipValue));
         // 07222025 Print("4. StopLossPips = " + DoubleToString(StopLossPips));
         // 07222025 Print("5. TakeProfitPips = " + DoubleToString(TakeProfitPips));
         // 07222025 Print("6. TrailingTriggerPips = " + DoubleToString(TrailingTriggerPips));
         // 07222025 Print("7. TrailingTailPips = " + DoubleToString(TrailingTailPips));
         
#endif          
         //// 07222025 Print("");
         //// 07222025 Print("");
         //// 07222025 Print("");
         
         
         double CurrPrice = 0;       
         
         double PipValue = 0;
         
         for(int i=0; i<15; i++)
         {
            PipValue = MarketInfo(Symbol(), MODE_TICKVALUE) * _TicksPerPIP;
            if(PipValue > 0)
               break;
               
            Sleep(SuspendThread_TimePeriod);
         }
         
         //PipValue = UpdateTickVal(MarketInfo(Symbol(), MODE_TICKVALUE) * _TicksPerPIP);
         
#ifndef _NO_PRINTOUT_          
         // 07222025 Print("PIPVal = ", DoubleToString(PipValue)); 
#endif          
   
         
         if(PipValue <= 0)
         {
            TransactionComplete = true;
            // 07222025 Print("2. CRITICAL ERROR!!!");
            return(0);              //  EXIT if ZERO...
         }
         
         //  PARAM1 Calculation
         //  ==================
         double Param1;
         
         string param_1 = "";
         string param_2 = "";
         string param_3 = "";
         string param_4 = "";
         
         string url  = "";
         
         
#ifdef   _TrailingStop_
         
         //if(!TTriggerLineActive)
         if(CalcRPbyTakeProfit)
                  {               
                        Param1 = (TakeProfitPips / _TicksPerPIP) * PipValue;
   #ifndef _NO_PRINTOUT_          
                        // 07222025 Print("PARAM1 - CalcRPbyTakeProfit = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TakeProfitPips: " + DoubleToString(TakeProfitPips / _TicksPerPIP,1)); 
   #endif                                    
                     
                  }
               else
                  {
                     // TRUE - By Trigger Level  |   FALSE - By Tail Level
                     if(CalcRPbyTrigOrTailLevel) 
                     {                 
                                        
                        Param1 = (TrailingTriggerPips / _TicksPerPIP) * PipValue;
   #ifndef _NO_PRINTOUT_          
                        // 07222025 Print("PARAM1 - CalcRPbyTrigOrTailLevel(1) = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips / _TicksPerPIP,1)); 
   #endif                      
                 
                        
                     }
                     else
                     {
     
                        Param1 = (TrailingTailPips / _TicksPerPIP) * PipValue;
   
   #ifndef _NO_PRINTOUT_
                        // 28.04.2022  
                        // 07222025 Print("TrailingTriggerPips" + DoubleToString(TrailingTriggerPips));        
                        // 07222025 Print("TrailingTailPips" + DoubleToString(TrailingTailPips));  
                        // 07222025 Print("_TicksPerPIP" + DoubleToString(_TicksPerPIP));  
   
                        // 07222025 Print("PARAM1 - CalcRPbyTrigOrTailLevel(0) = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TrailingTailPips: " + DoubleToString(MathAbs(TrailingTriggerPips - TrailingTailPips) / _TicksPerPIP,1)); 
   #endif                      
              
                        
                     }
                  }
#else
         Param1 = (TakeProfitPips / _TicksPerPIP) * PipValue;
         
   #ifndef _NO_PRINTOUT_          
            // 07222025 Print("Param1 = ", DoubleToString(Param1) + " PipValue: " + DoubleToString(PipValue) + " BASED ON TakeProfitPips: " + DoubleToString(TakeProfitPips / _TicksPerPIP,1)); 
   #endif          

#endif                  
         
         
         //  PARAM2 Calculation
         //  ==================
         double Param2 = 0;
         
         if(!CommissionBakedIn)
         {
         if(CommissionNotional)
            Param2 = FXOpenCommissions::CalculateCommission(Symbol(), 1);
         else
            Param2 = CommissionConst;
         }
         else
            Param2 = 0;

              
         //  Check Param1 & Param2 Values              
         if((Param1 - Param2) <= 0)
         {
            TransactionComplete = true;
            // 07222025 Print("3. CRITICAL ERROR!!!  Param1 - Param2 <= 0");
            return(0);              //  EXIT if ZERO...
         }

         
         //  CALCULATE RequiredProfit HERE
         //  ========================================
         //double RequiredProfit = DesiredNetProfit + CurFloatingLoss;  
         double RequiredProfit = 0;
         
         AcumulatedFloatingLoss = 0;
         if(GetCurrentLossFromGlobalVAR(AcumulatedFloatingLoss))
            // 07222025 Print("AcumulatedFloatingLoss: " + DoubleToString(AcumulatedFloatingLoss,2));
            
         if(PLperPipOrDesiredTP) 
            RequiredProfit = AcumulatedFloatingLoss +  (ProfitLossPerPIP * TakeProfitPips / _TicksPerPIP);          
         else
            RequiredProfit = AcumulatedFloatingLoss +  DesiredNetProfitVal;
            
                           
            
#ifdef   _TrailingStop_         
         //if(!TTriggerLineActive)
         if(CalcRPbyTakeProfit)
                  {
                     byTakeProfit = true;
                     CurrProfitLossPerPip = RequiredProfit / (TakeProfitPips / _TicksPerPIP); 
                        
                           
                        //RequiredProfit = (TakeProfitPips / _TicksPerPIP) * CurrProfitLossPerPip;
                        
   #ifndef _NO_PRINTOUT_                      
                        // 07222025 Print("ORIGINAL RequiredProfit - CalcRPbyTakeProfit: " + DoubleToString(RequiredProfit, 2)  + " BASED ON TakeProfitPips: " + DoubleToString((TakeProfitPips / _TicksPerPIP),1) + " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
   #endif                       
                  }
               else
                  {
                     // TRUE - By Trigger Level  |   FALSE - By Tail Level
                     if(CalcRPbyTrigOrTailLevel == true)   
                     {               
                        byTrailingTrigger = true;
                        CurrProfitLossPerPip = RequiredProfit / (TrailingTriggerPips / _TicksPerPIP);
                
                        //RequiredProfit = (TrailingTriggerPips / _TicksPerPIP) * CurrProfitLossPerPip;
                        
   #ifndef _NO_PRINTOUT_                      
                        // 07222025 Print("ORIGINAL RequiredProfit - byTrailingTrigger: " + DoubleToString(RequiredProfit, 2) + 
                              " BASED ON TrailingTriggerPips: " + DoubleToString((TrailingTriggerPips / _TicksPerPIP),1)+ 
                              " TrailingTailPips: " + DoubleToString(TrailingTailPips / _TicksPerPIP,1) + " " +
                              " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
   #endif                     
                                             
                     }
                     else if(CalcRPbyTrigOrTailLevel == false) 
                     {
                        byTrailingStop = true;
                        CurrProfitLossPerPip = RequiredProfit / (TrailingTailPips / _TicksPerPIP);
                        
                        //RequiredProfit = ((TrailingTailPips / _TicksPerPIP) * CurrProfitLossPerPip);
                        
   #ifndef _NO_PRINTOUT_                      
                        // 07222025 Print("ORIGINAL RequiredProfit - byTrailingStop: " + DoubleToString(RequiredProfit, 2) + 
                              " TrailingTriggerPips: " + DoubleToString(TrailingTriggerPips / _TicksPerPIP,1) + " " +
                              " BASED ON TrailingTailPips: " + DoubleToString((TrailingTailPips / _TicksPerPIP),1)+ 
                              " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
   #endif                     
                              
                                             
                     }
                  }
#else
//  Not Complete...
         if(CalcRPbyTakeProfit)
         {
            byTakeProfit = true;
            //RequiredProfit = (TakeProfitPips / _TicksPerPIP) * CurrProfitLossPerPip;
            
            #ifndef _NO_PRINTOUT_                      
            // 07222025 Print("FALLBACK RequiredProfit - CalcRPbyTakeProfit: " + DoubleToString(RequiredProfit, 2)  + " BASED ON TakeProfitPips: " + DoubleToString((TakeProfitPips / _TicksPerPIP),1) + " CurrProfitLossPerPip: " + DoubleToString(CurrProfitLossPerPip));
            #endif 
         }

#endif                   
         

      

            // FINAL RequiredProfit... 
            //// 07222025 Print("RequiredProfit + _AcumulatedFloatingLoss: " + DoubleToString(RequiredProfit + _AcumulatedFloatingLoss,2));   
            
            // OVERRIDE RequiredProfit value...
            if((_AcumulatedFloatingLoss > 0) && 
               EmergencyBreakEvenEXIT && 
               NumOfStops >= EmergencyBreakEvenAtRun)    
               {
                     RequiredProfit = _AcumulatedFloatingLoss;
#ifndef _NO_PRINTOUT_                      
                     // 07222025 Print("FINAL EMERGENCY - RequiredProfit = _AcumulatedFloatingLoss: " + DoubleToString(_AcumulatedFloatingLoss,2));
#endif                      
               }
       

         
         //// 07222025 Print("INSIDE CalcNewLotSize -> RequiredProfit = ",DoubleToString(RequiredProfit,2) );
         
         //  No RoundUps FULL Precission NEEDED!!!
         double RequiredLots = 0;
         RequiredLots = RequiredProfit / (Param1 - Param2); 
         
         if( MarketInfo(Symbol(), MODE_MAXLOT) < RequiredLots )
         {
               // 07222025 Print("<<< MAX_LOT reached inside CalcNewLotSize()...");
               // 07222025 Print("<<< ====================================== >>>");
               MessageBox("MAX_LOT reached inside CalcNewLotSize()...\nProgram Terminated!!!", "CRITICAL WARNING!!!", MB_OK);
               
               ShutOffVeleveHIT = true;
               TransactionComplete = true;
               
               return(RequiredLots);
         }
               
#ifndef _NO_PRINTOUT_           
         // 07222025 Print("1. RequiredLOTS = [RequiredProfit / (Param1 - Param2)]= ",DoubleToString(RequiredLots), " - " + DoubleToString(Param1), " - " + DoubleToString(Param2));
#endif          

         // Roundup and Normalize needed ONLY prior to Opening Position
         if(!ActiveMarketRoundUp)        
         {
            RequiredLots = NormalizeDouble(RequiredLots, NormDoublePrecission);         
         }
         else
         {
            RequiredLots = RoundUp(RequiredLots, ActiveMarketPrecission);
         }

#ifndef _NO_PRINTOUT_           
         // 07222025 Print("2. RoundUp RequiredLOTS = [RequiredProfit / (Param1 - Param2)]= ", DoubleToString(RequiredLots));
#endif          
         
         
         double CurrCommission = 0;
         
         //  Only if Commission is calculated on the side as in LMAX
         if(!CommissionBakedIn)
         {
            if(CommissionNotional)  
               CurrCommission = FXOpenCommissions::CalculateCommission(Symbol(), RequiredLots);
            else
               CurrCommission = CommissionConst * RequiredLots;
            
#ifndef _NO_PRINTOUT_            
            // 07222025 Print("1. CurrCommission = ",DoubleToString(CurrCommission) );
#endif
            
            if(ActiveCommissionRoundUp)
               CurrCommission = RoundUp(CurrCommission, ActiveMarketPrecission) ;
            else
               CurrCommission = NormalizeDouble(CurrCommission, ActiveMarketPrecission) ;


            
#ifndef _NO_PRINTOUT_            
            // 07222025 Print("2. RoundUp CurrCommission = ",DoubleToString(CurrCommission) );
#endif
         }
         else
            // 07222025 Print("3. CurrCommission = ",DoubleToString(CurrCommission) );
            
         
#ifndef _NO_PRINTOUT_      
         // 07222025 Print("Calculate BREAK EVEN...");    
         // 07222025 Print("PipValue = ",DoubleToString(PipValue) );
#endif          
         
         if((PipValue) <= 0)
         {
            TransactionComplete = true;
            // 07222025 Print("4. CRITICAL ERROR!!!");
            return(0);              //  EXIT if ZERO...
         }

          //CurrProfitLossPerPip = PipValue * RequiredLots; 
          
#ifndef _NO_PRINTOUT_           
         // 07222025 Print("CurrProfitLossPerPip = ", DoubleToString(CurrProfitLossPerPip));
#endif      
// =======================================================================================================================    
         // Add Current Commission to Floating Loss...                   [ Convert to decimal Pips ] 
// =======================================================================================================================         
         BreakEvenPips =  ((_AcumulatedFloatingLoss + CurrCommission) / CurrProfitLossPerPip) * (Point * _TicksPerPIP);
         //  No CurrCommissions needed - baked into RequiredLots...
         //BreakEvenPips =  ((_AcumulatedFloatingLoss) / CurrProfitLossPerPip) * (Point * _TicksPerPIP);
#ifndef _NO_PRINTOUT_         
         // 07222025 Print("BreakEvenPips = ", DoubleToString(BreakEvenPips) );
#endif
         
         
         if(ShutOffValve && !ShutOffVeleveHIT && 
           ((MAXLotsTrigger && Lots > MAXLotsAllowed) || 
           (MAXAccumLossTrigger && AcumulatedFloatingLoss > MAXAccumLossAllowed))
           )
           {
            
               // 07222025 Print("<<< ShutOFF Hit or MAX_LOT reached inside CalcNewLotSize()...");
               // 07222025 Print("<<< ========================================================= >>>");
               MessageBox("ShutOFF Hit or MAX_LOT reached inside CalcNewLotSize()...\nProgram Terminated!!!", "CRITICAL WARNING!!!", MB_OK);
               ShutOffVeleveHIT = true;
               TransactionComplete = true;
           }
         
#ifndef _NO_PRINTOUT_            
         // 07222025 Print("<<< RETURNING RequiredLOTS: " + DoubleToString(RequiredLots));
#endif          
         return(RequiredLots);  
           
}




// ==========================================================================================================


void ShutOffValveHIT()
{
   
}

// ==========================================================================================================


double GetCurrentBreakEvenPips(double _AcumulatedFloatingLoss, double CurrLots)
{
   //  Calculate BREAK EVEN
         double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
         //double tickVal = UpdateTickVal(MarketInfo(Symbol(), MODE_TICKVALUE));
         //// 07222025 Print("tickVal = ",DoubleToString(tickVal) );
         
         if((tickVal) <= 0)
         {
            TransactionComplete = true;
            //// 07222025 Print("4. CRITICAL ERROR!!!");
            return(0);              //  EXIT if ZERO...
         }
         
         double _BreakEvenPips =  _AcumulatedFloatingLoss / (tickVal * CurrLots) * Point;
         // 07222025 Print("BreakEvenPips = ",DoubleToString(BreakEvenPips) );
         
         return(_BreakEvenPips);
}


// ==========================================================================================================

//
//double RoundUp(double num, int precision)
//{
//   // precision == 1 -> Rounding up with 1/10 precission
//   // precision == 2 -> Rounding up with 1/100 precission
//   // precision == 3 -> Rounding up with 1/1000 precission
//   // precision == 4 -> Rounding up with 1/10000 precission
//   // precision == 5 -> Rounding up with 1/100000 precission
//   double precis_const;
//   
///*   if(precision == 1)
//      precis_const = 0.1;   // 1 / MathPow(10, 1);
//   else if(precision == 2)
//      precis_const = 0.01;  // 1 / MathPow(10, 2);
//*/
//   // USE NORMALIZE DOUBLE
//   
//   precis_const = 1 / MathPow(10, precision);
//      
//   double num_devided = num / precis_const;
//   double num_int = MathCeil(num_devided);
//   double num_round_up = num_int * precis_const;
//      
//   return(num_round_up);   
//}


double RoundUp(double num,int precision)
{
// precision == 1 -> Rounding up with 1/10 precission
// precision == 2 -> Rounding up with 1/100 precission
// precision == 3 -> Rounding up with 1/1000 precission
// precision == 4 -> Rounding up with 1/10000 precission
// precision == 5 -> Rounding up with 1/100000 precission

   double precis_const=1/MathPow(10,precision);

   double num_devided=num/precis_const;
   double num_int=MathCeil(num_devided);
   double num_round_up=num_int*precis_const;

   return(num_round_up);
}
  
  
  
  double SendWEBRequest(string _url)
  {
   
   string cookie=NULL;
   string headers;
   char post[], result[];
   int res; 
   int timeout=5000;

   ResetLastError();
     
     
   res=WebRequest("GET", 
                  _url,
                  cookie,
                  NULL,
                  timeout,
                  post,
                  0,
                  result,
                  headers);
                  
   if(res==-1)
     {
      //// 07222025 Print("Error in WebRequest. Error code  =", GetLastError());
      MessageBox("Add the address '" + _url + "' in the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      
      return(0);
     }
   else
     {
      //--- Load successfully
      //// 07222025 Print("WEB Request Server Response Code: " + IntegerToString(res));
      
      int ReturnSIZE = ArraySize(result);
      //// 07222025 Print("WEB Request Length in Bytes: " + IntegerToString(ReturnSIZE));        
        
      string RetBuffStr = CharArrayToString(result);
      //// 07222025 Print("WEB Request Body: " + RetBuffStr); 
      
      double RetBuffNum = StringToDouble(RetBuffStr);
      //// 07222025 Print("RetBuffNum: " + DoubleToString(RetBuffNum,0));
      
      return(RetBuffNum);
      
     }
     
  }
  
  
  
  bool WaitForTradingGreenLight()
  {
      uint SuspendCounter = 0;    
      uint MiliTimeDelayBeforeCancel = TimeDelayBeforeCancel * 1000;
      bool isTradeContextBusy = IsTradeContextBusy();
      uint thisTickValue = GetTickCount();
      bool isResponseWithinTimeRange = ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel);
      
      while(isTradeContextBusy &&
            isResponseWithinTimeRange)
      {
         Sleep(SuspendThread_TimePeriod);
         SuspendCounter++;
         
         isTradeContextBusy = IsTradeContextBusy();
         isResponseWithinTimeRange = ((GetTickCount() - thisTickValue) <= MiliTimeDelayBeforeCancel);
      } 
      
      
      if(!isTradeContextBusy)
      {
         //// 07222025 Print("Trade Context is AVAILABLE!!!");
         //// 07222025 Print("SuspendCounter: " + IntegerToString(SuspendCounter));
         
         return(true);
      }
      else
      {
         //// 07222025 Print("Trade Context is NOT AVAILABLE after WAITING for " + IntegerToString(MiliTimeDelayBeforeCancel) + "sec.");
         //// 07222025 Print("SuspendCounter: " + IntegerToString(SuspendCounter));
         
         return(false);
      }
      
  }
  
//  
//  bool InitializeAccountCurrency()
//{
//
//     string AccStr = AccountCurrency();
//      
//     if(AccStr == "USD")
//     {
//         TickConvertPair = "";
//         // 07222025 Print("Account is in: USD");
//     }
//     else 
//         if(AccStr == "GBP")
//         {
//             TickConvertPair = "GBPUSD" + CurrencyPairNameExt;
//             // 07222025 Print("Account is in: GBP");
//         }
//         else 
//             if(AccStr == "EUR")    
//             {
//                TickConvertPair = "EURUSD" + CurrencyPairNameExt;
//                // 07222025 Print("Account is in: EUR");
//             }
//             else
//                 if(AccStr == "CHF") 
//                 {
//                     TickConvertPair = "USDCHF" + CurrencyPairNameExt;
//                     // 07222025 Print("Account is in: CHF");
//                 } 
//                 else
//                 {
//                     // 07222025 Print("Account Currency NOT supported!!!");
//                     return(false);
//                 }
//
//
//      return(true);
//      
//}
//
//  
//  
//double UpdateTickVal(double OriginalTickVal)
//{
//   if(TickConvertPair == "")
//      return(OriginalTickVal);
//
//   
//   if((StringFind(TickConvertPair, "EUR", 0) >= 0) || (StringFind(TickConvertPair, "GBP", 0) >= 0))
//   {
//      //if(ExecCommand==BUY_STOP || ExecCommand==BUY_LIMIT || ExecCommand==BUY_MARKET)
//      //   return(OriginalTickVal* MarketInfo(TickConvertPair, MODE_ASK));
//      //else 
//      //   if(ExecCommand==SELL_STOP || ExecCommand==SELL_LIMIT || ExecCommand==SELL_MARKET)
//      //      return(OriginalTickVal* MarketInfo(TickConvertPair, MODE_BID));
//      
//      
//         return(OriginalTickVal * (MarketInfo(TickConvertPair, MODE_ASK) * MarketInfo(TickConvertPair, MODE_BID) / 2));
//      
//   }
//        
//   if(StringFind(TickConvertPair, "CHF", 0) >= 0)
//   {
//      return(OriginalTickVal * (1 / (MarketInfo(TickConvertPair, MODE_ASK) * MarketInfo(TickConvertPair, MODE_BID) / 2)));
//   }
//   
//   // 07222025 Print("UpdateTickVal - CRITICAL ERROR!!!");
//   return(0);
//   
//}