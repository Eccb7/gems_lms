class Course < ApplicationRecord
  belongs_to :instructor
  belongs_to :category
end
