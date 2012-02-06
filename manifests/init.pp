class amavis (
  $managed_mail_domains
  ) {

  File { require => Package['amavisd-new'] }

  package { [ 'amavisd-new',
              'clamav',
              'clamav-daemon',
              'clamav-freshclam',
              'spamassassin'
            ]: ensure => present }
  
  user { 'clamav':
    ensure  => present,
    groups  => ['amavis'],
    require => Package['amavisd-new', 'clamav-daemon'],
  }
  
  service { 'amavis':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => 'amavis',
    require   => Package['amavisd-new'],
  }
  
  service { 'clamav-daemon':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package['clamav-daemon'],
  }

  service { 'clamav-freshclam':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package['clamav-daemon'],
  }

  file {'/etc/amavis/conf.d/50-user':
    ensure    => file,
    require   => Package['amavisd-new'],
    notify    => Service['amavis'],
    checksum  => md5,
    owner     => root,
    group     => root,
    mode      => '0644',
    content   => template('amavis/50-user.erb'),
  }

  file { '/var/lib/amavis/tmp':
    ensure => directory,
    mode   => '0775',
    owner  => 'amavis',
    group  => 'amavis',
  }
  file { '/var/lib/amavis/virusmails':
    ensure => directory,
    mode   => '0775',
    owner  => 'amavis',
    group  => 'amavis',
  }
}
