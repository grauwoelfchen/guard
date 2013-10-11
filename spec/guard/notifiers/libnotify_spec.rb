require 'spec_helper'

describe Guard::Notifier::Libnotify do
  let(:notifier) { described_class.new }

  before do
    described_class.stub(:require_gem_safely).and_return(true)
    stub_const 'Libnotify', double
  end

  describe '.supported_hosts' do
    it { expect(described_class.supported_hosts).to eq %w[linux freebsd openbsd sunos solaris] }
  end

  describe '.available?' do
    context 'host is not supported' do
      before { RbConfig::CONFIG.stub(:[]).with('host_os').and_return('mswin') }

      it 'do not require libnotify' do
        expect(described_class).to_not receive(:require_gem_safely)

        expect(described_class).to_not be_available
      end
    end

    context 'host is supported' do
      before { RbConfig::CONFIG.stub(:[]).with('host_os').and_return('linux') }

      it 'requires libnotify' do
        expect(described_class).to receive(:require_gem_safely) { true }

        expect(described_class).to be_available
      end
    end
  end

  describe '#notify' do
    context 'with options passed at initialization' do
      let(:notifier) { described_class.new(title: 'Hello') }

      it 'uses these options by default' do
        expect(::Libnotify).to receive(:show).with(
          transient: false,
          append:    true,
          timeout:   3,
          urgency:   :low,
          summary:   'Hello',
          body:      'Welcome to Guard',
          icon_path: '/tmp/welcome.png'
        )

        notifier.notify('Welcome to Guard', image: '/tmp/welcome.png')
      end

      it 'overwrites object options with passed options' do
        expect(::Libnotify).to receive(:show).with(
          transient: false,
          append:    true,
          timeout:   3,
          urgency:   :low,
          summary:   'Welcome',
          body:      'Welcome to Guard',
          icon_path: '/tmp/welcome.png'
        )

        notifier.notify('Welcome to Guard', title: 'Welcome', image: '/tmp/welcome.png')
      end
    end

    context 'without additional options' do
      it 'shows the notification with the default options' do
        expect(::Libnotify).to receive(:show).with(
          transient: false,
          append:    true,
          timeout:   3,
          urgency:   :low,
          summary:   'Welcome',
          body:      'Welcome to Guard',
          icon_path: '/tmp/welcome.png'
        )

        notifier.notify('Welcome to Guard', title: 'Welcome', image: '/tmp/welcome.png')
      end
    end

    context 'with additional options' do
      it 'can override the default options' do
        expect(::Libnotify).to receive(:show).with(
          transient: true,
          append:    false,
          timeout:   5,
          urgency:   :critical,
          summary:   'Waiting',
          body:      'Waiting for something',
          icon_path: '/tmp/wait.png'
        )

        notifier.notify('Waiting for something', type: :pending, title: 'Waiting', image: '/tmp/wait.png',
          transient: true,
          append:    false,
          timeout:   5,
          urgency:   :critical
        )
      end
    end
  end

end
