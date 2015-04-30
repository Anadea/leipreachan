require 'spec_helper'

describe Leipreachan do
  before do
    ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'mysql2', 'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
  end

  context "MySQL: with password" do
    let!(:instance) { Leipreachan.get_backuper_for Rails.env }
    before do
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    it 'Backup' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:dbbackup!)).to eq "mysqldump -h localhost -ulogin -ppassword -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_tables!)).to eq "mysql --silent --skip-column-names -e \"SHOW TABLES\" -h localhost -ulogin -ppassword dbname | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h localhost -ulogin -ppassword dbname"
    end

    it 'Restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | mysql -h localhost -ulogin -ppassword dbname"
    end
  end
end
