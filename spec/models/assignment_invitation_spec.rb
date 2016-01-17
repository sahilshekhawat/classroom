require 'rails_helper'

RSpec.describe AssignmentInvitation, type: :model do
  fixtures :assignments, :assignment_invitations, :organizations, :users

  it_behaves_like 'a default scope where deleted_at is not present'

  it 'should have a key after initialization' do
    assignment_invitation = AssignmentInvitation.new
    expect(assignment_invitation.key).to_not be_nil
  end

  describe '#redeem_for', :vcr do
    subject { assignment_invitations(:private_assignment_invitation) }

    after(:each) do
      AssignmentRepo.destroy_all
    end

    it 'returns the AssignmentRepo' do
      assignment_repo = subject.redeem_for(users(:classroom_member))
      expect(assignment_repo).to eql(AssignmentRepo.last)
    end
  end

  describe '#title' do
    subject { assignment_invitations(:private_assignment_invitation) }

    it 'returns the assignments title' do
      assignment_title = subject.assignment.title
      expect(subject.title).to eql(assignment_title)
    end
  end

  describe '#to_param' do
    subject { assignment_invitations(:private_assignment_invitation) }

    it 'should return the key' do
      expect(subject.to_param).to eql(subject.key)
    end
  end
end
