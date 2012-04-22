class Product < ActiveRecord::Base
  validates :name, :presence => true
  validates :description, :presence => true
  validates :tropo_number, :presence => true, :uniqueness => true

  belongs_to :user
  has_many :surveys

  after_create :provision_tropo_number

  protected

  def provision_tropo_number
    Resqueue.enqueue(TropoProvisioner, self.id)
  end

end
