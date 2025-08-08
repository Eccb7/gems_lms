class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum status: { pending: 0, completed: 1, failed: 2, refunded: 3, initiated: 4, timeout: 5 }
  enum payment_method: { stripe: 0, paypal: 1, bank_transfer: 2, mpesa: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :transaction_id, presence: true, uniqueness: true
  validates :phone_number, presence: true, if: :mpesa?

  # M-Pesa specific validations
  validates :phone_number, format: { with: /\A254[0-9]{9}\z/, message: "must be a valid Kenyan phone number (254XXXXXXXXX)" }, if: :mpesa?

  scope :successful, -> { where(status: :completed) }
  scope :this_month, -> { where(created_at: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :mpesa_payments, -> { where(payment_method: :mpesa) }

  def refund!
    case payment_method
    when "mpesa"
      # M-Pesa refunds need to be handled through Safaricom portal
      # For now, mark as refunded and handle manually
      update!(status: :refunded, refunded_at: Time.current)
      # TODO: Implement M-Pesa refund API when available
    else
      # Handle other payment methods
      update!(status: :refunded, refunded_at: Time.current)
    end
  end

  def formatted_phone_number
    return unless phone_number
    # Convert to international format if needed
    phone = phone_number.gsub(/\D/, "") # Remove non-digits
    phone = "254#{phone[1..-1]}" if phone.start_with?("0") # Convert 07xx to 254xxx
    phone
  end

  def mpesa_reference
    "GEMS#{id}#{Time.current.strftime('%Y%m%d')}"
  end
end
