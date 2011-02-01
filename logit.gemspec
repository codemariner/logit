# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{logit}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Sayles"]
  s.date = %q{2011-02-01}
  s.description = %q{Easily add custom logging abilities to your Ruby or Rails application.}
  s.email = %q{ssayles@users.sourceforge.net}
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "lib/logit.rb"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "init.rb", "lib/logit.rb", "logit.gemspec", "Manifest"]
  s.homepage = %q{http://github.com/codemariner/logit}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Logit", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{logit}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Easily add custom logging abilities to your Ruby or Rails application.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
