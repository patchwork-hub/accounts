module LogoHelper
  def mail_header_logo_image_url
    site_upload = SiteUpload.find_by(var: 'mail_header_logo')
    return '' unless site_upload&.file&.respond_to?(:url)

    if site_upload.file.respond_to?(:metadata)
      width  = site_upload.file.metadata[:width]
      height = site_upload.file.metadata[:height]
      if width == 320 && height == 80
        return generate_image_url(site_upload)
      end
    end

    if site_upload.file.respond_to?(:variant)
      resized = site_upload.file.variant(resize_to_fill: [320, 80]).processed
      url = Rails.application.routes.url_helpers.rails_blob_url(resized, only_path: true)
      timestamp = site_upload.updated_at&.to_i
      return "#{url}?#{timestamp}"
    end

    generate_image_url(site_upload)
  end

  def mail_footer_logo_image_url
    site_upload = SiteUpload.find_by(var: 'mail_footer_logo')

    return '' unless site_upload&.file&.respond_to?(:url)

    generate_image_url(site_upload)
  end

  def generate_image_url(image)
    file_url  = image.file.url
    timestamp = image.updated_at&.to_i
    "#{file_url}?#{timestamp}"
  end
end
