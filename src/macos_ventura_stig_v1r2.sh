#!/bin/bash
# This script was created by Craig Opie and is licensed under the MIT license.

# Function to retrieve audit directories
get_audit_dirs() {
    /usr/bin/sudo /usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}'
}

# Disabling services and setting SSH configurations
echo "Disabling services..."
/usr/bin/sudo /bin/launchctl disable system/com.apple.tftpd

echo "Setting SSH configurations..."
STIG_SSH_CONFIG="/private/etc/ssh/ssh_config.d/stig_config"
echo -n "" | /usr/bin/sudo tee $STIG_SSH_CONFIG > /dev/null
/usr/bin/sudo /usr/bin/grep -q '^Ciphers' $STIG_SSH_CONFIG && /usr/bin/sudo /usr/bin/sed -i.bak 's/^Ciphers.*/Ciphers aes128-gcm@openssh.com/' $STIG_SSH_CONFIG || echo "Ciphers aes128-gcm@openssh.com" | /usr/bin/sudo tee -a $STIG_SSH_CONFIG > /dev/null
/usr/bin/sudo /usr/bin/grep -q '^MACs' $STIG_SSH_CONFIG && /usr/bin/sudo /usr/bin/sed -i.bak 's/^MACs.*/MACs hmac-sha2-256/' $STIG_SSH_CONFIG || echo "MACs hmac-sha2-256" | /usr/bin/sudo tee -a $STIG_SSH_CONFIG > /dev/null
/usr/bin/sudo /usr/bin/grep -q '^KexAlgorithms' $STIG_SSH_CONFIG && /usr/bin/sudo /usr/bin/sed -i.bak 's/^KexAlgorithms.*/KexAlgorithms ecdh-sha2-nistp256/' $STIG_SSH_CONFIG || echo "KexAlgorithms ecdh-sha2-nistp256" | /usr/bin/sudo tee -a $STIG_SSH_CONFIG > /dev/null

echo "Setting audit configurations..."
/usr/bin/sudo /usr/bin/sed -i.bak 's/.*expire-after.*/expire-after:7d/' /etc/security/audit_control; /usr/bin/sudo /usr/sbin/audit -s
/usr/bin/sudo /usr/bin/sed -i.bak 's/.*minfree.*/minfree:25/' /etc/security/audit_control; /usr/bin/sudo /usr/sbin/audit -s

echo "Setting network configurations..."
/usr/bin/sudo /usr/sbin/systemsetup -setusingnetworktime on
/usr/bin/sudo /usr/sbin/systemsetup -setnetworktimeserver "server"

# Creating banner files
echo "Setting up banners..."
echo "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.
By using this IS (which includes any device attached to this IS), you consent to the following conditions:
- The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to,
penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE),
and counterintelligence (CI) investigations.
- At any time, the USG may inspect and seize data stored on this IS.
- Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception,
and search, and may be disclosed or used for any USG-authorized purpose.
- This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your
personal benefit or privacy.
- Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or
monitoring of the content of privileged communications, or work product, related to personal representation or services
by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and
confidential. See User Agreement for details." | /usr/bin/sudo tee /etc/banner /Library/Security/PolicyBanner.rtfd > /dev/null

/usr/bin/sudo /usr/bin/sed -i.bak 's/^#Banner.*/Banner \/etc\/banner/' /etc/ssh/sshd_config
/usr/bin/sudo /bin/chmod 644 /Library/Security/PolicyBanner.rtfd

# Check for and potentially remove ACLs on log files
echo "Checking and removing ACLs on log files..."
ACL_FILES=$(/usr/bin/sudo /bin/ls -le $(/usr/bin/sudo /usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/grep -v current | /usr/bin/grep -E "0: group:" | /usr/bin/awk '{print $NF}')
for file in $ACL_FILES; do
    /usr/bin/sudo /bin/chmod -N "$file"
done

# Verify and potentially remove ACLs on log folders
echo "Verifying and removing ACLs on log folders..."
LOG_FOLDERS=$(get_audit_dirs)
for folder in $LOG_FOLDERS; do
    ACL_CHECK=$(/usr/bin/sudo /bin/ls -lde "$folder" | /usr/bin/grep "0: group:")
    if [ ! -z "$ACL_CHECK" ]; then
        /usr/bin/sudo /bin/chmod -N "$folder"
        echo "Removed ACL from $folder."
    else
        echo "No ACL found on $folder."
    fi
done

# Check if the user provided the --set-cac argument
if [ "$1" == "--set-cac" ]; then
    echo "Setting up CAC authentication..."
    # Backup and update /etc/pam.d/login
    /usr/bin/sudo /bin/cp /etc/pam.d/login /etc/pam.d/login_backup_$(date "+%Y-%m-%d_%H:%M")
    echo "# login: auth account password session
    auth    sufficient    pam_smartcard.so
    auth    optional    pam_krb5.so use_kcminit
    auth    optional    pam_ntlm.so try_first_pass
    auth    optional    pam_mount.so try_first_pass
    auth    required    pam_opendirectory.so try_first_pass
    auth    required    pam_deny.so
    account  required    pam_nologin.so
    account  required    pam_opendirectory.so
    password  required    pam_opendirectory.so
    session  required    pam_launchd.so
    session  required    pam_uwtmp.so
    session  optional    pam_mount.so" | /usr/bin/sudo tee /etc/pam.d/login > /dev/null

    # Backup and update /etc/pam.d/su
    /usr/bin/sudo /bin/cp /etc/pam.d/su /etc/pam.d/su_backup_$(date "+%Y-%m-%d_%H:%M")
    echo "# su: auth account session
    auth    sufficient    pam_smartcard.so
    auth    required    pam_rootok.so
    account    required    pam_group.so no_warn group=admin,wheel ruser root_only fail_safe
    account   required    pam_opendirectory.so no_check_shell
    password  required    pam_opendirectory.so
    session   required    pam_launchd.so" | /usr/bin/sudo tee /etc/pam.d/su > /dev/null

    # Backup and update /etc/pam.d/sudo
    /usr/bin/sudo /bin/cp /etc/pam.d/sudo /etc/pam.d/sudo_backup_$(date "+%Y-%m-%d_%H:%M")
    echo "# sudo: auth account password session
    auth    sufficient    pam_smartcard.so
    auth    required    pam_opendirectory.so
    auth    required    pam_deny.so
    account    required    pam_permit.so
    password    required    pam_deny.so
    session    required    pam_permit.so" | /usr/bin/sudo tee /etc/pam.d/sudo > /dev/null
fi

echo "Configure the macOS system with a firmware password with the following command: /usr/bin/sudo /usr/sbin/firmwarepasswd -setpasswd and then restart your system."
