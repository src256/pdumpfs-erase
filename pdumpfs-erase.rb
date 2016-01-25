#!/usr/bin/ruby
#
# pdumpfs-erase: erase old backup directory for pdumpfs
#
# Usage:
# pdumpfs-erase <pdumpfs backuped directories...>
#
# Copyright(C) 2014 src <src@srcw.net>, All rights reserved.
# This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms of 
# the GNU General Public License version 2.
#

require 'optparse'
require 'date'

VERSION = '1.0.0'

class PdumpfsEraserOption
  def self.parse(argv)
    option = PdumpfsEraserOption.new
    parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{opt.program_name} [OPTIONS] directories"
      opt.on_head('-h', '--help', 'Show this message') do |v|
        puts opt.help
        exit
      end
      opt.on_head('-v', '--version', 'Show program version') do |v|
        opt.version = VERSION
        puts opt.ver
        exit
      end
      opt.on('-n', '--no-act', 'run command but do not do it') do |v|
        option.no_act = true
      end
      opt.on('-k KEEPARGS', '--keep=KEEPARGS', 'ex: --keep 2Y6M6W7D (2years, 6months, 6weeks, 7days, default)') do |v|
        option.keep_year = $1.to_i if v=~ /(\d+)Y/
        option.keep_month = $1.to_i if v=~ /(\d+)M/
        option.keep_week = $1.to_i if v=~ /(\d+)W/
        option.keep_day = $1.to_i if v=~ /(\d+)D/
      end
      opt.on('-e ERASEDIR', '--erase=ERASEARGS', 'ex: --erase=temp,home\tom,') do |v|
        p v
        option.erase_dirs = v.split(/,/)
      end
    end
    parser.order!
    if argv.empty?
      puts parser.help
      exit
    end
#    p option
    option.target_dirs = argv
    option
  end
  
  def initialize
    @no_act = false    
    @keep_year = 2
    @keep_month = 6
    @keep_week = 6
    @keep_day = 7
    @target_dirs = []
    @today = Date.today
    @erase_dirs = []
  end
  
  attr_accessor :no_act, :keep_year, :keep_month, :keep_week, :keep_day, :erase_dirs, :target_dirs
  
  def detect_keep_dirs(backup_dirs)
    detect_year_keep_dirs(backup_dirs)
    detect_month_keep_dirs(backup_dirs)
    detect_week_keep_dirs(backup_dirs)
    detect_day_keep_dirs(backup_dirs)
  end
  
  private
  def keep_dirs(backup_dirs, num)
    num.downto(0) do |i|
      from_date, to_date = yield(i)
      dirs = BackupDir.find(backup_dirs, from_date, to_date)
      dirs[0].keep = true if dirs.size > 0
    end
  end
  
  def detect_year_keep_dirs(backup_dirs)
    keep_dirs(backup_dirs, @keep_year) do |i|
      from_date = Date.new(@today.year - i, 1, 1)
      to_date = Date.new(@today.year - i, 12, 31)
      [from_date, to_date]
    end
  end
  
  def detect_month_keep_dirs(backup_dirs)
    keep_dirs(backup_dirs, @keep_month) do |i|
      base_date = @today <<  i
      from_date = Date.new(base_date.year, base_date.month, 1)
      to_date = from_date >> 1
      [from_date, to_date]
    end
  end
  
  def detect_week_keep_dirs(backup_dirs)
    keep_dirs(backup_dirs, @keep_week) do |i|
      base_date = @today  - 7 * i
      from_date = base_date - base_date.cwday # 1
      to_date = from_date + 6
      [from_date, to_date]
    end
  end
  
  def detect_day_keep_dirs(backup_dirs)
    keep_dirs(backup_dirs, @keep_day) do |i|
      base_date = @today - i
      from_date = base_date
      to_date = base_date
      [from_date, to_date]
    end
  end  
end

class BackupDir
  def self.find(backup_dirs, from_date, to_date)
    backup_dirs.select{|backup_dir| backup_dir.date >= from_date && backup_dir.date <= to_date}
  end
  
  def initialize
    @keep = false
  end
  attr_accessor :path, :date, :keep
end

class PdumpfsEraser
  def initialize(option)
    @option = option
  end

  def erase
    @option.target_dirs.each do |target_dir|
      if @option.erase_dirs.size > 0
        erase_target_dir(target_dir)
      else
        expire_target_dir(target_dir)
      end
    end
  end
  
  private
  def scan_backup_dirs(target_dir)
    backup_dirs = []
    Dir.glob("#{target_dir}/[0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9]").sort.each do |path|
      if  File.directory?(path) && path =~ /(\d\d\d\d)\/(\d\d)\/(\d\d)/
#        puts "Backup dir: #{path}"
        backup_dir = BackupDir.new
        backup_dir.path = path
        backup_dir.date = Date.new($1.to_i, $2.to_i, $3.to_i)
        backup_dirs << backup_dir
      end
    end
    backup_dirs
  end
  
  def to_win_path(path)
    path.gsub(/\//, '\\')
  end
  
  def to_unix_path(path)
    path.gsub(/\\/, '/')
  end
  
  def expire_target_dir(target_dir)
    
    target_dir = to_unix_path(target_dir)
    puts "<<<<< Target dir: #{target_dir} >>>>>"
    
    backup_dirs = scan_backup_dirs(target_dir)
    @option.detect_keep_dirs(backup_dirs)
    backup_dirs.each do |backup_dir|
      next if backup_dir.keep
      
      t_start = Time.now
      print "Deleting #{backup_dir.path} ..."
      win_backup_path = to_win_path(backup_dir.path)
      unless @option.no_act
        #http://superuser.com/questions/19762/mass-deleting-files-in-windows/289399#289399
        
        ##### here
        
        print " pass1"
        system("del /F /S /Q #{win_backup_path} > nul")
        print " pass2"
        
        ##### here
        
        system("rmdir /S /Q #{win_backup_path}")
      end
      t_end = Time.now
      diff = (t_end - t_start).to_i
      diff_hours = diff / 3600
      puts " done[#{diff} seconds = #{diff_hours} hours]."
    end

    Dir.glob("#{target_dir}/[0-9][0-9][0-9][0-9]/[0-1][0-9]\0#{target_dir}/[0-9][0-9][0-9][0-9]").each do |dir|
      if File.directory?(dir) && Dir.entries(dir).size <= 2
        win_dir = to_win_path(dir)
        print "Deleting #{win_dir} ..."
        Dir.rmdir(win_dir)  unless @option.no_act
        puts " done."
      end
    end
    
    puts "Keep dirs:"
    backup_dirs.each do |dir|
      puts dir.path if dir.keep
    end        
  end
  
  def erase_target_dir(target_dir)
    target_dir = to_unix_path(target_dir)
    puts "<<<<< Target dir: #{target_dir} >>>>>"
    
    backup_dirs = scan_backup_dirs(target_dir)
    backup_dirs.each do |backup_dir|
      @option.erase_dirs.each do |erase_dir|
        erase_path = backup_dir.path + '/' + erase_dir
        if FileTest.exist?(erase_path)
          win_erase_path = to_win_path(erase_path)
          print "Deleting #{erase_path} ..." 
          system("rmdir /S /Q #{win_erase_path}") unless @option.no_act
          puts " done."          
        end
      end
      
    end
  end  
end

if __FILE__ == $0
  option = PdumpfsEraserOption.parse(ARGV)
  PdumpfsEraser.new(option).erase
end
