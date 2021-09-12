/**
 * @license Copyright (c) 2003-2021, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function (config) {
  update_tokens(config);
  config.removeButtons =
    "Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,About,Print,Save,NewPage,Save,Language,Flash,Smiley,Image,Iframe";

  config.extraPlugins =
    "a11yhelp,templates,ajax,dialogui,dialog,fontawesome5,button,lineutils,widgetselection,notification,toolbar,widget,clipboard,token,placeholder_select,lineheight,pastefromword,pastetools,xml";

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
  config.height = '600px';
  config.entities = false;

  config.tokenStart = "{{ ";
  config.tokenEnd = " }}";
};
