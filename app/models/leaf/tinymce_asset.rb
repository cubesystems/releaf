module Leaf
  class TinymceAsset < ActiveRecord::Base
    self.table_name = 'leaf_tinymce_assets'
    file_accessor :file
  end
end
