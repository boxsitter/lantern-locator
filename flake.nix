{
  description = "Python Development Environment";

  # REQUIREMENTS:
  # - A requirements.txt file should exist with locked (pinned) dependencies.
  #   If you don't have one yet, generate it after installing your packages:
  #
  #     pip install <package>
  #     pip freeze > requirements.txt
  #
  # USAGE:
  # 1. Run: nix develop
  # 2. Install packages: pip install -r requirements.txt
  # 3. After adding new packages: pip freeze > requirements.txt

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";  # Options: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Python interpreter - adjust version as needed
          python311
          stdenv.cc.cc.lib  # C standard library (needed for many compiled packages)

          # Uncomment system libraries as needed by your packages:
          # libffi            # Foreign Function Interface library
          # openssl           # SSL/TLS support
        ];

        # To expose system libraries at runtime for compiled packages, add to shellHook:
        shellHook = ''
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath (with pkgs; [ stdenv.cc.cc.lib openssl ])};
          # Create and activate a project-local virtual environment
          if [ ! -d .venv ]; then
            echo "Creating Python virtual environment..."
            python3 -m venv .venv
          fi
          source .venv/bin/activate

          # Install from requirements.txt only when it has changed
          if [ ! -f requirements.txt ]; then
            echo ""
            echo "⚠️  WARNING: requirements.txt not found!"
            echo "   Create one to track your locked dependencies:"
            echo "     pip install <package> && pip freeze > requirements.txt"
            echo ""
          else
            # Warn about any unpinned package lines (no version specifier)
            if grep -vE '^\s*#|^\s*$' requirements.txt | grep -qvE '(==|>=|<=|~=|!=)'; then
              echo ""
              echo "⚠️  WARNING: requirements.txt has unpinned dependencies."
              echo "   Lock them for reproducibility:"
              echo "     pip install -r requirements.txt && pip freeze > requirements.txt"
              echo ""
            fi
            REQS_HASH=$(sha256sum requirements.txt | cut -d' ' -f1)
            HASH_FILE=".venv/.reqs_hash"
            if [ ! -f "$HASH_FILE" ] || [ "$(cat $HASH_FILE)" != "$REQS_HASH" ]; then
              echo "Installing dependencies..."
              pip install -r requirements.txt --quiet
              echo "$REQS_HASH" > "$HASH_FILE"
            fi
          fi

          # Project-specific environment variables — uncomment and set as needed:
          # export DATABASE_URL="postgresql://localhost/mydb"
          # export DEBUG="true"
          # export APP_ENV="development"

          echo "✓ Python environment ready  ($(python --version))"
        '';
      };
    };
}
