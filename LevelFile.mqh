//+------------------------------------------------------------------+
//|                                                    LevelFile.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#import "kernel32.dll"
   int  GetCurrentProcessId();
   bool CopyFileW(string lpExistingFileName, string lpNewFileName, bool failIfExists); 
#import

//#import "user32.dll"
//int SendMessageA(int hWnd,int Msg,int wParam,int lParam);
//int FindWindowExA(int hWndParent,int hWndChildAfter, char &lpszClass[], char &lpszWindow[]);
//int GetWindowThreadProcessId(int hWnd, int &lpdwProcessId);
//int GetDesktopWindow();
//int GetParent(int hWnd);
//int PeekMessageA(int lpMsg, int HWND, uint wMsgFilterMin, uint  wMsgFilterMax, uint wRemoveMsg);
//#import
//
//#define WM_CLOSE        0x0010
//#define WM_MDIACTIVATE  0x0222

//#include <WinUser32.mqh>
#include <WinUser32-2.mqh>
#include <Strings\String.mqh>
#include <AccuMath.mqh>

//extern string symbol = "GOLD"; 

int periods[9] = {PERIOD_MN1, PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H1, PERIOD_M30, PERIOD_M15, PERIOD_M5, PERIOD_M1};

int hProcThis = 0;
int hWndFound = 0;
static int _cnt = 0;

// ========================================================================


bool GenerateSychLevelFile(int    _MarketOrderType,
                           string _DestinationInstance,
                           double _PriceTargetLevel,
                           double _StopLossLevel,
                           double _TakeProfitLevel
                           //,double _TrailingTriggerLevel
                           )
{

   int LastErr         =  -1;
   string mainDestPath =  "";
   string InternalPath =  "\\MQL4\\Files\\";   // Internal Path
   string FileName     =  "Pos.val";
   
   string EntryStr     =  "EntryLvl";
   string SLStr        =  "StopLossLvl";
   string TPStr        =  "TakeProfitLvl";
   string TTStr        =  "TrailingTriggerLvl";
   
   // Create .CSV file with Level Values locally in SandBox, giving it a _Local.Csv extention
   //  Write data from csv file...
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
   
   ResetLastError();
   
   int file_handle = FileOpen(FileName, FILE_WRITE|FILE_CSV|FILE_ANSI, '=');  
   if(file_handle != INVALID_HANDLE) 
     {      
      FileWrite(file_handle, EntryStr,   AccuChop_ToFracNum(_PriceTargetLevel));
      FileWrite(file_handle, SLStr,      AccuChop_ToFracNum(_StopLossLevel));
      FileWrite(file_handle, TPStr,      AccuChop_ToFracNum(_TakeProfitLevel));
      //FileWrite(file_handle, TTStr,      AccuChop_ToFracNum(_TrailingTriggerLevel));
     
      FileClose(file_handle); 
#ifndef _NO_PRINTOUT_      
      // 07222025 Print("FileName: " + FileName);
      // 07222025 Print("_PriceTargetLevel: " + DoubleToString(_PriceTargetLevel));
      // 07222025 Print("_StopLossLevel: " + DoubleToString(_StopLossLevel));
      // 07222025 Print("_TakeProfitLevel: " + DoubleToString(_TakeProfitLevel));
      //// 07222025 Print("_TrailingTriggerLevel: " + DoubleToString(_TrailingTriggerLevel));
      
      // 07222025 Print("File Writen OK"); 
#endif      
     } 
   else 
   {
      // 07222025 Print("Operation FileOpen for WRITE failed, error ", GetLastError()); 
      return false;
   }
   
   
   // Copy _Local.Csv to Destination folder renaming it to .Csv ONLY
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("Copy file to Destination Dir...");
#endif   

   string mainLocalPath = TerminalInfoString(TERMINAL_DATA_PATH);
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("GenerateSychLevelFile - mainLocalPath: " + mainLocalPath);
#endif   
   int sLen = StringLen(mainLocalPath);
   
   while(sLen >=0 && mainLocalPath[sLen] != '\\')
      sLen--;
      
   if(sLen < 0)
      return false;
      
   mainDestPath = StringSubstr(mainLocalPath,0, sLen);
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("GenerateSychLevelFile - mainDestPath: " + mainDestPath);
#endif
   mainDestPath = mainDestPath + _DestinationInstance + InternalPath + FileName;
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("GenerateSychLevelFile - mainDestPath: " + mainDestPath);
   
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
      // 07222025 Print("GenerateSychLevelFile - mainDestPath: " + mainDestPath);
#endif      
   }
   
   mainLocalPath = mainLocalPath + InternalPath + FileName;
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("GenerateSychLevelFile - mainLocalPath: " + mainLocalPath);
#endif   
   ResetLastError();
   
   int bResCopyFile = CopyFileW(mainLocalPath,      //  Existing File
                                mainDestPath, //  New File destination
                                false  );     //  TRUE - Do NOT overwrite new file
                                              //  FALSE - Overwrite new file
                                                
#ifndef _NO_PRINTOUT_   
   // 07222025 Print("GenerateSychLevelFile - bResCopyFile: " + IntegerToString(bResCopyFile));  
   // 07222025 Print("GenerateSychLevelFile - CopyFileW Error: " + IntegerToString(GetLastError()));
#endif   
   
   // Delete the _Local.Csv
   ResetLastError();
   
   
   uint SuspendCounter = 0;
   uint MiliTimeDelayBeforeCancel = 10 * 1000;
   uint thisTickValue = GetTickCount();
   
   while((FileIsExist(FileName, FILE_READ)) && 
   (GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel))
   {
#ifndef _NO_PRINTOUT_   
      LastErr = GetLastError();
      // 07222025 Print("GenerateSychLevelFile - " + FileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif       
      FileDelete(FileName);
#ifndef _NO_PRINTOUT_      
      LastErr = GetLastError();
      // 07222025 Print("GenerateSychLevelFile - " + FileName + " >>> FileDelete Error: " + IntegerToString(LastErr));
#endif      
      Sleep(SuspendThread2_TimePeriod);
      SuspendCounter++;

      //getThisTick = GetTickCount() - thisTickValue;
   }
   
#ifndef _NO_PRINTOUT_   
   if(LastErr == 0)
   {
      // 07222025 Print("GenerateSychLevelFile - " + FileName + " >>> File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );
      return true;
   }
   else
   {
      // 07222025 Print("GenerateSychLevelFile - Can''t Delete File: " + FileName + " >>> after " + IntegerToString(SuspendCounter) + " times trying..." );
      return false;
   }
#endif    
   
   //FileDelete(FileName);
   
   return true;
   
}                       


// ========================================================================


bool WaitToReceiveFile(string &_SynchFileName,
                       int _MarketOrderType,
                       int _SuspendThread_TimePeriod,    // 150
                       uint _TimeDelayBeforeCancel)      // 3 
{
   int   LastErr       =  -1; 
   string FileName     =  "Pos.val";
   string InternalPath =  "\\MQL4\\Files\\";

#ifndef _NO_PRINTOUT_    
   // 07222025 Print("<<< Inside - WaitToReceiveFile >>>");
#endif 
   
   // Expecting the opposit file to be received
   if(_MarketOrderType == 2)   
   {
      // LONG
      _SynchFileName = "LONG" + FileName;
   }
   else
   {
      // SHORT
      _SynchFileName = "SHORT" + FileName;
   }
   
   //string mainLocalPath = TerminalInfoString(TERMINAL_DATA_PATH);
   //mainLocalPath = mainLocalPath + InternalPath + FileName;
   
   uint SuspendCounter = 0;
   uint MiliTimeDelayBeforeCancel = _TimeDelayBeforeCancel * 1000;
   uint thisTickValue = GetTickCount();
   //uint getThisTick = GetTickCount() - thisTickValue;
   
   //bool fExistRes = FileIsExist(mainLocalPath, FILE_READ);
   //bool fExistRes = FileIsExist(FileName, FILE_READ);
   
   if(MiliTimeDelayBeforeCancel > 0)
   {
      ResetLastError();
      
      while(((!FileIsExist(_SynchFileName, FILE_READ)) && (!IsStopped())) && 
            (GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel))
      {
#ifndef _NO_PRINTOUT_       
         LastErr = GetLastError();
         // 07222025 Print("WaitToReceiveFile - " + _SynchFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif          
         Sleep(SuspendThread2_TimePeriod);
         SuspendCounter++;

#ifndef _NO_PRINTOUT_          
         if(MathMod(SuspendCounter, 35) == 0)   // 5 sec
            // 07222025 Print("WaitToReceiveFile: " + _SynchFileName + " >>> While WAITING 5sec..." + IntegerToString(LastErr));
#endif             
         //getThisTick = GetTickCount() - thisTickValue;
      }
   }
   else
   {
      ResetLastError();

#define _ONE_LINE_NOTIFICATION_
#ifdef   _ONE_LINE_NOTIFICATION_
         bool OneLine_FirstTime = true;
#endif
      
      while((!FileIsExist(_SynchFileName, FILE_READ)) && (!IsStopped()))
      {
#ifndef _ONE_LINE_NOTIFICATION_      
#ifndef _NO_PRINTOUT_       
         LastErr = GetLastError();
         // 07222025 Print("WaitToReceiveFile - " + _SynchFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif               
         Sleep(SuspendThread2_TimePeriod);
         SuspendCounter++;
         
#ifndef _NO_PRINTOUT_          
         if(MathMod(SuspendCounter, 35) == 0)   // 5 sec
            // 07222025 Print("WaitToReceiveFile: " + _SynchFileName + " >>> While WAITING 5sec..." + IntegerToString(LastErr));
#endif  
#endif

#ifdef   _ONE_LINE_NOTIFICATION_
         
         LastErr = GetLastError();
         
         if(OneLine_FirstTime)
         {   
            // 07222025 Print("WaitToReceiveFile - " + _SynchFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
            OneLine_FirstTime = false;
         }

         Sleep(SuspendThread2_TimePeriod);
         SuspendCounter++;
         
         if(MathMod(SuspendCounter, 35*12) == 0)   // 60 sec
         {
            // 07222025 Print("WaitToReceiveFile: " + _SynchFileName + " >>> WAITING 1min..." + IntegerToString(LastErr));
         }
#endif         
      }
   }
   
#ifndef _NO_PRINTOUT_     
   // 07222025 Print("WaitToReceiveFile - Final SuspendCounter: " + IntegerToString(SuspendCounter));
#endif 

   ResetLastError();
   
   if(FileIsExist(_SynchFileName, FILE_READ))  
   {
#ifndef _NO_PRINTOUT_    
      LastErr = GetLastError();
      // 07222025 Print("WaitToReceiveFile - " + _SynchFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif       
      return true;
   }
   else
   {
#ifndef _NO_PRINTOUT_    
      LastErr = GetLastError();
      // 07222025 Print("WaitToReceiveFile - " + _SynchFileName + " >>> FileIsExist Error: " + IntegerToString(LastErr));
#endif       
      return false;
   }
   
}


// ========================================================================


bool GetSychFileVals(string _FaileName,
                     double &_extPriceTargetLevel,
                     double &_extStopLossLevel,
                     double &_extTakeProfitLevel
                     //,double &_extTrailingTriggerLevel
                     )
{
   double intDPriceTargetLevel = 0;
   double intDStopLossLevel = 0;
   double intDTakeProfitLevel = 0;
   //double intDTrailingTriggerLevel = 0;
   
   ResetLastError();
   
   //  Read data from csv file...   
   int file_handle = FileOpen(_FaileName, FILE_READ|FILE_CSV|FILE_ANSI, '=');  
   if(file_handle != INVALID_HANDLE) 
     {
          string Line1_Val1 = FileReadString(file_handle);
          //string Line1_Val2 = FileReadString(file_handle);
       intDPriceTargetLevel = FileReadNumber(file_handle);
          
          string Line2_Val1 = FileReadString(file_handle);
          //string Line2_Val2 = FileReadString(file_handle);
          intDStopLossLevel = FileReadNumber(file_handle);
          
          string Line3_Val1 = FileReadString(file_handle);
          //string Line3_Val2 = FileReadString(file_handle);
          intDTakeProfitLevel = FileReadNumber(file_handle);
          
          //string Line4_Val1 = FileReadString(file_handle);
          ////string Line3_Val2 = FileReadString(file_handle);
          //intDTrailingTriggerLevel = FileReadNumber(file_handle);
          
          FileClose(file_handle); 
          // 07222025 Print("File Read Value by Value OK");  
          
          
          //=================================================
//          ResetLastError();
//          int file_handle2 = FileOpen(_FaileName + "2", FILE_WRITE|FILE_CSV|FILE_ANSI);  
//          if(file_handle != INVALID_HANDLE) 
//              {      
//               uint dRes1 = FileWrite(file_handle2, intDPriceTargetLevel);
//#ifndef _NO_PRINTOUT_                 
//               // 07222025 Print("1. FileWriteDouble Error: ", GetLastError());
//#endif                
//               uint dRes2 = FileWrite(file_handle2, intDStopLossLevel);
//#ifndef _NO_PRINTOUT_                 
//               // 07222025 Print("2. FileWriteDouble Error: ", GetLastError());
//#endif                
//               uint dRes3 = FileWrite(file_handle2, intDTakeProfitLevel);
//#ifndef _NO_PRINTOUT_                 
//               // 07222025 Print("3. FileWriteDouble Error: ", GetLastError());
//#endif 
//               //uint dRes4 = FileWrite(file_handle2, intDTrailingTriggerLevel);
//               //// 07222025 Print("4. FileWriteDouble Error: ", GetLastError());
//              
//               FileClose(file_handle2); 
//
//#ifndef _NO_PRINTOUT_                               
//               // 07222025 Print("File2 Writen OK"); 
//#endif                
//              } 
//         else 
//            {
//               // 07222025 Print("Operation FileOpen2 for WRITE failed, error ", GetLastError()); 
//               return false;
//            }
          
          //=================================================
          
          ////  Convert input values to double
          //double intPriceTargetLevel      = StringToDouble(Line1_Val2);
          //double intStopLossLevel         = StringToDouble(Line2_Val2);
          //double intTakeProfitLevel       = StringToDouble(Line3_Val2);
          
          _extPriceTargetLevel   =  intDPriceTargetLevel;
          _extStopLossLevel      =  intDStopLossLevel;
          _extTakeProfitLevel    =  intDTakeProfitLevel;
          //_extTrailingTriggerLevel = intDTrailingTriggerLevel;
//#ifndef _NO_PRINTOUT_            
//          // 07222025 Print("GetSychFileVals:");
//          // 07222025 Print("_FileName: " + _FaileName);
//          
//          // 07222025 Print("Line1_Val1: " + Line1_Val1);
//          //// 07222025 Print("Line1_Val2: " + Line1_Val2);
//          // 07222025 Print("intPriceTargetLevel: " + DoubleToString(intDPriceTargetLevel));
//          
//          // 07222025 Print("Line2_Val1: " + Line2_Val1);
//          //// 07222025 Print("Line2_Val2: " + Line2_Val2);
//          // 07222025 Print("intStopLossLevel: " + DoubleToString(intDStopLossLevel));
//
//          
//          // 07222025 Print("Line3_Val1: " + Line3_Val1);
//          //// 07222025 Print("Line3_Val2: " + Line3_Val2);
//          // 07222025 Print("intTakeProfitLevel: " + DoubleToString(intDTakeProfitLevel));
//          
//          //// 07222025 Print("Line4_Val1: " + Line4_Val1);
//          ////// 07222025 Print("Line3_Val2: " + Line3_Val2);
//          //// 07222025 Print("intDTrailingTriggerLevel: " + DoubleToString(intDTrailingTriggerLevel));
//         
//          // 07222025 Print("String Value Converted OK");
//#endif
                    
         // Delete the _Local.Csv
         ResetLastError();
         
         uint SuspendCounter = 0;
         uint MiliTimeDelayBeforeCancel = 10 * 1000;
         uint thisTickValue = GetTickCount();
         
         while((FileIsExist(_FaileName, FILE_READ)) && 
         (GetTickCount() - thisTickValue <= MiliTimeDelayBeforeCancel))
         {
            FileDelete(_FaileName);
            
            Sleep(SuspendThread2_TimePeriod);
            SuspendCounter++;
            
            //getThisTick = GetTickCount() - thisTickValue;
         }
#ifndef _NO_PRINTOUT_           
         // 07222025 Print("File Deleted after " + IntegerToString(SuspendCounter) + " times trying..." );
         //FileDelete(_FaileName);
         
         // 07222025 Print("FileDelete Error: " + IntegerToString(GetLastError()));
#endif          
          return true;
     }
     else 
     {
#ifndef _NO_PRINTOUT_       
         // 07222025 Print("Operation FileOpen for READ failed, error ", GetLastError());
#endif         
         return false;
     }
}


// ========================================================================


bool  CalcCounterLevels(int _MarketOrderType,
                        double _PriceTargetLevel,
                        double _StopLossLevel,
                        double _ext_TakeProfitLevel,
                        //double _ext_TrailingTriggerLevel,
                        double &_counterPriceTarget,
                        double &_counterStopLossPips,
                        double &_counterTakeProfitPips
                        //,double &_counterTrailingTriggerPips
                        )
{

double counterPriceTarget = 0;

#ifndef _NO_PRINTOUT_ 
   // 07222025 Print("Entry Levels...");
   // 07222025 Print("_PriceTargetLevel: " + DoubleToString(_PriceTargetLevel));
   // 07222025 Print("_StopLossLevel: " + DoubleToString(_StopLossLevel));
   // 07222025 Print("_ext_TakeProfitLevel: " + DoubleToString(_ext_TakeProfitLevel));
#endif    

   counterPriceTarget = _StopLossLevel;
   
   if(_MarketOrderType == 1)   
   {
      // Curr position is LONG - calculate SHORT
      // Calculate SELL_STOP
      _counterPriceTarget     =  _StopLossLevel;
      
      //_counterStopLossPips   =  (_PriceTargetLevel - _StopLossLevel) /Point;
      //_counterTakeProfitPips =  (counterPriceTarget - _ext_TakeProfitLevel) / Point;
      
      // 2022.12.23
      _counterStopLossPips   =  AccuDiff_ToFracNum(_PriceTargetLevel, _StopLossLevel)/Point;
      
//      if(CalcbyTakeProfit)
//         
//            else if(CalcRPbyTrigOrTailLevel)
//               
//            else
               
      
      _counterTakeProfitPips =  AccuDiff_ToFracNum(counterPriceTarget, _ext_TakeProfitLevel) /Point;
      
      //_counterTrailingTriggerPips =  (_counterPriceTarget - _ext_TrailingTriggerLevel) / Point;
   }
   else
   {
      // Curr position is SHORT - calculate LONG
      // Calculate BUY_STOP
      _counterPriceTarget     =  _StopLossLevel;
      
      //_counterStopLossPips   =  (_StopLossLevel - _PriceTargetLevel) /Point;
      //_counterTakeProfitPips =  (_ext_TakeProfitLevel - counterPriceTarget) / Point;
      
      // 2022.12.23
       _counterStopLossPips   =  AccuDiff_ToFracNum(_StopLossLevel, _PriceTargetLevel) /Point;
       _counterTakeProfitPips =  AccuDiff_ToFracNum(_ext_TakeProfitLevel, counterPriceTarget) /Point;
      
      //_counterTrailingTriggerPips =  (_ext_TrailingTriggerLevel - _counterPriceTarget) / Point;
   }
   
   if(_counterTakeProfitPips < _counterStopLossPips)
   {
      _counterTakeProfitPips = _counterStopLossPips;
      // 07222025 Print("TP Pips ADJUSTED!!!");
   }
   
#ifndef _NO_PRINTOUT_    
   // 07222025 Print("Calculated Levels...");
   // 07222025 Print("====================");
   // 07222025 Print("counterPriceTarget: " + DoubleToString(_counterPriceTarget));
   // 07222025 Print("counterStopLossPips: " + DoubleToString(_counterStopLossPips));
   // 07222025 Print("counterTakeProfitPips: " + DoubleToString(_counterTakeProfitPips));
   //// 07222025 Print("counterTrailingTriggerPips: " + DoubleToString(_counterTrailingTriggerPips));
#endif
   
   if((_counterStopLossPips <= 0) || (_counterTakeProfitPips <= 0))
         return false;
   else
      return true;
      
}


// ========================================================================



bool UpdateCounterBotTemplate(int    _MarketOrderType,
                              string _LaunchTemplateFileName,
                              double _counterPriceTarget,
                              double _counterStopLossPips,
                              double _counterTakeProfitPips
                              //,double _counterTrailingTriggerPips
                              )
{
   
   //  Check if appropriate templete is specified...   
   if(_MarketOrderType == 2)   
   {
      // LONG
      if(StringFind(_LaunchTemplateFileName, "LONG") < 0)
      {
         // 07222025 Print("Missing LONG inside Template File Name...");
         return false;
      }
   }
   else
   {
      // SHORT
      if(StringFind(_LaunchTemplateFileName, "SHORT") < 0)
      {
         // 07222025 Print("Missing SHORT inside Template File Name...");
         return false;
      }
   }
   
   // Check if template contains proper position direction
   CString cStr;
   string nStr;
   string FullTemplateFileName = TerminalInfoString(TERMINAL_DATA_PATH);
   FullTemplateFileName = FullTemplateFileName + "\\templates\\" + _LaunchTemplateFileName;
   
   ResetLastError();
    
   int file_handle = FileOpen(_LaunchTemplateFileName,FILE_TXT|FILE_READ|FILE_ANSI);
     
   //  Read in entire TEXT file line per line until End of File  
   if(file_handle != INVALID_HANDLE) 
     { 
      //FileWrite(file_handle, TimeCurrent(), Symbol(), Period() ); 
      
      while(!FileIsEnding(file_handle)) 
      { 
         
         nStr = FileReadString(file_handle);
         cStr.Append(nStr + "\r\n");
         //cStr.Copy(nStr2);
         //// 07222025 Print(nStr2);    
      }
      
      FileClose(file_handle); 
#ifndef _NO_PRINTOUT_       
      // 07222025 Print("FileOpen OK"); 
#endif      
     } 
   else 
   {
      // 07222025 Print("Operation FileOpen READ failed, error ", GetLastError());
      return false;
   }
   
   
   // Search & Retreave...
   // Find Section Opening Tag to narrow search for Tag
   // ====================================================

   string sTag1 = "ZennerGUN";
 
   //  Find the Section Tag that you seek
   int idx = cStr.Find(0, sTag1);
   
      
   uint iRes1 = FindAndReplaceValue(cStr, idx, "MainPriceTarget", _counterPriceTarget);
   uint iRes2 = FindAndReplaceValue(cStr, idx, "StopLossPIPS", _counterStopLossPips);
   
   uint iRes3;    //  Updated 4/12/2025 
   
   bool slaveCalcbyTakeProfit = FindBoolValue(cStr, idx, "CalcbyTakeProfit");                         //  -> Updated 6/11/2025
   // 07222025 Print("slaveCalcbyTakeProfit: " + IntegerToString(slaveCalcbyTakeProfit));
   
   bool slaveCalcRPbyTrigOrTailLevel = FindBoolValue(cStr, idx, "CalcRPbyTrigOrTailLevel");
   // 07222025 Print("slaveCalcRPbyTrigOrTailLevel: " + IntegerToString(slaveCalcRPbyTrigOrTailLevel));
   
   
   if(slaveCalcbyTakeProfit)
      iRes3 = FindAndReplaceValue(cStr, idx, "TakeProfitPIPS", _counterTakeProfitPips);
   else if(slaveCalcRPbyTrigOrTailLevel)
      iRes3 = FindAndReplaceValue(cStr, idx, "TrailingTriggerPIPS", _counterTakeProfitPips);
   else
      iRes3 = FindAndReplaceValue(cStr, idx, "TrailingTailPIPS", _counterTakeProfitPips);
   
   
   //uint iRes4 = FindAndReplaceValue(cStr, idx, "TrailingTriggerPIPS", _counterTrailingTriggerPips);
   
   
   ResetLastError();
   
   //  Store the UPDATED value into the TEXT file
   file_handle = FileOpen(_LaunchTemplateFileName,FILE_TXT|FILE_WRITE|FILE_ANSI);
   
   string sBuff;
   cStr.Copy(sBuff);  
   
   if(file_handle != INVALID_HANDLE) 
     { 
      //FileWrite(file_handle, TimeCurrent(), Symbol(), Period() ); 
      
      FileWriteString(file_handle, sBuff);
     
      FileClose(file_handle); 
#ifndef _NO_PRINTOUT_       
      // 07222025 Print("File Writen OK"); 
#endif       
      
     } 
   else 
   {
      // 07222025 Print("Operation FileOpen WRITE failed, error ", GetLastError()); 
      return false;
   }
   
   
   
   // Copy _Local.Csv to Destination folder renaming it to .Csv ONLY
#ifndef _NO_PRINTOUT_    
   // 07222025 Print("Copy file to Template Dir...");
#endif

   string InternalPathSource =  "\\MQL4\\Files\\";   // Internal Path
   string InternalPathDestination =  "\\templates\\";   // Internal Path
   
   string mainLocalPath = TerminalInfoString(TERMINAL_DATA_PATH) + InternalPathSource;
   string mainDestPath  = TerminalInfoString(TERMINAL_DATA_PATH) + InternalPathDestination;
   
   string FullSourceFileName      = mainLocalPath + _LaunchTemplateFileName;
   string FullDestinationFileName = mainDestPath  + _LaunchTemplateFileName;
   
   
   ResetLastError();
   
   int bResCopyFile = CopyFileW(FullSourceFileName,      //  Existing File
                                FullDestinationFileName, //  New File destination
                                false  );                //  TRUE - Do NOT overwrite new file
                                                         //  FALSE - Overwrite new file
#ifndef _NO_PRINTOUT_                                                 
   // 07222025 Print("UpdateCounterBotTemplate - bResCopyFile: " + IntegerToString(bResCopyFile));  
   // 07222025 Print("UpdateCounterBotTemplate - CopyFileW Error: " + IntegerToString(GetLastError()));
#endif 
   
   return true;
}



// ========================================================================



uint FindAndReplaceValue(CString &_cStr, uint fromPos, string TagName, double NewValue)
{

   string sEndOfLine = "\r\n";
    
   // Find the Name of the parameter you seek
   int idxBegin = _cStr.Find(fromPos, TagName); 
   
   // Find the End of Line for that ROW
   int idxEnd = _cStr.Find(idxBegin, sEndOfLine); 
   int lBuffLen = idxEnd - idxBegin;
   
   //  Extract the full ROW that is to be EDITED 
   string sContent = _cStr.Mid(idxBegin, lBuffLen);
   
  
   //cStr.Insert(idx + l_sTag1 - 1, sTag2);
   //cStr.Replace(sTag1, sTag3);
   
   string sep="=";                // A separator as a character 
   ushort u_sep;                  // The code of the separator character 
   string result[];               // An array to get strings 
   
   // Split the ROW into two parts - Name and Value - result[0] is Name and result[1] is Value
   u_sep = StringGetCharacter(sep, 0); 
   int k = StringSplit(sContent, u_sep, result);
   
   // Assign New integer value to be replaced in the file
   string sNewValue;
   //  Convert it to string value
   sNewValue = DoubleToString(NewValue);
   
   //Update New Value in the array
   result[1] = sNewValue;
   
   // Create New Replacment string including New Value in it
   string sNewContentBuff = StringConcatenate(result[0], sep, result[1]);
   
   // Make sought string unique by encapsulating it in braces
   _cStr.Insert(idxBegin, "{");
   _cStr.Insert(idxEnd + 1, "}");
   
   // Create the the string to be saught
   string sSearchTarget = "{" + sContent + "}";
   
   // Do the Replacement
   uint numReplaced = _cStr.Replace(sSearchTarget, sNewContentBuff);


   return numReplaced;
}


// ========================================================================


bool FindBoolValue(CString &_cStr, uint fromPos, string TagName)
{

   string sEndOfLine = "\r\n";
    
   // Find the Name of the parameter you seek
   int idxBegin = _cStr.Find(fromPos, TagName); 
   
   // Find the End of Line for that ROW
   int idxEnd = _cStr.Find(idxBegin, sEndOfLine); 
   int lBuffLen = idxEnd - idxBegin;
   
   //  Extract the full ROW that is to be EDITED 
   string sContent = _cStr.Mid(idxBegin, lBuffLen);
   
  
   //cStr.Insert(idx + l_sTag1 - 1, sTag2);
   //cStr.Replace(sTag1, sTag3);
   
   string sep="=";                // A separator as a character 
   ushort u_sep;                  // The code of the separator character 
   string result[];               // An array to get strings 
   
   // Split the ROW into two parts - Name and Value - result[0] is Name and result[1] is Value
   u_sep = StringGetCharacter(sep, 0); 
   int k = StringSplit(sContent, u_sep, result);
   

   
   return ((result[1] == "true") ? true : false);
}


// ========================================================================


bool ApplyChartTemplate(string _LaunchTemplateFileName)
{
   long hWndFirstChart  = ChartFirst();
   long hWndSecondChart = ChartNext(hWndFirstChart);
   
   //int hWnd = GetWindowHandle(hWndSecondChart);
   //// 07222025 Print("ApplyChartTemplate - GetWindowHandle: " + IntegerToString(hWnd));
   
   
   
   
   //  Wait:  The command is added to chart message queue and executed only after all previous commands have been processed.
   //  
   
//#define  _Try_2_
//   
//#ifdef   _Try_1_   
//   Sleep(5000);
//#endif 
//
//#ifdef   _Try_2_
//   #define  PM_NOREMOVE 0x0000
//
//   int j=0; 
//   bool bRes;
//   
//   do{
//       Sleep(150);
//       bRes = PeekMessageA(NULL, hWnd, 0, 0, PM_NOREMOVE);
//       j++;   
//   } while(!(bRes == 0));
//   
//   // 07222025 Print("Counter j: " + IntegerToString(j));
//   
//#endif


   // 07222025 Print("<<< ChartApplyTemplate>>>");
   // 07222025 Print("LaunchTemplateFileName: " + _LaunchTemplateFileName);
   
   int SuspendCounter = 0;
   bool ChartApplyRes = 0;
   
   while (True)   
   {   
      ResetLastError();
      ChartApplyRes = ChartApplyTemplate(hWndSecondChart, _LaunchTemplateFileName );   // "Launch_2.1_SHORT_SELLSTOP.tpl"
      //Sleep(200);
      
      
         
      //if(!ChartApplyRes) 
      //{
         // 07222025 Print("ChartApplyRes: " + IntegerToString(ChartApplyRes));
         // 07222025 Print("ChartApplyTemplate Error: " + IntegerToString(GetLastError()) + " - Template Applied: " + _LaunchTemplateFileName);
      //}
      
      if(ChartApplyRes != 0)
         break;
         
      Sleep(SuspendThread2_TimePeriod);
      
      if(SuspendCounter++ > 35) 
         break;
         
   }
         // 07222025 Print("ApplyChartTemplate LAST - ChartApplyRes: " + IntegerToString(ChartApplyRes));
         // 07222025 Print("ApplyChartTemplate LAST - ChartApplyTemplate Error: " + IntegerToString(GetLastError()));
         // 07222025 Print("SuspendCounter: " + IntegerToString(SuspendCounter));
      
      return ChartApplyRes;
      
   }   


// ========================================================================


void CloseNavigatorPopUpWindow()
{
   hProcThis = GetCurrentProcessId();
   FindWindowByProcessIdAndClassName(NULL, 1);

}

//void CloseNavigatorPopUpWindowOLD()
//{
//   
//   // 07222025 Print("CloseNavigatorPopUpWindow...");
//
////   if(!GlobalValEXIST(_GV_NAVIGATOR_PANNEL))
////   {
////      // 07222025 Print("Navigator Visible... DELETING!!!");
////      GlobalValSet(_GV_NAVIGATOR_PANNEL, 1);
////   }
////   else
////   {
////      // 07222025 Print("No Navigator Visible...  EXITING!!!");
////      GlobalValDel(_GV_NAVIGATOR_PANNEL);
////      
////      return;
////   }
//   
//   int    ClassNameLen  = StringLen(sClassName);
//   int    TitleLen      = StringLen(sTitle);
//
//   char dynClassName[];
//   char dynTitle[];
//
//   ArrayResize(dynClassName, ClassNameLen + 1);
//   ArrayResize(dynTitle, TitleLen + 1);
//
//   for(int i = 0; i < ClassNameLen; i++)
//      dynClassName[i] = (char) sClassName[i];
//   dynClassName[ClassNameLen] = 0;
//
//
//   for(int i = 0; i < TitleLen; i++)
//      dynTitle[i] = (char) sTitle[i];
//   dynTitle[TitleLen] = 0;
//
//
//   int hWndDesktop = 0;
//   int hWnd = 0;
//   int hProcThis = 0;
//   int hProcWindow = 0;
//
//   hProcThis = GetCurrentProcessId();
//   hWndDesktop = GetDesktopWindow();
//   
//   // 07222025 Print("GetCurrentProcessId: " + StringFormat("%08X", hProcThis));
//   // 07222025 Print("GetDesktopWindow: " + StringFormat("%08x", hWndDesktop));
//   
//   do
//     {
//      Sleep(150);
//      hWnd = FindWindowExA(hWndDesktop, hWnd, dynClassName, dynTitle);
//      // 07222025 Print("FindWindowExA: " + StringFormat("%08X", hWnd));
//      GetWindowThreadProcessId(hWnd, hProcWindow);
//      // 07222025 Print("GetWindowThreadProcessId: " + StringFormat("%08X", hProcWindow));
//     }
//   while((hProcWindow != hProcThis) || (hWnd == 0));
//
//   if(hWnd != 0)
//   {
//      // 07222025 Print("Navigator Window found: " + StringFormat("%08X", hWnd));
//      int RetVal = SendMessageA(hWnd, WM_CLOSE, 0, 0);
//   }
//   else
//      // 07222025 Print("Navigator Window NOT found... ");
//   
//}


// ========================================================================


//bool RemoveNavigatorPopUp() 
//{
//   // 07222025 Print("RemoveNavigatorPopUp...");
//
//   if(!GlobalValEXIST(_GV_NAVIGATOR_PANNEL))
//   {
//      // 07222025 Print("Navigator Visible... DELETING!!!");
//      GlobalValSet(_GV_NAVIGATOR_PANNEL, 1);
//   }
//   else
//   {
//      // 07222025 Print("No Navigator Visible...  EXITING!!!");
//      GlobalValDel(_GV_NAVIGATOR_PANNEL);
//      
//      return(true);
//   }
//   
//   char WndTitle[256];
//   string sTitle = "";
//   
//   int hWinForground = GetForegroundWindow();
//   if(hWinForground > 0)
//      GetWindowTextA(hWinForground, WndTitle, sizeof(WndTitle));
//   else
//   {
//      // 07222025 Print("Can't aquire handel to ForeGround Window...");
//      return(false);
//   }
//   
//   uint i = 0;
//   do{
//      StringAdd(sTitle, CharToString(WndTitle[i]));
//      i++;
//   } while(WndTitle[i] != 0);
//   
//   // 07222025 Print("Foreground Title: " + sTitle);
//   
//   
//   if(StringFind(sTitle, "Navigator") >= 0)
//   {
//      // 07222025 Print(IntegerToString(hWinForground) + " - Navigator in Foreground...  Closing!!!");
//      if(Window_Close(hWinForground) != 0)
//         // 07222025 Print("Can't Process WM_CLOSE message...");
//   }
//   else if(StringFind(sTitle, "157808") >= 0)
//   {
//      int hWinCurrentTop = GetParent(GetParent(GetWindowHandle(ChartFirst())));
//      
//      // 07222025 Print("hWinCurrentTop: " + IntegerToString(hWinCurrentTop));
//      // 07222025 Print("hWinForground: " + IntegerToString(hWinForground));
//      
//      if(hWinForground == hWinCurrentTop)
//      {
//         // 07222025 Print("Remove Navigator First...");
//         
//         keybd_event(17, 0, 0, 0); // CTRL down
//         keybd_event(78, 0, 0, 0); // N down
//         keybd_event(78, 0, 2, 0); // N up
//         keybd_event(17, 0, 2, 0); // CTRL up
//
//      } 
//   }
//   
//   
//   //if(hWinForground > 0)
//   //{
//   //   if(Window_Close(hWinForground) != 0)
//   //      // 07222025 Print("Can't Process WM_CLOSE message...");
//   //}
//   //else
//   //   // 07222025 Print("Can't GET Foreground Window...");
//      
////   Get the Win handel to the current window
////   int hWnd = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE, 0);
//   
////   Activate it and set the focus to it
////   ChartSetInteger(0, CHART_BRING_TO_TOP, true);
//
//   //keybd_event(17, 0, 0, 0); // CTRL down
//   //keybd_event(78, 0, 0, 0); // N down
//   //keybd_event(78, 0, 2, 0); // N up
//   //keybd_event(17, 0, 2, 0); // CTRL up
//   
////   WindowRedraw();
////   
//   //Sleep(150);
//   
//   return;
//}


//// ========================================================================
//
//
//void Window_activate(int hwnd) 
//{
//   int p = GetParent(hwnd);
//   SendMessageA(GetParent(p), WM_MDIACTIVATE, p, 0);
//}
//
//
//// ========================================================================
//
//
//void Window_maximize(int hwnd) 
//{
//   int p = GetParent(hwnd);
//   SendMessageA(GetParent(p), WM_MDIMAXIMIZE, p, 0);
//}
//
//
//// ========================================================================
//
//
//int Window_getHandle(string symbol) 
//{
//   int i, hwnd = 0;
//   for (i=0; i<ArraySize(periods); i++) {
//      hwnd = WindowHandle(symbol, periods[i]);
//      if (hwnd != 0) break;
//   }
//   return (hwnd);
//}
//
//
//// ========================================================================
//
//
////+----------------------------------------------------------------------+
////| Send command to the terminal to display the chart above all others.  |
////+----------------------------------------------------------------------+
//bool ChartBringToTop(const long chart_ID=0)
//  {
////--- reset the error value
//   ResetLastError();
////--- show the chart on top of all others
//   if(!ChartSetInteger(chart_ID,CHART_BRING_TO_TOP,0,true))
//     {
//      //--- display the error message in Experts journal
//      // 07222025 Print(__FUNCTION__+", Error Code = ",GetLastError());
//      return(false);
//     }
////--- successful execution
//   return(true);
//  }
  
  
int GetWindowHandle(const long chart_ID=0) 
  { 

   long result=-1; 

   ResetLastError(); 

   if(!ChartGetInteger(chart_ID,CHART_WINDOW_HANDLE,0,result)) 
     { 
      // 07222025 Print(__FUNCTION__+", Error Code = ",GetLastError()); 
     } 

   //return(GetParent((int)result)); 
   return((int)result); 
  }
  
  
// =====================================================================================


void Window_Activate(int hwnd) 
{
   int p = GetParent(hwnd);
   SendMessageA(GetParent(p), WM_MDIACTIVATE, p, 0);
   //SendMessageA(GetParent(hwnd), WM_MDIACTIVATE, hwnd, 0);
}


// =====================================================================================
//
//
//int Window_GetActive(int hwnd) 
//{
//   //int p = GetParent(hwnd);
//   //int hwnd=(int)ChartGetInteger(ChartFirst(),CHART_WINDOW_HANDLE);
//   
//   //int RetVal = SendMessageA(GetParent(p), WM_MDIGETACTIVE, 0, 0);
//   int RetVal = SendMessageA(GetParent(hwnd), WM_MDIGETACTIVE, 0, 0);
//   
//   return(RetVal);
//}
//
//
//// =====================================================================================  
//
//
//int Window_Close(int hwnd) 
//{
//   //int p = GetParent(hwnd);
//   //SendMessageA(GetParent(p), WM_MDIACTIVATE, p, 0);
//   int RetVal = SendMessageA(hwnd, WM_CLOSE, 0, 0);
//   
//   return(RetVal);
//}
//
//  

// ============================================================================


void FindWindowByProcessIdAndClassName(int hCurWnd, int cnt)
{

   static bool bExit = false;
   
   if(bExit)
      return;
      
   char ClassNameBuff[256];
   char TitleBuff[256];
   string sClassName = "";
   string sTitle = "";
   
   //// 07222025 Print("New Branch...");
	hCurWnd = GetTopWindow(hCurWnd);
		
	while (hCurWnd != NULL)
	{
		int cur_pid = 0;
		int dwTheardId = GetWindowThreadProcessId(hCurWnd, cur_pid);
				
		if (cur_pid == hProcThis)
		{
			if (IsWindowVisible(hCurWnd) != 0)
			{
				ClassNameBuff[0] = 0;
            int ResClassName = GetClassNameA(hCurWnd, ClassNameBuff, 256);
            
            if(ResClassName > 0)
            {
               uint i = 0;
               sClassName = "";
               do{
                  StringAdd(sClassName, CharToString(ClassNameBuff[i]));
                  i++;
               } 
               while(ClassNameBuff[i] != 0);
            }
            
            TitleBuff[0] = 0;
            int ResWindowText = GetWindowTextA(hCurWnd, TitleBuff, 256);
            if(ResWindowText > 0)
            {
               uint i = 0;
               sTitle = "";
               do{
                  StringAdd(sTitle, CharToString(TitleBuff[i]));
                  i++;
               } while(TitleBuff[i] != 0);
            }
				
				
				if(sTitle == "Navigator")
				{
               // 07222025 Print("Level: " + IntegerToString(cnt) + ". hCurWnd: " + StringFormat("%08X", hCurWnd) + " Process: " + StringFormat("%08X", hProcThis) + " ClassName: " + sClassName + " Title: " + sTitle);
               
                  //// 07222025 Print("Navigator Window found: " + StringFormat("%08X", hWndFound));
                  bExit = true;     //  EXIT right away...
                  
                  //int RetVal = SendMessageA(hCurWnd, WM_CLOSE, 0, 0);
                  
                  int RetVal = PostMessageA(hCurWnd, WM_CLOSE, 0, 0);
                  
                  //int RetVal = PostMessageA(hCurWnd, WM_DESTROY, 0, 0);
                  
                  
                  
                  //int Ress = DestroyWindow(hCurWnd);
                  
                  //// 07222025 Print("RetVal: " + RetVal);
            }
            //else
            //   // 07222025 Print(IntegerToString(cnt) + ". hCurWnd: " + StringFormat("%08X", hCurWnd) + " Process: " + StringFormat("%08X", hProcThis) + " ClassName: " + sClassName + " Title: " + sTitle);
               
               
				//if (_tcscmp(szClassName,szWndClassName)==0)
				//	return hCurWnd;
			}
		}
		
		FindWindowByProcessIdAndClassName(hCurWnd, cnt + 1);
		_cnt++;
      if(bExit)
         return;
      
		hCurWnd = GetWindow(hCurWnd, GW_HWNDNEXT);
	}
   
   //// 07222025 Print("Total iterations: " + IntegerToString(_cnt));
   
   return;
   
}



void SynchWithReciprocalSide(int    _MarketOrderType,
                             string _DestinationInstance)
{
   
   // 07222025 Print("<<< Deleting Garbage... >>>");
   
   string   file_name;      // variable for storing file names 
   string   filter="*.*"; // filter for searching the files 
   string   files[];        // list of file names 
   int      def_size=25;    // array size by default 
   int      size=0;         // number of files 


   ArrayResize(files, def_size); 

    
   long search_handle = FileFindFirst(filter, file_name); 

   if(search_handle != INVALID_HANDLE) 
     { 

      do 
      { 
         ResetLastError();
         FileIsExist(file_name);
         if(!(GetLastError() == ERR_FILE_IS_DIRECTORY))
         {
            files[size] = file_name; 
            size++; 
         }
      } 
      while(FileFindNext(search_handle, file_name)); 

      FileFindClose(search_handle); 
      // 07222025 Print("Junk Files Found: " + IntegerToString(size));
     } 
   else 
     { 
      // 07222025 Print("INVALID_HANDLE!"); 
      return; 
     } 
     
   ResetLastError(); 
    
   for(int i=0; i<size; i++) 
     { 
      if(FileIsExist(files[i])) 
      {
         PrintFormat("Junk: Deleting %s File!", files[i]); 
         FileDelete(files[i]); 
      }
      else
         PrintFormat("Not Junk a File!"); 
     } 
      
#ifndef _NO_PRINTOUT_       
   // 07222025 Print("<<< Synching with Counter Side... >>>");
#endif 
   
   SeekSynchSignal(_MarketOrderType, _DestinationInstance);
   
   return;
         
}


void UpdateSourceTemplateWithLastDevelopments()
{

//#ifndef _NO_PRINTOUT_    
   // 07222025 Print("Copy file to SOURCE Template Dir...");
//#endif

   string InternalPathDestination =  "\\MQL4\\Files\\";   // Internal Path
   string InternalPathSource =  "\\templates\\";   // Internal Path
   
   string mainLocalPath = TerminalInfoString(TERMINAL_DATA_PATH) + InternalPathSource;
   string mainDestPath  = TerminalInfoString(TERMINAL_DATA_PATH) + InternalPathDestination;
   
   string FullSourceFileName      = mainLocalPath + LaunchTemplateFileName + ".tpl";
   string FullDestinationFileName = mainDestPath  + LaunchTemplateFileName + ".tpl";
   
   
   ResetLastError();
   
   // 07222025 Print("FullSourceFileName: " + FullSourceFileName);
   // 07222025 Print("FullDestinationFileName: " + FullDestinationFileName);
   
   int bResCopyFile = CopyFileW(FullSourceFileName,      //  Existing File
                                FullDestinationFileName, //  New File destination
                                false  );                //  TRUE - Do NOT overwrite new file
                                                         //  FALSE - Overwrite new file
//#ifndef _NO_PRINTOUT_                                                 
   // 07222025 Print("UpdateSourceTemplateWithLastDevelopments - bResCopyFile: " + IntegerToString(bResCopyFile));  
   // 07222025 Print("UpdateSourceTemplateWithLastDevelopments - CopyFileW Error: " + IntegerToString(GetLastError()));
//#endif 

}