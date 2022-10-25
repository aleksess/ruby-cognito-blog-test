class Credentials
    include ActiveModel::API
    attr_accessor :username, :password
    validates :username, :password, presence: true
end