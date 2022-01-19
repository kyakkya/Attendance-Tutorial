class AttendancesController < ApplicationController
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec:0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG 
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec:0))
        flash[:info] = "お疲れ様でした。"
      else
         flash[:danger] = UPDATE_ERROR_MSG 
      end
    end  
    redirect_to @user
  end
  
  def edit_one_month
    @first_day = params[:date].nil??
    Date.current.beginning_of_month: params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

  unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
      one_month.each { |day| @user.attendances.create!(worked_on: day) }
    end
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:wo
  end  
end
