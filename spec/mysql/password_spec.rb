require 'spec_helper'

describe Leipreachan do
  before do
    stub_config('adapter', 'mysql')
    stub_config('username', 'login')
    stub_config('host', 'localhost')
    stub_config('database', 'dbname')
    instance.stub(:backup_base_on).and_return('.')
    instance.stub(:backup_file).and_return('201504040000.sql')
    instance.stub(:system) { |arg| arg }
    instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
  end

  let!(:instance) { Leipreachan.get_backuper_for Rails.env }

  context "MySQL: with password" do
    before do
      stub_config('password', 'password')
    end

    it 'Backup' do
      expect(instance.send(:dbbackup!)).to eq "mysqldump -h localhost -ulogin -ppassword -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      expect(instance.send(:drop_tables!)).to eq "mysql --silent --skip-column-names -e \"SHOW TABLES\" -h localhost -ulogin -ppassword dbname | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h localhost -ulogin -ppassword dbname"
    end

    it 'Restore' do
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | mysql -h localhost -ulogin -ppassword dbname"
    end
  end

    context "MySQL: without password" do
    before do
      stub_config('password', '')
    end

    it 'Backup' do
      expect(instance.send(:dbbackup!)).to eq "mysqldump -h localhost -ulogin -i -c -q --single-transaction dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      expect(instance.send(:drop_tables!)).to eq "mysql --silent --skip-column-names -e \"SHOW TABLES\" -h localhost -ulogin dbname | xargs -L1 -I% echo 'DROP TABLE `%`;' | mysql -v -h localhost -ulogin dbname"
    end

    it 'Restore' do
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | mysql -h localhost -ulogin dbname"
    end
  end
end
