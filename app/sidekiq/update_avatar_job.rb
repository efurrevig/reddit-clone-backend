class UpdateAvatarJob
  include Sidekiq::Job
  sidekiq_options retry: false # job will be discarded immediately if failed
  
  # user_id: integer, new_avatar_key: string, old_avatar_key: string
  def perform(user_id, new_avatar_key, old_avatar_key)
      obj = S3_BUCKET.object(new_avatar_key)
      if obj.exists?
        if old_avatar_key
          S3_BUCKET.object(old_avatar_key).delete
        end
        User.update(user_id, avatar_key: new_avatar_key)
      end
  end
end
