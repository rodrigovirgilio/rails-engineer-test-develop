module Admin
  class CompaniesController < ApplicationController
    def index
      @companies_count = Company.count
    end

    def import
      unless params[:file].present?
        redirect_to admin_companies_path, alert: 'Please select a CSV file.'
        return
      end

      file = params[:file]

      unless file.content_type == 'text/csv' || file.original_filename.end_with?('.csv')
        redirect_to admin_companies_path, alert: 'Please upload a valid CSV file.'
        return
      end

      result = Company.import_from_csv(file)

      if result[:errors].empty?
        redirect_to admin_companies_path, notice: "#{result[:count]} empresas importadas com sucesso!"
      else
        flash[:alert] = "#{result[:count]} imported companies. Errors found: #{result[:errors].first(5).join('; ')}"
        redirect_to admin_companies_path
      end
    rescue => e
      redirect_to admin_companies_path, alert: "Error importing file: #{e.message}"
    end

    def destroy_all
      count = Company.count
      Company.destroy_all
      redirect_to admin_companies_path, notice: "#{count} companies successfully removed!"
    end
  end
end
