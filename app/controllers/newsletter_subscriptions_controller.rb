class NewsletterSubscriptionsController < ApplicationController
  allow_unauthenticated_access only: :create

  def create
    subscription = NewsletterSubscription.new(newsletter_subscription_params.merge(subscribed_at: Time.current))

    if subscription.save
      NewsletterWelcomeEmailJob.perform_later(subscription.id)
      redirect_to root_path(anchor: "newsletter"), notice: "You've been subscribed successfully."
    else
      redirect_to root_path(anchor: "newsletter"), alert: subscription.errors.full_messages.to_sentence.presence || "Subscription could not be completed."
    end
  end

  private
    def newsletter_subscription_params
      params.require(:newsletter_subscription).permit(:email)
    end
end
