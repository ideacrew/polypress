/**
 * @license Copyright (c) 2003-2021, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function (config) {
  update_tokens(config);

  // This turns off formatting of CKEditor entities
  // when toggling between source and wysiwyg
  config.entities = false;

  // This turns off predictive html formatting when
  // toggled from wysiwyg to source
  config.htmlEncodeOutput = false;

  // This loads the editor with 1000px height
  config.height = 1000;

  // This regex preserves the double curly braces
  // for token insertions. Default behavior is to
  // convert them to html tags and any special
  // characters inside to ASCII
  config.protectedSource.push(/\{\{(.*?)\}\}/g);

  // This regex preserves the single curly braces
  // that have a % symbol at the start and end of
  // them. These are the conditionals within the
  // template. Default behavior is to convert
  // them to html tags and that breaks the template
  config.protectedSource.push(/\{\%(.*?)\%\}/g);

  // This regex preserves the new lines (line breaks)
  config.protectedSource.push(/\n/g);

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

  config.tokenStart = "{{ ";
  config.tokenEnd = " }}";
};
