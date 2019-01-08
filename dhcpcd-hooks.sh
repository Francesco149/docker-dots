# this is only for my openrc parabola thinkpad at the moment
if $if_up; then
  /etc/init.d/ntpd start
else
  /etc/init.d/ntpd stop
fi
