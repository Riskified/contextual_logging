require 'spec_helper'

class MyActionController < ::ActionController::Base
  include ContextualLogging::ActionControllerExtensions
end

describe ContextualLogging::Railtie do

end
