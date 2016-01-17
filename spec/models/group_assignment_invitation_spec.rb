require 'rails_helper'

RSpec.describe GroupAssignmentInvitation, type: :model do
  fixtures :groupings, :group_assignments, :group_assignment_invitations, :organizations, :users

  it 'should have a key after initialization' do
    group_assignment_invitation = GroupAssignmentInvitation.new
    expect(group_assignment_invitation.key).to_not be_nil
  end

  describe '#redeem_for', :vcr do
    let(:invitee) { users(:classroom_member)                                           }
    subject       { group_assignment_invitations(:private_group_assignment_invitation) }

    after(:each) do
      RepoAccess.destroy_all
      Group.destroy_all
      GroupAssignmentRepo.destroy_all
    end

    it 'returns the GroupAssignmentRepo' do
      subject.redeem_for(invitee, nil, 'Code Squad')
      expect(GroupAssignmentRepo.count).to eql(1)
    end
  end

  describe '#title' do
    subject { group_assignment_invitations(:private_group_assignment_invitation) }

    it 'returns the group assignments title' do
      expect(subject.title).to eql(subject.group_assignment.title)
    end
  end

  describe '#to_param' do
    subject { group_assignment_invitations(:private_group_assignment_invitation) }

    it 'should return the key' do
      expect(subject.to_param).to eql(subject.key)
    end
  end
end
