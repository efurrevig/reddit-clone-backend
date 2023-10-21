class ApplicationController < ActionController::API
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    end

    def presigned_url(fileType)
        key = SecureRandom.uuid + '.' + fileType.split('/')[1]
        url = S3_BUCKET
            .object(key)
            .presigned_url(
                :put, 
                expires_in: 1.minutes.to_i
            )
        url

    rescue Aws::Errors::ServiceError => e
        raise e
    end


end
