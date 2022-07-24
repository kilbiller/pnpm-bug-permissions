# Repro

pnpm deploy tries to access the /pruned folder which is one level higher than the pnpm workspace root and fails because of permission issues.

Bug

```bash
docker build . -t pnpm_bug --target=release
```

Workaround (by creating /pruned manually)

```bash
docker build . -t pnpm_bug --target=release-fixed
```
