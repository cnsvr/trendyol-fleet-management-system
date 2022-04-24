# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing do |exception|
    render json: { error: exception.message.split("\n").first }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message.split("\n").first }, status: :not_found
  end
end
