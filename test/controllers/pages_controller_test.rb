require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get configCrawler" do
    get :configCrawler
    assert_response :success
  end

end
