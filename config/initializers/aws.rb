Aws.config.update(
    credentials: Aws::Credentials.new(
        Rails.application.credentials.aws[:access_key_id],
        Rails.application.credentials.aws[:secret_access_key]
    ),
    region: Rails.application.credentials.aws[:region]
)

S3_BUCKET = Aws::S3::Resource.new.bucket(Rails.application.credentials.aws[:bucket])