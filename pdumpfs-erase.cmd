@echo off
cd /d %~dp0
call uru 223p173
ruby pdumpfs-erase.rb %*
