# Load dictionary
load './main_store.rb'

# gem install cmath
# for complex numbers log2
require 'cmath'

require 'parallel'

def clean_symbols(word)
  word.tr(
  "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
  "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
end

def scan_with_index(word, scan)
  res = []
  word.scan(scan) do |c|
   res << [c, $~.offset(0)[0]]
  end

  res
end

@possibilities = ["v", "a", "p"]
@comb = @possibilities.product(@possibilities, @possibilities, @possibilities, @possibilities)
@comb = @comb - @comb.find_all{|x| x.count("v") == 4 && x.count("a") == 1}

# remove accent and concact "magic list"
@words_clean = @dict.map{|w| clean_symbols(w) } + @ob.map{|w| clean_symbols(w) }
@frenq_sort = @words_clean.map{|x| x.chars}.reduce([Hash.new(0)] * 5) {|acc, x| (0..4).each do |i| acc[i][x[i]] += 1 end; acc }

@memo = {}
def possible_words(selected_word, pattern, words = @words_clean, exclude_words = [])
  return @memo[[selected_word, pattern, words, exclude_words]] if @memo[[selected_word, pattern, words, exclude_words]] != nil
  match_regex = ""

  list_of_letters_exists = []
  list_of_letters_doesnt_exist = []
  possition_for_new_letters = []
  pattern.each_with_index do |c, i|
    if c == 'a'
      list_of_letters_exists << selected_word[i]
      possition_for_new_letters << i
    elsif c == 'p'
      list_of_letters_doesnt_exist << selected_word[i]
      possition_for_new_letters << i
    end
  end

  pattern.each_with_index do |c, i|
    if c == 'p' || c == "a"
      if pattern.count("p") == 1 && pattern.count("a") == 1 && c == "p"
        index_a = pattern.find_index{|x,i| x == "a"}
        match_regex += selected_word[index_a]
      elsif pattern.count("v") == 3 && pattern.count("a") == 2 && c == "a"
        index_a = pattern.find_index.with_index{|x, ai| x == "a" && ai != i}
        match_regex += selected_word[index_a]
      else
        remove_letters = [selected_word[i]] + (list_of_letters_doesnt_exist - list_of_letters_exists)
        match_regex += "[#{remove_letters.uniq.join("^").prepend('^')}]"
      end
    elsif c == "v"
      match_regex += selected_word[i]
    else
      raise "some result that doesnt exist on the game -> #{c}"
    end
  end

  list_words = words.grep(Regexp.new(match_regex)) do |x|
    next if exclude_words.include?(x)
    next x if list_of_letters_exists.empty?
    possition_for_new_letters_temp = possition_for_new_letters

    exist_all_possible = list_of_letters_exists.drop_while do |w|

      search_word = scan_with_index(x, w).find do |pos|
        result = possition_for_new_letters_temp.include?(pos[1])
        possition_for_new_letters_temp = possition_for_new_letters_temp - [pos[1]]

        result
      end

      search_word != nil && search_word != []
    end == []

    exclude_dup = (list_of_letters_exists & list_of_letters_doesnt_exist)

    dups = true
    if exclude_dup != []
      dups = exclude_dup.map do |w|
        list_of_letters_exists.count(w) == x.chars.count(w)
      end.compact.uniq == [true]
    end

    dups && (exist_all_possible || list_of_letters_exists.empty?) ? x : nil
  end.compact

  @memo[[selected_word, pattern, words, exclude_words]] = list_words

  list_words
end

@memo_rank = {}
def rank_words_score(words = @words_clean)
  return @memo_rank[words] if @memo_rank[words] != nil

  size_clean_words = words.size
  comb_size = @comb.size
  freq = @words_clean.map{|x| x.chars.group_by(&:itself).transform_values(&:size) }.reduce({}) { |accum, x| accum.merge(x) { |_key, old, new| old + new  } }
  frenq_sort = @words_clean.map{|x| x.chars}.reduce([Hash.new(0)] * 5) {|acc, x| (0..4).each do |i| acc[i][x[i]] += 1 end; acc }

  rank_list = Parallel.map(words) do |selected_word|
    list_of_possible_words = stats_patterns_by_word(selected_word, words)

    sun_all_entry = list_of_possible_words.inject(0.0){|sum,x| sum + x.values[0][3] }

    avg_prob_freq = (selected_word.chars.map.with_index do |x, i|
      frenq_sort[i][x]/@words_clean.size.to_f
    end.sum() / 5.0)

    inf = - CMath.log2(avg_prob_freq)
    entry = avg_prob_freq * inf

    # puts "#{size_clean_words} -> #{selected_word} -> SUM: #{sun_all_entry} , SCORE_FREQ #{ entry}"

    {selected_word => [sun_all_entry, entry]}
  end

  pMin,pMax = rank_list.map{|x| x.values.first[0]}.minmax
  eMin,eMax = rank_list.map{|x| x.values.first[1]}.minmax
  px = (pMax-pMin).zero? ? 1 : (pMax-pMin).to_f
  ex = (eMax-eMin).zero? ? 1 : (eMax-eMin).to_f
  pMin ||= 0
  pMax ||= 0
  eMin ||= 0
  eMax ||= 0

  rank_list = rank_list.map{|x| {x.keys.first => x.values.first + [(x.values.first[0] - pMin)/px, (x.values.first[1] - eMin)/ex]}}

  rank_list = rank_list.sort_by{|a, b| (a.values.first[2] + a.values.first[3])/2.0 }.reverse

  @memo_rank[words] = rank_list

  rank_list
end

def write_first_rank()
  rank = rank_words_score()

  puts rank.first(20)

  puts rank.last(20)

  File.open("worlds.marshal", "w"){|to_file| Marshal.dump(rank, to_file)}

  rank
end

def write_rank_magic_word()
  rank = rank_words_score(@ob)

  puts rank.first(20)

  puts rank.last(20)

  File.open("magic_worlds.marshal", "w"){|to_file| Marshal.dump(rank, to_file)}

  rank
end

def pattern_for_target(target, word)
  pattern = word.chars.map.with_index do |c, i|
    if target[i] == c
      "v"
    elsif target.include?(c)
      scan_target = scan_with_index(target, c)
      scan_word = scan_with_index(word, c)
      diff_scan = scan_target - scan_word

      if diff_scan == []
        "p"
      else
        if scan_word.size > 1
          result = ""
          (scan_word - scan_target).each do |l, p|
            pos = diff_scan.first

            diff_scan = diff_scan - [pos]

            result = "a" if  (p == i)
            result = "p" if diff_scan == [] && result == ""
            break if result != ""
          end
          result
        else
          "a"
        end
      end
    else
      "p"
    end
  end
end

@wins = 0
def play_all_termos()
  @ob.each.with_index do |w, i|
    result = play_game(clean_symbols(w))
    @wins += 1 if result == "1"
    puts "#{@wins}/#{i+1}"
  end

  @wins
end

@rank1 = File.open("worlds.marshal", "r"){|from_file| Marshal.load(from_file)}
@wfreq = File.open("word_freq.marshal", "r"){|from_file| Marshal.load(from_file)}

def play_game(target, chances = 6)
  first_word = @rank1.sort_by{|a, b| [a.values.first[0], a.values.first[1]] }.last.keys.first
  exclude_words = [first_word]
  params = ["0", target, first_word, @words_clean, exclude_words, 0]
  chances.times do |i|
    params[5] = i
    params = process_engine(*params)

     case params[0]
     when "1"
       puts "GANHOU"
       return "1"
     when "-1"
       puts "perdeu"
       return "-1"
     end
  end

  puts "ERROUU todas - #{target}"
  return "-1"
end

def process_engine(result, target, word, word_cloud, exclude_words, attempt)
  puts "!!!!#{word}/#{target} - #{attempt}!!!!!"
  pattern = pattern_for_target(target, word)
  puts "!!!!#{pattern}!!!!!"

  return ["1", target, word, word_cloud, exclude_words] if pattern.count("v") == 5
  new_word_cloud = possible_words(word, pattern, word_cloud, exclude_words)
  new_word_cloud_size = new_word_cloud.size
  puts "!!!! CLOUD SIZE -> #{new_word_cloud_size} - #{attempt}!!!!!"
  second_word = nil

  if attempt >= 4 || new_word_cloud_size <= 10
    words = @wfreq.select{|x| new_word_cloud.include?(x[0]) }.sort_by{|a| a[1] }
    puts "!!!! RUN WFREQ #{words.last(10)} !!!!!"
    second_word = words.last[0] if words.size > 0
  end

  if second_word.nil?
    second_word = rank_words_score(new_word_cloud).sort_by{|a, b| [a.values.first[0], a.values.first[1]] }.last&.keys&.first
  end

  result = "0"
  result = "-1" if new_word_cloud.empty? || second_word == nil

  exclude_words.push(second_word)

  [result, target, second_word, new_word_cloud, exclude_words, attempt]
end

def stats_patterns_by_word(word, skip_zeros = true, words = @words_clean)
  @comb.map do |pattern|
    all_matches_size = possible_words(word, pattern, words).size
    next if all_matches_size.zero? && skip_zeros

    prob =  (all_matches_size / words.size.to_f)
    inf = - CMath.log2(prob)
    entry = prob * inf

    { pattern => [all_matches_size, prob, inf, entry ] }
  end.compact.flatten
end
