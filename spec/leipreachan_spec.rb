require 'spec_helper'

module Rails; end unless defined?(Rails)

describe Leipreachan do
  before do
    Rails.stub(:root).and_return('/tmp/Rails')
    Rails.stub(:env).and_return('test')
    Dir.stub(:new).and_return(['.', '..', '.DStore', '20150404000000.sql.gz', '20150403000000.sql.gz'])
  end

  it 'has a version number' do
    expect(Leipreachan::VERSION).not_to be nil
  end

  it 'defaults (max, date, dir)' do
    instance = Leipreachan::DBBackup.new Rails.env
    expect(instance.max_files).to eq(30)
    expect(instance.directory).to eq("backups")
    expect(instance.target_date).to eq(Date.current.strftime("%Y%m%d"))
  end

  it 'set MAX from ENV' do
    instance = Leipreachan::DBBackup.new({'MAX' => 100})
    expect(instance.max_files).to eq(100)
  end

  it 'set DATE from ENV' do
    instance = Leipreachan::DBBackup.new({'DATE' => "20150404"})
    expect(instance.target_date).to eq("20150404")
  end

  it 'set DIR form ENV' do
    instance = Leipreachan::DBBackup.new({'DIR' => "blah"})
    expect(instance.directory).to eq("blah")
  end

  it 'remove unwanted backups' do
    instance = Leipreachan::DBBackup.new({'MAX' => 2})
    Dir.unstub(:new)
    folder = File.join(Rails.root, 'backups',Date.current.strftime("%Y%m%d"))
    FileUtils.mkdir_p(folder)
    FileUtils.touch("#{folder}/201504010000.sql.gz")
    FileUtils.touch("#{folder}/201504010001.sql.gz")
    FileUtils.touch("#{folder}/201504010002.sql.gz")
    FileUtils.touch("#{folder}/201504010003.sql.gz")
    FileUtils.touch("#{folder}/201504010004.sql.gz")
    FileUtils.touch("#{folder}/201504010005.sql.gz")
    FileUtils.touch("#{folder}/201504010006.sql.gz")

    instance.send(:remove_unwanted_backups)
    expect(instance.send(:backup_folder_items)).to eq(['201504010006.sql.gz', '201504010005.sql.gz'])
    FileUtils.rm_rf(Rails.root)
  end

  context 'Backup database without password' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'username' => 'login', 'password' => '', 'database' => 'dbname'}})
      instance.stub!(:backup_base_on).and_return('.')
      instance.stub!(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan::DBBackup.new Rails.env }

    it 'mysql' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:backup_mysql!)).to eq "mysqldump -ulogin  -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'postgres' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:backup_pg!)).to eq " pg_dump -U login dbname | gzip > 201504040000.sql.gz"
    end
  end

  context 'Backup database with password' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
      instance.stub!(:backup_base_on).and_return('.')
      instance.stub!(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan::DBBackup.new Rails.env }

    it 'mysql' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:backup_mysql!)).to eq "mysqldump -ulogin -ppassword -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'postgres' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:backup_pg!)).to eq "PGPASSWORD='password' pg_dump -U login dbname | gzip > 201504040000.sql.gz"
    end
  end

  context 'Restore database' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
      instance.stub!(:backup_base_on).and_return('.')
      instance.stub!(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan::DBBackup.new Rails.env }

    it 'mysql restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore_mysql!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | mysql -ulogin -ppassword dbname"
    end

    it 'postgres drop database content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_pg!)).to eq "echo \"drop schema public cascade; create schema public;\" | PGPASSWORD='password' psql -U login dbname"
    end

    it 'postgres restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore_pg!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | PGPASSWORD='password' psql -U login dbname"
    end
  end

  context 'Other checks' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
      instance.stub!(:backup_base_on).and_return('.')
      instance.stub!(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan::DBBackup.new Rails.env }

    it 'backup_base_on return correct array' do
      expect(instance.send(:backup_folder_items)).to eq(['20150404000000.sql.gz', '20150403000000.sql.gz'])
    end
  end
end
