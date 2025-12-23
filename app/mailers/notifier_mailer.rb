# app/mailers/notifier_mailer.rb
class NotifierMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]

  def inspections_warnings(
    to:,
    subject:,
    expired_this_month_approved:,
    expired_this_month_rejected:,
    next_month_approved:,
    next_month_rejected:,
    two_months_approved:,
    two_months_rejected:,
    expired_month_name:,
    next_month_name:,
    two_months_name:
  )
    @expired_this_month_approved = expired_this_month_approved
    @expired_this_month_rejected = expired_this_month_rejected

    @next_month_approved  = next_month_approved
    @next_month_rejected  = next_month_rejected
    @two_months_approved  = two_months_approved
    @two_months_rejected  = two_months_rejected

    @expired_month_name   = expired_month_name
    @next_month_name      = next_month_name
    @two_months_name      = two_months_name


    mail(to: to, subject: subject)
  end
end
