require 'json'
require 'shellwords'

require 'rugged'
require 'set'

repo = Rugged::Repository.new '.'
lines_to_run = Set.new

repo.index.diff.each_patch { |patch|
  file = patch.delta.old_file[:path]

  patch.each_hunk { |hunk|
    hunk.each_line { |line|
      case line.line_origin
      when :addition
        lines_to_run << [file, line.new_lineno]
      when :deletion
        lines_to_run << [file, line.old_lineno]
      when :context
        # do nothing
      end
    }
  }
}

def diff before, after
  after.each_with_object({}) do |(file_name,line_cov), res|
    before_line_cov = before[file_name]

    # skip arrays that are exactly the same
    next if before_line_cov == line_cov

    # subtract the old coverage from the new coverage
    cov = line_cov.zip(before_line_cov).map do |line_after, line_before|
      if line_after
        line_after - line_before
      else
        line_after
      end
    end

    # add the "diffed" coverage to the hash
    res[file_name] = cov
  end
end

cov_map = Hash.new { |h, file| h[file] = Hash.new { |i, line| i[line] = [] } }

File.open('run_log.json') do |f|
  # Read in the coverage info
  JSON.parse(f.read).each do |args|
    if args.length == 4
      desc = args.first(2).join('#')
    else
      desc = args.first
    end

    before, after = args.last(2)

    # calculate the per test coverage
    delta = diff before, after
    p delta

    delta.each_pair do |file, lines|
      file_map = cov_map[file]

      lines.each_with_index do |val, i|
        # skip lines that weren't executed
        next unless val && val > 0

        # add the test name to the map. Multiple tests can execute the same
        # line, so we need to use an array.
        file_map[i + 1] << desc
      end
    end
  end
end

lines_to_run.each do |file, line|
  cov_map[File.expand_path(file)][line].each do |desc|
    puts desc
  end
end
