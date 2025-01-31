class PrincipalPolicy < BasePolicy


  def new
    Current.user.admin || Current.user.crear
  end

  def create
    Current.user.admin || Current.user.crear
  end

  def edit
    Current.user.admin || Current.user.empresa != nil || Current.user.crear
  end

  def update
    Current.user.admin || Current.user.empresa != nil || Current.user.crear
  end

  def destroy
    Current.user.admin || Current.user.crear
  end

  def no_conformidad
    Current.user.admin || Current.user.empresa != nil || Current.user.crear
  end

  def estado_activos
    Current.user.admin || Current.user.empresa != nil || Current.user.crear
  end

  def defectos_activos
    Current.user.admin || Current.user.empresa != nil || Current.user.crear
  end


  def method_missing(m, *args, &block)
    Current.user.admin || Current.user.crear
  end
end
