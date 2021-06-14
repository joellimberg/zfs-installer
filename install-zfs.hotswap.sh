c_default_dataset_create_options='
ROOT                           mountpoint=/ com.ubuntu.zsys:bootfs=yes com.ubuntu.zsys:last-used=$(date +%s)
'

function check_prerequisites {
  :
}

function configure_and_update_grub_Debian {
  chroot_execute "perl -i -pe 's/GRUB_CMDLINE_LINUX_DEFAULT=\"\K/init_on_alloc=0 /'        /etc/default/grub"

  # HERE!!!
  # 1. CHECK THAT THERE IS NOT DUPLICATION OF bootfs
  # 2. GATHER THEN DATASETS DYNAMICALLY!
  chroot_execute "perl -i -pe 's|GRUB_CMDLINE_LINUX=\"\K|root=ZFS=$v_rpool_name/ROOT bootfs=$c_bpool_name/BOOT/ROOT |' /etc/default/grub"

  # Silence warning during the grub probe (source: https://git.io/JenXF).
  #
  chroot_execute "echo 'GRUB_DISABLE_OS_PROBER=true'                                    >> /etc/default/grub"

  # Simplify debugging, but most importantly, disable the boot graphical interface: text mode is
  # required for the passphrase to be asked, otherwise, the boot stops with a confusing error
  # "filesystem [...] can't be mounted: Permission Denied".
  #
  chroot_execute "perl -i -pe 's/(GRUB_TIMEOUT_STYLE=hidden)/#\$1/'                        /etc/default/grub"
  chroot_execute "perl -i -pe 's/^(GRUB_HIDDEN_.*)/#\$1/'                                  /etc/default/grub"
  chroot_execute "perl -i -pe 's/GRUB_TIMEOUT=\K0/5/'                                      /etc/default/grub"
  chroot_execute "perl -i -pe 's/GRUB_CMDLINE_LINUX_DEFAULT=.*\Kquiet//'                   /etc/default/grub"
  chroot_execute "perl -i -pe 's/GRUB_CMDLINE_LINUX_DEFAULT=.*\Ksplash//'                  /etc/default/grub"
  chroot_execute "perl -i -pe 's/#(GRUB_TERMINAL=console)/\$1/'                            /etc/default/grub"
  chroot_execute 'echo "GRUB_RECORDFAIL_TIMEOUT=5"                                      >> /etc/default/grub'

  # A gist on GitHub (https://git.io/JenXF) manipulates `/etc/grub.d/10_linux` in order to allow
  # GRUB support encrypted ZFS partitions. This hasn't been a requirement in all the tests
  # performed on 18.04, but it's better to keep this reference just in case.

  chroot_execute "update-grub"
}

function configure_remaining_settings_Debian {
  configure_remaining_settings

  echo "ALMOST FINISHED! Press any key..."
  read -rsn1
}
