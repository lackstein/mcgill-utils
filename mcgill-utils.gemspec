Gem::Specification.new do |s|
  s.name        = "mcgill-utils"
  s.version     = "0.2"
  s.platform    = Gem::Platform::RUBY
  s.author      = "Noah Lackstein"
  s.email       = "noah@lackstein.com"
  s.homepage    = "http://github.com/lackstein/mcgill"
  s.summary     = "Retrieve information for courses being offered by McGill"
  s.description = <<-EOF
    Crawl McGill's website and the Visual Schedule Builder to determine which
    courses are being offered and information (professor, timing, capacity) for each section
  EOF
  s.license     = "MIT"

  # If you have other dependencies, add them here
  s.add_runtime_dependency "nokogiri"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
end