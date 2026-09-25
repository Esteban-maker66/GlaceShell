# Contributing to Glacé Shell

First off, thank you for considering contributing to Glacé Shell! Contributions are what make the open-source community an amazing place to learn, inspire, and create.

Glacé Shell is a personal dotfiles project released as a demo. Contributions that keep it portable, documented and easy to install are especially welcome.

## How Can I Contribute?

### 1. Reporting Bugs
- Check the [Issues tab](https://github.com/Esteban-maker66/GlaceShell/issues) to see if the bug has already been reported.
- If not, open a new issue. Include your system specs (Distro, Display Server/Compositor, Qt/SDDM version) and step-by-step instructions to reproduce the behavior.
- For anything that depends on `glaceBridge`, also paste the output of `systemctl --user status glace-ipc.service` and, if useful, the log from `journalctl --user -u glace-ipc.service`.

### 2. Suggesting Enhancements
- Feature requests are welcome! Please explain why the feature would be useful and how it fits into the overall glassmorphic design language.

### 3. Submitting Pull Requests (PRs)
1. **Fork the repository** and create your branch from `master`:
   ```bash
   git checkout -b feature/my-new-feature
   ```
2. **Make your changes**, following [STYLE.md](STYLE.md) for QML structure, naming and design tokens.
3. **Run the checks before pushing**:
   ```bash
   scripts/maintenance/check-portability.sh
   ```
   The [Portability workflow](.github/workflows/portability.yml) runs the same check plus a shell syntax check, a systemd unit verification and a dry-run of `setup/install.sh` on every push and pull request. A red CI means the PR cannot be merged.
4. **Update the documentation** if your change is visible to users. `COMPONENT-SPEC.md` documents every component's properties, and `ARCHITECTURE.md` describes the directory layout. New components must be added to `config/quickshell/components/qmldir` and documented.
5. **Open the PR** describing what changed and why. Small, focused PRs are much easier to review.

### 4. Adding a Component
- Create the file as `config/quickshell/components/PascalCase.qml`.
- Register it in `config/quickshell/components/qmldir` with a `Name 1.0 Name.qml` line.
- Resolve every asset with `Qt.resolvedUrl`. Absolute paths are rejected by the portability check.
- Add a section to `COMPONENT-SPEC.md` with a property table, the defaults and any behavioral notes.
- Add a usage example to `test/testBench.qml` so it can be previewed without SDDM.

## Commit Conventions
Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) style:

```text
feat(components): add weather condition icons for fog
fix(ipc): fall back to the previous volume when unmuting
docs(readme): document the SDDM_THEME_ROOT override
style(quickdock): align the action list with the design tokens
```

Use `feat`, `fix`, `docs`, `style`, `refactor`, `perf` or `chore` as the type.
Keep the subject in the imperative mood and under 72 characters.

## Code of Conduct
Be respectful and constructive. Discussions happen in issues and pull requests, so keep them focused on the code and assume good intent.

## License
By contributing you agree that your contributions will be licensed under the [GPL-3.0-or-later](LICENSE) license of this project.
