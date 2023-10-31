class UpdateAvatarJob
  include Sidekiq::Job
  
  # user_id: integer, new_avatar_key: string, old_avatar_key: string
  def perform(user_id, new_avatar_key, old_avatar_key)
      obj = S3_BUCKET.object(new_avatar_key)
      if obj.exists?
        User.update(user_id, avatar_key: new_avatar_key)
        if old_avatar_key
          S3_BUCKET.object(old_avatar_key).delete
        end
      end
  end
end
