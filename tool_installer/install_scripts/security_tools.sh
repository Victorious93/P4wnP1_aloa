#!/bin/bash
# Security research and penetration testing tools
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
TOOL_ID="${1:-}"

install_nmap() {
  echo "[sec] Installing nmap..."
  apt-get install -y --no-install-recommends nmap
  echo "[sec] nmap installed."
}

install_masscan() {
  echo "[sec] Installing masscan..."
  apt-get install -y --no-install-recommends masscan
  echo "[sec] masscan installed."
}

install_nikto() {
  echo "[sec] Installing nikto..."
  apt-get install -y --no-install-recommends nikto
  echo "[sec] nikto installed. Usage: nikto -h http://target/"
}

install_sqlmap() {
  echo "[sec] Installing sqlmap..."
  apt-get install -y --no-install-recommends sqlmap
  echo "[sec] sqlmap installed. Usage: sqlmap -u 'http://target/page?id=1'"
}

install_hydra() {
  echo "[sec] Installing Hydra..."
  apt-get install -y --no-install-recommends hydra
  echo "[sec] Hydra installed."
}

install_john() {
  echo "[sec] Installing John the Ripper..."
  apt-get install -y --no-install-recommends john
  echo "[sec] John the Ripper installed."
}

install_hashcat() {
  echo "[sec] Installing hashcat..."
  apt-get install -y --no-install-recommends hashcat
  echo "[sec] hashcat installed (CPU mode on Pi Zero)."
}

install_metasploit() {
  echo "[sec] Installing Metasploit Framework..."
  echo "[sec] WARNING: Metasploit requires ~1.5GB disk space."
  if which msfconsole >/dev/null 2>&1; then
    echo "[sec] Metasploit already installed."
    return
  fi
  apt-get install -y --no-install-recommends ruby ruby-dev libpcap-dev libpq-dev \
    postgresql postgresql-client build-essential
  gem install bundler --no-document 2>/dev/null || true
  cd /opt
  git clone --depth=1 https://github.com/rapid7/metasploit-framework.git 2>/dev/null || true
  cd metasploit-framework
  bundle install --without development test 2>/dev/null || true
  ln -sf /opt/metasploit-framework/msfconsole /usr/local/bin/msfconsole 2>/dev/null || true
  ln -sf /opt/metasploit-framework/msfvenom /usr/local/bin/msfvenom 2>/dev/null || true
  echo "[sec] Metasploit installed at /opt/metasploit-framework/"
}

install_impacket() {
  echo "[sec] Installing impacket..."
  apt-get install -y --no-install-recommends python3-impacket 2>/dev/null || \
    pip3 install impacket
  echo "[sec] impacket installed."
}

install_netcat() {
  echo "[sec] Installing netcat + ncat..."
  apt-get install -y --no-install-recommends netcat-openbsd ncat
  echo "[sec] netcat installed. Usage: nc -lvnp 4444"
}

install_socat() {
  echo "[sec] Installing socat..."
  apt-get install -y --no-install-recommends socat
  echo "[sec] socat installed. Usage: socat TCP-LISTEN:4444,fork EXEC:/bin/bash"
}

install_exploitdb() {
  echo "[sec] Installing ExploitDB (searchsploit)..."
  apt-get install -y --no-install-recommends exploitdb 2>/dev/null || \
    pip3 install searchsploit 2>/dev/null || true
  echo "[sec] searchsploit installed."
}

install_enum4linux() {
  echo "[sec] Installing enum4linux..."
  apt-get install -y --no-install-recommends enum4linux 2>/dev/null || \
    pip3 install enum4linux-ng 2>/dev/null || true
  echo "[sec] enum4linux installed."
}

install_wordlists() {
  echo "[sec] Installing wordlists..."
  apt-get install -y --no-install-recommends wordlists 2>/dev/null || true
  if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    gunzip -k /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true
  fi
  # Download SecLists subset if not present
  if [ ! -d /usr/share/seclists ]; then
    mkdir -p /usr/share/seclists
    git clone --depth=1 --filter=blob:none --sparse \
      https://github.com/danielmiessler/SecLists.git \
      /usr/share/seclists 2>/dev/null || true
  fi
  echo "[sec] Wordlists installed to /usr/share/wordlists/ and /usr/share/seclists/"
}

case "$TOOL_ID" in
  "nmap")         install_nmap ;;
  "masscan")      install_masscan ;;
  "nikto")        install_nikto ;;
  "sqlmap")       install_sqlmap ;;
  "hydra")        install_hydra ;;
  "john")         install_john ;;
  "hashcat")      install_hashcat ;;
  "metasploit")   install_metasploit ;;
  "impacket")     install_impacket ;;
  "netcat")       install_netcat ;;
  "socat")        install_socat ;;
  "exploitdb")    install_exploitdb ;;
  "enum4linux")   install_enum4linux ;;
  "wordlists")    install_wordlists ;;
  *)
    echo "[sec] Unknown tool: $TOOL_ID"
    exit 1
    ;;
esac
