class Survey < ActiveRecord::Base
  validates :question, :presence => true
  validates :yes_no, :presence => true

  belongs_to :product
end
