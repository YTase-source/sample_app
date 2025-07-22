class User < ApplicationRecord
  # 記憶トークン用のローカル変数
  attr_accessor :remember_token

  # save前に小文字に変換する
  # before_save { self.email = email.downcase }
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50, minimum: 5 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

  # ハッシュ化するメソッド
  has_secure_password

  validates :password, presence: true, length: { minimum: 8 }

  class << self
    # 渡された文字列のハッシュ値を返す
    # def self.digest(string)
    def digest(string)
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    # def self.new_token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    # remember_tokenをさらに暗号化(:remember_digest)
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    # 渡されたトークンがnilの場合は早期終了させる
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end
