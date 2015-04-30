require 'spec_helper'

describe Leipreachan do
  before do
    stub_config('adapter', 'postgresql')
  end
  let!(:instance) { Leipreachan.get_backuper_for Rails.env }
  it { expect(instance.respond_to?(:system_check_list)).to be_truthy }
end
