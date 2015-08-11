unless SSS
class User < ActiveRecord::Base
  devise :rememberable, :omniauthable,
    omniauth_providers: if Rails.env.production?
                          [:learning_layers_oidc]
                        else
                          [:developer]
                        end

  belongs_to :person

  def self.from_omniauth(auth)
    return nil if [auth.info.name, auth.provider, auth.uid].any? &:blank?

    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.person = Person.create
    end
    person = user.person
    person.email = auth.info.email if auth.info.email
    person.name = auth.info.name
    user.bearer_token = auth.extra.try(:bearer)
    user.save!
    user
  end

end
end
