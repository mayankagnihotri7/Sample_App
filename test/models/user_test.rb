require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.create(name: "Max", email: "max@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name not too long" do
    @user.name = "m" * 51
    assert_not @user.valid?
  end

  test "email not too long" do
    @user.email = "m" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email should be valid" do
    valid_addresses = %w[USER@foo.com THE_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{@user.email.inspect} should be valid"
    end
  end

  test "reject invalid email address" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{@user.email.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be lowercase before saving" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.email
  end

  test "password should be present(non blank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "minimum password length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, "")
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    raptor = users(:raptor)
    archer = users(:archer)
    assert_not raptor.following?(archer)
    raptor.follow(archer)
    assert raptor.following?(archer)
    assert archer.followers.include?(raptor)
    raptor.unfollow(archer)
    assert_not raptor.following?(archer)
  end

  test "feed should have the right posts" do
    raptor = users(:raptor)
    archer = users(:archer)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert raptor.feed.include?(post_following)
    end
    # Posts from self
    raptor.microposts.each do |post_self|
      assert raptor.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |posts_unfollow|
      assert_not raptor.feed.include?(posts_unfollow)
    end
  end
end
