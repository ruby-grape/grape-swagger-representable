# Releasing Grape-Swagger-Representable

Publishing requires push access to the canonical repository, RubyGems ownership, and RubyGems multi-factor authentication.

## Prepare the release

Start with a clean checkout whose `origin` points to `ruby-grape/grape-swagger-representable`, not a fork:

```sh
git remote get-url origin
git switch master
git pull --ff-only origin master
git status --short
```

Set `GrapeSwagger::Representable::VERSION` in [lib/grape-swagger/representable/version.rb](lib/grape-swagger/representable/version.rb). Use a patch version for fixes and a minor version for new features or breaking changes while the gem is below 1.0.

Change the next-release heading in [CHANGELOG.md](CHANGELOG.md) to the release version and date, and remove `Your contribution here.`:

```markdown
### 0.3.0 (2026/10/27)
```

Review compatibility changes before publishing. Version 0.3.0 requires Ruby 3.1 or newer, grape-swagger 2.x, and Representable 3.2 or newer within the 3.x series.

Resolve dependencies if needed, then run lint and specs:

```sh
bundle install
bundle exec rubocop
bundle exec rake spec
```

Commit and push the release preparation normally:

```sh
git add CHANGELOG.md README.md RELEASING.md lib/grape-swagger/representable/version.rb
git commit -m "Prepare grape-swagger-representable 0.3.0"
git push origin master
```

Wait for the [test matrix](https://github.com/ruby-grape/grape-swagger-representable/actions/workflows/test.yml) and [RuboCop](https://github.com/ruby-grape/grape-swagger-representable/actions/workflows/rubocop.yml) to pass for that exact commit. Danger runs on pull requests, not direct release-preparation pushes to `master`.

## Publish

Confirm that the worktree is clean and that the version is not already published. Bundler's release task builds the gem, creates and pushes the version tag, and publishes to RubyGems:

```sh
bundle exec rake release
```

Supply a fresh RubyGems one-time password when requested. Never write credentials or one-time passwords to repository files. If publishing fails after pushing the tag, diagnose the failure and resume with `gem push pkg/grape-swagger-representable-0.3.0.gem`; do not move an existing release tag.

Verify the published gem's version and SHA256 against the local artifact, and confirm the remote tag points to the release commit:

```sh
gem specification pkg/grape-swagger-representable-0.3.0.gem version
shasum -a 256 pkg/grape-swagger-representable-0.3.0.gem
curl --fail https://rubygems.org/api/v2/rubygems/grape-swagger-representable/versions/0.3.0.json
git ls-remote origin 'refs/tags/v0.3.0*'
```

Create a non-draft GitHub release from that existing tag, using the matching changelog section for its notes:

```sh
gh release create v0.3.0 --repo ruby-grape/grape-swagger-representable \
  --verify-tag --title "grape-swagger-representable 0.3.0" --notes-file /path/to/release-notes.txt
```

## Prepare the next development version

After confirming publication, bump the version to the next patch development iteration and add a fresh changelog section. For example, after 0.3.0, set the version to `0.3.1` and prepend:

```markdown
### 0.3.1 (Next)

* Your contribution here.
```

Commit the version and changelog changes, and push `master` normally. Never force-push `master`, overwrite a published gem, or move an existing release tag.
