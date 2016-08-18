class CategorySet < ActiveRecord::Base
  validates :name, presence: true
  has_many :categories

  def inclusive?
    inclusive
  end

  def total
    # call flatten so we can use enumerable::sum, total is a virtual attribute
    categories.flatten.sum(&:total)
  end
end
