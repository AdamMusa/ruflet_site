require "test_helper"

class NewsletterWelcomeEmailJobTest < ActiveJob::TestCase
  test "sends welcome email" do
    subscription = newsletter_subscriptions(:one)

    assert_emails 1 do
      perform_enqueued_jobs do
        NewsletterWelcomeEmailJob.perform_later(subscription.id)
      end
    end
  end
end
