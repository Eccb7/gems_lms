require "uri"
require "net/http"
require "json"
require "base64"

class MpesaService
  def initialize
    @base_url = Rails.application.credentials.dig(:mpesa, :base_url) || "https://sandbox.safaricom.co.ke"
    @consumer_key = Rails.application.credentials.dig(:mpesa, :consumer_key) || "uXgYD3XmdDeYwELx0gfnX0eaG1ojw7eJZPSvHQwwvvlUqGoR"
    @consumer_secret = Rails.application.credentials.dig(:mpesa, :consumer_secret) || "aJeex4H4ZFiO4iBVAFJxAiLKIPTTK0B3cXBJ5MonmGDik6nGsXJUVcalFL9ybx6G"
    @business_short_code = Rails.application.credentials.dig(:mpesa, :business_short_code) || "174379"
    @passkey = Rails.application.credentials.dig(:mpesa, :passkey) || "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
    @callback_url = Rails.application.routes.url_helpers.mpesa_callback_url(host: Rails.application.config.action_mailer.default_url_options[:host] || "localhost:3000", protocol: "http")
  end

  def initiate_stk_push(phone_number, amount, account_reference, transaction_desc)
    access_token = get_access_token
    return { success: false, error: "Failed to get access token" } unless access_token

    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    password = Base64.strict_encode64("#{@business_short_code}#{@passkey}#{timestamp}")

    payload = {
      BusinessShortCode: @business_short_code,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: amount.to_i,
      PartyA: format_phone_number(phone_number),
      PartyB: @business_short_code,
      PhoneNumber: format_phone_number(phone_number),
      CallBackURL: @callback_url,
      AccountReference: account_reference,
      TransactionDesc: transaction_desc
    }

    begin
      uri = URI("#{@base_url}/mpesa/stkpush/v1/processrequest")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{access_token}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        if result["ResponseCode"] == "0"
          {
            success: true,
            checkout_request_id: result["CheckoutRequestID"],
            merchant_request_id: result["MerchantRequestID"],
            customer_message: result["CustomerMessage"]
          }
        else
          {
            success: false,
            error: result["errorMessage"] || result["ResponseDescription"]
          }
        end
      else
        {
          success: false,
          error: "HTTP Error: #{response.code} - #{response.body}"
        }
      end
    rescue => e
      Rails.logger.error "M-Pesa STK Push Error: #{e.message}"
      {
        success: false,
        error: "Connection error: #{e.message}"
      }
    end
  end

  def query_stk_status(checkout_request_id)
    access_token = get_access_token
    return { success: false, error: "Failed to get access token" } unless access_token

    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    password = Base64.strict_encode64("#{@business_short_code}#{@passkey}#{timestamp}")

    payload = {
      BusinessShortCode: @business_short_code,
      Password: password,
      Timestamp: timestamp,
      CheckoutRequestID: checkout_request_id
    }

    begin
      uri = URI("#{@base_url}/mpesa/stkpushquery/v1/query")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{access_token}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        {
          success: true,
          result_code: result["ResultCode"],
          result_desc: result["ResultDesc"],
          checkout_request_id: result["CheckoutRequestID"]
        }
      else
        {
          success: false,
          error: "HTTP Error: #{response.code} - #{response.body}"
        }
      end
    rescue => e
      Rails.logger.error "M-Pesa Query Error: #{e.message}"
      {
        success: false,
        error: "Connection error: #{e.message}"
      }
    end
  end

  def process_callback(callback_data)
    # Process M-Pesa callback data
    stk_callback = callback_data["Body"]["stkCallback"]
    checkout_request_id = stk_callback["CheckoutRequestID"]
    result_code = stk_callback["ResultCode"].to_i

    if result_code == 0
      # Payment successful
      callback_metadata = stk_callback["CallbackMetadata"]["Item"]

      # Extract payment details
      amount = find_callback_value(callback_metadata, "Amount")
      mpesa_receipt_number = find_callback_value(callback_metadata, "MpesaReceiptNumber")
      transaction_date = find_callback_value(callback_metadata, "TransactionDate")
      phone_number = find_callback_value(callback_metadata, "PhoneNumber")

      {
        success: true,
        checkout_request_id: checkout_request_id,
        mpesa_receipt_number: mpesa_receipt_number,
        amount: amount,
        transaction_date: transaction_date,
        phone_number: phone_number
      }
    else
      # Payment failed
      {
        success: false,
        checkout_request_id: checkout_request_id,
        result_desc: stk_callback["ResultDesc"]
      }
    end
  end

  private

  def get_access_token
    return @access_token if @access_token && @token_expires_at && Time.current < @token_expires_at

    begin
      uri = URI("#{@base_url}/oauth/v1/generate?grant_type=client_credentials")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      auth_string = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")
      request["Authorization"] = "Basic #{auth_string}"

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        @access_token = result["access_token"]
        @token_expires_at = Time.current + result["expires_in"].to_i.seconds
        @access_token
      else
        Rails.logger.error "M-Pesa Auth Error: #{response.code} - #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "M-Pesa Auth Exception: #{e.message}"
      nil
    end
  end

  def format_phone_number(phone_number)
    # Remove any non-digit characters
    phone = phone_number.gsub(/\D/, "")

    # Convert to international format
    if phone.start_with?("0")
      phone = "254#{phone[1..-1]}"
    elsif phone.start_with?("7") || phone.start_with?("1")
      phone = "254#{phone}"
    end

    phone
  end

  def find_callback_value(callback_metadata, name)
    item = callback_metadata.find { |item| item["Name"] == name }
    item ? item["Value"] : nil
  end
end
