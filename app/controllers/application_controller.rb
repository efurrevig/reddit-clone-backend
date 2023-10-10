class ApplicationController < ActionController::API
    before_action :configure_permitted_parameters, if: :devise_controller?

    def test_method
        presigned_url("test_file")
    end
    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    end

    def presigned_url(file_name, method)
        return unless file_name
        #remove white space
        file_name = file_name.gsub(/\s+/, "")

        key = generate_key(file_name)
        url = S3_BUCKET.object(key).presigned_url(:put, expires_in: 10.minutes.to_i)
        url_object = {
            # URI(url) ? 
            url: url,
            key: key
        }
        puts("url: #{url}")

        url_object

    rescue Aws::Errors::ServiceError => e
        raise e
    end

    #generate a unique key for the file
    def generate_key(file_name)
        random_file_key = SecureRandom.uuid
        "#{random_file_key}-#{file_name}"
    end


end
