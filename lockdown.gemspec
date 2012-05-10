# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lockdown}
  s.version = "2.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Stone"]
  s.date = %q{2010-10-10}
  s.description = %q{Restrict access to your controller actions. }
  s.email = %q{andy@stonean.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "README.md",
     "Rakefile",
     "lib/lockdown.rb",
     "lib/lockdown/access.rb",
     "lib/lockdown/configuration.rb",
     "lib/lockdown/database.rb",
     "lib/lockdown/delivery.rb",
     "lib/lockdown/errors.rb",
     "lib/lockdown/frameworks/rails.rb",
     "lib/lockdown/frameworks/rails/controller.rb",
     "lib/lockdown/frameworks/rails/view.rb",
     "lib/lockdown/helper.rb",
     "lib/lockdown/orms/active_record.rb",
     "lib/lockdown/permission.rb",
     "lib/lockdown/resource.rb",
     "lib/lockdown/session.rb",
     "lib/lockdown/user_group.rb",
     "lockdown.gemspec",
     "test/helper.rb",
     "test/lockdown/test_access.rb",
     "test/lockdown/test_configuration.rb",
     "test/lockdown/test_delivery.rb",
     "test/lockdown/test_helper.rb",
     "test/lockdown/test_permission.rb",
     "test/lockdown/test_resource.rb",
     "test/lockdown/test_session.rb",
     "test/lockdown/test_user_group.rb"
  ]
  s.homepage = %q{http://stonean.com/wiki/lockdown}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{lockdown}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Authorization system for Rails}
  s.test_files = [
    "test/lockdown/test_user_group.rb",
     "test/lockdown/test_delivery.rb",
     "test/lockdown/test_configuration.rb",
     "test/lockdown/test_access.rb",
     "test/lockdown/test_session.rb",
     "test/lockdown/test_permission.rb",
     "test/lockdown/test_helper.rb",
     "test/lockdown/test_resource.rb",
     "test/helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

