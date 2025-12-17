# 📦 WP-Server-in-a-Box 🚀

**Your journey to a professional WordPress server starts here!**

Welcome to *WP-Server-in-a-Box*, the magic solution that transforms any raw Linux server into a high-performance WordPress fortress with a single command! Ideal for devs, agencies, and digital adventurers.

---

## 🎩 The Philosophy: "Cattle, not Pets" 🐮

Forget about pet servers that need constant cuddling and manual maintenance.
Our infrastructure follows the **Infrastructure as Code (IaC)** mantra. If something goes wrong, destroy and rebuild in seconds. The intelligence is in the code, not the machine!

---

## 🏰 Your Digital Fortress (Architecture)

We build a castle of Docker containers to protect and accelerate your site:

*   **🛡️ The Guardian (Nginx Proxy Manager):** The main gate. Manages traffic, blocks villains, and summons SSL certificates (green padlocks) automatically.
*   **⚙️ The Engine (WordPress + PHP-FPM):** A tuned version of WordPress, battle-ready (with `imagick`, `intl` extensions).
*   **🗄️ The Vault (MariaDB):** Where your most precious data lives securely.

All connected by isolated networks, ensuring that what happens in the database, stays in the database.

---

## 🛠️ What You Need (Prerequisites)

*   🐧 A Linux server (Ubuntu/Debian preferred - even the "bare bones" ones, we handle the rest!).
*   🔑 `root` access or `sudo` privileges.
*   🌐 A domain name pointing to your server's IP.

---

## ⚡ Quick Start: From Zero to Hero

1.  **Download the Spell (Clone the repo):**
    ```bash
    git clone https://github.com/muller-front/wp-server-in-a-box.git
    cd wp-server-in-a-box
    ```

2.  **Configure the Secrets (Optional):**
    If you're lazy (like us), just skip this! The script will ask for your passwords interactively if you don't create the file.
    ```bash
    cp .env.example .env
    nano .env # Optional: Manual configuration
    ```

3.  **Cast the Magic:**
    ```bash
    chmod +x run.sh
    ./run.sh
    ```
    > **✨ Magic Update:**
    > The script automatically installs **Docker** 🐳 using the official, secure script if it's missing. It also handles the `.env` generation for you.

4.  **The Grand Finale:**
    The script will print a clear **"Manual Configuration Guide"** at the end. Follow it to configure your Proxy Host and SSL certificates in the Nginx Proxy Manager interface (Port 81).

---

## 🤖 Your Robotic Assistants (Scripts)

*   **`run.sh`**: The Maestro. Installs dependencies, Docker, Nano, and brings up the entire container orchestra.
*   **`destroy.sh`**: The Panic Button. Tears down and cleans up everything, in case you want to start from scratch.
*   **`set-url.sh`**: The Mechanic. A utility tool to force-fix the site URL in `wp-config.php` if things go south.

---

## 📜 License

Distributed under the MIT License. Use, abuse, modify, and conquer the web!
