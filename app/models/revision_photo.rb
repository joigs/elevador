class RevisionPhoto < ApplicationRecord

  validates :code , presence: true

  belongs_to :revision
  has_one_attached :photo

  before_save :sanitize_filename



  scope :ordered_by_code, -> {
    select("revision_photos.*")
      .order(Arel.sql("
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(code, '.', 1), '.', -1) AS UNSIGNED),
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(code, '.', 2), '.', -1) AS UNSIGNED),
    CAST(IF(SUBSTRING_INDEX(SUBSTRING_INDEX(code, '.', 3), '.', -1) = '', '0', SUBSTRING_INDEX(SUBSTRING_INDEX(code, '.', 3), '.', -1)) AS UNSIGNED),
    CAST(IF(SUBSTRING_INDEX(SUBSTRING_INDEX(code, '.', 4), '.', -1) = '', '0', SUBSTRING_INDEX(SUBSTRING_INDEX(code, '.', 4), '.', -1)) AS UNSIGNED)
    "))
  }

  private

  # Method to set the filename of the photo to the record's ID
  def sanitize_filename
    if photo.attached?
      filename = photo.filename.to_s
      sanitized_filename = filename.gsub(/[^a-zA-Z0-9\.\-\_]+/, '_') # Sanitize to remove any non-alphanumeric, non-dash, non-underscore characters
      extension = File.extname(filename)
      base_name = File.basename(sanitized_filename, extension)
      new_filename = "#{base_name}#{extension}"

      # Attach the new file with sanitized name
      photo.blob.update!(filename: new_filename)
    end
  end
end

