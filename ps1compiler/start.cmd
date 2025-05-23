@echo off
Powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass', '-File .\bin\ui\menu.ps1' -NoNewWindow"