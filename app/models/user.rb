class User < ApplicationRecord

  validates :password, 
    presence: true, 
    length: { in: Devise.password_length }, 
    format: { with: PASSWORD_FORMAT }, 
    confirmation: true, 
    on: :create

  validates :password, 
    allow_nil: true, 
    length: { in: Devise.password_length }, 
    format: { with: PASSWORD_FORMAT }, 
    confirmation: true,
    on: :update

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessor :reset_token
end
