# Molecule

This role can be tested against a *local OpenStack* by using Molecule's `delegated` driver.

Key goals:

- No local OpenStack credentials/config are checked into git.
- Tests run on `localhost` and use your existing OpenStack auth via environment variables.

## Prereqs

- `molecule` installed in your environment
- `openstack.cloud` collection available (already required by the role)
- Your OpenStack auth configured locally (e.g. via `OS_CLIENT_CONFIG_FILE` + `OS_CLOUD`, or env vars)

## Run

Example (adapt values to your cloud):

```bash
# Activate your Python environment that has molecule installed
# source .venv/bin/activate

export OS_CLIENT_CONFIG_FILE=~/.config/openstack/clouds.yaml
export OS_CLOUD=mycloud

export OS_STACK_IMAGE="<image name>"
export OS_STACK_FLAVOR="<flavor name>"
export OS_STACK_KEYPAIR="<keypair name>"
export OS_STACK_PUBLIC_NETWORK="public"
export OS_STACK_PRIVATE_NETWORK="private_network"

# Optional: create multiple baseline nodes (molecule1..moleculeN)
# export OS_STACK_BASE_COUNT=2

molecule test -s default
```

## Profiles

This repo ships two Molecule scenarios:

- `default`: provisions a single small instance (defaults to `cirros 0.6`).
- `extended`: still provisions the baseline node, and can *optionally* add extra nodes for additional OS families.

The `extended` scenario is designed to be environment-safe:

- No image names are committed.
- Extra nodes are only added when you provide image names or selection patterns via env vars.
- If a pattern matches nothing, that category is silently skipped.

Run extended:

```bash
molecule test -s extended
```

Extended image selection env vars (all optional):

- Exact names:
	- `OS_STACK_IMAGE_RHEL`
	- `OS_STACK_IMAGE_UBUNTU`
	- `OS_STACK_IMAGE_WIN_SERVER`
	- `OS_STACK_IMAGE_WIN_DESKTOP`
- Or best-effort patterns (regex applied to available image names):
	- `OS_STACK_IMAGE_PATTERN_RHEL`
	- `OS_STACK_IMAGE_PATTERN_UBUNTU`
	- `OS_STACK_IMAGE_PATTERN_WIN_SERVER`
	- `OS_STACK_IMAGE_PATTERN_WIN_DESKTOP`

For Windows nodes, provide flavors explicitly (otherwise they are skipped):

- `OS_STACK_FLAVOR_WIN_SERVER`
- `OS_STACK_FLAVOR_WIN_DESKTOP`

Notes:

- `converge` provisions a Heat stack.
- `verify` checks that the stack exists.
- `destroy` deprovisions the stack.

If you want to avoid any provisioning, run just linting:

```bash
molecule lint -s default
```
