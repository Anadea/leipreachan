require 'spec_helper'

describe Leipreachan do
  before do
    stub_config('adapter', 'postgresql')
    stub_config('user', 'login')
    stub_config('host', 'localhost')
    stub_config('database', 'dbname')
    instance.stub(:backup_base_on).and_return('.')
    instance.stub(:backup_file).and_return('201504040000.sql')
    instance.stub(:system) { |arg| arg }
    instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
  end

  let!(:instance) { Leipreachan.get_backuper_for Rails.env }

  context "Postgresql: with password" do
    before do
      stub_config('password', 'password')
    end

    it 'Backup' do
      expect(instance.send(:dbbackup!)).to eq "PGPASSWORD='password' pg_dump -h localhost -U login dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      expect(instance.send(:drop_tables!)).to eq "PGPASSWORD='password' psql -h localhost -U login dbname -t -c \"select 'drop table \\\"' || tablename || '\\\" cascade;' from pg_tables where schemaname = 'public'\"  | PGPASSWORD='password' psql -h localhost -U login dbname"
    end

     it 'Restore' do
       expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | PGPASSWORD='password' psql -h localhost -U login dbname"
     end
  end

  context "Postgresql: without password" do
    before do
      stub_config('password', '')
    end

    it 'Backup' do
      expect(instance.send(:dbbackup!)).to eq "pg_dump -h localhost -U login dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      expect(instance.send(:drop_tables!)).to eq "psql -h localhost -U login dbname -t -c \"select 'drop table \\\"' || tablename || '\\\" cascade;' from pg_tables where schemaname = 'public'\"  | psql -h localhost -U login dbname"
    end

    it 'Restore' do
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | psql -h localhost -U login dbname"
    end
  end
end
