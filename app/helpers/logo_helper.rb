module LogoHelper
  def app_icon_image_url(size = '48')
    site_upload = SiteUpload.find_by(var: 'app_icon')

    return '' unless site_upload&.file&.respond_to?(:url)

    site_upload.file.url(size)
  end
end
