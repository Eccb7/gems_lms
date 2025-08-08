class PaymentsController < ApplicationController
  before_action :authenticate_user!, except: [ :mpesa_callback ]
  skip_before_action :verify_authenticity_token, only: [ :mpesa_callback ]
  before_action :set_course, only: [ :create, :mpesa_checkout ]

  def create
    @payment = current_user.payments.build(payment_params)
    @payment.course = @course
    @payment.currency = "KES"
    @payment.transaction_id = generate_transaction_id

    if @payment.save
      case @payment.payment_method
      when "mpesa"
        redirect_to mpesa_checkout_payment_path(@payment)
      else
        redirect_to @course, alert: "Payment method not supported yet."
      end
    else
      redirect_to @course, alert: "Payment failed: #{@payment.errors.full_messages.join(', ')}"
    end
  end

  def mpesa_checkout
    @payment = current_user.payments.find(params[:id])
    @course = @payment.course

    if @payment.completed?
      redirect_to @course, notice: "Payment already completed!"
      return
    end

    # Initialize M-Pesa STK Push
    mpesa_service = MpesaService.new
    result = mpesa_service.initiate_stk_push(
      @payment.formatted_phone_number,
      @payment.amount,
      @payment.mpesa_reference,
      "Payment for #{@course.title}"
    )

    if result[:success]
      @payment.update!(
        status: :initiated,
        mpesa_checkout_request_id: result[:checkout_request_id],
        mpesa_merchant_request_id: result[:merchant_request_id]
      )

      flash.now[:info] = result[:customer_message]
      render :mpesa_checkout
    else
      @payment.update!(status: :failed)
      redirect_to @course, alert: "Payment initialization failed: #{result[:error]}"
    end
  end

  def check_payment_status
    @payment = current_user.payments.find(params[:id])

    if @payment.mpesa_checkout_request_id.present?
      mpesa_service = MpesaService.new
      result = mpesa_service.query_stk_status(@payment.mpesa_checkout_request_id)

      if result[:success]
        case result[:result_code].to_i
        when 0
          @payment.update!(status: :completed)
          render json: { status: "completed", message: "Payment successful!" }
        when 1032
          @payment.update!(status: :timeout)
          render json: { status: "timeout", message: "Payment timed out. Please try again." }
        else
          @payment.update!(status: :failed)
          render json: { status: "failed", message: result[:result_desc] }
        end
      else
        render json: { status: "error", message: "Unable to check payment status" }
      end
    else
      render json: { status: "error", message: "Invalid payment request" }
    end
  end

  def mpesa_callback
    Rails.logger.info "M-Pesa Callback received: #{params}"

    begin
      callback_data = JSON.parse(request.body.read)
      mpesa_service = MpesaService.new
      result = mpesa_service.process_callback(callback_data)

      if result[:success]
        # Find payment by checkout request ID
        payment = Payment.find_by(mpesa_checkout_request_id: result[:checkout_request_id])

        if payment
          payment.update!(
            status: :completed,
            mpesa_receipt_number: result[:mpesa_receipt_number],
            completed_at: Time.current
          )

          # Enroll user in course
          unless payment.user.enrolled_in?(payment.course)
            payment.user.enrollments.create!(
              course: payment.course,
              enrolled_at: Time.current,
              status: :active
            )
          end

          # Send confirmation email
          # PaymentMailer.payment_confirmation(payment).deliver_later

          Rails.logger.info "Payment #{payment.id} completed successfully"
        end
      else
        # Handle failed payment
        payment = Payment.find_by(mpesa_checkout_request_id: result[:checkout_request_id])
        payment&.update!(status: :failed)

        Rails.logger.warn "Payment failed: #{result[:result_desc]}"
      end

      # Respond to M-Pesa
      render json: { ResultCode: 0, ResultDesc: "Success" }
    rescue => e
      Rails.logger.error "M-Pesa callback error: #{e.message}"
      render json: { ResultCode: 1, ResultDesc: "Error processing callback" }
    end
  end

  def index
    @payments = current_user.payments.includes(:course).order(created_at: :desc)
  end

  def show
    @payment = current_user.payments.find(params[:id])
  end

  private

  def set_course
    @course = Course.find(params[:course_id]) if params[:course_id]
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_method, :phone_number)
  end

  def generate_transaction_id
    "GEMS_#{Time.current.strftime('%Y%m%d_%H%M%S')}_#{SecureRandom.hex(4)}"
  end
end
