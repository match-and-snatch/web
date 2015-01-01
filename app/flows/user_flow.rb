class UserFlow < Flow

  factory do
    attr(:email).require.email.uniq
    vattr(:password).require.password
    vattr(:password_confirmation).require.equal_to -> { password }
  end
end