# macOS Ventura STIG V1R2 Script

This repository contains a script designed to automate the hardening process for macOS Ventura as per the Security Technical Implementation Guide (STIG) V1R2.

## Description

The script addresses a number of configuration and security settings, making it easier for system administrators and security professionals to ensure that macOS Ventura installations are compliant with the latest STIG recommendations.

Main functionalities:
- Retrieves audit directories.
- Disables specific services.
- Configures SSH for security.
- Sets up audit configurations.
- Adjusts network configurations.
- Creates system banners.
- Removes Access Control Lists (ACLs) from log files and folders.
- (Optionally) Configures PAM for Smart Card authentication.

## Prerequisites

- A system running macOS Ventura.
- Proper administrative privileges to execute the script.
- Installation of all configuration profiles from [STIG Downloads](https://public.cyber.mil/stigs/downloads/).

## Usage

1. Clone this repository:
   `git clone https://github.com/CraigOpie/macOS_Ventura_STIG.git`

2. Navigate to the directory containing the script:
   `cd macOS_Ventura_STIG.git/src`

3. Give the script execute permissions:
   `chmod +x macos_ventura_stig_v1r2.sh`

4. Run the script:
   `./macos_ventura_stig_v1r2.sh`

   If you want to enable Smart Card authentication configurations, use:
   `./macos_ventura_stig_v1r2.sh --set-cac`

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is open source, released under the [MIT License](https://opensource.org/licenses/MIT).

## Author

**Craig Opie**

---

Note: Always test scripts in a controlled environment before deploying in production.
