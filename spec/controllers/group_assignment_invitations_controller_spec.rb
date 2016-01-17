require 'rails_helper'

RSpec.describe GroupAssignmentInvitationsController, type: :controller do
  fixtures :groupings, :group_assignments, :group_assignment_invitations, :organizations, :users

  describe 'GET #show' do
    let(:invitation) { group_assignment_invitations(:private_group_assignment_invitation_with_starter_code) }

    context 'unauthenticated request' do
      it 'redirects the new user to sign in with GitHub' do
        get :show, id: invitation.key
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'PATCH #accept_invitation', :vcr do
    let(:group_assignment) { group_assignments(:private_group_assignment_with_starter_code) }
    let(:invitation)       { group_assignment.group_assignment_invitation                   }
    let(:organization)     { group_assignment.organization                                  }

    let(:user) { users(:classroom_member) }

    context 'authenticated request' do
      before(:each) do
        sign_in(user)
        request.env['HTTP_REFERER'] = "http://classroomtest.com/group-assignment-invitations/#{invitation.key}"
      end

      after(:each) do
        RepoAccess.destroy_all
        Group.destroy_all
        GroupAssignmentRepo.destroy_all
      end

      it 'redeems the users invitation' do
        patch :accept_invitation, id: invitation.key, group: { title: 'Code Squad' }

        expect(WebMock).to have_requested(:post, github_url("/organizations/#{organization.github_id}/teams"))
        expect(WebMock).to have_requested(:post, github_url("/organizations/#{organization.github_id}/repos"))

        expect(group_assignment.group_assignment_repos.count).to eql(1)
        expect(user.repo_accesses.count).to eql(1)
      end

      it 'does not allow users to join a group that is not apart of the grouping' do
        other_grouping = Grouping.create(title: 'Other Grouping', organization: organization)
        other_group    = Group.create(title: 'The Group', grouping: other_grouping)

        patch :accept_invitation, id: invitation.key, group: { id: other_group.id }

        expect(group_assignment.group_assignment_repos.count).to eql(0)
        expect(user.repo_accesses.count).to eql(0)
      end
    end
  end
end
