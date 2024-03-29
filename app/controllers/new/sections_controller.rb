# frozen_string_literal: true

module New
  # SectionsController
  class SectionsController < ApplicationController
    def new
      @section = Sections::SectionModel.new

      respond_to do |format|
        format.html
        format.js
      end
    end

    def edit
      @section = Sections::SectionModel.find(params[:id])
      @section.body = Bodies::BodyModel.new unless @section.body

      render layout: 'application'
    end

    def create
      filtered_section_params = section_params.to_h
      filtered_section_params[:key] =
        section_params.to_h[:title].split(/\s/).join('_').downcase

      result = Sections::SectionContract.new.call(filtered_section_params)
      if result.success?
        record = Sections::Section.new(result.to_h).create_model

        if record.success?
          flash[:notice] = 'Section created successfully'
          redirect_to action: :edit, id: record.success.id
        else
          @errors = Array.wrap(record.failure)
          @sections = Sections::SectionModel.all

          redirect_to controller: 'new/templates',
                      action: :index,
                      tab: 'sections'
        end
      else
        flash[:error] = "Unable to create section due to #{result.errors}"
        redirect_to controller: 'new/templates', action: :index, tab: 'sections'
      end
    end

    def update
      filtered_section_params = section_params.to_h
      filtered_section_params[:key] =
        section_params.to_h[:title].split(/\s/).join('_').downcase

      result = Sections::SectionContract.new.call(filtered_section_params)
      if result.success?
        Sections::Section.new(result.to_h).update_model(params['id'])
        flash[:notice] = 'Section content updated successfully'
        redirect_to controller: 'new/templates', action: :index, tab: 'sections'
      else
        flash[:error] = "Unable to update section due to #{result.errors}"
        render action: 'index'
      end
    end

    def destroy
      Sections::SectionModel.where(id: params['id']).first.delete

      flash[:notice] = 'Sections deleted successfully'
      redirect_to controller: 'new/templates', action: :index, tab: 'sections'
    end

    def instant_preview
      template =
        RenderLiquid.new.call(
          {
            body: instant_preview_params[:body],
            template: template_params,
            subject: instant_preview_params[:subject],
            key: instant_preview_params[:title].split(/\s/).join('_').downcase,
            cover_page: true,
            instant_preview: 'true',
            section_preview: true
          }
        )

      if template.success?
        @rendered_template = template.success[:rendered_template]
      else
        errors = template.failure
        errors = template.failure.errors if template.failure.respond_to?(
          :errors
        )
        @errors = Array.wrap(errors).flatten
      end
    end

    private

    def template_params
      {
        key: instant_preview_params[:title].split(/\s/).join('_').downcase,
        subject: instant_preview_params[:subject],
        title: instant_preview_params[:title],
        marketplace: instant_preview_params[:marketplace],
        body: {
          markup: instant_preview_params[:body]
        }
      }
    end

    def instant_preview_params
      params.permit(:body, :subject, :key, :title, :marketplace)
    end

    def section_params
      params
        .require(:section)
        .permit(*::Sections::SectionContract.params.key_map.dump)
    end
  end
end
