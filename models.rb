require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    validates :name,
        presence: true,
        format: { with: /\A\w+\z/ }
    validates :password,
        length: { in: 5..10 }
    has_many :tasks
end

class Task < ActiveRecord::Base
    validates :title,
        presence: true
    belongs_to :user
end