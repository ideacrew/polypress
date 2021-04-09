require 'rails_helper'

RSpec.describe NoticeKind, type: :model, dbclean: :around_each do
  describe '.set_data_elements' do
    subject { ::NoticeKind.new }

    let!(:template) { subject.build_template }
    let(:tokens) do
      [
        "person.is_applying_coverage",
        "person.first_name",
        "person.middle_name",
        "person.last_name",
        "person.name_sfx",
        "person.name_pfx",
        "person.dob",
        "person.gender",
        "person.is_veteran_or_active_military",
        "person.age_of_applicant",
        "person.ssn",
        "person.citizen_status",
        "person.is_resident_post_092296",
        "person.is_student"
      ]
    end

    before do
      allow(subject).to receive(:tokens).and_return(tokens)
      allow(subject).to receive(:conditional_tokens).and_return([])
    end

    it "should parse data elements for the template" do
      subject.set_data_elements
      expect(template.data_elements).to be_present
      expect(template.data_elements).to eq(tokens)
    end
  end
end
