# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # Rails.env.production? ? storage(:fog) : storage(:file)

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
     "fallback/" + [version_name, "default_avatar.png"].compact.join('_')
  end

  process :convert => 'png'
  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
     process :resize_to_limit => [126, 126]
  end

  version :avatar do
     process :resize_to_limit => [60, 60]
  end

  version :medium do
     process :resize_to_limit => [40, 40]
  end

  version :small do
     process :resize_to_limit => [28, 28]
  end

  version :tiny do
     process :resize_to_limit => [24, 24]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def filename
    super.chomp(File.extname(super)) + '.png' if original_filename
  end

end
