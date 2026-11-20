class NewsletterWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(subscription_id)
    subscription = NewsletterSubscription.find_by(id: subscription_id)
    return if subscription.nil?

    NewsletterMailer.with(subscription: subscription).welcome.deliver_now
  end
end
