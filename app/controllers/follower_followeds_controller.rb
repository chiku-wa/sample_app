class FollowerFollowedsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  # ユーザをフォローするアクション
  def create
    user = User.find_by(id: params[:followed_id])
    if user
      current_user.follow(user)
      redirect_to(user_path(user))
    else
      redirect_to(root_path)
    end
  end

  # ユーザをフォロー解除するアクション
  def destroy
    user = User.find_by(id: params[:id])
    if user
      current_user.unfollow(user)
      redirect_to(user_path(user))
    else
      redirect_to(root_path)
    end
  end
end
