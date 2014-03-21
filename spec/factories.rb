# @param _params [Hash]
# @return [User]
def create_user(_params = {})
  params = _params.clone
  params.reverse_merge! email:                 'szinin@gmail.com',
                        password:              'password',
                        password_confirmation: 'password',
                        first_name:            'sergei',
                        last_name:             'zinin',
                        is_profile_owner:      false

  AuthenticationManager.new(is_profile_owner:      params[:is_profile_owner],
                            email:                 params[:email],
                            password:              params[:password],
                            password_confirmation: params[:password_confirmation],
                            first_name:            params[:first_name],
                            last_name:             params[:last_name]).register
end

