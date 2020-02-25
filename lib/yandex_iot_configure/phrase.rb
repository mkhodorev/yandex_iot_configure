module YandexIotConfigure
  class Phrase
    def self.compile(data)
      Phrase.new.phrases_parse(data)
    end

    def phrases_parse(data)
      result = []

      data.each do |item|
        if item.is_a?(String)
          result << item
        elsif item.is_a?(Array)
          result += phrases_parse_array(item)
        elsif item.is_a?(Hash)
          result += phrases_parse_hash(item)
        end
      end

      result.uniq
    end

    def phrases_parse_hash(data)
      prefix = data['prefix'] || []
      prefix = [prefix] if prefix.is_a?(String)

      phrase = data['phrase'] || []
      phrase = [phrase] if phrase.is_a?(String)

      postfix = data['postfix'] || []
      postfix = [postfix] if postfix.is_a?(String)

      result = []

      phrase.each do |w|
        result << w

        prefix.each do |pre|
          result << "#{pre} #{w}"

          postfix.each do |po|
            result << "#{pre} #{w} #{po}"
          end
        end

        postfix.each do |po|
          result << "#{w} #{po}"
        end
      end

      result
    end

    def phrases_parse_array(data)
      result = []
      data = expand_phrases_array(data)
      prepare_to_mix_array(data).each do |arr|
        result += mix_phrases(arr)
      end
      result
    end

    def permutation(data, index)
      array = data.dup
      result = []
      array.count.times do
        item = index % array.count
        index = (index / array.count).floor
        result << array.delete_at(item)
      end
      result.join(' ')
    end

    def mix_phrases(data)
      result = []
      count = (1..data.count).inject(:*) || 1
      count.times do |i|
        result << permutation(data, i)
      end
      result
    end

    def expand_phrases_array(data)
      result = []

      data.each do |d|
        if d.is_a?(String)
          result << d
        elsif d.is_a?(Array)
          result << d
        elsif d.is_a?(Hash)
          result << phrases_parse_hash(d)
        end
      end

      result
    end

    def prepare_to_mix_array(data)
      result = [[]]

      data.each do |item|
        if item.is_a?(Array)
          arrs = []

          result.each do |r|
            item.each { |i| arrs << (r.dup << i) }
          end

          result = arrs
        else
          result.map! { |r| r << item }
        end
      end

      result
    end
  end
end
