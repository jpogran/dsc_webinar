Package{
  ensure => latest,
  provider => 'chocolatey',
}

reboot{ 'dsc_reboot':
  when    => pending,
}

package{ 'dotnet4.5.2':
  notify => Reboot['dsc_reboot'],
}->

package{ 'powershell':
  install_options => ['-pre'],
  notify          => Reboot['dsc_reboot'],
}->

dsc_windowsfeature{ 'iis':
  dsc_ensure => 'Present',
  dsc_name   => 'Web-Server',
}->

dsc_windowsfeature{ 'iisscriptingtools':
  dsc_ensure => 'Present',
  dsc_name   => 'Web-Scripting-Tools',
}->

dsc_windowsfeature{ 'aspnet45':
  dsc_ensure => 'Present',
  dsc_name   => 'Web-Asp-Net45',
}->

dsc_xwebsite{ 'defaultsite':
  dsc_ensure       => 'Absent',
  dsc_name         => 'Default Web Site',
  dsc_physicalpath => 'C:\\inetpub\\wwwroot',
}->

dsc_file{ 'websitefolder':
  dsc_ensure          => 'present',
  dsc_sourcepath      => 'c:\\vagrant\\artifacts\\website_code',
  dsc_destinationpath => 'c:\\inetpub\\foo',
  dsc_recurse         => true,
  dsc_type            => 'Directory',
}->

dsc_xwebapppool{ 'newwebapppool':
  dsc_name   => 'PuppetCodezAppPool',
  dsc_ensure => 'Present',
  dsc_state  => 'Started',
}->

dsc_xwebsite{ 'newwebsite':
  dsc_ensure          => 'Present',
  dsc_name            => 'PuppetCodez',
  dsc_state           => 'Started',
  dsc_physicalpath    => 'c:\\inetpub\\foo',
  dsc_applicationpool => 'PuppetCodezAppPool',
  dsc_bindinginfo     => {
    protocol => 'HTTP',
    port     => 8080,
  }
}
