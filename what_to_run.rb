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
  r = after.each_with_object({}) do |(k,v), res|
    cov = v.zip(before[k]).map do |line_after, line_before|
      if line_after
        line_after - line_before
      else
        line_after
      end
    end
    res[k] = cov
  end
  r.delete_if { |_, v| v.all? { |line| line.nil? || line == 0 } }
  r
end

cov_map = Hash.new { |h, file|
  h[file] = Hash.new { |i, line|
    i[line] = []
  }
}

File.open('run_log.json') do |f|
  JSON.parse(f.read).each do |desc, before, after|
    delta = diff before, after

    delta.each_pair do |file, lines|
      file_map = cov_map[file]

      lines.each_with_index do |val, i|
        next unless val && val > 0
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
