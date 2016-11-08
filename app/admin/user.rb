ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :cellphone_number
    end
    f.actions
  end

  permit_params :email, :password, :password_confirmation, :cellphone_number

  controller do
    def update
      @user = User.find(params[:id])
      if params[:user][:password].blank?
        @user.update_without_password(permitted_params[:user])
      else
        @user.update_attributes(permitted_params[:user])
      end
      return if @user.admin? && params[:user][:cellphone_number].blank?
      authy = Authy::API.register_user(
          email: @user.email,
          cellphone: params[:user][:cellphone_number],
          country_code: "1")
      @user.update(authy_id: authy.id) if authy
    end
  end
end
