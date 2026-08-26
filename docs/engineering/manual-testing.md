# M0 Manual Testing

## Purpose

Confirm that the foundation is usable by a developer before UI/audio work starts.

## Checklist

- [ ] Clone the repository.
- [ ] Confirm `README.md` explains MVP scope and validation.
- [ ] Run `make help` and confirm available commands are listed.
- [ ] Run `make check` and confirm all automated checks pass.
- [ ] Run `make manual-m0` and confirm this checklist is printed.
- [ ] Review OpenSpec retained specs for product, music theory, gameplay, security/privacy, and validation.
- [ ] Confirm no account, cloud, microphone, analytics, payment, or network feature is present in M0.

## Expected result

M0 passes when the repository can be validated locally and the next milestone can begin from a clear iOS-first, offline-first, SDD/TDD/IDD baseline.
