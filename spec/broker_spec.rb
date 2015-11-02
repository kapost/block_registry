require 'spec_helper'

RSpec.describe BlockRegistry do
  let(:key) { 'user-register' }
  let(:block) { ->{} }

  describe '#register' do
    describe 'when the key is already registered' do
      before do
        subject.register(key, &block)
      end

      let(:block2) { ->{} }

      it 'does not raise an error' do
        expect { subject.register(key, &block2) }.to_not raise_error
      end
    end

    describe 'when the key is not already registered' do
      it 'does not raise an error' do
        expect { subject.register(key, &block) }.to_not raise_error
      end
    end
  end

  describe '#unregister' do
    before do
      subject.register(key, &block)
    end

    describe 'when a block is given' do
      let(:block) { ->(str) { str << 'foo' } }

      describe 'and it is the only handler for the key' do
        it 'unregisters the block' do
          subject.unregister(key, &block)
          expect { subject.handle(key, '') }.to raise_error(BlockRegistry::UnregisteredError)
        end

        it 'no longer has the key registered' do
          expect { subject.unregister(key, &block) }.to change { subject.registered?(key) }.from(true).to(false)
        end
      end

      describe 'and it is not the only handler for the key' do
        let(:block2) { ->(str) { str << 'bar' } }

        before do
          subject.register(key, &block2)
        end

        it 'unregisters the block' do
          subject.unregister(key, &block)
          str = ''
          expect { subject.handle(key, str) }.to change { str }.to('bar')
        end

        it 'still has the key registered' do
          expect { subject.unregister(key, &block) }.to_not change { subject.registered?(key) }.from(true)
        end
      end
    end

    describe 'when a block is not given' do
      it 'unregisters all handlers for the key' do
        expect { subject.unregister(key) }.to change { subject.registered?(key) }.from(true).to(false)
      end
    end
  end

  describe '#registered?' do
    describe 'when a key has been registered' do
      before do
        subject.register(key, &block)
      end

      it { is_expected.to be_registered(key) }
    end

    describe 'when a key has not been registered' do
      it { is_expected.to_not be_registered(key) }
    end
  end

  describe '#handle' do
    let(:args) { %w[foo bar] }
    let(:block) { ->(_, _) {} }

    describe 'when the key is registered' do
      before do
        subject.register(key, &block)
      end

      it 'processes the arguments' do
        expect(block).to receive(:call).with(*args)
        subject.handle(key, *args)
      end

      it 'does not raise an error' do
        expect { subject.handle(key, *args) }.to_not raise_error
      end
    end

    describe 'when the key is not registered' do
      it 'does not process the arguments' do
        expect(block).to_not receive(:call).with(*args)
        subject.handle(key, *args) rescue nil
      end

      it 'raises an error' do
        expect { subject.handle(key, *args) }.to raise_error(BlockRegistry::UnregisteredError)
      end
    end
  end
end
