class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG 
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
         flash[:danger] = UPDATE_ERROR_MSG 
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do  
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end 
    flash[:success] = "１ヶ月分の勤怠を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid #トランザクションによるエラーの分岐です。
  flash[:danger] = "無効なデータがあったため更新をキャンセルしました。"
  redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  private
    def attendances_params
      params.require(:user).permit(attendances:[:started_at, :finished_at, :note])[:attendances]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限はありません。"
        redirect_to(root_url)
      end  
    end        
     
end
