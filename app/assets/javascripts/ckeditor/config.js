/**
 * @license Copyright (c) 2003-2021, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

[
  "widget",
  "dialog",
  "dialogui",
  "fontawesome",
  "lineutils",
  "token",
  "placeholder",
  "placeholder_select",
  "lineheight",
  "liquid",
  "strinsert",
  "preview",
  "pastefromword",
  "pastetools",
].forEach((element) => {
  CKEDITOR.plugins.addExternal(
    element,
    "/assets/ckeditor/plugins/" + element + "/plugin.js"
  );
});

CKEDITOR.editorConfig = function (config) {
  update_tokens(config);
  config.removeButtons =
    "Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,About,Print,Save,NewPage,Save,Language,Flash,Smiley,Image,Iframe";

  config.extraPlugins =
    "ajax,dialogui,dialog,preview,fontawesome,button,lineutils,widgetselection,notification,toolbar,widget,clipboard,token,placeholder,placeholder_select,lineheight,liquid,strinsert,pastefromword,pastetools,xml";

  CKEDITOR.dtd.$removeEmpty.span = 0;
  CKEDITOR.dtd.$removeEmpty.i = 0;

  // config.contentsCss = [
  //   CKEDITOR.basePath + "contents.css",
  //   "/path/to/custom.css",
  // ];

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

  config.tokenStart = "{{ ";
  config.tokenEnd = " }}";
};
