module Leipreachan
  # require 'rails'
  class Railtie < Rails::Railtie
    rake_tasks { load "tasks/leipreachan.rake" }
  end
end
