# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::SiteHelper, type: :helper, dbclean: :after_each do
  describe 'Site settings' do
    context '.site_name' do
      it 'should return application name' do
        expect(helper.site_name).to eq 'CoverME'
      end
    end

    context '.medicaid_agency_name' do
      it 'should return medicaid agency name' do
        expect(
          helper.medicaid_agency_name
        ).to eq 'Office for Family Independence'
      end
    end

    context '.medicaid_agency_phone' do
      it 'should return medicaid agency phone' do
        expect(helper.medicaid_agency_phone).to eq '(855) 797-4357'
      end
    end

    context '.marketplace_phone' do
      it 'should return contact center short phone number' do
        expect(helper.marketplace_phone).to eq '(866) 636-0355 TTY:711'
      end
    end

    context '.marketplace_shopping_name' do
      it 'should return shopping name' do
        expect(helper.marketplace_shopping_name).to eq 'Plan Compare'
      end
    end

    context '.contact_center_po_box' do
      it 'should return PO Box' do
        expect(helper.contact_center_po_box).to eq 'POB 616'
      end
    end

    context '.contact_center_zip_code' do
      it 'should return zip code' do
        expect(helper.contact_center_zip_code).to eq '04332-6626'
      end
    end
  end
end
