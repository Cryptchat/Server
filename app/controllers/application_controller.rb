class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing do |err|
    render json: { messages: [err.message] }, status: 400
  end

  rescue_from ActiveRecord::RecordInvalid do |err|
    render unprocessable_entity_response(err.message)
  end

  def success_response
    {
      json: { messages: ["OK"] },
      status: 200
    }
  end

  def unprocessable_entity_response(errors = [])
    errors = [errors] unless Array === errors
    errors << "Unprocessable entity" if errors.size == 0
    {
      json: { messages: errors },
      status: 422
    }
  end
end
