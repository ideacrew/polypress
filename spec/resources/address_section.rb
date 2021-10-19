# frozen_string_literal: true

# AddressSection
class AddressSection
  markup = <<~MARKUP
    {% assign primary_member = family.family_members | where: 'primary_member', true | first %}
    {% assign recipient = primary_member.person %}
    {% assign mailing_address = recipient.addresses | where: 'kind', 'mailing' | first %}

    <p>{{ recipient.person_name.first_name | capitalize }} {{ recipient.person_name.first_name | capitalize }}</p>
    <p>{{ mailing_address.address_line_1 }}</p>
    {% if mailing_address.address_line_2 and mailing_address.address_line_2.size > 0 %}
      <p>{{ mailing_address.address_line_2 }}</p>
    {% endif %}
    {% if mailing_address.address_line_3 and mailing_address.address_line_3.size > 0 %}
      <p>{{ mailing_address.address_line_3 }}</p>
    {% endif %}
    <p>{{ mailing_address.city }}, {{ mailing_address.state | upcase }} {{ mailing_address.zip }}</p>
  MARKUP

  Sections::Section.new(
    key: 'recipient_name_and_address',
    title: 'Recipient name and address',
    description: 'Recipient name and address',
    kind: 'component',
    section_body: {
      markup: markup,
      settings: {
        recipient_name: recipient_name,
        mailing_address: mailing_address
      }
    }
  )
end
