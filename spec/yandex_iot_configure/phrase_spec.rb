describe YandexIotConfigure::Phrase do
  let(:phrase) { YandexIotConfigure::Phrase.new }

  describe '#phrases_parse' do
    it 'when contains strings' do
      data = ['a', 'b', 'c']
      expect(phrase.phrases_parse(data)).to eql(data)
    end

    it 'when contains strings and duplicate arrays' do
      array = ['b', 'c']
      data = ['a', array, 'd', array]
      result = ['a', 'b', 'c', 'd']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and arrays' do
      data = ['a', ['b', 'c'], 'd', ['e', 'f']]
      result = ['a', 'b', 'c', 'd', 'e', 'f']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and nested arrays' do
      data = ['a', ['b', 'c', ['1', '2']], 'd']
      result = ['a', 'b', 'c', '1', '2', 'd']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and nested combined arrays' do
      data = ['a', { 'combine' => ['b', 'c', ['1', '2']] }, 'd']
      result = ['a', 'b c 1', 'b c 2', 'd']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and nested mix arrays' do
      data = ['a', ['b', 'c', { 'mix' => ['1', '2'] }], 'd']
      result = ['a', 'b', 'c', 'd', '1 2', '2 1']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and combined strings with nested mix arrays' do
      data = ['a', { 'combine' => ['b', 'c', { 'mix' => ['1', '2'] }] }, 'd']
      result = ['a', 'b c 1 2', 'b c 2 1', 'd']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and mixed arrays' do
      mix_array = { 'mix' => ['b', 'c'] }
      data = ['a', mix_array, 'd']
      result = ['a', 'b c', 'c b', 'd']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and compile phrase' do
      hash = { 'compile' => { 'prefix' => ['b', 'c'], 'phrase' => ['d'] } }
      hash_result = ['b d', 'c d', 'd']
      data = ['a', hash, 'e']
      result = ['a'] + hash_result + ['e']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and array with compile phrase and nested array' do
      hash_and_array = [ ['1', '2'], { 'compile' => { 'prefix' => ['b', 'c'], 'phrase' => ['d'] } } ]
      hash_and_array_result = ['1', '2', 'd', 'b d', 'c d']
      data = ['a', hash_and_array, 'e']
      result = ['a'] + hash_and_array_result + ['e']
      expect(phrase.phrases_parse(data)).to eql(result)
    end

    it 'when contains strings and array with combine compile phrase and nested array' do
      hash_and_array = { 'combine'=> [['1', '2'], { 'compile' => { 'prefix' => ['b', 'c'], 'phrase' => ['d'] } } ] }
      hash_and_array_result = ['1 b d', '1 c d', '1 d', '2 b d', '2 c d', '2 d']
      data = ['a', hash_and_array, 'e']
      result = ['a'] + hash_and_array_result + ['e']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when contains strings and array with mix compile phrase and mix nested array' do
      hash_and_array = { 'mix' => [ { 'mix' => ['1', '2'] }, { 'compile' => { 'prefix' => ['b', 'c'], 'phrase' => ['d'] } } ] }
      hash_and_array_result = [
        '1 2 b d', '1 2 c d', '1 2 d',
        'b d 1 2', 'c d 1 2', 'd 1 2',
        '2 1 b d', '2 1 c d', '2 1 d',
        'b d 2 1', 'c d 2 1', 'd 2 1'
      ]
      data = ['a', hash_and_array, 'e']
      result = ['a'] + hash_and_array_result + ['e']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'should create and return mixed phrases from array with nested hashes' do
      hash = { 'compile' => { 'prefix' => ['1'], 'phrase' => ['2'], 'postfix' => ['3'] } }
      data = [{ 'mix' => ['a', hash, 'b'] }]
      result = [
        'a 2 b', 'a b 2', '2 a b', '2 b a', 'b a 2', 'b 2 a',
        'a 1 2 b', 'a b 1 2', '1 2 a b', '1 2 b a', 'b a 1 2', 'b 1 2 a',
        'a 1 2 3 b', 'a b 1 2 3', '1 2 3 a b', '1 2 3 b a', 'b a 1 2 3', 'b 1 2 3 a',
        'a 2 3 b', 'a b 2 3', '2 3 a b', '2 3 b a', 'b a 2 3', 'b 2 3 a'
      ]
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end
  end

  describe '#compile_phrases' do
    it 'should create and return phrases from hash' do
      data = { 'prefix' => ['a', 'b'], 'phrase' => ['c'], 'postfix' => ['d', 'e'] }
      result = ['c', 'a c', 'b c', 'a c d', 'b c d', 'a c e', 'b c e', 'c d', 'c e']
      expect(phrase.compile_phrases(data).sort).to eql(result.sort)
    end
  end

  describe '#compile_all_phrases' do
    it 'should parse all data and compile phrases' do
      hash = { 'compile' => { 'prefix' => ['b', 'c'], 'phrase' => ['d'] } }
      hash_result = ['d', 'b d', 'c d']
      data = ['x', hash, ['y', hash, ['z', hash, 'x']], 'z']
      result = ['x', hash_result, ['y', hash_result, ['z', hash_result, 'x']], 'z']
      expect(phrase.compile_all_phrases(data)).to eql(result)
    end

    it 'should parse all data with mixed data and compile phrases' do
      hash = { 'compile' => { 'prefix' => ['b', 'c'], 'phrase' => ['d'] } }
      hash_result = ['d', 'b d', 'c d']
      mixed = { 'mix' => ['1', '2'] }
      data = ['x', hash, ['y', hash, mixed, 'z']]
      result = ['x', hash_result, ['y', hash_result, mixed, 'z']]
      expect(phrase.compile_all_phrases(data)).to eql(result)
    end
  end

  describe '#mixed_and_combined_all_phrases' do
    it 'should mix and return phrases from array' do
      data = [{ 'mix' => ['a', 'b', 'c'] }]
      result = [['a b c', 'b a c', 'c a b', 'a c b', 'b c a', 'c b a']]
      expect(phrase.mixed_and_combined_all_phrases(data)).to eql(result)
    end

    it 'should mix and return phrases from array with nested arrays' do
      data = [{ 'mix' => ['a', ['1', '2'], 'b'] }]
      result = [[
        'a 1 b', '1 a b', 'b a 1', 'a b 1', '1 b a', 'b 1 a',
        'a 2 b', '2 a b', 'b a 2', 'a b 2', '2 b a', 'b 2 a'
      ]]
      expect(phrase.mixed_and_combined_all_phrases(data)).to eql(result)
    end

    it 'should process item with strings and mixed arrays' do
      data = ['x', { 'mix' => ['a', ['1', '2'], 'b'] }, 'y']
      result = [
        'x',
        ['a 1 b', '1 a b', 'b a 1', 'a b 1', '1 b a', 'b 1 a',
         'a 2 b', '2 a b', 'b a 2', 'a b 2', '2 b a', 'b 2 a'],
        'y'
      ]
      expect(phrase.mixed_and_combined_all_phrases(data)).to eql(result)
    end

    it 'should mix and return phrases from array with combined array' do
      data = [{ 'mix' => ['a', { 'combine' => ['b', 'c'] }] }]
      result = [['a b c', 'b c a']]
      expect(phrase.mixed_and_combined_all_phrases(data)).to eql(result)
    end

    it 'should combine and return phrases from array with mixed array' do
      data = [{ 'combine' => ['a', { 'mix' => ['b', 'c'] }] }]
      result = [['a b c', 'a c b']]
      expect(phrase.mixed_and_combined_all_phrases(data)).to eql(result)
    end
  end

  describe '#combine_array' do
    it 'should return multiple arrays' do
      data = ['x', ['1', '2', '3'], 'y', ['a', 'b']]
      result = [
        ['x', '1', 'y', 'a'],
        ['x', '1', 'y', 'b'],
        ['x', '2', 'y', 'a'],
        ['x', '2', 'y', 'b'],
        ['x', '3', 'y', 'a'],
        ['x', '3', 'y', 'b']
      ]
      expect(phrase.combine_array(data)).to eql(result)
    end
  end

  describe '#permutation' do
    it 'should return permutation elements' do
      data = ['1', '2', '3', '4']
      expect(phrase.permutation(data, 1)).to eql('2 1 3 4')
    end
  end

  describe '#mix' do
    it 'should return mixed phrases' do
      data = ['1', '2', '3', '4']
      result = [
        '1 2 3 4', '1 2 4 3', '1 3 2 4', '1 3 4 2', '1 4 2 3', '1 4 3 2',
        '2 1 3 4', '2 1 4 3', '2 3 1 4', '2 3 4 1', '2 4 1 3', '2 4 3 1',
        '3 1 2 4', '3 1 4 2', '3 2 1 4', '3 2 4 1', '3 4 1 2', '3 4 2 1',
        '4 1 2 3', '4 1 3 2', '4 2 1 3', '4 2 3 1', '4 3 1 2', '4 3 2 1'
      ]
      expect(phrase.mix(data).sort).to eql(result.sort)
    end
  end

  describe '#mix_phrases' do
    it 'should create mix and return phrases from array' do
      data = ['x', ['c', 'a c', 'a c d', 'a c e', 'b c', 'b c d', 'b c e', 'c d', 'c e'], 'y']
      result = [
        'x c y', 'x a c y', 'x a c d y', 'x a c e y', 'x b c y', 'x b c d y', 'x b c e y', 'x c d y', 'x c e y',
        'y c x', 'y a c x', 'y a c d x', 'y a c e x', 'y b c x', 'y b c d x', 'y b c e x', 'y c d x', 'y c e x',
        'x y c', 'x y a c', 'x y a c d', 'x y a c e', 'x y b c', 'x y b c d', 'x y b c e', 'x y c d', 'x y c e',
        'y x c', 'y x a c', 'y x a c d', 'y x a c e', 'y x b c', 'y x b c d', 'y x b c e', 'y x c d', 'y x c e',
        'c y x', 'a c y x', 'a c d y x', 'a c e y x', 'b c y x', 'b c d y x', 'b c e y x', 'c d y x', 'c e y x',
        'c x y', 'a c x y', 'a c d x y', 'a c e x y', 'b c x y', 'b c d x y', 'b c e x y', 'c d x y', 'c e x y'
      ]
      expect(phrase.mix_phrases(data).sort).to eql(result.sort)
    end

    it 'should create and return mixed phrases from array' do
      data = ['a', 'b', 'c']
      result = ['a b c', 'a c b', 'b a c', 'b c a', 'c a b', 'c b a']
      expect(phrase.mix_phrases(data).sort).to eql(result.sort)
    end

    it 'should create and return mixed phrases from array with nested arrays' do
      data = ['a', ['1', '2'], 'b']
      result = [
        'a 1 b', 'a b 1', '1 a b', '1 b a', 'b 1 a', 'b a 1',
        'a 2 b', 'a b 2', '2 a b', '2 b a', 'b 2 a', 'b a 2'
      ]
      expect(phrase.mix_phrases(data).sort).to eql(result.sort)
    end
  end
end
