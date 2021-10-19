# frozen_string_literal: true

FactoryBot.define do
  factory :template, class: 'Templates::TemplateModel' do
    title { 'IVL open enrollment notice' }
  end
end
