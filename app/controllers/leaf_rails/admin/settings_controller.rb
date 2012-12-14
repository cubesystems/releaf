module LeafRails
  class Admin::SettingsController < Admin::BaseController
    def index
      #authorize! :manage, Settings

      @currencies =

      respond_to do |format|
        format.html
      end
    end

    def update
      #authorize! :manage, Settings

      %w[vat languages premium email_from accounts_admin_email orders_admin_email valid_currencies].each do |setting|
        unless params[setting].blank?
          val = case setting
          when 'languages'
            params[setting].split(',').map { |p| p.strip.downcase }
          when 'valid_currencies'
            params[setting].split(',').map { |p| p.strip.upcase }
          else
            params[setting]
          end
          Settings[setting] = val
        end
      end

      respond_to do |format|
        format.html { redirect_to admin_settings_url, notice: 'Setting was successfully updated.' }
      end
    end

  end
end
