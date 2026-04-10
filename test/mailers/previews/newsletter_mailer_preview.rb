# Preview all emails at http://localhost:3000/rails/mailers/newsletter_mailer
class NewsletterMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/newsletter_mailer/welcome
  def welcome
    subscription = NewsletterSubscription.new(email: "preview@ruflet.dev", subscribed_at: Time.current)
    NewsletterMailer.with(subscription: subscription).welcome
  end
end
