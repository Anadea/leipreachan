require 'spec_helper'

module Rails; end unless defined?(Rails)

describe Leipreachan do
  before do
    Rails.stub(:root).and_return('/rails/root')
    Rails.stub(:env).and_return('test')
    Dir.stub(:new).and_return(['.', '..', '.DStore', '20150404000000.sql.gz', '20150403000000.sql.gz'])
  end

  it 'has a version number' do
    expect(Leipreachan::VERSION).not_to be nil
  end

  context 'Backup database without password' do
    before do
      ActiveRecord::Base.stub(:configurations).and_return({'test' => {'username' => 'login', 'password' => '', 'database' => 'dbname'}})
      instance.stub!(:backup_base).and_return('.')
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
      instance.stub!(:backup_base).and_return('.')
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
      instance.stub!(:backup_base).and_return('.')
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
      instance.stub!(:backup_base).and_return('.')
      instance.stub!(:backup_file).and_return('201504040000.sql')
    end

    let!(:instance) { Leipreachan::DBBackup.new Rails.env }

    it 'backup_base return correct array' do
      expect(instance.send(:backup_folder_items)).to eq(['20150404000000.sql.gz', '20150403000000.sql.gz'])
    end
  end
end
