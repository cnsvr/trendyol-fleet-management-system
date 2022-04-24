# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/'
    assert_response :success
    assert_equal 'Welcome to the Fleet Management API', response.body
  end
end
