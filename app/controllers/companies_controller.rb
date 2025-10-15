class CompaniesController < ApplicationController
  def index
    @query = params[:query]

    if @query.present?
      @companies = Company.search(@query).limit(50)
    else
      @companies = []
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
