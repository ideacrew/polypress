# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
  ckeditor/plugins/ajax/plugin.js
  ckeditor/plugins/dialogui/plugin.js
  ckeditor/plugins/dialog/plugin.js
  ckeditor/plugins/preview/plugin.js
  ckeditor/plugins/fontawesome/plugin.js
  ckeditor/plugins/button/plugin.js
  ckeditor/plugins/lineutils/plugin.js
  ckeditor/plugins/widgetselection/plugin.js
  ckeditor/plugins/notification/plugin.js
  ckeditor/plugins/toolbar/plugin.js
  ckeditor/plugins/widget/plugin.js
  ckeditor/plugins/clipboard/plugin.js
  ckeditor/plugins/token/plugin.js
  ckeditor/plugins/placeholder/plugin.js
  ckeditor/plugins/placeholder_select/plugin.js
  ckeditor/plugins/lineheight/plugin.js
  ckeditor/plugins/liquid/plugin.js
  ckeditor/plugins/strinsert/plugin.js
  ckeditor/plugins/pastefromword/plugin.js
  ckeditor/plugins/pastetools/plugin.js
  ckeditor/plugins/xml/plugin.js
]
