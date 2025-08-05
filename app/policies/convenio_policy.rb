class ConvenioPolicy < BasePolicy



  def method_missing(m, *args, &block)
    Current.user.cotizar
  end
end