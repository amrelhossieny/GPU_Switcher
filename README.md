
---

# GPU Switcher 🚀

Easily take control of your hybrid GPU setup on Linux! This powerful Bash script detects and switches between available GPUs, making it a breeze to toggle between your NVIDIA and Intel graphics. With a sleek typewriter effect and detailed logging, GPU management has never been this smooth. Perfect for power users and developers who need to optimize their GPU configuration on the fly. Say goodbye to manual GPU switching and hello to seamless performance!

### Supported Operating Systems 🖥️
This script is designed to work on **Linux distributions** that support GPU switching, particularly those that use the `prime-select` tool for managing GPUs. It has been tested on:
- **Ubuntu** (and derivatives like Linux Mint)
- **Debian**
- **Pop!_OS**
- Other distributions that support `prime-select` or similar tools.

### Supported GPUs 🎮
The script currently supports the following types of GPUs:
- **NVIDIA GPUs**: Seamlessly switch between integrated and discrete NVIDIA GPUs using `prime-select`.
- **Intel Integrated GPUs**: Commonly found in laptops with hybrid graphics setups, easily managed by the script.
- **AMD GPUs**: The script detects AMD GPUs but does not support switching them. Users are advised to use the appropriate AMD tools for GPU management.

### Not Recommended For 🚫
This script may not be suitable for:
- **AMD-only systems**: While AMD GPUs are detected, the script does not support switching them. Users with AMD GPUs should use tools like `amdgpu-pro` or `radeon-profile`.
- **Systems without `prime-select` or similar tools**: If your system lacks `prime-select` or a similar GPU management tool, this script may not function as intended.
- **Systems with non-standard or custom GPU setups**: Unique or custom GPU configurations may not be correctly detected or switched by this script.
- **Users unfamiliar with command-line operations**: The script requires some familiarity with the terminal and may require administrative privileges (e.g., `sudo`) to switch GPUs.

---
