require 'spec_helper'

describe Leipreachan do
  before do
    ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'postgresql', 'user' => 'login', 'password' => '', 'database' => 'dbname'}})
  end

  context "Postgresql: without password" do
    let!(:instance) { Leipreachan.get_backuper_for Rails.env }
    before do
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    it 'Backup' do
      instance.stub(:system) { |arg| arg }
      expect(instance.send(:dbbackup!)).to eq "pg_dump -h localhost -U login dbname | gzip > 201504040000.sql.gz"
    end

    it 'Drop old content' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:drop_tables!)).to eq "psql -h localhost -U login dbname -t -c \"select 'drop table \\\"' || tablename || '\\\" cascade;' from pg_tables where schemaname = 'public'\"  | psql -h localhost -U login dbname"
    end

    it 'Restore' do
      instance.stub(:system) { |arg| arg }
      instance.stub(:get_file_for_restore).and_return('20150404000000.sql.gz')
      expect(instance.send(:restore!)).to eq "zcat < ./#{instance.send(:get_file_for_restore)} | psql -h localhost -U login dbname"
    end
  end
end
