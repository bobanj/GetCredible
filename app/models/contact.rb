class Contact < ActiveRecord::Base
  attr_accessible :authentication_id, :avatar, :invited, :name, :uid, :url, :username
end
