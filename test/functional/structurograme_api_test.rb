require File.dirname(__FILE__) + '/../test_helper'
require 'structurograme_controller'

class StructurogrameController; def rescue_action(e) raise e end; end

class StructurogrameControllerApiTest < Test::Unit::TestCase
  def setup
    @controller = StructurogrameController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_generate_from_xml
    result = invoke :generate_from_xml
    assert_equal nil, result
  end
end
