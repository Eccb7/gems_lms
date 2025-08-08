#!/usr/bin/env ruby

# Quick test script for M-Pesa integration
require 'bundler/setup'
require 'rails'

# Initialize Rails environment
ENV['RAILS_ENV'] ||= 'development'
require_relative 'config/environment'

puts "🚀 Testing M-Pesa Integration with Daraja API"
puts "=" * 50

# Test M-Pesa Service
service = MpesaService.new

puts "\n📋 Configuration Check:"
puts "Business Short Code: #{service.instance_variable_get(:@business_short_code)}"
puts "Base URL: #{service.instance_variable_get(:@base_url)}"
puts "Consumer Key: #{service.instance_variable_get(:@consumer_key)[0..10]}..." # Only show first part for security

puts "\n🔑 Testing Access Token Generation..."
begin
  access_token = service.send(:get_access_token)
  if access_token
    puts "✅ Access Token Generated Successfully!"
    puts "Token: #{access_token[0..20]}..." # Only show first part for security
  else
    puts "❌ Failed to generate access token"
  end
rescue => e
  puts "❌ Error: #{e.message}"
end

puts "\n🧪 Testing STK Push (Simulation)..."
begin
  # Test with a dummy phone number and small amount
  result = service.initiate_stk_push(
    "254708374149",  # Test phone number
    1,               # 1 KES for testing
    "GEMS_TEST",     # Account reference
    "Test payment for Gems LMS"  # Description
  )

  if result[:success]
    puts "✅ STK Push initiated successfully!"
    puts "Checkout Request ID: #{result[:checkout_request_id]}"
    puts "Customer Message: #{result[:customer_message]}"
  else
    puts "❌ STK Push failed: #{result[:error]}"
  end
rescue => e
  puts "❌ Error: #{e.message}"
end

puts "\n" + "=" * 50
puts "🏁 M-Pesa Integration Test Complete"
puts "\n💡 Next Steps:"
puts "1. Verify that the access token is being generated correctly"
puts "2. Test STK Push with a real Safaricom number"
puts "3. Set up callback URL for production"
puts "4. Test the payment flow end-to-end"
