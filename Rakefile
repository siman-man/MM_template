require 'open3'
require 'rake/clean'
require 'parallel'

FILE_NAME = "solver"
EXEC_COMMAND = "./solver"
TESTER = "#{FILE_NAME}.jar"
SEED = 1

CLEAN.include %w(data/* *.gcda *.gcov *.gcno *.png)

desc 'c++ file compile'
task :compile do
  sh("g++ -std=c++20 -D__NO_INLINE__ -W -Wall -Wno-sign-compare -O3 -o #{FILE_NAME} #{FILE_NAME}.cpp")
  # sh("g++ -std=c++20 -W -Wall -g -fsanitize=address -fno-omit-frame-pointer -Wno-sign-compare -O2 -o #{FILE_NAME} #{FILE_NAME}.cpp")
end

desc 'exec and view result'
task run: [:compile] do
  sh("java -jar ./#{TESTER} -vis -seed #{SEED} -exec './#{FILE_NAME}'")
end

task manual: [:compile] do
  sh("java -jar ./#{TESTER} -manual -seed #{SEED}")
end

desc 'check single'
task one: [:compile] do
  sh("time java -jar #{TESTER} -seed #{SEED} -novis -exec './#{FILE_NAME}'")
end

desc "example test"
task sample: [:compile] do
  run_test(0..9)
end

desc "production test"
task test: [:compile] do
  run_test(1000..1100)
end

desc "system test"
task final: [:compile] do
  run_test(2001..3000)
end

desc "production test"
task production: [:compile] do
  run_test(10000..12000)
end

desc "check select seed"
task seeds: [:compile] do
  run_test(File.readlines("seeds.txt").map(&:to_i))
end

def run_test(seeds)
  results = Parallel.map(seeds, in_processes: 4) do |seed|
    print "\rseed = #{seed}"
    data = Open3.capture3("#{EXEC_COMMAND} < in/%04d.txt > out/%04d.txt" % [seed, seed])
    data += Open3.capture3("target/release/vis in/%04d.txt out/%04d.txt" % [seed, seed])
    [seed, data]
  end.to_h

  File.open("result.txt", "w") do |file|
    seeds.each do |seed|
      file.puts("----- !BEGIN! ------")
      file.puts("Seed = #{seed}")

      data = results[seed]
      file.puts(data.select { |d| d.is_a?(String) }.flat_map { |d| d.split("\n") })
      file.puts("----- !END! ------")
    end
  end

  ruby "scripts/analyze.rb #{seeds.size}"
end

task default: :compile

