class PrincipalPolicy < BasePolicy
  def method_missing(m, *args, &block)
    Current.user.admin
  end

  def new
    Current.user.admin
  end

  def create
    Current.user.admin
  end

  def edit
    Current.user.admin || Current.user.empresa != nil
  end

  def update
    Current.user.admin || Current.user.empresa != nil
  end

  def destroy
    Current.user.admin
  end

  def no_conformidad
    Current.user.admin || Current.user.empresa != nil
  end

  def estado_activos
    Current.user.admin || Current.user.empresa != nil
  end

  def defectos_activos
    Current.user.admin || Current.user.empresa != nil
  end
end
