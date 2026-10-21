# Homelab WireGuard Hosts

Euclid is the WireGuard hub for private homelab traffic.

```text
euclid    10.100.0.1
new hosts 10.100.0.x
```

Use this network for server-to-server traffic such as Hawser agents and database connections. Do not expose database ports on public or LAN interfaces.

## Euclid

Euclid is configured in `modules/hosts/euclid/default.nix` with:

```nix
services.homelabWireguard = {
  enable = true;
  address = "10.100.0.1/24";
  privateKeySecret = "wireguard/euclid/private_key";
};
```

The module opens UDP `51820` for WireGuard. Euclid allows these internal TCP ports only on `wg0`:

```text
3000  Dockhand agent endpoint
3306  MariaDB/MySQL
5432  PostgreSQL
```

## Generate Keys

Generate one keypair per host. Run this on a trusted machine:

```bash
umask 077
mkdir -p /tmp/wireguard-keys
wg genkey | tee /tmp/wireguard-keys/<host>.key | wg pubkey > /tmp/wireguard-keys/<host>.pub
```

Example for Euclid:

```bash
umask 077
mkdir -p /tmp/wireguard-keys
wg genkey | tee /tmp/wireguard-keys/euclid.key | wg pubkey > /tmp/wireguard-keys/euclid.pub
```

The `.key` file is private. Store it in `sops`. The `.pub` file is public and can be pasted into Nix peer config.

## Add Euclid Private Key To Sops

Add this secret to `secrets.yaml`:

```yaml
wireguard:
  euclid:
    private_key: <contents of /tmp/wireguard-keys/euclid.key>
```

Use `sops secrets.yaml` so the value is encrypted before committing.

The Nix secret path must match:

```text
wireguard/euclid/private_key
```

## Add A New Host

Generate the new host keypair:

```bash
umask 077
mkdir -p /tmp/wireguard-keys
wg genkey | tee /tmp/wireguard-keys/<host>.key | wg pubkey > /tmp/wireguard-keys/<host>.pub
```

Add the new host private key to `secrets.yaml`:

```yaml
wireguard:
  <host>:
    private_key: <contents of /tmp/wireguard-keys/<host>.key>
```

Add the host as a peer on Euclid:

```nix
services.homelabWireguard.peers = [
  {
    publicKey = "<host public key>";
    allowedIPs = ["10.100.0.2/32"];
  }
];
```

Use a unique `/32` address for each host.

## New Host Config Example

The remote host should use Euclid as its only WireGuard peer:

```nix
services.homelabWireguard = {
  enable = true;
  address = "10.100.0.2/24";
  privateKeySecret = "wireguard/<host>/private_key";

  peers = [
    {
      publicKey = "<euclid public key>";
      allowedIPs = ["10.100.0.0/24"];
      endpoint = "euclid.<your-domain>:51820";
      persistentKeepalive = 25;
    }
  ];
};
```

If Euclid has a stable LAN address, the endpoint can be the LAN address instead:

```nix
endpoint = "192.168.1.10:51820";
```

## Hawser

Euclid uses localhost because Dockhand runs on the same host:

```nix
services.hawser.dockhandServerUrl = "ws://127.0.0.1:3000/api/hawser/connect";
```

Remote hosts should use Euclid's WireGuard address:

```nix
services.hawser.dockhandServerUrl = "ws://10.100.0.1:3000/api/hawser/connect";
```

or the local host alias:

```nix
services.hawser.dockhandServerUrl = "ws://euclid.wg:3000/api/hawser/connect";
```

Each Hawser agent also needs its own token under:

```text
dockhand/hawser_tokens/<host>
```

## Databases

PostgreSQL listens on localhost and Euclid's WireGuard address:

```text
127.0.0.1
::1
10.100.0.1
```

MariaDB listens on IPv4 interfaces so localhost keeps working, but the firewall only allows remote access through `wg0`:

```text
127.0.0.1
10.100.0.1
```

Remote database URLs should use `10.100.0.1` or `euclid.wg`, not the public domain.

## Verify

After deploying Euclid, check the interface:

```bash
sudo wg show
ip addr show wg0
```

From a remote host after it is added:

```bash
ping 10.100.0.1
nc -vz 10.100.0.1 5432
nc -vz 10.100.0.1 3000
```

If handshakes fail, check:

```bash
sudo wg show
sudo journalctl -u wireguard-wg0.service
```
