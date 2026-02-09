# ansible-role-os-stack

Ansible role to provision and deprovision OpenStack compute instances via a Heat stack.

This repository is intentionally low-profile and primarily exists for internal/lab automation and Molecule-driven integration testing.

## What it does

- Creates a Heat stack from a rendered template and waits for completion.
- Exposes stack outputs (e.g., instance names / IP addresses) for follow-up automation.
- Deletes the stack during deprovision.

## Requirements

- `ansible-core` and the `openstack.cloud` collection.
- OpenStack credentials available via either:
  - environment variables (OpenRC-style `OS_*`), and/or
  - `clouds.yaml` (`OS_CLIENT_CONFIG_FILE` + `OS_CLOUD`).

## Key variables

- `role_action`: `provision` or `deprovision`.
- `nodes`: list of node definitions (name/image/flavor/keypair/nics/etc.).
- `public_network_name`: name of the external network used for floating IP allocation.
- `os_stack_validate_certs`: defaults to `true` (secure by default).
- `config_file`: optional clouds.yaml path (defaults from `OS_CLIENT_CONFIG_FILE`). The role validates it exists when set.

Notes:

- The Heat stack name/tag is derived from `nodes[0].app_name` (defaults to `stack`).

If you have ambiguous image names in Glance, prefer passing an image **ID** rather than a name.

## Node definitions

This role renders a Heat template from the `nodes` list and then creates/updates a stack.

Validated (fail-fast) fields:

- Required per node: `name`, `flavor`, `key_name`, `nics` (non-empty list)
- Required per nic: `net-name`
- Optional: `os_type` (`linux` or `windows`)

Common useful fields:

- `image`: Glance image name or ID (recommended: ID)
- `app_name`: used for instance metadata and stack naming (first node)
- `role`: used for instance metadata
- `user_data`: literal userdata content (if omitted and `os_type: windows`, the role uses its Windows userdata template)
- `auto_ip`: if omitted or `true`, the stack allocates a floating IP for the first NIC; if `false`, the output uses a fixed IP
- `ansible_port`: included in stack outputs (default: 22 for Linux, 5986 for Windows)
- `block_device_mapping_v2`: passed through to Heat for more complex boot scenarios

## Usage (minimal example)

```yaml
- hosts: localhost
  gather_facts: false
  roles:
    - role: oatakan.os_stack
      vars:
        role_action: provision
        public_network_name: public
        nodes:
          - name: example-1
            os_type: linux
            image: cirros 0.6
            flavor: m1.small
            key_name: my-key
            nics:
              - net-name: private_network
```

## Molecule

This repo uses localhost-only Molecule scenarios that talk to a real OpenStack.

- Default: `./scripts/molecule.sh test -s default`
- Extended: `./scripts/molecule.sh test -s extended`

The wrapper script:

- sources a local `.env` (ignored by git), and
- can optionally source an OpenRC file via `OS_ENV_FILE`.

See [molecule/README.md](molecule/README.md) for environment variables used by the scenarios.

## CI

`ansible-lint` is run via GitHub Actions using `.github/workflows/ansible-lint.yml`.

## Security / secrets

- Do not commit `.env`, OpenRC files, `clouds.yaml`, or any local artifacts; `.gitignore` is configured to ignore these.
- Avoid embedding secrets in `nodes` (especially in any `user_data` fields): validation errors and failed runs may echo portions of the node definition to logs.
- For Windows userdata, providing an administrator password in userdata is inherently sensitive and may be persisted/logged by your OpenStack control plane.
