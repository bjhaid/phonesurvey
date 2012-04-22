class Product < ActiveRecord::Base
  validates :name, :presence => true
  validates :description, :presence => true

  belongs_to :user
  has_many :surveys
end
