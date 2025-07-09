class User < ApplicationRecord
  # save前に小文字に変換する
  # before_save { self.email = email.downcase }
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255}, format: { with: VALID_EMAIL_REGEX}, uniqueness: true

  # ハッシュ化するメソッド
  has_secure_password

  validates :password, presence: true, length: { minimum: 8 }
end
