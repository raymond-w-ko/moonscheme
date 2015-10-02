@echo off
SET LUA=.\lua.exe
cls
pushd "%~dp0"
%LUA% tests/run_tests.lua
popd
