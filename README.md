# wiz-deployment-0429

Test infrastructure for measuring **Wiz detection latency** on three intentionally permissive AWS resource configurations:

| Phase | Resource | What it tests |
|-------|----------|---------------|
| `phase1-s3-public`            | S3 bucket with anonymous public-read bucket policy | Public exposure detection |
| `phase2-secret-cross-account` | Secrets Manager secret with cross-account read in resource policy | Cross-account access detection |
| `phase3-kms-policy`           | KMS key with resource policy granting Encrypt/Decrypt to specific roles | KMS resource-policy grant detection |

Each phase is an independent Terraform stack with its own remote state.

## Repo layout

```
.
├── Jenkinsfile
└── terraform/
    └── wiz-deployment-0429/
        ├── phase1-s3-public/
        ├── phase2-secret-cross-account/
        └── phase3-kms-policy/
```

## Running a test

1. In Jenkins → **Build with Parameters**:
   - `ACTION` = `apply`
   - `PHASE` = pick one of the three
   - For `phase2-secret-cross-account`: set `EXTERNAL_ACCOUNT_ID` to the AWS account you want to grant cross-account read.
   - For `phase3-kms-policy`: set `TRUSTED_ROLE_ARNS_JSON` to a JSON array of role ARNs, e.g. `["arn:aws:iam::562517367791:role/MyTestRole"]`.
2. When the build goes green, find the `DEPLOYMENT COMPLETE` banner in the console output. Copy:
   - `Apply end` UTC timestamp → this is **t0**.
   - The Terraform outputs (ARNs/names) → search these in Wiz.
   - `WizDeploymentRun=build-<N>` → use this tag to filter Wiz Inventory.
3. In the Wiz console:
   - **Inventory** → filter by Subscription = AWS account `562517367791`, Region = `us-east-1`.
   - Add tag filter `WizDeploymentRun = build-<N>`.
   - First time the resource appears = **t1**. Latency = t1 − t0.
4. Also watch for **Issues** / toxic combinations to fire (separate, longer latency).
5. Tear down with `ACTION=destroy` and the same `PHASE`.

## Important caveats

- **Account-level S3 Block Public Access.** If your AWS account has BPA enabled at the account level, phase 1's bucket policy will be silently overridden and Wiz may not see public exposure. Check **S3 → Block Public Access settings for this account** before running.
- **Don't put real data in any of these.** The secret value is a placeholder; the bucket is intentionally world-readable.
- **State backend.** Reuses `wiz-ciem-tfstate-562517367791` with key prefix `wiz-deployment-0429/<phase>/`.
- **Terraform variables.** The Jenkinsfile exports `TF_VAR_account_id`, `TF_VAR_aws_region`, `TF_VAR_project_name`, `TF_VAR_deployment_id`, and (per-phase) `TF_VAR_external_account_id` / `TF_VAR_trusted_role_arns` automatically — no `-var` flags needed.
