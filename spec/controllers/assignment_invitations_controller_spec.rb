require 'rails_helper'

RSpec.describe AssignmentInvitationsController, type: :controller do
  fixtures :assignments, :assignment_invitations, :organizations, :users

  describe 'GET #show', :vcr do
    let(:invitation) { assignment_invitations(:private_assignment_invitation) }

    context 'unauthenticated request' do
      it 'redirects the new user to sign in with GitHub' do
        get :show, id: invitation.key
        expect(response).to redirect_to(login_path)
      end
    end

    context 'authenticated request' do
      let(:user) { users(:classroom_member) }

      before(:each) do
        sign_in(user)
      end

      it 'will bring you to the page' do
        get :show, id: invitation.key
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PATCH #accept_invitation', :vcr do
    let(:assignment) { assignments(:private_assignment_with_starter_code) }
    let(:invitation) { assignment.assignment_invitation                   }

    let(:user)       { users(:classroom_member) }

    before(:each) do
      sign_in(user)
      request.env['HTTP_REFERER'] = "http://classroomtest.com/assignment-invitations/#{invitation.key}"
    end

    after(:each) do
      AssignmentRepo.destroy_all
    end

    it 'redeems the users invitation' do
      patch :accept_invitation, id: invitation.key
      expect(user.assignment_repos.count).to eql(1)
    end

    context 'github repository creation fails' do
      before do
        allow_any_instance_of(AssignmentRepo)
          .to receive(:create_github_repository)
          .and_raise(GitHub::Error)
      end

      it 'does not create a an assignment repo record' do
        patch :accept_invitation, id: invitation.key
        expect(assignment.assignment_repos.count).to eq(0)
      end
    end

    context 'github import fails' do
      before do
        allow_any_instance_of(GitHubRepository)
          .to receive(:get_starter_code_from)
          .and_raise(GitHub::Error)
      end

      it 'removes the repository on GitHub' do
        patch :accept_invitation, id: invitation.key
        expect(WebMock).to have_requested(:delete, %r{\A#{github_url('/repositories')}/\d+\z})
      end
    end
  end
end
