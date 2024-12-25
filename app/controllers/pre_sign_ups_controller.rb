class PreSignUpsController < ApplicationController
  skip_before_action :require_login, only: %i[new create completed]

  def new; end

  def create
    email = params[:email]

    if email.present? && valid_email?(email)
      AdminMailer.new_pre_sign_up(email).deliver_later
      redirect_to pre_sign_up_completed_path
    else
      flash[:error] = "メールアドレスの送信に失敗しました"
      redirect_to pre_sign_up_path
    end
  end

  def completed; end

  private

  def valid_email?(email)
    email =~ URI::MailTo::EMAIL_REGEXP
  end
end
