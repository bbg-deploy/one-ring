RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.observers.disable :all # <-- Turn 'em all off!
  end
end