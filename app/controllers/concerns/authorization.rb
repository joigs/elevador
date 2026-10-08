module Authorization
  extend ActiveSupport::Concern
  included do

    class NotAuthorizedError < StandardError; end

    rescue_from NotAuthorizedError do
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
    end

    private

    def authorize! record = nil
      policy_class_name = controller_name.singularize
      policy_class_name = policy_class_name.include?('_') ? policy_class_name + '_policy' : policy_class_name + 'Policy'
      is_allowed = policy_class_name.classify.constantize.new(record).send(action_name)
      raise NotAuthorizedError unless is_allowed
    end

    def inspection_not_modifiable!(inspection)
      unless Current.user.admin? && inspection.ins_date > Time.zone.today
        flash[:alert] = "No puedes modificar esta inspección."
        redirect_to inspection_path(inspection)
      end
    end

    def alcance_cliente(scope, columna = :principal_id)
      return scope unless Current.user&.cliente?

      scope.where(columna => Current.user.principal_ids)
    end

    def bloquear_cliente_fuera_de_empresa!(record)
      return false unless Current.user&.cliente?
      return false if Current.user.empresa_de?(record)

      flash[:alert] = "No tienes permiso"
      redirect_to destino_inicial, status: :see_other
      true
    end

  end
end