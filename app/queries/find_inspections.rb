class FindInspections
  attr_reader :inspections

  def initialize(inspections = initial_scope)
    @inspections = inspections
  end

  def call(params = {})
    scoped = inspections
    scoped = filter_by_query_text(scoped, params[:query_text])
    sort(scoped, params[:order_by])
  end

  private

  def initial_scope
    Inspection.where("number > ?", 0)
  end

  def sort(scoped, order_by)
    order_by_query = Inspection::ORDER_BY.fetch(order_by&.to_sym, Inspection::ORDER_BY[:newest])
    scoped.order(order_by_query)
  end

  def filter_by_query_text(scoped, query_text)
    return scoped unless query_text.present?
    scoped.filter(text: query_text)
  end
end
