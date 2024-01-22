class ItemsController < ApplicationController
  before_action :authorize!
  def index
    @items = Item.all.order(name: :asc)
  end

  def show

  end

  # GET /items/new
  def new
    @category = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items or /.json
  def create
    @category = Item.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to items_url, notice: "Item was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    respond_to do |format|
      if category.update(category_params)
        format.html { redirect_to items_url, notice: "Category was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    category.destroy!

    respond_to do |format|
      format.html { redirect_to items_url, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def category
    @category = Category.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name)
  end
end
