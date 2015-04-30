require 'spec_helper'

describe Leipreachan do
  before do
    ActiveRecord::Base.stub(:configurations).and_return({'test' => {'adapter' => 'mysql2', 'username' => 'login', 'password' => 'password', 'database' => 'dbname'}})
  end
  let!(:instance) { Leipreachan.get_backuper_for Rails.env }
  it { expect(instance.respond_to?(:system_check_list)).to be_truthy }
end
