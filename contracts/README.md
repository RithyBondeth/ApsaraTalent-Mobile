# Gateway API client

`openapi.json` and `scripts/contracts/generate-clients.mjs` are synchronized from the sibling `ApsaraTalent-Api` repository. Do not hand-edit generated SDK files.

```sh
node scripts/contracts/generate-clients.mjs
node scripts/contracts/generate-clients.mjs --check
```

To change the source contract, update the API DTOs/controllers and run `npm run contracts:update` in the API checkout with `API_SPEC_URL` set to a running gateway Swagger URL. Exporting from the API refreshes both sibling SDKs and the web OpenAPI types. Review changes in all three repositories together.

For a real gateway check, run `E2E_CLIENTS=1 npm run test:e2e` from the API repository with Docker and dependencies installed in all three sibling checkouts. The isolated runner invokes both generated clients against one account draft and verifies revision conflict behavior and native OAuth exchange. The API `contracts/README.md` documents the full update and verification workflow.

The generated SDK exposes all 176 HTTP operations. User-facing features, role permissions, file handling, OAuth providers, and realtime delivery still need their own integration checks. SSE/realtime metadata is included in the frozen contract; realtime refresh names are exported by both generators.
