class Avo::Resources::User < Avo::BaseResource
  self.title = :email_address

  def fields
    field :id, as: :id
    field :email_address, as: :text
    field :admin, as: :boolean
    field :created_at, as: :date_time, readonly: true
  end
end
