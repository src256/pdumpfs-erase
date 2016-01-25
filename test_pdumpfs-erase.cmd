@echo off
cd /d %~dp0
call uru 223p173
ruby --version
ruby test_pdumpfs-erase.rb
