class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :email, presence: true
  validates :email, length: { maximum: 255 }
  validates :email, format: { with: Regex::Email::VALIDATE }
  validates :first_name, length: { maximum: 255 }
  validates :last_name, length: { maximum: 255 }

  enum role: { user: 0, admin: 1, super_admin: 2 }

  belongs_to :company, counter_cache: true

  after_initialize :setup_new_user, if: :new_record?
  before_validation :setup_company

  def name
    [first_name, last_name].join(' ').strip
  end

  private

  def setup_company
    return unless company.nil?

    self.company = Companies::Company.create!(name: 'My company')
    self.role = :admin # make this user the admin
  end

  def setup_new_user
    self.role ||= :user
  end
end
