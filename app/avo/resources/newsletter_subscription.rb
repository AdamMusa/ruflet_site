class Avo::Resources::NewsletterSubscription < Avo::BaseResource
  self.title = :email

  def fields
    field :id, as: :id
    field :email, as: :text
    field :subscribed_at, as: :date_time
    field :created_at, as: :date_time, readonly: true
  end
end
