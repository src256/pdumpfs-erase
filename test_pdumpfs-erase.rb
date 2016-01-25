require 'minitest/autorun'
require_relative 'pdumpfs-erase.rb'

class TestPdumpfsErase <  Minitest::Test
  def test_detect_keep_dirs
    opt = PdumpfsEraserOption.new
    opt.keep_year = 10
    opt.keep_month = 24
    opt.keep_week = 54
    opt.keep_day = 30
    
    backup_dirs = []    
    backup_dir = BackupDir.new
    backup_dir.path =  'R:/pc1/pdumpfs/d/2015/07/12'
    backup_dir.date = Date.new(2015, 7, 12)
    backup_dirs << backup_dir
    
    backup_dir = BackupDir.new
    backup_dir.path =  'R:/pc1/pdumpfs/d/2015/07/19'
    backup_dir.date = Date.new(2015, 7, 19)
    backup_dirs << backup_dir    
    
    backup_dir = BackupDir.new
    backup_dir.path =  'R:/pc1/pdumpfs/d/2015/07/26'
    backup_dir.date = Date.new(2015, 7, 26)
    backup_dirs << backup_dir
    
    
    opt.detect_keep_dirs(backup_dirs)
    
    assert_equal(true, backup_dirs[0].keep)
    assert_equal(true, backup_dirs[1].keep)
    assert_equal(true, backup_dirs[2].keep)
  end
end

