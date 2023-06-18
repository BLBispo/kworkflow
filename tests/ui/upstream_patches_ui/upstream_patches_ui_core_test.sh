#!/bin/bash

include './src/ui/upstream_patches_ui/upstream_patches_ui_core.sh'
include './tests/utils.sh'

function setUp()
{
  screen_sequence['SHOW_SCREEN']=''

  export ORIGINAL_PATH="$PWD"

  cd "${SHUNIT_TMPDIR}" || {
    fail "($LINENO): setUp(): It was not possible to move into ${SHUNIT_TMPDIR}"
    return
  }
}

function tearDown()
{
  cd "${ORIGINAL_PATH}" || {
    fail "($LINENO): tearDown(): It was not possible to move into ${ORIGINAL_PATH}"
    return
  }
}

function test_dashboard_entry_menu_check_valid_options()
{
  # Mock Register list
  # shellcheck disable=SC2317
  function create_menu_options()
  {
    menu_return_string=1
  }

  dashboard_entry_menu
  assert_equals_helper 'Expected register screen' "$LINENO" "${screen_sequence['SHOW_SCREEN']}" 'registered_mailing_list'

  # Mock bookmarked
  # shellcheck disable=SC2317
  function create_menu_options()
  {
    menu_return_string=2
  }

  dashboard_entry_menu
  assert_equals_helper 'Expected register screen' "$LINENO" "${screen_sequence['SHOW_SCREEN']}" 'bookmarked_patches'
}

function test_dashboard_entry_menu_check_failed()
{
  local output

  # Mock failed scenario
  # shellcheck disable=SC2317
  function create_menu_options()
  {
    return 22
  }

  output=$(dashboard_entry_menu)
  assert_equals_helper 'Expected failure' "$LINENO" "$?" 22
}

function test_list_patches_with_patches()
{
  local target_array_list

  # shellcheck disable=SC2317
  function create_menu_options()
  {
    menu_return_string='3'
  }

  target_array_list=(
    'some_patch'
    'some_other_patch'
    'more_patches'
  )

  list_patches 'Message test' target_array_list 'show_new_patches_in_the_mailing_list' ''
  assert_equals_helper 'Expected screen' "$LINENO" "${screen_sequence['SHOW_SCREEN']}" 'series_details'
  assert_equals_helper 'Expected screen' "$LINENO" "${screen_sequence['SHOW_SCREEN_PARAMETER']}" 2

  list_patches 'Message test' target_array_list 'bookmarked_patches' ''
  assert_equals_helper 'Expected screen' "$LINENO" "${screen_sequence['SHOW_SCREEN']}" 'bookmarked_series_details'
  assert_equals_helper 'Expected screen' "$LINENO" "${screen_sequence['SHOW_SCREEN_PARAMETER']}" 2
}

function test_list_patches_without_patches()
{
  local target_array_list

  # shellcheck disable=SC2317
  function create_message_box()
  {
    return
  }

  target_array_list=()

  list_patches 'Message test' target_array_list 'show_new_patches_in_the_mailing_list' ''
  assert_equals_helper 'Expected screen' "$LINENO" "${screen_sequence['SHOW_SCREEN']}" 'dashboard'

  list_patches 'Message test' target_array_list 'bookmarked_patches' ''
  assert_equals_helper 'Expected screen' "$LINENO" "${screen_sequence['SHOW_SCREEN']}" 'dashboard'
}

function test_show_new_patches_in_the_mailing_list_title()
{
  declare current_mailing_list=''

  # shellcheck disable=SC2317
  function create_loading_screen_notification()
  {
    return
  }
  # shellcheck disable=SC2317
  function get_patches_from_mailing_list()
  {
    return
  }
  # shellcheck disable=SC2317
  function list_patches()
  {
    return
  }

  # Not returning from a (supposed) series detail screen should set "$current_mailing_list" global variable to "$1"
  screen_sequence['RETURNING']=''
  show_new_patches_in_the_mailing_list 'amd-gfx'
  assert_equals_helper 'Wrong "current_mailing_list" value' "$LINENO" 'amd-gfx' "$current_mailing_list"

  # Returning from a (supposed) series detail screen should use the old "$current_mailing_list" value
  screen_sequence['RETURNING']=1
  show_new_patches_in_the_mailing_list 'arbitrary-value'
  assert_equals_helper 'Wrong "current_mailing_list" value' "$LINENO" 'amd-gfx' "$current_mailing_list"
}

invoke_shunit