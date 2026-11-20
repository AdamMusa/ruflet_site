class NewsletterMailer < ApplicationMailer
  def welcome
    @subscription = params.fetch(:subscription)

    mail to: @subscription.email, subject: "Welcome to the Ruflet newsletter"
  end
end
