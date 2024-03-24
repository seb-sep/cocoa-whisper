require 'xcodeproj'
require 'find'
require 'set'

# create new pod
# %x{echo -e "iOS\nSwift\nYes\nNone\nNo" | pod lib create cocoa-whisper}

pod_name = 'cocoa-whisper'

# remove assets and classes folder
%x{rm -rf #{pod_name}/Assets #{pod_name}/Classes}

# Pull fresh version of WhisperKit and swift-transformers into pod folder
if Dir.exist?("#{pod_name}/WhisperKit")
    %x{rm -rf #{pod_name}/WhisperKit}
end
if Dir.exist?("#{pod_name}/swift-transformers")
  %x{rm -rf #{pod_name}/swift-transformers}
end
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
    # puts "Processed: #{path}"
  end
end

# Remove imports from WhisperKit and swift-transformers
hf_imports = ['Hub', 'Tokenizers', 'TensorUtils', 'Generation', 'Models']
remove_imports(pod_name + '/swift-transformers/Sources/', hf_imports)
remove_imports(pod_name + '/WhisperKit/Sources/', hf_imports)

# replace fallbackTokenizerConfig with stub
# need to do this because Bundle.module seems to be undefined for this cocoapods project
# https://github.com/huggingface/swift-transformers/blob/4f915610451d29a05948802a140880ff37494dad/Sources/Hub/Hub.swift
# This should be fine, because tokenizers should not be used in a transcription module,
# and a stub is the most blatant way to mark this as a placeholder
hub_file = pod_name + '/swift-transformers/Sources/Hub/Hub.swift'

func_stub = <<~STUB
//\t This is a stubbed out version of the original function; it is not necessary.
//\t for use with Whisper and the call to Bundle.module.url does not seem to work in Cocoapods
\tstatic func fallbackTokenizerConfig(for modelType: String) -> Config? {
\t      return nil
\t}
STUB

processed_lines = []
brace_count = 0
in_func = false
content = File.read(hub_file)
content.each_line do |line|
  if line.strip.include?('static func fallbackTokenizerConfig')
    in_func = true
  end
  if in_func
    processed_lines << '// ' + line
    brace_count += line.count('{') - line.count('}')
    if brace_count == 0
      in_func = false
      processed_lines << func_stub
    end
  else
    processed_lines << line
  end
end

File.write(hub_file, processed_lines.join)


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
# seen_files: a set of files that have already been added to the project
def add_code(cur_dir, acc_path, group, seen_files=Set.new())
  Dir.glob("#{cur_dir}/*").each do |path|
    if File.file?(path) && File.extname(path) == '.swift'
      # puts "File: #{path}"
      name = File.basename(path)
      # rename file if there's another one with the same name by appending an underscore
      if seen_files.include?(name)
        new_path = File.dirname(path) + '/_' + name
        File.rename(path, new_path)
        seen_files.add('_' + name)
        group.new_reference(new_path)
      else
        seen_files.add(name)
        group.new_reference(path)
      end
    elsif File.directory?(path)
      # puts "Directory: #{path}"
      add_code(path, "#{acc_path}/#{File.basename(path)}", group.new_group(File.basename(path)), seen_files)
    end
  end
end

add_code(pod_name, "", group)

# Save the project file
project.save

# Run pod install
# system('ls')
Dir.chdir('Example') do
  %x{pod install}
end
