require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx
  include iterm2::stable
  include chrome
  include sublime_text
    sublime_text::package { 'Emmet':
    source => 'sergeche/emmet-sublime'
  }
  include spectacle
  include postgresql
  include mongodb
  include evernote
  include dropbox
  include tunnelblick
  include firefox
  include spotify
  include redis
  include imagemagick
  include virtualbox
  include steam
  include arduino
  include vlc
  include utorrent
  include zsh
  include ohmyzsh

  
  include osx::global::disable_key_press_and_hold
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::dock::autohide

  include osx::no_network_dsstores
  include osx::finder::show_all_on_desktop
  include osx::finder::unhide_library
  include osx::finder::show_hidden_files
  include osx::finder::enable_quicklook_text_selection
  include osx::universal_access::ctrl_mod_zoom
  include osx::universal_access::enable_scrollwheel_zoom

  osx::recovery_message { 'If this Mac is found, please send mail to mail@antoinemary.me': }

  class { 'osx::global::key_repeat_delay':
    delay => 0
  }

  boxen::osx_defaults { 'Sets the Speed With Which Mouse Movement Moves the Cursor':
    user   => $::boxen_user,
    domain => 'NSGlobalDomain',
    key    => 'com.apple.mouse.scaling',
    type   => 'float',
    value  => 10,
  }

  boxen::osx_defaults { 'Sets the Speed With Which Trackpad Movement Moves the Cursor':
      user   => $::boxen_user,
      domain => 'NSGlobalDomain',
      key    => 'com.apple.trackpad.scaling',
      type   => 'float',
      value  => 3.0,
    }

  boxen::osx_defaults { 'key repeat rate':
    user   => $::boxen_user,
    domain => 'NSGlobalDomain',
    key    => 'KeyRepeat',
    type   => 'float',
    value  => 2.0;
  }

  boxen::osx_defaults { 'Set the delay when auto-hiding the dock - Part 2':
    user   => $::boxen_user,
    domain => 'com.apple.dock',
    key    => 'autohide-time',
    type   => 'float',
    value  => 0,
    notify => Exec['killall Dock'];
  }

  boxen::osx_defaults { 'Set the Position of the Dock Relative to the Desktop':
    user   => $::boxen_user,
    key    => 'orientation',
    domain => 'com.apple.dock',
    value  => 'left',
    notify => Exec['killall Dock'];
  }

  boxen::osx_defaults { 'Set the Audio Bitpool for Bluetooth Audio Devices':
    user   => $::boxen_user,
    key    => '"Apple Bitpool Min (editable)"',
    domain => 'com.apple.BluetoothAudioAgent',
    value  => 50;
  }

  boxen::osx_defaults { 'Disable Dashboard':
    user   => $::boxen_user,
    key    => 'mcx-disabled',
    domain => 'com.apple.dashboard',
    value  => true,
    notify => Exec['killall Dock'];
  }


  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.6': }
  nodejs::version { 'v0.8': }
  nodejs::version { 'v0.10': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
