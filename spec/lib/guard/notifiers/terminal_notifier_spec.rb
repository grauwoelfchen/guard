require 'spec_helper'

describe Guard::Notifier::TerminalNotifier do
  let(:notifier) { described_class.new }

  before do
    described_class.stub(:require_gem_safely).and_return(true)
    stub_const 'TerminalNotifier::Guard', double(available?: true)
  end

  describe '.supported_hosts' do
    it { expect(described_class.supported_hosts).to eq %w[darwin] }
  end

  describe '.gem_name' do
    it { expect(described_class.gem_name).to eq 'terminal-notifier-guard' }
  end

  describe '.available?' do
    context 'host is not supported' do
      before { RbConfig::CONFIG.stub(:[]).with('host_os').and_return('mswin') }

      it 'do not require terminal-notifier-guard' do
        expect(described_class).to_not receive(:require_gem_safely)

        expect(described_class).to_not be_available
      end
    end

    context 'host is supported' do
      before { RbConfig::CONFIG.stub(:[]).with('host_os').and_return('darwin') }

      it 'requires terminal-notifier-guard' do
        expect(described_class).to receive(:require_gem_safely) { true }
        expect(described_class).to receive(:_register!) { true }

        expect(described_class).to be_available
      end

      context '.require_gem_safely fails' do
        before { expect(described_class).to receive(:require_gem_safely) { false } }

        it 'requires terminal-notifier-guard' do
          expect(described_class).to_not receive(:_register!)

          expect(described_class).to_not be_available
        end
      end

      context '._register! fails' do
        before do
          expect(described_class).to receive(:require_gem_safely) { true }
          expect(described_class).to receive(:_register!) { false }
        end

        it 'requires terminal-notifier-guard' do
          expect(described_class).to_not be_available
        end
      end
    end
  end

  describe '#notify' do
    context 'with options passed at initialization' do
      let(:notifier) { described_class.new(title: 'Hello', silent: true) }

      it 'uses these options by default' do
      expect(::TerminalNotifier::Guard).to receive(:execute).with(false,
                                                              title: 'Hello',
                                                              type: :success,
                                                              message: 'any message')

      notifier.notify('any message')
      end

      it 'overwrites object options with passed options' do
      expect(::TerminalNotifier::Guard).to receive(:execute).with(false,
                                                              title: 'Welcome',
                                                              type: :success,
                                                              message: 'any message')

      notifier.notify('any message', title: 'Welcome')
      end
    end

    it 'should call the notifier.' do
      expect(::TerminalNotifier::Guard).to receive(:execute).with(false,
                                                              title: 'any title',
                                                              type: :success,
                                                              message: 'any message')

      notifier.notify('any message', title: 'any title')
    end

    it "should allow the title to be customized" do
      expect(::TerminalNotifier::Guard).to receive(:execute).with(false,
                                                              title: 'any title',
                                                              message: 'any message',
                                                              type: :error)

      notifier.notify('any message', type: :error, title: 'any title')
    end

    context 'without a title set' do
      it 'should show the app name in the title' do
        expect(::TerminalNotifier::Guard).to receive(:execute).with(false,
                                                                title: 'FooBar Success',
                                                                type: :success,
                                                                message: 'any message')

        notifier.notify('any message', title: nil, app_name: 'FooBar')
      end
    end
  end

end
