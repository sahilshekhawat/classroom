class AssignmentInvitation < ActiveRecord::Base
  default_scope { where(deleted_at: nil) }

  update_index('stafftools#assignment_invitation') { self }

  has_one :organization, through: :assignment

  belongs_to :assignment

  validates :assignment, presence: true

  validates :key, presence:   true
  validates :key, uniqueness: true

  after_initialize :assign_key

  def redeem_for(invitee)
    if (repo_access = RepoAccess.find_by(user: invitee, organization: organization))
      assignment_repo = AssignmentRepo.find_by(assignment: assignment, repo_access: repo_access)
      return assignment_repo if assignment_repo.present?
    end

    assignment_repo = AssignmentRepo.find_by(assignment: assignment, user: invitee)
    return assignment_repo if assignment_repo.present?

    create_assignment_repo!(assignment, invitee)
  end

  def title
    assignment.title
  end

  def to_param
    key
  end

  protected

  def assign_key
    self.key ||= SecureRandom.hex(16)
  end

  private

  def create_assignment_repo!(assignment, invitee)
    AssignmentRepo.create!(assignment: assignment, user: invitee)
  rescue => err
    Rails.logger.error(err.message)
    raise
  end
end
