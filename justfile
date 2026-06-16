host := `hostname`

try-mwm:
    nix develop . --command bash -c "just -d ./pkgs/mwm/ --justfile ./pkgs/mwm/justfile try"

mwm:
    nix develop . --command bash -c "just -d ./pkgs/mwm/ --justfile ./pkgs/mwm/justfile"

build:
    sudo nixos-rebuild build --flake .#{{host}}

test:
    sudo nixos-rebuild test --flake .#{{host}}

switch:
    sudo nixos-rebuild switch --flake .#{{host}}

boot:
    sudo nixos-rebuild boot --flake .#{{host}}

list-generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

cleanup:
    nix-collect-garbage

clean:
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
    sudo nix-env --delete-generations old

update:
    nix-channel --update
    u
    sudo nixos-rebuild switch --flake .#{{host}}

jq:
    nix develop . --command bash -c "find ./build -name 'compile_commands.json' -exec cat {} + | jq -s add > compile_commands.json"
