# Environment Parameter Files

## Structure
Each environment has its own parameter file:
- `dev/main.parameters.json` → For development deployments
- `test/main.parameters.json` → For test/staging deployments
- `prod/main.parameters.json` → For production deployments

## Key Differences Per Environment

### Dev
- Smallest AKS nodes (1-3 auto-scale range)
- B1 App Service (cheapest)
- Hot storage tier
- 30-day log retention
- Auto-shutdown agent VMs at 19:00 daily

### Test
- Same as dev (learning/testing phase)
- Can be customized independently later

### Prod
- Larger AKS nodes (2-5 auto-scale range, minimum 2)
- P1v2 App Service (premium, SLA-backed)
- Cool storage tier (cost optimization)
- 90-day log retention
- No agent VMs deployed (uses Azure-hosted agents)

## Before Deployment
Replace placeholder values:

1. `alertEmail`: Set to your actual email for alert notifications
2. `costCenter`: Adjust to your organization's cost center code
3. `owner`: Update to your name/team

## Usage
See `DEPLOY_EXAMPLES.md` for exact deployment commands.
