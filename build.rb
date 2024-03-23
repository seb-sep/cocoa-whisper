require 'xcodeproj'
require 'find'

# create new pod
# %x{echo -e "iOS\nSwift\nYes\nNone\nNo" | pod lib create cocoa-whisper}

# Pull fresh version of WhisperKit and swift-transformers into pod folder
pod_name = 'cocoa-whisper'
if Dir.exist?("#{pod_name}/WhisperKit")
  %x{rm -rf #{pod_name}/WhisperKit}
end
# Dir.mkdir(deps_path)
Dir.chdir(pod_name) do
  whisperkit_repo = "git@github.com:argmaxinc/WhisperKit.git"
  tf_repo = "git@github.com:huggingface/swift-transformers.git"
  %x{git clone #{whisperkit_repo}}
  %x{git clone #{tf_repo}}
end


# Remove all files and folders from current directory path except those in the items array
def remove_unless(path, items)
  Dir.foreach(path) do |item|
    next if item == '.' or item == '..' or items.include?(item)
    # puts "Removing: #{path + item}"
    %x{rm -rf #{path + item}}
  end
end

# Remove extraneous files from WhisperKit and swift-transformers deps
remove_unless(pod_name + '/WhisperKit/', ['Sources'])
remove_unless(pod_name + '/WhisperKit/Sources/', ['WhisperKit'])
remove_unless(pod_name + '/swift-transformers/', ['Sources'])
remove_unless(pod_name + '/swift-transformers/Sources/', ['Generation', 'Hub', 'Models', 'Tokenizers', 'TensorUtils'])

# def remove_imports(path, imports)
#   Dir.foreach(path) do |file|
#     next if file == '.' or file == '..'
#     if File.directory?(file)
#       puts "Directory: #{file}"
#       remove_imports(file, imports)
#     elsif File.file?(file)
#       puts "File: #{file}"
#       text = File.read(file)
#       imports.each do |import|
#         text.gsub!(/^import #{import}.*$/, "")
#       end
#       File.open(file, "w") { |file| file.puts text }
#     end
#   end
# end


def remove_imports(search_path, imports)
  pattern = Regexp.new("^import (#{imports.join('|')})")
  Find.find(search_path) do |path|
    if File.file?(path) && File.extname(path) == '.swift'
      file_content = File.readlines(path)
      modified_content = file_content.reject { |line| line.chomp.match?(pattern) }

      File.open(path, "w") do |file|
        modified_content.each { |line| file.puts(line) }
      end
    end
    puts "Processed: #{path}"
  end
end

# Remove imports from WhisperKit and swift-transformers
hf_imports = ['Hub', 'Tokenizers', 'TensorUtils', 'Generation', 'Models']
remove_imports(pod_name + '/swift-transformers/Sources/', hf_imports)
remove_imports(pod_name + '/WhisperKit/Sources/', hf_imports)
# open project
proj_path = './_Pods.xcodeproj'
project = Xcodeproj::Project.open(proj_path)


# Target to add files to
target = project.targets.first

# Create a new group under the main group, if necessary
group = project.main_group.find_subpath('Development Pods', false)
group = group.find_subpath(pod_name, false)
# find/create root deps group
# group = group.find_subpath('deps', true)
# remove all files from deps group
group.clear


# Iterate through a directory of Swift code and copy it into an Xcode project
# cur_dir: the current path in the directory to copy
# acc_path: the path that accumulates in recursive calls
# group: the Xcode group to copy into
def add_code(cur_dir, acc_path, group)
  Dir.glob("#{cur_dir}/*").each do |path|
    if File.file?(path) && File.extname(path) == '.swift'
      # puts "File: #{path}"
      group.new_reference(path)
    elsif File.directory?(path)
      # puts "Directory: #{path}"
      add_code(path, "#{acc_path}/#{File.basename(path)}", group.new_group(File.basename(path)))
    end
  end
end

add_code(pod_name, "", group)

# Save the project file
project.save

# Run pod install
Dir.chdir('/Example') do
  %x{pod install}
end
