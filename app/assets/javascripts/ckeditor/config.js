/**
 * @license Copyright (c) 2003-2021, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

[
  "fontawesome",
  "lineutils",
  "token",
  "placeholder",
  "placeholder_select",
  "lineheight",
  "liquid",
].forEach((element) => {
  CKEDITOR.plugins.addExternal(
    element,
    "/assets/ckeditor/plugins/" + element + "/plugin.js"
  );
});

CKEDITOR.editorConfig = function (config) {
  update_tokens(config);
  config.removeButtons =
    "Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,About,Print,Save,NewPage,Preview,Save,Language,Flash,Smiley,Image,Iframe";

  config.extraPlugins =
    "fontawesome,button,lineutils,widgetselection,notification,toolbar,widget,dialogui,dialog,clipboard,token,placeholder,placeholder_select,lineheight,liquid";
  CKEDITOR.dtd.$removeEmpty.span = 0;
  CKEDITOR.dtd.$removeEmpty.i = 0;
  config.allowedContent = true;
  config.font_names =
    "Open Sans;" +
    "Georgia;" +
    "Lucida Sans Unicode;" +
    "Tahoma;" +
    "Times New Roman/Times New Roman, Times, serif;" +
    "Trebuchet MS;" +
    "Verdana;";
  config.language = "en";

  config.tokenStart = "{{";
  config.tokenEnd = "}}";
};
