# frozen_string_literal: true

module Effective
  module Datatables
    # Responsible to display all the notices
    class NoticesDatatable < Effective::MongoidDatatable
      datatable do

        bulk_actions_column do
          # bulk_action 'Delete', delete_notices_notice_kinds_path, data: { confirm: "Are you sure?", no_turbolink: true }
          # bulk_action 'Download', notifier.download_notices_notice_kinds_path, target: '_blank'
        end

        table_column :market_kind, :proc => proc { |row|
          row.market_kind.to_s.titleize
        }, :filter => false, :sortable => true
        table_column :mpi_indicator, :proc => proc { |row|
          prepend_glyph_to_text(row)
        }, :filter => false, :sortable => false
        table_column :title, :proc => proc { |row|
          link_to row.title, preview_notice_kind_path(row), target: '_blank'
        }, :filter => false, :sortable => false
        table_column :description, :proc => proc { |row|
          row.description
        }, :filter => false, :sortable => false
        table_column :recipient, :proc => proc { |row|
          row.recipient_klass_name.to_s.titleize
        }, :filter => false, :sortable => false
        table_column :last_updated_at, :proc => proc { |row|
          row.updated_at.in_time_zone('Eastern Time (US & Canada)').strftime('%m/%d/%Y %H:%M')
        }, :filter => false, :sortable => false
        table_column :actions, :width => '50px', :proc => proc { |row|
          dropdown = [
            ['Edit', edit_notice_kind_path(row), 'ajax'],
            ['Delete', delete_notice_notice_kind_path(row), 'delete ajax with confirm',  'Do you want to Delete this document?']
          ]
          render partial: 'datatables/shared/dropdown', locals: { dropdowns: dropdown, row_actions_id: "notice_actions_#{row.id}" }, formats: :html
        }, :filter => false, :sortable => false
      end

      def collection
        return @collection if defined? @collection
        notices = NoticeKind.all
        if attributes[:market_kind].present? && !['all'].include?(attributes[:market_kind]) && ['individual',
                                                                                                'shop'].include?(attributes[:market_kind])
          notices = notices.send(attributes[:market_kind])
        end
        @collection = notices
      end

      def nested_filter_definition
        {
          market_kind:
           [
             { scope: 'all', label: 'All' },
             { scope: 'individual', label: 'Individual' },
             { scope: 'shop', label: 'Shop' }
           ],
          top_scope: :market_kind
        }
      end
    end
  end
end
