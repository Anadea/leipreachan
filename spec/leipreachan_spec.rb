require 'spec_helper'

module Rails; end unless defined?(Rails)

describe Leipreachan do
  before do
    stub_config('adapter', 'mysql2')
    Dir.stub(:new).and_return(['.', '..', '.DStore', '20150404000000.sql.gz', '20150403000000.sql.gz'])
  end

  let!(:instance) { Leipreachan.get_backuper_for Rails.env }

  it 'Has a version number' do
    expect(Leipreachan::VERSION).not_to be nil
  end

  it 'Defaults (max, date, dir)' do
    expect(instance.max_days).to eq(30)
    expect(instance.directory).to eq("backups")
    expect(instance.backup_folder).to eq(Date.current.strftime("%Y%m%d"))
    expect(instance.target_date).to eq(nil)
  end

  it 'Check DAYS from ENV' do
    instance = Leipreachan.get_backuper_for({'DAYS' => 100})
    expect(instance.max_days).to eq(100)
  end

  it 'Check DATE from ENV' do
    instance = Leipreachan.get_backuper_for({'DATE' => "20150404"})
    expect(instance.backup_folder).to eq('20150404')
    expect(instance.target_date).to eq('20150404')
  end

  it 'Check DIR from ENV' do
    instance = Leipreachan.get_backuper_for({'DIR' => "blah"})
    expect(instance.directory).to eq("blah")
  end

  it 'Remove unwanted backups' do
    instance = Leipreachan.get_backuper_for({'DAYS' => 2})
    Dir.unstub(:new)
    10.times.each  do |item|
      FileUtils.mkdir_p(File.join(instance.send(:base_path), (Date.current - item.day).strftime("%Y%m%d")))
    end
    instance.send(:remove_unwanted_backups)
    expect(Dir.new(instance.send(:base_path)).entries.sort).to eq(['.', '..', Date.current.strftime("%Y%m%d"), (Date.current - 1.day).strftime("%Y%m%d")].sort)
    FileUtils.rm_rf(Rails.root)
  end

  context 'Other checks' do
    before do
      instance.stub(:backup_base_on).and_return('.')
      instance.stub(:backup_file).and_return('201504040000.sql')
    end

    it 'backup_base_on return correct array' do
      expect(instance.send(:backup_folder_items)).to eq(['20150404000000.sql.gz', '20150403000000.sql.gz'])
    end
  end

  context 'Exceptions checks' do
    it 'Check not found command' do
      instance.stub(:system_check_list).and_return(['11243111'])
      expect { instance.check_system_requirements! }.to raise_error(RuntimeError, '11243111 is required for Leipreachan backups')
    end
  end
end
