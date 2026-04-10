require "test_helper"

class NewsletterSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "creates subscription and enqueues welcome email" do
    assert_difference("NewsletterSubscription.count", 1) do
      assert_enqueued_with(job: NewsletterWelcomeEmailJob) do
        post newsletter_subscriptions_path, params: { newsletter_subscription: { email: "hello@example.com" } }
      end
    end

    assert_redirected_to root_path(anchor: "newsletter")
  end

  test "rejects duplicate email" do
    existing = newsletter_subscriptions(:one)

    assert_no_difference("NewsletterSubscription.count") do
      post newsletter_subscriptions_path, params: { newsletter_subscription: { email: existing.email } }
    end

    assert_redirected_to root_path(anchor: "newsletter")
  end
end
