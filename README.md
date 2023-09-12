# macOS Ventura STIG V1R2 Script

This repository contains a script designed to automate the hardening process for macOS Ventura as per the Security Technical Implementation Guide (STIG) V1R2.

## Description

The script addresses a number of configuration and security settings, streamlining the process for system administrators and security professionals to ensure macOS Ventura installations are compliant with the latest STIG recommendations.

Main functionalities:
- Retrieves audit directories.
- Disables specific services.
- Configures SSH for security.
- Sets up audit configurations.
- Adjusts network configurations.
- Creates system banners.
- Removes Access Control Lists (ACLs) from log files and folders.
- (Optionally) Configures PAM for Smart Card authentication.
- Installs provided configuration profiles.

## Prerequisites

- A system running macOS Ventura.
- Proper administrative privileges to execute the script.
- Installation of all configuration profiles from [STIG Downloads](https://public.cyber.mil/stigs/downloads/).

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/CraigOpie/macOS_Ventura_STIG.git
   ```

2. Navigate to the directory containing the script:
   ```bash
   cd macOS_Ventura_STIG.git/src
   ```

4. Give the script execute permissions:
   ```bash
   chmod +x macos_ventura_stig_v1r2.sh
   ```

6. Run the script:
   ```bash
   ./macos_ventura_stig_v1r2.sh
   ```

   If you want to enable Smart Card authentication configurations, use:
   ```bash
   ./macos_ventura_stig_v1r2.sh --set-cac
   ```

   To install profiles from a directory, use:
   ```bash
   ./macos_ventura_stig_v1r2.sh --set-profiles "/path/to/directory_with_mobileconfigs"
   ```

   To combine both the above functionalities:
   ```bash
   ./macos_ventura_stig_v1r2.sh --set-cac --set-profiles "/path/to/directory_with_mobileconfigs"
   ```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is open source, released under the [MIT License](https://opensource.org/licenses/MIT).

## Author

**Craig Opie**

---

Note: Always test scripts in a controlled environment before deploying in production.
