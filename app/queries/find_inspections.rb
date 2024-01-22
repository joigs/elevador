class FindInspections

  attr_reader :inspections
  def initialize(inspections = initial_scope)
    @inspections = inspections
  end

  def call(params = {})
    scoped = inspections
    sort(scoped, params[:order_by])
  end



  private

  def initial_scope
    Inspection
  end

  def sort(scoped, order_by)
    order_by_query = Inspection::ORDER_BY.fetch(order_by&.to_sym, Inspection::ORDER_BY[:newest])
    scoped.order(order_by_query)
  end


end