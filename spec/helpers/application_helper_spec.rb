require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context '#format_flash' do
    let(:name) { :notice }
    let(:msg) { 'Bootstrap 5.1 HTML for a dismissable flash message' }
    let(:html5_string) do
      "<div class=\"alert alert-success alert-dismissible fade show\" role=\"alert\">Bootstrap 5.1 HTML for a dismissable flash message\\n&lt;button type=&quot;button&quot; class=&quot;btn-close&quot; data-bs-dismiss=&quot;alert&quot; aria-label=&quot;Close&quot;&gt;&lt;/button&gt;</div>"
    end
    it 'should produce valid HTML5 tags' do
      expect(helper.format_flash(name, msg)).to eq html5_string
    end
  end
end
