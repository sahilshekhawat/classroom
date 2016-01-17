OmniAuth.config.test_mode = true

VCR.use_cassette 'auth_user' do
  token = ENV['CLASSROOM_TEST_OWNER_GITHUB_TOKEN'] ||= 'some-token'
  user = Octokit::Client.new(access_token: token).user

  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
    'provider' => 'github',
    'uid'      => user.id.to_s,

    'extra' => { 'raw_info' => { 'site_admin' => false } },

    'credentials' => { 'token' => token }
  )
end
