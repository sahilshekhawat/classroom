require 'rspec/rails'

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/support/cassettes'

  c.default_cassette_options = {
    serialize_with: :json,
    preserve_exact_body_bytes:  true,
    decode_compressed_response: true,
    record: ENV['TRAVIS'] ? :none : :once
  }

  # Application id
  c.filter_sensitive_data('<APPLICATION_TEST_GITHUB_CLIENT_ID>') do
    application_github_client_id
  end

  # Owner
  c.filter_sensitive_data('<CLASSROOM_TEST_OWNER_GITHUB_ID>') do
    classroom_test_owner_github_id
  end

  c.filter_sensitive_data('<CLASSROOM_TEST_OWNER_GITHUB_TOKEN>') do
    classroom_test_owner_github_token
  end

  # Organizations
  # Private Repos Plan
  c.filter_sensitive_data('<CLASSROOM_TEST_PRIVATE_REPOS_PLAN_ORGANIZATION_GITHUB_ID>') do
    classroom_test_private_repos_plan_organization_github_id
  end

  c.filter_sensitive_data('<CLASSROOM_TEST_PRIVATE_REPOS_PLAN_ORGANIZATION_GITHUB_LOGIN>') do
    classroom_test_private_repos_plan_organization_github_login
  end

  # Free Repos Plan
  c.filter_sensitive_data('<CLASSROOM_TEST_FREE_REPOS_PLAN_ORGANIZATION_GITHUB_ID>') do
    classroom_test_free_repos_plan_organization_github_id
  end

  c.filter_sensitive_data('<CLASSROOM_TEST_FREE_REPOS_PLAN_ORGANIZATION_GITHUB_LOGIN>') do
    classroom_test_free_repos_plan_organization_github_login
  end

  # Member
  c.filter_sensitive_data('<CLASSROOM_TEST_MEMBER_GITHUB_ID>') do
    classroom_member_github_id
  end

  c.filter_sensitive_data('<CLASSROOM_TEST_MEMBER_GITHUB_TOKEN>') do
    classroom_member_github_token
  end

  c.hook_into :webmock
end

def application_github_client_id
  ENV.fetch 'GITHUB_CLIENT_ID', 'i' * 20
end

def classroom_test_owner_github_id
  ENV.fetch 'CLASSROOM_TEST_OWNER_GITHUB_ID', 8_675_309
end

def classroom_test_owner_github_token
  ENV.fetch 'CLASSROOM_TEST_OWNER_GITHUB_TOKEN', 'x' * 40
end

def classroom_test_private_repos_plan_organization_github_id
  ENV.fetch 'CLASSROOM_TEST_PRIVATE_REPOS_PLAN_ORGANIZATION_GITHUB_ID', 1
end

def classroom_test_private_repos_plan_organization_github_login
  ENV.fetch 'CLASSROOM_TEST_PRIVATE_REPOS_PLAN_ORGANIZATION_GITHUB_LOGIN', 'classroom-testing-org'
end

def classroom_test_free_repos_plan_organization_github_id
  ENV.fetch 'CLASSROOM_TEST_FREE_REPOS_PLAN_ORGANIZATION_GITHUB_ID', 2
end

def classroom_test_free_repos_plan_organization_github_login
  ENV.fetch 'CLASSROOM_TEST_FREE_REPOS_PLAN_ORGANIZATION_GITHUB_LOGIN', 'the-justice-league'
end

def classroom_member_github_id
  ENV.fetch 'CLASSROOM_TEST_MEMBER_GITHUB_ID', 42
end

def classroom_member_github_token
  ENV.fetch 'CLASSROOM_TEST_MEMBER_GITHUB_TOKEN', 'q' * 40
end

def oauth_client
  Octokit::Client.new(access_token: classroom_test_owner_github_token)
end

def use_vcr_placeholder_for(text, replacement)
  VCR.configure do |c|
    c.define_cassette_placeholder(replacement) do
      text
    end
  end
end
