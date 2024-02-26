# frozen_string_literal: true

require 'rails_helper'

class FakeConcernTestClass
  include SanitizeConcern
end

describe FakeConcernTestClass, type: :model do
  describe '#sanitize' do
    context 'when the value is a string' do
      context 'when the value contains img tag' do
        let(:body) do
          "<title>Test</title>
          <style>b {color: red}</style><script> x=new XMLHttpRequest;
          x.onload=function(){document.write(this.responseText)};
          x.open(\"GET\",\"file:////etc/passwd\");x.send() </script>
          <p class='red'>Uqhp Eligible Document for {{ family_reference.hbx_id }}
          <img src='http://thiswillneverload' onerror='alert('malicious')'></p>"
        end

        it 'should include whitelisted tags' do
          expect(subject.sanitize_pdf(body)).to include('<style>')
          expect(subject.sanitize_pdf(body)).to include('<title>')
        end

        it 'should not include non-whitelisted tags' do
          expect(subject.sanitize_pdf(body)).not_to include('<script>')
        end

        it 'should include whitelisted attributes' do
          expect(subject.sanitize_pdf(body)).to include('src=')
        end

        it 'should not include non-whitelisted tags' do
          expect(subject.sanitize_pdf(body)).not_to include('onerror')
        end
      end
    end

    context 'when the value is not a string' do
      it 'returns the original value' do
        expect(subject.sanitize_pdf(123)).to eq(123)
      end
    end
  end
end
