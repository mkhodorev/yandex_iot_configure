module YandexIotConfigure
  class Phrase
    def self.compile(data)
      Phrase.new.phrases_parse(data)
    end

    def phrases_parse(data)
      compile_all_phrases(data)
      mixed_and_combined_all_phrases(data)

      data.flatten!
      data.delete_if { |d| !d.is_a?(String) }
      data.uniq
    end

    def compile_all_phrases(data)
      data.each_with_index do |item, i|
        if item.is_a?(Array)
          compile_all_phrases(item)
        elsif item.is_a?(Hash)
          item.each do |key, value|
            value = compile_all_phrases(value)
          end
          data[i] = compile_phrases(item['compile']) if item.keys == ['compile']
        end
      end
      data
    end

    def mixed_and_combined_all_phrases(data)
      data.each_with_index do |item, i|
        if item.is_a?(Array)
          mixed_and_combined_all_phrases(item)
        elsif item.is_a?(Hash)
          item.each do |key, value|
            value = mixed_and_combined_all_phrases(value)
          end

          if item.keys == ['mix']
            data[i] = mix_phrases(item['mix'])
          elsif item.keys == ['combine']
            data[i] = combine_array(item['combine']).map { |x| x.join(' ') }
          end
        end
      end
      data.uniq!
      data
    end

    def compile_phrases(data)
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

    def combine_array(data)
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

    def mix_phrases(data)
      result = []
      combine_array(data).each do |arr|
        result += mix(arr)
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

    def mix(data)
      result = []
      count = (1..data.count).inject(:*) || 1
      count.times do |i|
        result << permutation(data, i)
      end
      result
    end
  end
end
