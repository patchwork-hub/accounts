module LogoHelper
  def mail_header_logo_image_url
    site_upload = SiteUpload.find_by(var: 'mail_header_logo')

    return '' unless site_upload&.file&.respond_to?(:url)

    site_upload.file.url
  end

  def mail_footer_logo_image_url
    site_upload = SiteUpload.find_by(var: 'mail_footer_logo')

    return '' unless site_upload&.file&.respond_to?(:url)

    site_upload.file.url
  end
end
