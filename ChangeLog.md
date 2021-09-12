# ChangeLog

## Version 0.7.0

### Improve Data Model

1. Update data model to enable Section component sharing between Templates

### Refactor for Abstraction

1. Refactor hard-coded notice references and substitute for end-user accessible and managed objects

### UI Fixes and Improvements

1. UI Framwork
   1. Replace DataTables with Bootstrap markup. Remove Datatables gem
   2. Switch UI base to Webpacker and Bootstrap 5
   3. Remove jquery
2. UI Workflow
   1. Move the Template metadata off of the Template editor page
   2. Move Template editor to it's own page and maximize the ckeditor window
   3. Create index, show, create and edit pages for Sections
   4. Review index page anchor tag behavior
3. ckeditor fixes
   1. Enable paste from Word docs and other sources
   2. Fix highlighting for Liquid tags
      1. {{ }} - yellow highlight
      2. {% %} - green highlight
   3. Enable entry of tags with custom tokens
   4. Enable evaluation of internal tags, e.g. {% assign %}
   5. Enable evaluation of section tag, e.g. {% section %}
   6. Move ckeditor widget into new page with proper size adjusted based on window size
   7. Add assign, section to condition/loop dropdown
   8. Move application settings into tokens dropdown
   9. Rename Application Settings dropdown to insert section dropdown
   10. Add ability to insert emtpy token from tokens dropdown


### Error Reporting Improvements

1. Provide more informative error feedback to end user
