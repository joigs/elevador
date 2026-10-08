class StaticPagePolicy < BasePolicy


  def method_missing(m, *args, &block)
    Current.user.admin || Current.user.cotizar || Current.user.solicitar
  end


end