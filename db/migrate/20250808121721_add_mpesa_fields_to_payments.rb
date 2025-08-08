class AddMpesaFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :phone_number, :string
    add_column :payments, :mpesa_checkout_request_id, :string
    add_column :payments, :mpesa_merchant_request_id, :string
    add_column :payments, :mpesa_receipt_number, :string
    add_column :payments, :completed_at, :datetime
    add_column :payments, :refunded_at, :datetime

    add_index :payments, :mpesa_checkout_request_id, unique: true
    add_index :payments, :mpesa_receipt_number, unique: true
    add_index :payments, :phone_number
    add_index :payments, :completed_at
  end
end
