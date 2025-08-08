class CategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_category, only: [ :show ]

  def index
    @categories = Category.includes(:courses).order(:name)
  end

  def show
    @courses = @category.courses.published.includes(:instructor, :enrollments)

    # Apply filters and sorting similar to courses controller
    if params[:search].present?
      @courses = @courses.search_by_title_and_description(params[:search])
    end

    if params[:difficulty].present?
      @courses = @courses.where(difficulty_level: params[:difficulty])
    end

    case params[:price_filter]
    when "free"
      @courses = @courses.where(price: 0)
    when "paid"
      @courses = @courses.where("price > 0")
    end

    case params[:sort]
    when "popular"
      @courses = @courses.popular
    when "newest"
      @courses = @courses.recent
    when "price_low"
      @courses = @courses.order(:price)
    when "price_high"
      @courses = @courses.order(price: :desc)
    else
      @courses = @courses.recent
    end

    @courses = @courses.page(params[:page])
    @difficulty_levels = Course.difficulty_levels.keys
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to categories_path, alert: "Category not found."
  end
end
