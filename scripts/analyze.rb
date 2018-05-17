require 'fileutils'
require 'pathname'

class Analyze
  TSV_LABEL = ['seed', 'score', 'time'].join("\t")

  def initialize
    data_list = parse
    time_stamp = Time.now.strftime("%m%d-%H%m%S")

    result_file_path = Pathname.new(File.expand_path("data/record-#{time_stamp}.tsv", Dir.pwd))
    Dir.mkdir(result_file_path.dirname) unless File.exists?(result_file_path.dirname)
    @record = File.open(result_file_path, 'w')
    result = []

    begin
      @record.puts(TSV_LABEL)

      sum_score = 0.0
      seeds = []
      scores = []

      data_list.each do |data|
        data = clean_data(data)
        result << data

        seeds << data[:seed]
        scores << { seed: data[:seed], score: data[:score] }
        if data[:score] == 0.0
          sum_score += Float::INFINITY
        else
          sum_score += data[:score]
        end
        @record.puts(data.values.join("\t"))
      end

      scores.sort_by { |h| h[:seed] }.each do |data|
        puts data[:score]
      end
      puts "#{sum_score / data_list.size}"
    ensure
      @record&.close
    end
  end 

  def clean_data(data)
    seed = data['seed']&.to_i
    score = data['score']&.to_f
    /(?<minute>\d+)m(?<second>(\d|\.)+)s/ =~ data['user']
    time = minute.to_f * 60 + second.to_f
    width = data['width']&.to_i

    { seed: seed, score: score, time: time }
  end

  def parse
    filepath = File.expand_path('result.txt', Dir.pwd)
    data_list = []
    data = {}

    File.readlines(filepath).each do |line|
      line = clean_line(line)

      if line =~ /begin/
        data = {}
      elsif line =~ /!end!/
        data_list << data.dup
      else
        if validate(line)
          h = line2hash(line)
          data.merge!(h)
        end
      end
    end

    data_list
  end

  def line2hash(line)
    Hash[*line.split]
  end

  def clean_line(line)
    line.chomp.downcase.delete('=')
  end

  def validate(line)
    line =~ /^(score|seed|user)/
  end
end

Analyze.new
