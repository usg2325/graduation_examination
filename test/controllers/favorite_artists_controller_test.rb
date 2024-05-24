require "test_helper"

class FavoriteArtistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get favorite_artists_index_url
    assert_response :success
  end

  test "should get new" do
    get favorite_artists_new_url
    assert_response :success
  end
end
