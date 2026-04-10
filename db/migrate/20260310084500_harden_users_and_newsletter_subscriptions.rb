class HardenUsersAndNewsletterSubscriptions < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :admin, from: nil, to: false
    change_column_null :users, :admin, false, false

    change_column_null :newsletter_subscriptions, :email, false
    change_column_null :newsletter_subscriptions, :subscribed_at, false
    add_index :newsletter_subscriptions, :email, unique: true
  end
end
