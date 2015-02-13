require 'rugged'
require 'set'
require 'json'
require 'shellwords'

repo = Rugged::Repository.new '.'
lines_to_run = Set.new

repo.index.diff.each_patch { |patch|
  delta = patch.delta
  file = delta.old_file[:path]

  patch.each_hunk { |hunk|
    hunk.each_line { |line|
      if line.line_origin == :addition
        line = if line.new_lineno == -1
                 line.old_lineno
               else
                 line.new_lineno
               end
        lines_to_run << [file, line]
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

File.open('run_log.txt') do |f|
  f.each_line do |line|
    klass, method, before, after = JSON.parse line
    delta = diff before, after

    delta.each_pair do |file, lines|
      file_map = cov_map[file]

      lines.each_with_index do |val, i|
        next unless val && val > 0
        file_map[i + 1] << [klass, method]
      end
    end
  end
end

res = lines_to_run.flat_map do |file, line|
  cov_map[File.expand_path(file)][line].map do |klass, method|
    "#{klass}##{method}"
  end
end
puts Shellwords.escape("/#{res.join('|')}/")
