class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :username, :email, :avatar_key
end
