class Student < ApplicationRecord
  validates :cgpa, numericality: {
    greater_than_equal_to: 0.0,
    less_than_equal_to: 10.0
  }
end
