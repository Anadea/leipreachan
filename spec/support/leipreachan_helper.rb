module LeipreachanHelper
  def stub_config key, value
    ActiveRecord::Base.configurations['test'].stub(:[]).with(key).and_return(value)
  end
end
