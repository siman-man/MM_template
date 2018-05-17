require 'open3'
require 'rake/clean'
require 'parallel'

PROBLEM_NAME = ''
ROUND_ID = -1
TESTER = "#{PROBLEM_NAME}.jar"
SEED = 1

CLEAN.include %w(data/* *.gcda *.gcov *.gcno *.png)

desc 'c++ file compile'
task :compile do
  sh("g++ -std=c++11 -D__NO_INLINE__ -W -Wall -Wno-sign-compare -O2 -o #{PROBLEM_NAME} #{PROBLEM_NAME}.cpp")
end

desc 'exec and view result'
task run: [:compile] do
  sh("java -jar ./#{TESTER} -vis -seed #{SEED} -exec './#{PROBLEM_NAME}'")
end

task manual: [:compile] do
  sh("java -jar ./#{TESTER} -manual -seed #{SEED}")
end

desc 'check single'
task one: [:compile] do
  if ENV["debug"]
    sh("time java -jar #{TESTER} -seed #{SEED} -debug -novis -exec './#{PROBLEM_NAME}'")
  else
    sh("time java -jar #{TESTER} -seed #{SEED} -novis -exec './#{PROBLEM_NAME}'")
  end
end

desc 'check for windows'
task windows: [:compile] do
  sh("java -jar ./#{TESTER} -novis -seed #{SEED} -exec ./#{PROBLEM_NAME}.exe")
end

desc 'check out of memory'
task :debug do
  sh("g++ -std=c++11 -W -Wall -g -fsanitize=address -fno-omit-frame-pointer -Wno-sign-compare -O2 -o #{PROBLEM_NAME} #{PROBLEM_NAME}.cpp")
  sh("time java -jar #{TESTER} -seed #{SEED} -novis -exec './#{PROBLEM_NAME}'")
end

desc 'check how many called each function'
task :coverage do
  sh("g++ -W -Wall -Wno-sign-compare -o #{PROBLEM_NAME} --coverage #{PROBLEM_NAME}.cpp")
  sh("time java -jar #{TESTER} -seed #{SEED} -novis -exec './#{PROBLEM_NAME}'")
end

desc "example test"
task sample: [:compile] do
  run_test(1..10)
end

desc "production test"
task test: [:compile] do
  run_test(1000..1100)
end

desc "system test"
task final: [:compile] do
  run_test(2001..3000)
end

desc "system test production"
task production: [:compile] do
  run_test(10000..12000)
end

desc "check select seed"
task seeds: [:compile] do
  run_test(File.readlines("seeds.txt").map(&:to_i))
end

desc "create answere file"
task :submit do
  out = true
  File.readlines("#{PROBLEM_NAME}.cpp").each do |line|
    if line =~ /CUT_POINT/
      out = false
    elsif line =~ /CUT_END_POINT/
      out = true
    elsif out
      puts line
    end
  end
end

def run_test(seeds)
  results = Parallel.map(seeds, in_processes: 4) do |seed|
    puts "seed = #{seed}"
    data = Open3.capture3("time java -jar #{TESTER} -seed #{seed} -novis -exec './#{PROBLEM_NAME}'")
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

