class Group < ApplicationRecord
  validates :number, presence: true


  has_many :rules, dependent: :destroy
  has_many :items, dependent: :restrict_with_exception
end
