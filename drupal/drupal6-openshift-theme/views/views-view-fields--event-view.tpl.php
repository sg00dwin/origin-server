<?php
/**
 * @file views-view-fields.tpl.php
 * Default simple view template to all the fields as a row.
 *
 * - $view: The view in use.
 * - $fields: an array of $field objects. Each one contains:
 *   - $field->content: The output of the field.
 *   - $field->raw: The raw data for the field, if it exists. This is NOT output safe.
 *   - $field->class: The safe class id to use.
 *   - $field->handler: The Views field handler object controlling this field. Do not use
 *     var_export to dump this object, as it can't handle the recursion.
 *   - $field->inline: Whether or not the field should be inline.
 *   - $field->inline_html: either div or span based on the above flag.
 *   - $field->separator: an optional separator that may appear before a field.
 * - $row: The raw result object from the query, with all data it fetched.
 *
 * @ingroup views_templates
 */
?>

<?php print $fields['phpcode']->content; ?>
<?php print $fields['title']->content; ?>
<div class="views-field-group-location">
  <span><?php print $fields['field_event_city_value']->content; ?></span>
  <span><?php print $fields['field_event_state_value']->content; ?></span>
  <span><?php print $fields['field_event_country_value']->content; ?></span>
</div>
<?php print $fields['field_event_short_description_value']->content; ?>
