@echo off
cd /d %~dp0
call uru 221p85
ruby pdumpfs-erase.rb %*

