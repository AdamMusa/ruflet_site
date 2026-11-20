require "test_helper"

class NewsletterMailerTest < ActionMailer::TestCase
  test "welcome" do
    subscription = newsletter_subscriptions(:one)
    mail = NewsletterMailer.with(subscription: subscription).welcome

    assert_equal "Welcome to the Ruflet newsletter", mail.subject
    assert_equal [ subscription.email ], mail.to
    assert_equal [ "hello@ruflet.dev" ], mail.from
    assert_match subscription.email, mail.body.encoded
  end
end
