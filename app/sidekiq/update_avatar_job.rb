class UpdateAvatarJob
  include Sidekiq::Job
  sidekiq_options retry: false # job will be discarded immediately if failed
  
  # user_id: integer, new_avatar_key: string, old_avatar_key: string
  def perform(user_id, new_avatar_key, old_avatar_key)
    # check aws s3 bucket for new avatar
    # obj = S3_BUCKET.object(new_avatar_key)
    # puts(obj.exists?)
    # new_avatar = S3_BUCKET.head_object(bucket: S3_BUCKET, key: new_avatar_key)
    # puts new_avatar
    # if new avatar exists: 
      #delete old avatar
      #update user avatar url
    # else:
      #do nothing
    puts 'hello'
  end
end
