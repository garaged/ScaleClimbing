# Contributing

## Required workflow

1. Start from an intent or issue.
2. Update OpenSpec for observable behavior changes.
3. Add tests before or with implementation.
4. Run `make check` locally.
5. Open PRs as draft until the feature is complete and validated.

## Commands

```bash
make help
make check
make test
make smoke
make specs
make security
make manual-m0
```

## Security expectations

Do not commit secrets, signing material, generated build artifacts, or personal data. Do not add network, analytics, microphone, purchase, or cloud-sync behavior without an explicit spec and security/privacy review.
