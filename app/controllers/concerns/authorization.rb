module Authorization
  extend ActiveSupport::Concern
  included do

    class NotAuthorizedError < StandardError; end

    rescue_from NotAuthorizedError do
      redirect_to home_path, alert: "No tienes permiso"
    end

    private

    def authorize! record = nil
      policy_class_name = controller_name.singularize
      policy_class_name = policy_class_name.include?('_') ? policy_class_name + '_policy' : policy_class_name + 'Policy'
      is_allowed = policy_class_name.classify.constantize.new(record).send(action_name)
      raise NotAuthorizedError unless is_allowed
    end

    def inspection_not_modifiable!(inspection)
      unless Current.user.admin? && inspection.ins_date > Date.today
        redirect_to inspection_path(inspection), alert: 'No puedes modificar esta inspección.'
      end
    end

  end
end