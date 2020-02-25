describe YandexIotConfigure::Phrase do
  let(:phrase) { YandexIotConfigure::Phrase.new }

  describe '#phrases_parse' do
    it 'when all items are strings' do
      data = ['a', 'b', 'c']
      expect(phrase.phrases_parse(data)).to eql(data)
    end

    it 'when items with arrays' do
      array = ['b', 'c']
      data = ['a', array, 'd', array]
      result = ['a', 'b c', 'c b', 'd', 'b c', 'c b']
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end

    it 'when items with hashes' do
      hash = { 'prefix' => ['b', 'c'], 'phrase' => ['d'] }
      hash_result = ['b d', 'c d', 'd']
      data = ['a', hash, 'e', hash]
      result = ['a'] + hash_result + ['e'] + hash_result
      expect(phrase.phrases_parse(data).sort).to eql(result.sort)
    end
  end

  describe '#phrases_parse_hash' do
    it 'should create and return phrases from hash' do
      data = { 'prefix' => ['a', 'b'], 'phrase' => ['c'], 'postfix' => ['d', 'e'] }
      result = ['c', 'a c', 'b c', 'a c d', 'b c d', 'a c e', 'b c e', 'c d', 'c e']
      expect(phrase.phrases_parse_hash(data).sort).to eql(result.sort)
    end
  end

  describe '#expand_phrases_array' do
    it 'should expand array with hashes' do
      hash = { 'prefix' => ['a', 'b'], 'phrase' => ['c'], 'postfix' => ['d', 'e'] }
      data = ['x', hash, 'y']

      result = ['x', ['c', 'a c', 'a c d', 'a c e', 'b c', 'b c d', 'b c e', 'c d', 'c e'], 'y']
      expect(phrase.expand_phrases_array(data)).to eql(result)
    end

    it 'should expand array with nested arrays' do
      data = ['x', ['a', 'b'], 'y']
      result = ['x', ['a', 'b'], 'y']
      expect(phrase.expand_phrases_array(data)).to eql(result)
    end
  end

  describe '#prepare_phrases_array' do
    it 'should create and return phrases from array' do
      data = ['a', 'b', 'c']
      result = ['a b c', 'a c b', 'b a c', 'b c a', 'c a b', 'c b a']
      expect(phrase.phrases_parse_array(data).sort).to eql(result.sort)
    end

    it 'should create and return phrases from array with nested arrays' do
      data = ['a', ['1', '2'], 'b']
      result = [
        'a 1 b', 'a b 1', '1 a b', '1 b a', 'b 1 a', 'b a 1',
        'a 2 b', 'a b 2', '2 a b', '2 b a', 'b 2 a', 'b a 2'
      ]
      expect(phrase.phrases_parse_array(data).sort).to eql(result.sort)
    end

    it 'should create and return phrases from array with nested hashes' do
      hash = { 'prefix' => ['1'], 'phrase' => ['2'], 'postfix' => ['3'] }
      data = ['a', hash, 'b']
      result = [
        'a 2 b', 'a b 2', '2 a b', '2 b a', 'b a 2', 'b 2 a',
        'a 1 2 b', 'a b 1 2', '1 2 a b', '1 2 b a', 'b a 1 2', 'b 1 2 a',
        'a 1 2 3 b', 'a b 1 2 3', '1 2 3 a b', '1 2 3 b a', 'b a 1 2 3', 'b 1 2 3 a',
        'a 2 3 b', 'a b 2 3', '2 3 a b', '2 3 b a', 'b a 2 3', 'b 2 3 a'
      ]
      expect(phrase.phrases_parse_array(data).sort).to eql(result.sort)
    end
  end

  describe '#permutation' do
    it 'should return permutation elements' do
      data = ['1', '2', '3', '4']
      expect(phrase.permutation(data, 1)).to eql('2 1 3 4')
    end
  end

  describe '#mix_phrases' do
    it 'should return mixed phrases' do
      data = ['1', '2', '3', '4']
      result = [
        '1 2 3 4', '1 2 4 3', '1 3 2 4', '1 3 4 2', '1 4 2 3', '1 4 3 2',
        '2 1 3 4', '2 1 4 3', '2 3 1 4', '2 3 4 1', '2 4 1 3', '2 4 3 1',
        '3 1 2 4', '3 1 4 2', '3 2 1 4', '3 2 4 1', '3 4 1 2', '3 4 2 1',
        '4 1 2 3', '4 1 3 2', '4 2 1 3', '4 2 3 1', '4 3 1 2', '4 3 2 1'
      ]
      expect(phrase.mix_phrases(data).sort).to eql(result.sort)
    end
  end

  describe '#phrases_parse_array' do
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
      expect(phrase.phrases_parse_array(data).sort).to eql(result.sort)
    end
  end

  describe '#prepare_to_mix_array' do
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
      expect(phrase.prepare_to_mix_array(data)).to eql(result)
    end
  end
end
