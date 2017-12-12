Warden::Manager.after_set_user except: :fetch do |user, _auth, _opts|
  if user&.member? && ! user.membership_current?
    user.update(member: false)
  end
end

# https://stackoverflow.com/questions/4753730/
# can-i-execute-custom-actions-after-successful-sign-in-with-devise
