# frozen_string_literal: true

danger.import_dangerfile(gem: 'danger-pr-comment')

if git.added_files.include?('CHANGELOG.md')
  # Allow the initial changelog to document previously released versions.
  changelog.check!(unreleased_heading: nil)
else
  changelog.check!
end
