# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "cyclopedio-sql"
  s.version     = "0.1.0"
  s.authors     = ["Aleksander Smywinski-Pohl","Krzysztof Wrobel"]
  s.email       = ["apohllo@o2.pl"]
  s.homepage    = "http://cycloped.io"
  s.summary     = %q{Parsing of Wikipedia dumps.}
  s.description = %q{The library is used to parse and extract data from SQL files containing Wikipedia dumps.}

  s.rubyforge_project = "cyclopedio-sql"

  if(system("git"))
    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  else
    s.files         = `find .`.split("\n")
  end
  s.require_paths = ["lib"]
end
