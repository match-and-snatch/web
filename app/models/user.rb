class User < ActiveRecord::Base
  has_many :offers
  has_many :favorites
  has_many :feedbacks
  has_many :subscriptions
  has_many :messages

  def logged_in?
    persisted?
  end

  # @return [String]
  def self.generate_auth_token
    begin
      auth_token = SecureRandom.urlsafe_base64
    end while exists?(auth_token: auth_token)
    auth_token
  end

  # @return [String]
  def self.generate_registration_token
    begin
      registration_token = SecureRandom.urlsafe_base64
    end while exists?(registration_token: registration_token)
    registration_token
  end
end