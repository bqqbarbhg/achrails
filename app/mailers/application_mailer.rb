class ApplicationMailer < ActionMailer::Base
  default from: if Rails.env.production?
                  "noreply@achrails.herokuapp.com"
                else
                  "noreply@example.com"
                end
  layout 'mailer'
end
