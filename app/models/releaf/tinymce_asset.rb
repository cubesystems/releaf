module Releaf
  class TinymceAsset < ActiveRecord::Base
    self.table_name = 'releaf_tinymce_assets'
    file_accessor :file
  end
end
