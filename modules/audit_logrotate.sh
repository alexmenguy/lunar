# audit_logrotate
#
# Make sure logrotate is set up appropriately.
#.

audit_logrotate () {
  if [ "$os_name" = "Linux" ]; then
    check_file="/etc/logrotate.d/syslog"
    if [ -f "$check_file" ]; then
      funct_verbose_message "Log Rotate Configuration"
      if [ "$audit_mode" != 2 ]; then
        echo "Checking:  Logrotate is set up"
        total=`expr $total + 1`
        search_string="/var/log/messages /var/log/secure /var/log/maillog /var/log/spooler /var/log/boot.log /var/log/cron"
        check_value=`cat $check_file |grep "$search_string" |sed 's/ {//g'`
        if [ "$check_value" != "$search_string" ]; then
          score=`expr $score - 1`
          if [ "$audit_mode" = 1 ]; then
            echo "Warning:   Log rotate is not configured for $search_string [$score]"
            funct_verbose_message "" fix
            funct_verbose_message "cat $check_file |sed 's,.*{,$search_string {,' > $temp_file" fix
            funct_verbose_message "cat $temp_file > $check_file" fix
            funct_verbose_message "rm $temp_file" fix
            funct_verbose_message "" fix
          fi
          if [ "$audit_mode" = 0 ]; then
            funct_backup_file $check_file
            echo "Removing:  Configuring logrotate"
            cat $check_file |sed 's,.*{,$search_string {,' > $temp_file
            cat $temp_file > $check_file
            rm $temp_file
          fi
        else
          if [ "$audit_mode" = 1 ]; then
            score=`expr $score + 1`
            echo "Secure:    Log rotate is configured [$score]"
          fi
        fi
      else
        funct_restore_file $check_file $restore_dir
      fi
    fi
  fi
}