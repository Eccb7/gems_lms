class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :course, optional: true

  validates :content, presence: true, length: { maximum: 1000 }

  scope :between_users, ->(user1, user2) {
    where(
      "(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
      user1.id, user2.id, user2.id, user1.id
    )
  }
  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit -> { broadcast_message }

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end

  private

  def broadcast_message
    # Broadcast to recipient using Action Cable
    ActionCable.server.broadcast("messages_#{recipient_id}", {
      id: id,
      content: content,
      sender: sender.display_name,
      created_at: created_at.strftime('%H:%M')
    })
  end
end
