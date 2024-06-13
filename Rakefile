task :default => [:download, :"extract:pages", :"extract:languages", :"extract:redirects", :"extract:categories",
		  :"extract:templates", :"extract:offsets", :"extract:disambiguation","extract:links",
                  :"extract:eponymy"
]

wikipedia_path = ENV['WIKI_DATA']
db = ENV['WIKI_DB']
lang = ENV['WIKI_LANG']
if wikipedia_path.nil?
  puts "WIKI_DATA has to be set"
  exit
end
if db.nil?
  puts "WIKI_DB has to be set"
  exit
end
if lang.nil?
  puts "Language not specified, assuming English (en)"
  lang = "en"
end

desc "Compile content offset computer"
task :compile do
  puts "Generating offset parser from Ragel"
  puts `ragel utils/content_offset.rl`
  puts "Compiling offset parser"
  puts `g++ -o utils/content_offset utils/content_offset.c`
end

desc "Download dumps"
task :download do
  puts `./utils/download.rb -w #{wikipedia_path} -l #{lang}`
end

namespace :extract do
  def extract(script,source_name,target_name,path,config)
    unless File.exist?("#{path}/#{source_name}.sql")
      puts "Uncomressing #{path}/#{source_name}.sql.gz"
      `gzip -c -d #{path}/#{source_name}.sql.gz > #{path}/#{source_name}.sql`
    end
    puts `ruby ./utils/#{script}.rb -f #{path}/#{source_name}.sql -o #{path}/#{target_name}.csv -c #{config}`
    `rm #{path}/#{source_name}.sql`
  end

  desc "Extract all"
  task :all => [:"extract:pages", :"extract:languages", :"extract:redirects", :"extract:categories", :"extract:templates", :"extract:offsets"]

  path = ENV['WIKI_DATA']
  if path.nil?
    puts "WIKI_DATA has to be set"
    exit
  end
  config = ENV['WIKI_CONFIG']
  if config.nil?
    puts "WIKI_CONFIG has to be set"
    exit
  end
  desc "Extract pages"
  task :pages do
    puts "Extracting pages"
    extract("convert_pages","page","page",path,config)
  end

  desc "Extract language links"
  task :languages do
    puts "Extracting languages"
    extract("convert_langlinks","langlinks","translations",path,config)
  end

  desc "Extract redirects"
  task :redirects do
    puts "Extracting redirects"
    file_name = "redirect"
    `gzip -c -d #{path}/#{file_name}.sql.gz > #{path}/#{file_name}.sql`
    puts `ruby ./utils/convert_redirects.rb -f #{path}/#{file_name}.sql -t #{path}/redirectTargetsBySource.csv -s #{path}/redirectSourcesByTarget.csv`
    `rm #{path}/#{file_name}.sql`
  end

  desc "Extract category links"
  task :categories do
    puts "Extracting category links"
    file_name = "categorylinks"
    `gzip -c -d #{path}/#{file_name}.sql.gz > #{path}/#{file_name}.sql`
    puts `ruby ./utils/convert_category_links.rb -f #{path}/#{file_name}.sql -o #{path}/`
    `rm #{path}/#{file_name}.sql`
  end

  desc "Extract templates"
  task :templates do
    puts "Extracting templates"
    extract("convert_templates","templatelinks","templates",path,config)
  end

  desc "Extract article links"
  task :links do
    puts "Extracting links"
    file_name = "pagelinks"
    `gzip -c -d #{path}/#{file_name}.sql.gz > #{path}/#{file_name}.sql`
    puts `ruby ./utils/convert_links.rb -f #{path}/#{file_name}.sql -t #{path}/linkByTarget.csv -s #{path}/linkBySource.csv`
    `rm #{path}/#{file_name}.sql`
  end

  desc "Extract page offsets"
  task :offsets do
    puts "Extracting offsets"
    file_name = "pages-articles"
    puts "Decompressing pages-articles. Makre sure lbzip2 is installed."
    `lbzip2 -d #{path}/#{file_name}.xml.bz2` if File.exist?("#{path}/#{file_name}.xml.bz2")
    puts "Extracting offsets"
    puts `./utils/content_offset #{path}/#{file_name}.xml > #{path}/offsets.csv`
  end

  desc "Extract disambiguation pages"
  task :disambiguation do
    puts "Extracting disambiguation pages"
    puts `./utils/find_disambiguation.rb -f #{path}/page.csv -t #{path}/templates.csv -c #{config}`
  end

  desc "Extract eponymous links"
  task :eponymy do
    puts "Extracting eponymous links"
    puts `./utils/find_eponymous.rb -o #{path}/eponymous_from_templates.csv -t #{path}/templates.csv -c #{config}`
  end

  desc "Extract infobox inclusion"
  task :infoboxes do
    puts "Extracting infobox inclusion"
    puts `./utils/extract_infoboxes.rb -o #{path}/infoboxes.csv -t #{path}/templates.csv`
  end
end
