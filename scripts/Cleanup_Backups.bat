@echo off

:: define the "\name" of a shared folder on the remote "\\device"
:: -d -30 means that files, older than 30 days will be deleted
PushD "%1" &&(
  forfiles -s -m *.* -d -%2 -c "cmd /c del @file" 
 ) & PopD
