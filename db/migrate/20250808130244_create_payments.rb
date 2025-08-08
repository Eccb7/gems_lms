class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'KES'
      t.string :status, default: 'pending'
      t.string :payment_method, default: 'mpesa'
      t.text :description

      # M-Pesa specific fields
      t.string :phone_number
      t.string :mpesa_receipt_number
      t.string :checkout_request_id
      t.string :merchant_request_id
      t.string :transaction_id
      t.datetime :transaction_date
      t.text :callback_response

      t.timestamps
    end

    add_index :payments, :status
    add_index :payments, :payment_method
    add_index :payments, :checkout_request_id
    add_index :payments, :mpesa_receipt_number
  end
end
