# app/mailers/notifier_mailer.rb
class NotifierMailer < ApplicationMailer
  default from: ENV.fetch("GMAIL_USERNAME")

  def inspections_warnings(
    to:,
    subject:,
    expired_this_month:,
    next_month_approved:,
    next_month_rejected:,
    two_months_approved:,
    two_months_rejected:,
    expired_month_name:,
    next_month_name:,
    two_months_name:,
    excel_path:,
    excel_filename:
  )
    @expired_this_month   = expired_this_month
    @next_month_approved  = next_month_approved
    @next_month_rejected  = next_month_rejected
    @two_months_approved  = two_months_approved
    @two_months_rejected  = two_months_rejected

    @expired_month_name   = expired_month_name
    @next_month_name      = next_month_name
    @two_months_name      = two_months_name

    if excel_path.present? && File.exist?(excel_path)
      attachments[excel_filename] = File.binread(excel_path)
    end

    mail(to: to, subject: subject)
  end
end
