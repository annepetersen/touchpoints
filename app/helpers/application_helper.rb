# frozen_string_literal: true

require 'kramdown'

module ApplicationHelper
  def suppress_main_layout_flash?
    return true if flash && ['User successfully added', 'User successfully removed'].include?(flash.notice)
  end

  def to_markdown(text)
    return nil if text.blank?

    raw(sanitize(Kramdown::Document.new(text).to_html))
  end

  def organization_dropdown_options
    Organization.all.order(:name).map { |org| ["#{org.abbreviation} - #{org.name}", org.id] }
  end

  def organization_abbreviation_dropdown_options
    Organization.all.order(:name).map { |org| ["#{org.abbreviation} - #{org.name}", org.abbreviation] }
  end

  def hisp_questions_key
    {
      '1' => 'satisfaction',
      '2' => 'trust',
      '3' => 'effectiveness',
      '4' => 'ease',
      '5' => 'efficiency',
      '6' => 'transparency',
      '7' => 'employee',
    }
  end

  def collection_rating_label(rating:)
    case rating
    when 'TRUE'
      '🟢'
    when 'FALSE'
      '🔴'
    when 'PARTIAL'
      '🟡'
    end
  end

  # key = a Collection.rating
  # value = sort order
  def collection_rating_sort_values
    {
      'FALSE' => '1',
      'PARTIAL' => '2',
      'TRUE' => '3',
    }
  end

  # key = a Service.aasm_state
  # value = sort order
  def service_status_sort_values
    {
      'created' => '1',
      'submitted' => '2',
      'approved' => '3',
      'verified' => '4',
      'archived' => '5',
    }
  end

  # key = a Website.production_status
  # value = sort order
  def website_status_sort_values
    {
      'in_development' => '1',
      'production' => '2',
      'being_decommissioned' => '3',
      'redirect' => '4',
      'archived' => '5',
      'decommissioned' => '6',
    }
  end

  def website_status_label_tags(status)
    {
      'in_development' => 'bg-blue',
      'production' => 'bg-mint',
      'being_decommissioned' => 'bg-accent-warm-dark',
      'redirect' => 'bg-accent-warm-light',
      'archived' => 'bg-gray-30',
      'decommissioned' => 'bg-black',
    }[status]
  end

  # Returns javascript to capture form input for one Form Question
  def question_type_javascript_params(question)
    if question.question_type == 'text_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'hidden_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'date_select'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'text_email_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'text_phone_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'textarea'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'radio_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'star_radio_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'thumbs_up_down_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'big_thumbs_up_down_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'yes_no_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]\") && form.querySelector(\"input[name=#{question.answer_field}]\").value"
    elsif question.question_type == 'checkbox'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && Array.apply(null,form.querySelectorAll(\"input[name=#{question.answer_field}]:checked\")).map(function(x) {return x.value;}).join(',')"
    elsif %w[dropdown states_dropdown].include?(question.question_type)
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'text_display'
      'null'
    elsif question.question_type == 'custom_text_display'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    end
  end

  def is_at_least_form_manager?(user:, form:)
    user.admin? ||
      form.user_role?(user:) == UserRole::Role::FormManager
  end

  def current_path
    request.fullpath
  end

  def answer_fields
    %w[
      answer_01
      answer_02
      answer_03
      answer_04
      answer_05
      answer_06
      answer_07
      answer_08
      answer_09
      answer_10
      answer_11
      answer_12
      answer_13
      answer_14
      answer_15
      answer_16
      answer_17
      answer_18
      answer_19
      answer_20
    ]
  end

  # Legacy route from before the Form model was merged with the Touchpoint model
  def submit_touchpoint_uuid_url(form)
    "#{root_url}touchpoints/#{form.short_uuid}/submit"
  end

  def format_time(time, timezone)
    I18n.l time.to_time.in_time_zone(timezone), format: :long
  end

  def timezone_abbreviation(timezone)
    zone = ActiveSupport::TimeZone.new(timezone)
    zone.now.strftime('%Z')
  end

  def form_integrity_checksum(form:)
    data_to_encode = render(partial: 'components/widget/fba', formats: :js, locals: { form: })
    Digest::SHA256.base64digest(data_to_encode)
  end

  def s3_client
    Aws::S3::Client.new(
      region: ENV.fetch("S3_UPLOADS_AWS_REGION"),
      credentials: Aws::Credentials.new(
        ENV.fetch("S3_UPLOADS_AWS_ACCESS_KEY_ID"),
        ENV.fetch("S3_UPLOADS_AWS_SECRET_ACCESS_KEY")
      )
    )
  end

  def s3_service
    Aws::S3::Resource.new(client: s3_client)
  end

  def s3_presigner
    Aws::S3::Presigner.new(client: s3_client)
  end

  def s3_presigned_url(key)
    s3_presigner.presigned_url(
      :get_object,
      bucket: ENV.fetch("S3_UPLOADS_AWS_BUCKET_NAME"),
      key: key,
      expires_in: 5.minutes.to_i
    ).to_s
  end

  def fiscal_year_and_quarter(date)
    fiscal_year = date.year

    # Adjust fiscal year upward if the current month is October or later
    if date.month >= 10
      fiscal_year += 1
    end

    if [1,2,3].include?(date.month)
      fiscal_quarter = 2
    elsif [4,5,6].include?(date.month)
      fiscal_quarter = 3
    elsif [7,8,9].include?(date.month)
      fiscal_quarter = 4
    elsif [10,11,12].include?(date.month)
      fiscal_quarter = 1
    end

    [fiscal_year, fiscal_quarter]
  end
end
