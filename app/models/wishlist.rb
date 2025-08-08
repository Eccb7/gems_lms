class Wishlist < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id, message: "Course already in wishlist" }

  scope :recent, -> { order(created_at: :desc) }

  def self.toggle_for_user_and_course(user, course)
    wishlist_item = find_by(user: user, course: course)

    if wishlist_item
      wishlist_item.destroy
      false # Removed from wishlist
    else
      create!(user: user, course: course)
      true # Added to wishlist
    end
  end
end
