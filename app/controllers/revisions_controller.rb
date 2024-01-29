class RevisionsController < ApplicationController
  def show
    @inspection = Inspection.find(params[:id])
    @item = @inspection.item
    @group = @item.group
    @rules = @group.rules
  end
end
