class Coupon < ApplicationRecord
  has_many :coupon_usages, dependent: :destroy
  has_many :users, through: :coupon_usages

  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :valid_from, presence: true
  validates :valid_until, presence: true

  enum discount_type: { percentage: 0, fixed_amount: 1 }

  scope :active, -> { where(active: true) }
  scope :valid_now, -> { where('valid_from <= ? AND valid_until >= ?', Time.current, Time.current) }
  scope :not_expired, -> { where('valid_until >= ?', Time.current) }

  def valid_for_use?
    active? && valid_now? && !usage_limit_reached?
  end

  def usage_limit_reached?
    return false if usage_limit.nil?
    coupon_usages.count >= usage_limit
  end

  def valid_now?
    Time.current.between?(valid_from, valid_until)
  end

  def calculate_discount(amount)
    case discount_type
    when 'percentage'
      (amount * discount_value / 100).round(2)
    when 'fixed_amount'
      [discount_value, amount].min
    end
  end

  def can_be_used_by?(user)
    return false unless valid_for_use?
    return false if user_limit && coupon_usages.where(user: user).count >= user_limit
    true
  end
end
